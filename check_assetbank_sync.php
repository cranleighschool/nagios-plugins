<?php
/*
 * (c) 2009 by Michael Bladowski (info@macropage.de)
 * GPLv2, no warranty of any kind given.
*/


$url = $argv[1];

$url = preg_replace('/\s*/','',$url);


$bla = file_get_contents($url);

$obj = json_decode($bla);
$then = strtotime($obj->last_update);
$now = time();
print "Rsync last run: $obj->last_update ";

if ($then > strtotime('-12 hours')) {
        print "OK";
        exit(0);
}
if ($then > strtotime('-24 hours') && $then < strtotime('-12 hours')) {
        print "WARNING";
        exit(1);
}
if ($then < $now && $then > strtotime('-24 hours')) {
        print "ERROR";
        exit(2);
}
