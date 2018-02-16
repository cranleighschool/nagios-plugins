<?php
/*
 * (c) 2009 by Michael Bladowski (info@macropage.de)
 * GPLv2, no warranty of any kind given.
*/


$url = $argv[1];

$url = preg_replace('/\s*/','',$url);


$obj = json_decode(curler($url));

if (!isset($obj->lastUpdated)) {
	print "Object Not found";
	exit(2);
}

$then = strtotime($obj->lastUpdated);
$now = time();

if ($then > strtotime('-18 hours')) {
	print "RSYNC last run: $obj->lastUpdated";
	exit(0);
}

if ($then > strtotime('-24 hours') && $then < strtotime('-18 hours')) {
	print "WARNING - Rsync not run in the last 12 hours";
	exit(1);
}

if ($then < $now && $then > strtotime('-24 hours')) {
	print "ERROR - Rsync not run in the last 24 hours";
	exit(2);
}

// If we get to here, then something's not right! And we need a human to investigate more!
print "ERROR - Last Updated: ".$obj->lastUpdated;
exit(3);

function curler($url) {
	$ch = curl_init();
	$headers = array(
		"User-Agent: nagios-check"
	);
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_HTTPHEADER, $headers);
	$result = curl_exec($ch);
	curl_close($ch);

	return $result;
}
