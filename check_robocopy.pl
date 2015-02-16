#!/usr/bin/perl
#
# check_robocopy.pl
# - A nagios plugin to monitor a regular robocopy backup job.
#
# Usage:
#  check_robocopy.pl [--user <user>] [--password <pass>] [--maxAge <hours>] <file>
# 
# where
#  <file>		Is the path of a robocopy logfile, which might be local or provided as a smb: URI
#			( e.g. smb://server/path/to/robocopy/logfile )
#  --maxAge <hours>	Check for a completed run in the last <hours> hours (default: 24 hours).
#  --user <user> 	The username, if fetching logfile via smb
#  --password <pass>	The password, if fetching logfile via smb
# 
# Returns 
#  CRITICAL if no copy job was finished in the given timespan,
#  WARNING if there were files/dirs which could not be copied and
#  OK otherwise.
#
# Also provides performance data.
#
# Author: Moritz Bechler <mbechler@eenterphace.org> for Schmieder IT Solutions (http://www.schmieder.de)
# License: MIT License
#
# Copyright (c) 2010 Moritz Bechler
# 
# Permission is hereby granted, free of charge, to any person obtaining a copy
# of this software and associated documentation files (the "Software"), to deal
# in the Software without restriction, including without limitation the rights
# to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
# copies of the Software, and to permit persons to whom the Software is
# furnished to do so, subject to the following conditions:
# 
# The above copyright notice and this permission notice shall be included in
# all copies or substantial portions of the Software.
#  
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
# IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
# FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
# AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
# LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
# OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
# THE SOFTWARE.
#


use strict;
use FindBin;
use lib "$FindBin::Bin";
use File::Temp;
use Getopt::Long;
use Date::Parse;
use Date::Format;



my $user = '';
my $password = '';
my $maxAge = 24;

GetOptions('user=s' => \$user, 'password=s' => \$password, 'maxAge=n' => \$maxAge);

my $uri = shift;

if(!$uri) {
	print "Usage: $0 [--user <user>] [--password <pass>] [--maxAge <hours>]  smb://server/path/to/robocopy/logfile\n";
	die "No logfile URI provided";
}

my $tmpfile = '';

if(! -e $uri) {
	$tmpfile = tmpnam();

	my $cmd = "/usr/bin/smbget -q -n -o $tmpfile ";
	if($user) {
		$cmd .= "-u \"$user\" ";
	}
	if($password) {
		$cmd .= "-p \"$password\" ";
	}
	$cmd .= "\"$uri\"";

	if(!system($cmd)) {
		print "CRITICAL: Failed to fetch robocopy logfile\n";
		exit(2);
	}
} else {
	$tmpfile = $uri;
}

sub strtonum {
	my $str = shift;
	chomp $str;
	my $numpart = $str*1;
	my $offset = 1;
	
	if(substr($str,-1) == 'g') {
		$offset = 1024*1024*1024;
	} elsif (substr($str,-1) == 'm') {
		$offset = 1024*1024;
	} elsif (substr($str,-1) == 'k') {
		$offset = 1024;
	}	
	return int($numpart * $offset);
}

my $started = 0;
my $ended = 0;

my $filesTotal = 0;
my $filesCopied = 0;
my $filesSkipped = 0;
my $filesMismatch = 0;
my $filesFailed = 0;
my $filesExtra = 0;

my $dirsTotal = 0;
my $dirsCopied = 0;
my $dirsSkipped = 0;
my $dirsMismatch = 0;
my $dirsFailed = 0;
my $dirsExtra = 0;

my $bytesTotal = 0;
my $bytesCopied = 0;
my $bytesPerSec = 0;

my $totalTime = 0;

open TMPFILE, "<$tmpfile";

while(my $line = <TMPFILE>) {
	if($line =~ m/\s*Started : (.*)$/) {
		$started = str2time( $1 );
		if(!$started) {
			print "UNKNOWN: Failed to parse date\n";
			exit 3;
		}
	}

	if($line =~ m/\s*Ended : (.*)$/) {
		$ended = str2time( $1 );
		if($ended < time() - $maxAge*60*60) {
			print "CRITICAL: No backup ended in last $maxAge hours\n";
			exit 2;
		}
	}

	if($line =~ m/\s*Files :\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/) {
		$filesTotal = $1;
		$filesCopied = $2;
		$filesSkipped = $3;
		$filesMismatch = $4;
		$filesFailed = $5;
		$filesExtra = $6;
	}

		
	if($line =~ m/\s*Dirs :\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s+(\d+)\s*$/) {
		$dirsTotal = $1;
		$dirsCopied = $2;
		$dirsSkipped = $3;
		$dirsMismatch = $4;
		$dirsFailed = $5;
		$dirsExtra = $6;
	}
	
	if($line =~ m/\s*Times :\s+ (\d+:\d+:\d+)/) {
		$totalTime = $1;
	}

	if($line =~ m/\s*Bytes :\s+([\d\.]+ (g|m|k))\s+([\d\.]+ (g|m|k))/) {
		$bytesTotal = strtonum($1);
		$bytesCopied = strtonum($3);
	}

	if($line =~ m/\s*Speed :\s+(\d+) Bytes\/sec/) {
		$bytesPerSec = $1;
	}
	
	
}

close TMPFILE;

my $status = 0;

if(!$started or !$ended) {
	print "CRITICAL: Couldn't parse log file\n";
	exit 2;
}

if($filesFailed > 0 or $dirsFailed > 0) {
	print "WARNING: Some files failed to be backed-up";
	$status = 1;
} else {
	print "OK: Backup of $filesTotal files and $dirsTotal dirs finished in $totalTime on " .  time2str("%c", $ended) . "";

}
print " | filesTotal=$filesTotal,dirsTotal=$dirsTotal,filesCopied=$filesCopied,dirsCopied=$dirsCopied,";
print "filesSkipped=$filesSkipped,dirsSkipped=$dirsSkipped,filesFailed=$filesFailed,dirsFailed=$dirsFailed,";
print "bytesPerSec=$bytesPerSec,bytesTotal=$bytesTotal,bytesCopied=$bytesCopied";
print "\n";

exit $status;
