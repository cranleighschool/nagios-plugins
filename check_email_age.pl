#!/usr/bin/perl
#
# ============================== SUMMARY =====================================
#
# Program : check_email_age.pl
# Version : 1.0
# Date    : Nov 11 2011
# Author  : fabricat
# Summary : This plugin logs into a POP3 or POP3 over SSL (POP3s) account and
#           reports the age (in hours) of the oldest messages in the mailbox.
#           Performance data is available.
#
# License : GPL - summary below, full text at http://www.fsf.org/licenses/gpl.txt
#
# =========================== PROGRAM LICENSE =================================
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation; either version 2 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
# ===================== INFORMATION ABOUT THIS PLUGIN =========================
#
# This program is written and maintained by: 
#   fabricat <fabricat(at)gmail.com>
#
# It is a slight rewrite of a POP3 plugin written by Jason Ellison.
#
# OVERVIEW
#
# This plugin logs into a POP3 or POP3 over SSL (POP3s) account and
# the age (in hours) of the oldest messages in the mailbox.
# This plugin provides performance data in the form of the hours of age. 

# Usage: check_email_age.pl -H <host> -u <username> -p <password> \
#                           [-w <warning>] [-c <critical>] [-P <pop3|pop3s>]
# -h, --help
#        print this help message
# -v, --version
#        print version
# -V, --verbose
#        print extra debugging information
# -H, --host=HOST
#        hostname or IP address of host to check
# -u, --username=USERNAME
# -p, --password=PASSWORD
# -w, --warnng=INT
#        number of hours which if exceeded will cause a warning
# -c, --critical=INT
#        number of hours which if exceeded will cause a critical
# -P, --protocol=pop3|pop3s
#        protocol to use when checking messages (if omitted defaults to pop3)

# ============================= SETUP NOTES ====================================
#
# Copy this file to your Nagios installation folder in "libexec/". 
# Rename to "check_email_age.pl"

# Manually test it with a command like the following:
# ./check_email_age.pl -H pop.example.org -u username -p password

# NAGIOS SETUP

# define command{
#   command_name check_email_age
#   command_line $USER1$/check_email_age.pl -H $HOSTADDRESS$ -u $ARG1$ -p $ARG2$ -w $ARG3$  -c $ARG4$ -P $ARG5$
# }
#
# define service{
#   use generic-service
#   host_name MAILSERVER
#   service_description Check email age
#   check_command check_email_age!jellison!A$3cr3T!24!48!pop3
#   normal_check_interval 3
#   retry_check_interval 1
# }

use Mail::POP3Client;
use Date::Parse;
use Getopt::Long;

my $TIMEOUT = 20;
my %ERRORS=('OK'=>0,'WARNING'=>1,'CRITICAL'=>2,'UNKNOWN'=>3,'DEPENDENT'=>4);

my $version  = '1.0';
my $opt_version = undef;
my $host     = undef; #hostname or ip address of pop3 server
my $protocol = 'pop3'; #protocol pop3 or pop3 over ssl (pop3s)
my $username = undef; #pop3 user account
my $password = undef; #pop3 password
my $critical = 60;
my $warning  = 24;

sub print_version { print "$0: version $version\n" };

sub verb { my $t=shift; print "VERBOSE: ",$t,"\n" if defined($verbose) ; }

sub print_usage {
        print "Usage: $0 -H <host> -u <username> -p <password> [-w <warning>] [-c <critical>] [-P <pop3|pop3s>]\n";
}
sub help {
	print "\nCheck oldest email age from a POP3 Account ", $version, "\n";
	print " by fabricat\n\n";
	print_usage();
	print <<EOD;
-h, --help
	print this help message
-v, --version
	print version
-V, --verbose
	print extra debugging information
-H, --host=HOST
	hostname or IP address of host to check
-u, --username=USERNAME
-p, --password=PASSWORD
-w, --warnng=INT
	number of hours which if exceeded will cause a warning (detaults to $warning)
-c, --critical=INT
	number of hours which if exceeded will cause a critical (detaults to $critical)
-P, --protocol=pop3|pop3s
	protocol to use when checking messages (defaults to $protocol)
EOD
}

sub check_options {
    Getopt::Long::Configure ("bundling");
    GetOptions(
	'V'	=> \$verbose,	'verbose'	=> \$verbose,
	'v'	=> \$opt_version,	'version'	=> \$opt_version,
	'h'	=> \$help,	'help'		=> \$help,
	'H:s'	=> \$host,	'host:s'	=> \$host,
	'P:s'	=> \$protocol,	'protocol:s'	=> \$protocol,
	'u:s'	=> \$username,	'username:s'	=> \$username,
	'p:s'	=> \$password,	'password:s'	=> \$password,
	'c:i'	=> \$critical,	'critical:i'	=> \$critical,
	'w:i'	=> \$warning,	'warning:i'	=> \$warning
    );

  if (defined($help) ) { help(); exit $ERRORS{"UNKNOWN"}; }
  if (defined($opt_version) ) { print_version(); exit $ERRORS{"UNKNOWN"}; }
  if (! defined($host) ) # check host and filter
    { print "ERROR: No host defined!\n"; print_usage(); exit $ERRORS{"UNKNOWN"}; }
  if (! defined($username) ) # check username 
    { print "ERROR: No username defined!\n"; print_usage(); exit $ERRORS{"UNKNOWN"}; }
  if ( (!($protocol eq 'pop3')) && (!($protocol eq 'pop3s')) )
    { print "ERROR: Protocol must be pop3 or pop3s!\n"; print_usage(); exit $ERRORS{"UNKNOWN"}; }

  verb "host = $host";
  verb "protocol = $protocol";
  verb "username = $username";
#  verb "password = $password";
  verb "warning = $warning";
  verb "critical = $critical";
}

check_options();

$pop = new Mail::POP3Client( USER => "$username",
  PASSWORD => "$password",
  HOST => "$host",
  TIMEOUT => 10,
  USESSL => ($protocol eq "pop3s") 
);

$count = $pop->Count();

verb "message count = $count";

if ($count > 0) {
  @head = $pop->Head(1);
  foreach( @head ) {
    if ($_ =~ m/^Date:\s+(.+)$/i) {
      $date = $1;
    }
  }
  $time = str2time($date);
  $now = time();
  $diff = int(($now - $time) / 3600);
  
  verb "Date: $date";
  verb "Timestamp: $time";
#  verb "Now: $now";
  verb "Hours old: $diff";
}

if ($count eq -1) {
  $statusinfo = "Failed to log in as $username";
  $statuscode="CRITICAL";
  $diff = 0;
}elsif ($count eq 0) {
  $statusinfo = "No email messages present";
  $statuscode="OK";
  $diff = 0;
}elsif ($diff >= $critical) {
  $statusinfo = "oldest message (on $count total) for $username is $diff hours old";
  $statuscode="CRITICAL";
}elsif ($diff >= $warning) {
  $statusinfo = "oldest message (on $count total) for $username is $diff hours old";
  $statuscode="WARNING";
}else{
  $statusinfo = "oldest message (on $count total) for $username is $diff hours old";
  $statuscode="OK";
}

$pop->Close();

#printf("POP3 Old Messages ");

printf("$statuscode - $statusinfo");

printf(" |age=$diff;$warning;$critical;;");

print "\n";

exit $ERRORS{$statuscode};
