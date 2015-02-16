import urllib, urllib2
import json
import argparse

parser = argparse.ArgumentParser()
parser.add_argument("--message",help="Message to send")
parser.add_argument("--type",help="Problem or Recovery")
params = parser.parse_args()

json_dict = { 'title': 'Nagios Host (INT)', 'message': params.message,'picture': 'https://cdn1.iconfinder.com/data/icons/energy-power/512/flame_fire_energy_fire_hazard-128.png' }

# convert json_dict to JSON
json_data = json.dumps(json_dict)

# convert str to bytes (ensure encoding is OK)
post_data = json_data.encode('utf-8')

headers = {}
headers['Content-Type'] = 'application/json'

url = 'https://hall.com/api/1/services/generic/aea25988da6f0e187d7bf5028746ed26'

req = urllib2.Request(url, post_data,headers)
response = urllib2.urlopen(req)
the_page = response.read()
