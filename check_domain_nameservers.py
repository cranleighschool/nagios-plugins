import commands
from datetime import datetime
import sys
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--domain",required=True,help="Domain name to check")
parser.add_argument("--ns1",required=True,help="Nameserver 1")
parser.add_argument("--ns2",required=True,help="Nameserver 2")
parser.add_argument("--ns3",required=True,help="Nameserver 3")
args = parser.parse_args()

data = commands.getstatusoutput("whois "+args.domain)

#print data
domain_type = args.domain.split('.',1)[-1]
name_server_number = 0
nameservers = {}
data_arr = data[1].split("\n")

if domain_type == 'co.uk' or domain_type == 'org.uk':
	name_servers_found = False
	for row in data_arr:
		if name_servers_found == True and row == "\r":
			name_servers_found = False
		elif name_servers_found == True:
			name_server_number = name_server_number+1
			nameservers[name_server_number] = row.strip()
		elif "Name" in row:
			name_servers_found = True
else:
	for row in data_arr:
		if "Name Server:" in row:
			name_server_number = name_server_number+1
			nameservers[name_server_number] = row.replace("Name Server:","").strip()

#print nameservers
error = False
error_text = ""
if nameservers[1].lower() != args.ns1.lower():
	error = True
	error_text = "NS1 is "+nameservers[1].lower()+" Should be "+args.ns1.lower()
if nameservers[2].lower() != args.ns2.lower():
	error = True
	error_text = error_text + "\nNS2 is "+nameservers[2].lower()+" Should be "+args.ns2.lower()
if len(nameservers) <= 2:
	error = True
	error_text = error_text + "\nNo 3rd Name Server Defined"
elif nameservers[3].lower() != args.ns3.lower():
	error = True
        error_text = error_text +  "\nNS3 is "+nameservers[3].lower()+" Should be "+args.ns3.lower()

if error:
	print "ERROR - "+error_text
	sys.exit(-1)
else:
	print "OK - All Nameservers correct"
	sys.exit(0)
