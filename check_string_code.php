#!/usr/bin/php
<?php
namespace FredBradley\NagiosChecks;
new StringCheckFromURL();
class StringCheckFromURL {
	
	private $options;
	private $needle;
	private $haystack;
	
	public function __construct() {

		$shortopts  = "";
		
		$longopts  = array(
		    "url:",     // Required value
		    "str:",    // Optional value
		);
		
		$this->options = getopt($shortopts, $longopts);
		
		if (count($this->options)!==2) {
			print "UNKNOWN - Options not set";
			exit(3);
		}
		
		$this->check();
		
	}
	
	private function get_data($url) {
		$ch = curl_init();
		$timeout = 5;
		curl_setopt($ch, CURLOPT_URL, $url);
		curl_setopt($ch, CURLOPT_RETURNTRANSFER, 1);
		curl_setopt($ch, CURLOPT_CONNECTTIMEOUT, $timeout);
		curl_setopt($ch, CURLOPT_FOLLOWLOCATION, TRUE);
		$data = curl_exec($ch);
		curl_close($ch);
		return $data;
	}

	private function doWget($url, $filename) {
		$filename = "/tmp/".$filename;
		$cmd = "wget --quiet -O ".$filename." \"$url\" ";
		exec($cmd);
		
		return $filename;
	}
	public function check() {

		$this->needle = $this->options['str'];
		$this->haystack = $this->options['url'];

		$file = $this->doWget($this->haystack, "string_check_".substr($this->haystack, 8)."_".time());
		
		$contents = file_get_contents($file);
		exec("rm ".$file);
		
		if (strpos($contents, $this->needle)) {
	
			print "OK - String Found";
			exit(0);
	
		} else {
	
			print "UH OH - String Not Found";
			exit(2);
	
		}
	
	}
	
}

