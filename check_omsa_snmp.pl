#! /usr/bin/perl -w
#
# snmp check for the Dell Poweredge Series
# requires the OMSA snmp sub agent to run on the remote side
# and perl Net-SNMP to be installed on the nagios server host
################################################################################
# if you feel uncertain about the status of your agent installation, here is a short test:
# snmpwalk -v 2c -c YOURCOMMUNITY HOSTNAME .1.3.6.1.4.1.674.10892.1.700.20.1.8.1
# Result might be sth. like this:
#
# SNMPv2-SMI::enterprises.674.10892.1.700.20.1.8.1.1 = STRING: "ESM Frt I/O Temp"
# SNMPv2-SMI::enterprises.674.10892.1.700.20.1.8.1.2 = STRING: "ESM Riser Temp"
# SNMPv2-SMI::enterprises.674.10892.1.700.20.1.8.1.3 = STRING: "ESM CPU 1 Temp"
# SNMPv2-SMI::enterprises.674.10892.1.700.20.1.8.1.4 = STRING: "ESM CPU 2 Temp"
# SNMPv2-SMI::enterprises.674.10892.1.700.20.1.8.1.5 = STRING: "BP Bottom Temp"
# SNMPv2-SMI::enterprises.674.10892.1.700.20.1.8.1.6 = STRING: "BP Top Temp"
#
################################################################################
# Author:  Steffen Roegner, http://www.sroegner.de
# Created: 11. October 2006
################################################################################
 
use strict;
use Getopt::Long;
use Net::SNMP;
use lib "/usr/lib64/nagios/plugins";
use utils qw(%ERRORS &print_revision &support &usage);
use vars qw($opt_V $opt_h $opt_P $opt_C $opt_H @opt_groups $PROGNAME);

$PROGNAME = "check_omsa_snmp";

# This is the status table for 'normal' on/off units, like a power supply
my %DellStatus = ( '1' => 'other', '2' => 'unknown', '3' => 'ok', '4' => 'nonCritical', '5' => 'critical' );

# This status table for the sensor probes, which have a upper and lower range of values that are ok, noncritical, so on.
my %DellStatusProbe = ( 1  => 'other',
                        2  => 'unknown',
	                    3  => 'ok',
	                    4  => 'nonCriticalUpper',
	                    5  => 'CriticalUpper',
	                    6  => 'nonRecoverableUpper',
	                    7  => 'nonCriticalLower',
	                    8  => 'criticalLower',
	                    9  => 'nonRecoverableLower',
	                    10 => 'failed'
                       );
										
# the base oid for all Groups
my $DellOID = '1.3.6.1.4.1.674.10892.1';

my %PowerSupplyTable  = ( 'baseoid'     => $DellOID . '.600.12', 
                          'statusid'    => '.1.5', 
                          'typeid'      => '.1.7',
                          'locationid'  => '.1.8', 
                          'statustable' => \%DellStatus
                        );
                       
my %VoltageProbeTable = ( 'baseoid' => $DellOID . '.600.20', 
                          'statusid' => '.1.5', 
                          'typeid'   => '.1.7',
                          'locationid' => '.1.8', 
                          'statustable' => \%DellStatusProbe
                        );

my %CoolingDeviceTable = ( 'baseoid'     => $DellOID . '.700.12', 
                           'statusid'    => '.1.5', 
                           'locationid'  => '.1.8', 
                           'statustable' => \%DellStatus 
                         );

my %TemperatureProbeTable = ( 'baseoid'     => $DellOID . '.700.20', 
                           'statusid'    => '.1.5', 
                           'typeid'      => '.1.7',
                           'locationid'  => '.1.8', 
                           'statustable' => \%DellStatus 
                         );

my %AllOMSATables         = (  "PowerSupply"     => \%PowerSupplyTable,
                            "VoltageProbe"    => \%VoltageProbeTable,
                            "CoolingDevice"   => \%CoolingDeviceTable,
                            "TemperaturProbe" => \%TemperatureProbeTable
			 );

