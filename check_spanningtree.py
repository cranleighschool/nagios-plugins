import netsnmp
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--hostname",help="Hostname of the device to check")
parser.add_argument("--community",help="SNMP Ciommunity to use")
parser.add_argument("--exclude",help="Port to exclude (blocking state expected)",default=0)
params = parser.parse_args()

#print params.hostname

oid = netsnmp.VarList(netsnmp.Varbind('.1.3.6.1.2.1.17.2.15.1.3'))
ports = netsnmp.snmpwalk(oid, Version = 2, DestHost=params.hostname,
                           Community=params.community)
#print res


exit_state = 0
output = ""
portnumber = 0

for state in ports:
	#print str(portnumber) + " " + state
	portnumber = portnumber + 1
#0=>'unknown',1=>'disabled',2=>'blocking',3=>'listening',4=>'learning',5=>'forwarding',6=>'broken'
	if int(state) == 2 and portnumber != int(params.exclude):
		output = output + " Port "+str(portnumber)+" Blocking"
		exit_state = 2
	if int(state) == 6:
		output = output + " Port "+str(portnumber)+" Broken"
		exit_state = 2

if output == "":
	print "All Ports OK"
else:
	print output

sys.exit(exit_state)
