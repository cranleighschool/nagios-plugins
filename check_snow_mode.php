#!/usr/bin/php
<?php
namespace FredBradley\NagiosChecks;
// NB: This is essentially the reverse check of "string_in_code" - as we want it to return "OK" if the string DOESN'T EXIST!
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
	
	public function check() {

		$this->needle = $this->options['str'];
		$this->haystack = $this->options['url'];
	
		$contents = file_get_contents($this->haystack);
		
		if (strpos($contents, $this->needle)) {
	
			print "SNOW MODE IS ON";
			exit(2);
	
		} else {
	
			print "No Snow";
			exit(0);
	
		}
	
	}
	
}

