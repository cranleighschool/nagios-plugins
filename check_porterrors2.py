import netsnmp
import sys
import argparse
import os

stats_dir = '/var/switch_error_stats/'

def write_new_log(hostname,type,list):
	log_file = open(stats_dir+hostname+"_"+type,'w+')
	for item in list:
        	log_file.write(item+"\n")
	log_file.close()

def read_log(hostname,type):
	file = open(stats_dir+hostname+"_"+type,'r')
	lines = file.readlines()
	file.close()
	return lines

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

if os.path.isfile(stats_dir+params.hostname+'_in'):
	#print "In Log exists"
	errors_in_last_check = read_log(params.hostname,'in')
	for potential_error_in in error_in:
		if int(potential_error_in) > errors_in_last_check[portnumber]:
			output= output+"Rx Errors"+str(portnumber)+"\n"
	#	portnumber = portnumber + 1
else:
	write_new_log(params.hostname,'in',error_in)


if os.path.isfile(stats_dir+params.hostname+'_out'):
	#print "Out Log exists"
	errors_out_last_check = read_log(params.hostname,'out')
	for potential_error_out in error_out:
		if int(potential_error_out) > errors_out_last_check[portnumber]:
			output= output+"Tx Errors"+str(portnumber)+"\n"
	#	portnumber = portnumber + 1
else:
	write_new_log(params.hostname,'out',error_in)



if output == "":
	write_new_log(params.hostname,'in',error_in)
	write_new_log(params.hostname,'out',error_out)
	print "All Ports OK"
	sys.exit(0)
else:
	print output.rstrip("\n")
	sys.exit(1)
