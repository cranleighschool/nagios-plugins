#!/bin/python
import urllib, urllib2, cookielib, string

username = 'testpupil2012'
password = 'AllYourBase'

cj = cookielib.CookieJar()
opener = urllib2.build_opener(urllib2.HTTPCookieProcessor(cj))
login_data = urllib.urlencode({'user_id' : username, 'password' : password, 'submit' : 'Login'})
opener.open('https://vle.cranleigh.org/webapps/login/', login_data)
#resp = opener.open('https://vle.cranleigh.org/webapps/portal/frameset.jsp')
resp = opener.open('https://vle.cranleigh.org/webapps/portal/execute/tabs/tabAction')

resp_string = resp.read()
#print resp_string

#if string.find(resp_string,'https://vle.cranleigh.org/webapps/login/?action=logout') != -1:
if string.find(resp_string,'/webapps/login/?action=logout') != -1:


	print "LDAP LOGIN OK"
	exit(0)
else:
	print "LDAP LOGIN NOT OK"
	exit(-1)
