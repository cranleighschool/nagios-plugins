import netsnmp
import sys
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--hostname",help="Hostname of the device to check")
parser.add_argument("--community",help="SNMP Ciommunity to use")
parser.add_argument("--exclude",help="Port to exclude (blocking state expected)",default=0)
params = parser.parse_args()

#print params.hostname

oid_in = netsnmp.VarList(netsnmp.Varbind('.1.3.6.1.2.1.2.2.1.14'))
oid_out = netsnmp.VarList(netsnmp.Varbind('.1.3.6.1.2.1.2.2.1.20'))
error_in = netsnmp.snmpwalk(oid_in, Version = 2, DestHost=params.hostname,
                           Community=params.community)
error_out = netsnmp.snmpwalk(oid_out, Version = 2, DestHost=params.hostname,
                           Community=params.community)

exit_state = 0
output = ""
portnumber = 0

for potential_error_in in error_in:
	portnumber = portnumber + 1
	if int(potential_error_in) > 1:
		output = output+potential_error_in+" Errors Inbound on "+str(portnumber)+"\n"
		exit_state = 1
for potential_error_out in error_out:
	portnumber = portnumber + 1
	if int(potential_error_in) > 1:
		output = output+potential_error_out+" Errors Outbound on "+str(portnumber)+"\n"
		exit_state = 1
if output == "":
	print "All Ports OK"
else:
	print output.rstrip("\n")

sys.exit(exit_state)
