<?php
$url = "https://cdn.cranleigh.org/fonts/bentonsans/";

$check_endpoints = array(
	"light" => "lt/woff",
	"light-italic" => "ltit/woff",
	"regular" => "reg/woff",
	"italic" => "it/woff",
	"css" => "fontface.css"
);

foreach ($check_endpoints as $name => $endpoint):
	runCheck($url.$endpoint, $name);
endforeach;

function runCheck($url, $name) {

	if (!isset($url)) {
		print "URL ARG NOT FOUND";
		exit(3);
	}
	
	
	$headers = @get_real_headers($url);
	
	if (!isset($headers['Response'])) {
		print "Headers Not Found";
		exit(2);
	}
	
	if (has_string("200 OK", $headers['Response'])===false) {
		print "ERROR ".$name." ".$headers['Response'];
		exit(2);
	}
	
}

function has_string($needle, $haystack) {
	if (strpos($haystack, $needle)) {
		return true;
	} else {
		return false;
	}
}


function get_real_headers($url,$format=0,$follow_redirect=1) {
	if (!$follow_redirect) {
		//set new default options
		$opts = array('http' =>
			array('max_redirects'=>1,'ignore_errors'=>1)
		);
		stream_context_get_default($opts);
	}
	
	//get headers
	$headers=get_headers($url,$format);
	//restore default options
	if (isset($opts)) {
		$opts = array('http' =>
			array('max_redirects'=>20,'ignore_errors'=>0)
		);
		stream_context_get_default($opts);
	}

	$new_headers = array();

	$i = 0;

	foreach ($headers as $header) {
		$i++;
		$header = explode(": ", $header);
		if (isset($header[1])) {
			$new_headers[$header[0]] = $header[1];
		} else {
			$new_headers["Response"] = $header[0];
		}
	}
	return $new_headers;
}
print "Found All Fonts and CSS";
exit(0);