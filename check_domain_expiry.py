import commands
from datetime import datetime

import argparse
parser = argparse.ArgumentParser()
parser.add_argument("--domain",required=True,help="Domain name to check")
parser.add_argument("--warning",required=True,help="Number of days away for warning")
parser.add_argument("--critical",required=True,help="Number of days away for critial")
args = parser.parse_args()

data = commands.getstatusoutput("whois "+args.domain+" | grep 'Exp.*[d|D]ate'")

#print data
#data = data[0].replace("'Registrar Registration Expiration Date: ","")

expiry_string = data[1].replace("Registry Expiry Date: ","")
expiry_string = expiry_string.replace("Registrar Registration Expiration Date: ","")
expiry_string = expiry_string.replace("        Expiry date:  ","")
expiry_string = expiry_string.replace("Domain Expiration Date:                      ","")
#print "UNKNOWN - "+expiry_string.strip()
#exit(3)
domain_type = args.domain.split('.',1)[-1]

#print expiry_string

#remove trailing time
if domain_type == 'co.uk' or domain_type=='org.uk':
   expiry_time = datetime.strptime(expiry_string.strip(),'%d-%b-%Y')
elif domain_type == 'biz':
   expiry_string = expiry_string.split(" ")
   expiry_string = expiry_string[1]+" "+expiry_string[2]+" "+expiry_string[5]
   expiry_time = datetime.strptime(expiry_string,'%b %d %Y')
else:
   if 'T' in expiry_string:
   	expiry_string = expiry_string.split('T', 1)[0]
   else:
	expiry_string = expiry_string.split(' ', 1)[0]
   expiry_time = datetime.strptime(expiry_string.strip(),'%Y-%m-%d')

now = datetime.now()

time_to_expiry = expiry_time - now

days_to_expiry = time_to_expiry.days
if days_to_expiry > int(args.warning):
	print "OK - "+args.domain+" Has "+str(days_to_expiry)+" Days Until Expiry"
	exit(0)
elif (days_to_expiry < int(args.warning)) and (days_to_expiry > int(args.critical)):
	print "WARNING - "+args.domain+" Has "+str(days_to_expiry)+" Days Until Expiry"
	exit(1)
else:
	print "CRITICAL - "+args.domain+" Has "+str(days_to_expiry)+" Days Until Expiry"
	exit(2)
