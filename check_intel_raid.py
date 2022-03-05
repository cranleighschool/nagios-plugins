#!/bin/python
import urllib, urllib2, cookielib, string
import argparse
from bs4 import BeautifulSoup
parser = argparse.ArgumentParser()
parser.add_argument("--hostname",required=True,help="Hostname of the device to check")
args = parser.parse_args()

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
resp = opener.open('http://'+args.hostname+':3570/mnrptc?axbtmh=PhysicalConfig&abcdqwr=-355376429849183320&fadaddad=-8866881143680860964')
resp_string = resp.read()
soup = BeautifulSoup(resp_string)

#print soup

drives = soup.find_all('font')
for drive in drives:
	#print drive.text
	parts = drive.text.split('\t\t\t\t\t\t\t\t\t\t\t',)
	#print parts
	if len(parts) == 2:
		#print parts[0]
		if "Online" not in parts[1]:
			print "Possible Failed Drive In Slot: "+str(parts[0])
			exit(2)


print "All Physical Drives OK"
exit (0)
		#print parts[1].strip('\t')
#if string.find(resp_string,'https://vle.cranleigh.org/webapps/login?action=logout') != -1:
#	print "LDAP LOGIN OK"
#	exit(0)
#else:
#	print "LDAP LOGIN NOT OK"
#	exit(-1)