sub print_help ();
sub print_usage ();
sub getSession ($$$);
sub getTable($$);
sub getSingleValue($$);
sub printHash($);
sub shortCheck($);
sub handleReturnCode($);
sub listGroups();

Getopt::Long::Configure('bundling');
GetOptions
        ("V"   => \$opt_V, "version"    => \$opt_V,
         "h"   => \$opt_h, "help"       => \$opt_h,
         "P=s" => \$opt_P, "Port=s"  => \$opt_P,
         "H=s" => \$opt_H, "hostname=s" => \$opt_H,
         "G=s" => \@opt_groups, "groups=s" => \@opt_groups,
         "C=s" => \$opt_C, "community=s" => \$opt_C);

if ($opt_V) {
	print_revision($PROGNAME,'$Revision: 0.6 $');
	exit $ERRORS{'OK'};
}

if ($opt_h) {
	print_help();
	exit $ERRORS{'OK'};
}

# Preparing for the default (@opt_groups needs to be undefined)
my @groups = ("All");

if (defined @opt_groups) {
	@groups = ();  
    for (split(/,/, join(',', @opt_groups))){
  		my $val = $_;
    	if(defined $AllOMSATables{$val}) {
    		@groups = (@groups, $val);
    	}
    	elsif ($val =~ /all$/i){
    		@groups = ("all");
    		last;
    	}
    	else{
    		print "Group unknown: '$_'. Avaliable Groups are ";
    		for (listGroups()){ print "$_, "; }
    		print "All (default)\n";
    		exit $ERRORS{'UNKNOWN'};
    	}
    }
    if (@groups == 0){ @groups = ("All") }
}

# serving the default (all Probes)
if ($groups[0] =~ /all$/i) { @groups = listGroups() }

($opt_H) || ($opt_H = shift) || usage("Host name not specified\n");
my $host = $1 if ($opt_H =~ /^([-_.A-Za-z0-9]+\$?)$/);

my $port = '161';
if ($opt_P) { $port = $1 if ($opt_P =~ /^([0-9]+)$/) }

my $community = 'public';
if ($opt_C) { $community = $opt_C; }
	
my $ses = getSession($host, $community, $port);
if(! $ses) { 
    # errors should be printed out inside the getSession function
    exit $ERRORS{'UNKNOWN'}; 
}

my %alltabs = %AllOMSATables;
my @message;
my $retval = $ERRORS{'OK'};

# There is no way to check the session if one is connected but not authorized
my $hoststring = getSingleValue($ses, '1.3.6.1.2.1.1.5.0');
if($ses->error ne ""){
    print $ses->error . ", check the host and SNMP community parameters\n";
    exit $ERRORS{'UNKNOWN'};
}

# Check for OMSA first, it is pointless to check all groups if none is present
my $omsastring = getSingleValue($ses, '1.3.6.1.4.1.674.10892.1.100.1.0');
if ($omsastring ne "Server Administrator"){
    print "Agent $host has no OMSA Subagent attached. Sorry!\n";
    exit $ERRORS{'UNKNOWN'};
}

# iterate over all specified groups and check status
for (@groups){
    my $groupname = $_;
    my %tab = %{$alltabs{$groupname}};
    my $base = $tab{'baseoid'};
    my $statid = $tab{'statusid'};
    my $status = getTable($ses, $base . $statid);
    if (! defined $status) { 
        print "No OMSA response\n";
        exit $ERRORS{'UNKNOWN'};
    }
    my $probe  = shortCheck($status);

    if ($probe eq "0"){
        push(@message, $groupname);
    } else {
       # if one of the result tables held something different than 3, we need to look deeper
       # into what happened. First we need to find the regarding location id and request the 
       # actual error location - this will only happen on errors!
        my $location_oid = $probe;
        my $such = $base.$statid;
        my $ersetz = $base.$tab{'locationid'};
        my %stat_tab = %{$tab{'statustable'}};
        my $single_status = $status->{$probe};
        # test
        $single_status = 5;
        $location_oid =~ s/$such(.+)$/$ersetz$1/;
        my $location = getSingleValue($ses, $location_oid);
        @message = ($location . " is " . $stat_tab{$single_status});
        $retval = handleReturnCode($single_status);
        last;
    }
}

