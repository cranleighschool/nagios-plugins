#!/usr/bin/perl

##################################################################################
##################################################################################
######################  Made by Tytus Kurek on November 2012  ####################
##################################################################################
##################################################################################
####   This is a Nagios Plugin destined to check BGP peer availability and    ####
####                      session state on Cisco devices                      ####
##################################################################################
##################################################################################

use strict;
use vars qw($community $IP $peer);

use Getopt::Long;
use Pod::Usage;

# Subroutines execution

getParameters ();
checkBGPState ();

# Subroutines definition

sub checkBGPState ()	# Checks BGP session status via SNMP
{
	my $OID = '1.3.6.1.2.1.15.3.1.2';
	my %states = (1 => 'IDLE', 2 => 'CONNECT', 3 => 'ACTIVE', 4 => 'OPENSENT', 5 => 'OPENCONFIRM', 6 => 'ESTABLISHED');
	my $version = '2c';

	my $command = "/usr/bin/snmpwalk -v $version -c $community $IP $OID 2>&1";
	my $result = `$command`;

	if ($result =~ m/^Timeout.*$/)
	{
		my $output = "UNKNOWN! No SNMP response from $IP.";
		my $code = 3;
		exitScript ($output, $code);
	}

	my $peerOID = $OID . ".$peer";
	$command = "/usr/bin/snmpget -v $version -c $community $IP $peerOID";
	$result = `$command`;

	if ($result =~ m/^Timeout.*$/)
	{
		my $output = "UNKNOWN! No SNMP response from $IP.";
		my $code = 3;
		exitScript ($output, $code);
	}

	else
	{
		if ($result =~ m/SNMPv2-SMI::mib-2.15.3.1.2.$peer\s=\sNo\sSuch\sInstance\scurrently\sexists\sat\sthis\sOID/)
		{
			my $output = "CRITICAL! BGP peer $peer unavailable.";
			my $code = 2;
			exitScript ($output, $code);
		}

		else
		{
			$command = "/usr/bin/snmpget -v $version -c $community $IP $peerOID";
			$result =~ m/SNMPv2-SMI::mib-2.15.3.1.2.$peer\s=\sINTEGER:\s(\d)/;
			my $state = $states{$1};
	
			if ($state ne 'ESTABLISHED')
			{
				my $output = "CRITICAL! BGP peer $peer session state: $state.";
				my $code = 2;
				exitScript ($output, $code);
			}

			else
			{
				my $output = "OK! BGP peer $peer session state: $state.";
				my $code = 0;
				exitScript ($output, $code);
			}
		}
	}
}

sub exitScript ()	# Exits the script with an appropriate message and code
{
	print "$_[0]\n";
	exit $_[1];
}

sub getParameters ()	# Obtains script parameters and prints help if needed
{
	my $help = '';

	GetOptions ('help|?' => \$help,
		    'C=s' => \$community,
		    'H=s' => \$IP,
		    'P=s' => \$peer)

	or pod2usage (1);
	pod2usage (1) if $help;
	pod2usage (1) if (($community eq '') || ($IP eq '') || ($peer eq ''));
	pod2usage (1) if (($IP !~ m/^\d+\.\d+\.\d+\.\d+$/) || ($peer !~ m/^\d+\.\d+\.\d+\.\d+$/));

=head1 SYNOPSIS

check_cisco_bgp.pl [options] (-help || -?)

=head1 OPTIONS

Mandatory:

-H	IP address of monitored Cisco ASA device

-C	SNMP community

-P	BGP peer IP address

=cut
}
