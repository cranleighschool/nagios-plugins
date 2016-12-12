<?php
function get_data($url) {
	$ch = curl_init();
	$timeout = 5;
	curl_setopt($ch, CURLOPT_URL, $url);
	curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
	curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
	$data = curl_exec($ch);
	curl_close($ch);
	return $data;
}
$return_content = get_data('https://f.fontdeck.com/s/css/l4MsFun30OJhB9DTDGcb8JQSAOQ/www.cranleigh.org/24879.css');

if (strpos($return_content, 'Aspect Regular')):
	print "OK";
	exit(0);	
} else {
	print "ERROR";
	exit(2);
}