if ($retval == $ERRORS{'OK'}) {
    print (join(", ", @message), " are ok\n");
}
else{
	print (@message, "\n");
}

if($ses) { $ses->close }

exit $retval;

## This is the fast status-only check
## Returns "0" if all oid values are equal to $STATUS{'ok'}
## Return the first oid with a status different from that
sub shortCheck ($){
    ## this is expected to be a Net::SNMP get_table result hash
    my %result = %{(shift)};
    foreach (keys(%result)){
        if ($result{$_} ne 3) { return $_ }
    }
    return "0";
}

## utility "PrettyPrint" function for hashes
sub printHash ($){
    my %ref = %{(shift)};
    for (keys %ref){ print ($_.": ".$ref{$_},"\n") }
}

## function similar to a single snmpget command
## Returns the value as a String, or an empty String
sub getSingleValue($$) {
    my $session = shift;
    my $oid     = shift;
    my $tab     = {};
    $tab        = $session->get_request( -varbindlist => [$oid]);
    return $tab->{$oid};	
}

sub getTable($$) {
    my $session = shift;
    my $oid     = shift;
    my $tab     = 0;
    $tab        = $session->get_table( -baseoid => $oid);
    return $tab;	
}

sub getSession($$$){
    my $o_host      = shift;
    my $o_community = shift;
    my $o_port      = shift;
    my ($session, $error) = Net::SNMP->session(
		-hostname  => $o_host,
		-community => $o_community,
		-port      => $o_port,
		-version   => "2c"
	   );
	
	if($session){
		return $session;
	}else{
		print "Error connecting ".$o_host.": ";
		print ($error, "\n");
	}
	return 0;
}

sub listGroups(){
	return (keys %AllOMSATables);	
}

sub handleReturnCode($){
    my $actual_status = shift;
    # This is my very doubtful attempt to map dell statuses to Nagios ones
    my %MapOMSANagios = ( 1  => $ERRORS{'CRITICAL'},
                          2  => $ERRORS{'UNKNOWN'},
                          3  => $ERRORS{'OK'},
                          4  => $ERRORS{'WARNING'},
                          5  => $ERRORS{'CRITICAL'},
                          6  => $ERRORS{'CRITICAL'},
                          7  => $ERRORS{'WARNING'},
                          8  => $ERRORS{'CRITICAL'},
                          9  => $ERRORS{'CRITICAL'},
                          10 => $ERRORS{'CRITICAL'}
                         );

    for (keys %MapOMSANagios) { 
        if ($_ == $actual_status) { return $MapOMSANagios{$actual_status}}
    }
    return $ERRORS{'UNKNOWN'};
}

sub print_usage () {
	print "Usage: $PROGNAME [-P port] -H <host> [-C community] [-G group1,group2,...]\n";
}

sub print_help () {
	print_revision($PROGNAME,'$Revision: 0.6 $');
	print "Copyright (c) 2005 Steffen Roegner

This plugin checks an assortment of system parameters of a Dell Poweredge Server via snmp.
At this time, there are PowerUnits, CoolingUnits Voltage- and Temperature-Sensors checked.

";
	print_usage();
	print "
-H, --hostname=HOST
   Name or IP address of host to check
-C, --community=community
   SNMPv2c community (default public)
-P, --port=SNMP port (default 161)
   SNMP Port
-G, --groups=OMSA groups to request (default All)
   Possible Values:";
   print (join(', ', listGroups()), ", All\n\n");
	support();
}
