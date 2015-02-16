import netsnmp
import sys
import argparse

def convert_state(number):
	number = int(number)
	if(number == 0):
		return "unknown"
	if(number == 1):
		return "disabled"
	if(number == 2):
		return "blocking"
	if(number == 3):
		return "listening"
	if(number == 4):
		return "learning"
	if(number == 5):
		return "forwarding"
	if(number == 6):
		return "broken"

parser = argparse.ArgumentParser()
parser.add_argument("--hostname",help="Hostname of the device to check")
parser.add_argument("--community",help="SNMP Ciommunity to use")
parser.add_argument("--blocked",help="Port whos blocking state is expected",default=0)
params = parser.parse_args()

#print params.hostname

spanningtree_statuses = netsnmp.VarList(netsnmp.Varbind('.1.3.6.1.2.1.17.2.15.1.3'))
interface_names = netsnmp.VarList(netsnmp.Varbind('IF-MIB::ifDescr'))
#popuplate spanning tree status with some data
netsnmp.snmpwalk(spanningtree_statuses, Version = 2, DestHost=params.hostname,
                           Community=params.community)
#populate interface names with some data
netsnmp.snmpwalk(interface_names, Version = 2, DestHost=params.hostname,
                           Community=params.community)
#print res

exit_state = 0
output = ""
portnumber = 1


interfaceList = {}

for interface in interface_names:
	interfaceList[int(interface.iid)] = interface.val

#print interfaceList
#sys.exit()

#print type(ports)
#print ports
#for state in ports:

print spanningtree_statuses[49].val
#for port_state in spanningtree_statuses:	
	
#	index = port_state.tag.replace('mib-2.17.2.15.1.3.','')
	
	#print index + " " + interfaceList[int(index)] + " " + convert_state(port_state.val)
#	if int(port_state.val) == 2 and int(index) != int(params.exclude):
#		output = output + " Port "+interfaceList[int(index)]+" Blocking"
#		exit_state = 2
#	if int(port_state.val) == 6:
#		output = output + " Port "+interfaceList[int(index)]+" Broken"
#		exit_state = 2
	

if output == "":
        print "All Ports OK"
else:
        print output.rstrip()

sys.exit(exit_state)
