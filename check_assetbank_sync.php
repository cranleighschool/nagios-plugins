<?php
/*
 * (c) 2009 by Michael Bladowski (info@macropage.de)
 * GPLv2, no warranty of any kind given.
*/


$url = $argv[1];

$url = preg_replace('/\s*/','',$url);


$bla = file_get_contents($url);

$obj = json_decode($bla);

if (!isset($obj->lastUpdated)) {
	print "Object Not found";
	exit(2);
}

$then = strtotime($obj->lastUpdated);
$now = time();

if ($then > strtotime('-12 hours')) {
	print "RSYNC last run: $obj->lastUpdated";
        exit(0);
}

if ($then > strtotime('-24 hours') && $then < strtotime('-12 hours')) {
        print "WARNING - Rsync not run in the last 12 hours";
        exit(1);
}

if ($then < $now && $then > strtotime('-24 hours')) {
        print "ERROR - Rsync not run int he last 24 hours";
        exit(2);
}

print "ERROR - Reached End of File";
exit(3);
