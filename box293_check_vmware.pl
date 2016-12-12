#!/usr/bin/perl -w

# ------------------------------------------------------------------------------
# box293_check_vmware.pl - VMware Plugin for Nagios
# Copyright (C) 2014  Troy Lea AKA Box293
# Original Author: Troy Lea <plugins@box293.com> Twitter: @Box293
# Maintained by: Troy Lea <plugins@box293.com> Twitter: @Box293
# See all my Nagios Projects on the Nagios Exchange: 
#	http://exchange.nagios.org/directory/Owner/Box293/1
#
# This program is free software: you can redistribute it and/or modify it under
# the terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later
# version.
#
# This program is distributed in the hope that it will be useful, but
# WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or
# FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for
# more details.
#
# You should have received a copy of the GNU General Public License along with
# this program.  If not, see <http://www.gnu.org/licenses/>.
#
# To see the license type:
#		box293_check_vmware.pl --license | more
#	
# ------------------------------------------------------------------------------
# 				BEGIN Version Notes
# ------------------------------------------------------------------------------
# Version : 2014-03-26
# Date    : March 26 2014
# Notes   : Pre-release version
#
# Version : 2014-04-15
# Date    : April 15 2014
# Notes   : Official release version
#
# Version : 2014-05-07
# Date    : May 7 2014
# Notes   : Fixed bug where hosts were incorrectly reporting they are in 
#			Maintenance Mode (reported by Marvin Holze and Steven Miller).
#			Added functions for upcoming Nagios XI Wizard
#
# Version : 2014-05-09
# Date    : May 9 2014
# Notes   : Fixed bug in Cluster_Memory_Usage check where the Memory Used was
#			not being correctly reported (reported by Vitaly Burshteyn). This
#			also affected the Cluster_Resource_Info check.
#
# Version : 2014-05-10
# Date    : May 10 2014
# Notes   : Fixed bug in Cluster_CPU_Usage check where the CPU Used was not 
#			being correctly reported (reported by Vitaly Burshteyn). This also
#			affected the Cluster_Resource_Info check.
#
# Version : 2014-05-30
# Date    : May 30 2014
# Notes   : Added functions for upcoming Nagios XI Wizard. Fixed bug with
#			--reporting_si not accepting the Time argument.
#
# Version : 2014-08-24
# Date    : August 24 2014
# Notes   : Improved debugging, creates a debugging file when in debug mode.
#			All checks that output performance data now have the name of the
#			check appended to the end of the performance data surrounded by
#			square brackets. This makes the use of templates in PNP easy.
#			Fixed bug in Host_pNIC_Status where the incorrect amount of pNICs
#			were being calculated when specifying which pNICs to check.
#			Fixed bug in Host_pNIC_Status where --nic_state was not correctly
#			triggering a CRITICAL state. Fixed bug in Host_pNIC_Status where
#			the phrase "NOT Connected" was appearing twice on a disconnected
#			pNIC. Fixed bug with Host_Switch_Status check, only the first switch
#			was being reported and would not find more than one switch if the
#			host had more than one. Fixed bug with Guest_Disk_Usage where the 
#			"Disk Usage" was reported as 0 when the guest had snapshots.
#			Added a Version argument to report the plugin version.
#			Added check Guest_Status which reports on Power State, Uptime,
#			VMware Tools Version and Status, IP Address, Hostname, ESX(i) Host
#			Guest Is Running On, Consolidation State and Guest Version.
#
# Version : 2014-12-13
# Date    : December 13 2014
# Notes   : Added option AlwaysOK for drs_automation_level so the check will
#			always return an OK state (requested by Willem D’Haese).
#			Added option AlwaysOK for drs_dpm_level so the check will always
#			return an OK state (requested by Willem D’Haese).
#			Added option AlwaysOK for ha_host_monitoring so the check will
#			always return an OK state. Added option AlwaysOK for
#			ha_admission_control so the check will always return an OK state.
#			Added check Datastore_Performance_Overall which will return the
#			Datastore Performance for ALL connected hosts to the datastore
#			(requested by Willem D’Haese).
#			Added check Datastore_Cluster_Usage (requested by snapon_admin).
#			Added check Datastore_Cluster_Status (requested by snapon_admin).
#			Updated the Nagios XI Wizard checks List_Datastores, List_Guest,
#			List_Hosts and List_vCenter_Objects with improved encoding to
#			allow UTF-8 characters (reported by DingGuo Xiao).
#			Fixed bug in Datastore_Usage to limit the amount of decimal places
#			returned for the Used Space value. Fixed bug in certain checks like
#			Guest_Snapshot where guests have special characters like a \
#			backslash (reported by Dennis Peere). Updated Host_Status checks
#			to report Triggered Alarms and trigger warning and critical states
#			if the alarms have not been acknowledged in vCenter (requested by
#			Pierre-François Gallic, Ian Bergeron, Jacob Estrin, Brice Courault).
#			Added argument --perfdata_option which allows you to disable the
#			check name being appended to the end of the performance data string
#			in square brackets, as some monitoring systems like Centreon do not
#			like this (reported/requested by Bruno Guerpillon).
#
# Version : 2015-01-29
# Date    : January 29 2015
# Notes   : Fixed bug in Guest_CPU_Usage where high CPU usage could result in
#			a negative free value.
#			Added --modifier argument to allow request and response data to be
#			modified for Host and Guest checks (requested by Willem D’Haese).
#			Added Guest_Host check for determining if the ESX(i) host the guest
#			is running on matches the parent_hosts defined in Nagios (requested
#			by Virgil Hoover and other attendees at the Nagios World Conference
#			2014). This check will work in conjunction with the upcoming
#			box293_event_handler plugin to run on the Nagios host.
#			Added the --query_url, --query_username, --query_password and
#			--service_status_info arguments to allow the plugin to query Nagios
#			for checks like Guest_Host to determine Nagios parent object directive.
#			Added more debugging to the Nagios XI Wizard List_xxx checks.
#			--debug option will now show how long the plugin ran for.
#			All cluster checks now report the name of the cluster at the
#			beginning of the status output (requested by Willem D’Haese).
#
# Version : 2015-03-03
# Date    : March 3 2015
# Notes   : Added argument --exclude_snapshot to be used with the Guest_Snapshot
#			check. This allows you to exclude snapshots that contain specific text
#			in the NAME of the snapshot (requested by Pierre-François Gallic).
#			Changed --perfdata_option to allow you to specify what metrics you
#			want the specific check to use / report on, applies to all checks
#			that return performance data. See manual for full details for each
#			check (requested by Bruno Guerpillon).
#			Fixed bug in Cluster_HA_Status that caused check to fail when the
#			Slot Size had been defined using vSphere Web Interface (reported by
#			Daniel Vleeshakker).
#			Re-fixed bug in Datastore_Usage to limit the amount of decimal
#			places returned for the Used Space value.
#			Fixed bug in Datastore_Cluster_Usage to limit the amount of decimal
#			places returned for the Used Space value.
#
# Version : 2015-05-21
# Date    : May 21 2015
# Notes   : Updated all host related checks to return an OK status IF the host
#			is in Standby Mode. Specifically applies to the checks
#			Datastore_Performance, Datastore_Performance_Overall, Host_CPU_Info,
#			Host_CPU_Usage, Host_License_Status, Host_Memory_Usage,
#			Host_OS_Name_Version, Host_pNIC_Status, Host_pNIC_Usage, Host_Status,
#			Host_Storage_Adapter_Info, Host_Storage_Adapter_Performance,
#			Host_Switch_Status, Host_vNIC_Status. Also created the check
#			Host_Up_Down_State to be used as a host object check, helpful for
#			hosts that are in Standby Mode and you don't want to be alerted
#			about this as Standby Mode is normal behaviour. This check also
#			introduced the argument --standby_exit_state which allows you
#			to report a DOWN state if the host is in standby mode. Standby checks
#			Requested by Willem D'Haese and Hans Bos.
#			Fixed bug in Datastore_Cluster_Status check where it was not returning
#			any output, reported by Luc Lesouef.
#
# Version : 2015-08-03
# Date    : August 03 2015
# Notes   : Updated all checks to work with vSphere API versions v 4.0 onwards.
#			Some features get introduced by VMware in different API releases and
#			the plugin was not allowing for these differences. Specific checks updated
#			are Cluster_CPU_Usage, Cluster_Memory_Usage, Datastore_Cluster_Status
#			(only valid in vSphere 5.0 onwards), Datastore_Cluster_Usage (only valid
#			in vSphere 5.0 onwards), Guest_CPU_Info (# of cores only reported in
#			vSphere 5.0 onwards, CPU Reservation only reported on directly connected
#			ESXi hosts v 5.0 onwards ... via vCenter works for 4.0 onwards),
#			Guest_CPU_Usage, Guest_Disk_Performance, Guest_Disk_Usage,
#			Guest_Memory_Info (Memory Reservation only reported on directly connected
#			ESXi hosts v 5.0 onwards ... via vCenter works for 4.0 onwards),
#			Guest_Memory_Usage, Guest_NIC_Usage (Packets only reported for VMs running
#			on ESXi hosts 5.0 onwards), Guest_Status (Uptime only reported for guests
#			running on ESXi hosts 4.1 onwards, consolidation state only reported for VMs
#			running on ESXi hosts 5.0 onwards), Host_CPU_Info, Host_CPU_Usage,
#			Host_License_Status, Host_Memory_Usage,	Host_OS_Name_Version, Host_pNIC_Status,
#			Host_pNIC_Usage, Host_Status, Host_Storage_Adapter_Info,
#			Host_Storage_Adapter_Performance (will not work on hosts less than 4.1),
#			Host_Switch_Status, Host_Up_Down_State (no uptime or perfdata on hosts less
#			than 4.1), Host_vNIC_Status. API problem reported by Andrea Setti.
#			Fixed List_Hosts check used by Nagios XI wizard so that it correctly detects
#			if a host has storage adapters or datastores (reported by maddev).
#			Fixed some issues with guest consolidation detection.
#			Updated Guest_Status to alert if guestToolsNotRunning is detected, critical
#			by default. Reported by Olivier Cheron.
#
my $current_version = '2015-08-03';
# ------------------------------------------------------------------------------
# 				END Version Notes
# ------------------------------------------------------------------------------
#				BEGIN Initial Checks
# ------------------------------------------------------------------------------
# Record the time the plugin started
my $time_script_started = time;

use strict;
use File::Basename;
# Get the filename of the script before VMware::VIRuntime hides it
my $script_basename = basename($0);
my $script = $0;

# Need to generate POD information now as VMware::VIRuntime will cause problems
my $pod_usage = `perldoc -t $0`;

# Define Options
my %opts = (
	check => {
		type => '=s',
		help => 'Valid checks are: Cluster_CPU_Usage|Cluster_DRS_Status|Cluster_EVC_Status|Cluster_HA_Status|Cluster_Memory_Usage|Cluster_Resource_Info|Cluster_Swapfile_Status|Cluster_vMotion_Info|Datastore_Cluster_Status|Datastore_Cluster_Usage|Datastore_Performance|Datastore_Performance_Overall|Datastore_Usage|Guest_CPU_Info|Guest_CPU_Usage|Guest_Disk_Performance|Guest_Disk_Usage|Guest_Host|Guest_Memory_Info|Guest_Memory_Usage|Guest_NIC_Usage|Guest_Snapshot|Guest_Status|Host_CPU_Info|Host_CPU_Usage|Host_License_Status|Host_Memory_Usage|Host_OS_Name_Version|Host_pNIC_Status|Host_pNIC_Usage|Host_Status|Host_Storage_Adapter_Info|Host_Storage_Adapter_Performance|Host_Switch_Status|Host_Up_Down_State|Host_vNIC_Status|vCenter_License_Status|vCenter_Name_Version',
		required => 0,
		}, # End 'check' => {
	concurrent_checks => {
		type => '=i',
		help => 'Maximum amount of concurrent checks that can run at any one time. Default is 15. This option helps prevent the vMA appliance from being overloaded.',
		required => 0,
		default => 15,
		}, # End 'concurrent_checks' => {
	cluster => {
		type => '=s',
		help => 'You will need to provide a cluster name for checks like: Cluster_CPU_Usage|Cluster_DRS_Status|Cluster_HA_Status|Cluster_Memory_Usage|Cluster_Resource_Info|Cluster_Swapfile_Status|Cluster_vMotion_Info|Guest_Snapshot.',
		required => 0,
		}, # End 'cluster' => {
	critical => {
		type => '=s',
		help => 'Allows you to provide a critical threshold for the check. Multiple thresholds can be defined as some checks have thresholds for different metrics (like "disk rate" and "latency"). Each critical threshold is in the format <type>:<value> such as "cpu_free:10". The value is relative to the default metric(s) used by the check OR the type defined using the --reporting_si argument. Multiple thresholds are separated with a comma such as "disk_rate:150,disk_latency:30". If the --critical argument is not supplied then it will not return a critical state. Supplying the --critical argument does not require the --warning argument however if both arguments are supplied then both thresholds are checked and triggered accordingly.',
		required => 0,
		}, # End 'critical' => {
	datacenter => {
		type => '=s',
		help => 'You will need to provide a Datacenter name for checks like: Guest_Snapshot.',
		required => 0,
		}, # End 'datacenter' => {
	debug => {
		type => "",
		help => 'Generates a LOT of verbose information about what the plugin is doing. Creates the file /home/vi-admin/box293_check_vmware_debug_log.txt. If the debug file exists it will be overwritten.',
		required => 0,
		}, # End 'debug' => {
	drs_automation_level => {
		type => '=s',
		help => 'Should the clusters\' DRS Automation Level setting be manual|partiallyAutomated|fullyAutomated|AlwaysOK? This will determine the service state, fullyAutomated by default.',
		required => 0,
		}, # End 'drs_automation_level' => {
	drs_dpm_level => {
		type => '=s',
		help => 'Should the clusters\' DRS Power Management (DPM) setting be off|manual|automated|AlwaysOK? This will determine the service state, off by default.',
		required => 0,
		}, # End 'drs_dpm_level' => {
	drs_state => {
		type => '=s',
		help => 'Should the clusters\' Distributed Resource Scheduler (DRS) state be enabled or disabled? This will determine the service state, enabled by default.',
		required => 0,
		}, # End 'drs_state' => {
	exclude_issue => {
		type => '=s',
		help => 'Prevent certain HOST or CLUSTER event states from causing a warning or critical status (like enabling SSH). Exclude options are: ClusterOvercommittedEvent|DasClusterIsolatedEvent|DasHostFailedEvent|DasHostIsolatedEvent|HeartbeatDatastoreNotSufficient|HostNoRedundantManagementNetworkEvent|InsufficientFailoverResourcesEvent|LocalTSMEnabledEvent|RemoteTSMEnabledEvent and you can supply multiple options by separating them with a comma like: LocalTSMEnabledEvent,RemoteTSMEnabledEvent',
		required => 0,
		}, # End 'exclude_issue' => {
	exclude_snapshot => {
		type => '=s',
		help => 'Exclude snapshots that contain specific text, useful for backup products that create/remove snapshots freuqently. Examples are GX_BACKUP or VEEAM and you can supply multiple options by separating them with a comma like: GX_BACKUP,VEEAM. NOTE: text is CaSe sEnSaTiVe!',
		required => 0,
		}, # End 'exclude_snapshot' => {
	evc_mode => {
		type => '=s',
		help => 'Should the clusters\' Enhanced vMotion Compatibility (EVC) Mode be disabled or enabled? This will determine the service state, disabled by default.',
		required => 0,
		}, # End 'evc_mode' => {
	guest => {
		type => '=s',
		help => 'The name of the virtual machine you are performing a check against.',
		required => 0,
		}, # End 'guest' => {
	guest_consolidation_state => {
		type => '=s',
		help => 'A sub option of the Guest_Status check. Allows you to define what service state (OK, WARNING, CRITICAL) should be returned if the guest disks require consolidation (true, false). The option is in the format <consolidation_state>:<service_state> such as "true:WARNING". Both states can be defined by separating with a comma such as "true:WARNING,false:OK". Default states are: true:CRITICAL, false:OK',
		required => 0,
		}, # End 'guest_consolidation_state' => {
	guest_power_state => {
		type => '=s',
		help => 'A sub option of the Guest_Status check. Allows you to define what service state (OK, WARNING, CRITICAL) should be returned for different guest power states (poweredOn, poweredOff, suspended). Each option is in the format <power_state>:<service_state> such as "poweredOff:CRITICAL". Multiple options are separated with a comma such as "poweredOn:OK,poweredOff:CRITICAL,suspended:WARNING". Default states are: poweredOn:OK, poweredOff:CRITICAL, suspended:CRITICAL',
		required => 0,
		}, # End 'guest_power_state' => {
	guest_tools_version_state => {
		type => '=s',
		help => 'A sub option of the Guest_Status check. Allows you to define what service state (OK, WARNING, CRITICAL) should be returned for different guest tools version status (guestToolsBlacklisted, guestToolsCurrent, guestToolsNeedUpgrade, guestToolsSupportedNew, guestToolsSupportedOld, guestToolsTooNew, guestToolsTooOld, guestToolsUnmanaged). Each option is in the format <tools_state>:<service_state> such as "guestToolsUnmanaged:OK". Multiple options are separated with a comma such as "guestToolsNeedUpgrade:CRITICAL,guestToolsSupportedOld:CRITICAL,". Default states are: guestToolsBlacklisted:CRITICAL, guestToolsCurrent:OK, guestToolsNeedUpgrade:WARNING, guestToolsSupportedNew:OK, guestToolsSupportedOld:WARNING, guestToolsTooNew:CRITICAL, guestToolsTooOld:CRITICAL, guestToolsUnmanaged:OK',
		required => 0,
		}, # End 'guest_tools_version_state' => {
	ha_state => {
		type => '=s',
		help => 'Should the clusters\' High Availability (HA) state be enabled or disabled? This will determine the service state, enabled by default.',
		required => 0,
		}, # End 'ha_state' => {
	ha_admission_control => {
		type => '=s',
		help => 'Should the HA clusters\' Admission Control option be enabled|disabled|AlwaysOK? This will determine the service state, enabled by default.',
		required => 0,
		}, # End 'ha_admission_control' => {
	ha_host_monitoring => {
		type => '=s',
		help => 'Should the HA clusters\' Host Monitoring option be enabled|disabled|AlwaysOK? This will determine the service state, enabled by default.',
		required => 0,
		}, # End 'ha_host_monitoring' => {
	help => {
		type => "",
		help => 'Display the Help text',
		required => 0,
		}, # End 'help' => {
	hide_key => {
		type => '',
		help => 'Do not display the license key for Host_License_Status or vCenter_License_Status checks. Used when this information is deemed highly sensitive.',
		required => 0,
		}, # End 'hide_key' => {
	host => {
		type => '=s',
		help => 'Name of the ESX(i) host you are performing the check against. If connecting directly to an ESX(i) host without going via a vCenter server DO not define the --host argument, the --server argument will be used instead.',
		required => 0,
		}, # End 'host' => {
	license => {
		type => "",
		help => 'Display the GNU General Public License. To see the license type:\n./box293_check_vmware.pl --license | more\n',
		required => 0,
		}, # End 'license' => {
	modifier => {
		type => '=s',
		help => 'The modifier argument allows manipulation of input and output values in Guest and Host checks. Each modifier is in the format <type>:<operation>:<option>:<value> such as "request:add:insensitive:.box293.local" or "response:remove:insensitive:.box293.local". Multiple modifiers are separated with a comma such as "request:add:insensitive:.box293.local,response:shift:upper:shift". <type> = request OR response | <operation> = add OR remove OR shift | <option> = upper OR lower OR insensitive | <value> = the VALUE to add or remove OR \'shift\' for shift operations. Refer to the manual for more detailed information on this argument.',
		required => 0,
		}, # End 'modifier' => {
	mtu => {
		type => '=i',
		help => 'For vSwitch and NIC checks you can query the MTU size like: 1500 or 9000. This will determine the service state, no default value.',
		required => 0,
		}, # End 'mtu' => {
	name => {
		type => '=s',
		help => 'You will need to provide a name for checks like: Datastore|Datastore_Cluster|Host_pNIC_Status|Host_pNIC_Usage|Host_Storage_Adapter_Info|Host_Storage_Adapter_Performance|Host_Switch_Status|Host_vNIC_Status. For switch checks, a host can have multiple vSwitches, so you can specify which vSwitches you want checked (otherwise all vSwitches will be checked). Same applies for pNIC and vNIC checks. You can check multiple objects by separating them with a comma such as vmnic0,vmnic1',
		required => 0,
		}, # End 'name' => {
	nic_state => {
		type => '=s',
		help => 'For NIC checks (including NICs in a vSwitch) you can query if a NIC is connected or disconnected. This will determine the service state, connected by default.',
		required => 0,
		}, # End 'nic_state' => {
	nic_duplex => {
		type => '=s',
		help => 'For NIC checks (including NICs in a vSwitch) you can query the duplex setting which can be full or half. This will determine the service state, full by default.',
		required => 0,
		}, # End 'nic_duplex' => {
	nic_speed => {
		type => '=i',
		help => 'For NIC checks (including NICs in a vSwitch) you can query the NIC speed like: 10|100|1000|10000|40000. This will determine the service state, no default value.',
		required => 0,
		}, # End 'nic_speed' => {
	perfdata_option => {
		type => '=s',
		help => 'Allows you to modify the perfdata string where applicable. Each option is in the format <option>:<value> such as "post_check:disabled". By default, checks that return a performance data string have the check name appended to the end of the performance data string in square brackets (PNP4Nagios uses this for templates) ... post_check:disabled prevents this from happening as some monitoring systems like Centreon do not like this. Other options can be used to select what performance data you want checked / reported on such as "Latency:1". Multiple options are separated with a comma such as "Latency:1,post_check:disabled". Refer to the manual for what options are specific to which check.',
		required => 0,
		}, # End 'perfdata_option' => {
	query_url => {
		type => '=s',
		help => 'This is the URL of the Nagios server\'s objectjson.cgi. Required for the Guest_Host check. Example: http://xitest.box293.local/nagios/cgi-bin/objectjson.cgi',
		required => 0,
		}, # End 'query_url' => {
	query_username => {
		type => '=s',
		help => 'This is the username for accessing the Nagios server\'s objectjson.cgi. Required for the Guest_Host check.',
		required => 0,
		}, # End 'query_username' => {
	query_password => {
		type => '=s',
		help => 'This is the password for accessing the Nagios server\'s objectjson.cgi. Required for the Guest_Host check.',
		required => 0,
		}, # End 'query_password' => {
	reporting_si => {
		type => '=s',
		help => 'The International System of Unit to use for results that are returned for checks like CPU Usage, Memory Usage etc. Argument format is <type>:<SI>, for example CPU:GHz or Datastore_Rate:kBps. Multiple arguments are allowed, separated with a comma, for example Datastore_Rate:kBps,Latency:ms . This is an optional argument as all checks will use a default unit unless specified. Refer to the manual for a detailed list of allowed arguments and what checks they work with.',
		required => 0,
		}, # End 'reporting_si' => {
	server => {
		type => '=s',
		help => 'Name of the vCenter Server OR ESX(i) host you are performing the check against.',
		required => 0,
		}, # End 'server' => {
	service_status_info => {
		type => '=s',
		help => 'The current "Status Information" of the Nagios service which is running the Guest_Host check (required for the Guest_Host check). In a Nagios service object definition use the macro $SERVICEOUTPUT$, refer to the manual for a detailed explanation.',
		required => 0,
		}, # End 'service_status_info' => {
	standby_exit_state => {
		type => '=s',
		help => 'If an ESX(i) host is in Standby mode, the default exit state is UP. If you want it to report a DOWN state, use this argument with the value down. Example: --standby_exit_state down ',
		required => 0,
		}, # End 'standby_exit_state' => {
	swapfile_policy => {
		type => '=s',
		help => 'Should the clusters\' Swapfile Policy option be vmDirectory or hostLocal? This will determine the service state, vmDirectory by default.',
		required => 0,
		}, # End 'swapfile_policy' => {
	timeout => {
		type => '=i',
		help => 'Specify the time a check is allowed to execute for. 60 seconds by default.',
		required => 0,
		default => 60,
		}, # End 'timeout' => {
	version => {
		type => "",
		help => 'Display the plugin version',
		required => 0,
		}, # End 'version' => {
	warning => {
		type => '=s',
		help => 'Allows you to provide a warning threshold for the check. Multiple thresholds can be defined as some checks have thresholds for different metrics (like "disk rate" and "latency"). Each warning threshold is in the format <type>:<value> such as "cpu_free:10". The value is relative to the default metric(s) used by the check OR the type defined using the --reporting_si argument. Multiple thresholds are separated with a comma such as "disk_rate:150,disk_latency:30". If the --warning argument is not supplied then it will not return a warning state. Supplying the --warning argument does not require the --critical argument however if both arguments are supplied then both thresholds are checked and triggered accordingly.',
		required => 0,
		}, # End 'warning' => {
	); # End my %opts = (

# Read/Validate options and connect to the server
Opts::add_options(%opts);

# Check the options
Opts::parse();

# Perform some pre-flight checks
my $pre_flight_checks = 0;
Debug_Process('create', 'Line ' . __LINE__ . ' Script started @ ' . localtime($time_script_started));
Debug_Process('append', 'Line ' . __LINE__ . ' $current_version: \'' . $current_version . '\'');
Debug_Process('append', 'Line ' . __LINE__ . ' $pre_flight_checks: \'' . $pre_flight_checks . '\'');

if (Opts::option_is_set('license')) {
	$pre_flight_checks = 1;
	Print_License();
	exit(3);
	} # End if (!Opts::option_is_set('license')) {

if (Opts::option_is_set('help')) {
	$pre_flight_checks = 1;
	Print_Help();
	exit(3);
	} # End if (!Opts::option_is_set('help')) {

if (Opts::option_is_set('version')) {
	$pre_flight_checks = 1;
	Version();
	exit(0);
	} # End if (!Opts::option_is_set('help')) {

if (!Opts::option_is_set('check')) {
	$pre_flight_checks = 1;
	Debug_Process('append', 'Line ' . __LINE__ . ' $pre_flight_checks: \'' . $pre_flight_checks . '\'');
	Debug_Process('append', 'Line ' . __LINE__ . ' --check argument is REQUIRED, aborting!');
	print "\n--check argument is REQUIRED, aborting!\n\n";
	Print_Help();
	print "--check argument is REQUIRED, aborting!\n\n";
	print "To see the HELP type box293_check_vmware.pl --help | more\n\n";
	exit(3);
	} # End if (!Opts::option_is_set('check')) {
else {
	Debug_Process('append', 'Line ' . __LINE__ . ' --check argument is supplied and is \'' . Opts::get_option('check') .'\', proceeding.');
	} # End else {

if (!Opts::option_is_set('server')) {
	$pre_flight_checks = 1;
	Debug_Process('append', 'Line ' . __LINE__ . ' $pre_flight_checks: \'' . $pre_flight_checks . '\'');
	Debug_Process('append', 'Line ' . __LINE__ . ' --server argument is REQUIRED, aborting!');
	print "\n--server argument is REQUIRED, aborting!\n\n";
	Print_Help();
	print "\n--server argument is REQUIRED, aborting!\n\n";
	print "To see the HELP type box293_check_vmware.pl --help | more\n\n";
	exit(3);
	} # End if (!Opts::option_is_set('server')) {
else {
	Debug_Process('append', 'Line ' . __LINE__ . ' --server argument is supplied and is \'' . Opts::get_option('server') .'\', proceeding.');
	} # End else {

# Proceed if pre_flight_checks flag wasn't triggered
if ($pre_flight_checks == 0) {
	# Validate the options
	Opts::validate();
	
	# Make sure we don't have too many checks running
	my @running_checks;
	open (PS_OUT, "ps -C $script_basename --no-headers|");
	while (<PS_OUT>) {
		push @running_checks, $_;
		} # End while (<PS_OUT>) {
	close (PS_OUT);
	my $total_checks = @running_checks - 1;
	my $allowed_checks = Opts::get_option('concurrent_checks');
	Debug_Process('append', 'Line ' . __LINE__ . " Running Checks: '" . @running_checks . "'");
	Debug_Process('append', 'Line ' . __LINE__ . " Total Checks: '$total_checks'");
	Debug_Process('append', 'Line ' . __LINE__ . " Concurrent Checks: '$allowed_checks'");
	if ($total_checks > $allowed_checks) {
		# Too many checks, script will not run
		# Exit the script outputting the $exit_message and $exit_state.
		Debug_Process('append', 'Line ' . __LINE__ . " Total number of concurrent checks exceeds '$allowed_checks', aborting!");
		Debug_Process('append', 'Line ' . __LINE__ . " Exit Code: '3'");
		Debug_Process('append', 'Line ' . __LINE__ . ' Script ended @ ' . localtime(time));
		print "Total number of concurrent checks exceeds $allowed_checks, aborting!\n";
		exit 3;
		# ------------------------------------------------------------------------------
		#				End Initial Checks
		# ------------------------------------------------------------------------------
		} # End if ($total_checks > $allowed_checks) {
	else {
		Debug_Process('append', 'Line ' . __LINE__ . " Total number of concurrent checks NOT exceeded, proceeding.");
		# ------------------------------------------------------------------------------
		#				BEGIN Basic Requirements
		# ------------------------------------------------------------------------------
		use VMware::VIRuntime;
		use Encode;
		use HTTP::Date;
		use POSIX;
		use Scalar::Util qw/reftype looks_like_number/;
		use Switch;
		use Text::Balanced qw/extract_bracketed/;
		use Time::Piece;
		use Time::Seconds;
		# ------------------------------------------------------------------------------
		#				END Basic Requirements
		# ------------------------------------------------------------------------------
		#				BEGIN Global Hash
		# ------------------------------------------------------------------------------
		# Metrics Lookup
		our %Metrics_Lookup = (
			Cluster_CPU_Usage 					=> [ 'Cores', 'CPU_Effective', 'CPU_Free', 'CPU_Total', 'CPU_Used' ],
			Cluster_Memory_Usage 				=> [ 'Memory_Effective', 'Memory_Free', 'Memory_Total', 'Memory_Used' ],
			Cluster_Resource_Info 				=> [ 'Cores', 'CPU_Effective', 'CPU_Free', 'CPU_Total', 'CPU_Used', 'Hosts_Available', 'Hosts_Total', 'Memory_Effective', 'Memory_Free', 'Memory_Total', 'Memory_Used' ],
			Datastore_Cluster_Usage	 			=> [ 'Capacity', 'Children', 'Free', 'Used' ],
			Datastore_Performance				=> {
				Datastore_Rate		=> [ 'read', 'write' ],
				Number_Of			=> [ 'numberRead', 'numberWrite' ],
				Latency				=> [ 'deviceReadLatency', 'deviceWriteLatency' ]
 				},
			Datastore_Performance_Overall		=> {
				Datastore_Rate		=> [ 'read', 'write' ],
				Hosts				=> [ 'Hosts' ],
				Number_Of			=> [ 'numberRead', 'numberWrite' ],
				Latency				=> [ 'deviceReadLatency', 'deviceWriteLatency' ]
 				},
 			Datastore_Usage 					=> [ 'Datastore_Capacity', 'Datastore_Free', 'Datastore_Used' ],
 			Guest_CPU_Info 						=> [ 'Cores', 'CPU_Limit', 'CPU_Reservation', 'CPU_Total' ],
 			Guest_CPU_Usage 					=> {
				CPU_Available		=> [ 'usagemhz' ],
				CPU_Free			=> [ 'usagemhz' ],
				CPU_Ready_Time		=> [ 'ready' ],
				CPU_Used			=> [ 'usagemhz' ]
 				},
			Guest_Disk_Performance				=> {
				Averaged			=> [ 'numberReadAveraged', 'numberWriteAveraged' ],
				Disk_Rate			=> [ 'read', 'write' ],
				Latency				=> [ 'readLatencyUS', 'writeLatencyUS', 'totalReadLatency', 'totalWriteLatency' ]
				},
			Guest_Disk_Usage 					=> [ 'Disk_Capacity', 'Disk_Free', 'Disk_Size_On_Datastore', 'Disk_Snapshot_Space', 'Disk_Suspend_File', 'Disk_Swap_File', 'Disk_Swap_Userworld', 'Disk_Usage' ],
			Guest_Memory_Info					=> [ 'Memory_Limit', 'Memory_Reservation', 'Memory_Total' ],
			Guest_Memory_Usage 					=> {
				Memory_Active		=> [ 'active' ],
				Memory_Ballooned	=> [ 'vmmemctl' ],
				Memory_Consumed		=> [ 'consumed', 'Memory_Free', 'Memory_Total' ],
				Memory_Free			=> [ 'consumed', 'Memory_Free', 'Memory_Total' ],
				Memory_Overhead		=> [ 'overhead' ],
				Memory_Shared		=> [ 'shared' ],
				Memory_Swap			=> [ 'swapin', 'swapout', 'swapinRate', 'swapoutRate' ],
				Memory_Total		=> [ 'consumed', 'Memory_Free', 'Memory_Total' ]
 				},
 			Guest_NIC_Usage 					=> {
				NIC_Rate			=> [ 'received', 'transmitted' ],
				NIC_Packets			=> [ 'packetsRx', 'packetsTx' ]
 				},
 			Host_CPU_Usage 						=> [ 'CPU_Free', 'CPU_Total', 'CPU_Used' ],
 			Host_Memory_Usage 					=> [ 'Memory_Free', 'Memory_Total', 'Memory_Used' ],
 			Host_pNIC_Usage 					=> {
				NIC_Rate			=> [ 'received', 'transmitted' ],
				NIC_Packets			=> [ 'packetsRx', 'packetsTx' ],
				NIC_Packet_Errors	=> [ 'errorsRx', 'errorsTx' ]
 				},
 			Host_Storage_Adapter_Performance	=> {
				Averaged			=> [ 'numberReadAveraged', 'numberWriteAveraged' ],
				HBA_Rate			=> [ 'read', 'write' ],
				HBA_Latency			=> [ 'totalReadLatency', 'totalWriteLatency' ]
				}
			);


		# VMware overallStatus
		our %Overall_Status = (
			gray	=> 'WARNING',	# The configuration status of the entity is not being monitored
			yellow	=> 'WARNING',	# A problem is about to occur or a transient condition has occurred (For example, reconfigure fail-over policy)
			red		=> 'CRITICAL',	# A problem has been detected involving the entity
			green	=> 'OK'			# No configuration issues have been detected
			); # End our %Overall_Status = (


		# International System of Units for Bytes
		our %SI_Bytes = (
			B	=>	1,
			kB	=>	1024,
			MB	=>	1048576,
			GB	=>	1073741824,
			TB	=>	1099511627776,
			PB	=>	1125899906842624,
			EB	=>	1152921504606846976
			); # End our %SI_Bytes = (

			
		# International System of Units for Bytes Per Second
		our %SI_Bytes_PS = (
			Bps		=>	1,
			kBps	=>	1024,
			MBps	=>	1048576,
			GBps	=>	1073741824,
			TBps	=>	1099511627776,
			PBps	=>	1125899906842624,
			EBps	=>	1152921504606846976
			); # End our %SI_Bytes_PS = (

			
		# International System of Units for Hertz
		our %SI_Hertz = (
			Hz	=>	1,
			kHz	=>	1000,
			MHz	=>	1000000,
			GHz	=>	1000000000,
			THz	=>	1000000000000
			); # End our %SI_Hertz = (


		# International System of Units for Time
		our %SI_Time = (
			us	=>  0.000001,
			ms	=>  0.001,
			s	=>	1,
			m	=>	60,
			h	=>	3600,
			d	=>	86400,
			); # End our %SI_Time = (


		# International System of Units for Time - Human Readable
		our %SI_Time_Human = (
			us	=>  'microsecond',
			ms	=>  'millisecond',
			s	=>	'second',
			m	=>	'minute',
			h	=>	'hour',
			d	=>	'day',
			); # End our %SI_Time_Human = (


		# International System of Units Lookup
		our %SI_Lookup = (
			CPU_Speed				=>	\%SI_Hertz,
			Datastore_Cluster_Size	=>	\%SI_Bytes,
			Datastore_Rate			=>	\%SI_Bytes_PS,
			Datastore_Size			=>	\%SI_Bytes,
			Disk_Rate				=>	\%SI_Bytes_PS,
			Disk_Size				=>	\%SI_Bytes,
			HBA_Rate				=>	\%SI_Bytes_PS,
			Latency					=>	\%SI_Time,
			Memory_Rate				=>	\%SI_Bytes_PS,
			Memory_Size				=>	\%SI_Bytes,
			NIC_Rate				=>	\%SI_Bytes_PS,
			Time					=>	\%SI_Time,
			); # End our %SI_Lookup = (


		# Nagios exit states
		our %States = (
			OK       => 0,
			STANDBY  => 0,
			UP       => 0,
			WARNING  => 1,
			CRITICAL => 2,
			DOWN 	 => 2,
			UNKNOWN  => 3
			); # End our %States = (


		# Nagios exit state names
		our %State_Names = (
			0 => 'OK',
			1 => 'WARNING',
			2 => 'CRITICAL',
			3 => 'UNKNOWN'
			); # End %State_Names = (


		# VMware Virtual NIC Types
		our %vNIC_Types = (
			'faultToleranceLogging' => 'Fault Tolerance',
			'management' 			=> 'Management',
			'vSphereReplication' 	=> 'Replication',
			'vmotion' 				=> 'vMotion'
			);
		# ------------------------------------------------------------------------------
		#				END Global Hash
		# ------------------------------------------------------------------------------
		#				BEGIN Global Arrays
		# ------------------------------------------------------------------------------
		our @Exclude_Snapshot_Supplied;
		our @Modifiers_Supplied_Global;
		# ------------------------------------------------------------------------------
		#				END Global Arrays
		# ------------------------------------------------------------------------------
		#				BEGIN Global Variables
		# ------------------------------------------------------------------------------
		our $api_version;
		our $cluster_drs_message;
		our $cluster_ha_message;
		our $exit_message;
		our $exit_message_abort;
		our $exit_message_current;
		our $exit_message_to_add;
		our $exit_state;
		our $exit_state_abort;
		our $exit_state_current;
		our $exit_state_to_add;
		our $exit_state_to_return;
		our $guest_connection_state;
		our $guest_connection_state_flag;
		our $guest_uptime;
		our $guest_uptime_state_flag;
		our $host_connection_state;
		our $host_connection_state_flag;
		our $host_uptime;
		our $host_uptime_state_flag;
		our $message;
		our $message_current;
		our $message_to_add;
		our $nic_type;
		our $perfdata_message;
		our $perfdata_message_current;
		our $perfdata_message_to_add;
		our $request_type;
		our $si_object_type;
		our $si_prefix_current;
		our $si_prefix_default;
		our $si_prefix_to_return;
		our $si_type;
		our $si_value_current;
		our $si_value_to_return;
		our $snapshot_info_all;
		our $target_cluster_view;
		our $target_datacenter_view;
		our $target_datastore_cluster_view;
		our $target_datastore_view;
		our $target_guest_option;
		our $target_guest_view;
		our $target_host_option;
		our $target_host_view;
		our $target_server_type;
		# ------------------------------------------------------------------------------
		#				END Global Variables
		# ------------------------------------------------------------------------------
		#				BEGIN Subroutines
		# ------------------------------------------------------------------------------
		sub API_Version {
			Debug_Process('append', 'Line ' . __LINE__ . ' API_Version');
			
			# Are we connected to a vCenter Server?
			$target_server_type = Server_Type();
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type: \'' . $target_server_type . '\'');
			if ($target_server_type ne 'VirtualCenter') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type ne \'VirtualCenter\'');
				# Get the host that the guest is running on
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'summary.runtime.host\')->value: \'' . $target_guest_view->get_property('summary.runtime.host')->value . '\'');
				# Define the property filter for the host
				push my @target_properties, ('summary.config.product.version', 'summary.runtime.powerState');
				# Get the host
				($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));
				$api_version = $target_host_view->get_property('summary.config.product.version');
				} # End if ($target_server_type ne 'VirtualCenter') {
			else {
				my $target_vcenter_view = Vim::get_service_content();
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_vcenter_view: \'' . $target_vcenter_view . '\'');
				$api_version = $target_vcenter_view->about->version;
				} # End else {
			Debug_Process('append', 'Line ' . __LINE__ . ' $api_version: \'' . $api_version . '\'');
			
			return $api_version;
			} # End sub API_Version {


		sub Build_Exit_Message {
			Debug_Process('append', 'Line ' . __LINE__ . ' Build_Exit_Message');
			my $exit_message_type = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_type: \'' . $exit_message_type . '\'');
			
			# Determine the message type
			switch ($exit_message_type) {
				case 'Exit' {
					$exit_message_current = $_[1];
					$exit_message_to_add = $_[2];

					if (defined($exit_message_current)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_current: \'' . $exit_message_current . '\'');
						} # End if (defined($exit_message_current)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_current: \'\'');
						} # End else {
					
					if (defined($exit_message_to_add)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_to_add: \'' . $exit_message_to_add . '\'');
						} # End if (defined($exit_message_to_add)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_to_add: \'\'');
						} # End else {
					
					# Determine if we create or build the $exit_message
					if (!defined($exit_message_current)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($exit_message_current)');
						Debug_Process('append', 'Line ' . __LINE__ . ' Create a new $exit_message');
						# Create a new $exit_message
						$exit_message = $exit_message_to_add;
						} # End if (!defined($exit_message_current)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_message_current)');
						Debug_Process('append', 'Line ' . __LINE__ . ' Build on the existing $exit_message');
						# Build on the existing $exit_message
						$exit_message = "$exit_message_current, $exit_message_to_add";
						} # End else {
					} # End case 'Exit' {
				
				case 'Perfdata' {
					$exit_message_current = $_[1];
					$perfdata_message_current = $_[2];
					
					if (defined($perfdata_message_current)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_message_current)');
						$exit_message = $exit_message_current . "|" . $perfdata_message_current;
						} # End if (defined($perfdata_message_current)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($perfdata_message_current)');
						$exit_message = $exit_message_current;
						} # End else {
					} # End case 'Perfdata' {
				} # End switch ($exit_message_type) {

			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');		
			return $exit_message;
			} # End sub Build_Exit_Message {


		sub Build_Message {
			Debug_Process('append', 'Line ' . __LINE__ . ' Build_Message');
			my $build_message_current = $_[0];
			my $build_message_to_add = $_[1];
			if (defined($build_message_current)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $build_message_current: \'' . $build_message_current . '\'');
				} # End if (defined($build_message_current)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $build_message_current: \'\'');
				} # End else {
			Debug_Process('append', 'Line ' . __LINE__ . ' $build_message_to_add: \'' . $build_message_to_add . '\'');
			
			# Determine if we create or build the $message
			if (!defined($build_message_current)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' !defined($build_message_current)');
				Debug_Process('append', 'Line ' . __LINE__ . ' Create a new $message');
				# Create a new $message
				$message = $build_message_to_add;
				} # End if (!defined($build_message_current)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' Build on the existing $message');
				# Build on the existing $message
				# Determine if we seperate the messages with provided delimiter
				if (defined($_[2])) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($_[2])');
					if ($build_message_current eq '') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $build_message_current eq \'\'');
						$message = $build_message_to_add;
						} #End if ($build_message_current eq '') {
					else {
						$message = $build_message_current . $_[2] . $build_message_to_add;
						} # End else {
					} # End if (defined($_[2])) {
				else {
					if (defined($build_message_to_add)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($build_message_to_add)');
						$message = $build_message_current . $build_message_to_add;
						} # End if (defined($build_message_to_add)) {
					else {
						$message = $build_message_current;
						} # End else {
					} # End else {
				} # End else {

			Debug_Process('append', 'Line ' . __LINE__ . ' $message: \'' . $message . '\'');		
			return $message;
			} # End sub Build_Message {


		sub Build_Perfdata_Message {
			Debug_Process('append', 'Line ' . __LINE__ . ' Build_Perfdata_Message');
			my $perfdata_message_type = $_[0];
			my $perfdata_string;
			my $message_string;

			Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_message_type: \'' . $perfdata_message_type . '\'');
			
			# Determine the message type
			switch ($perfdata_message_type) {
				case 'Build' {
					$perfdata_message_current = $_[1];
					$perfdata_message_to_add = $_[2];

					if (defined($perfdata_message_current)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_message_current: \'' . $perfdata_message_current . '\'');
						} # End if (defined($perfdata_message_current)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_message_current: \'\'');
						} # End else {
						
					if (defined($perfdata_message_to_add)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_message_to_add: \'' . $perfdata_message_to_add . '\'');
						} # End if (defined($perfdata_message_to_add)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_message_to_add: \'\'');
						} # End else {
						
					# Determine if we create or build the $perfdata_string
					if (!defined($perfdata_message_current)) {
						# Create a new $perfdata_string
						$perfdata_string = $perfdata_message_to_add;
						} # End if (!defined($perfdata_message_current)) {
					elsif (!defined($perfdata_message_to_add)) {
						# Create a new $perfdata_string
						$perfdata_string = $perfdata_message_current;
						} # End elsif (!defined($perfdata_message_to_add)) {
					else {
						# Build on the existing $perfdata_string
						$perfdata_string = "$perfdata_message_current $perfdata_message_to_add";
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_string: \'' . $perfdata_string . '\'');
					return $perfdata_string;
					} # End case 'Build' {
				
				case 'Create' {
					my %Thresholds_User = %{$_[1]};
					my $threshold_type = $_[2];
					my $threshold_compare = $_[3];
					$exit_state_current = $_[4];
					my $perfdata_label = $_[5];	# <-- Cannot contain the equals sign or single quote 
					my $perfdata_value = $_[6];	# <-- Ideally should not exceed 19 characters

					if (%Thresholds_User) {
						Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
						} # End if (%Thresholds_User) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'\'');
						} # End else {

					if (defined($threshold_type)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_type: \'' . $threshold_type . '\'');
						} # End if (defined($threshold_type)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_type: \'\'');
						} # End else {

					if (defined($threshold_compare)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_compare: \'' . $threshold_compare . '\'');
						} # End if (defined($threshold_compare)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_compare: \'\'');
						} # End else {

					if (defined($exit_state_current)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current: \'' . $exit_state_current . '\'');
						} # End if (defined($exit_state_current)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current: \'\'');
						} # End else {
						
					if (defined($perfdata_label)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_label: \'' . $perfdata_label . '\'');
						} # End if (defined($perfdata_label)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_label: \'\'');
						} # End else {

					if (defined($perfdata_value)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_value: \'' . $perfdata_value . '\'');
						} # End if (defined($perfdata_value)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_value: \'\'');
						} # End else {

					my $perfdata_uom;			# <-- Unit of measurement
					if (!defined($_[7])) {
						$perfdata_uom = '';
						} # End if (!defined($_[7])) {
					else {
						$perfdata_uom = $_[7];
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_uom: \'' . $perfdata_uom . '\'');
					
					# Get the warning threshold if it exists
					my $perfdata_warning;
					if (defined($Thresholds_User{'warning'}{$threshold_type})) {
						$perfdata_warning = $Thresholds_User{'warning'}{$threshold_type};
						} # End if (defined($Thresholds_User{'warning'}{$threshold_type})) {
					else {
						$perfdata_warning = '';
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_warning: \'' . $perfdata_warning . '\'');
					
					# Get the critical threshold if it exists
					my $perfdata_critical;
					if (defined($Thresholds_User{'critical'}{$threshold_type})) {
						$perfdata_critical = $Thresholds_User{'critical'}{$threshold_type};
						} # End if (defined($Thresholds_User{'warning'}{$threshold_type})) {
					else {
						$perfdata_critical = '';
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_critical: \'' . $perfdata_critical . '\'');
					
					# Determine if we need to check for any thresholds being triggered
					if ($threshold_compare eq 'none') {
						$message_string = '';
						$exit_state_to_return = 'OK';
						} # End if ($threshold_compare eq 'none') {
					else {
						# Determine if any thresholds were triggered
						($message_string, $exit_state_to_return) = Thresholds_Process($threshold_compare, $threshold_type, $perfdata_value, $perfdata_warning, $perfdata_critical);
						} # End else {
						
					# Create the $perfdata_string to return
					$perfdata_string = "\'$perfdata_label\'=$perfdata_value" . $perfdata_uom;

					Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_string: \'' . $perfdata_string . '\'');
					
					# Determine if $perfdata_warning and $perfdata_critical need to be part of $perfdata_string
					if ($perfdata_warning eq '') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_warning eq \'\'');
						# We don't need $perfdata_warning HOWEVER if we need $perfdata_critical then we will need warning
						if ($perfdata_critical ne '') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_critical ne \'\'');
							# We need $perfdata_critical
							$perfdata_string = "$perfdata_string;$perfdata_warning;$perfdata_critical";
							} # End if ($perfdata_critical ne '') {
						} # End if ($perfdata_warning eq '') {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_warning ne \'\'');
						# $perfdata_warning is required
						$perfdata_string = "$perfdata_string;$perfdata_warning";
						# Do we need $perfdata_critical ?
						if ($perfdata_critical ne '') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_critical ne \'\'');
							$perfdata_string = "$perfdata_string;$perfdata_critical";
							} # End if ($perfdata_critical ne '') {
						} # End else {

					# Build the $exit_state_to_return
					$exit_state_to_return = Build_Exit_State($exit_state_current, $exit_state_to_return);

					Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_string: \'' . $perfdata_string . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $message_string: \'' . $message_string . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_return: \'' . $exit_state_to_return . '\'');
					
					return ($perfdata_string, $message_string, $exit_state_to_return);
					} # End case 'create' {
				
				} # End switch ($perfdata_message_type) {
			} # End sub Build_Perfdata_Message {


		sub Build_Exit_State {
			Debug_Process('append', 'Line ' . __LINE__ . ' Build_Exit_State');
			$exit_state_current = $_[0];
			$exit_state_to_add = $_[1];
			if (defined($exit_state_current)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_state_current)');
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current: \'' . $exit_state_current . '\'');
				} # End if (defined($exit_state_current)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' !defined($exit_state_current)');
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current: \'\'');
				} # End else {
			if (defined($exit_state_to_add)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_state_to_add)');
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add: \'' . $exit_state_to_add . '\'');
				} # End if (defined($exit_state_to_add)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' !defined($exit_state_to_add)');
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add: \'\'');
				} # End else {
				
			# Determine if we create or build the $exit_state
			if (!defined($exit_state_current)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' !defined($exit_state_current)');
				# Check to see if we are adding anything
				if (!defined($exit_state_to_add)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !defined($exit_state_to_add)');
					Debug_Process('append', 'Line ' . __LINE__ . ' It hasn\'t been defined yet, it\'ll be OK');
					# It hasn't been defined yet, it'll be OK
					$exit_state = 'OK';
					} # End if (!defined($exit_state_to_add)) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_state_to_add)');
					Debug_Process('append', 'Line ' . __LINE__ . ' Create an $exit_state using $exit_state_to_add');
					# Create an $exit_state using $exit_state_to_add
					$exit_state = $exit_state_to_add;
					} # End else {
				} # End if (!defined($exit_state_current)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_state_current)');
				if (!defined($exit_state_to_add)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !defined($exit_state_to_add)');
					Debug_Process('append', 'Line ' . __LINE__ . ' We don\'t have anything to add so we\'ll make it what it is currently');
					# We don't have anything to add so we'll make it what it is currently
					$exit_state = $exit_state_current;
					} # End if (!defined($exit_state_to_add)) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_state_to_add)');
					Debug_Process('append', 'Line ' . __LINE__ . ' Determine what the $exit_state should be');
					# Determine what the $exit_state should be
					if ($exit_state_current eq 'OK' or $exit_state_current eq 'UP') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current eq \'OK\' or $exit_state_current eq \'UP\'');
						if  ($exit_state_current eq 'UP') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current eq \'UP\'');
							$exit_state = $exit_state_current;
							} # End if  ($exit_state_current eq 'UP') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current ne \'UP\'');
							$exit_state = $exit_state_to_add;
							} # End else {
						} # End if ($exit_state_current eq 'OK' or $exit_state_current eq 'UP') {
					elsif ($exit_state_current eq 'WARNING') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current eq \'WARNING\'');
						if ($exit_state_to_add eq 'CRITICAL') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add eq \'CRITICAL\'');
							$exit_state = $exit_state_to_add;
							} # End if ($exit_state_to_add eq 'CRITICAL') {
						elsif ($exit_state_to_add eq 'UNKNOWN') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add eq \'UNKNOWN\'');
							$exit_state = $exit_state_to_add;
							} # End elsif ($exit_state_to_add eq 'UNKNOWN') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state = $exit_state_current');
							$exit_state = $exit_state_current;
							} # End else {
						} # End elsif ($exit_state_current eq 'WARNING') {
					elsif ($exit_state_current eq 'CRITICAL') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current eq \'CRITICAL\'');
						if ($exit_state_to_add eq 'UNKNOWN') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add eq \'UNKNOWN\'');
							$exit_state = $exit_state_to_add;
							} # End if ($exit_state_to_add eq 'UNKNOWN') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add ne \'UNKNOWN\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state = $exit_state_current');
							$exit_state = $exit_state_current;
							} # End else {
						} # End elsif ($exit_state_current eq 'CRITICAL') {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add ne \'OK\' OR \'WARNING\' OR \'CRITICAL\' OR \'UNKNOWN\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state = $exit_state_to_add');
						if  ($exit_state_current eq 'UP') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current eq \'UP\'');
							$exit_state = $exit_state_current;
							} # End if  ($exit_state_current eq 'UP') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_current ne \'UP\'');
							$exit_state = $exit_state_to_add;
							} # End else {
						} # End else {
					} # End else {
				} # End else {

			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
			return $exit_state;
			} # End sub Build_Exit_State {


		sub Cluster_CPU_Usage {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_CPU_Usage');
			
			$request_type = $_[0];
			$target_cluster_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get any user supplied thresholds
			my %Thresholds_User = Thresholds_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

			my %Perfdata_Options = %{$_[2]};
			my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
			
			# Get the number of CPU Cores
			my $cpu_cores_total = $target_cluster_view->get_property('summary.numCpuCores');
			Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_cores_total: \'' . $cpu_cores_total . '\'');
			
			my $cpu_cores_available = 0;
			
			# Determine what SI to use for the CPU speed
			my $si_prefix_to_return = SI_Get('CPU_Speed', 'GHz');
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return: \'' . $si_prefix_to_return . '\'');
			
			# Get the Effective CPU speed (it's in MHz)
			my $cluster_cpu_speed_effective = $target_cluster_view->get_property('summary.effectiveCpu');
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_speed_effective: \'' . $cluster_cpu_speed_effective . '\'');
				
			# Convert the Effective CPU Speed to SI
			$cluster_cpu_speed_effective = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return, $cluster_cpu_speed_effective);
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_speed_effective: \'' . $cluster_cpu_speed_effective . '\'');
			
			# Get the $cluster_cpu_usage
			my $cluster_cpu_usage = 0;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_usage: \'' . $cluster_cpu_usage . '\'');
			# Get all the hosts in the cluster
			my $cluster_hosts = $target_cluster_view->host;
			if (defined($cluster_hosts)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_hosts: \'' . $cluster_hosts . '\'');
				} # End if (defined($cluster_hosts)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_hosts: \'\'');
				} # End else {
			
			# Loop through each host
			foreach (@{$cluster_hosts}) {
				# Define the property filter for the host
				push my @target_properties, ('summary.runtime.connectionState', 'summary.quickStats', 'summary.runtime.inMaintenanceMode', 'summary.hardware.numCpuCores', 'summary.config.product.version');
				Debug_Process('append', 'Line ' . __LINE__ . ' @target_properties: \'' . @target_properties . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @target_properties values: \'' . join(", ", @target_properties) . '\'');
			
				# Get the host
				my $cluster_current_host = Vim::get_view(
					view_type	=> $_->type,
					mo_ref		=> $_,
					properties	=> [ @target_properties ]
					); # End my $cluster_current_host = Vim::get_view(
				
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_current_host: \'' . $cluster_current_host . '\'');
				
				# Get the Host Connection State
				($host_connection_state, $host_connection_state_flag, $exit_message, my $exit_state_ignored) = Host_Connection_State($cluster_current_host);
				
				# Proceed if the host is connected
				if ($host_connection_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
					# Get the host uptime
					($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($cluster_current_host);
					if ($host_uptime_state_flag == 0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
						# Proceed as the host is UP
						
						# Get the $host_maintenance_mode
						my $host_maintenance_mode = $cluster_current_host->get_property('summary.runtime.inMaintenanceMode');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode: \'' . $host_maintenance_mode . '\'');
					
						# See if the host is in maintenance mode
						if ($host_maintenance_mode eq 'false') {
							# Get the overall CPU used by the current host
							my $cluster_cpu_usage_current_host = $cluster_current_host->get_property('summary.quickStats.overallCpuUsage');
							Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_usage_current_host: \'' . $cluster_cpu_usage_current_host . '\'');
							# Convert the $cluster_cpu_usage_current_host to SI
							$cluster_cpu_usage_current_host = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return, $cluster_cpu_usage_current_host);
							Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_usage_current_host: \'' . $cluster_cpu_usage_current_host . '\'');
							
							# Add this to cluster_cpu_usage
							$cluster_cpu_usage = $cluster_cpu_usage + $cluster_cpu_usage_current_host;
							Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_usage: \'' . $cluster_cpu_usage . '\'');
							
							# Get how many cores this host has
							$cpu_cores_available = $cpu_cores_available + $cluster_current_host->get_property('summary.hardware.numCpuCores');
							Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_cores_available: \'' . $cpu_cores_available . '\'');
							} # End if ($host_maintenance_mode  eq 'false') {
						} # End if ($host_uptime_state_flag == 0) {
					} # End if ($host_connection_state_flag == 0) {
				} # End foreach (@{$cluster_hosts}) {
			
			# Calculate the $cluster_cpu_free
			my $cluster_cpu_free = $cluster_cpu_speed_effective - $cluster_cpu_usage;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_free: \'' . $cluster_cpu_free . '\'');

			$exit_message = '';

			# Determine if Cores should be reported
			if (defined($perfdata_options_selected->{'Cores'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Cores\'})');
				# Exit Message CPU Cores Total
				($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Cores Total', $cpu_cores_total);
				$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message_to_add);
				$exit_message = Build_Message($exit_message, " {Cores (Total: $cpu_cores_total)");
				
				# Exit Message CPU Cores Available
				($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Cores Available', $cpu_cores_available);
				$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
				$exit_message = Build_Message($exit_message, " (Available: $cpu_cores_available)}");
				} # End if (defined($perfdata_options_selected->{'Cores'})) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Cores\'})');
				} # End else {

			# Determine if any CPU_xxx metrics are to be reported
			if (defined($perfdata_options_selected->{'CPU_Free'}) or defined($perfdata_options_selected->{'CPU_Used'}) or defined($perfdata_options_selected->{'CPU_Effective'}) or defined($perfdata_options_selected->{'CPU_Total'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_xxx\'})');
				
				# Start the CPU exit_message section
				$exit_message = Build_Message($exit_message, ' {CPU');

				# Determine if CPU_Free should be reported
				if (defined($perfdata_options_selected->{'CPU_Free'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Free\'})');
					# Exit Message CPU Speed Free
					($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_free', 'le', $exit_state, 'CPU Free', $cluster_cpu_free, $si_prefix_to_return);
					$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
					$exit_message = Build_Message($exit_message, ' (Free: ' . Format_Number_With_Commas($cluster_cpu_free) . " " . $si_prefix_to_return . $message_to_add . ')');
					} # End if (defined($perfdata_options_selected->{'CPU_Free'})) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Free\'})');
					} # End else {

				# Determine if CPU_Used should be reported
				if (defined($perfdata_options_selected->{'CPU_Used'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Used\'})');
					# Exit Message CPU Speed Used
					($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_used', 'ge', $exit_state, 'CPU Used', $cluster_cpu_usage, $si_prefix_to_return);
					$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
					$exit_message = Build_Message($exit_message, ' (Used: ' . Format_Number_With_Commas($cluster_cpu_usage) . " $si_prefix_to_return" . $message_to_add . ')');
					} # End if (defined($perfdata_options_selected->{'CPU_Used'})) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Used\'})');
					} # End else {

				# Determine if CPU_Effective should be reported
				if (defined($perfdata_options_selected->{'CPU_Effective'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Effective\'})');
					# Exit Message CPU Speed Effective 
					($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'CPU Effective', $cluster_cpu_speed_effective, $si_prefix_to_return);
					$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
					$exit_message = Build_Message($exit_message, ' (Effective: ' . Format_Number_With_Commas($cluster_cpu_speed_effective) . " " . $si_prefix_to_return . ')');
					} # End if (defined($perfdata_options_selected->{'CPU_Effective'})) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Effective\'})');
					} # End else {

				# Determine if CPU_Total should be reported
				if (defined($perfdata_options_selected->{'CPU_Total'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Total\'})');

					# Get the Total CPU speed (it's in MHz)
					my $cluster_cpu_speed_total = $target_cluster_view->get_property('summary.totalCpu');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_speed_total: \'' . $cluster_cpu_speed_total . '\'');
					
					# Convert the Total CPU Speed to SI
					$cluster_cpu_speed_total = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return, $cluster_cpu_speed_total);
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_cpu_speed_total: \'' . $cluster_cpu_speed_total . '\'');
					
					# Exit Message CPU Speed Total
					($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'CPU Total', $cluster_cpu_speed_total, $si_prefix_to_return);
					$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
					$exit_message = Build_Message($exit_message, ' (Total: ' . Format_Number_With_Commas($cluster_cpu_speed_total) . " " . $si_prefix_to_return . ')');
					} # End if (defined($perfdata_options_selected->{'CPU_Total'})) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Total\'})');
					} # End else {

				# Finish the CPU exit_message section
				$exit_message = Build_Message($exit_message, '}');
				} # End if (defined($perfdata_options_selected->{'CPU_Free'}) or defined($perfdata_options_selected->{'CPU_Used'}) or defined($perfdata_options_selected->{'CPU_Effective'}) or defined($perfdata_options_selected->{'CPU_Total'})) {

			if ($request_type eq 'Info') {
				return Process_Request_Type($request_type, $exit_message, $perfdata_message, $exit_state);
				} # End if ($request_type eq 'Info') {
			else {
				# Exit Message With Perfdata
				$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
				return Process_Request_Type($request_type, $exit_message, $exit_state);
				} # End else {
			} # End sub Cluster_CPU_Usage {


		sub Cluster_DRS {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_DRS');
			$request_type = $_[0];
			$target_cluster_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get the DRS Config
			my $cluster_drs_config = $target_cluster_view->get_property('configurationEx')->drsConfig;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_drs_config: \'' . $cluster_drs_config . '\'');
			if ($cluster_drs_config->enabled == 1) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_drs_config->enabled == 1');
				# DRS is Enabled
				# Test the --drs_state option
				($exit_state_to_add, $message_to_add) = Test_User_Option('drs_state', 'enabled', 'CRITICAL', 'DRS: {DRS is', 'DRS: {Enabled', 'enabled');
				$cluster_drs_message = Build_Message($message_to_add, '}');
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_drs_message: \'' . $cluster_drs_message . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
				
				# Get the $cluster_status
				(my $cluster_status, $exit_state_to_add) = Cluster_Status($target_cluster_view);
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_status: \'' . $cluster_status . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add: \'' . $exit_state_to_add . '\'');
				if ($exit_state_to_add ne 'OK') {
					Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add ne \'OK\'');
					$cluster_drs_message = Build_Message($cluster_drs_message, " [$cluster_status]");
					Build_Exit_State($exit_state, $exit_state_to_add);
					} # End if ($exit_state_to_add ne 'OK') {
				

				# Need to determine if the user wants the status of --drs_automation_level to always be OK
				my $drs_automation_level_always_ok = Test_User_Option_Always_OK('drs_automation_level');

				# Get the Automation Level and test the --drs_automation_level option
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_drs_config->defaultVmBehavior->val: \'' . $cluster_drs_config->defaultVmBehavior->val . '\'');
				switch ($cluster_drs_config->defaultVmBehavior->val) {
					case 'manual' { 
						if ($drs_automation_level_always_ok == 1) {
							$exit_state_to_add = 'OK';
							$message_to_add = 'Automation Level: Manual';
							} # End if ($drs_automation_level_always_ok == 1) {
						else {
							($exit_state_to_add, $message_to_add) = Test_User_Option('drs_automation_level', 'manual', 'CRITICAL', 'Automation Level is', 'Automation Level: Manual', 'fullyAutomated');
							} # End else {
						} # End case 'manual' { 
					
					case 'partiallyAutomated' {
						if ($drs_automation_level_always_ok == 1) {
							$exit_state_to_add = 'OK';
							$message_to_add = 'Automation Level: Partially Automated';
							} # End if ($drs_automation_level_always_ok == 1) {
						else {
							($exit_state_to_add, $message_to_add) = Test_User_Option('drs_automation_level', 'partiallyAutomated', 'CRITICAL', 'Automation Level is', 'Automation Level: Partially Automated', 'fullyAutomated');
							} # End else {
						} # End case 'partiallyAutomated' { 
					
					case 'fullyAutomated' {
						if ($drs_automation_level_always_ok == 1) {
							$exit_state_to_add = 'OK';
							$message_to_add = 'Automation Level: Fully Automated';
							} # End if ($drs_automation_level_always_ok == 1) {
						else {
							($exit_state_to_add, $message_to_add) = Test_User_Option('drs_automation_level', 'fullyAutomated', 'CRITICAL', 'Automation Level is', 'Automation Level: Fully Automated', 'fullyAutomated');
							} # End else {
						} # End case 'fullyAutomated' { 
					} # End switch ($cluster_drs_config->defaultVmBehavior) {
				$cluster_drs_message = Build_Message($cluster_drs_message, " {$message_to_add}");
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				
				# Get the Migration Threshold
				$cluster_drs_message = Build_Message($cluster_drs_message, ' {Migration Threshold: ' . $cluster_drs_config->vmotionRate . '}');
				Debug_Process('append', 'Line ' . __LINE__ . ' Migration Threshold: ' . $cluster_drs_config->vmotionRate . '\'');
				
				# Need to determine if the user wants the status of --drs_dpm_level to always be OK
				my $drs_dpm_level_always_ok = Test_User_Option_Always_OK('drs_dpm_level');

				# Get the Power Management Level and test the --drs_dpm_level option
				my $cluster_dpm_config = $target_cluster_view->get_property('configurationEx')->dpmConfigInfo;
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_dpm_config: \'' . $cluster_dpm_config . '\'');
				if ($cluster_dpm_config->enabled == 1) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_dpm_config->enabled == 1');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_dpm_config->defaultDpmBehavior->val: \'' . $cluster_dpm_config->defaultDpmBehavior->val . '\'');
					switch ($cluster_dpm_config->defaultDpmBehavior->val) {
						case 'manual' {
							if ($drs_dpm_level_always_ok == 1) {
								$exit_state_to_add = 'OK';
								$message_to_add = '{DPM: Manual';
								} # End if ($drs_dpm_level_always_ok == 1) {
							else {
								($exit_state_to_add, $message_to_add) = Test_User_Option('drs_dpm_level', 'manual', 'CRITICAL', '{DPM is', '{DPM: Manual', 'off');
								} # End else {
							} # End case 'manual' { 
						
						case 'automated' {
							if ($drs_dpm_level_always_ok == 1) {
								$exit_state_to_add = 'OK';
								$message_to_add = '{DPM: Automated';
								} # End if ($drs_dpm_level_always_ok == 1) {
							else {
								($exit_state_to_add, $message_to_add) = Test_User_Option('drs_dpm_level', 'automated', 'CRITICAL', '{DPM is', '{DPM: Automated', 'off');
								} # End else {
							} # End case 'automated' { 
						} # End switch ($cluster_drs_config->defaultVmBehavior) {
					Debug_Process('append', 'Line ' . __LINE__ . ' Threshold: ' . $cluster_dpm_config->hostPowerActionRate . '\'');
					$cluster_drs_message = Build_Message($cluster_drs_message, " $message_to_add, Threshold: " . $cluster_dpm_config->hostPowerActionRate . '}');
					} # End if ($cluster_dpm_config->enabled == 1) {
				else {
					if ($drs_dpm_level_always_ok == 1) {
						$exit_state_to_add = 'OK';
						$message_to_add = '{DPM: Off';
						} # End if ($drs_dpm_level_always_ok == 1) {
					else {
						($exit_state_to_add, $message_to_add) = Test_User_Option('drs_dpm_level', 'off', 'CRITICAL', '{DPM is', '{DPM: Off', 'off');
						} # End else {
					$cluster_drs_message = Build_Message($cluster_drs_message, " $message_to_add}");
					} # End else {
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				} # End if ($cluster_drs_config->enabled == 1) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' DRS is disabled');
				# DRS is disabled
				# Test the --drs_state option
				($exit_state_to_add, $message_to_add) = Test_User_Option('drs_state', 'disabled', 'CRITICAL', '{DRS: DRS is', 'DRS: {Disabled', 'enabled');
				$cluster_drs_message = Build_Message($message_to_add, '}');
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				} # End else {
			
			return Process_Request_Type($request_type, $cluster_drs_message, $exit_state);
			} # End sub Cluster_DRS {


		sub Cluster_EVC {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_EVC');
			$request_type = $_[0];
			$target_cluster_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get the Enhanced vMotion Compatibility Mode (if unset the mode is not active)
			my $cluster_evc_mode;
			my $cluster_evc_mode_value;
			my $evc_message_to_return;
			if (!defined($target_cluster_view->get_property('summary')->currentEVCModeKey)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' !defined($target_cluster_view->get_property(\'summary\')->currentEVCModeKey)');
				Debug_Process('append', 'Line ' . __LINE__ . ' EVC Mode Disabled');
				# It's disabled
				$cluster_evc_mode = 'disabled';
				$cluster_evc_mode_value = '';
				} # End if (!defined($target_cluster_view->summary->currentEVCModeKey)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' EVC Mode Enabled');
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view->get_property(\'summary\')->currentEVCModeKey: \'' . $target_cluster_view->get_property('summary')->currentEVCModeKey . '\'');
				# It's enabled
				$cluster_evc_mode = 'enabled';
				$cluster_evc_mode_value = ' (' . $target_cluster_view->get_property('summary')->currentEVCModeKey . ')';
				} # End else {
			
			my $user_option_test_value;
			if (Opts::option_is_set('evc_mode')) {
				($exit_state_to_return, $evc_message_to_return) = Test_User_Option('evc_mode', $cluster_evc_mode, 'CRITICAL', 'EVC is', 'EVC: ' . $cluster_evc_mode . $cluster_evc_mode_value, 'no_default');
				} # End if (Opts::option_is_set('evc_mode')) {
			else {
				$exit_state_to_return = 'OK';
				$evc_message_to_return = 'EVC: ' . $cluster_evc_mode . $cluster_evc_mode_value;			
				} # End else {
			
			return Process_Request_Type($request_type, $evc_message_to_return, $exit_state_to_return);
			} # End sub Cluster_EVC {


		sub Cluster_HA {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_HA');
			$request_type = $_[0];
			$target_cluster_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get the HA Config
			my $cluster_ha_config = $target_cluster_view->get_property('configurationEx')->dasConfig;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config: \'' . $cluster_ha_config . '\'');
			if ($cluster_ha_config->enabled == 1) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->enabled == 1');
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->enabled: \'' . $cluster_ha_config->enabled . '\'');
				# HA is enabled
				# Test the --ha_state option
				($exit_state_to_add, $message_to_add) = Test_User_Option('ha_state', 'enabled', 'CRITICAL', '{HA: HA is', 'HA: {Enabled', 'enabled');
				$cluster_ha_message = Build_Message($message_to_add, '}');
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				
				# Get the $cluster_status
				(my $cluster_status, $exit_state_to_add) = Cluster_Status($target_cluster_view);
				if ($exit_state_to_add ne 'OK') {
					$cluster_ha_message = Build_Message($cluster_ha_message, " [$cluster_status]");
					Build_Exit_State($exit_state, $exit_state_to_add);
					} # End if ($exit_state_to_add ne 'OK') {
				
				# Need to determine if the user wants the status of --ha_host_monitoring to always be OK
				my $ha_host_monitoring_always_ok = Test_User_Option_Always_OK('ha_host_monitoring');

				# Determine Host Monitoring
				if ($cluster_ha_config->hostMonitoring eq 'enabled') {
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->hostMonitoring eq \'enabled\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->hostMonitoring: \'' . $cluster_ha_config->hostMonitoring . '\'');
					# Test the --ha_host_monitoring option
					if ($ha_host_monitoring_always_ok == 1) {
						$exit_state_to_add = 'OK';
						$message_to_add = '{Host Monitoring: Enabled';
						} # End if ($ha_host_monitoring_always_ok == 1) {
					else {
						($exit_state_to_add, $message_to_add) = Test_User_Option('ha_host_monitoring', 'enabled', 'CRITICAL', '{Host Monitoring is', '{Host Monitoring: Enabled', 'enabled');
						} # End else {
					} # End if ($cluster_ha_config->hostMonitoring eq 'enabled') {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->hostMonitoring NOT enabled');
					# Test the --ha_host_monitoring option
					if ($ha_host_monitoring_always_ok == 1) {
						$exit_state_to_add = 'OK';
						$message_to_add = '{Host Monitoring: Disabled';
						} # End if ($ha_host_monitoring_always_ok == 1) {
					else {
						($exit_state_to_add, $message_to_add) = Test_User_Option('ha_host_monitoring', 'disabled', 'CRITICAL', '{Host Monitoring is', '{Host Monitoring: Disabled', 'enabled');
						} # End else {
					} # End else {
				$cluster_ha_message = Build_Message($cluster_ha_message, " $message_to_add}");
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				
				# Need to determine if the user wants the status of --ha_admission_control to always be OK
				my $ha_admission_control_always_ok = Test_User_Option_Always_OK('ha_admission_control');

				# Determine Admission Control
				if ($cluster_ha_config->admissionControlEnabled == 1) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->admissionControlEnabled == 1');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->admissionControlEnabled: \'' . $cluster_ha_config->admissionControlEnabled . '\'');
					# It's enabled
					# Test the --ha_admission_control option
					if ($ha_admission_control_always_ok == 1) {
						$exit_state_to_add = 'OK';
						$message_to_add = '{Admission Control: Enabled';
						} # End if ($ha_admission_control_always_ok == 1) {
					else {
						($exit_state_to_add, $message_to_add) = Test_User_Option('ha_admission_control', 'enabled', 'CRITICAL', '{Admission Control is', '{Admission Control: Enabled', 'enabled');
						} # End else {
					
					# Find out all the options
					$message_to_add = Build_Message($message_to_add, ', Policy:');
					my $cluster_ha_config_admission_control_policy = $cluster_ha_config->admissionControlPolicy;
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy: \'' . $cluster_ha_config_admission_control_policy . '\'');
					my $cluster_ha_config_admission_control_policy_resource_flag = 0;
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_resource_flag: \'' . $cluster_ha_config_admission_control_policy_resource_flag . '\'');
					# We need to loop through the hash table
					foreach my $cluster_ha_config_admission_control_policy_key (keys %$cluster_ha_config_admission_control_policy) {
						my $cluster_ha_config_admission_control_policy_text;
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_key: \'' . $cluster_ha_config_admission_control_policy_key . '\'');
						switch ($cluster_ha_config_admission_control_policy_key) {
							case 'failoverLevel' {
								Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy->failoverLevel: \'' . $cluster_ha_config_admission_control_policy->failoverLevel . '\'');
								# This is about the number of hosts
								$cluster_ha_config_admission_control_policy_text = 'Tolerates ';
								if ($cluster_ha_config_admission_control_policy->failoverLevel > 1) {
									$cluster_ha_config_admission_control_policy_text = Build_Message($cluster_ha_config_admission_control_policy_text, $cluster_ha_config_admission_control_policy->failoverLevel . ' Hosts Failing');
									} # End if ($cluster_ha_config_admission_control_policy->failoverLevel > 1) {
								else {
									$cluster_ha_config_admission_control_policy_text = Build_Message($cluster_ha_config_admission_control_policy_text, $cluster_ha_config_admission_control_policy->failoverLevel . ' Host Failure');
									} # End else {
								} # End case 'failoverLevel' {


							case 'slotPolicy' {
								Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy->slotPolicy: \'' . $cluster_ha_config_admission_control_policy->slotPolicy . '\'');
								# This relates to the failoverLevel ... user has defined a fixed slot size
								Debug_Process('append', 'Line ' . __LINE__ . ' Not doing anything in this case {} ... simply here to avoid errors');
								} # End case 'slotPolicy' {
								

							case 'failoverHosts' {
								Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy->failoverHosts: \'' . $cluster_ha_config_admission_control_policy->failoverHosts . '\'');
								# This is about specific hosts
								# Lets loop through all the hosts
								my $cluster_ha_config_admission_control_policy_host_counter = 0;
								Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_host_counter: \'' . $cluster_ha_config_admission_control_policy_host_counter . '\'');
								my $cluster_ha_config_admission_control_policy_host_list;
								foreach (@{$cluster_ha_config_admission_control_policy->failoverHosts}) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
									my $cluster_ha_config_admission_control_policy_host = Vim::get_view(
										view_type => $_->type,
										mo_ref => $_
										); # End my $cluster_ha_config_admission_control_policy_host = Vim::get_view(
									Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_host->name: \'' . $cluster_ha_config_admission_control_policy_host->name . '\'');
									$cluster_ha_config_admission_control_policy_host_list = Build_Message($cluster_ha_config_admission_control_policy_host_list, $cluster_ha_config_admission_control_policy_host->name, ', ');
									$cluster_ha_config_admission_control_policy_host_counter++;
									} # End foreach (@{$cluster_ha_config_admission_control_policy->failoverHosts}) {
								# Now lets update $cluster_ha_config_admission_control_policy_text
								$cluster_ha_config_admission_control_policy_text = 'Specified Failover';
								Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_host_counter: \'' . $cluster_ha_config_admission_control_policy_host_counter . '\'');
								if ($cluster_ha_config_admission_control_policy_host_counter > 1) {
									$cluster_ha_config_admission_control_policy_text = Build_Message($cluster_ha_config_admission_control_policy_text, " Hosts: $cluster_ha_config_admission_control_policy_host_list");
									} # End if ($cluster_ha_config_admission_control_policy_host_counter > 1) {
								else {
									$cluster_ha_config_admission_control_policy_text = Build_Message($cluster_ha_config_admission_control_policy_text, " Host: $cluster_ha_config_admission_control_policy_host_list");
									} # End else {
								} # End case 'failoverHosts' {
							

							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_resource_flag: \'' . $cluster_ha_config_admission_control_policy_resource_flag . '\'');
								# This is about reserving a % of cluster resources
								if ($cluster_ha_config_admission_control_policy_resource_flag == 0) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_resource_flag == 0');

									my $cluster_ha_config_admission_control_policy_cpuFailoverResourcesPercent;
									if(defined($cluster_ha_config_admission_control_policy->cpuFailoverResourcesPercent)) {
										$cluster_ha_config_admission_control_policy_cpuFailoverResourcesPercent = $cluster_ha_config_admission_control_policy->cpuFailoverResourcesPercent;
										} # End if(defined($cluster_ha_config_admission_control_policy->cpuFailoverResourcesPercent)) {
									else {
										$cluster_ha_config_admission_control_policy_cpuFailoverResourcesPercent = 'Unknown ';
										} # End else {
									Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_cpuFailoverResourcesPercent: \'' . $cluster_ha_config_admission_control_policy_cpuFailoverResourcesPercent . '\'');

									my $cluster_ha_config_admission_control_policy_memoryFailoverResourcesPercent;
									if(defined($cluster_ha_config_admission_control_policy->memoryFailoverResourcesPercent)) {
										$cluster_ha_config_admission_control_policy_memoryFailoverResourcesPercent = $cluster_ha_config_admission_control_policy->memoryFailoverResourcesPercent;
										} # End if(defined($cluster_ha_config_admission_control_policy->memoryFailoverResourcesPercent)) {
									else {
										$cluster_ha_config_admission_control_policy_memoryFailoverResourcesPercent = 'Unknown ';
										} # End else {
									Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config_admission_control_policy_memoryFailoverResourcesPercent: \'' . $cluster_ha_config_admission_control_policy_memoryFailoverResourcesPercent . '\'');

									$cluster_ha_config_admission_control_policy_text = "Reserved Capacity CPU: " . $cluster_ha_config_admission_control_policy_cpuFailoverResourcesPercent . "%, Memory: " . $cluster_ha_config_admission_control_policy_memoryFailoverResourcesPercent . "%";
									$cluster_ha_config_admission_control_policy_resource_flag = 1;
									} # End if ($cluster_ha_config_admission_control_policy_resource_flag == 0) {
								} # End else {
							} # End switch ($cluster_ha_config_admission_control_policy_key) {
						if (defined($cluster_ha_config_admission_control_policy_text)) {
							$message_to_add = Build_Message($message_to_add, " $cluster_ha_config_admission_control_policy_text");	
							} # End if (defined($cluster_ha_config_admission_control_policy_text)) {
						} # End foreach my $cluster_ha_config_admission_control_policy_key (keys %$cluster_ha_config_admission_control_policy) {
					$message_to_add = Build_Message($message_to_add, '}');
					} # End if ($cluster_ha_config->admissionControlEnabled == 1) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' Admission Control is disabled');
					# Admission Control is disabled
					# Test the --ha_admission_control option
					if ($ha_admission_control_always_ok == 1) {
						$exit_state_to_add = 'OK';
						$message_to_add = '{Admission Control: Disabled';
						} # End if ($ha_admission_control_always_ok == 1) {
					else {
						($exit_state_to_add, $message_to_add) = Test_User_Option('ha_admission_control', 'disabled', 'CRITICAL', '{Admission Control is', '{Admission Control: Disabled', 'enabled');
						} # End else {
					$message_to_add = Build_Message($message_to_add, '}');
					} # End else {
				$cluster_ha_message = Build_Message($cluster_ha_message, " $message_to_add");
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				
				# Determine VM Options
				$cluster_ha_message = Build_Message($cluster_ha_message, ' {VM Options: Restart Priority:');
				Debug_Process('append', 'Line ' . __LINE__ . ' VM Options:');
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->defaultVmSettings->restartPriority: \'' . $cluster_ha_config->defaultVmSettings->restartPriority . '\'');
				switch ($cluster_ha_config->defaultVmSettings->restartPriority) {
					case 'disabled' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' Disabled,');
						} # End case 'disabled' { 
					
					case 'low' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' Low,');
						} # End case 'low' { 
					
					case 'medium' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' Medium,');
						} # End case 'medium' { 
					
					case 'high' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' High,');
						} # End case 'high' { 
					} # End switch ($cluster_ha_config->defaultVmSettings->restartPriority) {
				
				$cluster_ha_message = Build_Message($cluster_ha_message, ' Isolation Response:');
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->defaultVmSettings->isolationResponse: \'' . $cluster_ha_config->defaultVmSettings->isolationResponse . '\'');
				switch ($cluster_ha_config->defaultVmSettings->isolationResponse) {
					case 'none' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' Leave Powered On}');
						} # End case 'none' { 
					
					case 'powerOff' { 
						$cluster_ha_message =Build_Message($cluster_ha_message, ' Power Off}');
						} # End case 'powerOff' { 
					
					case 'shutdown' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' Shutdown}');
						} # End case 'shutdown' { 
					} # End switch ($cluster_ha_config->defaultVmSettings->isolationResponse) {
				
				# Determine VM Monitoring
				$cluster_ha_message = Build_Message($cluster_ha_message, ' {VM Monitoring:');
				Debug_Process('append', 'Line ' . __LINE__ . ' VM Monitoring:');
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_ha_config->vmMonitoring: \'' . $cluster_ha_config->vmMonitoring . '\'');
				switch ($cluster_ha_config->vmMonitoring) {
					case 'vmMonitoringDisabled' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' Disabled}');
						} # End case 'vmMonitoringDisabled' { 
					
					case 'vmMonitoringOnly' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' VM Only}');
						} # End case 'vmMonitoringOnly' { 
					
					case 'vmAndAppMonitoring' { 
						$cluster_ha_message = Build_Message($cluster_ha_message, ' VM and Application}');
						} # End case 'vmAndAppMonitoring' { 
					} # End switch ($cluster_ha_config->vmMonitoring) {
				
				} # End if ($cluster_ha_config->enabled == 1) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' HA is disabled:');
				# HA is disabled
				# Test the --ha_state option
				($exit_state_to_add, $message_to_add) = Test_User_Option('ha_state', 'disabled', 'CRITICAL', '{HA: HA is', 'HA: {Disabled', 'enabled');
				$cluster_ha_message = Build_Message($message_to_add, '}');
				$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
				} # End else {
			
			return Process_Request_Type($request_type, $cluster_ha_message, $exit_state);
			} # End sub Cluster_HA {


		sub Cluster_Issues {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Issues');
			$target_cluster_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			my $cluster_issues;
			my $exclude_flag;
			
			# Get cluster configIssue
			my $cluster_configIssue = $target_cluster_view->configIssue;
			if (defined($cluster_configIssue)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_configIssue: \'' . $cluster_configIssue . '\'');
				} # End if (defined($cluster_configIssue)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_configIssue: \'\'');
				} # End else {
			
			# Get any exclude_issue arguments
			my @exclude_issue;
			if (Opts::option_is_set('exclude_issue')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Option --exclude_issue supplied');
				Debug_Process('append', 'Line ' . __LINE__ . ' values: \'' . Opts::get_option('exclude_issue') . '\'');
				# Put the options into an array
				@exclude_issue = split(/,/, Opts::get_option('exclude_issue'));
				} # End if (Opts::option_is_set('exclude_issue')) {
			
			# Loop through the issues
			foreach (@$cluster_configIssue) {
				Debug_Process('append', 'Line ' . __LINE__ . ' ref($_): \'' . ref($_) . '\'');
				$exclude_flag = 0;
				Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag: \'' . $exclude_flag . '\'');
				# Loop through the exclude options
				foreach my $exclude (@exclude_issue) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $exclude: \'' . $exclude . '\'');
					# If one of the exclude items matches our config issue then trigger the $exclude_flag
					if (ref($_) eq $exclude) {
						Debug_Process('append', 'Line ' . __LINE__ . ' ref($_) eq $exclude');
						$exclude_flag = 1;
						Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag: \'' . $exclude_flag . '\'');
						} # End if (ref($_) eq $exclude) {
					elsif (ref($_) eq 'EventEx')  {
						Debug_Process('append', 'Line ' . __LINE__ . ' ref($_) eq \'EventEx\'');
						if ($_->eventTypeId =~ m/$exclude/) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $_->eventTypeId =~ m/$exclude/');
							$exclude_flag = 1;
							Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag: \'' . $exclude_flag . '\'');
							} # End if ($_->eventTypeId =~ m/$exclude/) {
						} # End elsif (ref($_) eq 'EventEx')  {
					} # End foreach my $exclude (@exclude_issue) {
				
				# Only continue if our config issue is NOT an exclude item
				if ($exclude_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag == 0');
					# Identify and report the issue
					switch (ref($_)) {
						case 'EventEx' {
							switch ($_->eventTypeId) {
								case m/DasFailoverHostUnreachableEvent/ {
									$cluster_issues = Build_Message($cluster_issues, 'HA Agent on Host(s) is Unreachable', ', ');
									} # End case m/DasFailoverHostUnreachableEvent/ {
							
								else {
									$cluster_issues = Build_Message($cluster_issues, 'Unknown configIssue ' . $_->eventTypeId, ', ');
									} # End else {
								} # End switch ($_->eventTypeId) {
							} # End case 'EventEx' {
						
						case 'ClusterOvercommittedEvent' {
							$cluster_issues = Build_Message($cluster_issues, 'Insufficient Capacity', ', ');
							} # End case 'ClusterOvercommittedEvent' {
						
						case 'DasClusterIsolatedEvent' {
							$cluster_issues = Build_Message($cluster_issues, 'All HA Hosts Isolated From Network', ', ');
							} # End case 'DasClusterIsolatedEvent' {
						
						case 'DasHostFailedEvent' {
							$cluster_issues = Build_Message($cluster_issues, 'Host Failure', ', ');
							} # End case 'DasHostFailedEvent' {
						
						case 'DasHostIsolatedEvent' {
							$cluster_issues = Build_Message($cluster_issues, 'A HA Host Is Isolated From Network', ', ');
							} # End case 'DasHostIsolatedEvent' {
						
						case 'InsufficientFailoverResourcesEvent' {
							$cluster_issues = Build_Message($cluster_issues, 'Insufficient Resources To Satisfy HA Failover', ', ');
							} # End case 'InsufficientFailoverResourcesEvent' {
						
						else {
							$cluster_issues = Build_Message($cluster_issues, 'Unknown configIssue ' . ref($_), ', ');
							} # End else {
						} # End switch (ref($_)) {
					} # End if ($exclude_flag == 0) {
				} # End foreach (@$cluster_configIssue) {
			
			return $cluster_issues;
			} # End sub Cluster_Issues {


		sub Cluster_Memory_Usage {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Memory_Usage');
			$request_type = $_[0];
			$target_cluster_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get any user supplied thresholds
			my %Thresholds_User = Thresholds_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

			my %Perfdata_Options = %{$_[2]};
			my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
			
			# Determine what SI to use for the Memory_Size
			my $si_prefix_to_return = SI_Get('Memory_Size', 'GB');
			
			# Get the Effective memory in the cluster (it's in MB)
			my $cluster_memory_effective = $target_cluster_view->get_property('summary.effectiveMemory');
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_effective: \'' . $cluster_memory_effective . '\'');
			
			# Convert the $cluster_memory_effective to SI
			$cluster_memory_effective = SI_Process('Memory_Size', 'MB', $si_prefix_to_return, $cluster_memory_effective);
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_effective: \'' . $cluster_memory_effective . '\'');
			
			# Get the $cluster_memory_usage
			my $cluster_memory_usage = 0;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_usage: \'' . $cluster_memory_usage . '\'');
			
			# Get all the hosts in the cluster
			my $cluster_hosts = $target_cluster_view->host;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_hosts: \'' . $cluster_hosts . '\'');
			
			# Loop through each host
			foreach (@{$cluster_hosts}) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
			
				# Define the property filter for the host
				push my @target_properties, ('summary.runtime.connectionState', 'summary.quickStats', 'summary.runtime.inMaintenanceMode', 'summary.config.product.version');
				Debug_Process('append', 'Line ' . __LINE__ . ' host @target_properties: \'' . @target_properties . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' host @target_properties values: \'' . join(", ", @target_properties) . '\'');
			
				# Get the host
				my $cluster_current_host = Vim::get_view(
					view_type	=> $_->type,
					mo_ref 		=> $_,
					properties	=> [ @target_properties ]
					); # End my $cluster_current_host = Vim::get_view(

				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_current_host: \'' . $cluster_current_host . '\'');

				# Get the Host Connection State
				($host_connection_state, $host_connection_state_flag, $exit_message, my $exit_state_ignored) = Host_Connection_State($cluster_current_host);
				
				# Proceed if the host is connected
				if ($host_connection_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
					# Get the host uptime
					($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($cluster_current_host);
					if ($host_uptime_state_flag == 0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
						# Proceed as the host is UP
						
						# Get the $host_maintenance_mode
						my $host_maintenance_mode = $cluster_current_host->get_property('summary.runtime.inMaintenanceMode');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode: \'' . $host_maintenance_mode . '\'');
				
						# See if the host is in maintenance mode
						if ($host_maintenance_mode eq 'false') {
							# Get the overall memory used by the current host
							my $cluster_memory_usage_current_host = $cluster_current_host->get_property('summary.quickStats.overallMemoryUsage');
							Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_usage_current_host: \'' . $cluster_memory_usage_current_host . '\'');
							# Convert the $cluster_memory_usage_current_host to SI
							$cluster_memory_usage_current_host = SI_Process('Memory_Size', 'MB', $si_prefix_to_return, $cluster_memory_usage_current_host);
							Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_usage_current_host: \'' . $cluster_memory_usage_current_host . '\'');
							
							# Add this to cluster_memory_usage
							$cluster_memory_usage = $cluster_memory_usage + $cluster_memory_usage_current_host;
							Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_usage: \'' . $cluster_memory_usage . '\'');
							} # End if ($host_maintenance_mode eq 'false') {
						} # End if ($host_uptime_state_flag == 0) {
					} # End if ($host_connection_state_flag == 0) {
				} # End foreach (@{$cluster_hosts}) {
			
			# Calculate the $cluster_memory_free
			my $cluster_memory_free = $cluster_memory_effective - $cluster_memory_usage;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_free: \'' . $cluster_memory_free . '\'');

			# Start the exit_message
			$exit_message = ' Memory';

			# Determine if Memory_Free should be reported
			if (defined($perfdata_options_selected->{'Memory_Free'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Free\'})');
				# Exit Message Memory Free
				($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_free', 'le', $exit_state, 'Memory Free', $cluster_memory_free, $si_prefix_to_return);
				$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message_to_add);
				$exit_message = Build_Message($exit_message, ' {Free: ' . Format_Number_With_Commas($cluster_memory_free) . " $si_prefix_to_return" . $message_to_add . '}');
				} # End if (defined($perfdata_options_selected->{'Memory_Free'})) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Free\'})');
				} # End else {

			# Determine if Memory_Used should be reported
			if (defined($perfdata_options_selected->{'Memory_Used'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Used\'})');
				# Exit Message Memory Used
				($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_used', 'ge', $exit_state, 'Memory Used', $cluster_memory_usage, $si_prefix_to_return);
				$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
				$exit_message = Build_Message($exit_message, ' {Used: ' . Format_Number_With_Commas($cluster_memory_usage) . " $si_prefix_to_return" . $message_to_add . '}');
				} # End if (defined($perfdata_options_selected->{'Memory_Used'})) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Used\'})');
				} # End else {

			# Determine if Memory_Effective should be reported
			if (defined($perfdata_options_selected->{'Memory_Effective'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Effective\'})');
				# Exit Message Memory Effective
				($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Effective', $cluster_memory_effective, $si_prefix_to_return);
				$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
				$exit_message = Build_Message($exit_message, ' {Effective: ' . Format_Number_With_Commas($cluster_memory_effective) . " $si_prefix_to_return}");
				} # End if (defined($perfdata_options_selected->{'Memory_Effective'})) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Effective\'})');
				} # End else {

			# Determine if Memory_Total should be reported
			if (defined($perfdata_options_selected->{'Memory_Total'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Total\'})');

				# Get the total memory in the cluster (it's in MB)
				my $cluster_memory_total = $target_cluster_view->get_property('summary.totalMemory');
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_total: \'' . $cluster_memory_total . '\'');
				
				# Convert the $cluster_memory_total to SI
				$cluster_memory_total = SI_Process('Memory_Size', 'B', $si_prefix_to_return, $cluster_memory_total);
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_memory_total: \'' . $cluster_memory_total . '\'');

				# Exit Message Memory Total
				($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Total', $cluster_memory_total, $si_prefix_to_return);
				$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
				$exit_message = Build_Message($exit_message, ' {Total: ' . Format_Number_With_Commas($cluster_memory_total) . " $si_prefix_to_return}");
				} # End if (defined($perfdata_options_selected->{'Memory_Total'})) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Total\'})');
				} # End else {
			
			if ($request_type eq 'Info') {
				return Process_Request_Type($request_type, $exit_message, $perfdata_message, $exit_state);
				} # End if ($request_type eq 'Info') {
			else {
				# Exit Message With Perfdata
				$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
				return Process_Request_Type($request_type, $exit_message, $exit_state);
				} # End else {
			} # End sub Cluster_Memory_Usage {


		sub Cluster_Resource_Info {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Resource_Info');
			$target_cluster_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get any user supplied thresholds
			my %Thresholds_User = Thresholds_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

			my %Perfdata_Options = %{$_[1]};
			my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
						
			my $cluster_perfdata_message;
			my $cluster_perfdata_message_to_add;
			
			# Get the cluster name
			my $cluster_name = Opts::get_option('cluster');
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');

			# Start the exit_message_cluster
			my $exit_message_cluster = "'$cluster_name'";

			# Determine if Hosts_xxx should be reported
			if (defined($perfdata_options_selected->{'Hosts_Available'}) or defined($perfdata_options_selected->{'Hosts_Total'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Hosts_xxx\'})');

				# Start the Hosts exit_message_cluster
				$exit_message_cluster = Build_Message($exit_message_cluster, ' [Hosts');

				# Determine if Hosts_Total should be reported
				if (defined($perfdata_options_selected->{'Hosts_Total'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Hosts_Total\'})');
					# Get the total number of hosts
					my $cluster_hosts_total = $target_cluster_view->get_property('summary.numHosts');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_hosts_total: \'' . $cluster_hosts_total . '\'');
					($cluster_perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Hosts Total', $cluster_hosts_total);
					$cluster_perfdata_message = Build_Perfdata_Message('Build', $cluster_perfdata_message_to_add);
					$exit_message_cluster = Build_Message($exit_message_cluster, " {Total: $cluster_hosts_total}");
					} # End if (defined($perfdata_options_selected->{'Hosts_Total'})) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Hosts_Total\'})');
					} # End else {

				# Determine if Hosts_Available should be reported
				if (defined($perfdata_options_selected->{'Hosts_Available'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Hosts_Available\'})');
					# Get the available number of hosts
					my $cluster_hosts_available = $target_cluster_view->get_property('summary.numEffectiveHosts');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_hosts_available: \'' . $cluster_hosts_available . '\'');
					($cluster_perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Hosts Available', $cluster_hosts_available);
					$cluster_perfdata_message = Build_Perfdata_Message('Build', $cluster_perfdata_message, $cluster_perfdata_message_to_add);
					$exit_message_cluster = Build_Message($exit_message_cluster, " {Available: $cluster_hosts_available}");
					} # End if (defined($perfdata_options_selected->{'Hosts_Available'})) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Hosts_Available\'})');
					} # End else {
				
				# Finish the Hosts exit_message_cluster
				$exit_message_cluster = Build_Message($exit_message_cluster, '] ');
				} # End if (defined($perfdata_options_selected->{'Hosts_Available'}) or defined($perfdata_options_selected->{'Hosts_Total'})) {
				
			
			# Determine if Cores or CPU_xxx should be reported
			if (defined($perfdata_options_selected->{'Cores'}) or defined($perfdata_options_selected->{'CPU_Free'}) or defined($perfdata_options_selected->{'CPU_Used'}) or defined($perfdata_options_selected->{'CPU_Effective'}) or defined($perfdata_options_selected->{'CPU_Total'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Cores\'}) or defined($perfdata_options_selected->{\'CPU_xxx\'})');
				# Get the CPU Info
				(my $cluster_cpu_message, my $cluster_cpu_perfdata_message, $exit_state) = Cluster_CPU_Usage('Info', $target_cluster_view, \%Perfdata_Options);
				$cluster_perfdata_message = Build_Perfdata_Message('Build', $cluster_perfdata_message, $cluster_cpu_perfdata_message);
				$cluster_cpu_message =~ s/^\s+//;
				$exit_message_cluster =~ s/\s+$//;
				$exit_message_cluster = Build_Message($exit_message_cluster, " [$cluster_cpu_message]");
				} # End if (defined($perfdata_options_selected->{'Cores'}) or defined($perfdata_options_selected->{'CPU_Free'}) or defined($perfdata_options_selected->{'CPU_Used'}) or defined($perfdata_options_selected->{'CPU_Effective'}) or defined($perfdata_options_selected->{'CPU_Total'})) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Cores\'}) or defined($perfdata_options_selected->{\'CPU_xxx\'})');
				} # End else {
				
			# Determine if Memory_xxx should be reported
			if (defined($perfdata_options_selected->{'Memory_Free'}) or defined($perfdata_options_selected->{'Memory_Used'}) or defined($perfdata_options_selected->{'Memory_Effective'}) or defined($perfdata_options_selected->{'Memory_Total'})) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_xxx\'})');
				# Get the Memory Info
				(my $cluster_memory_message, my $cluster_memory_perfdata_message, $exit_state) = Cluster_Memory_Usage('Info', $target_cluster_view, \%Perfdata_Options);
				$cluster_perfdata_message = Build_Perfdata_Message('Build', $cluster_perfdata_message, $cluster_memory_perfdata_message);
				$cluster_memory_message =~ s/^\s+//;
				$exit_message_cluster =~ s/\s+$//;
				$exit_message_cluster = Build_Message($exit_message_cluster, " [$cluster_memory_message]");
				} # End if (defined($perfdata_options_selected->{'Memory_Free'}) or defined($perfdata_options_selected->{'Memory_Used'}) or defined($perfdata_options_selected->{'Memory_Effective'}) or defined($perfdata_options_selected->{'Memory_Total'})) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_xxx\'})');
				} # End else {

			# Exit Message With Perfdata
			$exit_message_cluster =~ s/\s+$//;
			$exit_message_cluster = Build_Exit_Message('Perfdata', $exit_message_cluster, $cluster_perfdata_message);
			
			return ($exit_message_cluster, $exit_state);
			} # End sub Cluster_Resource_Info {


		sub Cluster_Select {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Select');
			$exit_state_abort = 'OK';
			
			# Get the property filter
			my @target_properties = @{$_[0]};
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Select @target_properties: \'' . @target_properties . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Select @target_properties values: \'' . join(", ", @target_properties) . '\'');
			
			my $cluster_name;
			# Need to make sure the --cluster argument has been provided
			if (!Opts::option_is_set('cluster')) {
				# The --cluster argument was not provided, abort
				$exit_message_abort = "The --cluster argument was not provided for the Cluster you want to monitor, aborting!";
				$exit_state_abort = 'UNKNOWN';
				} # End if (!Opts::option_is_set('cluster')) {
			else {
				$cluster_name = Opts::get_option('cluster');
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name provided via --cluster: \'' . $cluster_name . '\'');
				$target_cluster_view = Vim::find_entity_view (
					view_type 	=> 'ClusterComputeResource',
					filter 		=> {
						name 	=> $cluster_name
						},
					properties	=> [ @target_properties ]
					); # End $target_cluster_view = Vim::find_entity_view (

				if (defined($target_cluster_view)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
					} # End if (defined($target_cluster_view)) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'\'');
					} # End else {
				
				# Make sure we were able to find the cluster
				if (!$target_cluster_view) {
					# cluster was not found, aborting
					$exit_message_abort = "Cluster \'" . $cluster_name . "\' not found";
					$exit_state_abort = 'UNKNOWN';
					} # End if (!$target_cluster_view) {	
				} # End else {
			
			return ($target_cluster_view, $exit_message_abort, $exit_state_abort);
			} # End sub Cluster_Select {


		sub Cluster_Status {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Status');
			$target_cluster_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			my $cluster_status_flag = 0;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_status_flag: \'' . $cluster_status_flag . '\'');
			
			my $cluster_status = $target_cluster_view->get_property('overallStatus')->val;
			Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_status: \'' . $cluster_status . '\'');
			
			# Check if there are any cluster issues
			my $cluster_issues = Cluster_Issues($target_cluster_view);
			if (defined($cluster_issues)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_issues: \'' . $cluster_issues . '\'');
				} # End if (defined($cluster_issues)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_issues: \'\'');
				} # End else {
			
			# If any cluster config issues were detected create the exit_message and exit_state
			if (defined($cluster_issues)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($cluster_issues)');
				if ($cluster_status ne 'green') {
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_status ne \'green\'');
					# First we define the exit_message_to_add and exit_state_to_add
					$exit_message_to_add = 'Cluster has a ' . uc($cluster_status) . ' status {';
					$exit_state_to_add = $Overall_Status{$cluster_status};
					$cluster_status_flag = 1;
					Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_to_add: \'' . $exit_message_to_add . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_add: \'' . $exit_state_to_add . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_status_flag: \'' . $cluster_status_flag . '\'');
					} # End $cluster_status ne 'green'
				if ($cluster_status_flag == 1) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_status_flag == 1');
					# Now we create/build the exit_message and exit_state
					$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
					$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
					$exit_message = Build_Message($exit_message, "$cluster_issues}");
					} # End if ($cluster_status_flag == 1) {
				} # End if (defined($cluster_issues)) {
			
			# If no problems were detected define the $exit_message and $exit_state
			if ($cluster_status_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_status_flag == 0');
				$exit_message = 'No problems detected';
				$exit_state = 'OK';
				} # End if ($cluster_status_flag == 0) {
			
			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
			return ($exit_message, $exit_state);
			} # End sub Cluster_Status {


		sub Cluster_Swapfile {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_Swapfile');
			$request_type = $_[0];
			$target_cluster_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get the Swapfile Policy
			my $cluster_swapfile_policy;
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view->get_property(\'configurationEx.vmSwapPlacement\'): \'' . $target_cluster_view->get_property('configurationEx.vmSwapPlacement') . '\'');
			switch ($target_cluster_view->get_property('configurationEx.vmSwapPlacement')) {
				case 'vmDirectory' { 
					# Test the --swapfile_policy option
					($exit_state, $cluster_swapfile_policy) = Test_User_Option('swapfile_policy', 'vmDirectory', 'CRITICAL', 'Swapfile Policy is', 'Swapfile Policy: Store In VM Directory', 'vmDirectory');
					} # End case 'vmDirectory' { 
				
				case 'hostLocal' { 
					# Test the --swapfile_policy option
					($exit_state, $cluster_swapfile_policy) = Test_User_Option('swapfile_policy', 'hostLocal', 'CRITICAL', 'Swapfile Policy is', 'Swapfile Policy: Specified By Host', 'vmDirectory');
					} # End case 'vmDirectory' { 
				} # End switch ($target_cluster_view->configurationEx->vmSwapPlacement) {
			
			return Process_Request_Type($request_type, $cluster_swapfile_policy, $exit_state);
			} # End sub Cluster_Swapfile {


		sub Cluster_vMotion {
			Debug_Process('append', 'Line ' . __LINE__ . ' Cluster_vMotion');
			$request_type = $_[0];
			$target_cluster_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view: \'' . $target_cluster_view . '\'');
			
			# Get any user supplied thresholds
			my %Thresholds_User = Thresholds_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

			Debug_Process('append', 'Line ' . __LINE__ . ' $target_cluster_view->summary->numVmotions: \'' . $target_cluster_view->summary->numVmotions . '\'');
			# Exit Message Number Of vMotions
			($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Number of vMotions', $target_cluster_view->summary->numVmotions);
			$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
			$exit_message = Build_Message($exit_message, 'vMotions: ' . Format_Number_With_Commas($target_cluster_view->get_property('summary.numVmotions')));
			
			# Exit Message With Perfdata
			$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
			
			return ($exit_message, $exit_state);
			} # End sub Cluster_vMotion {


		sub Datacenter_Select {
			Debug_Process('append', 'Line ' . __LINE__ . ' Datacenter_Select');
			$exit_state_abort = 'OK';
			
			# Get the property filter
			my @target_properties = @{$_[0]};

			Debug_Process('append', 'Line ' . __LINE__ . ' datacenter @target_properties: \'' . @target_properties . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' datacenter @target_properties values: \'' . join(", ", @target_properties) . '\'');

			my $datacenter_name;
			# Need to make sure the --datacenter argument has been provided
			if (!Opts::option_is_set('datacenter')) {
				# The --datacenter argument was not provided, abort
				$exit_message_abort = "The --datacenter argument was not provided for the Datacenter you want to monitor, aborting!";
				$exit_state_abort = 'UNKNOWN';
				} # End if (!Opts::option_is_set('datacenter')) {
			else {
				$datacenter_name = Opts::get_option('datacenter');
				$target_datacenter_view = Vim::find_entity_view (
					view_type 	=> 'Datacenter',
					filter 		=> {
						name 	=> $datacenter_name
						},
					properties	=> [ @target_properties ]
					); # End $target_datacenter_view = Vim::find_entity_view (

				if (defined($target_datacenter_view)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_datacenter_view: \'' . $target_datacenter_view . '\'');
					} # End if (defined($target_datacenter_view)) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_datacenter_view: \'\'');
					} # End else {
				
				# Make sure we were able to find the datacenter
				if (!$target_datacenter_view) {
					# datacenter was not found, aborting
					$exit_message_abort = "Datacenter \'" . $datacenter_name . "\' not found";
					$exit_state_abort = 'UNKNOWN';
					} # End if (!$target_datacenter_view) {
				} # End else {
			
			return ($target_datacenter_view, $exit_message_abort, $exit_state_abort);
			} # End sub Datacenter_Select {


		sub Datastore {
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore');
			$target_datastore_view = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_datastore_view: \'' . $target_datastore_view . '\'');
			
			# Get the datastore_name
			my $datastore_name = $target_datastore_view->get_property('summary.name');
			Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_name: \'' . $datastore_name . '\'');
			
			# Get any user supplied thresholds
			my %Thresholds_User = Thresholds_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

			Debug_Process('append', 'Line ' . __LINE__ . ' $_[1]: \'' . $_[1] . '\'');
			# Perform the relevant action
			switch ($_[1]) {
				case 'Performance' {
					# Determine the performance counters we want to get data on
					my %Perfdata_Options = %{$_[3]};
					(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);
			
					# Define the property filter for the host
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'datastore', 'configManager.storageSystem', 'summary.config.product.version');
					
					# Get the host this datastore is connected to
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					
					if ($exit_state_abort ne 'UNKNOWN') {
						Debug_Process('append', 'Line ' . __LINE__ . ' if ($exit_state_abort ne \'UNKNOWN\') {');
						# Check if it is in STANDBY
						if ($exit_state_abort eq 'STANDBY') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_abort eq \'STANDBY\'');
							$exit_state = 'OK';
							$exit_message = 'Host is in Standby mode, Datastore Performance check will not be performed';
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_abort ne \'STANDBY\'');
							# Get the Host Connection State
							($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
							
							# Proceed if the host is connected
							if ($host_connection_state_flag == 0) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
									
								# This is the datastore object reference
								my $datastore_ref = $target_datastore_view->get_property('summary.datastore')->value;
								Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_ref: \'' . $datastore_ref . '\'');
								
								my $detection_check = 'no';
								Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
								# Check to see if this host has any datastores
								if ($target_host_view->datastore) {
									Debug_Process('append', 'Line ' . __LINE__ . ' Host has datastores');
									Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->datastore: \'' . $target_host_view->datastore . '\'');
									# Loop through all datastores on this host
									foreach my $host_datastore (@{$target_host_view->datastore}) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_datastore: \'' . $host_datastore . '\'');
										# Check to see if this host has the requested datastore
										if ($host_datastore->value eq $datastore_ref) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $host_datastore->value: \'' . $host_datastore->value . ' eq: \'' . $datastore_ref . '\'');
											$detection_check = 'yes';
											Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
											} # End if ($host_datastore->value eq $datastore_ref) {
										} # End foreach my $host_datastore (@{$target_host_view->datastore}) {
									if ($detection_check eq 'no') {
										Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check eq \'no\'');
										$exit_message_to_add = "Datastore \'" . $datastore_name . "\' NOT found on this host!";
										Build_Exit_Message('Exit', $exit_message, $exit_message_to_add); 
										$exit_state = Build_Exit_State($exit_state, 'UNKNOWN');
										} # End if ($detection_check eq 'no') {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' All checks are good, proceed');
										# All checks are good, proceed
										
										# Get the $target_host_view_storage_system
										my $target_host_view_storage_system = $target_host_view->get_property('configManager.storageSystem');
										Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_storage_system: \'' . $target_host_view_storage_system . '\'');
										
										# Get the $host_storage_system
										my $host_storage_system = Vim::get_view(
											mo_ref		=>	$target_host_view_storage_system,
											properties	=> [ 'fileSystemVolumeInfo.mountInfo' ]
											); # End my $host_storage_system = Vim::get_view(

										Debug_Process('append', 'Line ' . __LINE__ . ' $host_storage_system: \'' . $host_storage_system . '\'');
										
										# Get the instance (this is the physical disk)
										Debug_Process('append', 'Line ' . __LINE__ . ' @{$host_storage_system->get_property(\'fileSystemVolumeInfo.mountInfo\')}: \'' . @{$host_storage_system->get_property('fileSystemVolumeInfo.mountInfo')} . '\'');
										my $instance;
										foreach my $fsv_hash (@{$host_storage_system->get_property('fileSystemVolumeInfo.mountInfo')}) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $fsv_hash: \'' . $fsv_hash . '\'');
											# Check to see if this is the volume we want
											if ($fsv_hash->volume->name eq $datastore_name) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $fsv_hash->volume->name: \'' . $fsv_hash->volume->name . '\' eq: \'' . $datastore_name . '\'');
												# Loop through the extent array
												Debug_Process('append', 'Line ' . __LINE__ . ' @{$fsv_hash->volume->extent}: \'' . @{$fsv_hash->volume->extent} . '\'');
												foreach my $extent (@{$fsv_hash->volume->extent}) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $extent: \'' . $extent . '\'');
													# Define $instance
													$instance = $extent->diskName;
													Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
													} # End foreach my $extent (@{$fsv_hash->volume->extent}) {
												last;
												} # End if ($fsv_hash->volume->name eq $datastore_name) {
											} # End foreach my $fsv_hash (@{$host_storage_system->get_property('fileSystemVolumeInfo.mountInfo')}) {
										
										my $host_version = $target_host_view->get_property('summary.config.product.version');
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_version: \'' . $host_version . '\'');

										# The returned perfdata will be put in here
										my $perf_data;
										
										# Get the Perfdata
										(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_host_view, 'disk', $instance, \@$requested_perf_counter_keys);
										# Process the Perfdata
										$perf_data->{$instance} = Perfdata_Process($perf_data_requested, $perf_counters_used);

										# Start exit_message
										$exit_message = Build_Message($exit_message, "Datastore \'$datastore_name\'");

										# Determine if Datastore_Rate should be reported
										if (defined($perfdata_options_selected->{'Datastore_Rate'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Datastore_Rate\'})');
											# Determine what SI to use for Datastore_Rate
											my $si_datastore_rate = SI_Get('Datastore_Rate', 'kBps');
											Debug_Process('append', 'Line ' . __LINE__ . ' $si_datastore_rate: \'' . $si_datastore_rate . '\'');
											# Define the Datastore_Rate variables
											my $datastore_read = SI_Process('Datastore_Rate', 'kBps', $si_datastore_rate, $perf_data->{$instance}->{read});
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_read: \'' . $datastore_read . '\'');
											my $datastore_write = SI_Process('Datastore_Rate', 'kBps', $si_datastore_rate, $perf_data->{$instance}->{write});
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_write: \'' . $datastore_write . '\'');
											# Get the Datastore_Rate percentages
											(my $datastore_read_percentage, my $datastore_write_percentage) = Process_Percentages($datastore_read, $datastore_write);

											# Exit Message Datastore Read Rate 
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_rate', 'ge', $exit_state, 'Read Rate', $datastore_read, $si_datastore_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message = Build_Message($exit_message, " {Rate (Read:" . Format_Number_With_Commas($datastore_read) . " $si_datastore_rate / $datastore_read_percentage%" . $message_to_add . ')');
											
											# Exit Message Datastore Write Rate
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_rate', 'ge', $exit_state, 'Write Rate', $datastore_write, $si_datastore_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message = Build_Message($exit_message, '(Write:' . Format_Number_With_Commas($datastore_write) . " $si_datastore_rate / $datastore_write_percentage%" . $message_to_add . ')}');
											} # End if (defined($perfdata_options_selected{'Datastore_Rate'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Datastore_Rate\'})');
											} # End else {

										# Determine if Number_Of should be reported
										if (defined($perfdata_options_selected->{'Number_Of'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Number_Of\'})');
											# Exit Message Datastore Number of Reads
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Number of Reads', $perf_data->{$instance}->{numberRead});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message = Build_Message($exit_message, ' {Number of (Reads:' . Format_Number_With_Commas($perf_data->{$instance}->{numberRead}) . ')');
											
											# Exit Message Datastore Number of Writes
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Number of Writes', $perf_data->{$instance}->{numberWrite});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message = Build_Message($exit_message, ' (Writes:' . Format_Number_With_Commas($perf_data->{$instance}->{numberWrite}) . ')}');		
											} # End if (defined($perfdata_options_selected{'Number_Of'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Number_Of\'})');
											} # End else {

										# Determine if Latency should be reported
										if (defined($perfdata_options_selected->{'Latency'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Latency\'})');
											# Determine what SI to use for Latency
											my $si_latency = SI_Get('Latency', 'ms');
											Debug_Process('append', 'Line ' . __LINE__ . ' $si_latency: \'' . $si_latency . '\'');
											# Define the Latency variables
											my $datastore_device_read_latency = SI_Process('Time', 'ms', $si_latency, $perf_data->{$instance}->{deviceReadLatency});
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_read_latency: \'' . $datastore_device_read_latency . '\'');
											my $datastore_device_write_latency = SI_Process('Time', 'ms', $si_latency, $perf_data->{$instance}->{deviceWriteLatency});
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_write_latency: \'' . $datastore_device_write_latency . '\'');

											# Exit Message Datastore Read Latency
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_latency', 'ge', $exit_state, 'Read Latency', $datastore_device_read_latency, $si_latency);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message = Build_Message($exit_message, ' {Latency (Read:' . Format_Number_With_Commas($datastore_device_read_latency) . " $si_latency" . $message_to_add . ')');
											
											# Exit Message Datastore Write Latency
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_latency', 'ge', $exit_state, 'Write Latency', $datastore_device_write_latency, $si_latency);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message = Build_Message($exit_message, '(Write:' . Format_Number_With_Commas($datastore_device_write_latency) . " $si_latency" . $message_to_add . ')}');
											} # End if (defined($perfdata_options_selected{'Latency'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Latency\'})');
											} # End else {
										
										# Exit Message With Perfdata
										$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
										} # End else {
									} # End if ($target_host_view->datastore) {
								else {
									$exit_state = Build_Exit_State($exit_state, 'UNKNOWN');
									$exit_message_to_add = "NO Datastores found on this host!";
									Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
									} # End else {
								} # End if ($host_connection_state_flag == 0) {
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = $exit_message_abort;
						} # End else {
					} # End case 'Performance' {


				case 'Performance_Overall' {
					# Determine the performance counters we want to get data on
					my %Perfdata_Options = %{$_[3]};
					(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);
					
					# Get all the hosts that are connected to this datastore
					Debug_Process('append', 'Line ' . __LINE__ . ' Get all the hosts that are connected to this datastore');
					my @datastore_hosts;
					Debug_Process('append', 'Line ' . __LINE__ . ' @datastore_hosts: \'' . @datastore_hosts . '\'');
					
					foreach my $datastore_array_item (@{$target_datastore_view->{'host'}}) {
						push @datastore_hosts, $datastore_array_item->{'key'};
						} # End foreach my $datastore_array_item (@{$target_datastore_view->{'host'}}) {

					Debug_Process('append', 'Line ' . __LINE__ . ' @datastore_hosts: \'' . @datastore_hosts . '\'');

					# Make sure there are hosts connected to this datastore
					Debug_Process('append', 'Line ' . __LINE__ . ' Make sure there are hosts connected to this datastore');
					if (@datastore_hosts > 0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' @datastore_hosts > 0');

						# This variable will be used to record if a host was in standby
						my $datastore_standby_hosts = 0;
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_standby_hosts: \'' . $datastore_standby_hosts . '\'');

						# This is the datastore object reference
						my $datastore_ref = $target_datastore_view->get_property('summary.datastore')->value;
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_ref: \'' . $datastore_ref . '\'');
									
						Debug_Process('append', 'Line ' . __LINE__ . ' Define variables to store collected data');
						my $datastore_connected_hosts = 0;
						my $datastore_total_hosts = @datastore_hosts;
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_connected_hosts: \'' . $datastore_connected_hosts . '\'');

						my $datastore_read_overall = 0;
						my $datastore_write_overall = 0;
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_read_overall: \'' . $datastore_read_overall . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_write_overall: \'' . $datastore_write_overall . '\'');							

						my $datastore_number_read_overall = 0;
						my $datastore_number_write_overall = 0;
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_number_read_overall: \'' . $datastore_number_read_overall . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_number_write_overall: \'' . $datastore_number_write_overall . '\'');

						my $datastore_device_read_latency_overall = 0;
						my $datastore_device_write_latency_overall = 0;
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_read_latency_overall: \'' . $datastore_device_read_latency_overall . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_write_latency_overall: \'' . $datastore_device_write_latency_overall . '\'');							
							
						# Now get the performance data from each host
						Debug_Process('append', 'Line ' . __LINE__ . ' Now get the performance data from each host');
						Debug_Process('append', 'Line ' . __LINE__ . ' foreach $host_key (@datastore_hosts) {');
						foreach my $host_key (@datastore_hosts) {
							# Define the property filter for this host
							push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'datastore', 'configManager.storageSystem', 'summary.config.product.version');
							
							# Get the target_host_view for this host
							($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $host_key);
							
							if ($exit_state_abort ne 'UNKNOWN') {
								# Check if it is in STANDBY
								if ($exit_state_abort eq 'STANDBY') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_abort eq \'STANDBY\'');
									# Record a host was in standby
									$datastore_standby_hosts++;
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_standby_hosts: \'' . $datastore_standby_hosts . '\'');
									#$exit_state = 'OK';
									#$exit_message = 'Host is in Standby mode, Datastore Performance check will not be performed';
									} # End if ($exit_state_abort eq 'STANDBY') {
								else {
									# Get the Host Connection State
									($host_connection_state, $host_connection_state_flag, my $exit_message_ingnore, my $exit_state_ignore) = Host_Connection_State($target_host_view);
								
									# Proceed if the host is connected
									if ($host_connection_state_flag == 0) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
										
										# Get the $target_host_view_storage_system
										my $target_host_view_storage_system = $target_host_view->get_property('configManager.storageSystem');
										Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_storage_system: \'' . $target_host_view_storage_system . '\'');
										
										# Get the $host_storage_system
										my $host_storage_system = Vim::get_view(
											mo_ref		=>	$target_host_view_storage_system,
											properties	=> [ 'fileSystemVolumeInfo.mountInfo' ]
											); # End my $host_storage_system = Vim::get_view(

										Debug_Process('append', 'Line ' . __LINE__ . ' $host_storage_system: \'' . $host_storage_system . '\'');
										
										# Get the instance (this is the physical disk)
										Debug_Process('append', 'Line ' . __LINE__ . ' @{$host_storage_system->get_property(\'fileSystemVolumeInfo.mountInfo\')}: \'' . @{$host_storage_system->get_property('fileSystemVolumeInfo.mountInfo')} . '\'');
										my $instance;
										foreach my $fsv_hash (@{$host_storage_system->get_property('fileSystemVolumeInfo.mountInfo')}) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $fsv_hash: \'' . $fsv_hash . '\'');
											# Check to see if this is the volume we want
											if ($fsv_hash->volume->name eq $datastore_name) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $fsv_hash->volume->name: \'' . $fsv_hash->volume->name . '\' eq: \'' . $datastore_name . '\'');
												# Loop through the extent array
												Debug_Process('append', 'Line ' . __LINE__ . ' @{$fsv_hash->volume->extent}: \'' . @{$fsv_hash->volume->extent} . '\'');
												foreach my $extent (@{$fsv_hash->volume->extent}) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $extent: \'' . $extent . '\'');
													# Define $instance
													$instance = $extent->diskName;
													Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
													} # End foreach my $extent (@{$fsv_hash->volume->extent}) {
												last;
												} # End if ($fsv_hash->volume->name eq $datastore_name) {
											} # End foreach my $fsv_hash (@{$host_storage_system->get_property('fileSystemVolumeInfo.mountInfo')}) {
										
										my $host_version = $target_host_view->get_property('summary.config.product.version');
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_version: \'' . $host_version . '\'');
										
										#my @requested_perf_counter_keys;
										# These are the performance counters we want to get data on
										#@requested_perf_counter_keys = ('read', 'write', 'numberRead', 'numberWrite', 'deviceReadLatency', 'deviceWriteLatency');
										
										# The returned perfdata will be put in here
										my $perf_data;
										
										# Get the Perfdata
										(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_host_view, 'disk', $instance, \@$requested_perf_counter_keys);
										# Process the Perfdata
										$perf_data->{$instance} = Perfdata_Process($perf_data_requested, $perf_counters_used);

										# Add the perfdata to the overall variables
										
										# Determine if Hosts should be reported
										if (defined($perfdata_options_selected->{'Hosts'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Hosts\'})');
											$datastore_connected_hosts++;
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_connected_hosts: \'' . $datastore_connected_hosts . '\'');
											} # End if (defined($perfdata_options_selected{'Hosts'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Hosts\'})');
											} # End else {
											
										# Determine if Datastore_Rate should be reported
										if (defined($perfdata_options_selected->{'Datastore_Rate'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Datastore_Rate\'})');
											$datastore_read_overall = $datastore_read_overall + $perf_data->{$instance}->{read};
											$datastore_write_overall = $datastore_write_overall + $perf_data->{$instance}->{write};
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_read_overall: \'' . $datastore_read_overall . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_write_overall: \'' . $datastore_write_overall . '\'');
											} # End if (defined($perfdata_options_selected{'Datastore_Rate'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Datastore_Rate\'})');
											} # End else {

										# Determine if Number_Of should be reported
										if (defined($perfdata_options_selected->{'Number_Of'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Number_Of\'})');
											$datastore_number_read_overall = $datastore_number_read_overall + $perf_data->{$instance}->{numberRead};
											$datastore_number_write_overall = $datastore_number_write_overall + $perf_data->{$instance}->{numberWrite};
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_number_read_overall: \'' . $datastore_number_read_overall . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_number_write_overall: \'' . $datastore_number_write_overall . '\'');
											} # End if (defined($perfdata_options_selected{'Number_Of'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Number_Of\'})');
											} # End else {

										# Determine if Latency should be reported
										if (defined($perfdata_options_selected->{'Latency'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Latency\'})');
											$datastore_device_read_latency_overall = $datastore_device_read_latency_overall + $perf_data->{$instance}->{deviceReadLatency};
											$datastore_device_write_latency_overall = $datastore_device_write_latency_overall + $perf_data->{$instance}->{deviceWriteLatency};
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_read_latency_overall: \'' . $datastore_device_read_latency_overall . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_write_latency_overall: \'' . $datastore_device_write_latency_overall . '\'');
											} # End if (defined($perfdata_options_selected{'Latency'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Latency\'})');
											} # End else {
										} # End if ($host_connection_state_flag == 0) {
									} # End else {
								} # End if ($exit_state_abort ne 'UNKNOWN') {
							} # End foreach my $host_key (@datastore_hosts) {

						# Check ALL the hosts were in STANDBY
						if ($datastore_total_hosts == $datastore_standby_hosts) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_total_hosts == $datastore_standby_hosts');
							# ALL the hosts were in standby
							$exit_state = 'OK';
							$exit_message = "ALL Hosts connected to Datastore \'$datastore_name\' are in Standby mode, Datastore Performance Overall check will not be performed";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' Now process all of the data collected');

							# Start exit_message
							$exit_message = Build_Message('', "Datastore \'$datastore_name\'");
							
							# Determine if Hosts should be reported
							if (defined($perfdata_options_selected->{'Hosts'})) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Hosts\'})');
								# Exit Message Total Hosts Connected 
								$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, "'Hosts Connected'=$datastore_connected_hosts 'Hosts Total'=$datastore_total_hosts");
								$exit_message = Build_Message($exit_message, " {Hosts: (Connected: $datastore_connected_hosts)(Total: $datastore_total_hosts)}");
								$exit_state = Build_Exit_State($exit_state, 'OK');
								} # End if (defined($perfdata_options_selected{'Hosts'})) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Hosts\'})');
								} # End else {
								
							# Determine if Datastore_Rate should be reported
							if (defined($perfdata_options_selected->{'Datastore_Rate'})) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Datastore_Rate\'})');
								# Determine what SI to use for Datastore_Rate
								my $si_datastore_rate = SI_Get('Datastore_Rate', 'MBps');
								Debug_Process('append', 'Line ' . __LINE__ . ' $si_datastore_rate: \'' . $si_datastore_rate . '\'');
								# Define the Datastore_Rate variables
								my $datastore_read = SI_Process('Datastore_Rate', 'kBps', $si_datastore_rate, $datastore_read_overall);
								Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_read: \'' . $datastore_read . '\'');
								my $datastore_write = SI_Process('Datastore_Rate', 'kBps', $si_datastore_rate, $datastore_write_overall);
								Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_write: \'' . $datastore_write . '\'');
								# Get the Datastore_Rate percentages
								(my $datastore_read_percentage, my $datastore_write_percentage) = Process_Percentages($datastore_read, $datastore_write);

								# Exit Message Datastore Read Rate 
								($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_rate', 'ge', $exit_state, 'Read Rate', $datastore_read, $si_datastore_rate);
								$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
								$exit_message = Build_Message($exit_message, " {Rate (Read:" . Format_Number_With_Commas($datastore_read) . " $si_datastore_rate / $datastore_read_percentage%" . $message_to_add . ')');
								
								# Exit Message Datastore Write Rate
								($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_rate', 'ge', $exit_state, 'Write Rate', $datastore_write, $si_datastore_rate);
								$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
								$exit_message = Build_Message($exit_message, '(Write:' . Format_Number_With_Commas($datastore_write) . " $si_datastore_rate / $datastore_write_percentage%" . $message_to_add . ')}');
								} # End if (defined($perfdata_options_selected{'Datastore_Rate'})) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Datastore_Rate\'})');
								} # End else {

							# Determine if Number_Of should be reported
							if (defined($perfdata_options_selected->{'Number_Of'})) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Number_Of\'})');
								# Exit Message Datastore Number of Reads
								($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Number of Reads', $datastore_number_read_overall);
								$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
								$exit_message = Build_Message($exit_message, ' {Number of (Reads:' . Format_Number_With_Commas($datastore_number_read_overall) . ')');
								
								# Exit Message Datastore Number of Writes
								($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Number of Writes', $datastore_number_write_overall);
								$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
								$exit_message = Build_Message($exit_message, ' (Writes:' . Format_Number_With_Commas($datastore_number_write_overall) . ')}');
								} # End if (defined($perfdata_options_selected{'Number_Of'})) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Number_Of\'})');
								} # End else {

							# Determine if Latency should be reported
							if (defined($perfdata_options_selected->{'Latency'})) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Latency\'})');
								# Determine what SI to use for Latency
								my $si_latency = SI_Get('Latency', 'ms');
								Debug_Process('append', 'Line ' . __LINE__ . ' $si_latency: \'' . $si_latency . '\'');
								# Define the Latency variables
								my $datastore_device_read_latency = SI_Process('Time', 'ms', $si_latency, $datastore_device_read_latency_overall);
								Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_read_latency: \'' . $datastore_device_read_latency . '\'');
								my $datastore_device_write_latency = SI_Process('Time', 'ms', $si_latency, $datastore_device_write_latency_overall);
								Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_device_write_latency: \'' . $datastore_device_write_latency . '\'');

								# Exit Message Datastore Read Latency
								($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_latency', 'ge', $exit_state, 'Read Latency', $datastore_device_read_latency, $si_latency);
								$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
								$exit_message = Build_Message($exit_message, ' {Latency (Read:' . Format_Number_With_Commas($datastore_device_read_latency) . " $si_latency" . $message_to_add . ')');
								
								# Exit Message Datastore Write Latency
								($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_latency', 'ge', $exit_state, 'Write Latency', $datastore_device_write_latency, $si_latency);
								$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
								$exit_message = Build_Message($exit_message, '(Write:' . Format_Number_With_Commas($datastore_device_write_latency) . " $si_latency" . $message_to_add . ')}');
								} # End if (defined($perfdata_options_selected{'Latency'})) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Latency\'})');
								} # End else {
							
							# Exit Message With Perfdata
							$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
							} # End else {
						} # End if (@datastore_hosts > 0) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' @datastore_hosts == 0');
						$exit_state = 'UNKNOWN';
						$exit_message = "There are no hosts connected to the datastore '$datastore_name'";
						} # End else {
					} # End case 'Performance_Overall' {
				

				case 'Usage' {
					my %Perfdata_Options = %{$_[3]};
					(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
					
					# Get the datastore_capacity
					my $datastore_capacity = $target_datastore_view->get_property('summary.capacity');
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_capacity: \'' . $datastore_capacity . '\'');
					
					# Determine what SI to use for the Datastore_Size
					my $si_prefix_to_return = SI_Get('Datastore_Size', 'GB');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return: \'' . $si_prefix_to_return . '\'');
					
					# Convert the $datastore_capacity to SI
					$datastore_capacity = SI_Process('Datastore_Size', 'B', $si_prefix_to_return, $datastore_capacity);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_capacity: \'' . $datastore_capacity . '\'');
					# Convert this to an integer
					$datastore_capacity = ceil($datastore_capacity);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_capacity: \'' . $datastore_capacity . '\'');
					
					# Get the datastore_free_space
					my $datastore_free_space = $target_datastore_view->get_property('summary.freeSpace');
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_free_space: \'' . $datastore_free_space . '\'');
					# Convert the $datastore_free_space to SI
					$datastore_free_space = SI_Process('Datastore_Size', 'B', $si_prefix_to_return, $datastore_free_space);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_free_space: \'' . $datastore_free_space . '\'');
					
					# Start exit_message
					$exit_message = Build_Message($exit_message, "Datastore \'$datastore_name\'");
					
					# Determine if Datastore_Free should be reported
					if (defined($perfdata_options_selected->{'Datastore_Free'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Datastore_Free\'})');
						# Exit Message Datastore Free Space
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_free', 'le', $exit_state, 'Free Space', $datastore_free_space, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, " {Free Space: " . Format_Number_With_Commas($datastore_free_space) . " " . $si_prefix_to_return . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Datastore_Free'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Datastore_Free\'})');
						} # End else {
						
					# Determine if Datastore_Used should be reported
					if (defined($perfdata_options_selected->{'Datastore_Used'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Datastore_Used\'})');
						# Calculate the $datastore_used_space
						my $datastore_used_space = sprintf("%.1f", $datastore_capacity - $datastore_free_space);
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_used_space: \'' . $datastore_used_space . '\'');
						# Convert the $datastore_used_space to SI
						$datastore_used_space = SI_Process('Datastore_Size', $si_prefix_to_return, $si_prefix_to_return, $datastore_used_space);
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_used_space: \'' . $datastore_used_space . '\'');

						# Exit Message Datastore Used Space
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_used', 'ge', $exit_state, 'Used Space', $datastore_used_space, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Used Space: ' . Format_Number_With_Commas($datastore_used_space) . " " . $si_prefix_to_return . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Datastore_Used'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Datastore_Used\'})');
						} # End else {
						
					# Determine if Datastore_Capacity should be reported
					if (defined($perfdata_options_selected->{'Datastore_Capacity'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Datastore_Capacity\'})');
						# Exit Message Datastore Capacity
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Capacity', $datastore_capacity, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Capacity: ' . Format_Number_With_Commas($datastore_capacity) . " $si_prefix_to_return}");
						} # End if (defined($perfdata_options_selected->{'Datastore_Capacity'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Datastore_Capacity\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End case 'Usage' {
				} # End switch ($_[1]) {

			return ($exit_message, $exit_state);
			} # End sub Datastore {


		sub Datastore_Cluster {
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore_Cluster');
			$target_datastore_cluster_view = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_datastore_cluster_view: \'' . $target_datastore_cluster_view . '\'');
			
			# Get the datastore_cluster_name
			my $datastore_cluster_name = $target_datastore_cluster_view->get_property('summary.name');
			Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_name: \'' . $datastore_cluster_name . '\'');

			# Get any user supplied thresholds
			my %Thresholds_User = Thresholds_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

			Debug_Process('append', 'Line ' . __LINE__ . ' $_[1]: \'' . $_[1] . '\'');
			# Perform the relevant action
			switch ($_[1]) {
				case 'Status' {
					# Start the exit message
					$exit_message = Build_Message('', "Datastore Cluster \'$datastore_cluster_name\'");

					# Get the datastore_cluster_overall_status
					my $datastore_cluster_overall_status = $target_datastore_cluster_view->get_property('overallStatus')->val;
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_overall_status: \'' . $datastore_cluster_overall_status . '\'');
					$exit_message = Build_Message($exit_message, " {Overall Status is $datastore_cluster_overall_status=$Overall_Status{$datastore_cluster_overall_status}}");
					$exit_state = Build_Exit_State($Overall_Status{$datastore_cluster_overall_status});
										
					# Get the datastore_cluster_alarm_actions_enabled
					my $datastore_cluster_alarm_actions_enabled = $target_datastore_cluster_view->get_property('alarmActionsEnabled');
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_alarm_actions_enabled: \'' . $datastore_cluster_alarm_actions_enabled . '\'');
					
					# Get the datastore_cluster_triggered_alarm_state
					if (defined($target_datastore_cluster_view->get_property('triggeredAlarmState'))) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($target_datastore_cluster_view->get_property(\'triggeredAlarmState\'))');
						my $datastore_cluster_triggered_alarm_state = $target_datastore_cluster_view->get_property('triggeredAlarmState');
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_triggered_alarm_state: \'' . $datastore_cluster_triggered_alarm_state . '\'');
						my $datastore_cluster_triggered_alarms_total = @$datastore_cluster_triggered_alarm_state;
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_triggered_alarms_total: \'' . $datastore_cluster_triggered_alarms_total . '\'');
						# Start the Alarms message
						$exit_message = Build_Message($exit_message, " {Alarms Total: $datastore_cluster_triggered_alarms_total");
						
						# Now loop through all the triggered alarms
						Debug_Process('append', 'Line ' . __LINE__ . ' Processing triggered alarms');
						my $triggered_alarm_count = 0;
						foreach my $triggered_alarm (@$datastore_cluster_triggered_alarm_state) {
							$triggered_alarm_count++;
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_count: \'' . $triggered_alarm_count . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm: \'' . $triggered_alarm . '\'');
							# Get the alarm status
							my $triggered_alarm_overall_status = $triggered_alarm->{'overallStatus'}->val;
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_overall_status: \'' . $triggered_alarm_overall_status . '\'');
							# Has the alarm been acknowledged
							my $triggered_alarm_acknowledged = $triggered_alarm->{'acknowledged'};
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_acknowledged: \'' . $triggered_alarm_acknowledged . '\'');
							# When was the alarm triggered?
							my $triggered_alarm_time = $triggered_alarm->{'time'};
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_time: \'' . $triggered_alarm_time . '\'');
							# Calculate the age of the alarm
							my $alarm_time_difference = sprintf("%0.f", ((localtime->epoch - str2time($triggered_alarm_time)) / 86400));

							Debug_Process('append', 'Line ' . __LINE__ . ' $alarm_time_difference before check: \'' . $alarm_time_difference . '\'');
							
							# Check to make sure this isn't -0
							if ($alarm_time_difference == -0) {
								$alarm_time_difference = 0;
								} # End if ($alarm_time_difference == -0) {

							Debug_Process('append', 'Line ' . __LINE__ . ' $alarm_time_difference after check: \'' . $alarm_time_difference . '\'');
							
							# Build the message for this alarm
							$exit_message = Build_Message($exit_message, " (#$triggered_alarm_count:");
							if ($triggered_alarm_acknowledged == 0) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_acknowledged == 0');
								# Build the message for this alarm
								$exit_message = Build_Message($exit_message, " NOT Acknowledged, $triggered_alarm_overall_status=$Overall_Status{$triggered_alarm_overall_status}");
								$exit_state = Build_Exit_State($Overall_Status{$triggered_alarm_overall_status});
								} # End if ($triggered_alarm_acknowledged == 0) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_acknowledged != 0');
								$exit_message = Build_Message($exit_message, " Acknowledged, $triggered_alarm_overall_status");
								$exit_state = Build_Exit_State($exit_state, "OK");
								} # End else {
								
							# Build the message for this alarm
							$exit_message = Build_Message($exit_message, ", Age: $alarm_time_difference " . Process_Plural($alarm_time_difference, 'Today', 'Day', 'Days') . ")");
							} # End foreach my $triggered_alarm (@$datastore_cluster_triggered_alarm_state) {
						$exit_message = Build_Message($exit_message, "}");
						} # End if (defined($target_datastore_cluster_view->get_property('triggeredAlarmState'))) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($target_datastore_cluster_view->get_property(\'triggeredAlarmState\'))');
						# Build the message for this alarm
						$exit_message = Build_Message($exit_message, " {No Alarms}");
						$exit_state = Build_Exit_State($exit_state, "OK");
						} # End else {

					# Get the datastore_cluster_pod_storage_drs_entry
					if (defined($target_datastore_cluster_view->get_property('podStorageDrsEntry'))) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($target_datastore_cluster_view->get_property(\'podStorageDrsEntry\'))');
						# Start the Storage DRS message
						$exit_message = Build_Message($exit_message, " {Storage DRS");
						
						# Get the datastore_cluster_pod_storage_drs_enabled
						my $datastore_cluster_pod_storage_drs_enabled = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.enabled');
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_enabled: \'' . $datastore_cluster_pod_storage_drs_enabled . '\'');

						if ($datastore_cluster_pod_storage_drs_enabled == 1) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_enabled == 1');
							$exit_message = Build_Message($exit_message, " is Enabled");
							my $datastore_cluster_pod_storage_drs_entry = $target_datastore_cluster_view->get_property('podStorageDrsEntry');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_entry: \'' . $datastore_cluster_pod_storage_drs_entry . '\'');

							# Get the datastore_cluster_pod_storage_drs_default_intra_vm_affinity
							my $datastore_cluster_pod_storage_drs_default_intra_vm_affinity = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.defaultIntraVmAffinity');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_default_intra_vm_affinity: \'' . $datastore_cluster_pod_storage_drs_default_intra_vm_affinity . '\'');
							switch ($datastore_cluster_pod_storage_drs_default_intra_vm_affinity) {
								case 0 {
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_default_intra_vm_affinity == 0 (false)');
									$exit_message = Build_Message($exit_message, " (Guest Disks: Keep Apart)");
									} # End case 0 {

								case 1 {
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_default_intra_vm_affinity == 1 (true)');
									$exit_message = Build_Message($exit_message, " (Guest Disks: Keep Together)");
									} # End case 1 {
								} # End switch ($datastore_cluster_pod_storage_drs_default_intra_vm_affinity) {
							
							# Get the datastore_cluster_pod_storage_drs_io_load_balance_enabled
							my $datastore_cluster_pod_storage_drs_io_load_balance_enabled = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.ioLoadBalanceEnabled');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_io_load_balance_enabled: \'' . $datastore_cluster_pod_storage_drs_io_load_balance_enabled . '\'');
							switch ($datastore_cluster_pod_storage_drs_io_load_balance_enabled) {
								case 0 {
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_io_load_balance_enabled == 0 (false)');
									$exit_message = Build_Message($exit_message, " (I/O Load Balancing: Disabled)");
									} # End case 0 {

								case 1 {
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_io_load_balance_enabled == 1 (true)');
									$exit_message = Build_Message($exit_message, " (I/O Load Balancing: Enabled");

									# Get the datastore_cluster_pod_storage_drs_io_load_balance_config_io_load_imbalance_threshold
									my $datastore_cluster_pod_storage_drs_io_load_balance_config_io_load_imbalance_threshold = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.ioLoadBalanceConfig.ioLoadImbalanceThreshold');
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_io_load_balance_config_io_load_imbalance_threshold: \'' . $datastore_cluster_pod_storage_drs_io_load_balance_config_io_load_imbalance_threshold . '\'');
									$exit_message = Build_Message($exit_message, ", I/O Imbalance Threshold: $datastore_cluster_pod_storage_drs_io_load_balance_config_io_load_imbalance_threshold");
									
									# Get the datastore_cluster_pod_storage_drs_io_load_balance_config_io_latency_threshold
									my $datastore_cluster_pod_storage_drs_io_load_balance_config_io_latency_threshold = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.ioLoadBalanceConfig.ioLatencyThreshold');
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_io_load_balance_config_io_latency_threshold: \'' . $datastore_cluster_pod_storage_drs_io_load_balance_config_io_latency_threshold . '\'');
									$exit_message = Build_Message($exit_message, ", I/O Latency Threshold: $datastore_cluster_pod_storage_drs_io_load_balance_config_io_latency_threshold ms");

									$exit_message = Build_Message($exit_message, ")");
									} # End case 1 {
								} # End switch ($datastore_cluster_pod_storage_drs_io_load_balance_enabled) {
							
							# Get the datastore_cluster_pod_storage_drs_default_vm_behavior
							my $datastore_cluster_pod_storage_drs_default_vm_behavior = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.defaultVmBehavior');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_default_vm_behavior: \'' . $datastore_cluster_pod_storage_drs_default_vm_behavior . '\'');
							$exit_message = Build_Message($exit_message, " (Automation Level:");
							switch ($datastore_cluster_pod_storage_drs_default_vm_behavior) {
								case 'manual' {
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_default_vm_behavior eq manual');
									$exit_message = Build_Message($exit_message, " Manual)");
									} # End case 'manual' {

								case 'automated' {
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_default_vm_behavior eq automated');
									$exit_message = Build_Message($exit_message, " Automated)");
									} # End case 'automated' {
								} # End switch ($datastore_cluster_pod_storage_drs_default_vm_behavior) {

							# Get the datastore_cluster_pod_storage_drs_space_load_balance_config_min_space_utilization_difference
							my $datastore_cluster_pod_storage_drs_space_load_balance_config_min_space_utilization_difference = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.spaceLoadBalanceConfig.minSpaceUtilizationDifference');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_space_load_balance_config_min_space_utilization_difference: \'' . $datastore_cluster_pod_storage_drs_space_load_balance_config_min_space_utilization_difference . '\'');

							# Get the datastore_cluster_pod_storage_drs_space_load_balance_config_space_utilization_threshold
							my $datastore_cluster_pod_storage_drs_space_load_balance_config_space_utilization_threshold = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.spaceLoadBalanceConfig.spaceUtilizationThreshold');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_space_load_balance_config_space_utilization_threshold: \'' . $datastore_cluster_pod_storage_drs_space_load_balance_config_space_utilization_threshold . '\'');
							$exit_message = Build_Message($exit_message, " (Space Load Balancing Threshold: $datastore_cluster_pod_storage_drs_space_load_balance_config_space_utilization_threshold% Used)");
							
							# Get the datastore_cluster_pod_storage_drs_load_balance_interval
							my $datastore_cluster_pod_storage_drs_load_balance_interval = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.loadBalanceInterval');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_load_balance_interval: \'' . $datastore_cluster_pod_storage_drs_load_balance_interval . '\'');
							my $datastore_cluster_pod_storage_drs_load_balance_interval_hours = $datastore_cluster_pod_storage_drs_load_balance_interval / 60;
							$exit_message = Build_Message($exit_message, " (Load Balancing Runs Every: $datastore_cluster_pod_storage_drs_load_balance_interval_hours " . Process_Plural($datastore_cluster_pod_storage_drs_load_balance_interval_hours, 'Hours', 'Hour', 'Hours') . ")");

							# Get the datastore_cluster_pod_storage_drs_option
							my $datastore_cluster_pod_storage_drs_option = $target_datastore_cluster_view->get_property('podStorageDrsEntry.storageDrsConfig.podConfig.option');
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_option: \'' . $datastore_cluster_pod_storage_drs_option . '\'');

							# Loop through the options
							foreach my $drs_options (@$datastore_cluster_pod_storage_drs_option) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $drs_options: \'' . $drs_options . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' $drs_options->\'key\': \'' . $drs_options->{'key'} . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' $drs_options->\'value\': \'' . $drs_options->{'value'} . '\'');
								if ($drs_options->{'key'} eq 'IgnoreAffinityRulesForMaintenance') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $drs_options->{\'key\'} eq \'IgnoreAffinityRulesForMaintenance\'');
									my $datastore_cluster_pod_storage_drs_option_ignore_affinity_rules_for_maintenance = $drs_options->{'value'};
									Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_option_ignore_affinity_rules_for_maintenance: \'' . $datastore_cluster_pod_storage_drs_option_ignore_affinity_rules_for_maintenance . '\'');
									$exit_message = Build_Message($exit_message, " (Affinity Rule Behaviour During Maintenance:");
									switch ($datastore_cluster_pod_storage_drs_option_ignore_affinity_rules_for_maintenance) {
										case 0 {
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_option_ignore_affinity_rules_for_maintenance eq 0');
											$exit_message = Build_Message($exit_message, " Ignored)");
											} # End case '0' {

										case '1' {
											Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_option_ignore_affinity_rules_for_maintenance eq 1');
											$exit_message = Build_Message($exit_message, " Adhered)");
											} # End case '1' {
										} # End switch ($datastore_cluster_pod_storage_drs_option_ignore_affinity_rules_for_maintenance) {
									} # End if ($drs_options->{'key'} eq 'IgnoreAffinityRulesForMaintenance') {
								} # End foreach my $drs_options (@$datastore_cluster_pod_storage_drs_option) {
							} # End if ($datastore_cluster_pod_storage_drs_enabled == 1) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_pod_storage_drs_enabled == 0');
							$exit_message = Build_Message($exit_message, " is Disabled");
							} # End else {
						
						# End the Storage DRS message
						$exit_message = Build_Message($exit_message, "}");
						} # End if (defined($target_datastore_cluster_view->get_property('podStorageDrsEntry'))) {
					} # End case 'Status' {

				case 'Usage' {
					my %Perfdata_Options = %{$_[3]};
					my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
			
					# Get the datastore_cluster_capacity
					my $datastore_cluster_capacity = $target_datastore_cluster_view->get_property('summary.capacity');
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_capacity: \'' . $datastore_cluster_capacity . '\'');
					
					# Determine what SI to use for the Datastore_Cluster_Size
					my $si_prefix_to_return = SI_Get('Datastore_Cluster_Size', 'TB');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return: \'' . $si_prefix_to_return . '\'');
					
					# Convert the $datastore_cluster_capacity to SI
					$datastore_cluster_capacity = SI_Process('Datastore_Cluster_Size', 'B', $si_prefix_to_return, $datastore_cluster_capacity);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_capacity: \'' . $datastore_cluster_capacity . '\'');
					# Convert this to an integer
					$datastore_cluster_capacity = ceil($datastore_cluster_capacity);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_capacity: \'' . $datastore_cluster_capacity . '\'');
					
					# Get the datastore_cluster_free_space
					my $datastore_cluster_free_space = $target_datastore_cluster_view->get_property('summary.freeSpace');
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_free_space: \'' . $datastore_cluster_free_space . '\'');
					# Convert the $datastore_cluster_free_space to SI
					$datastore_cluster_free_space = SI_Process('Datastore_Cluster_Size', 'B', $si_prefix_to_return, $datastore_cluster_free_space);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_free_space: \'' . $datastore_cluster_free_space . '\'');
					
					# Calculate the $datastore_cluster_used_space
					my $datastore_cluster_used_space = sprintf("%.1f", $datastore_cluster_capacity - $datastore_cluster_free_space);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_used_space: \'' . $datastore_cluster_used_space . '\'');
					# Convert the $datastore_cluster_used_space to SI
					$datastore_cluster_used_space = SI_Process('Datastore_Cluster_Size', $si_prefix_to_return, $si_prefix_to_return, $datastore_cluster_used_space);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_used_space: \'' . $datastore_cluster_used_space . '\'');

					# Start the exit_mesage
					$exit_message = "Datastore Cluster \'$datastore_cluster_name\'";

					# Determine if Free should be reported
					if (defined($perfdata_options_selected->{'Free'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Free\'})');
						# Exit Message Datastore Cluster Free Space
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_cluster_free', 'le', $exit_state, 'Free Space', $datastore_cluster_free_space, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, " {Free Space: " . Format_Number_With_Commas($datastore_cluster_free_space) . " " . $si_prefix_to_return . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Free'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Free\'})');
						} # End else {

					# Determine if Used should be reported
					if (defined($perfdata_options_selected->{'Used'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Used\'})');
						# Exit Message Datastore Cluster Used Space
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'datastore_cluster_used', 'ge', $exit_state, 'Used Space', $datastore_cluster_used_space, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Used Space: ' . Format_Number_With_Commas($datastore_cluster_used_space) . " " . $si_prefix_to_return . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Used'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Used\'})');
						} # End else {

					# Determine if Capacity should be reported
					if (defined($perfdata_options_selected->{'Capacity'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Capacity\'})');
						# Exit Message Datastore Cluster Capacity
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Capacity', $datastore_cluster_capacity, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Capacity: ' . Format_Number_With_Commas($datastore_cluster_capacity) . " $si_prefix_to_return}");
						} # End if (defined($perfdata_options_selected->{'Capacity'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Capacity\'})');
						} # End else {

					# Determine if Children should be reported
					if (defined($perfdata_options_selected->{'Children'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Children\'})');

						# Get the child datastores in datastore_cluster
						my $datastore_cluster_children = @{$target_datastore_cluster_view->{'childEntity'}};
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_children: \'' . $datastore_cluster_children . '\'');
						
						# Exit Message Datastore Cluster Children
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, "'Child Datastores'=$datastore_cluster_children");
						$exit_message = Build_Message($exit_message, ' {Child Datastores: ' . Format_Number_With_Commas($datastore_cluster_children) . "}");
						$exit_state = Build_Exit_State($exit_state, 'OK');
						} # End if (defined($perfdata_options_selected->{'Children'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Children\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End case 'Usage' {
				} # End switch ($_[1]) {

			return ($exit_message, $exit_state);
			} # End sub Datastore_Cluster {


		sub Datastore_Cluster_Select {
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore_Cluster_Select');
			$exit_state_abort = 'OK';
			
			# Get the property filter
			my @target_properties = @{$_[0]};
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore_Cluster_Select @target_properties: \'' . @target_properties . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore_Cluster_Select @target_properties values: \'' . join(", ", @target_properties) . '\'');
			
			# Datastore Clusters only available since vSphere 5.0
			my $target_vcenter_view = Vim::get_service_content();	
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_vcenter_view: \'' . $target_vcenter_view . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_vcenter_view->about->version: \'' . $target_vcenter_view->about->version . '\'');
			if ($target_vcenter_view->about->version ge 5.0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_vcenter_view->about->version ge 5.0');
				my $datastore_cluster_name;
				# Determine if the datastore cluster name was passed internally
				if (defined($_[1])) {
					Debug_Process('append', 'Line ' . __LINE__ . ' Datastore Cluster name has been passed internally');
					# Datastore Cluster name has been passed internally
					use URI::Escape qw(uri_unescape);
					$datastore_cluster_name = uri_unescape($_[1]);
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_name: \'' . $datastore_cluster_name . '\'');
					
					$target_datastore_cluster_view = Vim::find_entity_view (
						view_type 	=> 'StoragePod',
						filter 		=> {
							name	=> $datastore_cluster_name,
							},
						properties	=> [ @target_properties ]
						); # End $target_datastore_cluster_view = Vim::find_entity_view (
					
					# Make sure we were able to find the datastore cluster
					if (!$target_datastore_cluster_view) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !$target_datastore_cluster_view');
						Debug_Process('append', 'Line ' . __LINE__ . ' Datastore Cluster was not found, aborting!');
						# Datastore was not found, aborting
						$exit_message_abort = "Datastore Cluster \'" . $datastore_cluster_name . "\' not found";
						$exit_state_abort = 'UNKNOWN';
						} # End if (!$target_datastore_cluster_view) {
					} # End if (defined($_[1])) {
				else {
					# Need to make sure the --name argument has been provided
					if (!Opts::option_is_set('name')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'name\')');
						Debug_Process('append', 'Line ' . __LINE__ . ' The --name argument was not provided for the datastore cluster you want to monitor, aborting!');
						# The --name argument was not provided, abort
						$exit_message_abort = "The --name argument was not provided for the datastore cluster you want to monitor, aborting!";
						$exit_state_abort = 'UNKNOWN';
						} # End if (!Opts::option_is_set('name')) {
					else {
						$datastore_cluster_name = Opts::get_option('name');
						Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_cluster_name: \'' . $datastore_cluster_name . '\'');
						
						$target_datastore_cluster_view = Vim::find_entity_view (
							view_type	=> 'StoragePod',
							filter 		=> {
								name	=> $datastore_cluster_name,
								},
							properties	=> [ @target_properties ]
							); # End $target_datastore_cluster_view = Vim::find_entity_view (
						
						# Make sure we were able to find the datastore cluster
						if (!$target_datastore_cluster_view) {
							Debug_Process('append', 'Line ' . __LINE__ . ' !$target_datastore_cluster_view');
							Debug_Process('append', 'Line ' . __LINE__ . ' Datastore Cluster was not found, aborting!');
							# Datastore was not found, aborting
							$exit_message_abort = "Datastore Cluster \'" . $datastore_cluster_name . "\' not found";
							$exit_state_abort = 'UNKNOWN';
							} # End if (!$target_datastore_cluster_view) {
						} # End else {
					} # End else {
				} # End if ($target_vcenter_view->about->version ge 5.0) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_vcenter_view->about->version lt 5.0');
				$exit_message_abort = "Datastore Cluster checks are only valid in vSphere 5.0 onwards, aborting!";
				$exit_state_abort = 'UNKNOWN';
				} # End else {
			
			return ($target_datastore_cluster_view, $exit_message_abort, $exit_state_abort);
			} # End sub Datastore_Cluster_Select {


		sub Datastore_Select {
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore_Select');
			$exit_state_abort = 'OK';
			
			# Get the property filter
			my @target_properties = @{$_[0]};
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore_Select @target_properties: \'' . @target_properties . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' Datastore_Select @target_properties values: \'' . join(", ", @target_properties) . '\'');
			
			my $datastore_name;
			# Determine if the datastore name was passed internally
			if (defined($_[1])) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Datastore name has been passed internally');
				# Datastore name has been passed internally
				use URI::Escape qw(uri_unescape);
				$datastore_name = uri_unescape($_[1]);
				Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_name: \'' . $datastore_name . '\'');
				
				$target_datastore_view = Vim::find_entity_view (
					view_type 	=> 'Datastore',
					filter 		=> {
						name	=> $datastore_name,
						},
					properties	=> [ @target_properties ]
					); # End $target_datastore_view = Vim::find_entity_view (
				
				# Make sure we were able to find the datastore
				if (!$target_datastore_view) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !$target_datastore_view');
					Debug_Process('append', 'Line ' . __LINE__ . ' Datastore was not found, aborting!');
					# Datastore was not found, aborting
					$exit_message_abort = "Datastore \'" . $datastore_name . "\' not found";
					$exit_state_abort = 'UNKNOWN';
					} # End if (!$target_datastore_view) {
				} # End if (defined($_[1])) {
			else {
				# Need to make sure the --name argument has been provided
				if (!Opts::option_is_set('name')) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'name\')');
					Debug_Process('append', 'Line ' . __LINE__ . ' The --name argument was not provided for the datastore you want to monitor, aborting!');
					# The --name argument was not provided, abort
					$exit_message_abort = "The --name argument was not provided for the datastore you want to monitor, aborting!";
					$exit_state_abort = 'UNKNOWN';
					} # End if (!Opts::option_is_set('name')) {
				else {
					$datastore_name = Opts::get_option('name');
					Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_name: \'' . $datastore_name . '\'');
					
					$target_datastore_view = Vim::find_entity_view (
						view_type	=> 'Datastore',
						filter 		=> {
							name	=> $datastore_name,
							},
						properties	=> [ @target_properties ]
						); # End $target_datastore_view = Vim::find_entity_view (
					
					# Make sure we were able to find the datastore
					if (!$target_datastore_view) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !$target_datastore_view');
						Debug_Process('append', 'Line ' . __LINE__ . ' Datastore was not found, aborting!');
						# Datastore was not found, aborting
						$exit_message_abort = "Datastore \'" . $datastore_name . "\' not found";
						$exit_state_abort = 'UNKNOWN';
						} # End if (!$target_datastore_view) {
					} # End else {
				} # End else {
			
			return ($target_datastore_view, $exit_message_abort, $exit_state_abort);
			} # End sub Datastore_Select {
			

		sub Debug_Process {
			# Is Debug Mode set?
			if (Opts::option_is_set('debug')) {
				# Yes it is
				my $debug_option = $_[0];
				my $debug_value = $_[1];
				my $debug_log = '/home/vi-admin/box293_check_vmware_debug_log.txt';

				# Display the message on the screen
				print $debug_value . "\n";

				# Open the debug log
				switch ($debug_option) {
					case 'create' {
						open(FILE, '>' . $debug_log);
						print FILE "$debug_value\n";
						close(FILE);
						} # End case 'create' {

					case 'append' {
						open(FILE, '>>' . $debug_log);
						print FILE "$debug_value\n";
						close(FILE);
						} # End case 'append' {
					} # End switch ($debug_option) {
				} # End if (Opts::option_is_set('debug')) {
			} # End sub Debug_Process {


		sub Define_Instance {
			Debug_Process('append', 'Line ' . __LINE__ . ' Define_Instance');
			my $instance_type = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $instance_type: \'' . $instance_type . '\'');
			
			my $instance;
			switch ($instance_type) {
				case 'Virtual_Disk' {
					my $guest_controllers = $_[1];
					my $guest_disks = $_[2];
					my $current_disk = $_[3];
					my $controller_label = $guest_controllers->{$guest_disks->{$current_disk}->controllerKey}->deviceInfo->label;
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_controllers: \'' . $guest_controllers . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_disks: \'' . $guest_disks . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk: \'' . $current_disk . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $controller_label: \'' . $controller_label . '\'');
					
					switch ($controller_label) {
						case /^(SCSI)/ {
							$instance = "scsi" . $guest_controllers->{$guest_disks->{$current_disk}->controllerKey}->busNumber . ":" . $guest_disks->{$current_disk}->unitNumber;
							} # End case /^(SCSI)/ {
						
						case /^(IDE)/ {
							$instance = "ide" . $guest_controllers->{$guest_disks->{$current_disk}->controllerKey}->busNumber . ":" . $guest_disks->{$current_disk}->unitNumber;
							} # End case /^(IDE)/ {
						} # End switch ($controller_label) {
					} # End case 'Virtual_Disk' {
				} # End switch ($instance_type) {
			
			Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');

			return $instance;
			} # End sub Define_Instance {


		sub Disk {
			Debug_Process('append', 'Line ' . __LINE__ . ' Disk');
			$target_guest_view = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');
			
			# Get the Guest Connection State
			($guest_connection_state, $guest_connection_state_flag, $exit_message, $exit_state) = Guest_Connection_State($target_guest_view);
			
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');
				# Get any user supplied thresholds
				my %Thresholds_User = Thresholds_Get();
				Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
			
				# Start by getting all the virtual disks in the guest
				my $guest_disks;
				my $guest_controllers;
				my $guest_disk_counter = 0;
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_disk_counter: \'' . $guest_disk_counter . '\'');
				# Loop through all the devices in the guest
				foreach my $device (@{$target_guest_view->get_property('config.hardware.device')}) {
					Debug_Process('append', 'Line ' . __LINE__ . ' ref($device): \'' . ref($device) . '\'');
					
					# Check for a VirtualDisk
					if (ref($device) eq 'VirtualDisk') {
						# Add this VirtualDisk to $guest_disks
						$guest_disks->{$guest_disk_counter} = $device;
						$guest_disk_counter++;
						} # End if (ref($device) eq 'VirtualDisk') {
					
					# Check for a VirtualSCSIController
					if (ref($device)->isa('VirtualSCSIController')) {
						# Add this VirtualSCSIController to $guest_controllers
						$guest_controllers->{$device->key} = $device;
						} # End if (ref($device)->isa('VirtualSCSIController')) {
					
					# Check for a VirtualIDEController
					if (ref($device)->isa('VirtualIDEController')) {
						# Add this VirtualIDEController to $guest_controllers
						$guest_controllers->{$device->key} = $device;
						} # End if (ref($device)->isa('VirtualIDEController')) {

					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_disk_counter: \'' . $guest_disk_counter . '\'');
					} # End foreach my $device (@{$target_guest_view->get_property('config.hardware.device')}) {
				
				# Make sure the guest has virtual disks
				if (defined($guest_disks)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($guest_disks)');
					# Define the property filter for the host
					push my @target_properties, ('summary.runtime.powerState', 'summary.config.product.version');
					
					# Get the $host_version
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));
					my $host_version = $target_host_view->get_property('summary.config.product.version');

					Debug_Process('append', 'Line ' . __LINE__ . ' $_[1]: \'' . $_[1] . '\'');
					# Perform the relevant action
					switch ($_[1]) {
						case 'Performance' {
							# Get the guest uptime state
							($guest_uptime_state_flag, $exit_message, $exit_state) = Guest_Uptime_State($target_guest_view);
							if ($guest_uptime_state_flag == 0) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag == 0');
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_version: \'' . $host_version . '\'');
								# Virtual Disk metrics are only available on ESX(i) 4.1 onwards
								if ($host_version ge '4.1.0') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $host_version ge \'4.1.0\'');
									# Determine the performance counters we want to get data on
									my %Perfdata_Options = %{$_[3]};
									(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);

									# The returned perfdata will be put in here
									my $perf_data;
									
									Debug_Process('append', 'Line ' . __LINE__ . ' Loop through all the virtual disks');
									# Loop through all the virtual disks
									for (my $current_disk = 0; $current_disk < scalar(keys %$guest_disks); $current_disk++) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk: \'' . $current_disk . '\'');

										# Get the datastore this virtual disk resides on
										$target_datastore_view = Vim::get_view (
											mo_ref => $guest_disks->{$current_disk}->backing->datastore
											); # End $target_host_view = Vim::get_view (

										Debug_Process('append', 'Line ' . __LINE__ . ' $target_datastore_view: \'' . $target_datastore_view . '\'');
										
										my $datastore_name = $target_datastore_view->summary->name;
										my $disk_name = $guest_disks->{$current_disk}->deviceInfo->label;
										Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_name: \'' . $datastore_name . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $disk_name: \'' . $disk_name . '\'');
										
										# Define $instance
										my $instance = Define_Instance('Virtual_Disk', $guest_controllers, $guest_disks, $current_disk);
										Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
										
										# Get the Perfdata
										(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_guest_view, 'virtualDisk', $instance, \@$requested_perf_counter_keys);
										# Process the Perfdata
										$perf_data->{$instance} = Perfdata_Process($perf_data_requested, $perf_counters_used);
										
										# Start the exit_message_to_add
										$exit_message_to_add = "[$disk_name ($instance) on '$datastore_name'";

										# Determine if Disk_Rate should be reported
										if (defined($perfdata_options_selected->{'Disk_Rate'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Disk_Rate\'})');
											# Determine what SI to use for Disk_Rate
											my $si_disk_rate = SI_Get('Disk_Rate', 'kBps');
											Debug_Process('append', 'Line ' . __LINE__ . ' $si_disk_rate: \'' . $si_disk_rate . '\'');
											# Define the Disk_Rate variables
											my $disk_read = SI_Process('Disk_Rate', 'kBps', $si_disk_rate, $perf_data->{$instance}->{read});
											Debug_Process('append', 'Line ' . __LINE__ . ' $disk_read: \'' . $disk_read . '\'');
											my $disk_write = SI_Process('Disk_Rate', 'kBps', $si_disk_rate, $perf_data->{$instance}->{write});
											Debug_Process('append', 'Line ' . __LINE__ . ' $disk_write: \'' . $disk_write . '\'');
											# Get the Disk_Rate percentages
											(my $disk_read_percentage, my $disk_write_percentage) = Process_Percentages($disk_read, $disk_write);
																					
											# Exit Message Disk Read Rate 
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_rate', 'ge', $exit_state, "$disk_name ($instance) Read Rate", $disk_read, $si_disk_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, "{Rate (Read:" . Format_Number_With_Commas($disk_read) . " $si_disk_rate / $disk_read_percentage%" . $message_to_add . ')');
											
											# Exit Message Disk Write Rate
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_rate', 'ge', $exit_state, "$disk_name ($instance) Write Rate", $disk_write, $si_disk_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Write:' . Format_Number_With_Commas($disk_write) . " $si_disk_rate / $disk_write_percentage%" . $message_to_add . ')}');
											} # End if (defined($perfdata_options_selected{'Disk_Rate'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Disk_Rate\'})');
											} # End else {

										# Determine if Averaged should be reported
										if (defined($perfdata_options_selected->{'Averaged'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Averaged\'})');
											# Exit Message Disk Number of Reads
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$disk_name ($instance) Averaged Number of Reads", $perf_data->{$instance}->{numberReadAveraged});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Averaged Number of (Reads:' . Format_Number_With_Commas($perf_data->{$instance}->{numberReadAveraged}) . ')');
											
											# Exit Message Disk Number of Writes
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$disk_name ($instance) Averaged Number of Writes", $perf_data->{$instance}->{numberWriteAveraged});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' (Writes:' . Format_Number_With_Commas($perf_data->{$instance}->{numberWriteAveraged}) . ')}');
											} # End if (defined($perfdata_options_selected->{'Averaged'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Averaged\'})');
											} # End else {

										# Determine if Latency should be reported
										if (defined($perfdata_options_selected->{'Latency'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected{\'Latency\'})');
											if ($host_version ge '5.1.0') {
												Debug_Process('append', 'Line ' . __LINE__ . ' $host_version ge \'5.1.0\'');
												# Determine what SI to use for Latency
												my $si_latency = SI_Get('Latency', 'us');
												Debug_Process('append', 'Line ' . __LINE__ . ' $si_latency: \'' . $si_latency . '\'');
												# Define the Latency variables
												my $disk_read_latency_us = SI_Process('Time', 'us', $si_latency, $perf_data->{$instance}->{readLatencyUS});
												Debug_Process('append', 'Line ' . __LINE__ . ' $disk_read_latency_us: \'' . $disk_read_latency_us . '\'');
												my $disk_write_latency_us = SI_Process('Time', 'us', $si_latency, $perf_data->{$instance}->{writeLatencyUS});
												Debug_Process('append', 'Line ' . __LINE__ . ' $disk_write_latency_us: \'' . $disk_write_latency_us . '\'');
												
												# Exit Message Disk Read Latency
												($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_latency', 'ge', $exit_state, "$disk_name ($instance) Read Latency", $disk_read_latency_us, $si_latency);
												$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
												$exit_message_to_add = Build_Message($exit_message_to_add, ' {Latency (Read:' . Format_Number_With_Commas($disk_read_latency_us) . " $si_latency" . $message_to_add . ')');
												
												# Exit Message Disk Write Latency
												($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_latency', 'ge', $exit_state, "$disk_name ($instance) Write Latency", $disk_write_latency_us, $si_latency);
												$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
												$exit_message_to_add = Build_Message($exit_message_to_add, '(Write:' . Format_Number_With_Commas($disk_write_latency_us) . " $si_latency" . $message_to_add . ')}');
												} # End if ($host_version ge '5.1.0') {
											else {
												Debug_Process('append', 'Line ' . __LINE__ . ' $host_version lt \'5.1.0\'');
												# Determine what SI to use for Latency
												my $si_latency = SI_Get('Latency', 'ms');
												Debug_Process('append', 'Line ' . __LINE__ . ' $si_latency: \'' . $si_latency . '\'');
												# Define the Latency variables
												my $disk_total_read_latency = SI_Process('Time', 'ms', $si_latency, $perf_data->{$instance}->{totalReadLatency});
												Debug_Process('append', 'Line ' . __LINE__ . ' $disk_total_read_latency: \'' . $disk_total_read_latency . '\'');
												my $disk_total_write_latency = SI_Process('Time', 'ms', $si_latency, $perf_data->{$instance}->{totalWriteLatency});
												Debug_Process('append', 'Line ' . __LINE__ . ' $disk_total_write_latency: \'' . $disk_total_write_latency . '\'');
												
												# Exit Message Disk Read Latency
												($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_latency', 'ge', $exit_state, "$disk_name ($instance) Total Read Latency", $disk_total_read_latency, $si_latency);
												$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
												$exit_message_to_add = Build_Message($exit_message_to_add, ' {Latency (Read:' . Format_Number_With_Commas($disk_total_read_latency) . " $si_latency" . $message_to_add . ')');
												
												# Exit Message Disk Write Latency
												($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_latency', 'ge', $exit_state, "$disk_name ($instance) Total Write Latency", $disk_total_write_latency, $si_latency);
												$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
												$exit_message_to_add = Build_Message($exit_message_to_add, '(Write:' . Format_Number_With_Commas($disk_total_write_latency) . " $si_latency" . $message_to_add . ')}');
												} # End else {
											} # End if (defined($perfdata_options_selected->{'Latency'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected{\'Latency\'})');
											} # End else {
										
										# Add to the exit message
										$exit_message_to_add = Build_Message($exit_message_to_add, "]"); 
										
										# Exit Message Appended
										$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
										} # End for (my $current_disk = 0; $current_disk < scalar(keys %$guest_disks); $current_disk++) {\
									
									# Exit Message With Perfdata
									$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
									} # End if ($host_version ge '4.1.0') {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' Virtual Disk metrics are only available on ESX(i) 4.1 onwards');
									# Virtual Disk metrics are only available on ESX(i) 4.1 onwards
									$exit_message = "Virtual Disk metrics are only available on ESX(i) 4.1 onwards, aborting!";
									$exit_state = Build_Exit_State($exit_state, 'UNKNOWN');
									} # End else {
								} # End if ($guest_uptime_state_flag == 0) {
							} # End case 'Performance' {
						
						case 'Usage' {
							# Determine the performance counters we want to get data on
							my %Perfdata_Options = %{$_[3]};
							my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);

							# Determine what SI to use for the Disk_Size
							my $si_disk_size = SI_Get('Disk_Size', 'GB');
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_disk_size: \'' . $si_disk_size . '\'');
							
							# Define $disk_usage_total
							my $disk_usage_total = 0;
							Debug_Process('append', 'Line ' . __LINE__ . ' $disk_usage_total: \'' . $disk_usage_total . '\'');
							
							Debug_Process('append', 'Line ' . __LINE__ . ' Loop through all the virtual disks');
							# Loop through all the virtual disks
							for (my $current_disk = 0; $current_disk < scalar(keys %$guest_disks); $current_disk++) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk: \'' . $current_disk . '\'');

								# Get the datastore this virtual disk resides on
								$target_datastore_view = Vim::get_view (
									mo_ref => $guest_disks->{$current_disk}->backing->datastore
									); # End $target_host_view = Vim::get_view (
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_datastore_view: \'' . $target_datastore_view . '\'');
								
								my $datastore_name = $target_datastore_view->summary->name;
								my $disk_name = $guest_disks->{$current_disk}->deviceInfo->label ;
								my $instance = Define_Instance('Virtual_Disk', $guest_controllers, $guest_disks, $current_disk);
								Debug_Process('append', 'Line ' . __LINE__ . ' $datastore_name: \'' . $datastore_name . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' $disk_name: \'' . $disk_name . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
								
								my $disk_capacity = $guest_disks->{$current_disk}->capacityInKB;
								Debug_Process('append', 'Line ' . __LINE__ . ' $disk_capacity: \'' . $disk_capacity . '\'');
								# Convert the $datastore_capacity to SI
								$disk_capacity = SI_Process('Disk_Size', 'kB', $si_disk_size, $disk_capacity);
								Debug_Process('append', 'Line ' . __LINE__ . ' $disk_capacity: \'' . $disk_capacity . '\'');
								
								# Get the $current_disk_file_name
								my $current_disk_file_name = $guest_disks->{$current_disk}->backing->fileName;
								Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk_file_name: \'' . $current_disk_file_name . '\'');

								# I want the size of the flat vmdk file
								# Following steps are a bit dodgy but it does the trick !
								
								if (defined $target_guest_view->snapshot) {
									# Get rid of -xxxxxx.vmdk
									for (my $chop_counter = 0; $chop_counter < 12; $chop_counter++) {
										chop($current_disk_file_name);
										} # End for (my $chop_counter = 0; $chop_counter < 12; $chop_counter++) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk_file_name: \'' . $current_disk_file_name . '\'');
									} # End if (defined $target_guest_view->snapshot) {
								else {
									# Get rid of .vmdk
									for (my $chop_counter = 0; $chop_counter < 5; $chop_counter++) {
										chop($current_disk_file_name);
										} # End for (my $chop_counter = 0; $chop_counter < 5; $chop_counter++) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk_file_name: \'' . $current_disk_file_name . '\'');
									} # End else {

								# Now add -flat.vmdk to the end of the file
								$current_disk_file_name = $current_disk_file_name . '-flat.vmdk';
								Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk_file_name: \'' . $current_disk_file_name . '\'');
									
								# Determine the size on datastore
								my $disk_size_on_datastore = 0;
								my $test_value_1;
								Debug_Process('append', 'Line ' . __LINE__ . ' Loop through all the VM files');
								# Loop through all the VM files
								foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk_file_name: \'' . $current_disk_file_name . '\'');
									Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->name: \'' . $file_hash->name . '\'');
									
									# Look for the files we want
									if ($current_disk_file_name eq $file_hash->name) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $current_disk_file_name eq $file_hash->name');
										Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->name: \'' . $file_hash->name . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->size: \'' . $file_hash->size . '\'');
										# Create a test value
										$test_value_1 = SI_Process('Disk_Size', 'B', 'kB', $file_hash->size);
										Debug_Process('append', 'Line ' . __LINE__ . ' $test_value_1: \'' . $test_value_1 . '\'');
										# Define $disk_size_on_datastore (B)
										$disk_size_on_datastore = SI_Process('Disk_Size', 'B', $si_disk_size, $file_hash->size);
										Debug_Process('append', 'Line ' . __LINE__ . ' $disk_size_on_datastore: \'' . $disk_size_on_datastore . '\'');
										} # End if ($current_disk_file_name eq $file_hash->name) {
									} # End foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
								
								# Determine the provisioning type
								Debug_Process('append', 'Line ' . __LINE__ . ' $guest_disks->{$current_disk}->backing->thinProvisioned: \'' . $guest_disks->{$current_disk}->backing->thinProvisioned . '\'');

								my $disk_provision_type;
								my $provisioning_flag;
								if ($guest_disks->{$current_disk}->backing->thinProvisioned) {
									$provisioning_flag = 'Thin';
									} # End if ($guest_disks->{$current_disk}->backing->thinProvisioned) {
								else {
									if ($host_version ge '4' && $host_version lt '5') {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_version ge \'4\' && $host_version lt \'5\'');
										# Checking to see if the disk is thin or thick due to an ESX(i) 4 bug
										# See VMware KB 1020137
										my $test_value_2 = $guest_disks->{$current_disk}->capacityInKB;
										Debug_Process('append', 'Line ' . __LINE__ . ' $test_value_2: \'' . $test_value_2 . '\'');
										if ($test_value_1 != $test_value_2) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $test_value_1 != $test_value_2');
											$provisioning_flag = 'Thin';
											} # End if ($test_value_1 != $test_value_2) {
										else {
											$provisioning_flag = 'Thick';
											} # End else {
										} # End if ($host_version ge '4' && $host_version lt '5') {
									else {
										$provisioning_flag = 'Thick';
										} # End else {
									} # End else {

								Debug_Process('append', 'Line ' . __LINE__ . ' $provisioning_flag: \'' . $provisioning_flag . '\'');

								if ($provisioning_flag eq 'Thin') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $provisioning_flag eq \'Thin\'');
									$disk_provision_type = 'Thin';
									# Increment $disk_usage_total
									$disk_usage_total = $disk_usage_total + $disk_size_on_datastore;
									} # End if ($provisioning_flag eq 'Thin') {
								else {
									if ($guest_disks->{$current_disk}->backing->eagerlyScrub) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $guest_disks->{$current_disk}->backing->eagerlyScrub');
										$disk_provision_type = 'Thick (Eager)';
										# Increment $disk_usage_total
										$disk_usage_total = $disk_usage_total + $disk_capacity;
										} # End elsif ($device->backing->eagerlyScrub) {
									else {
										$disk_provision_type = 'Thick (Lazy)';
										# Increment $disk_usage_total
										$disk_usage_total = $disk_usage_total + $disk_capacity;
										} # End else {
									} # End else {

								Debug_Process('append', 'Line ' . __LINE__ . ' $disk_provision_type: \'' . $disk_provision_type . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' $disk_usage_total: \'' . $disk_usage_total . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' $guest_disks->{$current_disk}->capacityInKB: \'' . $guest_disks->{$current_disk}->capacityInKB . '\'');
																
								if (defined($perfdata_options_selected->{'Disk_Capacity'}) or defined($perfdata_options_selected->{'Disk_Size_On_Datastore'}) or defined($perfdata_options_selected->{'Disk_Free'})) {
									# Start exit_message_to_add for Individual Disks
									$exit_message_to_add = "[$disk_name ($instance) on \'$datastore_name\' {Provisioning: $disk_provision_type}";

									# Determine if Disk_Capacity should be reported
									if (defined($perfdata_options_selected->{'Disk_Capacity'})) {
										Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Capacity\'})');
										# Exit Message Disk Capacity
										($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$disk_name ($instance) Capacity", $disk_capacity, $si_disk_size);
										$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
										$exit_message_to_add = Build_Message($exit_message_to_add, " {Disk Capacity: " . Format_Number_With_Commas($disk_capacity) . " $si_disk_size}");
										} # End if (defined($perfdata_options_selected->{'Disk_Capacity'})) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Capacity\'})');
										} # End else {
									
									if ($disk_provision_type eq 'Thin') {
										Debug_Process('append', 'Line ' . __LINE__ . ' $disk_provision_type eq \'Thin\'');
										# Get the remaining free space in the thin disk
										my $disk_space_remaining = sprintf("%.1f", $disk_capacity - $disk_size_on_datastore);
										Debug_Process('append', 'Line ' . __LINE__ . ' $disk_space_remaining: \'' . $disk_space_remaining . '\'');
										# Get the percentages
										(my $disk_space_remaining_percentage, my $disk_size_on_datastore_percentage) = Process_Percentages($disk_space_remaining, $disk_size_on_datastore);

										# Determine if Disk_Size_On_Datastore should be reported
										if (defined($perfdata_options_selected->{'Disk_Size_On_Datastore'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Size_On_Datastore\'})');
											# Exit Message Size On Datastore
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$disk_name ($instance) Size On Datastore", $disk_size_on_datastore, $si_disk_size);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Size On Datastore: ' . Format_Number_With_Commas($disk_size_on_datastore) . " $si_disk_size}");
											} # End if (defined($perfdata_options_selected->{'Disk_Size_On_Datastore'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Size_On_Datastore\'})');
											} # End else {

										# Determine if Disk_Free should be reported
										if (defined($perfdata_options_selected->{'Disk_Free'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Free\'})');
											# Exit Message Disk Free Space
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_free', 'le', $exit_state, "$disk_name ($instance) Free Space", $disk_space_remaining, $si_disk_size);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Free Space: ' . Format_Number_With_Commas($disk_space_remaining) . " $si_disk_size / $disk_space_remaining_percentage%" . $message_to_add . '}');
											} # End if (defined($perfdata_options_selected->{'Disk_Free'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Free\'})');
											} # End else {
										} # End if ($disk_provision_type eq 'Thin') {
									
									# Add to the exit message
									$exit_message_to_add = Build_Message($exit_message_to_add, "]"); 
									
									#  Exit Message Appended
									$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
									}
								} # End for (my $current_disk = 0; $current_disk < scalar(keys %$guest_disks); $current_disk++) {
							
							# Determine if a swap file or suspend file is in place
							my $swap_message_to_add;
							my $perfdata_swap_message_to_add;
							my $uw_swap_message_to_add;
							my $perfdata_uw_swap_message_to_add;
							my $suspend_message_to_add;
							my $perfdata_suspend_message_to_add;
							Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'summary.runtime.powerState\')->val: \'' . $target_guest_view->get_property('summary.runtime.powerState')->val . '\'');
							switch ($target_guest_view->get_property('summary.runtime.powerState')->val) {
								case 'poweredOn' {
									foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->type: \'' . $file_hash->type . '\'');
										switch ($file_hash->type) {
											case 'swap' {
												# Determine if Disk_Swap_File should be reported
												if (defined($perfdata_options_selected->{'Disk_Swap_File'})) {
													Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Swap_File\'})');
													# Get $swap_size
													my $swap_size = $file_hash->size;
													Debug_Process('append', 'Line ' . __LINE__ . ' $swap_size: \'' . $swap_size . '\'');
													# Convert the $swap_size to SI
													$swap_size = SI_Process('Disk_Size', 'B', $si_disk_size, $swap_size);
													Debug_Process('append', 'Line ' . __LINE__ . ' $swap_size: \'' . $swap_size . '\'');
													
													# Exit Message swap file 
													($perfdata_swap_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Swap File', $swap_size, $si_disk_size);
													$swap_message_to_add = "{Swap File: " . Format_Number_With_Commas($swap_size) . " $si_disk_size}";
										
													# Increment $disk_usage_total
													$disk_usage_total = $disk_usage_total + $swap_size;
													Debug_Process('append', 'Line ' . __LINE__ . ' $disk_usage_total: \'' . $disk_usage_total . '\'');
													} # End if (defined($perfdata_options_selected->{'Disk_Swap_File'})) {
												else {
													Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Swap_File\'})');
													} # End else {
												} # End case 'swap' {
											
											case 'uwswap' {
												# Determine if Disk_Swap_Userworld should be reported
												if (defined($perfdata_options_selected->{'Disk_Swap_Userworld'})) {
													Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Swap_Userworld\'})');
													# Get $uwswap_size
													my $uwswap_size = $file_hash->size;
													Debug_Process('append', 'Line ' . __LINE__ . ' $uwswap_size: \'' . $uwswap_size . '\'');
													# Convert the $uwswap_size to SI
													$uwswap_size = SI_Process('Disk_Size', 'B', $si_disk_size, $uwswap_size);
													Debug_Process('append', 'Line ' . __LINE__ . ' $uwswap_size: \'' . $uwswap_size . '\'');
													
													# Exit Message uwswap
													($perfdata_uw_swap_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Userworld Swap File', $uwswap_size, $si_disk_size);
													$uw_swap_message_to_add = "{Userworld Swap File: " . Format_Number_With_Commas($uwswap_size) . " $si_disk_size}";
										
													# Increment $disk_usage_total
													$disk_usage_total = $disk_usage_total + $uwswap_size;
													Debug_Process('append', 'Line ' . __LINE__ . ' $disk_usage_total: \'' . $disk_usage_total . '\'');
													} # End if (defined($perfdata_options_selected->{'Disk_Swap_Userworld'})) {
												else {
													Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Swap_Userworld\'})');
													} # End else {
												} # End case 'uwswap' {
											} # End switch ($file_hash->type) {

										Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->name: \'' . $file_hash->name . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->type: \'' . $file_hash->type . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->size: \'' . $file_hash->size . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->key: \'' . $file_hash->key . '\'');
										} # End foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
									} # End case 'poweredOn' {
								
								case 'suspended' {
									# Determine if Disk_Suspend_File should be reported
									if (defined($perfdata_options_selected->{'Disk_Suspend_File'})) {
										Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Suspend_File\'})');
										foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->type: \'' . $file_hash->type . '\'');
											if ($file_hash->type eq 'suspend') {
												# Get $suspend_size
												my $suspend_size = $file_hash->size;
												Debug_Process('append', 'Line ' . __LINE__ . ' $suspend_size: \'' . $suspend_size . '\'');
												# Convert the $suspend_size to SI
												$suspend_size = SI_Process('Disk_Size', 'B', $si_disk_size, $suspend_size);
												Debug_Process('append', 'Line ' . __LINE__ . ' $suspend_size: \'' . $suspend_size . '\'');
												
												# Exit Message suspend file
												($perfdata_suspend_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Suspend File', $suspend_size, $si_disk_size);
												$suspend_message_to_add = "{Suspend File: " . Format_Number_With_Commas($suspend_size) . " $si_disk_size}";
									
												# Increment $disk_usage_total
												$disk_usage_total = $disk_usage_total + $suspend_size;
												Debug_Process('append', 'Line ' . __LINE__ . ' $disk_usage_total: \'' . $disk_usage_total . '\'');
												last;
												} # End if ($file_hash->type eq 'suspend') {

											Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->name: \'' . $file_hash->name . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->type: \'' . $file_hash->type . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->size: \'' . $file_hash->size . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->key: \'' . $file_hash->key . '\'');
											} # End foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
										} # End if (defined($perfdata_options_selected->{'Disk_Suspend_File'})) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Suspend_File\'})');
										} # End else {
									} # End case 'suspended' {
								} # End switch ($target_guest_view->summary->runtime->powerState->val) {
							
							# Checking for snapshots
							my $snapshot_message_to_add;
							my $perfdata_snapshot_message_to_add;
							if (defined $target_guest_view->snapshot) {
								# Determine if Disk_Snapshot_Space should be reported
								if (defined($perfdata_options_selected->{'Disk_Snapshot_Space'})) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Snapshot_Space\'})');
									Debug_Process('append', 'Line ' . __LINE__ . ' defined $target_guest_view->snapshot');
									my $snapshot_total_space_used = Guest_Snapshot('Space Used', $target_guest_view);
									Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_total_space_used: \'' . $snapshot_total_space_used . '\'');
									# Convert the $snapshot_total_space_used to SI
									$snapshot_total_space_used = SI_Process('Disk_Size', 'B', $si_disk_size, $snapshot_total_space_used);
									Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_total_space_used: \'' . $snapshot_total_space_used . '\'');
									
									# Exit Message snapshot data
									($perfdata_snapshot_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'All Snapshot Space', $snapshot_total_space_used, $si_disk_size);
									$snapshot_message_to_add = "{All Snapshot Space: " . Format_Number_With_Commas($snapshot_total_space_used) . " $si_disk_size}";
									
									# Increment $disk_usage_total
									$disk_usage_total = $disk_usage_total + $snapshot_total_space_used;
									Debug_Process('append', 'Line ' . __LINE__ . ' $disk_usage_total: \'' . $disk_usage_total . '\'');
									} # End if (defined($perfdata_options_selected->{'Disk_Snapshot_Space'})) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Snapshot_Space\'})');
									} # End else {
								} # End if (defined $target_guest_view->snapshot) {

							if (defined($perfdata_options_selected->{'Disk_Usage'}) or defined($swap_message_to_add) or defined($uw_swap_message_to_add) or defined($suspend_message_to_add) or defined($snapshot_message_to_add)) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Usage\'}) or defined($swap_message_to_add) or defined($uw_swap_message_to_add) or defined($suspend_message_to_add) or defined($snapshot_message_to_add)');
								# Start exit_message_to_add for Totals
								$exit_message_to_add = '[Totals:';
								
								# Exit Message Disk Usage Totals
								my $perfdata_totals_message;

								# Determine if Disk_Usage should be reported
								if (defined($perfdata_options_selected->{'Disk_Usage'})) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Disk_Usage\'})');
									($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'disk_total', 'ge', $exit_state, 'Total Disk Usage', $disk_usage_total, $si_disk_size);
									$perfdata_totals_message = Build_Perfdata_Message('Build', $perfdata_totals_message, $perfdata_message_to_add);
									$exit_message_to_add = Build_Message($exit_message_to_add, " {Disk Usage: " . Format_Number_With_Commas($disk_usage_total) . " $si_disk_size" . $message_to_add . '}');
									} # End if (defined($perfdata_options_selected->{'Disk_Usage'})) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Usage\'})');
									} # End else {
								
								if (defined($swap_message_to_add)) {
									$exit_message_to_add = Build_Message($exit_message_to_add, $swap_message_to_add, ' ');
									$perfdata_totals_message = Build_Perfdata_Message('Build', $perfdata_totals_message, $perfdata_swap_message_to_add);
									} # End if (defined($swap_message_to_add)) {
								
								if (defined($uw_swap_message_to_add)) {
									$exit_message_to_add = Build_Message($exit_message_to_add, $uw_swap_message_to_add, ' ');
									$perfdata_totals_message = Build_Perfdata_Message('Build', $perfdata_totals_message, $perfdata_uw_swap_message_to_add);
									} # End if (defined($uw_swap_message_to_add)) {
								
								if (defined($suspend_message_to_add)) {
									$exit_message_to_add = Build_Message($exit_message_to_add, $suspend_message_to_add, ' ');
									$perfdata_totals_message = Build_Perfdata_Message('Build', $perfdata_totals_message, $perfdata_suspend_message_to_add);
									} # End if (defined($suspend_message_to_add)) {
								
								if (defined($snapshot_message_to_add)) {
									$exit_message_to_add = Build_Message($exit_message_to_add, $snapshot_message_to_add, ' ');
									$perfdata_totals_message = Build_Perfdata_Message('Build', $perfdata_totals_message, $perfdata_snapshot_message_to_add);
									} # End if (defined($snapshot_message_to_add)) {
								
								$exit_message_to_add = Build_Message($exit_message_to_add, ']');
								
								if (defined($perfdata_totals_message)) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_totals_message)');
									# Put the perfdata_totals_message in front of the existing perfdata_message
									$perfdata_message = Build_Perfdata_Message('Build', $perfdata_totals_message, $perfdata_message, $exit_state);
									} # End if (defined($perfdata_totals_message)) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_totals_message)');
									} # End else {

								# Does the existing $exit_message exist?
								if (!defined($exit_message)) {
									Debug_Process('append', 'Line ' . __LINE__ . ' !defined($exit_message)');
									$exit_message = $exit_message_to_add;
									} # End if (!defined($exit_message)) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_message)');
									# Exit Message Appended (putting the totals in front of the existing $exit_message)
									$exit_message = Build_Exit_Message('Exit', $exit_message_to_add, $exit_message);
									} # End else {
								} # End if (defined($perfdata_options_selected->{'Disk_Usage'}) or defined($swap_message_to_add) or defined($uw_swap_message_to_add) or defined($suspend_message_to_add) or defined($snapshot_message_to_add)) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Disk_Usage\'}) or NOT defined($swap_message_to_add) or NOT defined($uw_swap_message_to_add) or NOT defined($suspend_message_to_add) or NOT defined($snapshot_message_to_add)');
								} # End else {
								
							# Exit Message With Perfdata
							$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
							} # End case 'Usage' {
						} # End switch ($_[1]) {
					} # End if (defined($guest_disks)) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' There are no virtual disks, abort');
					# There are no virtual disks, abort
					$exit_message = 'This guest has NO virtual disks, aborting!';
					$exit_state = Build_Exit_State($exit_state, 'UNKNOWN');
					} # End else {
					
				} # End if ($guest_connection_state_flag == 0) {
			
			return ($exit_message, $exit_state);
			} # End sub Disk {


		sub Format_Number_With_Commas {
			my @parts = split(/,/, $_[0]);
			$parts[0] =~ s/(\d)(?=(\d{3})+(\D|$))/$1\,/g;
			return join('.', @parts);
			} # End sub Format_Number_With_Commas {


		sub Guest_Connection_State {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Connection_State');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');
			
			# Get $guest_connection_state
			$guest_connection_state = $target_guest_view->get_property('summary.runtime.connectionState')->val;
			Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state: \'' . $guest_connection_state . '\'');
			
			switch ($guest_connection_state) {
				case 'connected' {
					$guest_connection_state_flag = 0;
					} # End case 'connected') {
				
				case 'disconnected' {
					$exit_message = 'Guest disconnected!';
					$exit_state = 'CRITICAL';
					$guest_connection_state_flag = 1;
					} # End case 'disconnected') {
				
				case 'inaccessible' {
					$exit_message = 'One or more of the guest configuration files are inaccessible!';
					$exit_state = 'CRITICAL';
					$guest_connection_state_flag = 1;
					} # End case 'inaccessible') {
				
				case 'invalid' {
					$exit_message = 'The guest configuration format is invalid!';
					$exit_state = 'CRITICAL';
					$guest_connection_state_flag = 1;
					} # End case 'invalid') {
				
				case 'orphaned' {
					$exit_message = 'The guest is no longer registered on the host it is associated with!';
					$exit_state = 'CRITICAL';
					$guest_connection_state_flag = 1;
					} # End case 'orphaned') {
				} # End switch ($guest_connection_state) {
			
			return ($guest_connection_state, $guest_connection_state_flag, $exit_message, $exit_state)
			} # End sub Guest_Connection_State {


		sub Guest_CPU_Info {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_CPU_Info');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');

			my %Perfdata_Options = %{$_[1]};
			my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
			
			# Get the Guest Connection State
			($guest_connection_state, $guest_connection_state_flag, $exit_message, $exit_state) = Guest_Connection_State($target_guest_view);
			
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');
				# Get the guest uptime state
				($guest_uptime_state_flag, $exit_message, $exit_state) = Guest_Uptime_State($target_guest_view);
				if ($guest_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag == 0');
					# Get any user supplied thresholds
					my %Thresholds_User = Thresholds_Get();
					Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
					
					# Determine what SI to use
					my $si_prefix_to_return_speed = SI_Get('CPU_Speed', 'MHz');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return_speed: \'' . $si_prefix_to_return_speed . '\'');
					
					# Get the number of CPU Cores
					my $guest_cpu_cores = $target_guest_view->get_property('summary.config.numCpu');
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_cores: \'' . $guest_cpu_cores . '\'');

					$api_version = API_Version();
					
					# numCoresPerSocket only available since vSphere API 5.0
					if ($api_version ge 5.0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $api_version ge 5.0');
						# Determine if Cores should be reported
						if (defined($perfdata_options_selected->{'Cores'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Cores\'})');
							# Exit Message CPU Cores
							# Get the number of CPU Cores Per Socket
							my $guest_cpu_cores_per_socket = $target_guest_view->get_property('config.hardware.numCoresPerSocket');
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_cores_per_socket: \'' . $guest_cpu_cores_per_socket . '\'');
							# Determine the number of sockets	
							my $guest_cpu_sockets = $guest_cpu_cores / $guest_cpu_cores_per_socket;
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_sockets: \'' . $guest_cpu_sockets . '\'');
							if ($guest_cpu_cores == 1) {
								$exit_message = " {CPU Cores: $guest_cpu_cores}";
								} # End if ($guest_cpu_cores == 1) {
							else {
								$exit_message = " {CPU (Cores Total: $guest_cpu_cores) (Cores Per Socket: $guest_cpu_cores_per_socket) (Sockets: $guest_cpu_sockets)}";
								} # End else {
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Cores Total', $guest_cpu_cores);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Cores Per Socket', $guest_cpu_cores_per_socket);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Sockets', $guest_cpu_sockets);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							} # End if (defined($perfdata_options_selected->{'Cores'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Cores\'})');
							} # End else {
						} # End if ($api_version ge 5.0) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 5.0');
						} # End else {
					
					# Determine if CPU_Total should be reported
					if (defined($perfdata_options_selected->{'CPU_Total'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Total\'})');
						# Define the property filter for the host
						push my @target_properties, ('summary.runtime.powerState', 'summary.hardware.cpuMhz');
						# Get the total cpu in the guest (MHz) (requires some metrics from the host)
						($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));
						my $host_cpu_speed = $target_host_view->get_property('summary.hardware.cpuMhz');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_cpu_speed: \'' . $host_cpu_speed . '\'');
						my $guest_cpu_total = $guest_cpu_cores * $host_cpu_speed;
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_total: \'' . $guest_cpu_total . '\'');
						# Convert the CPU Speed to SI
						$guest_cpu_total = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return_speed, $guest_cpu_total);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_total: \'' . $guest_cpu_total . '\'');
						
						# Exit Message CPU Total
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'CPU Total', $guest_cpu_total, $si_prefix_to_return_speed);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, " {Total $si_prefix_to_return_speed: " . Format_Number_With_Commas($guest_cpu_total) . " " . $si_prefix_to_return_speed . '}');
						} # End if (defined($perfdata_options_selected->{'CPU_Total'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Total\'})');
						} # End else {

					# cpuReservation only available on direct connected hosts v 5.0 or greater
					my $CPU_Reservation = 0;
					$target_server_type = Server_Type();
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type: \'' . $target_server_type . '\'');
					if ($target_server_type ne 'VirtualCenter') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type ne \'VirtualCenter\'');
						if ($api_version lt 5.0) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 5.0');
							Debug_Process('append', 'Line ' . __LINE__ . ' cpuReservation only available on direct connected hosts v 5.0 or greater');
							$CPU_Reservation = 1;
							} # End if ($api_version lt 5.0) {
						} # End if ($target_server_type ne 'VirtualCenter') {
					if ($CPU_Reservation == 0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $CPU_Reservation == 0');
						# Determine if CPU_Reservation should be reported
						if (defined($perfdata_options_selected->{'CPU_Reservation'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Reservation\'})');
							# Get the cpu reservation of the guest (MHz)
							Debug_Process('append', 'Line ' . __LINE__ . ' here1');
					
							my $guest_cpu_reservation = $target_guest_view->get_property('summary.config.cpuReservation');
							Debug_Process('append', 'Line ' . __LINE__ . ' here2');
					
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_reservation: \'' . $guest_cpu_reservation . '\'');
							# Convert the $guest_cpu_reservation to SI
							$guest_cpu_reservation = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return, $guest_cpu_reservation);
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_reservation: \'' . $guest_cpu_reservation . '\'');

							# Exit Message CPU Reservation
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_reservation', 'ne', $exit_state, 'CPU Reservation', $guest_cpu_reservation, $si_prefix_to_return_speed);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, " {Reservation $si_prefix_to_return_speed: " . Format_Number_With_Commas($guest_cpu_reservation) . " " . $si_prefix_to_return_speed . $message_to_add . '}');
							} # End if (defined($perfdata_options_selected->{'CPU_Reservation'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Reservation\'})');
							} # End else {
						} # End if ($CPU_Reservation == 0) {
						
					# Determine if CPU_Limit should be reported
					if (defined($perfdata_options_selected->{'CPU_Limit'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Limit\'})');
						# Get the cpu limit of the guest (MHz)
						my $guest_cpu_max = $target_guest_view->get_property('summary.runtime.maxCpuUsage');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_max: \'' . $guest_cpu_max . '\'');
						# Convert the $guest_cpu_max to SI
						$guest_cpu_max = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return, $guest_cpu_max);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_max: \'' . $guest_cpu_max . '\'');

						# Exit Message CPU Limit
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_limit', 'ne', $exit_state, 'CPU Limit', $guest_cpu_max, $si_prefix_to_return_speed);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, " {Limit $si_prefix_to_return_speed: " . Format_Number_With_Commas($guest_cpu_max) . " " . $si_prefix_to_return_speed . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'CPU_Limit'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Limit\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End if ($guest_uptime_state_flag == 0) {
				} # End if ($guest_connection_state_flag == 0) {

			return ($exit_message, $exit_state);
			} # End sub Guest_CPU_Info {


		sub Guest_CPU_Usage {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_CPU_Usage');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');

			my %Perfdata_Options = %{$_[1]};
			(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);
			
			# Get the Guest Connection State
			($guest_connection_state, $guest_connection_state_flag, $exit_message, $exit_state) = Guest_Connection_State($target_guest_view);
			
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');
				# Get the guest uptime state
				($guest_uptime_state_flag, $exit_message, $exit_state) = Guest_Uptime_State($target_guest_view);
				if ($guest_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag == 0');
					# Proceed as the guest is UP
					# Get any user supplied thresholds
					my %Thresholds_User = Thresholds_Get();
					Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
					
					# The returned perfdata will be put in here
					my $perf_data;
					
					my @instances;
					# Get the total CPU Cores in the guest
					my $guest_cpu_cores = $target_guest_view->get_property('summary.config.numCpu');
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_cores: \'' . $guest_cpu_cores . '\'');
					if ($guest_cpu_cores > 1) {
						for (my $instance = 0; $instance < $guest_cpu_cores; $instance++) {
							push @instances, $instance;
							} # End for (my $instance = 0; $instance < $guest_cpu_cores; $instance++) {
						} # End if ($guest_cpu_cores > 1) {
					push @instances, '';
					
					Debug_Process('append', 'Line ' . __LINE__ . ' Get the Perfdata');
					# Get the Perfdata
					foreach my $instance (@instances) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
						(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_guest_view, 'cpu', $instance, \@$requested_perf_counter_keys);
						# Process the Perfdata
						$perf_data->{$instance} = Perfdata_Process($perf_data_requested, $perf_counters_used);
						} # End foreach my $instance (@instances) {

					# Define the property filter for the host
					push my @target_properties, ('summary.runtime.powerState', 'summary.hardware.cpuMhz', 'summary.config.product.version');
					
					# Get the host the guest is running on
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));

					# Start exit_message
					$exit_message = '';
					
					if (defined($perfdata_options_selected->{'CPU_Free'}) or defined($perfdata_options_selected->{'CPU_Used'}) or defined($perfdata_options_selected->{'CPU_Available'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Free\'}) or defined($perfdata_options_selected->{\'CPU_Used\'}) or defined($perfdata_options_selected->{\'CPU_Available\'})');
						
						# Determine what SI to use
						my $si_prefix_to_return_speed = SI_Get('CPU_Speed', 'MHz');
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return_speed: \'' . $si_prefix_to_return_speed . '\'');
						
						# Get the total cpu in the guest (MHz)
						my $host_cpu_speed = $target_host_view->get_property('summary.hardware.cpuMhz');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_cpu_speed: \'' . $host_cpu_speed . '\'');
						my $guest_cpu_total = $guest_cpu_cores * $host_cpu_speed;
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_total: \'' . $guest_cpu_total . '\'');
						# Convert the CPU Speed to SI
						$guest_cpu_total = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return_speed, $guest_cpu_total);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_total: \'' . $guest_cpu_total . '\'');
						
						# Get the cpu used by the guest (MHz)
						my $guest_cpu_used = $perf_data->{''}->{usagemhz};
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_used: \'' . $guest_cpu_used . '\'');
						$guest_cpu_used = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return_speed, $guest_cpu_used);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_used: \'' . $guest_cpu_used . '\'');
							
						# Get the free cpu of the guest
						my $guest_cpu_free = $guest_cpu_total - $guest_cpu_used;
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_free: \'' . $guest_cpu_free . '\'');
					
						# Make sure negative numbers are accounted for
						if ($guest_cpu_free < 0) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_free < 0');
							$guest_cpu_free = 0;
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_cpu_free: \'' . $guest_cpu_free . '\'');
							} # End if ($guest_cpu_free < 0) {

						# Determine if CPU_Free should be reported
						if (defined($perfdata_options_selected->{'CPU_Free'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Free\'})');
							# Exit Message CPU Free
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_free', 'le', $exit_state, 'Total CPU Free', $guest_cpu_free, $si_prefix_to_return_speed);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, ' {Free: ' . Format_Number_With_Commas($guest_cpu_free) . " " . $si_prefix_to_return_speed . $message_to_add . '}');
							} # End if (defined($perfdata_options_selected->{'CPU_Free'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Free\'})');
							} # End else {

						# Determine if CPU_Used should be reported
						if (defined($perfdata_options_selected->{'CPU_Used'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Used\'})');
							# Exit Message CPU Used Total
							$exit_message = Build_Message($exit_message, ' {Usage');
							if ($guest_cpu_cores > 1) {
								$exit_message = Build_Message($exit_message, ': (');
								} # End if ($guest_cpu_cores == 1) {
							else {
								$exit_message = Build_Message($exit_message, ' ');
								} # End else {else {
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_used', 'ge', $exit_state, 'Total CPU Usage', $guest_cpu_used, $si_prefix_to_return_speed);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, "Total: " . Format_Number_With_Commas($guest_cpu_used) . " $si_prefix_to_return_speed" . $message_to_add);
							if ($guest_cpu_cores > 1) {
								$exit_message = Build_Message($exit_message, ')');
								} # End if ($guest_cpu_cores == 1) {
							
							if ($guest_cpu_cores > 1) {
								# Do every core
								for (my $instance = 0; $instance < $guest_cpu_cores; $instance++) {
									# Exit Message CPU Used Per Core
									($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "CPU $instance: Usage", $perf_data->{$instance}->{usagemhz}, $si_prefix_to_return_speed);
									$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
									$exit_message = Build_Message($exit_message, " (CPU $instance: " . Format_Number_With_Commas(SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return_speed, $perf_data->{$instance}->{usagemhz})) . " $si_prefix_to_return_speed)");
									} # End for (my $instance = 0; $instance < $guest_cpu_cores; $instance++) {
								} # End if ($guest_cpu_cores > 1) {
							# Add to the exit message
							$exit_message = Build_Message($exit_message, "}");
							} # End if (defined($perfdata_options_selected->{'CPU_Used'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Used\'})');
							} # End else {

						# Determine if CPU_Available should be reported
						if (defined($perfdata_options_selected->{'CPU_Available'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Available\'})');
							# Exit Message Total CPU Available
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Total Available', $guest_cpu_total, $si_prefix_to_return);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, ' {Total Available: ' . Format_Number_With_Commas($guest_cpu_total) . " " . $si_prefix_to_return . '}');
							} # End if (defined($perfdata_options_selected->{'CPU_Available'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Available\'})');
							} # End else {
						} # End if (defined($perfdata_options_selected->{'CPU_Free'}) or defined($perfdata_options_selected->{'CPU_Used'}) or defined($perfdata_options_selected->{'CPU_Available'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT (defined($perfdata_options_selected->{\'CPU_Free\'}) or defined($perfdata_options_selected->{\'CPU_Used\'}) or defined($perfdata_options_selected->{\'CPU_Available\'}))');
						} # End else {	
					
					# Determine if CPU_Ready_Time should be reported
					if (defined($perfdata_options_selected->{'CPU_Ready_Time'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Ready_Time\'})');
						# Get the host version to determine if ready counter is used
						my $host_version = $target_host_view->get_property('summary.config.product.version');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_version: \'' . $host_version . '\'');
						if ($host_version ge '3.5.0') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_version ge \'3.5.0\'');
							# Determine what SI to use
							my $si_prefix_to_return_ready_time = SI_Get('Time', 'ms');
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return_ready_time: \'' . $si_prefix_to_return_ready_time . '\'');
							
							# Exit Message Total CPU Ready Time
							$exit_message = Build_Message($exit_message, ' {Ready Time');
							if ($guest_cpu_cores > 1) {
								$exit_message = Build_Message($exit_message, ': (');
								} # End if ($guest_cpu_cores == 1) {
							else {
								$exit_message = Build_Message($exit_message, ' ');
								} # End else {else {
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_ready_time', 'ge', $exit_state, 'Total Ready Time', $perf_data->{''}->{ready}, $si_prefix_to_return_ready_time);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, 'Total: ' . Format_Number_With_Commas(SI_Process('Time', 'ms', $si_prefix_to_return_ready_time, $perf_data->{''}->{ready})) . " $si_prefix_to_return_ready_time" . $message_to_add);
							if ($guest_cpu_cores > 1) {
								$exit_message = Build_Message($exit_message, ')');
								} # End if ($guest_cpu_cores == 1) {
							
							if ($guest_cpu_cores > 1) {
								# Do every core
								for (my $instance = 0; $instance < $guest_cpu_cores; $instance++) {
									# Exit Message CPU Ready Time Per Core
									($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "CPU $instance Ready Time", $perf_data->{$instance}->{ready}, $si_prefix_to_return_ready_time);
									$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
									$exit_message = Build_Message($exit_message, " (CPU $instance: " . Format_Number_With_Commas(SI_Process('Time', 'ms', $si_prefix_to_return_ready_time, $perf_data->{$instance}->{ready})) . " $si_prefix_to_return_ready_time)");
									} # End for (my $instance = 0; $instance < $guest_cpu_cores; $instance++) {
								} # End if ($guest_cpu_cores > 1) {
							# Add to the exit message
							$exit_message = Build_Message($exit_message, "}");
							} # End if ($host_version ge '3.5.0') {
						} # End if (defined($perfdata_options_selected->{'CPU_Ready_Time'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Ready_Time\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End if ($guest_uptime_state_flag == 0) {
				} # End if ($guest_connection_state_flag == 0) {
			return ($exit_message, $exit_state);
			} # End sub Guest_CPU_Usage {


		sub Guest_Host {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Host');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');

			my $query_url = $_[1];
			my $query_username = $_[2];
			my $query_password = $_[3];

			($guest_connection_state, $guest_connection_state_flag, my $exit_message_connection_state, my $exit_state_connection_state) = Guest_Connection_State($target_guest_view);
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');

				# Check to make sure we received all the requires options
				if (!Opts::option_is_set('service_status_info')) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'service_status_info\')');
					Debug_Process('append', 'Line ' . __LINE__ . ' The --service_status_info argument was not provided, abort');
					# The --service_status_info argument was not provided, abort
					$exit_message_abort = "The --service_status_info argument was not provided, aborting!";
					$exit_state_abort = 'UNKNOWN';
					return ($exit_message_abort, $exit_state_abort);
					} # End if (!Opts::option_is_set('service_status_info')) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'service_status_info\')');

					my $service_status_info = Opts::get_option('service_status_info');
					Debug_Process('append', 'Line ' . __LINE__ . ' $service_status_info: \'' . $service_status_info . '\'');
					
					# Get the host that the guest is running on
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'summary.runtime.host\')->value: \'' . $target_guest_view->get_property('summary.runtime.host')->value . '\'');
					# Define the property filter for the host
					push my @target_properties, ('summary.runtime.powerState', 'summary.config.name');
					# Get the host
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));
					my $guest_host_name = $target_host_view->get_property('summary.config.name');
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_host_name: \'' . $guest_host_name . '\'');

					# Apply the response modifier if it exists, this is for nagios object names that are spelt differently to vCenter results
					$guest_host_name = Modifiers_Process('response', $guest_host_name);
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_host_name: \'' . $guest_host_name . '\'');

					# Get the value of the --guest argument
					my $guest_name = Opts::get_option('guest');
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_name: \'' . $guest_name . '\'');
					# Apply the request modifier if it exists
					$guest_name = Modifiers_Process('request', $guest_name);
					
					my $query_to_perform_guest = '?query=host&hostname=' . $guest_name;
					Debug_Process('append', 'Line ' . __LINE__ . ' $query_to_perform_guest: \'' . $query_to_perform_guest . '\'');

					# Run the query to get the parent_hosts
					(my $parent_hosts_array_guest, my $query_exit_status_guest, my $query_exit_message_guest) = Query_Perform('parent_hosts', $query_url, $query_username, $query_password, $query_to_perform_guest);

					# Results as per the query_exit_status_guest
					switch ($query_exit_status_guest) {
						case 'OK' {
							# Get the service status info state and value
							my @service_status_info_split = split(/=/, $service_status_info);
							Debug_Process('append', 'Line ' . __LINE__ . ' @service_status_info_split total items: \'' . scalar @service_status_info_split . '\'');
							my $service_status_info_state;
							my @service_status_info_value;
							if (scalar @service_status_info_split > 1) {
								Debug_Process('append', 'Line ' . __LINE__ . ' scalar @service_status_info_split > 0');
								$service_status_info_state = $service_status_info_split[0];
								push (@service_status_info_value, '"' . $service_status_info_split[1] . '"');
								} # End if (scalar @service_status_info_split > 1) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' scalar @service_status_info_split !> 0');
								$service_status_info_state = '';
								push (@service_status_info_value, '');
								} # End else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $service_status_info_state: \'' . $service_status_info_state . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' @service_status_info_value: \'' . $service_status_info_value[0] . '\'');

							# If the current service status exists then Determine what the current state is
							if ($service_status_info_state ne '') {
								Debug_Process('append', 'Line ' . __LINE__ . ' $service_status_info_state ne \'\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' This means that a service state was sent along with the check');
								if (scalar @$parent_hosts_array_guest > 0) {
									Debug_Process('append', 'Line ' . __LINE__ . ' scalar @$parent_hosts_array_guest > 0');
									Debug_Process('append', 'Line ' . __LINE__ . ' This means there are parents defined');
									# Make sure that the parent in the service state actually matches the real parent
									Debug_Process('append', 'Line ' . __LINE__ . ' Make sure that the parent in the service state actually matches the real parent');
									if ($service_status_info_value[0] eq '"' . $guest_host_name . '"') {
										Debug_Process('append', 'Line ' . __LINE__ . ' The parent in the service state matches the real parent');
										switch ($service_status_info_state) {
											case 'Cannot_Find_Nagios_Host_Object_-_Cannot_Define_Parent' {
												Debug_Process('append', 'Line ' . __LINE__ . ' case \'Cannot_Find_Nagios_Host_Object_-_Cannot_Define_Parent\'');
												# Determine if this has been updated in Nagios
												($exit_state, $exit_message) = Test_Parents(\@$parent_hosts_array_guest, $guest_host_name, 'Current_Parent', 'OK', 'Cannot_Find_Nagios_Host_Object_-_Cannot_Define_Parent', 'WARNING', $query_url, $query_username, $query_password);
												} # End case 'Cannot_Find_Nagios_Host_Object_-_Cannot_Define_Parent' {


											case 'Current_Parent' {
												Debug_Process('append', 'Line ' . __LINE__ . ' case \'Current_Parent\'');
												$exit_state = 'OK';
												$exit_message = 'Current_Parent=' . $guest_host_name;
												} # End case 'Current_Parent' {


											case 'Host_Object_Updated_And_Waiting_For_Nagios_Restart_-_Updated_Parent_Is' {
												Debug_Process('append', 'Line ' . __LINE__ . ' case \'Host_Object_Updated_And_Waiting_For_Nagios_Restart_-_Updated_Parent_Is\'');
												# Determine if Nagios has been restarted
												Debug_Process('append', 'Line ' . __LINE__ . ' Determine if Nagios has been restarted');
												($exit_state, $exit_message) = Test_Parents(\@$parent_hosts_array_guest, $guest_host_name, $guest_host_name, 'Current_Parent', 'OK', 'Host_Object_Updated_And_Waiting_For_Nagios_Restart_-_Updated_Parent_Is', 'WARNING', $query_url, $query_username, $query_password);
												} # End case 'Host_Object_Updated_And_Waiting_For_Nagios_Restart_-_Updated_Parent_Is' {


											case 'Incorrect_Parent_Defined_-_Should_Be' {
												Debug_Process('append', 'Line ' . __LINE__ . ' case \'Incorrect_Parent_Defined_-_Should_Be\'');
												# Determine if this has been updated in Nagios
												($exit_state, $exit_message) = Test_Parents(\@$parent_hosts_array_guest, $guest_host_name, 'Current_Parent', 'OK', 'Incorrect_Parent_Defined_-_Should_Be', 'WARNING', $query_url, $query_username, $query_password);
												} # End case 'Incorrect_Parent_Defined_-_Should_Be' {

											
											case 'No_Parent_Defined_-_Should_Be' {
												Debug_Process('append', 'Line ' . __LINE__ . ' case \'No_Parent_Defined_-_Should_Be\'');
												# Determine if this has been updated in Nagios
												($exit_state, $exit_message) = Test_Parents(\@$parent_hosts_array_guest, $guest_host_name, 'Current_Parent', 'OK', 'No_Parent_Defined_-_Should_Be', 'WARNING', $query_url, $query_username, $query_password);
												} # End case 'No_Parent_Defined_-_Should_Be' {


											else {
												Debug_Process('append', 'Line ' . __LINE__ . ' else {');
												Debug_Process('append', 'Line ' . __LINE__ . ' Status received is not a known status');
												Debug_Process('append', 'Line ' . __LINE__ . ' Determine if the host that the guest is currently running on IS one of the host parents defined');
												($exit_state, $exit_message) = Test_Parents(\@$parent_hosts_array_guest, $guest_host_name, 'Current_Parent', 'OK', 'Incorrect_Parent_Defined_-_Should_Be', 'WARNING', $query_url, $query_username, $query_password);
												} # End else {
											} # End switch ($service_status_info_state) {
										} # End if ($service_status_info_value[0] eq '"' . $guest_host_name . '"') {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' The parent in the service state DOES NOT match the real parent');
										$exit_state = 'WARNING';
										$exit_message = 'Incorrect_Parent_Defined_-_Should_Be=' . $guest_host_name;
										} # End else {
									} # End if (scalar @$parent_hosts_array_guest > 0) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' @$parent_hosts_array_guest is !> 0');
									Debug_Process('append', 'Line ' . __LINE__ . ' This means there are NO parents defined');
									Debug_Process('append', 'Line ' . __LINE__ . ' Make sure the parent host actually exists');
									# Make sure the parent host actually exists
									my $host_object_check = Test_Parent_Exists_In_Nagios($guest_host_name, $query_url, $query_username, $query_password);
									switch ($host_object_check) {
										case 'true' {
											$exit_state = 'WARNING';
											$exit_message = 'No_Parent_Defined_-_Should_Be=' . $guest_host_name;
											} # End case 'true' {

										case 'false' {
											$exit_state = 'WARNING';
											$exit_message = 'Cannot_Find_Nagios_Host_Object_Cannot_-_Define_Parent' . '=' . $guest_host_name;
											} # End case 'false' {
										} # End switch ($host_object_check) {
									} # End else {
								} # End if ($service_status_info_state ne '') {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' $service_status_info_state eq \'\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' This means that NO service state was sent along with the check');
								if (scalar @$parent_hosts_array_guest > 0) {
									Debug_Process('append', 'Line ' . __LINE__ . ' @$parent_hosts_array_guest is > 0');
									Debug_Process('append', 'Line ' . __LINE__ . ' This means there are parents defined');
									# Determine if the host that the guest is currently running on IS one of the host parents defined
									Debug_Process('append', 'Line ' . __LINE__ . ' Determine if the host that the guest is currently running on IS one of the host parents defined');
									($exit_state, $exit_message) = Test_Parents(\@$parent_hosts_array_guest, $guest_host_name, 'Current_Parent', 'OK', 'Incorrect_Parent_Defined_-_Should_Be', 'WARNING', $query_url, $query_username, $query_password);
									} # End if (scalar @$parent_hosts_array_guest > 0) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' @$parent_hosts_array_guest is !> 0');
									Debug_Process('append', 'Line ' . __LINE__ . ' This means there are NO parents defined');
									Debug_Process('append', 'Line ' . __LINE__ . ' Make sure the parent host actually exists');
									# Make sure the parent host actually exists
									my $host_object_check = Test_Parent_Exists_In_Nagios($guest_host_name, $query_url, $query_username, $query_password);
									switch ($host_object_check) {
										case 'true' {
											$exit_state = 'WARNING';
											$exit_message = 'No_Parent_Defined_-_Should_Be=' . $guest_host_name;
											} # End case 'true' {

										case 'false' {
											$exit_state = 'WARNING';
											$exit_message = 'Cannot_Find_Nagios_Host_Object_-_Cannot_Define_Parent' . '=' . $guest_host_name;
											} # End case 'false' {
										} # End switch ($host_object_check) {
									} # End else {
								} # End else {
							} # End case 'OK' {


						case 'UNKNOWN' {
							$exit_state = $query_exit_status_guest;
							$exit_message = 'Nagios objectjson.cgi Query FAILED: ' . $query_exit_message_guest;
							} # End case 'UNKNOWN' {
						} # End switch ($query_exit_status_guest) {
					} # End else {
				} # End if ($guest_connection_state_flag == 0) {
				
			return ($exit_message, $exit_state);
			} # End sub Guest_Host {


		sub Guest_Memory_Info {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Memory_Info');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');

			my %Perfdata_Options = %{$_[1]};
			my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
			
			# Get the Guest Connection State
			($guest_connection_state, $guest_connection_state_flag, $exit_message, $exit_state) = Guest_Connection_State($target_guest_view);
			
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');
				# Get the guest uptime state
				($guest_uptime_state_flag, $exit_message, $exit_state) = Guest_Uptime_State($target_guest_view);
				if ($guest_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag == 0');
					# Get any user supplied thresholds
					my %Thresholds_User = Thresholds_Get();
					Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
					
					# Determine what SI to use for the Memory_Size
					my $si_prefix_to_return_size = SI_Get('Memory_Size', 'MB');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return_size: \'' . $si_prefix_to_return_size . '\'');

					# Start exit_message
					$exit_message = '';

					# Determine if Memory_Total should be reported
					if (defined($perfdata_options_selected->{'Memory_Total'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Total\'})');
						# Get the total memory in the guest (MB)
						my $guest_memory_total = $target_guest_view->get_property('summary.config.memorySizeMB');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_total: \'' . $guest_memory_total . '\'');
						# Convert the $guest_memory_total to SI
						$guest_memory_total = SI_Process('Memory_Size', 'MB', $si_prefix_to_return_size, $guest_memory_total);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_total: \'' . $guest_memory_total . '\'');
						# Convert this to an integer
						$guest_memory_total = ceil($guest_memory_total);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_total: \'' . $guest_memory_total . '\'');
						
						# Exit Message Memory Total
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Total', $guest_memory_total, $si_prefix_to_return_size);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Total: ' . Format_Number_With_Commas($guest_memory_total) . " $si_prefix_to_return_size}");
						} # End if (defined($perfdata_options_selected->{'Memory_Total'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Total\'})');
						} # End else {

					$api_version = API_Version();
					# memoryReservation only available on direct connected hosts v 5.0 or greater
					my $Memory_Reservation = 0;
					$target_server_type = Server_Type();
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type: \'' . $target_server_type . '\'');
					if ($target_server_type ne 'VirtualCenter') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type ne \'VirtualCenter\'');
						if ($api_version lt 5.0) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 5.0');
							Debug_Process('append', 'Line ' . __LINE__ . ' memoryReservation only available on direct connected hosts v 5.0 or greater');
							$Memory_Reservation = 1;
							} # End if ($api_version lt 5.0) {
						} # End if ($target_server_type ne 'VirtualCenter') {
					if ($Memory_Reservation == 0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $Memory_Reservation == 0');
						# Determine if Memory_Reservation should be reported
						if (defined($perfdata_options_selected->{'Memory_Reservation'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Reservation\'})');
							# Get the memory reservation of the guest (MB)
							my $guest_memory_reservation = $target_guest_view->get_property('summary.config.memoryReservation');
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_reservation: \'' . $guest_memory_reservation . '\'');
							# Convert the $guest_memory_reservation to SI
							$guest_memory_reservation = SI_Process('Memory_Size', 'MB', $si_prefix_to_return_size, $guest_memory_reservation);
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_reservation: \'' . $guest_memory_reservation . '\'');
							# Convert this to an integer
							$guest_memory_reservation = ceil($guest_memory_reservation);
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_reservation: \'' . $guest_memory_reservation . '\'');
							
							# Exit Message Memory Reservation
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_reservation', 'ne', $exit_state, 'Memory Reservation', $guest_memory_reservation, $si_prefix_to_return_size);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, " {Reservation $si_prefix_to_return_size: " . Format_Number_With_Commas($guest_memory_reservation) . " " . $si_prefix_to_return_size . $message_to_add . '}');
							} # End if (defined($perfdata_options_selected->{'Memory_Reservation'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Reservation\'})');
							} # End else {
						} # End if ($Memory_Reservation == 0) {

					# Determine if Memory_Limit should be reported
					if (defined($perfdata_options_selected->{'Memory_Limit'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Limit\'})');
						# Get the memory limit the guest is allowed (MB)
						my $guest_memory_max = $target_guest_view->get_property('summary.runtime.maxMemoryUsage');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_max: \'' . $guest_memory_max . '\'');
						# Convert the $guest_memory_max to SI
						$guest_memory_max = SI_Process('Memory_Size', 'MB', $si_prefix_to_return_size, $guest_memory_max);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_max: \'' . $guest_memory_max . '\'');
						# Convert this to an integer
						$guest_memory_max = ceil($guest_memory_max);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_max: \'' . $guest_memory_max . '\'');
						
						# Exit Message Memory Limit
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_limit', 'ne', $exit_state, 'Memory Limit', $guest_memory_max, $si_prefix_to_return_size);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, " {Limit $si_prefix_to_return_size: " . Format_Number_With_Commas($guest_memory_max) . " " . $si_prefix_to_return_size . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Memory_Limit'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Limit\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End if ($guest_uptime_state_flag == 0) {
				} # End if ($guest_connection_state_flag == 0) {

			return ($exit_message, $exit_state);
			} # End sub Guest_Memory_Info {


		sub Guest_Memory_Usage {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Memory_Usage');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');

			my %Perfdata_Options = %{$_[1]};
			(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);
			
			# Get the Guest Connection State
			($guest_connection_state, $guest_connection_state_flag, $exit_message, $exit_state) = Guest_Connection_State($target_guest_view);
					
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');
				# Get the guest uptime state
				($guest_uptime_state_flag, $exit_message, $exit_state) = Guest_Uptime_State($target_guest_view);
				if ($guest_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag == 0');
					# Proceed as the guest is UP
					# Get any user supplied thresholds
					my %Thresholds_User = Thresholds_Get();
					Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
					
					# Get data via performance counters,tThe returned perfdata will be put in here
					my $perf_data;
					
					my $instance = '';
					
					# Get the Perfdata
					(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_guest_view, 'mem', $instance, \@$requested_perf_counter_keys);
					# Process the Perfdata
					$perf_data->{$instance} = Perfdata_Process($perf_data_requested, $perf_counters_used);
					
					# Determine what SI to use for the Memory_Size
					my $si_prefix_to_return_size = SI_Get('Memory_Size', 'MB');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return_size: \'' . $si_prefix_to_return_size . '\'');

					# Start exit_message
					$exit_message = 'Guest Memory';

					# Determine if Memory_Free, Memory_Consumed, Memory_Total should be reported
					if (defined($perfdata_options_selected->{'Memory_Total'}) or defined($perfdata_options_selected->{'Memory_Consumed'}) or defined($perfdata_options_selected->{'Memory_Free'})) {
						# Get the total memory in the guest (MB)
						my $guest_memory_total = $target_guest_view->get_property('summary.config.memorySizeMB');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_total: \'' . $guest_memory_total . '\'');
						# Convert the $guest_memory_total to SI
						$guest_memory_total = SI_Process('Memory_Size', 'MB', $si_prefix_to_return_size, $guest_memory_total);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_total: \'' . $guest_memory_total . '\'');
						# Convert this to an integer
						$guest_memory_total = ceil($guest_memory_total);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_total: \'' . $guest_memory_total . '\'');

						# Get the consumed memory used by the guest (kB)
						my $guest_memory_consumed = $perf_data->{$instance}->{consumed};
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_consumed: \'' . $guest_memory_consumed . '\'');
						# Convert the $guest_memory_consumed to SI
						$guest_memory_consumed = SI_Process('Memory_Size', 'kB', $si_prefix_to_return_size, $guest_memory_consumed);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_consumed: \'' . $guest_memory_consumed . '\'');
						
						# Calculate the free memory available
						my $guest_memory_free = sprintf("%.1f", ($guest_memory_total - $guest_memory_consumed));
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_free: \'' . $guest_memory_free . '\'');

						# Determine if Memory_Free should be reported
						if (defined($perfdata_options_selected->{'Memory_Free'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Free\'})');
							# Exit Message Memory Free
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_free', 'le', $exit_state, 'Memory Free', $guest_memory_free, $si_prefix_to_return_size);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, ' {Free: ' . Format_Number_With_Commas($guest_memory_free) . " $si_prefix_to_return_size" . $message_to_add . '}');
							} # End if (defined($perfdata_options_selected->{'Memory_Free'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Free\'})');
							} # End else {
						
						# Determine if Memory_Consumed should be reported
						if (defined($perfdata_options_selected->{'Memory_Consumed'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Consumed\'})');
							# Exit Message Memory Consumed
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_consumed', 'ge', $exit_state, 'Memory Consumed', $guest_memory_consumed, $si_prefix_to_return_size);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, ' {Consumed: ' . Format_Number_With_Commas($guest_memory_consumed) . " $si_prefix_to_return_size" . $message_to_add . '}');
							} # End if (defined($perfdata_options_selected->{'Memory_Consumed'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Consumed\'})');
							} # End else {

						# Determine if Memory_Total should be reported
						if (defined($perfdata_options_selected->{'Memory_Total'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Total\'})');
							# Exit Message Memory Total
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Total', $guest_memory_total, $si_prefix_to_return_size);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, ' {Total: ' . Format_Number_With_Commas($guest_memory_total) . " $si_prefix_to_return_size}");
							} # End if (defined($perfdata_options_selected->{'Memory_Total'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Total\'})');
							} # End else {
						} # End if (defined($perfdata_options_selected->{'Memory_Total'}) or defined($perfdata_options_selected->{'Memory_Free'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Total\'}) or NOT defined($perfdata_options_selected->{\'Memory_Consumed\'}) or NOT defined($perfdata_options_selected->{\'Memory_Free\'})');
						} # End else {
					
					# Determine if Memory_Ballooned should be reported
					if (defined($perfdata_options_selected->{'Memory_Ballooned'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Ballooned\'})');
						# Get memory ballooning of the guest (kB)
						my $guest_memory_ballooned = $perf_data->{$instance}->{vmmemctl};
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_ballooned: \'' . $guest_memory_ballooned . '\'');
						# Convert the $guest_memory_ballooned to SI
						$guest_memory_ballooned = SI_Process('Memory_Size', 'kB', $si_prefix_to_return_size, $guest_memory_ballooned);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_ballooned: \'' . $guest_memory_ballooned . '\'');
						
						# Exit Message Memory Ballooned
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_ballooned', 'ge', $exit_state, 'Memory Ballooned', $guest_memory_ballooned, $si_prefix_to_return_size);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Ballooned: ' . Format_Number_With_Commas($guest_memory_ballooned) . " $si_prefix_to_return_size" . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Memory_Ballooned'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Ballooned\'})');
						} # End else {
					
					# Determine if Memory_Overhead should be reported
					if (defined($perfdata_options_selected->{'Memory_Overhead'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Overhead\'})');
						# Get the memory overhead of the guest (kB)
						my $guest_memory_overhead = $perf_data->{$instance}->{overhead};
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_overhead: \'' . $guest_memory_overhead . '\'');
						# Convert the $guest_memory_overhead to SI
						$guest_memory_overhead = SI_Process('Memory_Size', 'kB', $si_prefix_to_return_size, $guest_memory_overhead);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_overhead: \'' . $guest_memory_overhead . '\'');
						
						# Exit Message Memory Overhead
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Overhead', $guest_memory_overhead, $si_prefix_to_return_size);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Overhead: ' . Format_Number_With_Commas($guest_memory_overhead) . " $si_prefix_to_return_size}");
						} # End if (defined($perfdata_options_selected->{'Memory_Overhead'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Overhead\'})');
						} # End else {
					
					# Determine if Memory_Active should be reported
					if (defined($perfdata_options_selected->{'Memory_Active'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Active\'})');
						# Get the active memory used by the guest (kB)
						my $guest_memory_active = $perf_data->{$instance}->{active};
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_active: \'' . $guest_memory_active . '\'');
						# Convert the $guest_memory_active to SI
						$guest_memory_active = SI_Process('Memory_Size', 'kB', $si_prefix_to_return_size, $guest_memory_active);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_active: \'' . $guest_memory_active . '\'');
						
						# Exit Message Memory Active
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Active', $guest_memory_active, $si_prefix_to_return_size);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Active: ' . Format_Number_With_Commas($guest_memory_active) . " $si_prefix_to_return_size}");
						} # End if (defined($perfdata_options_selected->{'Memory_Active'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Active\'})');
						} # End else {
					
					# Determine if Memory_Shared should be reported
					if (defined($perfdata_options_selected->{'Memory_Shared'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Shared\'})');
						# Get the memory shared of the guest (kB)
						my $guest_memory_shared = $perf_data->{$instance}->{shared};
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_shared: \'' . $guest_memory_shared . '\'');
						# Convert the $guest_memory_shared to SI
						$guest_memory_shared = SI_Process('Memory_Size', 'kB', $si_prefix_to_return_size, $guest_memory_shared);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_shared: \'' . $guest_memory_shared . '\'');
						
						# Exit Message Memory Shared
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Shared', $guest_memory_shared, $si_prefix_to_return_size);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Shared: ' . Format_Number_With_Commas($guest_memory_shared) . " $si_prefix_to_return_size}");
						} # End if (defined($perfdata_options_selected->{'Memory_Shared'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Shared\'})');
						} # End else {
					
					# Determine if Memory_Swap should be reported
					if (defined($perfdata_options_selected->{'Memory_Swap'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Swap\'})');
						# Define the property filter for the host
						push my @target_properties, ('summary.runtime.powerState', 'summary.config.product.version');
						
						# Get the $host_version
						($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));
						my $host_version = $target_host_view->get_property('summary.config.product.version');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_version: \'' . $host_version . '\'');
						
						# Determine which ESX(i) version so we know know what swap counters to use
						if ($host_version lt 4) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_version lt 4');
							# Get the memory swapin of the guest (kB)
							my $guest_memory_swapin = $perf_data->{$instance}->{swapin};
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapin: \'' . $guest_memory_swapin . '\'');
							# Convert the $guest_memory_swapin to SI
							$guest_memory_swapin = SI_Process('Memory_Size', 'kB', $si_prefix_to_return_size, $guest_memory_swapin);
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapin: \'' . $guest_memory_swapin . '\'');
						
							# Get the memory swapout of the guest (kB)
							my $guest_memory_swapout = $perf_data->{$instance}->{swapout};
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapout: \'' . $guest_memory_swapout . '\'');
							# Convert the $guest_memory_swapout to SI
							$guest_memory_swapout = SI_Process('Memory_Size', 'kB', $si_prefix_to_return_size, $guest_memory_swapout);
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapout: \'' . $guest_memory_swapout . '\'');
						
							# Exit Message Memory Swapped In
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_swapped', 'ge', $exit_state, 'Swapped In', $guest_memory_swapin, $si_prefix_to_return_size);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, ' {Swapped (In: ' . Format_Number_With_Commas($guest_memory_swapin) . " $si_prefix_to_return_size" . $message_to_add . ')');
							
							# Exit Message Memory Swapped Out
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_swapped', 'ge', $exit_state, 'Swapped Out', $guest_memory_swapout, $si_prefix_to_return_size);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, '(Out: ' . Format_Number_With_Commas($guest_memory_swapout) . " $si_prefix_to_return_size" . $message_to_add . ')}');
							} # End if ($host_version lt 4) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_version ge 4');
							# Determine what SI to use for the Memory_Rate
							my $si_prefix_to_return_rate = SI_Get('Memory_Rate', 'kBps');
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return_rate: \'' . $si_prefix_to_return_rate . '\'');

							# Get the memory swapinRate of the guest (kBps)
							my $guest_memory_swapin_rate = $perf_data->{$instance}->{swapinRate};
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapin_rate: \'' . $guest_memory_swapin_rate . '\'');
							# Convert the $guest_memory_swapin_rate to SI
							$guest_memory_swapin_rate = SI_Process('Memory_Rate', 'kBps', $si_prefix_to_return_rate, $guest_memory_swapin_rate);
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapin_rate: \'' . $guest_memory_swapin_rate . '\'');
						
							# Get the memory swapoutRate of the guest (kBps)
							my $guest_memory_swapout_rate = $perf_data->{$instance}->{swapoutRate};
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapout_rate: \'' . $guest_memory_swapout_rate . '\'');
							# Convert the $guest_memory_swapout_rate to SI
							$guest_memory_swapout_rate = SI_Process('Memory_Rate', 'kBps', $si_prefix_to_return_rate, $guest_memory_swapout_rate);
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_memory_swapout_rate: \'' . $guest_memory_swapout_rate . '\'');
							
							# Exit Message Memory Swap In Rate
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_swap_rate', 'ge', $exit_state, 'Swapping Rate In', $guest_memory_swapin_rate, $si_prefix_to_return_rate);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, ' {Swap Rate (In: ' . Format_Number_With_Commas($guest_memory_swapin_rate) . " $si_prefix_to_return_rate" . $message_to_add . ')');
							
							# Exit Message Memory Swap Out Rate
							($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_swap_rate', 'ge', $exit_state, 'Swapping Rate Out', $guest_memory_swapout_rate, $si_prefix_to_return_rate);
							$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
							$exit_message = Build_Message($exit_message, '(Out: ' . Format_Number_With_Commas($guest_memory_swapout_rate) . " $si_prefix_to_return_rate" . $message_to_add . ')}');
							} # End else {
						} # End if (defined($perfdata_options_selected->{'Memory_Swap'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Swap\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End if ($guest_uptime_state_flag == 0) {
				} # End if ($guest_connection_state_flag == 0) {
			return ($exit_message, $exit_state);
			} # End sub Guest_Memory_Usage {


		sub Guest_NIC {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_NIC');
			$target_guest_view = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');
			
			# Get the Guest Connection State
			($guest_connection_state, $guest_connection_state_flag, $exit_message, $exit_state) = Guest_Connection_State($target_guest_view);
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');
				# Get the guest uptime state
				($guest_uptime_state_flag, $exit_message, $exit_state) = Guest_Uptime_State($target_guest_view);
				if ($guest_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag == 0');
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[1]: \'' . $_[1] . '\'');
					# Perform the requested action
					switch ($_[1]) {
						case 'Usage' {
							# Get any user supplied thresholds
							my %Thresholds_User = Thresholds_Get();
							Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

							my %Perfdata_Options = %{$_[3]};
							(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);
							
							# The returned perfdata will be put in here
							my $perf_data;
							
							# These are the performance counters we want to get data on
							my @requested_perf_counter_keys = ('received', 'transmitted', 'packetsRx', 'packetsTx');
							
							# Determine what SI to use for NIC_Rate
							my $si_nic_rate = SI_Get('NIC_Rate', 'kBps');
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_nic_rate: \'' . $si_nic_rate . '\'');
								
							# Get all the virtual NICs
							my $guest_nic_all;
							foreach my $device (@{$target_guest_view->get_property('config.hardware.device')}) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $device: \'' . $device . '\'');
								if ($device->isa('VirtualEthernetCard')) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $device->isa(\'VirtualEthernetCard\'): \'' . $device->isa('VirtualEthernetCard') . '\'');
									$guest_nic_all->{$device->key} = $device;
									} # End if ($device->isa('VirtualEthernetCard')) {
								} # End foreach my $device (@{$target_guest_view->get_property('config.hardware.device')}) {
							
							my @instances;
							# Determine the instances to use
							if ($target_guest_view->get_property('summary.config.numEthernetCards') == 1) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'summary.config.numEthernetCards\') == 1');
								# This is the guest itself as it only has one NIC
								push @instances, '';
								} # End if ($target_guest_view->get_property('summary.config.numEthernetCards') == 1) {
							else {
								# This will be each NIC in the guest as it has more than one NIC
								foreach my $guest_nic (keys %$guest_nic_all) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $guest_nic_all->{$guest_nic}->key: \'' . $guest_nic_all->{$guest_nic}->key . '\'');
									push @instances, $guest_nic_all->{$guest_nic}->key;
									} # End foreach my $guest_nic (keys %$guest_nic_all) {
								} # End else {
							
							$api_version = API_Version();

							# Packets Data only available on VMs running on hosts v 5.0 or greater
							my $Packets_Check = 0;
							# Get the host that the guest is running on
							Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'summary.runtime.host\')->value: \'' . $target_guest_view->get_property('summary.runtime.host')->value . '\'');
							# Define the property filter for the host
							push my @target_properties, ('summary.config.product.version', 'summary.runtime.powerState');
							# Get the host
							($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));
							$api_version = $target_host_view->get_property('summary.config.product.version');
							if ($api_version lt 5.0) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 5.0');
								Debug_Process('append', 'Line ' . __LINE__ . ' Packets Data only available on direct connected hosts v 5.0 or greater');
								$Packets_Check = 1;
								} # End if ($api_version lt 5.0) {
					
							foreach my $instance (@instances) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
								# Get the Perfdata
								(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_guest_view, 'net', $instance, \@$requested_perf_counter_keys);
								# Process the Perfdata
								$perf_data->{$instance} = Perfdata_Process($perf_data_requested, $perf_counters_used);
								
								# Create the exit message
								if ($instance eq '') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $instance eq \'\'');
									# Start exit_message_to_add
									$exit_message_to_add = '';

									# Determine if NIC_Rate should be reported
									if (defined($perfdata_options_selected->{'NIC_Rate'})) {
										Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'NIC_Rate\'})');
										# Define the NIC_Rate variables
										my $nic_rx = SI_Process('NIC_Rate', 'kBps', $si_nic_rate, $perf_data->{$instance}->{received});
										Debug_Process('append', 'Line ' . __LINE__ . ' $nic_rx: \'' . $nic_rx . '\'');
										my $nic_tx = SI_Process('NIC_Rate', 'kBps', $si_nic_rate, $perf_data->{$instance}->{transmitted});
										Debug_Process('append', 'Line ' . __LINE__ . ' $nic_tx: \'' . $nic_tx . '\'');
										# Get the NIC_Rate percentages
										(my $nic_rx_percentage, my $nic_tx_percentage) = Process_Percentages($nic_rx, $nic_tx);

										# Exit Message NIC Rate Rx
										($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'nic_rate', 'ge', $exit_state, 'Rate Rx', $nic_rx, $si_nic_rate);
										$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
										$exit_message_to_add = Build_Message($exit_message_to_add, ' {Rate (Rx:' . Format_Number_With_Commas($nic_rx) . " $si_nic_rate / $nic_rx_percentage%" . $message_to_add . ')');
										
										# Exit Message NIC Rate Tx
										($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'nic_rate', 'ge', $exit_state, 'Rate Tx', $nic_tx, $si_nic_rate);
										$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
										$exit_message_to_add = Build_Message($exit_message_to_add, '(Tx:' . Format_Number_With_Commas($nic_tx) . " $si_nic_rate / $nic_tx_percentage%" . $message_to_add . ')}');
										} # End if (defined($perfdata_options_selected->{'NIC_Rate'})) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'NIC_Rate\'})');
										} # End else {
									
									if ($Packets_Check == 0) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $Packets_Check == 0');
										# Determine if NIC_Packets should be reported
										if (defined($perfdata_options_selected->{'NIC_Packets'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'NIC_Packets\'})');
											# Exit Message Packets Rx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Packets Rx', $perf_data->{$instance}->{packetsRx});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Packets (Rx:' . Format_Number_With_Commas($perf_data->{$instance}->{packetsRx}) . ')');
											
											# Exit Message Packets Tx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Packets Tx', $perf_data->{$instance}->{packetsTx});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Tx:' . Format_Number_With_Commas($perf_data->{$instance}->{packetsTx}) . ')}');
											} # End if (defined($perfdata_options_selected->{'NIC_Packets'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'NIC_Packets\'})');
											} # End else {
										} # End if ($Packets_Check == 0) {
									
									} # End if ($instance eq '') {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' $instance ne \'\'');
									# Start exit_message_to_add
									$exit_message_to_add = ' [' . $guest_nic_all->{$instance}->deviceInfo->label;
	
									# Determine if NIC_Rate should be reported
									if (defined($perfdata_options_selected->{'NIC_Rate'})) {
										Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'NIC_Rate\'})');
										# Define the NIC_Rate variables
										my $nic_rx = SI_Process('NIC_Rate', 'kBps', $si_nic_rate, $perf_data->{$instance}->{received});
										Debug_Process('append', 'Line ' . __LINE__ . ' $nic_rx: \'' . $nic_rx . '\'');
										my $nic_tx = SI_Process('NIC_Rate', 'kBps', $si_nic_rate, $perf_data->{$instance}->{transmitted});
										Debug_Process('append', 'Line ' . __LINE__ . ' $nic_tx: \'' . $nic_tx . '\'');
										# Get the NIC_Rate percentages
										(my $nic_rx_percentage, my $nic_tx_percentage) = Process_Percentages($nic_rx, $nic_tx);

										# Exit Message NIC Rate Rx
										($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'nic_rate', 'ge', $exit_state, $guest_nic_all->{$instance}->deviceInfo->label . ' Rate Rx', $nic_rx, $si_nic_rate);
										$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
										$exit_message_to_add = Build_Message($exit_message_to_add, ' {Rate (Rx:' . Format_Number_With_Commas($nic_rx) . " $si_nic_rate / $nic_rx_percentage%" . $message_to_add . ')');
										
										# Exit Message NIC Rate Tx
										($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'nic_rate', 'ge', $exit_state, $guest_nic_all->{$instance}->deviceInfo->label . ' Rate Tx', $nic_tx, $si_nic_rate);
										$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
										$exit_message_to_add = Build_Message($exit_message_to_add, '(Tx:' . Format_Number_With_Commas($nic_tx) . " $si_nic_rate / $nic_tx_percentage%" . $message_to_add . ')}');
										} # End if (defined($perfdata_options_selected->{'NIC_Rate'})) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'NIC_Rate\'})');
										} # End else {
									
									if ($Packets_Check == 0) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $Packets_Check == 0');
										# Determine if NIC_Packets should be reported
										if (defined($perfdata_options_selected->{'NIC_Packets'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'NIC_Packets\'})');
											# Exit Message Packets Rx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, $guest_nic_all->{$instance}->deviceInfo->label . ' Packets Rx', $perf_data->{$instance}->{packetsRx});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Packets (Rx:' . Format_Number_With_Commas($perf_data->{$instance}->{packetsRx}) . ')');
											
											# Exit Message Packets Tx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, $guest_nic_all->{$instance}->deviceInfo->label . ' Packets Tx', $perf_data->{$instance}->{packetsTx});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Tx:' . Format_Number_With_Commas($perf_data->{$instance}->{packetsTx}) . ')}');
											} # End if (defined($perfdata_options_selected->{'NIC_Packets'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'NIC_Packets\'})');
											} # End else {
										} # End if ($Packets_Check == 0) {
									
									# End exit_message_to_add
									$exit_message_to_add = Build_Message($exit_message_to_add, ']');
									} # End else {
								
								# Exit Message Appended
								$exit_message = Build_Message($exit_message, $exit_message_to_add, ',');
								} # End foreach my $instance (@instances) {	
							
							# Exit Message With Perfdata
							$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
							} # End case 'Usage' {
						} # End switch ($_[1]) {
					} # End if ($guest_uptime_state_flag == 0) {
				} # End if ($guest_connection_state_flag == 0) {
			
			return Process_Request_Type($_[0], $exit_message, $exit_state);
			} # End sub Guest_NIC {


		sub Guest_Select {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Select');
			$exit_state_abort = 'OK';
			
			# Get the property filter
			my @target_properties = @{$_[0]};
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Select @target_properties: \'' . @target_properties . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Select @target_properties values: \'' . join(", ", @target_properties) . '\'');
			
			# Determine if we were passed the guest name by a user argument or internally
			if ($_[1]) {
				# Passed internally
				use URI::Escape qw(uri_unescape);
				$target_guest_option = uri_unescape($_[1]);
				Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Select $target_guest_option passed internally: \'' . $target_guest_option . '\'');
				} # End if ($_[1]) {
			else {
				# Passed by a user argument
				# Need to make sure the --guest argument has been provided
				if (!Opts::option_is_set('guest')) {
					# The --guest argument was not provided, abort
					$exit_message_abort = "The --guest argument was not provided, aborting!";
					$exit_state_abort = 'UNKNOWN';
					} # End if (!Opts::option_is_set('guest')) {
				else {
					$target_guest_option = Opts::get_option('guest');
					Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Select $target_guest_option provided via --guest: \'' . $target_guest_option . '\'');

					# Apply the request modifier if it exists
					$target_guest_option = Modifiers_Process('request', $target_guest_option);

					} # End else {
				} # End else {
			
			if ($exit_state_abort ne 'UNKNOWN') {
				# Get the guest
				$target_guest_view = Vim::find_entity_view (
					view_type 	=> 'VirtualMachine',
					filter	 	=> {
						name 	=> $target_guest_option 
						},
					properties	=> [ @target_properties ]
					); # End $target_guest_view = Vim::find_entity_view (

				if (defined($target_guest_view)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');
					} # End if (defined($target_guest_view)) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'\'');
					} # End else {
				

				# Make sure we were able to find the guest
				if (!$target_guest_view) {
					# Guest was not found, aborting
					$exit_message_abort = "Guest \'" . $target_guest_option . "\' not found";
					$exit_state_abort = 'UNKNOWN';
					} # End if (!$target_guest_view) {
				} # End if ($exit_state_abort ne 'UNKNOWN') {
				
			return ($target_guest_view, $exit_message_abort, $exit_state_abort);
			} # End sub Guest_Select {

			
		sub Guest_Snapshot {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Snapshot');
			my $snapshot_request = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_request: \'' . $snapshot_request . '\'');
			
			# Perform the relevant request
			switch ($snapshot_request) {
				case 'Exclude Snapshot - Get' {
					# Determine if user supplied exclude_snapshot
					if (Opts::option_is_set('exclude_snapshot')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'exclude_snapshot\')');
						push(@Exclude_Snapshot_Supplied, split(/,/, Opts::get_option('exclude_snapshot')));
						Debug_Process('append', 'Line ' . __LINE__ . ' @Exclude_Snapshot_Supplied: \'' . @Exclude_Snapshot_Supplied . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' @Exclude_Snapshot_Supplied values: \'' . join(", ", @Exclude_Snapshot_Supplied) . '\'');
						} # End if (Opts::option_is_set('exclude_snapshot')) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' option --exclude_snapshot was NOT set');
						} # End else {
					} # End case 'Exclude Snapshot - Get' {


				case 'Exclude Snapshot - Test' {
					my $exclude_snapshot_test_value = $_[1];
					my $exclude_snapshot_test_result = 0;

					Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_snapshot_test_value: \'' . $exclude_snapshot_test_value . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_snapshot_test_result: \'' . $exclude_snapshot_test_result . '\'');
					
					if (scalar @Exclude_Snapshot_Supplied > 0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' scalar @Exclude_Snapshot_Supplied > 0');
						foreach my $exclude_snapshot_supplied_value (@Exclude_Snapshot_Supplied) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_snapshot_supplied_value: \'' . $exclude_snapshot_supplied_value . '\'');
							if ($exclude_snapshot_test_value =~ /$exclude_snapshot_supplied_value/) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_snapshot_test_value =~ /$exclude_snapshot_supplied_value/');
								Debug_Process('append', 'Line ' . __LINE__ . ' This means we are not going to report this snapshot');
								$exclude_snapshot_test_result = 1;
								} # End if ($exclude_snapshot_test_value =~ /$exclude_snapshot_supplied_value/) {
							} # End foreach my $exclude_snapshot_supplied_value (@Exclude_Snapshot_Supplied) {
						} # End if (scalar @Exclude_Snapshot_Supplied > 0) {

					Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_snapshot_test_result: \'' . $exclude_snapshot_test_result . '\'');
					
					return $exclude_snapshot_test_result;
					} # End case 'Exclude Snapshot - Test' {
					

				case 'Find Snapshot' {
					# Determine the target guest(s)
					my @targets;
					my $target_flag = 0;

					Debug_Process('append', 'Line ' . __LINE__ . ' $target_flag: \'' . $target_flag . '\'');

					# Is it just a single guest
					if (Opts::option_is_set('guest')) {
						Debug_Process('append', 'Line ' . __LINE__ . " Option: 'guest'");
						$target_flag = 1;
						# Define the guest property filter
						push my @target_properties, ('name');
						# Get the guest
						($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
						if ($exit_state_abort ne 'UNKNOWN') {
							# Add the guest to @targets
							Debug_Process('append', 'Line ' . __LINE__ . ' @targets, $target_guest_view->name: \'' . $target_guest_view->name . '\'');
							push @targets, $target_guest_view->name;
							} # End if ($exit_state_abort ne 'UNKNOWN') {
						} # End if (Opts::option_is_set('guest')) {
					
					# Is it all the guests on a host
					if (Opts::option_is_set('host')) {
						Debug_Process('append', 'Line ' . __LINE__ . " Option: 'host'");
						$target_flag = 1;
						# Define the host property filter
						push my @target_properties, ('summary.runtime.powerState', 'name');
						# Get the host
						my ($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
						if ($exit_state_abort ne 'UNKNOWN') {
							# Get all the guests on the host
							my $target_guest_views = Vim::find_entity_views (
								view_type	=> 'VirtualMachine',
								begin_entity => $target_host_view,
								properties	=> ['name'],
								); # End $target_guest_views = Vim::find_entity_view (

							Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_views: \'' . $target_guest_views . '\'');
							
							# Add the guests to @targets
							foreach (@$target_guest_views) {
								Debug_Process('append', 'Line ' . __LINE__ . ' push @targets, $_->name: \'' . $_->name . '\'');
								push @targets, $_->name;
								} # End foreach (@$target_guest_views) {
							} # End if ($exit_state_abort ne 'UNKNOWN') {
						} # End if (Opts::option_is_set('guest')) {
					
					# Is it all the guests in a cluster
					if (Opts::option_is_set('cluster')) {
						Debug_Process('append', 'Line ' . __LINE__ . " Option: 'cluster'");
						$target_flag = 1;
						# Define the cluster property filter
						push my @target_properties, ('name');
						# Get the cluster
						(my $target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
						if ($exit_state_abort ne 'UNKNOWN') {
							# Get all the guests in the cluster
							my $target_guest_views = Vim::find_entity_views (
								view_type	=> 'VirtualMachine',
								begin_entity => $target_cluster_view,
								properties	=> ['name'],
								); # End $target_guest_views = Vim::find_entity_view (

							Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_views: \'' . $target_guest_views . '\'');
							
							# Add the guests to @targets
							foreach (@$target_guest_views) {
								Debug_Process('append', 'Line ' . __LINE__ . ' push @targets, $_->name: \'' . $_->name . '\'');
								push @targets, $_->name;
								} # End foreach (@$target_guest_views) {
							} # End if ($exit_state_abort ne 'UNKNOWN') {
						} # End if (Opts::option_is_set('cluster')) {
					
					# Is it all the guests in a datacenter
					if (Opts::option_is_set('datacenter')) {
						Debug_Process('append', 'Line ' . __LINE__ . " Option: 'datacenter'");
						$target_flag = 1;
						# Define the datacenter property filter
						push my @target_properties, ('name');
						# Get the datacenter
						(my $target_datacenter_view, $exit_message_abort, $exit_state_abort) = Datacenter_Select(\@target_properties);
						if ($exit_state_abort ne 'UNKNOWN') {
							# Get all the guests in the datacenter
							my $target_guest_views = Vim::find_entity_views (
								view_type	=> 'VirtualMachine',
								begin_entity => $target_datacenter_view,
								properties	=> ['name'],
								); # End $target_guest_views = Vim::find_entity_view (

							Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_views: \'' . $target_guest_views . '\'');
							
							# Add the guests to @targets
							foreach (@$target_guest_views) {
								Debug_Process('append', 'Line ' . __LINE__ . ' push @targets, $_->name: \'' . $_->name . '\'');
								push @targets, $_->name;
								} # End foreach (@$target_guest_views) {
							} # End if ($exit_state_abort ne 'UNKNOWN') {
						} # End if (Opts::option_is_set('datacenter')) {

					Debug_Process('append', 'Line ' . __LINE__ . ' @targets: \'' . @targets . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @targets values: \'' . join(", ", @targets) . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_flag: \'' . $target_flag . '\'');

					if ($target_flag == 0) {
						$exit_state = 'UNKNOWN';
						$exit_message = 'You did not provide a snapshot target, it must be a guest, host, cluster or datacenter, aborting!';
						} # End if ($target_flag == 0) {
					else {
						if ($exit_state_abort ne 'UNKNOWN') {
							# Check to see if any targets were found
							if (@targets) {
								# Get any user supplied thresholds
								my %Thresholds_User = Thresholds_Get();
								Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

								# Define the guest property filter
								push my @target_properties, ('name', 'snapshot', 'layoutEx.file');
								
								# Process each guest
								foreach my $target (@targets) {
									# Get the guest
									($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties, $target);
									my $target_guest_name = $target_guest_view->name;

									Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_name: \'' . $target_guest_name . '\'');
									
									# Check for any snapshots
									if (defined($target_guest_view->snapshot)) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->snapshot: \'' . $target_guest_view->snapshot . '\'');
										# Process the Root Snapshot List
										Guest_Snapshot('Process Root Snapshot List', $target_guest_view);
										
										# Find the oldest snapshot
										my $oldest_snapshot;
										my $snapshot_name;
										# Loop through each snapshot this guest has
										foreach my $snapshot_id (keys %{$snapshot_info_all->{$target_guest_name}}) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_id: \'' . $snapshot_id . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_name: \'' . $target_guest_name . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{id}: \'' . $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{id} . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{name}: \'' . $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{name} . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{createTime}: \'' . $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{createTime} . '\'');
											
											# Check to see if $oldest_snapshot is defined
											if (!defined($oldest_snapshot)) {
												# Not defined so assign the values
												$oldest_snapshot = $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{id};
												$snapshot_name = $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{name};
												Debug_Process('append', 'Line ' . __LINE__ . ' $oldest_snapshot: \'' . $oldest_snapshot . '\'');
												Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_name: \'' . $snapshot_name . '\'');
												} # End if (!defined($oldest_snapshot)) {
											else {
												# We need to check if the currently defined $oldest_snapshot is actually the oldest
												if ($snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{createTime} lt $snapshot_info_all->{$target_guest_name}->{$oldest_snapshot}->{createTime}) {
													Debug_Process('append', 'Line ' . __LINE__ . ' id \'' . $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{id} . '\'  \'' . $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{createTime} . "' is OLDER than id \'$oldest_snapshot\' '" . $snapshot_info_all->{$target_guest_name}->{$oldest_snapshot}->{createTime} . '\'');
													
													# This snapshot is older so assign the values
													$oldest_snapshot = $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{id};
													$snapshot_name = $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{name};
													} # End if ($snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{createTime} lt $snapshot_info_all->{$target_guest_name}->{$oldest_snapshot}->{createTime}) {
												else {
													# This snapshot is newer so ignore
													Debug_Process('append', 'Line ' . __LINE__ . ' id \'' . $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{id} . '\' \'' . $snapshot_info_all->{$target_guest_name}->{$snapshot_id}->{createTime} . "' is NEWER than id \'$oldest_snapshot\' '" . $snapshot_info_all->{$target_guest_name}->{$oldest_snapshot}->{createTime} . '\'');
													} # End else {
												} # End else {
											} # End foreach my $snapshot_id (keys %{$snapshot_info_all->{$target_guest_name}}) {
									
										# Check to see if this snapshot should be excluded from the results
										my $exclude_snapshot_test_result = Guest_Snapshot('Exclude Snapshot - Test', $snapshot_name);
										Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_snapshot_test_result: \'' . $exclude_snapshot_test_result . '\'');
										if ($exclude_snapshot_test_result == 0) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_snapshot_test_result == 0');
											# Calculate the age of the snapshot
											my $time_difference = sprintf("%0.f", ((localtime->epoch - str2time($snapshot_info_all->{$target_guest_view->name}->{$oldest_snapshot}->{createTime})) / 86400));

											Debug_Process('append', 'Line ' . __LINE__ . ' $time_difference before check: \'' . $time_difference . '\'');
											
											# Check to make sure this isn't -0
											if ($time_difference == -0) {
												$time_difference = 0;
												} # End if ($time_difference == -0) {

											Debug_Process('append', 'Line ' . __LINE__ . ' $time_difference after check: \'' . $time_difference . '\'');
											
											# Exit Message checking snapshot age
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'snapshot_age', 'ge', $exit_state, "$target_guest_name Snapshot Age", $time_difference);
											$exit_message_to_add = "[\'$target_guest_name\' (Notes: $snapshot_name) (Age: $time_difference" . $message_to_add . ")]";
											
											# Add to the Exit Message
											$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
											} # End if ($exclude_snapshot_test_result == 0) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' EXCLUDING the snapshot: \'' . $snapshot_name . '\'');
											} # End else {
										} # End if (defined($target_guest_view->snapshot)) {
									} # End foreach my $target (@targets) {	
								} # End if (@targets) {
								
								# Check to see if no snapshots were found
								if (!defined($exit_message)) {
									# Create the Exit Message
									$exit_message = Build_Exit_Message('Exit', $exit_message, 'No snapshots found');
									$exit_state = 'OK';
									} # End if (!defined($exit_message)) {
							} # End if ($exit_state_abort ne 'UNKNOWN') {
						else {
							$exit_state = $exit_state_abort;
							$exit_message = $exit_message_abort;
							} # End else {
						} # End else {
					return ($exit_message, $exit_state);
					} # End case 'Find Snapshot' {
				
				
				case 'Gather Snapshot Info' {
					my $snapshot_item = $_[1];
					Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_item: \'' . $snapshot_item . '\'');

					# Define the hash we will add the values to
					my $info_to_return;
					
					# Add the snapshot id to the hash
					$info_to_return->{id} = $snapshot_item->id;
					Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_item->id: \'' . $snapshot_item->id . '\'');
					
					# Add the snapshot name to the hash
					$info_to_return->{name} = $snapshot_item->name;
					Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_item->name: \'' . $snapshot_item->name . '\'');

					# Add the snapshot createTime to the hash
					$info_to_return->{createTime} = $snapshot_item->createTime;
					Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_item->createTime: \'' . $snapshot_item->createTime . '\'');
					
					return $info_to_return;
					} # End case 'Gather Snapshot Info' {
				
				
				case 'Process Root Snapshot List' {
					my $target_guest_view = $_[1];			
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');
					# Get the root_snapshot_list
					my $root_snapshot_list = $target_guest_view->snapshot->rootSnapshotList;
					Debug_Process('append', 'Line ' . __LINE__ . ' $root_snapshot_list: \'' . $root_snapshot_list . '\'');
					# Loop through the list
					foreach my $snapshot_list_item (@$root_snapshot_list) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_list_item: \'' . $snapshot_list_item . '\'');
						# Add the snapshot info to $snapshot_info_all
						$snapshot_info_all->{$target_guest_view->name}{$snapshot_list_item->id} = Guest_Snapshot('Gather Snapshot Info', $snapshot_list_item);
						
						# Check for child snapshots
						if (defined($snapshot_list_item->childSnapshotList)) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_list_item->childSnapshotList: \'' . $snapshot_list_item->childSnapshotList . '\'');
							# Process the child snapshots
							Guest_Snapshot('Process Child Snapshot List', $snapshot_list_item->childSnapshotList, $target_guest_view->name);
							} # End if (defined($snapshot_list_item->childSnapshotList)) {
						} # End foreach my $snapshot_list_item (@$root_snapshot_list) {
					} # End case 'Process Root Snapshot List' {
				
				
				case 'Process Child Snapshot List' {
					my $child_snapshot_list = $_[1];			
					Debug_Process('append', 'Line ' . __LINE__ . ' $child_snapshot_list: \'' . $child_snapshot_list . '\'');
					
					my $guest_name = $_[2];			
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_name: \'' . $guest_name . '\'');
					
					# Loop through the list
					foreach my $snapshot_list_item (@$child_snapshot_list) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_list_item: \'' . $snapshot_list_item . '\'');
						# Add the snapshot info to $snapshot_info_all
						$snapshot_info_all->{$guest_name}{$snapshot_list_item->id} = Guest_Snapshot('Gather Snapshot Info', $snapshot_list_item);
						
						# Check for child snapshots
						if (defined($snapshot_list_item->childSnapshotList)) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_list_item->childSnapshotList: \'' . $snapshot_list_item->childSnapshotList . '\'');
							# Process the child snapshots
							Guest_Snapshot('Process Child Snapshot List', $snapshot_list_item->childSnapshotList, $guest_name);
							} # End if (defined($snapshot_list_item->childSnapshotList)) {
						} # End foreach my $snapshot_list_item (@$child_snapshot_list) {
					} # End case 'Process Child Snapshot List' {
					
				
				case 'Space Used' {
					$target_guest_view = $_[1];
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');

					# Check to see if the VM has any snapshots
					if (defined $target_guest_view->snapshot) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined $target_guest_view->snapshot');

						# Calculate the total space used by snapshot files (B)
						my $snapshot_total_space_used = 0;
						Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_total_space_used: \'' . $snapshot_total_space_used . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' Loop through all the VM files');
						# Loop through all the VM files
						foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->name: \'' . $file_hash->name . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' $file_hash->size: \'' . $file_hash->size . '\'');
							# Look for the files we want
							switch ($file_hash->name) {
								case /(delta.vmdk)$/ {
									Debug_Process('append', 'Line ' . __LINE__ . 'delta.vmdk');
									# This is a snapshot delta file
									$snapshot_total_space_used = $snapshot_total_space_used + $file_hash->size;
									Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_total_space_used: \'' . $snapshot_total_space_used . '\'');
									} # End case /(delta.vmdk)$/ {
								
								case /(.vmsn)$/ {
									Debug_Process('append', 'Line ' . __LINE__ . '.vmsn');
									# This is a snapshot memory state file
									$snapshot_total_space_used = $snapshot_total_space_used + $file_hash->size;
									Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_total_space_used: \'' . $snapshot_total_space_used . '\'');
									} # End case /(.vmsn)$/ {
								} # End switch ($file_hash->name) {
							} # End foreach my $file_hash (@{$target_guest_view->get_property('layoutEx.file')}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $snapshot_total_space_used: \'' . $snapshot_total_space_used . '\'');
						return $snapshot_total_space_used;
						} # End if (defined $target_guest_view->snapshot) {
					} # End case 'Space Used' {
				
				} # End switch ($snapshot_request) {
			} # End sub Guest_Snapshot {
		
		
		sub Guest_Status {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Status');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');
			
			($guest_connection_state, $guest_connection_state_flag, my $exit_message_connection_state, my $exit_state_connection_state) = Guest_Connection_State($target_guest_view);
			# Proceed if the guest is connected
			if ($guest_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_connection_state_flag == 0');

				# Get any user supplied thresholds
				my %Thresholds_User = Thresholds_Get();
				Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
					
				# Get the guest uptime state
				($guest_uptime_state_flag, my $exit_message_uptime_state, my $exit_state_uptime_state) = Guest_Uptime_State($target_guest_view);
				
				# Get the guest power state
				my $guest_power_state = $target_guest_view->get_property('summary.runtime.powerState')->val;
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_power_state: \'' . $guest_power_state . '\'');
				
				# Get the guest power state options
				my %Guest_Power_State_Options;
				if (Opts::option_is_set('guest_power_state')) {
					Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'guest_power_state\')');
					my @power_state_options = split(/,/, Opts::get_option('guest_power_state'));
					Debug_Process('append', 'Line ' . __LINE__ . ' @power_state_options: \'' . @power_state_options . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @power_state_options values: \'' . join(", ", @power_state_options) . '\'');
					foreach my $power_state_item (@power_state_options) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $power_state_item: \'' . $power_state_item . '\'');
						my @power_state_item_split = split(/:/, $power_state_item);
						Debug_Process('append', 'Line ' . __LINE__ . ' @power_state_item_split: \'' . @power_state_item_split . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' @power_state_item_split values: \'' . join(", ", @power_state_item_split) . '\'');
						if (defined($power_state_item_split[0])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($power_state_item_split[0])');
							Debug_Process('append', 'Line ' . __LINE__ . ' $power_state_item_split[0]: \'' . $power_state_item_split[0] . '\'');
							if ($power_state_item_split[0] =~ /^(poweredOn|poweredOff|suspended)$/) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $power_state_item_split[0] =~ /^(poweredOn|poweredOff|suspended)$/');
								if (defined($power_state_item_split[1])) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($power_state_item_split[1])');
									Debug_Process('append', 'Line ' . __LINE__ . ' $power_state_item_split[1]: \'' . $power_state_item_split[1] . '\'');
									if ($power_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $power_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/');
										$Guest_Power_State_Options{$power_state_item_split[0]} = $power_state_item_split[1];
										Debug_Process('append', 'Line ' . __LINE__ . ' $Guest_Power_State_Options{$power_state_item_split[0]}: \'' . $Guest_Power_State_Options{$power_state_item_split[0]} . '\'');
										} # End if ($power_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/) {
									} # End if (defined($power_state_item_split[1])) {
								} # End if ($power_state_item_split[0] =~ /^(poweredOn|poweredOff|suspended)$/) {
							} # End if (defined($power_state_item_split[0])) {
						} # End foreach my $power_state_item (@power_state_options) {
					} # End if (Opts::option_is_set('guest_power_state')) {
				
				# Define any guest power state options that were not set
				if (!defined($Guest_Power_State_Options{'poweredOn'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Power_State_Options{\'poweredOn\'})');
					$Guest_Power_State_Options{'poweredOn'} = 'OK';
					} # End if (!defined($Guest_Power_State_Options{'poweredOn'})) {
				
				if (!defined($Guest_Power_State_Options{'poweredOff'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Power_State_Options{\'poweredOff\'})');
					$Guest_Power_State_Options{'poweredOff'} = 'CRITICAL';
					} # End if (!defined($Guest_Power_State_Options{'poweredOff'})) {
				
				if (!defined($Guest_Power_State_Options{'suspended'})) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Power_State_Options{\'suspended\'})');
					$Guest_Power_State_Options{'suspended'} = 'CRITICAL';
					} # End if (!defined($Guest_Power_State_Options{'suspended'})) {

				Debug_Process('append', 'Line ' . __LINE__ . ' $Guest_Power_State_Options{$guest_power_state}: \'' . $Guest_Power_State_Options{$guest_power_state} . '\'');
				
				# Start the Exit Message
				if ($Guest_Power_State_Options{$guest_power_state} ne 'OK') {
					$exit_message = '{State: ' . $guest_power_state . ' (' . $Guest_Power_State_Options{$guest_power_state} . ')}';
					} # End if ($Guest_Power_State_Options{$guest_power_state} ne 'OK') {
				else {
					$exit_message = '{State: ' . $guest_power_state . '}';
					} # End else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');

				# Build the Exit State
				$exit_state = Build_Exit_State('', $Guest_Power_State_Options{$guest_power_state});
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');		

				$api_version = API_Version();
							
				if ($guest_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag == 0');
					# Uptime only available since vSphere API 4.1
					if ($api_version ge 4.1) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $api_version ge 4.1');
						# Get the SI to be used for Uptime
						my $si_prefix_to_return_time = SI_Get('Time', 'd');
						
						# Get the Uptime
						my $guest_uptime = $target_guest_view->get_property('summary.quickStats.uptimeSeconds');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime: \'' . $guest_uptime . '\'');
						# Convert the Uptime to SI
						$guest_uptime = SI_Process('Time', 's', $si_prefix_to_return_time, $guest_uptime);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime: \'' . $guest_uptime . '\'');
						# Convert this to an integer
						$guest_uptime = ceil($guest_uptime);
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime: \'' . $guest_uptime . '\'');

						# Determine if any Uptime thresholds were triggered
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'guest_uptime', 'le', $exit_state, 'Uptime', $guest_uptime);
						$exit_message = Build_Message($exit_message, ' {Uptime: ' . $guest_uptime . ' ' . $si_prefix_to_return_time . $message_to_add . '}');
						} # End if ($api_version ge 4.1) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 4.1');
						# Uptime only available in vSphere API 4.1 onwards
						} # End else {
					
					# Get the Tools Running Status
					my $guest_tools_running_status = $target_guest_view->get_property('summary.guest.toolsRunningStatus');
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_tools_running_status: \'' . $guest_tools_running_status . '\'');
					
					# Get the guest tools version state options
					my %Guest_Tools_Version_State_Options;
					if (Opts::option_is_set('guest_tools_version_state')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'guest_tools_version_state\')');
						my @tools_version_state_options = split(/,/, Opts::get_option('guest_tools_version_state'));
						Debug_Process('append', 'Line ' . __LINE__ . ' @tools_version_state_options: \'' . @tools_version_state_options . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' @tools_version_state_options values: \'' . join(", ", @tools_version_state_options) . '\'');
						foreach my $tools_version_state_item (@tools_version_state_options) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $tools_version_state_item: \'' . $tools_version_state_item . '\'');
							my @tools_version_state_item_split = split(/:/, $tools_version_state_item);
							Debug_Process('append', 'Line ' . __LINE__ . ' @tools_version_state_item_split: \'' . @tools_version_state_item_split . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' @tools_version_state_item_split values: \'' . join(", ", @tools_version_state_item_split) . '\'');
							if (defined($tools_version_state_item_split[0])) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($tools_version_state_item_split[0])');
								Debug_Process('append', 'Line ' . __LINE__ . ' $tools_version_state_item_split[0]: \'' . $tools_version_state_item_split[0] . '\'');
								if ($tools_version_state_item_split[0] =~ /^(guestToolsBlacklisted|guestToolsCurrent|guestToolsNeedUpgrade|guestToolsNotRunning|guestToolsSupportedNew|guestToolsSupportedOld|guestToolsTooNew|guestToolsTooOld|guestToolsUnmanaged)$/) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $tools_version_state_item_split[0] =~ /^(poweredOn|poweredOff|suspended)$/');
									if (defined($tools_version_state_item_split[1])) {
										Debug_Process('append', 'Line ' . __LINE__ . ' defined($tools_version_state_item_split[1])');
										Debug_Process('append', 'Line ' . __LINE__ . ' $tools_version_state_item_split[1]: \'' . $tools_version_state_item_split[1] . '\'');
										if ($tools_version_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $tools_version_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/');
											$Guest_Tools_Version_State_Options{$tools_version_state_item_split[0]} = $tools_version_state_item_split[1];
											Debug_Process('append', 'Line ' . __LINE__ . ' $Guest_Tools_Version_State_Options{$tools_version_state_item_split[0]}: \'' . $Guest_Tools_Version_State_Options{$tools_version_state_item_split[0]} . '\'');
											} # End if ($tools_version_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/) {
										} # End if (defined($tools_version_state_item_split[1])) {
									} # End if ($tools_version_state_item_split[0] =~ /^(guestToolsBlacklisted|guestToolsCurrent|guestToolsNeedUpgrade|guestToolsNotRunning|guestToolsSupportedNew|guestToolsSupportedOld|guestToolsTooNew|guestToolsTooOld|guestToolsUnmanaged)$/) {
								} # End if (defined($tools_version_state_item_split[0])) {
							} # End foreach my $tools_version_state_item (@tools_version_state_options) {
						} # End if (Opts::option_is_set('guest_tools_version_state')) {
					
					# Define any guest tools version state options that were not set
					if (!defined($Guest_Tools_Version_State_Options{'guestToolsBlacklisted'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsBlacklisted\'})');
						$Guest_Tools_Version_State_Options{'guestToolsBlacklisted'} = 'CRITICAL';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsBlacklisted'})) {
					
					if (!defined($Guest_Tools_Version_State_Options{'guestToolsCurrent'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsCurrent\'})');
						$Guest_Tools_Version_State_Options{'guestToolsCurrent'} = 'OK';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsCurrent'})) {
					
					if (!defined($Guest_Tools_Version_State_Options{'guestToolsNeedUpgrade'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsNeedUpgrade\'})');
						$Guest_Tools_Version_State_Options{'guestToolsNeedUpgrade'} = 'WARNING';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsNeedUpgrade'})) {

					if (!defined($Guest_Tools_Version_State_Options{'guestToolsNotRunning'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsNotRunning\'})');
						$Guest_Tools_Version_State_Options{'guestToolsNotRunning'} = 'CRITICAL';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsNotRunning'})) {

					if (!defined($Guest_Tools_Version_State_Options{'guestToolsSupportedNew'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsSupportedNew\'})');
						$Guest_Tools_Version_State_Options{'guestToolsSupportedNew'} = 'OK';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsSupportedNew'})) {

					if (!defined($Guest_Tools_Version_State_Options{'guestToolsSupportedOld'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsSupportedOld\'})');
						$Guest_Tools_Version_State_Options{'guestToolsSupportedOld'} = 'WARNING';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsSupportedOld'})) {

					if (!defined($Guest_Tools_Version_State_Options{'guestToolsTooNew'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsTooNew\'})');
						$Guest_Tools_Version_State_Options{'guestToolsTooNew'} = 'CRITICAL';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsTooNew'})) {

					if (!defined($Guest_Tools_Version_State_Options{'guestToolsTooOld'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsTooOld\'})');
						$Guest_Tools_Version_State_Options{'guestToolsTooOld'} = 'CRITICAL';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsTooOld'})) {
					
					if (!defined($Guest_Tools_Version_State_Options{'guestToolsUnmanaged'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Tools_Version_State_Options{\'guestToolsUnmanaged\'})');
						$Guest_Tools_Version_State_Options{'guestToolsUnmanaged'} = 'OK';
						} # End if (!defined($Guest_Tools_Version_State_Options{'guestToolsUnmanaged'})) {
					
					$exit_message = Build_Message($exit_message, ' {Tools');
					
					if ($guest_tools_running_status eq 'guestToolsRunning') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_tools_running_status eq \'guestToolsRunning\'');

						# Get the Tools Version
						my $guest_tools_version = $target_guest_view->get_property('guest.toolsVersion');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_tools_version: \'' . $guest_tools_version . '\'');
						
						$exit_message = Build_Message($exit_message, ' (Version: ' . $guest_tools_version . ')');
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
						
						# Get the Tools Version Status
						my $guest_tools_version_status_original = $target_guest_view->get_property('summary.guest.toolsVersionStatus2');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_tools_version_status_original: \'' . $guest_tools_version_status_original . '\'');

						Debug_Process('append', 'Line ' . __LINE__ . ' $Guest_Tools_Version_State_Options{$guest_power_state}: \'' . $Guest_Tools_Version_State_Options{$guest_tools_version_status_original} . '\'');
						
						if ($Guest_Tools_Version_State_Options{$guest_tools_version_status_original} ne 'OK') {
							$exit_message_to_add = ' (Status: ' . $guest_tools_version_status_original . ' (' . $Guest_Tools_Version_State_Options{$guest_tools_version_status_original} . '))}';
							} # End if ($Guest_Tools_Version_State_Options{$guest_tools_version_status_original} ne 'OK') {
						else {
							$exit_message_to_add = ' (Status: ' . $guest_tools_version_status_original . ')}';
							} # End else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_to_add: \'' . $exit_message_to_add . '\'');
											
						$exit_message = Build_Message($exit_message, $exit_message_to_add);
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
						
						# Build the Exit State
						$exit_state = Build_Exit_State($exit_state, $Guest_Tools_Version_State_Options{$guest_tools_version_status_original});
						Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
									
						# Get the Guest IP Address
						my $guest_tools_ip_address;
						if (defined($target_guest_view->{'summary.guest.ipAddress'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($target_guest_view->{\'summary.guest.ipAddress\'})');
							$guest_tools_ip_address = $target_guest_view->get_property('summary.guest.ipAddress');
							} # End if (defined($target_guest_view->{'summary.guest.ipAddress'})) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' !defined($target_guest_view->{\'summary.guest.ipAddress\'})');
							
							# Guest might have an IPv6 address or not be bound on the primary adapter, lets loop through them all
							if (defined($target_guest_view->{'guest.net'})) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($target_guest_view->{\'guest.net\'})');
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'guest.net\'): ' . $target_guest_view->get_property('guest.net') . '\'');
								foreach my $guest_nic (@{$target_guest_view->get_property('guest.net')}) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $guest_nic: ' . $guest_nic . '\'');
									#Debug_Process('append', 'Line ' . __LINE__ . ' $guest_nic->ipConfig->ipAddress: ' . $guest_nic->ipConfig->ipAddress . '\'');
									foreach my $guest_nic_ip_address (@{$guest_nic->ipConfig->ipAddress}) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $guest_nic_ip_address: ' . $guest_nic_ip_address . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $guest_nic_ip_address->ipAddress: ' . $guest_nic_ip_address->ipAddress . '\'');
										$guest_tools_ip_address = Build_Message($guest_tools_ip_address, $guest_nic_ip_address->ipAddress, ', ')
										} # End foreach my $guest_nic_ip_address (@{$guest_nic->ipConfig->ipAddress}) {
									} # End foreach my $guest_nic (@{$target_guest_view->get_property('guest.net')}) {
								} # End if (defined($target_guest_view->{'guest.net'})) {
							# Last check to see if there is an address
							if (!defined($guest_tools_ip_address)) {
								$guest_tools_ip_address = 'Not Defined';
								} # End if (!defined($guest_tools_ip_address)) {
							} # End else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_tools_ip_address: \'' . $guest_tools_ip_address . '\'');
						
						# Get the Guest Local Host Name
						my $guest_local_host_name = $target_guest_view->get_property('summary.guest.hostName');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_local_host_name: \'' . $guest_local_host_name . '\'');
						
						$exit_message = Build_Message($exit_message, ' {IP Address: ' . $guest_tools_ip_address . '} {Guest Hostname: ' . $guest_local_host_name . '}');
						} # End if ($guest_tools_running_status eq 'guestToolsRunning') {
					else {
						if ($guest_tools_running_status eq 'guestToolsNotRunning') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_tools_running_status eq \'guestToolsNotRunning\'');
							$exit_message_to_add = ' (Status: ' . $guest_tools_running_status . ' (' . $Guest_Tools_Version_State_Options{$guest_tools_running_status} . '))}';
							$exit_message = Build_Message($exit_message, $exit_message_to_add);
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
							# Build the Exit State
							$exit_state = Build_Exit_State($exit_state, $Guest_Tools_Version_State_Options{$guest_tools_running_status});
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
							} # End if ($guest_tools_running_status eq 'guestToolsNotRunning') {
						} # End else {
					} # End if ($guest_uptime_state_flag == 0) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime_state_flag != 0');
					} # End else {
				
				# Get the host that the guest is running on
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'summary.runtime.host\')->value: \'' . $target_guest_view->get_property('summary.runtime.host')->value . '\'');
				# Define the property filter for the host
				push my @target_properties, ('summary.runtime.powerState', 'summary.config.name', 'summary.config.product.version');
				# Get the host
				($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties, $target_guest_view->get_property('summary.runtime.host'));
				my $guest_host_name = $target_host_view->get_property('summary.config.name');
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_host_name: \'' . $guest_host_name . '\'');
				$exit_message = Build_Message($exit_message, ' {Host: ' . $guest_host_name . '}');

				# consolidationNeeded only available in vSphere API 5.0 onwards
				if ($api_version ge 5.0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $api_version ge 5.0');
					# consolidationNeeded only available on VMs running on hosts v 5.0 or greater
					$api_version = $target_host_view->get_property('summary.config.product.version');
					if ($api_version lt 5.0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 5.0');
						Debug_Process('append', 'Line ' . __LINE__ . ' consolidationNeeded only available on direct connected hosts v 5.0 or greater');
						} # End if ($api_version lt 5.0) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $api_version ge 5.0');
						# Get the consolidation state
						my $guest_consolidation_needed = $target_guest_view->get_property('summary.runtime.consolidationNeeded');
						Debug_Process('append', 'Line ' . __LINE__ . ' $guest_consolidation_needed: \'' . $guest_consolidation_needed . '\'');

						# Get the guest consolidation state options
						my %Guest_Consolidation_State_Options;
						if (Opts::option_is_set('guest_consolidation_state')) {
							Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'guest_consolidation_state\')');
							my @consolidation_state_options = split(/,/, Opts::get_option('guest_consolidation_state'));
							Debug_Process('append', 'Line ' . __LINE__ . ' @consolidation_state_options: \'' . @consolidation_state_options . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' @consolidation_state_options values: \'' . join(", ", @consolidation_state_options) . '\'');
							foreach my $power_state_item (@consolidation_state_options) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $power_state_item: \'' . $power_state_item . '\'');
								my @consolidation_state_item_split = split(/:/, $power_state_item);
								Debug_Process('append', 'Line ' . __LINE__ . ' @consolidation_state_item_split: \'' . @consolidation_state_item_split . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' @consolidation_state_item_split values: \'' . join(", ", @consolidation_state_item_split) . '\'');
								if (defined($consolidation_state_item_split[0])) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($consolidation_state_item_split[0])');
									Debug_Process('append', 'Line ' . __LINE__ . ' $consolidation_state_item_split[0]: \'' . $consolidation_state_item_split[0] . '\'');
									if ($consolidation_state_item_split[0] =~ /^(true|false)$/) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $consolidation_state_item_split[0] =~ /^(poweredOn|poweredOff|suspended)$/');
										if (defined($consolidation_state_item_split[1])) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($consolidation_state_item_split[1])');
											Debug_Process('append', 'Line ' . __LINE__ . ' $consolidation_state_item_split[1]: \'' . $consolidation_state_item_split[1] . '\'');
											if ($consolidation_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $consolidation_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/');
												$Guest_Consolidation_State_Options{$consolidation_state_item_split[0]} = $consolidation_state_item_split[1];
												Debug_Process('append', 'Line ' . __LINE__ . ' $Guest_Consolidation_State_Options{$consolidation_state_item_split[0]}: \'' . $Guest_Consolidation_State_Options{$consolidation_state_item_split[0]} . '\'');
												} # End if ($consolidation_state_item_split[1] =~ /^(OK|WARNING|CRITICAL)$/) {
											} # End if (defined($consolidation_state_item_split[1])) {
										} # End if ($consolidation_state_item_split[0] =~ /^(true|false)$/) {
									} # End if (defined($consolidation_state_item_split[0])) {
								} # End foreach my $power_state_item (@consolidation_state_options) {
							} # End if (Opts::option_is_set('guest_consolidation_state')) {
						
						# Define any guest consolidation state options that were not set
						if (!defined($Guest_Consolidation_State_Options{'true'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Consolidation_State_Options{\'true\'})');
							$Guest_Consolidation_State_Options{'true'} = 'CRITICAL';
							} # End if (!defined($Guest_Consolidation_State_Options{'true'})) {
						
						if (!defined($Guest_Consolidation_State_Options{'false'})) {
							Debug_Process('append', 'Line ' . __LINE__ . ' !defined($Guest_Consolidation_State_Options{\'false\'})');
							$Guest_Consolidation_State_Options{'false'} = 'OK';
							} # End if (!defined($Guest_Consolidation_State_Options{'false'})) {
						
						# Build the Exit Message
						if ($guest_consolidation_needed == 1) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_consolidation_needed == 1');
							Debug_Process('append', 'Line ' . __LINE__ . ' $Guest_Consolidation_State_Options{$guest_consolidation_needed}: \'' . $Guest_Consolidation_State_Options{$guest_consolidation_needed} . '\'');
							$exit_message = Build_Message($exit_message, ' {Consolidation Needed: YES (' . $Guest_Consolidation_State_Options{$guest_consolidation_needed} . ')}');
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
							
							# Build the Exit State
							$exit_state = Build_Exit_State($exit_state, $Guest_Consolidation_State_Options{$guest_consolidation_needed});
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
							} # End if ($guest_consolidation_needed == 1) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_consolidation_needed != 1');
							$exit_message = Build_Message($exit_message, ' {Consolidation Needed: NO}');
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
							
							# Build the Exit State
							$exit_state = Build_Exit_State($exit_state, $Guest_Consolidation_State_Options{$guest_consolidation_needed});
							Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
							} # End else {
						} # End else {
					} # End if ($api_version ge 5.0) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 5.0');
					# consolidationNeeded only available in vSphere API 5.0 onwards
					} # End else {
				
				# Get the Guest VM Version
				my $guest_vm_version = $target_guest_view->get_property('config.version');
				Debug_Process('append', 'Line ' . __LINE__ . ' $guest_vm_version: \'' . $guest_vm_version . '\'');
				$exit_message = Build_Message($exit_message, ' {Guest Version: ' . $guest_vm_version . '}');		
				} # End if ($guest_connection_state_flag == 0) {
			
			return ($exit_message, $exit_state);
			} # End sub Guest_Status {


		sub Guest_Uptime_State {
			Debug_Process('append', 'Line ' . __LINE__ . ' Guest_Uptime_State');
			$target_guest_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view: \'' . $target_guest_view . '\'');
			
			# Check the guest is powered on
			if ($target_guest_view->get_property('summary.runtime.powerState')->val eq 'poweredOn') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_view->get_property(\'summary.runtime.powerState\')->val eq \'poweredOn\'');

				# Uptime only available since vSphere API 4.1
				$api_version = API_Version();
					
				if ($api_version ge 4.1) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $api_version ge 4.1');
					# Get the guest uptime
					$guest_uptime = $target_guest_view->get_property('summary.quickStats.uptimeSeconds');
					if (!defined($guest_uptime)) {
						Debug_Process('append', 'Line ' . __LINE__ . 'The guest is powered off or not accessible');
						# The guest is powered off or not accessible
						$guest_uptime_state_flag = 1;
						$exit_message = 'Guest is powered OFF or is not accesible, cannot collect data!';
						$exit_state = 'UNKNOWN';
						} # End if (!defined($guest_uptime)) {
					elsif (defined($guest_uptime)) {
						# Is the guest_uptime a valid value?
						if ($guest_uptime == 0) {
							Debug_Process('append', 'Line ' . __LINE__ . '$guest_uptime == 0');
							Debug_Process('append', 'Line ' . __LINE__ . 'The guest has been up for 0 seconds which usually indicates the agent and vCenter are not communicating');
							# The guest has been up for 0 seconds which usually indicates the agent and vCenter are not communicating
							$guest_uptime_state_flag = 1;
							$exit_message = 'Guest has an Uptime of 0 seconds, cannot collect data!';
							$exit_state = 'CRITICAL';
							} # End if ($guest_uptime == 0) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $guest_uptime: \'' . $guest_uptime . '\'');
							# It's a valid value
							$guest_uptime_state_flag = 0;
							} # End else {
						} # End elsif (defined($guest_uptime)) {
					} # End if ($api_version ge 4.1) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $api_version lt 4.1');
					# Uptime only available in vSphere API 4.1 onwards
					$guest_uptime_state_flag = 0;
					} # End else {
					
				} # End if ($target_guest_view->summary->runtime->powerState->val ne 'poweredOn') {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' The guest is NOT powered on');
				# The guest is NOT powered on
				$guest_uptime_state_flag = 1;
				$exit_message = 'Guest is NOT powered on, cannot collect data!';
				$exit_state = 'CRITICAL';
				} # End else {
				
			return ($guest_uptime_state_flag, $exit_message, $exit_state)
			} # End sub Guest_Uptime_State {

			
		sub Host_Connection_State {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Connection_State');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			my $exit_state_to_return;
			# Get $host_connection_state
			$host_connection_state = $target_host_view->get_property('summary.runtime.connectionState')->val;
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state: \'' . $host_connection_state . '\'');
			
			switch ($host_connection_state) {
				case 'connected' {
					$host_connection_state_flag = 0;
					$exit_state_to_return = 'OK';
					} # End case 'connected') {
				
				case 'disconnected' {
					$exit_message = 'Host disconnected!';
					$exit_state_to_return = 'CRITICAL';
					$host_connection_state_flag = 1;
					} # End case 'disconnected') {
				
				case 'notResponding' {
					$exit_message = 'Host NOT responding!';
					$exit_state_to_return = 'CRITICAL';
					$host_connection_state_flag = 1;
					} # End case 'notResponding') {
				} # End switch ($host_connection_state) {
			
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag: \'' . $host_connection_state_flag . '\'');
			if (defined($exit_message)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
				} # End if (defined($exit_message)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'\'');
				} # End else {
			
			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_to_return: \'' . $exit_state_to_return . '\'');
			return ($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state_to_return)
			} # End sub Host_Connection_State {


		sub Host_CPU_Info {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_CPU_Info');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					# Get the CPU Model
					my $cpu_model = $target_host_view->get_property('summary.hardware.cpuModel');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_model: \'' . $cpu_model . '\'');
					# Remove any white spaces from the beginning and end of the string
					$cpu_model =~ s/^\s+|\s+$//g;
					Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_model: \'' . $cpu_model . '\'');
					
					# Determine what SI to use
					my $si_prefix_to_return_speed = SI_Get('CPU_Speed', 'GHz');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return_speed: \'' . $si_prefix_to_return_speed . '\'');
					
					# Get the CPU Speed
					my $cpu_speed = $target_host_view->get_property('summary.hardware.cpuMhz');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_speed: \'' . $cpu_speed . '\'');
					# Convert the CPU Speed to GHz
					$cpu_speed = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return_speed, $cpu_speed);
					Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_speed: \'' . $cpu_speed . '\'');
					
					# Get the number of CPU Cores
					my $cpu_cores = $target_host_view->get_property('summary.hardware.numCpuCores');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_cores: \'' . $cpu_cores . '\'');
					# Define the text to be used in the $exit_message
					my $cpu_cores_text;
					if ($cpu_cores > 1) {
						$cpu_cores_text = 'cores';
						} # End if ($cpu_sockets > 1) {
					else {
						$cpu_cores_text = 'core';
						} # End else {
					
					$exit_message = "$cpu_model, $cpu_cores $cpu_cores_text @ $cpu_speed" . $si_prefix_to_return_speed;
					$exit_state = 'OK';
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag == 0) {
			return ($exit_message, $exit_state);
			} # End sub Host_CPU_Info {


		sub Host_CPU_Usage {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_CPU_Usage');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					# Get any user supplied thresholds
					my %Thresholds_User = Thresholds_Get();
					Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

					my %Perfdata_Options = %{$_[1]};
					my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
					
					# Get the CPU Speed
					my $cpu_speed = $target_host_view->get_property('summary.hardware.cpuMhz');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_speed: \'' . $cpu_speed . '\'');
					# Get the number of CPU Cores
					my $cpu_cores = $target_host_view->get_property('summary.hardware.numCpuCores');
					Debug_Process('append', 'Line ' . __LINE__ . ' $cpu_cores: \'' . $cpu_cores . '\'');
					# Calculate the total CPU speed
					my $host_cpu_speed_total = $cpu_speed*$cpu_cores;
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_cpu_speed_total: \'' . $host_cpu_speed_total . '\'');
					
					# Determine what SI to use for the CPU speed
					my $si_prefix_to_return = SI_Get('CPU_Speed', 'GHz');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return: \'' . $si_prefix_to_return . '\'');
					
					# Convert the CPU Speed to SI
					$host_cpu_speed_total = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return, $host_cpu_speed_total);
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_cpu_speed_total: \'' . $host_cpu_speed_total . '\'');
					
					# Get the overall CPU used by the host
					my $host_cpu_usage = $target_host_view->get_property('summary.quickStats.overallCpuUsage');
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_cpu_usage: \'' . $host_cpu_usage . '\'');
					# Convert the CPU usage to SI
					$host_cpu_usage = SI_Process('CPU_Speed', 'MHz', $si_prefix_to_return, $host_cpu_usage);
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_cpu_usage: \'' . $host_cpu_usage . '\'');
					
					# Calculate the free CPU available
					my $host_cpu_free = $host_cpu_speed_total - $host_cpu_usage;
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_cpu_free: \'' . $host_cpu_free . '\'');

					# Start exit_message
					$exit_message = 'Host CPU';
					
					# Determine if CPU_Free should be reported
					if (defined($perfdata_options_selected->{'CPU_Free'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Free\'})');
						# Exit Message CPU Free
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_free', 'le', $exit_state, 'CPU Free', $host_cpu_free, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Free: ' . Format_Number_With_Commas($host_cpu_free) . " $si_prefix_to_return" . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'CPU_Free'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Free\'})');
						} # End else {
					
					# Determine if CPU_Used should be reported
					if (defined($perfdata_options_selected->{'CPU_Used'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Used\'})');
						# Exit Message CPU Used
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'cpu_used', 'ge', $exit_state, 'CPU Used', $host_cpu_usage, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Used: ' . Format_Number_With_Commas($host_cpu_usage) . " $si_prefix_to_return" . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'CPU_Used'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Used\'})');
						} # End else {
					
					# Determine if CPU_Total should be reported
					if (defined($perfdata_options_selected->{'CPU_Total'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'CPU_Total\'})');
						# Exit Message CPU Total
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'CPU Total', $host_cpu_speed_total, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Total: ' . Format_Number_With_Commas($host_cpu_speed_total) . " $si_prefix_to_return}");
						} # End if (defined($perfdata_options_selected->{'CPU_Total'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'CPU_Total\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag == 0) {
			
			return ($exit_message, $exit_state);
			} # End sub Host_CPU_Usage {


		sub Host_Hardware {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Hardware');
			$request_type = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			
			switch ($request_type) {
				case 'pnic_all' {
					# Define hash to store all pnic(s)
					my %pnic_all;
					
					# Get the $host_network_info passed to us
					my $host_network_info = $_[1];
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_info: \'' . $host_network_info . '\'');
					
					# Loop through each pnic item in $host_network_info
					foreach my $pnic_hash (@$host_network_info) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_hash: \'' . $pnic_hash . '\'');
						# Add the $pnic_hash to %pnic_all
						$pnic_all{$pnic_hash->key} = $pnic_hash;
						} # End foreach my $pnic_hash (@{$host_network_info->pnic}) {
					
					# Return the hash
					return %pnic_all;
					} # End case 'pnic' {
				} # End switch ($request_type) {
			} # End sub Host_Hardware {


		sub Host_Issues {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Issues');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			my $host_issues;
			my $exclude_flag;
			
			# Get host configIssue
			my $host_configIssue = $target_host_view->configIssue;
			if (defined($host_configIssue)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_configIssue: \'' . $host_configIssue . '\'');
				} # End if (defined($host_configIssue)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_configIssue: \'\'');
				} # End else {
			
			# Get any exclude_issue arguments
			my @exclude_issue;
			if (Opts::option_is_set('exclude_issue')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' --exclude_issue option is set');
				Debug_Process('append', 'Line ' . __LINE__ . ' exclude_issue values: \'' . Opts::get_option('exclude_issue') . '\'');
				# Put the options into an array
				@exclude_issue = split(/,/, Opts::get_option('exclude_issue'));
				} # End if (Opts::option_is_set('exclude_issue')) {
			
			# Loop through the issues
			foreach (@$host_configIssue) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
				$exclude_flag = 0;
				Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag: \'' . $exclude_flag . '\'');
				# Loop through the exclude options
				foreach my $exclude (@exclude_issue) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $exclude: \'' . $exclude . '\'');
					# If one of the exclude items matches our config issue then trigger the $exclude_flag
					if (ref($_) eq $exclude) {
						Debug_Process('append', 'Line ' . __LINE__ . ' ref($_): \'' . ref($_) . '\' eq $exclude: \'' . $exclude . '\'');
						$exclude_flag = 1;	
						Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag: \'' . $exclude_flag . '\'');
						} # End if (ref($_) eq $exclude) {
					elsif (ref($_) eq 'EventEx')  {
						Debug_Process('append', 'Line ' . __LINE__ . ' ref($_): \'' . ref($_) . '\' eq \'EventEx\'');
						if ($_->eventTypeId =~ m/$exclude/) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $_->eventTypeId =~ m/$exclude/');
							$exclude_flag = 1;
							Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag: \'' . $exclude_flag . '\'');
							} # End if ($_->eventTypeId =~ m/$exclude/) {
						} # End elsif (ref($_) eq 'EventEx')  {
					} # End foreach my $exclude (@exclude_issue) {
				
				# Only continue if our config issue is NOT an exclude item
				if ($exclude_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $exclude_flag == 0');
					Debug_Process('append', 'Line ' . __LINE__ . ' ref($_): \'' . ref($_) . '\'');
					# Identify and report the issue
					switch (ref($_)) {
						case 'EventEx' {
							Debug_Process('append', 'Line ' . __LINE__ . ' $_->eventTypeId: \'' . $_->eventTypeId . '\'');
							switch ($_->eventTypeId) {
								case m/HeartbeatDatastoreNotSufficient/ {
									$host_issues = Build_Message($host_issues, 'Insufficient Heartbeat Datastores', ', ');
									} # End case m/HeartbeatDatastoreNotSufficient/ {
								
								else {
									$host_issues = Build_Message($host_issues, 'Unknown configIssue ' . $_->eventTypeId, ', ');
									} # End else {
								} # End switch ($_->eventTypeId) {
							} # End case 'EventEx' {
						
						case 'HostNoRedundantManagementNetworkEvent' {
							$host_issues = Build_Message($host_issues, 'NO Management Network Redundancy', ', ');
							} # End case 'RemoteTSMEnabledEvent' {
						
						case 'LocalTSMEnabledEvent' {
							$host_issues = Build_Message($host_issues, 'Local Tech Support Mode ENABLED', ', ');
							} # End case 'LocalTSMEnabledEvent' {
						
						case 'RemoteTSMEnabledEvent' {
							$host_issues = Build_Message($host_issues, 'Remote Tech Support Mode ENABLED', ', ');
							} # End case 'RemoteTSMEnabledEvent' {
						
						else {
							$host_issues = Build_Message($host_issues, 'Unknown configIssue ' . ref($_), ', ');
							} # End else {
						} # End switch (ref($_)) {
					} # End if ($exclude_flag == 0) {
				} # End foreach (@$host_configIssue) {
			
			return $host_issues;
			} # End sub Host_Issues {


		sub Host_License {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_License');
			$target_host_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			# Get the $service_content
			my $service_content = Vim::get_service_content();
			Debug_Process('append', 'Line ' . __LINE__ . ' $service_content: \'' . $service_content . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					# Check if we are connected to a host
					if ($service_content->about->apiType eq 'HostAgent') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $service_content->about->apiType eq \'HostAgent\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' We are going to query the host license directly');
						# We are going to query the host license directly
						
						# Get $host_license_manager
						my $host_license_manager = Vim::get_view(
							mo_ref 		=> $service_content->licenseManager,
							properties	=> [ 'licenses', 'evaluation.properties' ]
							);
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_manager: \'' . $host_license_manager . '\'');
						
						# Check to see if we are in evaluation mode
						if (@{$host_license_manager->licenses}[0]->name eq 'Evaluation Mode') {
							Debug_Process('append', 'Line ' . __LINE__ . ' @{$host_license_manager->licenses}[0]->name eq \'Evaluation Mode\'');
							# Report on the evaluation mode
							$exit_message = 'Evaluation Mode';
							$exit_state = Build_Exit_State($exit_state, 'WARNING');
							# Check to see if the evaluation has expired
							my $eval_check = 0;
							Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check: \'' . $eval_check . '\'');
							foreach (@{$host_license_manager->get_property('evaluation.properties')}) {
								if ($_->value eq 'Evaluation period has expired, please install license.') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $$_->value eq \'Evaluation period has expired, please install license.\'');
									$eval_check = 1;
									} # End if ($_->value eq 'Evaluation period has expired, please install license.') {
								} # End foreach (@{$host_license_manager->get_property('evaluation.properties')}) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check: \'' . $eval_check . '\'');
							
							if ($eval_check == 1) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check == 1');
								$exit_message = Build_Exit_Message('Exit', $exit_message, 'Evaluation Period Expired');
								$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
								} # End if ($eval_check == 1) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' Evaluation period has not expired');
								my $host_license_expiration_hours;
								my $host_license_expiration_minutes;
								foreach (@{$host_license_manager->get_property('evaluation.properties')}) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $_->key: \'' . $_->key . '\'');
									switch ($_->key) {
										case 'expirationHours' {
											$host_license_expiration_hours = $_->value;
											Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours: \'' . $host_license_expiration_hours . '\'');
											} # End case 'expirationHours' {
										
										case 'expirationMinutes' {
											$host_license_expiration_minutes = $_->value;
											Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_minutes: \'' . $host_license_expiration_minutes . '\'');
											} # End case 'expirationMinutes' {
										} # End switch ($_->key) {
									} # End foreach (@{$host_license_manager->get_property('evaluation.properties')}) {v
								
								$exit_message = Build_Exit_Message('Exit', $exit_message, 'Evaluation Period Remaining:');
								if ($host_license_expiration_hours > 0) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours > 0');
									if ($host_license_expiration_hours <= 24) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours <= 24');
										if ($host_license_expiration_hours == 1) {
											$exit_message = Build_Message($exit_message, "$host_license_expiration_hours hour");
											} # End if ($host_license_expiration_hours == 1) {
										else {
											$exit_message = Build_Message($exit_message, "$host_license_expiration_hours hours");
											} # End else {
										$exit_message = Build_Message($exit_message, "$host_license_expiration_minutes minutes");
										$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
										} # End if ($host_license_expiration_hours <= 24) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours > 24');
										$exit_message = Build_Message($exit_message, " " . floor($host_license_expiration_hours/24) . " days");
										$exit_state = Build_Exit_State($exit_state, 'WARNING');
										} # End else {
									} # End if ($host_license_expiration_hours > 0) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours <= 0');
									$exit_message = Build_Message($exit_message, "$host_license_expiration_minutes minutes");
									$exit_state = Build_Exit_State($exit_state, 'WARNING');
									} # End else {
								} # End else {
							} # End if (@{$host_license_manager->licenses}[0]->name eq 'Evaluation Mode') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' Host has a valid license');
							# Report the current license version and key
							$exit_message = 'Licensed {Version: ' . @{$host_license_manager->licenses}[0]->name . '}';
							# Only report the license key if the --hide_key argument was not used
							if (!Opts::option_is_set('hide_key')) {
								$exit_message = Build_Message($exit_message, ' {Key: ' . @{$host_license_manager->licenses}[0]->licenseKey . '}');
								} # End if (!Opts::option_is_set('hide_key')) {
							$exit_state = Build_Exit_State($exit_state, 'OK');
							} # End else {
						} # End if ($service_content->about->apiType eq 'HostAgent') {
					else {
						# We are going to query the host license through vCenter
						Debug_Process('append', 'Line ' . __LINE__ . ' We are going to query the host license through vCenter');

						# Get $vcenter_license_manager
						my $vcenter_license_manager = Vim::get_view(
							mo_ref 		=> $service_content->licenseManager,
							properties	=> [ 'licenses', 'evaluation.properties', 'licenseAssignmentManager' ]
							);
						Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_manager: \'' . $vcenter_license_manager . '\'');
						
						# Get $license_assignment_manager
						my $license_assignment_manager =  Vim::get_view(
							mo_ref 		=> $vcenter_license_manager->licenseAssignmentManager
							);
						Debug_Process('append', 'Line ' . __LINE__ . ' $license_assignment_manager: \'' . $license_assignment_manager . '\'');
						
						# Get $assigned_licenses
						my $assigned_licenses = $license_assignment_manager->QueryAssignedLicenses(
							entityId => $target_host_view->get_property('summary.host')->value,
							);
						Debug_Process('append', 'Line ' . __LINE__ . ' $assigned_licenses: \'' . $assigned_licenses . '\'');
							
						# Get $assigned_license
						my $assigned_license = @{$assigned_licenses}[0]->assignedLicense;
						Debug_Process('append', 'Line ' . __LINE__ . ' $assigned_license: \'' . $assigned_license . '\'');
						
						# Check to see if we are in evaluation mode
						if ($assigned_license->name eq 'Evaluation Mode') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $assigned_license->name eq \'Evaluation Mode\'');
							# Report on the evaluation mode
							$exit_message = 'Evaluation Mode';
							$exit_state = Build_Exit_State($exit_state, 'WARNING');
							# Check to see if the evaluation has expired
							my $eval_check = 0;
							Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check: \'' . $eval_check . '\'');
							foreach (@{$vcenter_license_manager->get_property('evaluation.properties')}) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $_->value: \'' . $_->value . '\'');
								if ($_->value eq 'Evaluation period has expired, please install license.') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $_->value eq \'Evaluation period has expired, please install license.\'');
									$eval_check = 1;
									} # End if ($_->value eq 'Evaluation period has expired, please install license.') {
								} # End foreach (@{$vcenter_license_manager->get_property('evaluation.properties')}) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check: \'' . $eval_check . '\'');
							
							if ($eval_check == 1) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check == 1');
								Debug_Process('append', 'Line ' . __LINE__ . ' Evaluation Period Expired');
								$exit_message = Build_Exit_Message('Exit', $exit_message, 'Evaluation Period Expired');
								$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
								} # End if ($eval_check == 1) {
							else {
								my $host_license_expiration_hours;
								my $host_license_expiration_minutes;
								foreach (@{$assigned_license->properties}) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $_->key: \'' . $_->key . '\'');
									switch ($_->key) {
										case 'expirationHours' {
											$host_license_expiration_hours = $_->value;
											Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours: \'' . $host_license_expiration_hours . '\'');
											} # End case 'expirationHours' {
										
										case 'expirationMinutes' {
											$host_license_expiration_minutes = $_->value;
											Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_minutes: \'' . $host_license_expiration_minutes . '\'');
											} # End case 'expirationMinutes' {
										} # End switch ($_->key) {
									} # End foreach (@{$assigned_license->properties}) {
								
								$exit_message = Build_Exit_Message('Exit', $exit_message, 'Evaluation Period Remaining:');
								if ($host_license_expiration_hours > 0) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours > 0');
									if ($host_license_expiration_hours <= 24) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours <= 24');
										if ($host_license_expiration_hours == 1) {
											$exit_message = Build_Message($exit_message, "$host_license_expiration_hours hour");
											} # End if ($host_license_expiration_hours == 1) {
										else {
											$exit_message = Build_Message($exit_message, "$host_license_expiration_hours hours");
											} # End else {
										$exit_message = Build_Message($exit_message, "$host_license_expiration_minutes minutes");
										$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
										} # End if ($host_license_expiration_hours <= 24) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours > 24');
										$exit_message = Build_Message($exit_message, " " . floor($host_license_expiration_hours/24) . " days");
										$exit_state = Build_Exit_State($exit_state, 'WARNING');
										} # End else {
									} # End if ($host_license_expiration_hours > 0) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . ' $host_license_expiration_hours <= 0');
									$exit_message = Build_Message($exit_message, "$host_license_expiration_minutes minutes");
									$exit_state = Build_Exit_State($exit_state, 'WARNING');
									} # End else {
								} # End else {
							} # End if ($assigned_license->name eq 'Evaluation Mode') {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' Host has a valid license');
							# Report the current license version and key
							$exit_message = 'Licensed {Version: ' . $assigned_license->name . '}';
							# Only report the license key if the --hide_key argument was not used
							if (!Opts::option_is_set('hide_key')) {
								$exit_message = Build_Message($exit_message, ' {Key: ' . $assigned_license->licenseKey . '}');
								} # End if (!Opts::option_is_set('hide_key')) {
							$exit_state = Build_Exit_State($exit_state, 'OK');
							} # End else {	
						} # End else {
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag = 0) {
			
			return Process_Request_Type($_[0], $exit_message, $exit_state);
			} # End sub Host_License {


		sub Host_Memory_Usage {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Memory_Usage');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					# Get any user supplied thresholds
					my %Thresholds_User = Thresholds_Get();
					Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

					my %Perfdata_Options = %{$_[1]};
					my $perfdata_options_selected = Perfdata_Option_Process('metric_standard', \%Perfdata_Options);
					
					# Get the total memory in the host
					my $host_memory_total = $target_host_view->get_property('summary.hardware.memorySize');
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_memory_total: \'' . $host_memory_total . '\'');
					
					# Determine what SI to use for the Memory_Size
					my $si_prefix_to_return = SI_Get('Memory_Size', 'GB');
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return: \'' . $si_prefix_to_return . '\'');
						
					# Convert the $host_memory_total to SI
					$host_memory_total = SI_Process('Memory_Size', 'B', $si_prefix_to_return, $host_memory_total);
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_memory_total: \'' . $host_memory_total . '\'');
					# Convert this to an integer
					$host_memory_total = ceil($host_memory_total);
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_memory_total: \'' . $host_memory_total . '\'');
					
					# Get the overall memory used by the host
					my $host_memory_usage = $target_host_view->get_property('summary.quickStats.overallMemoryUsage');
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_memory_usage: \'' . $host_memory_usage . '\'');
					# Convert the $host_memory_usage to SI
					$host_memory_usage = SI_Process('Memory_Size', 'MB', $si_prefix_to_return, $host_memory_usage);
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_memory_usage: \'' . $host_memory_usage . '\'');
					
					# Calculate the free memory available
					my $host_memory_free = $host_memory_total - $host_memory_usage;
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_memory_free: \'' . $host_memory_free . '\'');
					
					# Start exit_message
					$exit_message = 'Host Memory';
					
					# Determine if Memory_Free should be reported
					if (defined($perfdata_options_selected->{'Memory_Free'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Free\'})');
						# Exit Message Memory Free
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_free', 'le', $exit_state, 'Memory Free', $host_memory_free, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Free: ' . Format_Number_With_Commas($host_memory_free) . " $si_prefix_to_return" . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Memory_Free'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Free\'})');
						} # End else {
					
					# Determine if Memory_Used should be reported
					if (defined($perfdata_options_selected->{'Memory_Used'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Used\'})');
						# Exit Message Memory Used
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'memory_used', 'ge', $exit_state, 'Memory Used', $host_memory_usage, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Used: ' . Format_Number_With_Commas($host_memory_usage) . " $si_prefix_to_return" . $message_to_add . '}');
						} # End if (defined($perfdata_options_selected->{'Memory_Used'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Used\'})');
						} # End else {
					
					# Determine if Memory_Total should be reported
					if (defined($perfdata_options_selected->{'Memory_Total'})) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Memory_Total\'})');
						# Exit Message Memory Total
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, 'Memory Total', $host_memory_total, $si_prefix_to_return);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ' {Total: ' . Format_Number_With_Commas($host_memory_total) . " $si_prefix_to_return}");
						} # End if (defined($perfdata_options_selected->{'Memory_Total'})) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Memory_Total\'})');
						} # End else {
					
					# Exit Message With Perfdata
					$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag == 0) {
			return ($exit_message, $exit_state);
			} # End sub Host_Memory_Usage {


		sub Host_NIC_Status {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_NIC_Status');
			$target_host_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					# Get the $target_host_view_network_system
					my $target_host_view_network_system = $target_host_view->get_property('configManager.networkSystem');
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_network_system: \'' . $target_host_view_network_system . '\'');
					
					# Get the $host_network_system
					my $host_network_system = Vim::get_view(
						mo_ref	=>	$target_host_view_network_system,
						properties	=> [ 'networkInfo.vswitch', 'networkInfo.proxySwitch', 'networkInfo.pnic', 'networkInfo.vnic', 'networkInfo.consoleVnic' ]
						); # End my $host_network_system = Vim::get_view(
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system: \'' . $host_network_system . '\'');
					
					# Create an array of NIC names the user may have provided
					my @nic_names;
					# Determine if the --name argument was provided
					if (Opts::option_is_set('name')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'name\')');
						# Put the options into an array
						@nic_names = split(/,/, Opts::get_option('name'));
						} # End if (!Opts::option_is_set('name')) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' All nics will be returned');
						# All nics will be returned
						@nic_names = 'all';
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names: \'' . @nic_names . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names values: \'' . join(", ", @nic_names) . '\'');
					
					# Get local vSwitches if they exist
					my $local_vswitches;
					if (defined($host_network_system->get_property('networkInfo.vswitch'))) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_network_system->get_property(\'networkInfo.vswitch\'))');
						$local_vswitches = $host_network_system->get_property('networkInfo.vswitch');
						Debug_Process('append', 'Line ' . __LINE__ . ' $local_vswitches: \'' . $local_vswitches . '\'');
						} # End if (defined($host_network_system->get_property('networkInfo.vswitch'))) {
					# Get Distributed vSwitches if they exist
					my $distributed_vswitches;
					if (defined($host_network_system->get_property('networkInfo.proxySwitch'))) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_network_system->get_property(\'networkInfo.proxySwitch\'))');
						$distributed_vswitches = $host_network_system->get_property('networkInfo.proxySwitch');
						Debug_Process('append', 'Line ' . __LINE__ . ' $distributed_vswitches: \'' . $distributed_vswitches . '\'');
						} # End if (defined($host_network_system->get_property('networkInfo.proxySwitch'))) {
					
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[2]: \'' . $_[2] . '\'');
					# Perform the action depending on if it is a pnic or vnic
					switch ($_[2]) {
						case 'pnic' {
							# Create the pnic_all hash
							my %pnic_all = Host_Hardware('pnic_all', $host_network_system->get_property('networkInfo.pnic'));
							Debug_Process('append', 'Line ' . __LINE__ . ' %pnic_all: \'' . %pnic_all . '\'');
							
							my $pnic_count = 0;
							my $pnic_connected_count = 0;
							my $pnic_disconnected_count = 0;

							Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_count: \'' . $pnic_count . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_connected_count: \'' . $pnic_connected_count . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_disconnected_count: \'' . $pnic_disconnected_count . '\'');

							Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the @nic_names array to determine which ones to report on');
							# Loop through the @nic_names array to determine which ones to report on (all by default)
							foreach my $nic_name (@nic_names) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $nic_name: \'' . $nic_name . '\'');
								my $detection_check = 'no';
								Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' Loop through all the physical NICs');
								# Loop through all the physical NICs
								foreach my $pnic_key (keys %pnic_all) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_key: \'' . $pnic_key . '\'');
									my $pnic_name = $pnic_all{$pnic_key}->device;
									Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_name: \'' . $pnic_name . '\'');
									Debug_Process('append', 'Line ' . __LINE__ . ' See if the $nic_name matches $pnic_name');
									# See if the $nic_name matches $pnic_name
									if ($nic_name =~ /^($pnic_name|all)$/) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $nic_name =~ /^($pnic_name|all)$/');
										$pnic_count++;
										Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_count: \'' . $pnic_count . '\'');
										$detection_check = 'yes';
										Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
										my $pnic_hash = $pnic_all{$pnic_key};
										Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_hash: \'' . $pnic_hash . '\'');

										Debug_Process('append', 'Line ' . __LINE__ . ' Determine vSwitch name');
										# Determine vSwitch name
										my $vswitch_detection_check = 'no';
										Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_detection_check: \'' . $vswitch_detection_check . '\'');
										while ($vswitch_detection_check eq 'no') {
											Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_detection_check eq \'no\'');
											if (defined($distributed_vswitches)) {
												Debug_Process('append', 'Line ' . __LINE__ . ' defined($distributed_vswitches)');
												# Distributed vSwitch(s) exists, let's loop through them
												foreach my $distributed_vswitch (@$distributed_vswitches) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $distributed_vswitch: \'' . $distributed_vswitch . '\'');
													# Check to see if any pnics exist
													if (defined($distributed_vswitch->pnic)) {
														Debug_Process('append', 'Line ' . __LINE__ . ' defined($distributed_vswitch->pnic)');
														# Loop through all the pNICs in this switch
														foreach my $distributed_vswitch_pnic (@{$distributed_vswitch->pnic}) {
															Debug_Process('append', 'Line ' . __LINE__ . ' $distributed_vswitch_pnic: \'' . $distributed_vswitch_pnic . '\'');
															# See if $pnic_key matches $distributed_vswitch_pnic 
															if ($pnic_key eq $distributed_vswitch_pnic) {
																Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_key eq $distributed_vswitch_pnic');
																$message_to_add = '[' . $pnic_name . ' on Distributed vSwitch \'' . $distributed_vswitch->dvsName . '\'';
																Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_detection_check = \'yes\'');
																$vswitch_detection_check = 'yes';
																} # End if ($pnic_key eq $distributed_vswitch_pnic) {
															} # End foreach my $distributed_vswitch_pnic (@{$distributed_vswitch->pnic}) {
														} # End if (defined($distributed_vswitch->pnic)) {
													} # End foreach my $distributed_vswitch (@$distributed_vswitches) {
												} # End if (defined($distributed_vswitches)) {
											if (defined($local_vswitches)) {
												Debug_Process('append', 'Line ' . __LINE__ . ' defined($local_vswitches)');
												# Local vSwitch(s) exists, let's loop through them
												foreach my $local_vswitch (@$local_vswitches) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $local_vswitch: \'' . $local_vswitch . '\'');
													# Check to see if any pnics exist
													if (defined($local_vswitch->pnic)) {
														Debug_Process('append', 'Line ' . __LINE__ . ' defined($local_vswitch->pnic)');
														# Loop through all the pNICs in this switch
														foreach my $local_vswitch_pnic (@{$local_vswitch->pnic}) {
															Debug_Process('append', 'Line ' . __LINE__ . ' $local_vswitch_pnic: \'' . $local_vswitch_pnic . '\'');
															# See if $pnic_key matches $local_vswitch_pnic 
															if ($pnic_key eq $local_vswitch_pnic) {
																Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_key eq $local_vswitch_pnic');
																$message_to_add = '[' . $pnic_name . ' on Local vSwitch \'' . $local_vswitch->name . '\'';
																Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_detection_check = \'yes\'');
																$vswitch_detection_check = 'yes';
																} # End if ($pnic_key eq $local_vswitch_pnic) {
															} # End foreach my $local_vswitch_pnic (@{$local_vswitch->pnic}) {
														} # End if (defined($local_vswitch->pnic)) {
													} # End foreach my $local_vswitch (@$local_vswitches) {
												} # End if (defined($local_vswitches)) {
											if ($vswitch_detection_check eq 'no') {
												Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_detection_check eq \'no\'');
												$message_to_add = '[' . $pnic_name . ' \'Spare pNIC\'';
												Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_detection_check = \'yes\'');
												$vswitch_detection_check = 'yes';
												} # End if ($vswitch_detection_check eq 'no') {
											} # End while ($vswitch_detection_check == 'no') {
										
										$message_to_add = Build_Message($message_to_add, ", Driver: " . $pnic_all{$pnic_key}->driver);

										Debug_Process('append', 'Line ' . __LINE__ . ' Checking to see if the pnic is connected');
										# Checking to see if the pnic is connected
										if (!defined($pnic_all{$pnic_key}->linkSpeed)) {
											Debug_Process('append', 'Line ' . __LINE__ . ' !defined($pnic_all{$pnic_key}->linkSpeed)');
											if (Opts::option_is_set('nic_state')) {
												Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'nic_state\')');
												# Test the --nic_state option
												# Using the Test_User_Option sub to generate an exit code
												($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_state', 'disconnected', 'CRITICAL', 'NIC is', 'NOT Connected', 'connected');
												} # End if (Opts::option_is_set('nic_state')) {
											else {
												$exit_state_to_add = 'CRITICAL';
												} # End else {
											$pnic_disconnected_count++;
											Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_disconnected_count: \'' . $pnic_disconnected_count . '\'');
											$message_to_add = Build_Message($message_to_add, ", NOT Connected]");	
											$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
											} # End if (!defined($pnic_all{$pnic_key}->linkSpeed)) {
										else {
											# It's connected
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($pnic_all{$pnic_key}->linkSpeed)');
											if (Opts::option_is_set('nic_state')) {
												Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'nic_state\')');
												# Test the --nic_state option
												# Using the Test_User_Option sub to generate an exit code
												($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_state', 'connected', 'CRITICAL', 'NIC is', 'Connected', 'connected');
												$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
												} # End if (Opts::option_is_set('nic_state')) {

											# Test the --nic_speed option
											my $nic_speed = $pnic_all{$pnic_key}->linkSpeed->speedMb;
											Debug_Process('append', 'Line ' . __LINE__ . ' $nic_speed: \'' . $nic_speed . '\'');
											($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_speed', $nic_speed, 'CRITICAL', 'NIC Speed is', Format_Number_With_Commas($nic_speed) . " MB", 'no_default');
											$message_to_add = Build_Message($message_to_add, $exit_message_to_add, ', ');
											$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
											# Check the duplex
											if ($pnic_all{$pnic_key}->linkSpeed->duplex == 0) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_all{$pnic_key}->linkSpeed->duplex == 0');
												# Test the --nic_duplex option
												($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_duplex', 'half', 'CRITICAL', 'NIC Speed is', 'Half Duplex', 'full');
												} # End if ($pnic_all{$pnic_key}->linkSpeed->duplex == 0) {
											else {
												Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_all{$pnic_key}->linkSpeed->duplex != 0');
												# Test the --nic_duplex option
												($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_duplex', 'full', 'CRITICAL', 'NIC Speed is', 'Full Duplex', 'full');
												} # End else {
											$message_to_add = Build_Message($message_to_add, ", $exit_message_to_add]");
											$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
											$pnic_connected_count++;
											Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_connected_count: \'' . $pnic_connected_count . '\'');
											} # End else {
										$exit_message = Build_Exit_Message('Exit', $exit_message, $message_to_add);
										} # End if ($nic_name =~ /^($pnic_name|all)$/) {
									} # End foreach my $pnic_key (keys %pnic_all) {
								
								# Determine if the user provided pNIC could not be found
								if ($detection_check eq 'no') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check eq \'no\'');
									$exit_message_to_add = "[pNIC \'$nic_name\' could not be found!]";
									$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
									$exit_message = Build_Exit_Message('Exit', $exit_message, $message_to_add);
									} # End if ($detection_check eq 'no') {
								} # End foreach my $nic_name (@nic_names) {
							
							# Add information about total pNICs if there is more than 1
							if ($pnic_count > 1) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_count > 1');
								# Add the total pnic count to the $exit_message
								$message_to_add = "NICs [Total: $pnic_count";
								if ($pnic_connected_count > 0) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_connected_count > 0');
									# Add the connected pnic count to the $exit_message
									$message_to_add = Build_Message($message_to_add, ", Connected: $pnic_connected_count");
									} # End if ($pnic_connected_count > 0) {
								if ($pnic_disconnected_count > 0) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_disconnected_count > 0');
									# Add the disconnected pnic count to the $exit_message
									$message_to_add = Build_Message($message_to_add, ", Disconnected: $pnic_disconnected_count");
									} # End if ($pnic_disconnected_count > 0) {
								$exit_message = "$message_to_add], $exit_message";
								} # End if ($pnic_count > 1) {
							} # End case 'pnic' {
						

						case 'vnic' {
							# Create an array of vNICs
							my @vnic_all;
							# ESXi host
							if ($host_network_system->get_property('networkInfo.vnic')) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system->get_property(\'networkInfo.vnic\')');
								@vnic_all = $host_network_system->get_property('networkInfo.vnic');
								} # End if ($host_network_system->get_property('networkInfo.vnic')) {
							# ESX host
							if ($host_network_system->get_property('networkInfo.consoleVnic')) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system->get_property(\'networkInfo.consoleVnic\')');
								@vnic_all = $host_network_system->get_property('networkInfo.consoleVnic');
								} # End if ($host_network_system->get_property('networkInfo.consoleVnic')) {

							Debug_Process('append', 'Line ' . __LINE__ . ' @vnic_all: \'' . @vnic_all . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' @vnic_all values: \'' . join(", ", @vnic_all) . '\'');
	
							# Get the $target_host_view_virtual_nic_manager
							my $target_host_view_virtual_nic_manager = $target_host_view->get_property('configManager.virtualNicManager');
							Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_virtual_nic_manager: \'' . $target_host_view_virtual_nic_manager . '\'');
							
							# Get the $host_virtual_nic_manager
							my $host_virtual_nic_manager = Vim::get_view(
								mo_ref	=>	$target_host_view_virtual_nic_manager,
								properties	=> [ 'info.netConfig' ]
								); # End my $host_virtual_nic_manager = Vim::get_view(
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_virtual_nic_manager: \'' . $host_virtual_nic_manager . '\'');
								
							# Get all the vNICs
							my $host_virtual_nic_manager_all_vnics = $host_virtual_nic_manager->get_property('info.netConfig');
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_virtual_nic_manager_all_vnics: \'' . $host_virtual_nic_manager_all_vnics . '\'');

							Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the @nic_names array to determine which ones to report on');
							# Loop through the @nic_names array to determine which ones to report on (all by default)
							foreach my $nic_name (@nic_names) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $nic_name: \'' . $nic_name . '\'');
								my $detection_check = 'no';
								Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');

								Debug_Process('append', 'Line ' . __LINE__ . ' Loop through all known vNICs');
								# Loop through all known vNICs
								foreach my $vnic_array (@vnic_all) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_array: \'' . $vnic_array . '\'');
									Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the array of vNICs (they are a hash)');
									# Loop through the array of vNICs (they are a hash)
									foreach my $vnic_hash (@$vnic_array) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_hash: \'' . $vnic_hash . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' Need to determine if this is located in a distributed vSwitch or local vSwitch');
										# Need to determine if this is located in a distributed vSwitch or local vSwitch
										my $vnic_hash_identifier;
										if (defined($vnic_hash->spec->distributedVirtualPort)) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($vnic_hash->spec->distributedVirtualPort)');
											$vnic_hash_identifier = $vnic_hash->device;
											Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_hash_identifier: \'' . $vnic_hash_identifier . '\'');
											} # End if (defined($vnic_hash->spec->distributedVirtualPort)) {
										else {
											$vnic_hash_identifier = $vnic_hash->portgroup;
											Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_hash_identifier: \'' . $vnic_hash_identifier . '\'');
											} # End else {

										Debug_Process('append', 'Line ' . __LINE__ . ' See if the $nic_name matches the $vnic_hash_identifier');
										# See if the $nic_name matches the $vnic_hash_identifier
										if ($nic_name =~ /^($vnic_hash_identifier|all)$/) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $nic_name =~ /^($vnic_hash_identifier|all)$/');
											$detection_check = 'yes';
											Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
											my $role_flag = 0;
											Debug_Process('append', 'Line ' . __LINE__ . ' $role_flag: \'' . $role_flag . '\'');

											Debug_Process('append', 'Line ' . __LINE__ . ' Determine vSwitch name');
											# Determine vSwitch name
											if (defined($vnic_hash->spec->distributedVirtualPort)) {
												Debug_Process('append', 'Line ' . __LINE__ . ' defined($vnic_hash->spec->distributedVirtualPort)');
												Debug_Process('append', 'Line ' . __LINE__ . ' It\'s on a distributed vSwitch');
												# It's on a distributed vSwitch
												foreach (@$distributed_vswitches) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
													if ($_->dvsUuid eq $vnic_hash->spec->distributedVirtualPort->switchUuid) {
														Debug_Process('append', 'Line ' . __LINE__ . ' $_->dvsUuid eq $vnic_hash->spec->distributedVirtualPort->switchUuid');
														$exit_message_to_add = '[{' . $vnic_hash->device . ' on Distributed vSwitch \'' . $_->dvsName . '\'}';		
														} # End if ($_->dvsUuid eq $vnic_hash->spec->distributedVirtualPort->switchUuid) {
													} # End foreach (@$distributed_vswitches) {
												} # End if (defined($vnic_hash->spec->distributedVirtualPort)) {
											else {
												Debug_Process('append', 'Line ' . __LINE__ . ' It\'s on a local vSwitch');
												# It's on a local vSwitch
												my $vswitch_name = '';
												Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_name: \'' . $vswitch_name . '\'');
												while ($vswitch_name eq '') {
													Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_name eq \'\'');
													foreach my $vswitch (@$local_vswitches) {
														Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch: \'' . $vswitch . '\'');
														foreach (@{$vswitch->portgroup}) {
															Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
															if ($_ eq 'key-vim.host.PortGroup-' . $vnic_hash->portgroup) {
																Debug_Process('append', 'Line ' . __LINE__ . ' $_ eq \'key-vim.host.PortGroup-\' . $vnic_hash->portgroup');
																$vswitch_name = $vswitch->name;
																Debug_Process('append', 'Line ' . __LINE__ . ' $vswitch_name: \'' . $vswitch_name . '\'');
																} # End if ($_ eq 'key-vim.host.PortGroup-' . $vnic_hash->portgroup) {
															} # End foreach (@{$vswitch->portgroup}) {
														} # End foreach my $vswitch (@$local_vswitches) {
													} # End while ($vswitch_name eq '') {
												$exit_message_to_add = '[{' . $vnic_hash->portgroup . ' (' . $vnic_hash->device . ' on Local vSwitch \'' . $vswitch_name . '\')}';			
												} # End else {
											
											my $mtu_size;
											if (defined($vnic_hash->spec->mtu)) {
												Debug_Process('append', 'Line ' . __LINE__ . ' defined($vnic_hash->spec->mtu)');
												$mtu_size = $vnic_hash->spec->mtu;
												} # End if (defined($vnic_hash->spec->mtu)) {
											else {
												$mtu_size = 1500;
												} # End else {
											Debug_Process('append', 'Line ' . __LINE__ . ' $mtu_size: \'' . $mtu_size . '\'');
											# Test the --mtu option
											($exit_state_to_add, $message_to_add) = Test_User_Option('mtu', $mtu_size, 'CRITICAL', 'MTU is', "MTU: " . Format_Number_With_Commas($mtu_size), 'no_default');
											$exit_message_to_add = Build_Message($exit_message_to_add, " {$message_to_add}");
											$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
											
											$exit_message_to_add = Build_Message($exit_message_to_add, " {Roles:");
											Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the global hash of vNIC_Types (to get their role)');
											# Loop through the global hash of vNIC_Types (to get their role)
											$message_to_add = '';
											foreach my $vnic_type (keys %vNIC_Types) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_type: \'' . $vnic_type . '\'');
												Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the array of vnic roles provided by the virtual nic manager');
												# Loop through the array of vnic roles provided by the virtual nic manager
												foreach my $vnic_role (@$host_virtual_nic_manager_all_vnics) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_role: \'' . $vnic_role . '\'');
													# See if the current role matches the current $vnic_type from the global hash of vNIC_Types
													if ($vnic_role->nicType eq $vnic_type) {
														Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_role->nicType eq $vnic_type');
														# Check to see if this role has any interfaces defined
														if (defined($vnic_role->selectedVnic)) {
															Debug_Process('append', 'Line ' . __LINE__ . ' defined($vnic_role->selectedVnic)');
															Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the array of selectedVnics that are currently assigned this role');
															# Loop through the array of selectedVnics that are currently assigned this role
															foreach my $vnic_role_defined (@{$vnic_role->selectedVnic}) {
																Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_role_defined: \'' . $vnic_role_defined . '\'');
																# Check to see if the currently selected NIC $vnic_hash has this role assigned to it
																if ($vnic_role_defined eq $vnic_type . "." . $vnic_hash->key) {
																	Debug_Process('append', 'Line ' . __LINE__ . ' $vnic_role_defined eq $vnic_type . "." . $vnic_hash->key');
																	$role_flag = 1;
																	Debug_Process('append', 'Line ' . __LINE__ . ' $role_flag: \'' . $role_flag . '\'');
																	$message_to_add = Build_Message($message_to_add, $vNIC_Types{$vnic_type}, ', ');
																	} # End if ($vnic_role_defined eq $vnic_type . "." . $vnic_hash->key) {
																} # End foreach my $vnic_role_defined (@{$vnic_role->selectedVnic}) {
															} # End if (defined($vnic_role->selectedVnic)) {
														} # End if ($vnic_role->nicType eq $vnic_type) {
													} # End foreach my $vnic_role (@$host_virtual_nic_manager_all_vnics) {
												} # End foreach my $vnic_type (keys %vNIC_Types) {foreach my $vnic_type (keys %vNIC_Types) {

											Debug_Process('append', 'Line ' . __LINE__ . ' Determine if a role was detected');
											# Determine if a role was detected
											if ($role_flag == 1) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $role_flag == 1');
												$exit_message_to_add = Build_Message($exit_message_to_add, " $message_to_add}");	
												} # End if ($role_flag == 1) {
											else {
												# A workaround for detecting the Service Console on ESX servers
												if ($target_host_view->get_property('summary.config.product.productLineId') eq 'esx') {
													Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->get_property(\'summary.config.product.productLineId\') eq \'esx\'');
													$exit_message_to_add = Build_Message($exit_message_to_add, " Service Console}");
													} # End if ($target_host_view->get_property('summary.config.product.productLineId') eq 'esx') {
												else {
													$exit_message_to_add = Build_Message($exit_message_to_add, " NONE}");
													} # End else {
												} # End else {
											$exit_message = Build_Exit_Message('Exit', $exit_message, "$exit_message_to_add]");
											} # End if ($nic_name =~ /^($vnic_hash_identifier|all)$/) {
										} # End foreach my $vnic_hash (@$vnic_array) {
									} # End foreach my $vnic_array (@vnic_all) {
								
								# Determine if the user provided vNIC could not be found
								if ($detection_check eq 'no') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check eq \'no\'');
									$exit_message_to_add = "[vNIC \'$nic_name\' could not be found!]";
									$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
									$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
									} # End if ($detection_check eq 'no') {
								} # End foreach my $nic_name (@nic_names) {
							} # End case 'vnic' {
						} # End switch ($_[2]) {
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag == 0) {
			
			return Process_Request_Type($_[0], $exit_message, $exit_state);
			} #End sub Host_NIC_Status {


		sub Host_NIC_Usage {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_NIC_Usage');
			$target_host_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			$exit_state = 'OK';
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					# Get the $target_host_view_network_system
					my $target_host_view_network_system = $target_host_view->get_property('configManager.networkSystem');
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_network_system: \'' . $target_host_view_network_system . '\'');
					
					# Get the $host_network_system
					my $host_network_system = Vim::get_view(
						mo_ref		=>	$target_host_view_network_system,
						properties	=> [ 'networkInfo.pnic' ]
						); # End my $host_network_system = Vim::get_view(
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system: \'' . $host_network_system . '\'');
					
					# The returned perfdata will be put in here
					my $perf_data;

					my %Perfdata_Options = %{$_[3]};
					(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);
					
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[2]: \'' . $_[2] . '\'');
					# Perform the action depending on if it is a pnic or vnic
					switch ($_[2]) {
						case 'pnic' {
							# Create the pnic_all hash
							my %pnic_all = Host_Hardware('pnic_all', $host_network_system->get_property('networkInfo.pnic'));
							Debug_Process('append', 'Line ' . __LINE__ . ' %pnic_all: \'' . %pnic_all . '\'');

							my @nic_names;
							# Determine if the --name argument was provided
							if (Opts::option_is_set('name')) {
								Debug_Process('append', 'Line ' . __LINE__ . 'Opts::option_is_set(\'name\')');
								# Put the options into an array
								@nic_names = split(/,/, Opts::get_option('name'));
								} # End if (!Opts::option_is_set('name')) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . 'All NICs will be returned, the next few lines will obtain all NICs');
								# All NICs will be returned, the next few lines will obtain all NICs
								foreach (keys %pnic_all) {
									push @nic_names, $pnic_all{$_}->device;
									} # End foreach (keys %pnic_all) {
								} # End else {

							Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names: \'' . @nic_names . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names values: \'' . join(", ", @nic_names) . '\'');
					
							# Get any user supplied thresholds
							my %Thresholds_User = Thresholds_Get();
							Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

							Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the @nic_names array');
							# Loop through the @nic_names array 
							foreach my $current_nic (@nic_names) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $current_nic: \'' . $current_nic . '\'');
								my $detection_check = 'no';
								Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');

								Debug_Process('append', 'Line ' . __LINE__ . ' Now loop through each item in the %pnic_all');
								# Now loop through each item in the %pnic_all
								foreach my $known_nic (keys %pnic_all) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $known_nic: \'' . $known_nic . '\'');
									# Define $current_nic_name
									my $known_nic_name = $pnic_all{$known_nic}->device;
									Debug_Process('append', 'Line ' . __LINE__ . ' $known_nic_name: \'' . $known_nic_name . '\'');
									# Check to see if this is the NIC we want
									if ($current_nic eq $known_nic_name) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $current_nic eq $known_nic_name');
										$detection_check = 'yes';
										Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
										
										# Get the Perfdata
										(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_host_view, 'net', $current_nic, \@$requested_perf_counter_keys);
										# Process the Perfdata
										$perf_data->{$current_nic} = Perfdata_Process($perf_data_requested, $perf_counters_used);

										# Start exit_message_to_add
										$exit_message_to_add = " [$current_nic";
		
										# Determine if NIC_Rate should be reported
										if (defined($perfdata_options_selected->{'NIC_Rate'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'NIC_Rate\'})');
											# Determine what SI to use for NIC_Rate
											my $si_nic_rate = SI_Get('NIC_Rate', 'kBps');
											Debug_Process('append', 'Line ' . __LINE__ . ' $si_nic_rate: \'' . $si_nic_rate . '\'');
											# Define the NIC_Rate variables
											my $nic_rx = SI_Process('NIC_Rate', 'kBps', $si_nic_rate, $perf_data->{$current_nic}->{received});
											Debug_Process('append', 'Line ' . __LINE__ . ' $nic_rx: \'' . $nic_rx . '\'');
											my $nic_tx = SI_Process('NIC_Rate', 'kBps', $si_nic_rate, $perf_data->{$current_nic}->{transmitted});
											Debug_Process('append', 'Line ' . __LINE__ . ' $nic_tx: \'' . $nic_tx . '\'');
											# Get the NIC_Rate percentages
											(my $nic_rx_percentage, my $nic_tx_percentage) = Process_Percentages($nic_rx, $nic_tx);

											# Exit Message NIC Rate Rx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'nic_rate', 'ge', $exit_state, "$current_nic Rate Rx", $nic_rx, $si_nic_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Rate (Rx:' . Format_Number_With_Commas($nic_rx) . " $si_nic_rate / $nic_rx_percentage%" . $message_to_add . ')');
											
											# Exit Message NIC Rate Tx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'nic_rate', 'ge', $exit_state, "$current_nic Rate Tx", $nic_tx, $si_nic_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Tx:' . Format_Number_With_Commas($nic_tx) . " $si_nic_rate / $nic_tx_percentage%" . $message_to_add . ')}');
											} # End if (defined($perfdata_options_selected->{'NIC_Rate'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'NIC_Rate\'})');
											} # End else {
										
										# Determine if NIC_Packets should be reported
										if (defined($perfdata_options_selected->{'NIC_Packets'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'NIC_Packets\'})');
											# Exit Message Packets Rx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$current_nic Packets Rx", $perf_data->{$current_nic}->{packetsRx});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Packets (Rx:' . Format_Number_With_Commas($perf_data->{$current_nic}->{packetsRx}) . ')');
											
											# Exit Message Packets Tx
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$current_nic Packets Tx", $perf_data->{$current_nic}->{packetsTx});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Tx:' . Format_Number_With_Commas($perf_data->{$current_nic}->{packetsTx}) . ')}');
											} # End if (defined($perfdata_options_selected->{'NIC_Packets'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'NIC_Packets\'})');
											} # End else {

										# Determine if NIC_Packet_Errors should be reported
										if (defined($perfdata_options_selected->{'NIC_Packet_Errors'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'NIC_Packet_Errors\'})');
											# Determine if the ESX host is version 5 or greater for Packet Error Counters
											if ($target_host_view->get_property('summary.config.product.version') ge 5) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->get_property(\'summary.config.product.version\') ge 5');
												# Exit Message Packet Errors Rx
												($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'packet_errors', 'ge', $exit_state, "$current_nic Packet Errors Rx", $perf_data->{$current_nic}->{errorsRx});
												$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
												$exit_message_to_add = Build_Message($exit_message_to_add, ' {Packet Errors (Rx:' . Format_Number_With_Commas($perf_data->{$current_nic}->{errorsRx}) . $message_to_add . ')');
												
												# Exit Message Packet Errors Tx
												($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'packet_errors', 'ge', $exit_state, "$current_nic Packet Errors Tx", $perf_data->{$current_nic}->{errorsTx});
												$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
												$exit_message_to_add = Build_Message($exit_message_to_add, '(Tx:' . Format_Number_With_Commas($perf_data->{$current_nic}->{errorsTx}) . $message_to_add . ')}');
												} # End if ($target_host_view->summary->config->product->version ge 5) {
											} # End if (defined($perfdata_options_selected->{'NIC_Packet_Errors'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'NIC_Packet_Errors\'})');
											} # End else {

										# End exit_message_to_add
										$exit_message_to_add = Build_Message($exit_message_to_add, ']');
										} # End if ($current_nic eq $known_nic) {
									} # End foreach my $known_nic (keys %pnic_all) {
								
								# Determine if the user provided nic could not be found
								if ($detection_check eq 'no') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check eq \'no\'');
									$exit_message_to_add = "[NIC \'$current_nic\' could not be found!]";
									$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
									} # End if ($detection_check eq 'no') {
								
								# Exit Message Appended
								$exit_message = Build_Message($exit_message, $exit_message_to_add, ',');
								#$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
								} # End foreach my $current_nic (@nic_names) {
							
							# Exit Message With Perfdata
							$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
							} # End case 'pnic' {
						} # End switch ($_[2]) {
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag == 0) {
			
			return Process_Request_Type($_[0], $exit_message, $exit_state);
			} #End sub Host_NIC_Usage {


		sub Host_OS_Name_Version {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_OS_Name_Version');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					$exit_message = $target_host_view->get_property('summary.config.product.fullName');
					$exit_state = 'OK';
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag = 0) {
			
			return ($exit_message, $exit_state);
			} # End sub Host_OS_Name_Version {


		sub Host_Select {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Select');
			$exit_state_abort = 'OK';
			# We need to identify if we are connected to a vCenter Server or an ESX(i) Host
			$target_server_type = Server_Type();
			
			# Get the property filter
			my @target_properties = @{$_[0]};
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Select @target_properties: \'' . @target_properties . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Select @target_properties values: \'' . join(", ", @target_properties) . '\'');

			# Get the host
			if ($target_server_type eq 'VirtualCenter') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type eq \'VirtualCenter\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' host connected via vCenter server');
				# We are connected to an ESX(i) host via a vCenter server
				# Determine if we were passed the host name by a user argument or internally
				if ($_[1]) {
					Debug_Process('append', 'Line ' . __LINE__ . ' host name passed internally');
					# Passed internally
					$target_host_option = $_[1];
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_option: \'' . $target_host_option . '\'');
					$target_host_view = Vim::get_view (
						mo_ref		=> $target_host_option,
						properties	=> [ @target_properties ]
						); # End $target_host_view = Vim::get_view (
					} # End if ($_[1]) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' host name is going to be obtained by --host argument');
					# Passed by a user argument
					# Need to make sure the --host argument has been provided
					if (!Opts::option_is_set('host')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'host\')');
						Debug_Process('append', 'Line ' . __LINE__ . ' The --host argument was not provided, abort');
						# The --host argument was not provided, abort
						$exit_message_abort = "You are connected to a vCenter server and the --host argument was not provided, aborting!";
						$exit_state_abort = 'UNKNOWN';
						} # End if (!Opts::option_is_set('host')) {
					else {
						$target_host_option = Opts::get_option('host');
						Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_option: \'' . $target_host_option . '\'');

						# Apply the request modifier if it exists
						$target_host_option = Modifiers_Process('request', $target_host_option);

						$target_host_view = Vim::find_entity_view (
							view_type 	=> 'HostSystem',
							filter 		=> {
								name 	=> $target_host_option 
								},
							properties	=> [ @target_properties ]
							); # End $target_host_view = Vim::find_entity_view (
						} # End else {
					} # End else {
				} # End if ($target_server_type eq 'VirtualCenter') {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' host connected directly');
				# We are connected directly to an ESX(i) host
				$target_host_option = Opts::get_option('server');
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_option: \'' . $target_host_option . '\'');
				$target_host_view = Vim::find_entity_view (
					view_type 	=> 'HostSystem',
					properties	=> [ @target_properties ]
					); # End $target_host_view = Vim::find_entity_view (
				} # End else {

			if ($exit_state_abort ne 'UNKNOWN') {
				# Make sure we were able to find the host
				if (!$target_host_view) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !$target_host_view');
					Debug_Process('append', 'Line ' . __LINE__ . ' Host was not found, aborting');
					# Host was not found, aborting
					$exit_message_abort =  "Host \'" . $target_host_option . "\' not found";
					$exit_state_abort = 'UNKNOWN';
					} # End if (!$target_host_view) {
				else {
					# Get the host powerState
					my $host_power_state = $target_host_view->get_property('summary.runtime.powerState')->val;
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_power_state: \'' . $host_power_state . '\'');

					Debug_Process('append', 'Line ' . __LINE__ . ' Check to see if the host is in standBy');
					if ($host_power_state eq 'standBy') {
						Debug_Process('append', 'Line ' . __LINE__ . ' if ($host_power_state eq \'standBy\') {');
						$exit_state_abort = 'STANDBY';
						} # End if ($host_power_state eq 'standBy') {
					
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
					} # End else {
				} # End if ($exit_state_abort ne 'UNKNOWN') {

			return ($target_host_view, $exit_message_abort, $exit_state_abort);
			} # End sub Host_Select {


		sub Host_Status {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Status');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');

			my $host_status_flag = 0;
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_status_flag: \'' . $host_status_flag . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Get the $host_maintenance_mode
			my $host_maintenance_mode = $target_host_view->get_property('summary.runtime.inMaintenanceMode');
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode: \'' . $host_maintenance_mode . '\'');
			
			# Determine if the host is currently responding
			if ($host_connection_state eq 'notResponding') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state eq \'notResponding\'');
				# See if the host is in maintenance mode
				if ($host_maintenance_mode eq 'true') {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode eq \'true\'');
					# If it's in maintenance mode then it's probably expected
					$exit_message = 'Host NOT responding, currently in Maintenance Mode';
					$exit_state = 'WARNING';
					$host_status_flag = 1;
					} # End if ($host_maintenance_mode eq 'true') {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode ne \'true\'');
					# Otherwise it's possibly a more severe problem
					$exit_message = 'Host NOT responding, NOT in Maintenance Mode';
					$exit_state = 'CRITICAL';
					$host_status_flag = 1;
					} # End else {
				} # End if ($host_connection_state eq 'notResponding') {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' Seeing as the host is connected lets see what else is happening');
				# Seeing as the host is connected lets see what else is happening
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
				
					# Get the host overallStatus
					my $host_status = $target_host_view->get_property('summary.overallStatus')->val;
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_status: \'' . $host_status . '\'');
					
					# Check if there are any host issues
					my $host_issues = Host_Issues($target_host_view);
					
					# If any host config issues were detected create the exit_message and exit_state
					if (defined($host_issues)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_issues)');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_issues: \'' . $host_issues . '\'');
						if ($host_status ne 'green') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_status ne \'green\'');
							# First we define the exit_message_to_add and exit_state_to_add
							$exit_message_to_add = 'Host has a ' . uc($host_status) . ' status {';
							$exit_state_to_add = $Overall_Status{$host_status};
							$host_status_flag = 1;
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_status_flag: \'' . $host_status_flag . '\'');
							} # End if ($host_status ne 'green') {
						if ($host_status_flag == 1) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_status_flag == 1');
							# Now we create/build the exit_message and exit_state
							$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
							$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
							$exit_message = $exit_message . $host_issues;
							$exit_message = $exit_message . '}';
							} # End if ($host_status_flag == 1) {
						} # End if (defined($host_issues)) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' !defined($host_issues)');
						} # End else {
					
					# Get the host_triggered_alarm_state
					if (defined($target_host_view->get_property('triggeredAlarmState'))) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($target_host_view->get_property(\'triggeredAlarmState\'))');
						my $host_triggered_alarm_state = $target_host_view->get_property('triggeredAlarmState');
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_triggered_alarm_state: \'' . $host_triggered_alarm_state . '\'');
						my $host_triggered_alarms_total = @$host_triggered_alarm_state;
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_triggered_alarms_total: \'' . $host_triggered_alarms_total . '\'');
						# Start the Alarms message
						$exit_message = Build_Message($exit_message, "{Alarms Total: $host_triggered_alarms_total");
						
						# Now loop through all the triggered alarms
						Debug_Process('append', 'Line ' . __LINE__ . ' Processing triggered alarms');
						my $triggered_alarm_count = 0;
						foreach my $triggered_alarm (@$host_triggered_alarm_state) {
							$triggered_alarm_count++;
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_count: \'' . $triggered_alarm_count . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm: \'' . $triggered_alarm . '\'');
							# Get the alarm status
							my $triggered_alarm_overall_status = $triggered_alarm->{'overallStatus'}->val;
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_overall_status: \'' . $triggered_alarm_overall_status . '\'');
							# Has the alarm been acknowledged
							my $triggered_alarm_acknowledged = $triggered_alarm->{'acknowledged'};
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_acknowledged: \'' . $triggered_alarm_acknowledged . '\'');
							# When was the alarm triggered?
							my $triggered_alarm_time = $triggered_alarm->{'time'};
							Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_time: \'' . $triggered_alarm_time . '\'');
							# Calculate the age of the alarm
							my $alarm_time_difference = sprintf("%0.f", ((localtime->epoch - str2time($triggered_alarm_time)) / 86400));

							Debug_Process('append', 'Line ' . __LINE__ . ' $alarm_time_difference before check: \'' . $alarm_time_difference . '\'');
							
							# Check to make sure this isn't -0
							if ($alarm_time_difference == -0) {
								$alarm_time_difference = 0;
								} # End if ($alarm_time_difference == -0) {

							Debug_Process('append', 'Line ' . __LINE__ . ' $alarm_time_difference after check: \'' . $alarm_time_difference . '\'');
							
							# Build the message for this alarm
							$exit_message = Build_Message($exit_message, " (#$triggered_alarm_count:");
							if ($triggered_alarm_acknowledged == 0) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_acknowledged == 0');
								# Build the message for this alarm
								$exit_message = Build_Message($exit_message, " NOT Acknowledged, $triggered_alarm_overall_status=$Overall_Status{$triggered_alarm_overall_status}");
								$exit_state = Build_Exit_State($Overall_Status{$triggered_alarm_overall_status});
								$host_status_flag = 1;
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_status_flag: \'' . $host_status_flag . '\'');
								} # End if ($triggered_alarm_acknowledged == 0) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' $triggered_alarm_acknowledged != 0');
								$exit_message = Build_Message($exit_message, " Acknowledged, $triggered_alarm_overall_status");
								$exit_state = Build_Exit_State($exit_state, "OK");
								} # End else {
								
							# Build the message for this alarm
							$exit_message = Build_Message($exit_message, ", Age: $alarm_time_difference " . Process_Plural($alarm_time_difference, 'Today', 'Day', 'Days') . ")");
							} # End foreach my $triggered_alarm (@$host_triggered_alarm_state) {
						$exit_message = Build_Message($exit_message, "}");
						} # End if (defined($target_host_view->get_property('triggeredAlarmState'))) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($target_host_view->get_property(\'triggeredAlarmState\'))');
						} # End else {


					# See if the host is in maintenance mode
					if ($host_maintenance_mode eq 'true') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode eq \'true\'');
						$exit_message = Build_Exit_Message('Exit', $exit_message, 'Host in Maintenance Mode');
						$exit_state = Build_Exit_State($exit_state, 'OK');
						$host_status_flag = 1;
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_status_flag: \'' . $host_status_flag . '\'');
						} # End if ($host_maintenance_mode eq 'true') {
					} # End if ($host_uptime_state_flag == 0) {
				} # End else {
			
			# If no problems were detected define the $exit_message and $exit_state
			if ($host_status_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_status_flag == 0');
				$exit_message = 'No problems detected';
				$exit_state = 'OK';
				} # End if ($host_status_flag == 0) {
			
			return ($exit_message, $exit_state);
			} # End sub Host_Status {

		
		sub Host_Storage_Adapter {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Storage_Adapter');
			$target_host_view = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
			
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[1]: \'' . $_[1] . '\'');
					# Proceed as the host is UP
					# Perform the requested action
					switch ($_[1]) {
						case 'Info' {
							my @hba_names;
							# Determine if the --name argument was provided
							if (Opts::option_is_set('name')) {
								Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'name\')');
								# Put the options into an array
								@hba_names = split(/,/, Opts::get_option('name'));
								} # End if (Opts::option_is_set('name')) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' All HBAs will be reported on');
								# All HBAs will be reported on
								@hba_names = 'all';
								} # End else {

							Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names: \'' . @hba_names . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names values: \'' . join(", ", @hba_names) . '\'');
					
							# Get the $target_host_view_storage_system
							my $target_host_view_storage_system = $target_host_view->get_property('configManager.storageSystem');
							Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_storage_system: \'' . $target_host_view_storage_system . '\'');
							
							# Get the $host_storage_system
							my $host_storage_system = Vim::get_view(
								mo_ref		=>	$target_host_view_storage_system,
								properties	=> [ 'storageDeviceInfo.hostBusAdapter' ]
								); # End my $host_storage_system = Vim::get_view(
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_storage_system: \'' . $host_storage_system . '\'');
							
							Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the @hba_names array to determine which ones to report on');
							# Loop through the @hba_names array to determine which ones to report on (all by default)
							foreach my $hba_name (@hba_names) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $hba_name: \'' . $hba_name . '\'');
								my $detection_check = 'no';
								Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');

								Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the HBA\'s on the host');
								# Loop through the HBA's on the host
								foreach my $hba (@{$host_storage_system->get_property('storageDeviceInfo.hostBusAdapter')}) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $hba: \'' . $hba . '\'');
									my $hba_device = $hba->device;
									Debug_Process('append', 'Line ' . __LINE__ . ' $hba_device: \'' . $hba_device . '\'');
									# See if the $hba_name matches the $hba_device
									if ($hba_name =~ /^($hba_device|all)$/) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $hba_name =~ /^($hba_device|all)$/');
										$detection_check = 'yes';
										Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
										
										# I would really like to report on driver version however this info is not available via the SDK.
										
										$exit_message_to_add = '[' . $hba->model . " (" . $hba->device . ") {Driver: " . $hba->driver . "}]";
										$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
										$exit_state = Build_Exit_State($exit_state, 'OK');
										} # End if ($hba_name =~ /^($hba_device|all)$/) {
									} # End foreach my $hba (@{$host_storage_system->storageDeviceInfo->hostBusAdapter}) {
								
								# Determine if the user provided HBA could not be found
								if ($detection_check eq 'no') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check eq \'no\'');
									$exit_message_to_add = "[Storage Adapter \'$hba_name\' could not be found!]";
									$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
									$exit_state = Build_Exit_State($exit_state, 'UNKNOWN');
									} # End if ($detection_check eq 'no') {
								} # End foreach my $hba_name (@hba_names) {
							} # End case 'Info' {
						
						
						case 'Performance' {
							my %Perfdata_Options = %{$_[3]};
							(my $perfdata_options_selected, my $requested_perf_counter_keys) = Perfdata_Option_Process('metric_counters', \%Perfdata_Options);
					
							# The returned perfdata will be put in here
							my $perf_data;
							
							# Get any user supplied thresholds
							my %Thresholds_User = Thresholds_Get();
							Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');
							
							my @hba_names;
							# Determine if the --name argument was provided
							if (Opts::option_is_set('name')) {
								Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'name\')');
								# Put the options into an array
								@hba_names = split(/,/, Opts::get_option('name'));

								Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names: \'' . @hba_names . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' @nic_names values: \'' . join(", ", @hba_names) . '\'');
					
								# Get the $target_host_view_storage_system
								my $target_host_view_storage_system = $target_host_view->get_property('configManager.storageSystem');
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_storage_system: \'' . $target_host_view_storage_system . '\'');
								
								# Get the $host_storage_system
								my $host_storage_system = Vim::get_view(
									mo_ref	=>	$target_host_view_storage_system,
									properties	=> [ 'storageDeviceInfo.hostBusAdapter' ]
									); # End my $host_storage_system = Vim::get_view(
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_storage_system: \'' . $host_storage_system . '\'');
								
								# Check to see if this HBA exists
								my $hba_requested_info;
								my $instance;
								Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the requested HBA names');
								# Loop through the requested HBA names
								foreach my $hba_requested_name (@hba_names) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $hba_requested_name: \'' . $hba_requested_name . '\'');
									my $host_hba_check = 'no';
									Debug_Process('append', 'Line ' . __LINE__ . ' $host_hba_check: \'' . $host_hba_check . '\'');
									Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the HBA\'s on the host');
									# Loop through the HBA's on the host
									foreach my $hba (@{$host_storage_system->get_property('storageDeviceInfo.hostBusAdapter')}) {
										Debug_Process('append', 'Line ' . __LINE__ . ' $hba: \'' . $hba . '\'');
										if ($hba_requested_name eq $hba->device) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $hba_requested_name eq $hba->device');
											$hba_requested_info->{$hba->device} = $hba;
											$instance = $hba->device;
											$host_hba_check = 'yes';
											Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
											Debug_Process('append', 'Line ' . __LINE__ . ' $host_hba_check: \'' . $host_hba_check . '\'');
											last;
											} # End if ($hba_requested_name eq $hba->device) {
										} # End foreach my $hba (@{$host_storage_system->storageDeviceInfo->hostBusAdapter}) {
									
									# Proceed if the HBA exists on this host
									if ($host_hba_check eq 'yes') {
										Debug_Process('append', 'Line ' . __LINE__ . ' $host_hba_check eq \'yes\'');
										# Get the Perfdata
										(my $perf_data_requested, my $perf_counters_used) = Perfdata_Retrieve($target_host_view, 'storageAdapter', $instance, \@$requested_perf_counter_keys);
										# Process the Perfdata
										$perf_data->{$instance} = Perfdata_Process($perf_data_requested, $perf_counters_used);
										
										# Start exit_message_to_add
										$exit_message_to_add = '[' . $hba_requested_info->{$instance}->model . " ($instance)";
										
										# Determine if HBA_Rate should be reported
										if (defined($perfdata_options_selected->{'HBA_Rate'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'HBA_Rate\'})');
											# Determine what SI to use for HBA_Rate
											my $si_hba_rate = SI_Get('HBA_Rate', 'kBps');
											Debug_Process('append', 'Line ' . __LINE__ . ' $si_hba_rate: \'' . $si_hba_rate . '\'');
											
											# Define the HBA_Rate variables
											my $hba_read = SI_Process('HBA_Rate', 'kBps', $si_hba_rate, $perf_data->{$instance}->{read});
											Debug_Process('append', 'Line ' . __LINE__ . ' $hba_read: \'' . $hba_read . '\'');
											my $hba_write = SI_Process('HBA_Rate', 'kBps', $si_hba_rate, $perf_data->{$instance}->{write});
											Debug_Process('append', 'Line ' . __LINE__ . ' $hba_write: \'' . $hba_write . '\'');
											# Get the HBA_Rate percentages
											(my $hba_read_percentage, my $hba_write_percentage) = Process_Percentages($hba_read, $hba_write);

											# Exit Message HBA Rate Read
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'hba_rate', 'ge', $exit_state, "$instance Rate Read", $hba_read, $si_hba_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Rate (Read:' . Format_Number_With_Commas($hba_read) . " $si_hba_rate / $hba_read_percentage%" . $message_to_add . ')');
											
											# Exit Message HBA Rate Write
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'hba_rate', 'ge', $exit_state, "$instance Rate Write", $hba_write, $si_hba_rate);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Write:' . Format_Number_With_Commas($hba_write) . " $si_hba_rate / $hba_write_percentage%" . $message_to_add . ')}');
											} # End if (defined($perfdata_options_selected->{'HBA_Rate'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'HBA_Rate\'})');
											} # End else {

										# Determine if Averaged should be reported
										if (defined($perfdata_options_selected->{'Averaged'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'Averaged\'})');
											# Exit Message HBA Average Number of Reads
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$instance Average Number of Reads", $perf_data->{$instance}->{numberReadAveraged});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Averaged Number of (Reads:' . Format_Number_With_Commas($perf_data->{$instance}->{numberReadAveraged}) . ')');
											
											# Exit Message HBA Average Number of Writes
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'none', 'none', $exit_state, "$instance Average Number of Writes", $perf_data->{$instance}->{numberWriteAveraged});
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Writes:' . Format_Number_With_Commas($perf_data->{$instance}->{numberWriteAveraged}) . ')}');
											} # End if (defined($perfdata_options_selected->{'Averaged'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'Averaged\'})');
											} # End else {

										# Determine if HBA_Latency should be reported
										if (defined($perfdata_options_selected->{'HBA_Latency'})) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($perfdata_options_selected->{\'HBA_Latency\'})');
											# Determine what SI to use for latency
											my $si_latency = SI_Get('Latency', 'ms');
											Debug_Process('append', 'Line ' . __LINE__ . ' $si_latency: \'' . $si_latency . '\'');
											# Define the Latency variables
											my $hba_total_read_latency = SI_Process('Time', 'ms', $si_latency, $perf_data->{$instance}->{totalReadLatency});
											Debug_Process('append', 'Line ' . __LINE__ . ' $hba_total_read_latency: \'' . $hba_total_read_latency . '\'');
											my $hba_total_write_latency = SI_Process('Time', 'ms', $si_latency, $perf_data->{$instance}->{totalWriteLatency});
											Debug_Process('append', 'Line ' . __LINE__ . ' $hba_total_write_latency: \'' . $hba_total_write_latency . '\'');

											# Exit Message HBA Latency Total Read
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'hba_latency', 'ge', $exit_state, "$instance Latency Total Read", $hba_total_read_latency, $si_latency);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, ' {Total Latency (Read:' . Format_Number_With_Commas($hba_total_read_latency) . " $si_latency" . $message_to_add . ')');
											
											# Exit Message HBA Latency Total Write
											($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'hba_latency', 'ge', $exit_state, "$instance Latency Total Write", $hba_total_write_latency, $si_latency);
											$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
											$exit_message_to_add = Build_Message($exit_message_to_add, '(Write:' . Format_Number_With_Commas($hba_total_write_latency) . " $si_latency" . $message_to_add . ')}');
											} # End if (defined($perfdata_options_selected->{'HBA_Latency'})) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' NOT defined($perfdata_options_selected->{\'HBA_Latency\'})');
											} # End else {

										# End exit_message_to_add
										$exit_message_to_add = Build_Message($exit_message_to_add, ']');
										
										# Exit Message Appended
										$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
										} # End if ($host_hba_check eq 'yes') {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' Could not find the requested HBA');
										# Could not find the requested HBA
										$exit_message_to_add = '[Storage Adapter \'' . $hba_requested_name . '\' was NOT found on this host!]';
										$exit_message = Build_Exit_Message('Exit', $exit_message, $exit_message_to_add);
										$exit_state = Build_Exit_State($exit_state, 'UNKNOWN');
										} # End else {
									} # End foreach my $hba_requested_name (@hba_names) {
								
								# Exit Message With Perfdata
								$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
								} # End if (!Opts::option_is_set('name')) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' You must provide a HBA Name using the --name argument, aborting!');
								$exit_message = 'You must provide a HBA Name using the --name argument, aborting!';
								$exit_state = Build_Exit_State($exit_state, 'UNKNOWN');
								} # End else {
							} # End case 'Performance' {
						} # End switch ($_[1]) {
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag == 0) {
			return Process_Request_Type($_[0], $exit_message, $exit_state);
			} # End sub Host_Storage_Adapter {


		sub Host_Switch {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Switch');
			$target_host_view = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');
						
			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Proceed if the host is connected
			if ($host_connection_state_flag == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state_flag == 0');
				# Get the host uptime
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Proceed as the host is UP
					# Get the $target_host_view_network_system
					my $target_host_view_network_system = $target_host_view->get_property('configManager.networkSystem');
					Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view_network_system: \'' . $target_host_view_network_system . '\'');
					
					# Get the $host_network_system
					my $host_network_system = Vim::get_view(
						mo_ref		=>	$target_host_view_network_system,
						properties	=> [ 'networkInfo.vswitch', 'networkInfo.proxySwitch', 'networkInfo.pnic' ]
						); # End my $host_network_system = Vim::get_view(
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system: \'' . $host_network_system . '\'');
					
					# Create the pnic_all hash
					my %pnic_all = Host_Hardware('pnic_all', $host_network_system->get_property('networkInfo.pnic'));
					Debug_Process('append', 'Line ' . __LINE__ . ' %pnic_all: \'' . %pnic_all . '\'');
					
					my @switch_names;
					# Determine if the --name argument was provided
					if (Opts::option_is_set('name')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'name\')');
						# Put the options into an array
						@switch_names = split(/,/, Opts::get_option('name'));
						} # End if (!Opts::option_is_set('name')) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' All switches will be returned');
						# All switches will be returned
						Debug_Process('append', 'Line ' . __LINE__ . ' Now loop through each item in the $host_network_system');
						# Now loop through each item in the $host_network_system
						foreach my $host_network_system_item (keys %$host_network_system) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system_item: \'' . $host_network_system_item . '\'');
							# Determine if this is a switch item
							if ($host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/');
								Debug_Process('append', 'Line ' . __LINE__ . ' We need to determine if this is a vswitch or a proxySwitch');
								# We need to determine if this is a vswitch or a proxySwitch
								switch ($host_network_system_item) {
									case 'networkInfo.vswitch' {
										if (defined($host_network_system->get_property($host_network_system_item))) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_network_system->get_property($host_network_system_item))');
											foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item: \'' . $current_switch_item . '\'');
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item->name: \'' . $current_switch_item->name . '\'');
												push @switch_names, $current_switch_item->name;
												} # End foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
											} # End if (defined($host_network_system->get_property($host_network_system_item))) {
										} #End case 'networkInfo.vswitch' {


									case 'networkInfo.proxySwitch' {
										if (defined($host_network_system->get_property($host_network_system_item))) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_network_system->get_property($host_network_system_item))');
											foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item: \'' . $current_switch_item . '\'');
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item->dvsName: \'' . $current_switch_item->dvsName . '\'');
												push @switch_names, $current_switch_item->dvsName;
												} # End foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
											} # End if (defined($host_network_system->get_property($host_network_system_item))) {
										} # End case 'networkInfo.proxySwitch' {
									} # End switch ($host_network_system_item) {
								} # End if ($host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/) {
							} # End foreach my $host_network_system_item (keys %$host_network_system) {
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' @switch_names: \'' . @switch_names . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @switch_names values: \'' . join(", ", @switch_names) . '\'');

					Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the @switch_names array to determine which ones to report on');	
					# Loop through the @switch_names array to determine which ones to report on (all by default)
					foreach (@switch_names) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
						my $skip_switch;
						my $switch_item;
						my $detection_check = 'no';
						Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');

						Debug_Process('append', 'Line ' . __LINE__ . ' Now loop through each item in the $host_network_system');
						# Now loop through each item in the $host_network_system
						foreach my $host_network_system_item (keys %$host_network_system) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system_item: \'' . $host_network_system_item . '\'');
							# Determine if this is a switch item
							if ($host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/');
								my $switch_name;
								Debug_Process('append', 'Line ' . __LINE__ . ' We need to determine if this is a vswitch or a proxySwitch');
								# We need to determine if this is a vswitch or a proxySwitch
								switch ($host_network_system_item) {
									case 'networkInfo.vswitch' {
										if (defined($host_network_system->get_property($host_network_system_item))) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_network_system->get_property($host_network_system_item))');
											foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item: \'' . $current_switch_item . '\'');
												my $current_switch_item_name = $current_switch_item->name;
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item_name: \'' . $current_switch_item_name . '\'');
												if ($_ eq $current_switch_item_name) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $_ eq $current_switch_item_name');
													$switch_name = $current_switch_item_name;
													Debug_Process('append', 'Line ' . __LINE__ . ' $switch_name: \'' . $switch_name . '\'');

													$switch_item = $current_switch_item;
													Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item: \'' . $current_switch_item . '\'');

													$exit_message = Build_Message($exit_message, "[" . $current_switch_item_name . " {Local}", ', ');
													$skip_switch = 'no';
													Debug_Process('append', 'Line ' . __LINE__ . ' $skip_switch: \'' . $skip_switch . '\'');
													last;
													} # End if ($_ eq $current_switch_item_name) {
												else {
													Debug_Process('append', 'Line ' . __LINE__ . ' Not this vswitch');
													$skip_switch = 'yes';
													Debug_Process('append', 'Line ' . __LINE__ . ' $skip_switch: \'' . $skip_switch . '\'');
													} # End else {
												} # End foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
											} # End if (defined($host_network_system->get_property($host_network_system_item))) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' This item is not a vswitch');
											$skip_switch = 'yes';
											Debug_Process('append', 'Line ' . __LINE__ . ' $skip_switch: \'' . $skip_switch . '\'');
											} # End else {	
										} # End case 'networkInfo.vswitch' {
									

									case 'networkInfo.proxySwitch' {
										if (defined($host_network_system->get_property($host_network_system_item))) {
											Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_network_system->get_property($host_network_system_item))');
											foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item: \'' . $current_switch_item . '\'');
												my $current_switch_item_name = $current_switch_item->dvsName;
												Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item_name: \'' . $current_switch_item_name . '\'');
												if ($_ eq $current_switch_item_name) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $_ eq $current_switch_item_name');
													$switch_name = $current_switch_item_name;
													Debug_Process('append', 'Line ' . __LINE__ . ' $switch_name: \'' . $switch_name . '\'');

													$switch_item = $current_switch_item;
													Debug_Process('append', 'Line ' . __LINE__ . ' $current_switch_item: \'' . $current_switch_item . '\'');
													
													$exit_message = Build_Message($exit_message, "[" . $current_switch_item_name . " {Distributed}", ', ');
													$skip_switch = 'no';
													Debug_Process('append', 'Line ' . __LINE__ . ' $skip_switch: \'' . $skip_switch . '\'');
													last;
													} # End if ($_ eq $current_switch_item_name) {
												else {
													Debug_Process('append', 'Line ' . __LINE__ . ' Not this dvswitch');
													$skip_switch = 'yes';
													Debug_Process('append', 'Line ' . __LINE__ . ' $skip_switch: \'' . $skip_switch . '\'');
													} # End else {
												} # End foreach my $current_switch_item (@{$host_network_system->get_property($host_network_system_item)}) {
											} # End if (defined($host_network_system->get_property($host_network_system_item))) {
										else {
											Debug_Process('append', 'Line ' . __LINE__ . ' This item is not a dvswitch');
											$skip_switch = 'yes';
											Debug_Process('append', 'Line ' . __LINE__ . ' $skip_switch: \'' . $skip_switch . '\'');
											} # End else {
										} # End case 'networkInfo.proxySwitch' {
									} # End switch ($host_network_system_item) {
								
								if ($skip_switch eq 'no') {
									Debug_Process('append', 'Line ' . __LINE__ . ' $skip_switch eq \'no\'');
									$detection_check = 'yes';
									Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check: \'' . $detection_check . '\'');
									
									# Ports
									Debug_Process('append', 'Line ' . __LINE__ . ' Ports');
									Debug_Process('append', 'Line ' . __LINE__ . ' $switch_item->numPorts: \'' . $switch_item->numPorts . '\'');
									Debug_Process('append', 'Line ' . __LINE__ . ' $switch_item->numPortsAvailable: \'' . $switch_item->numPortsAvailable . '\'');
									$exit_message = Build_Message($exit_message, ", Ports {Total: " . $switch_item->numPorts . "} {Available: " . $switch_item->numPortsAvailable . "}");
									# Test the --mtu option
									my $mtu_size = $switch_item->mtu;
									Debug_Process('append', 'Line ' . __LINE__ . ' $mtu_size: \'' . $mtu_size . '\'');
									($exit_state_to_add, $message_to_add) = Test_User_Option('mtu', $mtu_size, 'CRITICAL', 'MTU is', "MTU: {" . Format_Number_With_Commas($mtu_size) . '}', 'no_default');
									$exit_message = Build_Message($exit_message, ", $message_to_add");
									$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);

									Debug_Process('append', 'Line ' . __LINE__ . ' Find all the pnics');
									# Find all the pnics
									if (defined($switch_item->pnic)) {
										Debug_Process('append', 'Line ' . __LINE__ . ' defined($switch_item->pnic)');
										my $pnic_count = 0;
										my $pnic_connected_count = 0;
										my $pnic_disconnected_count = 0;
										Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_count: \'' . $pnic_count . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_connected_count: \'' . $pnic_connected_count . '\'');
										Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_disconnected_count: \'' . $pnic_disconnected_count . '\'');
										$message_to_add = '';

										Debug_Process('append', 'Line ' . __LINE__ . ' Loop through all the pnics');
										# Loop through all the pnics
										foreach (@{$switch_item->pnic}) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
											$message_to_add = Build_Message($message_to_add, '{' . $pnic_all{$_}->device . ', Driver: ' . $pnic_all{$_}->driver, ' ');
											# Checking to see if the pnic is connected
											if (!defined($pnic_all{$_}->linkSpeed)) {
												Debug_Process('append', 'Line ' . __LINE__ . ' !defined($pnic_all{$_}->linkSpeed)');
												if (Opts::option_is_set('nic_state')) {
													Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'nic_state\')');
													# Test the --nic_state option
													# Using the Test_User_Option sub to generate an exit code
													($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_state', 'disconnected', 'CRITICAL', 'NIC is', 'NOT Connected', 'connected');
													$message_to_add = Build_Message($message_to_add, ', NOT Connected}');
													} # End if (Opts::option_is_set('nic_state')) {
												else {
													Debug_Process('append', 'Line ' . __LINE__ . ' NIC is disconnected');
													$exit_state_to_add = 'CRITICAL';
													} # End else {
												$pnic_disconnected_count++;
												Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_disconnected_count: \'' . $pnic_disconnected_count . '\'');
												$message_to_add = Build_Message($message_to_add, ', NOT Connected}');	
												$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
												} # End if (!defined($pnic_all{$_}->linkSpeed)) {
											else {
												Debug_Process('append', 'Line ' . __LINE__ . ' NIC is Connected');
												# It's connected
												# Test the --nic_speed option
												my $nic_speed = $pnic_all{$_}->linkSpeed->speedMb;
												Debug_Process('append', 'Line ' . __LINE__ . ' $nic_speed: \'' . $nic_speed . '\'');
												($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_speed', $nic_speed, 'CRITICAL', 'NIC Speed is', Format_Number_With_Commas($nic_speed) . " MB", 'no_default');
												$message_to_add = Build_Message($message_to_add, ", $exit_message_to_add");
												$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
												# Check the speed and duplex
												if ($pnic_all{$_}->linkSpeed->duplex == 0) {
													Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_all{$_}->linkSpeed->duplex == 0');
													# Test the --nic_duplex option
													($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_duplex', 'half', 'CRITICAL', 'NIC Speed is', 'Half Duplex', 'full');
													} # End if ($pnic_all{$_}->linkSpeed->duplex == 0) {
												else {
													Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_all{$_}->linkSpeed->duplex != 0');
													# Test the --nic_duplex option
													($exit_state_to_add, $exit_message_to_add) = Test_User_Option('nic_duplex', 'full', 'CRITICAL', 'NIC Speed is', 'Full Duplex', 'full');
													} # End else {
												$message_to_add = Build_Message($message_to_add, ", $exit_message_to_add}");
												$exit_state = Build_Exit_State($exit_state, $exit_state_to_add);
												$pnic_connected_count++;
												Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_connected_count: \'' . $pnic_connected_count . '\'');
												} # End else {
											$pnic_count++;
											Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_count: \'' . $pnic_count . '\'');
											} # End foreach (@{$switch_item->pnic}) {
										
										# Add the total pnic count to the $exit_message
										my $nic_message = "NICs: {Total: $pnic_count";
										if ($pnic_connected_count > 0) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_connected_count > 0');
											# Add the connected pnic count to the $exit_message
											$nic_message = Build_Message($nic_message, ", Connected: $pnic_connected_count");
											} # End if ($pnic_connected_count > 0) {
										if ($pnic_disconnected_count > 0) {
											Debug_Process('append', 'Line ' . __LINE__ . ' $pnic_disconnected_count > 0');
											# Add the disconnected pnic count to the $exit_message
											$nic_message = Build_Message($nic_message, ", Disconnected: $pnic_disconnected_count");
											} # End if ($pnic_disconnected_count > 0) {
										$nic_message = Build_Message($nic_message, "}");
										$exit_message = Build_Message($exit_message, ", $nic_message $message_to_add]");
										} # End if (defined($switch_item->pnic)) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' No Physical NICs');
										$exit_message = Build_Message($exit_message, ', NICs: {No Physical NICs}]');
										} # End else {
									} # End if ($skip_switch eq 'no') {
								} # End if ($host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/) {
							} # End foreach my $host_network_system_item (keys %$host_network_system) {
						
						# Determine if the user provided switch could not be found
						if ($detection_check eq 'no') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $detection_check eq \'no\'');
							$exit_message_to_add = "[Switch \'$_\' could not be found!]";
							$exit_message = Build_Message($exit_message, $exit_message_to_add);
							$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
							} # End if ($detection_check eq 'no') {
						} # End foreach (@switch_names) {
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($host_connection_state_flag == 0) {
					
			return Process_Request_Type($_[0], $exit_message, $exit_state);
			} # End sub Host_Switch {


		sub Host_Up_Down_State {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Up_Down_State');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');

			# Get the Host Connection State
			($host_connection_state, $host_connection_state_flag, $exit_message, $exit_state) = Host_Connection_State($target_host_view);
			
			# Get the $host_maintenance_mode
			my $host_maintenance_mode = $target_host_view->get_property('summary.runtime.inMaintenanceMode');
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode: \'' . $host_maintenance_mode . '\'');
			
			# Get the host powerState
			my $host_power_state = $target_host_view->get_property('summary.runtime.powerState')->val;
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_power_state: \'' . $host_power_state . '\'');

			# Start with a fresh exit message
			$exit_message = '';
			
			# Start with a fresh exit state
			$exit_state = '';
			
			Debug_Process('append', 'Line ' . __LINE__ . ' Check to see if the host is in standBy');
			if ($host_power_state eq 'standBy') {
				Debug_Process('append', 'Line ' . __LINE__ . ' if ($host_power_state eq \'standBy\') {');

				# Determine if user wants standby to be down
				if (Opts::option_is_set('standby_exit_state')) {
					Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'standby_exit_state\')');
					my $standby_exit_state = Opts::get_option('standby_exit_state');
					Debug_Process('append', 'Line ' . __LINE__ . ' $standby_exit_state: \'' . $standby_exit_state . '\'');
					if ($standby_exit_state eq 'down') {
						Debug_Process('append', 'Line ' . __LINE__ . ' $standby_exit_state eq \'down\'');
						$exit_state = 'DOWN';
						} # End if ($standby_exit_state eq 'down') {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $standby_exit_state ne \'down\'');
						$exit_state = 'STANDBY';
						} # End else {
					} # End if (Opts::option_is_set('standby_exit_state')) {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'standby_exit_state\')');
					$exit_state = 'STANDBY';
					} # End else {

				$exit_message = Build_Message($exit_message, 'Host in StandBy mode');
				} # End if ($host_power_state eq 'standBy') {
			elsif ($host_connection_state eq 'notResponding') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state eq \'notResponding\'');
				$exit_message = Build_Message($exit_message, 'Host NOT responding');
				$exit_state = 'DOWN';
				} # End elsif ($host_connection_state eq 'notResponding') {
			elsif ($host_connection_state eq 'disconnected') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_connection_state eq \'notResponding\'');
				$exit_message = Build_Message($exit_message, 'Host DISCONNECTED');
				$exit_state = 'DOWN';
				} # End elsif ($host_connection_state eq 'disconnected') {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' The host is connected');
				$exit_message = Build_Message($exit_message, 'Host is Up');
				$exit_state = 'UP';
				} # End else {

			# See if the host is in maintenance mode
			if ($host_maintenance_mode eq 'true') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_maintenance_mode eq \'true\'');
				$exit_message = Build_Message($exit_message, 'in Maintenance Mode', ', ');
				} # End if ($host_maintenance_mode eq 'true') {

			# If the host is up add host uptime information
			if ($exit_state eq 'UP') {
				Debug_Process('append', 'Line ' . __LINE__ . ' elsif ($exit_state eq \'UP\') {');
				($host_uptime_state_flag, $exit_message, $exit_state) = Host_Uptime_State($target_host_view);
				if ($host_uptime_state_flag == 0) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag == 0');
					# Add uptime to the exit message and generate performace data

					# Get any user supplied thresholds
					my %Thresholds_User = Thresholds_Get();
					Debug_Process('append', 'Line ' . __LINE__ . ' %Thresholds_User: \'' . %Thresholds_User . '\'');

					# Determine if the ESX host is version 4.1 or greater for Uptime Stats
					if ($target_host_view->get_property('summary.config.product.version') ge 4.1) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->get_property(\'summary.config.product.version\') ge 4.1');
						# Determine what SI to use for Uptime
						my $si_uptime = SI_Get('Time', 'd');
						# Get the uptime value
						my $host_uptime_value = SI_Process('Time', 's', $si_uptime, $target_host_view->get_property('summary.quickStats.uptime'));
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_value: \'' . $host_uptime_value . '\'');
						# Only need 1 decimal place 
						$host_uptime_value = sprintf("%.1f", $host_uptime_value);
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_value: \'' . $host_uptime_value . '\'');
						# The human readable version
						my $si_uptime_human = $SI_Time_Human{$si_uptime};
						if ($host_uptime_value > 1) {
							$si_uptime_human .= 's';
							} # End if ($host_uptime_value > 1) {
						
						# Exit Message Uptime
						($perfdata_message_to_add, $message_to_add, $exit_state) = Build_Perfdata_Message('Create', \%Thresholds_User, 'uptime', 'le', $exit_state, "Uptime", $host_uptime_value, $si_uptime);
						$perfdata_message = Build_Perfdata_Message('Build', $perfdata_message, $perfdata_message_to_add);
						$exit_message = Build_Message($exit_message, ', Uptime: ' . Format_Number_With_Commas($host_uptime_value) . ' ' . $si_uptime_human . $message_to_add);
						} # End if ($target_host_view->summary->config->product->version ge 4.1) {

					# Add the host version to the message
					$exit_message = Build_Message($exit_message, ', Version: ' . $target_host_view->get_property('summary.config.product.fullName'));

					# Determine if the ESX host is version 4.1 or greater for Perfdata (uptime related)
					if ($target_host_view->get_property('summary.config.product.version') ge 4.1) {
						# Exit Message With Perfdata
						$exit_message = Build_Exit_Message('Perfdata', $exit_message, $perfdata_message);
						} # End if ($target_host_view->summary->config->product->version ge 4.1) {
					} # End if ($host_uptime_state_flag == 0) {
				} # End if ($exit_state eq 'UP') {
			return ($exit_message, $exit_state);
			} # End sub Host_Up_Down_State {


		sub Host_Uptime_State {
			Debug_Process('append', 'Line ' . __LINE__ . ' Host_Uptime_State');
			$target_host_view = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view: \'' . $target_host_view . '\'');


			# Determine if the ESX host is version 4.1 or greater for Uptime Stats
			if ($target_host_view->get_property('summary.config.product.version') ge 4.1) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->get_property(\'summary.config.product.version\') ge 4.1');
				# Get the host uptime
				$host_uptime = $target_host_view->get_property('summary.quickStats.uptime');
				if (!defined($host_uptime)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !defined($host_uptime)');
					# The host is powered off or not accessible
					$host_uptime_state_flag = 1;
					$exit_message = 'Host is powered OFF or is not accesible, cannot collect data!';
					$exit_state = 'UNKNOWN';
					} # End if (!defined($host_uptime)) {
				elsif (defined($host_uptime)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' defined($host_uptime)');
					# Is the host_uptime a valid value?
					if ($host_uptime == 0) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime == 0');
						# The host has been up for 0 seconds which usually indicates the agent and vCenter are not communicating
						$host_uptime_state_flag = 1;
						$exit_message = 'Host has an Uptime of 0 seconds, cannot collect data!';
						$exit_state = 'CRITICAL';
						} # End if ($host_uptime == 0) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime: \'' . $host_uptime . '\'');
						# It's a valid value
						$host_uptime_state_flag = 0;
						} # End else {
					} # End elsif (defined($host_uptime)) {
				} # End if ($target_host_view->summary->config->product->version ge 4.1) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->get_property(\'summary.config.product.version\') lt 4.1');
				# Uptime was not added to the vSphere API until version 4.1
				$host_uptime_state_flag = 0;
				} # End else {
				
			
			
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_uptime_state_flag: \'' . $host_uptime_state_flag . '\'');
			if (defined($exit_message)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'' . $exit_message . '\'');
				} # End if (defined($exit_message)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message: \'\'');
				} # End else {
			if (defined($exit_state)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'' . $exit_state . '\'');
				} # End if (defined($exit_state)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state: \'\'');
				} # End else {
			return ($host_uptime_state_flag, $exit_message, $exit_state)
			} # End sub Host_Uptime_State {


		sub List_Datastore_Clusters {
			Debug_Process('append', 'Line ' . __LINE__ . ' List_Datastore_Clusters');
			# Get all the datastore_clusters
			my $target_datastore_cluster_views = Vim::find_entity_views (
				view_type	=> 'StoragePod',
				properties	=> ['summary.name', 'summary.capacity'],
				); # End $target_datastore_cluster_views = Vim::find_entity_view (

			# Sort the results
			my @target_datastore_cluster_views_sorted = sort { lc($a->{'summary.name'}) cmp lc($b->{'summary.name'}) } @$target_datastore_cluster_views;
			
			# Build a JSON of all the objects to send back to PHP
			my $target_datastore_cluster_views_json = '{"datastore_clusters":[';
			my $json_counter = 0;

			foreach (@target_datastore_cluster_views_sorted) {
				my $datastore_cluster_name = $_->{'summary.name'};
				#print $datastore_cluster_name . "\n";

				my $datastore_cluster_capacity = $_->{'summary.capacity'};

				# Determine what SI to use for the Datastore_Cluster_Size
				my $si_prefix_to_return = SI_Get('Datastore_Cluster_Size', 'TB');
				
				# Convert the $datastore_cluster_capacity to SI
				$datastore_cluster_capacity = SI_Process('Datastore_Cluster_Size', 'B', $si_prefix_to_return, $datastore_cluster_capacity);
				# Convert this to an integer
				$datastore_cluster_capacity = ceil($datastore_cluster_capacity);
			
				# Add a comma to the JSON if this isn't the first object
				if ($json_counter != 0) {
					$target_datastore_cluster_views_json = $target_datastore_cluster_views_json . ',';
					} # End if ($json_counter != 0) {

				# Add to the JSON
				$target_datastore_cluster_views_json = $target_datastore_cluster_views_json . '{"datastore_cluster_name":"' . $datastore_cluster_name . '","datastore_cluster_size":"' . $datastore_cluster_capacity;

				# Finish the JSON
				$target_datastore_cluster_views_json = $target_datastore_cluster_views_json . '}';
				
				# Increment the JSON Counter
				$json_counter++;
				} # End foreach (@target_datastore_cluster_views_sorted) {

			# End the JSON
			$target_datastore_cluster_views_json = $target_datastore_cluster_views_json . ']}';
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_datastore_cluster_views_json: \'' . $target_datastore_cluster_views_json . '\'');
			
			# Disconnect from the vCenter Server / ESX(i) Host
			Util::disconnect();

			# Encode the JSON
			use MIME::Base64 qw(encode_base64);
			use Encode qw(encode);
			my $target_datastore_cluster_views_encoded = encode_base64(encode("UTF-8", "$target_datastore_cluster_views_json"));

			# Record the time the plugin ended
			my $time_script_ended = time;

			# Determine how long the plugin took to run
			my $time_script_ran = $time_script_ended - $time_script_started;
			Debug_Process('create', 'Line ' . __LINE__ . ' Script ended @ ' . localtime($time_script_ended));
			Debug_Process('create', 'Line ' . __LINE__ . ' Script running time: ' . $time_script_ran . ' seconds');

			print $target_datastore_cluster_views_encoded;
			exit;
			} # End sub List_Datastore_Clusters {


		sub List_Datastores {
			Debug_Process('append', 'Line ' . __LINE__ . ' List_Datastores');
			# Get all the datastores
			my $target_datastore_views = Vim::find_entity_views (
				view_type	=> 'Datastore',
				properties	=> ['summary.name', 'summary.capacity', 'summary.type', 'host'],
				); # End $target_datastore_views = Vim::find_entity_view (

			# Sort the results
			my @target_datastore_views_sorted = sort { lc($a->{'summary.name'}) cmp lc($b->{'summary.name'}) } @$target_datastore_views;
			
			# Build a JSON of all the objects to send back to PHP
			my $target_datastore_views_json = '{"datastores":[';
			my $json_counter = 0;

			foreach (@target_datastore_views_sorted) {
				my $datastore_name = $_->{'summary.name'};
				#print $datastore_name . "\n";

				my $datastore_capacity = $_->{'summary.capacity'};

				# Determine what SI to use for the Datastore_Size
				my $si_prefix_to_return = SI_Get('Datastore_Size', 'GB');
				
				# Convert the $datastore_capacity to SI
				$datastore_capacity = SI_Process('Datastore_Size', 'B', $si_prefix_to_return, $datastore_capacity);
				# Convert this to an integer
				$datastore_capacity = ceil($datastore_capacity);
			
				my $datastore_type = $_->{'summary.type'};
				#print "\n";

				# Add a comma to the JSON if this isn't the first object
				if ($json_counter != 0) {
					$target_datastore_views_json = $target_datastore_views_json . ',';
					} # End if ($json_counter != 0) {

				# Add to the JSON
				$target_datastore_views_json = $target_datastore_views_json . '{"datastore_name":"' . $datastore_name . '","datastore_size":"' . $datastore_capacity . '","datastore_type":"' . $datastore_type . '"';

				# Now add the connected hosts to the JSON
				$target_datastore_views_json = $target_datastore_views_json . ',"hosts":[';
				my $json_host_counter = 0;
				foreach my $host (@{$_->host}) {
					my $datastore_host = Vim::get_view (
						view_type	=> 'HostSystem',
						mo_ref		=> $host->key,
						properties	=> [ 'name' ]
						); # End my $datastore_hosts = Vim::get_view (

					#print " " . $datastore_host->name . "\n";

					# Add a comma to the JSON if this isn't the first host
					if ($json_host_counter != 0) {
						$target_datastore_views_json = $target_datastore_views_json . ',';
						} # End if ($json_host_counter != 0) {

					# Add to the JSON
					$target_datastore_views_json = $target_datastore_views_json . '{"host_name":"' . $datastore_host->name . '"}';

					# Increment the JSON Counter
					$json_host_counter++;
					} # End foreach my $host (@{$_->host}) {

				# Finish the hosts
				$target_datastore_views_json = $target_datastore_views_json . ']';
				
				# Finish the JSON
				$target_datastore_views_json = $target_datastore_views_json . '}';
				
				# Increment the JSON Counter
				$json_counter++;
				} # End foreach (@target_datastore_views_sorted) {

			# End the JSON
			$target_datastore_views_json = $target_datastore_views_json . ']}';
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_datastore_views_json: \'' . $target_datastore_views_json . '\'');
			
			# Disconnect from the vCenter Server / ESX(i) Host
			Util::disconnect();

			# Encode the JSON
			use MIME::Base64 qw(encode_base64);
			use Encode qw(encode);
			my $target_datastore_views_encoded = encode_base64(encode("UTF-8", "$target_datastore_views_json"));

			# Record the time the plugin ended
			my $time_script_ended = time;

			# Determine how long the plugin took to run
			my $time_script_ran = $time_script_ended - $time_script_started;
			Debug_Process('create', 'Line ' . __LINE__ . ' Script ended @ ' . localtime($time_script_ended));
			Debug_Process('create', 'Line ' . __LINE__ . ' Script running time: ' . $time_script_ran . ' seconds');

			print $target_datastore_views_encoded;
			exit;
			} # End sub List_Datastores {

		
		sub List_Guests {
			Debug_Process('append', 'Line ' . __LINE__ . ' List_Guests');
			# Get all the guests
			my $target_guest_views = Vim::find_entity_views (
				view_type	=> 'VirtualMachine',
				properties	=> ['name', 'guest.hostName', 'guest.ipAddress', 'summary.runtime.powerState'],
				); # End $target_guest_views = Vim::find_entity_view (
			
			# Sort the results
			my @target_guest_views_sorted = sort { lc($a->{'name'}) cmp lc($b->{'name'}) } @$target_guest_views;

			# Build a JSON of all the objects to send back to PHP
			my $target_guest_views_json = '{"guests":[';
			my $json_counter = 0;
			foreach (@target_guest_views_sorted) {
				my $guest_name = $_->name;
				#print $guest_name . "\n";

				my $guest_hostname = '';
				if (defined($_->{'guest.hostName'})) {
					$guest_hostname = $_->{'guest.hostName'};
					#print $guest_hostname . "\n";
					} # End if (defined($_->{'guest.hostName'})) {

				my $guest_address = '';
				if (defined($_->{'guest.ipAddress'})) {
					$guest_address = $_->{'guest.ipAddress'};
					#print $guest_address . "\n";
					} # End if (defined($_->{'guest.ipAddress'})) {

				my $guest_power_state = $_->{'summary.runtime.powerState'}->val;
				#print "\n";

				# Add a comma to the JSON if this isn't the first object
				if ($json_counter != 0) {
					$target_guest_views_json = $target_guest_views_json . ',';
					} # End if ($json_counter != 0) {

				# Add to the JSON
				$target_guest_views_json = $target_guest_views_json . '{"guest_name":"' . $guest_name . '","guest_hostname":"' . $guest_hostname . '","guest_address":"' . $guest_address . '","guest_power_state":"' . $guest_power_state . '"}';

				# Increment the JSON Counter
				$json_counter++;
				} # End foreach (@target_guest_views_sorted) {

			# End the JSON
			$target_guest_views_json = $target_guest_views_json . ']}';
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_guest_views_json: \'' . $target_guest_views_json . '\'');
			
			# Disconnect from the vCenter Server / ESX(i) Host
			Util::disconnect();

			# Encode the JSON
			use MIME::Base64 qw(encode_base64);
			use Encode qw(encode);
			my $target_guest_views_encoded = encode_base64(encode("UTF-8", "$target_guest_views_json"));

			# Record the time the plugin ended
			my $time_script_ended = time;

			# Determine how long the plugin took to run
			my $time_script_ran = $time_script_ended - $time_script_started;
			Debug_Process('create', 'Line ' . __LINE__ . ' Script ended @ ' . localtime($time_script_ended));
			Debug_Process('create', 'Line ' . __LINE__ . ' Script running time: ' . $time_script_ran . ' seconds');

			print $target_guest_views_encoded;
			exit;
			} # End sub List_Guests {

		
		sub List_Hosts {
			Debug_Process('append', 'Line ' . __LINE__ . ' List_Hosts');
			# Get all the hosts
			my $target_host_views = Vim::find_entity_views (
				view_type	=> 'HostSystem',
				properties	=> ['name', 'summary.runtime.powerState', 'summary.runtime.inMaintenanceMode', 'configManager.networkSystem', 'configManager.storageSystem', 'datastore'],
				); # End $target_host_views = Vim::find_entity_view (
			
			# Sort the results
			my @target_host_views_sorted = sort { lc($a->{'name'}) cmp lc($b->{'name'}) } @$target_host_views;

			# Build a JSON of all the objects to send back to PHP
			my $target_host_views_json = '{"hosts":[';
			my $json_counter = 0;
			foreach (@target_host_views_sorted) {
				my $host_name = $_->name;
				my $host_power_state = $_->{'summary.runtime.powerState'}->val;
				my $host_maintenance_mode = $_->{'summary.runtime.inMaintenanceMode'};

				# Add a comma to the JSON if this isn't the first object
				if ($json_counter != 0) {
					$target_host_views_json = $target_host_views_json . ',';
					} # End if ($json_counter != 0) {

				# Add to the JSON
				$target_host_views_json = $target_host_views_json . '{"host_name":"' . $host_name . '","host_power_state":"' . $host_power_state . '","host_maintenance_mode":"' . $host_maintenance_mode . '"';

				# Now add the host pNICs to the JSON
				$target_host_views_json = $target_host_views_json . ',"pnics":[';
				my $json_pnic_counter = 0;

				if ($host_power_state eq 'poweredOn') {
					# Get the $target_host_view_network_system
					my $target_host_view_network_system = $_->get_property('configManager.networkSystem');
						
					# Get the $host_network_system
					my $host_network_system = Vim::get_view(
						mo_ref	=>	$target_host_view_network_system,
						properties	=> [ 'networkInfo.pnic', 'networkInfo.vnic', 'networkInfo.consoleVnic', 'networkInfo.vswitch', 'networkInfo.proxySwitch' ]
						); # End my $host_network_system = Vim::get_view(

					# Create the pnic_all hash
					my %pnic_all = Host_Hardware('pnic_all', $host_network_system->get_property('networkInfo.pnic'));
						
					# Loop through all the physical NICs
					foreach my $pnic_key (keys %pnic_all) {
						my $pnic_name = $pnic_all{$pnic_key}->device;
						my $pnic_driver = $pnic_all{$pnic_key}->driver;

						my $pnic_state = '';
						my $pnic_speed = '';
						my $pnic_duplex = '';

						# Checking to see if the pnic is connected
						if (!defined($pnic_all{$pnic_key}->linkSpeed)) {
							$pnic_state = 'Disconnected';
							} # End if (!defined($pnic_all{$pnic_key}->linkSpeed)) {
						else {
							# It's connected
							$pnic_state = 'Connected';
							$pnic_speed = $pnic_all{$pnic_key}->linkSpeed->speedMb;

							if ($pnic_all{$pnic_key}->linkSpeed->duplex == 0) {
								$pnic_duplex = 'Half';
								} # End if ($pnic_all{$pnic_key}->linkSpeed->duplex == 0) {
							else {
								$pnic_duplex = 'Full';
								} # End else {
							} # End else {
						
						# Add a comma to the JSON if this isn't the first pnic
						if ($json_pnic_counter != 0) {
							$target_host_views_json = $target_host_views_json . ',';
							} # End if ($json_pnic_counter != 0) {

						# Add to the JSON
						$target_host_views_json = $target_host_views_json . '{"pnic_name":"' . $pnic_name . '","pnic_driver":"' . $pnic_driver . '","pnic_state":"' . $pnic_state . '","pnic_speed":"' . $pnic_speed . '","pnic_duplex":"' . $pnic_duplex . '"}';

						# Increment the JSON Counter
						$json_pnic_counter++;
					
						} # End foreach my $pnic_key (keys %pnic_all) {
					} # End if ($host_power_state eq 'poweredOn') {
				
				# Finish the pNIC JSON
				$target_host_views_json = $target_host_views_json . ']';

				# Now add the host vNICs to the JSON
				$target_host_views_json = $target_host_views_json . ',"vnics":[';
				my $json_vnic_counter = 0;

				if ($host_power_state eq 'poweredOn') {
					# Get the $target_host_view_network_system
					my $target_host_view_network_system = $_->get_property('configManager.networkSystem');
						
					# Get the $host_network_system
					my $host_network_system = Vim::get_view(
						mo_ref	=>	$target_host_view_network_system,
						properties	=> [ 'networkInfo.pnic', 'networkInfo.vnic', 'networkInfo.consoleVnic', 'networkInfo.vswitch', 'networkInfo.proxySwitch' ]
						); # End my $host_network_system = Vim::get_view(

					# Create an array of vNICs
					my @vnic_all;
					# ESXi host
					if ($host_network_system->get_property('networkInfo.vnic')) {
						@vnic_all = $host_network_system->get_property('networkInfo.vnic');
						} # End if ($host_network_system->get_property('networkInfo.vnic')) {
					# ESX host
					if ($host_network_system->get_property('networkInfo.consoleVnic')) {
						@vnic_all = $host_network_system->get_property('networkInfo.consoleVnic');
						} # End if ($host_network_system->get_property('networkInfo.consoleVnic')) {

					# Loop through all known vNICs
					foreach my $vnic_array (@vnic_all) {
						# Loop through the array of vNICs (they are a hash)
						foreach my $vnic_hash (@$vnic_array) {
							my $vnic_name;
							if (defined($vnic_hash->spec->distributedVirtualPort)) {
								$vnic_name = $vnic_hash->device;
								} # End if (defined($vnic_hash->spec->distributedVirtualPort)) {
							else {
								$vnic_name = $vnic_hash->portgroup;
								} # End else {
							#print $vnic_name . "\n";

							my $mtu_size;
							if (defined($vnic_hash->spec->mtu)) {
								$mtu_size = $vnic_hash->spec->mtu;
								} # End if (defined($vnic_hash->spec->mtu)) {
							else {
								$mtu_size = 1500;
								} # End else {
								
							# Add a comma to the JSON if this isn't the first vnic
							if ($json_vnic_counter != 0) {
								$target_host_views_json = $target_host_views_json . ',';
								} # End if ($json_vnic_counter != 0) {
								
							# Add to the JSON
							$target_host_views_json = $target_host_views_json . '{"vnic_name":"' . $vnic_name . '","mtu_size":"' . $mtu_size . '"}';

							# Increment the JSON Counter
							$json_vnic_counter++;
							
							} # End foreach my $vnic_hash (@$vnic_array) {
						} # End foreach my $vnic_array (@vnic_all) {
					} # End if ($host_power_state eq 'poweredOn') {
		
				# Finish the vNIC JSON
				$target_host_views_json = $target_host_views_json . ']';

				# Now add the switches to the JSON
				$target_host_views_json = $target_host_views_json . ',"switches":[';
				my $json_switch_counter = 0;

				if ($host_power_state eq 'poweredOn') {
					# Get the $target_host_view_network_system
					my $target_host_view_network_system = $_->get_property('configManager.networkSystem');
						
					# Get the $host_network_system
					my $host_network_system = Vim::get_view(
						mo_ref	=>	$target_host_view_network_system,
						properties	=> [ 'networkInfo.pnic', 'networkInfo.vnic', 'networkInfo.consoleVnic', 'networkInfo.vswitch', 'networkInfo.proxySwitch' ]
						); # End my $host_network_system = Vim::get_view(

					# Create the pnic_all hash
					my %pnic_all = Host_Hardware('pnic_all', $host_network_system->get_property('networkInfo.pnic'));
					
					# Now loop through each item in the $host_network_system
					foreach my $host_network_system_item (keys %$host_network_system) {
						#print $host_network_system_item . "\n";
						
						# Determine if this is a switch item
						if ($host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/) {
							my $switch_name;
							my $mtu_size;
							# We need to determine if this is a vswitch or a proxySwitch
							switch ($host_network_system_item) {
								case 'networkInfo.vswitch' {
									if (defined($host_network_system->get_property($host_network_system_item))) {
										foreach (@{$host_network_system->get_property($host_network_system_item)}) {
											$switch_name = $_->name;	
											#print $switch_name . "\n";
											$mtu_size = $_->mtu;
											
											# Add a comma to the JSON if this isn't the first switch
											if ($json_switch_counter != 0) {
												$target_host_views_json = $target_host_views_json . ',';
												} # End if ($json_pnic_counter != 0) {

											# Add to the JSON
											$target_host_views_json = $target_host_views_json . '{"switch_name":"' . $switch_name . '","mtu_size":"' . $mtu_size . '"';

											# Now add the switch pNICs to the JSON
											$target_host_views_json = $target_host_views_json . ',"pnics":[';
											my $json_switch_pnic_counter = 0;

											# Find all the pnics
											if (defined($_->pnic)) {
												# Loop through all the pnics
												foreach my $pnic (@{$_->{pnic}}) {
													my $switch_pnic_name = $pnic_all{$pnic}->device;
																						
													# Add a comma to the JSON if this isn't the first pnic
													if ($json_switch_pnic_counter != 0) {
														$target_host_views_json = $target_host_views_json . ',';
														} # End if ($json_switch_pnic_counter != 0) {

													# Add to the JSON
													$target_host_views_json = $target_host_views_json . '{"pnic_name":"' . $switch_pnic_name . '"}';

													# Increment the JSON Counter
													$json_switch_pnic_counter++;
													} # End foreach my $pnic ($_->pnic}) {
												} # End if (defined($_->pnic)) {

											# Finish the Switch pNIC JSON
											$target_host_views_json = $target_host_views_json . ']';

											# Increment the JSON Counter
											$json_switch_counter++;

											# Finish the Switch JSON
											$target_host_views_json = $target_host_views_json . '}';
											} # End foreach (@{$host_network_system->get_property($host_network_system_item)}) {
										} # End if (defined($host_network_system->get_property($host_network_system_item))) {
									} # End case 'networkInfo.vswitch' {
								
								case 'networkInfo.proxySwitch' {

									if (defined($host_network_system->get_property($host_network_system_item))) {
										foreach (@{$host_network_system->get_property($host_network_system_item)}) {
											$switch_name = $_->dvsName;
											#print $switch_name . "\n";
											$mtu_size = $_->mtu;

											# Add a comma to the JSON if this isn't the first switch
											if ($json_switch_counter != 0) {
												$target_host_views_json = $target_host_views_json . ',';
												} # End if ($json_pnic_counter != 0) {

											# Add to the JSON
											$target_host_views_json = $target_host_views_json . '{"switch_name":"' . $switch_name . '","mtu_size":"' . $mtu_size . '"';

											# Now add the switch pNICs to the JSON
											$target_host_views_json = $target_host_views_json . ',"pnics":[';
											my $json_switch_pnic_counter = 0;

											# Find all the pnics
											if (defined($_->pnic)) {
												# Loop through all the pnics
												foreach my $pnic (@{$_->{pnic}}) {
													my $switch_pnic_name = $pnic_all{$pnic}->device;
																						
													# Add a comma to the JSON if this isn't the first pnic
													if ($json_switch_pnic_counter != 0) {
														$target_host_views_json = $target_host_views_json . ',';
														} # End if ($json_switch_pnic_counter != 0) {

													# Add to the JSON
													$target_host_views_json = $target_host_views_json . '{"pnic_name":"' . $switch_pnic_name . '"}';

													# Increment the JSON Counter
													$json_switch_pnic_counter++;
													} # End foreach my $pnic ($_->pnic}) {
												} # End if (defined($_->pnic)) {

											# Finish the Switch pNIC JSON
											$target_host_views_json = $target_host_views_json . ']';

											# Increment the JSON Counter
											$json_switch_counter++;

											# Finish the Switch JSON
											$target_host_views_json = $target_host_views_json . '}';
											} # End foreach (@{$host_network_system->get_property($host_network_system_item)}) {
										} # End if (defined($host_network_system->get_property($host_network_system_item))) {
									} # End case 'networkInfo.proxySwitch' {
								} # End switch ($host_network_system_item) {
							} # End if ($host_network_system_item =~ /^(networkInfo.vswitch|networkInfo.proxySwitch)$/) {
						#print "\n";
						} # End foreach my $host_network_system_item (keys %$host_network_system) {
					} # End if ($host_power_state eq 'poweredOn') {

				# Finish the Switch JSON
				$target_host_views_json = $target_host_views_json . ']';

				# Now add the host HBAs to the JSON
				$target_host_views_json = $target_host_views_json . ',"hbas":[';
				my $json_hba_counter = 0;

				if ($host_power_state eq 'poweredOn') {
					# Get the $target_host_view_storage_system
					my $target_host_view_storage_system = $_->get_property('configManager.storageSystem');
					
					# Get the $host_storage_system
					my $host_storage_system = Vim::get_view(
						mo_ref		=>	$target_host_view_storage_system,
						properties	=> [ 'storageDeviceInfo.hostBusAdapter' ]
						); # End my $host_storage_system = Vim::get_view(
					
					# Loop through the HBA's on the host
					foreach my $hba (@{$host_storage_system->get_property('storageDeviceInfo.hostBusAdapter')}) {
						if (defined($hba)) {
							my $hba_name = $hba->device;
							my $hba_model = $hba->model;

							# Add a comma to the JSON if this isn't the first hba
							if ($json_hba_counter != 0) {
								$target_host_views_json = $target_host_views_json . ',';
								} # End if ($json_hba_counter != 0) {
			
							# Add to the JSON
							$target_host_views_json = $target_host_views_json . '{"hba_name":"' . $hba_name . '","hba_model":"' . $hba_model . '"}';

							# Increment the JSON Counter
							$json_hba_counter++;
							} # End if (defined($hba)) {
						} # End foreach my $hba (@{$host_storage_system->storageDeviceInfo->hostBusAdapter}) {
					} # End if ($host_power_state eq 'poweredOn') {

				# Finish the HBA JSON
				$target_host_views_json = $target_host_views_json . ']';

				# Now add the host Datastores to the JSON
				$target_host_views_json = $target_host_views_json . ',"datastores":[';
				my $json_datastore_counter = 0;

				if ($host_power_state eq 'poweredOn') {
					# Loop through the Datastore's on the host
					foreach my $datastore (@{$_->datastore}) {
						if (defined($datastore)) {
							my $target_datastore_view = Vim::get_view (
								mo_ref		=>	$datastore,
								properties	=> ['summary.name', 'summary.capacity', 'summary.type'],
								); # End $target_datastore_view = Vim::get_view (

							my $datastore_name = $target_datastore_view->{'summary.name'};
							#print $datastore_name . "\n";

							my $datastore_capacity = $target_datastore_view->{'summary.capacity'};

							# Determine what SI to use for the Datastore_Size
							my $si_prefix_to_return = SI_Get('Datastore_Size', 'GB');
							
							# Convert the $datastore_capacity to SI
							$datastore_capacity = SI_Process('Datastore_Size', 'B', $si_prefix_to_return, $datastore_capacity);
							# Convert this to an integer
							$datastore_capacity = ceil($datastore_capacity);
						
							my $datastore_type = $target_datastore_view->{'summary.type'};
							#print "\n";

							# Add a comma to the JSON if this isn't the first object
							if ($json_datastore_counter != 0) {
								$target_host_views_json = $target_host_views_json . ',';
								} # End if ($json_datastore_counter != 0) {

							# Add to the JSON
							$target_host_views_json = $target_host_views_json . '{"datastore_name":"' . $datastore_name . '","datastore_size":"' . $datastore_capacity . '","datastore_type":"' . $datastore_type . '"}';

							# Increment the JSON Counter
							$json_datastore_counter++;
							} # End if (defined($datastore)) {
						} # End foreach my $datastore (@{$_->datastore}) {
					} # End if ($host_power_state eq 'poweredOn') {
				
				# Finish the Datastore JSON
				$target_host_views_json = $target_host_views_json . ']';

				# Finish the JSON for the current host
				$target_host_views_json = $target_host_views_json . '}';

				# Increment the JSON Counter
				$json_counter++;
				} # End foreach (@target_host_views_sorted) {

			# End the JSON
			$target_host_views_json = $target_host_views_json . ']}';
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_views_json: \'' . $target_host_views_json . '\'');
			
			# Disconnect from the vCenter Server / ESX(i) Host
			Util::disconnect();

			# Encode the JSON
			use MIME::Base64 qw(encode_base64);
			use Encode qw(encode);
			my $target_host_views_encoded = encode_base64(encode("UTF-8", "$target_host_views_json"));

			# Record the time the plugin ended
			my $time_script_ended = time;

			# Determine how long the plugin took to run
			my $time_script_ran = $time_script_ended - $time_script_started;
			Debug_Process('create', 'Line ' . __LINE__ . ' Script ended @ ' . localtime($time_script_ended));
			Debug_Process('create', 'Line ' . __LINE__ . ' Script running time: ' . $time_script_ran . ' seconds');

			print $target_host_views_encoded;
			exit;
			} # End sub List_Hosts {

			
		sub List_vCenter_Objects {
			Debug_Process('append', 'Line ' . __LINE__ . ' List_Hosts');
			# Start the JSON of all the objects to send back to PHP
			my $vcenter_json = '{';

			# Get all the Clusters
			my $target_cluster_views = Vim::find_entity_views (
				view_type	=> 'ClusterComputeResource',
				properties	=> ['name', 'configurationEx'],
				); # End $target_cluster_views = Vim::find_entity_view (
						
			# Sort the results
			my @target_cluster_views_sorted = sort { lc($a->{'name'}) cmp lc($b->{'name'}) } @$target_cluster_views;

			# Start the JSON of all the Cluster objects
			$vcenter_json = $vcenter_json . '"clusters":[';
			my $json_cluster_counter = 0;
			foreach (@target_cluster_views_sorted) {
				my $cluster_name = $_->name;
				#print $cluster_name . "\n";

				my $cluster_ha_config = $_->get_property('configurationEx')->dasConfig;
				my $cluster_ha = '';
				if ($cluster_ha_config->enabled == 1) {
					$cluster_ha = 'Yes';
					} # End if ($cluster_ha_config->enabled == 1) {
				else {
					$cluster_ha = 'No';
					} # End else {
				#print $cluster_ha . "\n";

				my $cluster_drs_config = $_->get_property('configurationEx')->drsConfig;
				my $cluster_drs = '';
				if ($cluster_drs_config->enabled == 1) {
					$cluster_drs = 'Yes';
					} # End if ($cluster_drs_config->enabled == 1) {
				else {
					$cluster_drs = 'No';
					}
				#print $cluster_drs . "\n";
				
				# Add a comma to the JSON if this isn't the first object
				if ($json_cluster_counter != 0) {
					$vcenter_json = $vcenter_json . ',';
					} # End if ($json_cluster_counter != 0) {

				# Add to the JSON
				$vcenter_json = $vcenter_json . '{"cluster_name":"' . $cluster_name . '","cluster_ha":"' . $cluster_ha . '","cluster_drs":"' . $cluster_drs . '"}';

				# Increment the JSON Cluster Counter
				$json_cluster_counter++;
				} # End foreach (@target_cluster_views_sorted) {

			# End the Cluster JSON
			$vcenter_json = $vcenter_json . ']';


			# Get all the Datacenters
			my $target_datacenter_views = Vim::find_entity_views (
				view_type 	=> 'Datacenter',
				properties	=> [ 'name' ]
				); # End $target_datacenter_views = Vim::find_entity_views (

			# Sort the results
			my @target_datacenter_views_sorted = sort { lc($a->{'name'}) cmp lc($b->{'name'}) } @$target_datacenter_views;

			# Start the JSON of all the Datacenter objects
			$vcenter_json = $vcenter_json . ',"datacenters":[';
			my $json_datacenter_counter = 0;

			foreach (@target_datacenter_views_sorted) {
				my $datacenter_name = $_->name;

				# Add a comma to the JSON if this isn't the first object
				if ($json_datacenter_counter != 0) {
					$vcenter_json = $vcenter_json . ',';
					} # End if ($json_datacenter_counter != 0) {

				# Add to the JSON
				$vcenter_json = $vcenter_json . '{"datacenter_name":"' . $datacenter_name . '"}';

				# Increment the JSON Cluster Counter
				$json_datacenter_counter++;
				} # End foreach (@target_datacenter_views_sorted) {

			# End the Datacenter JSON
			$vcenter_json = $vcenter_json . ']';

			# End the JSON
			$vcenter_json = $vcenter_json . '}';
			Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_json: \'' . $vcenter_json . '\'');
			
			# Disconnect from the vCenter Server / ESX(i) Host
			Util::disconnect();

			# Encode the JSON
			use MIME::Base64 qw(encode_base64);
			use Encode qw(encode);
			my $vcenter_encoded = encode_base64(encode("UTF-8", "$vcenter_json"));

			# Record the time the plugin ended
			my $time_script_ended = time;

			# Determine how long the plugin took to run
			my $time_script_ran = $time_script_ended - $time_script_started;
			Debug_Process('create', 'Line ' . __LINE__ . ' Script ended @ ' . localtime($time_script_ended));
			Debug_Process('create', 'Line ' . __LINE__ . ' Script running time: ' . $time_script_ran . ' seconds');

			print $vcenter_encoded;
			exit;
			} # End sub List_vCenter_Objects {


		sub Modifiers_Get {
			Debug_Process('append', 'Line ' . __LINE__ . ' Modifiers_Get');
			my @Modifiers_Supplied_Local;

			# Determine if user supplied modifiers
			if (Opts::option_is_set('modifier')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'modifier\')');
				my @modifiers = split(/,/, Opts::get_option('modifier'));
				Debug_Process('append', 'Line ' . __LINE__ . ' @modifiers: \'' . @modifiers . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @modifiers values: \'' . join(", ", @modifiers) . '\'');
				
				foreach my $modifier_item (@modifiers) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_item: \'' . $modifier_item . '\'');
					my @modifier_item_split = split(/:/, $modifier_item);
					Debug_Process('append', 'Line ' . __LINE__ . ' @modifier_item_split: \'' . @modifier_item_split . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @modifier_item_split values: \'' . join(", ", @modifier_item_split) . '\'');
				
					if (defined($modifier_item_split[0])) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_item_split[0])');
						Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_item_split[0]: \'' . $modifier_item_split[0] . '\'');
						my %Modifiers_Current;
						if (defined($modifier_item_split[1])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_item_split[1])');
							Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_item_split[1]: \'' . $modifier_item_split[1] . '\'');
							if (defined($modifier_item_split[2])) {
								Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_item_split[2])');
								Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_item_split[2]: \'' . $modifier_item_split[2] . '\'');

								my $modifier_type = $modifier_item_split[0];
								$Modifiers_Current{'type'} = $modifier_type;
								my $modifier_operation = $modifier_item_split[1];
								$Modifiers_Current{'operation'} = $modifier_operation;
								my $modifier_option = $modifier_item_split[2];
								$Modifiers_Current{'option'} = $modifier_option;

								# Not all modifiers have a value
								if (defined($modifier_item_split[3])) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_item_split[3])');
									Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_item_split[3]: \'' . $modifier_item_split[3] . '\'');

									my $modifier_value = $modifier_item_split[3];
									$Modifiers_Current{'value'} = $modifier_value;
									} # End if (defined($modifier_item_split[3])) {
								} # End if (defined($modifier_item_split[2])) {
							} # End if (defined($modifier_item_split[1])) {

						# Check to make sure a modifier was defined and add it to the array if so
						if (%Modifiers_Current) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_item_split[3])');
							push @Modifiers_Supplied_Local, {%Modifiers_Current};
							} # End if (%Modifiers_Current) {
						} #End if (defined($modifier_item_split[0])) {
					} # End foreach my $modifier_item (@modifiers) {	
				} # End if (Opts::option_is_set('modifier')) {

			Debug_Process('append', 'Line ' . __LINE__ . ' @Modifiers_Supplied_Local: \'' . @Modifiers_Supplied_Local . '\'');
			
			return @Modifiers_Supplied_Local;
			} # End sub Modifiers_Get {


		sub Modifiers_Process {
			Debug_Process('append', 'Line ' . __LINE__ . ' Modifiers_Process');
			my $modifier_type = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_type: \'' . $modifier_type . '\'');

			# This is the target value
			my $target_value = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_value: \'' . $target_value . '\'');

			# Define the variable to store the modified value
			my $modified_value = $target_value;
			Debug_Process('append', 'Line ' . __LINE__ . ' $modified_value: \'' . $modified_value . '\'');
			
			# Check to make sure the are any modifiers
			if (scalar @Modifiers_Supplied_Global > 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' @Modifiers_Supplied_Global > 0');
				# Loop through all the modifiers
				foreach my $modifier_current (@Modifiers_Supplied_Global) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_current: \'' . $modifier_current . '\'');
					
					# Is there a modifier defined for this request type?
					if ($modifier_current->{'type'} eq $modifier_type) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_current->{\'type\'} eq $modifier_type');

						# Get all the options the user passed
						my $modifier_operation = $modifier_current->{'operation'};
						Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_operation: \'' . $modifier_operation . '\'');
						my $modifier_option = $modifier_current->{'option'};
						Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_option: \'' . $modifier_option . '\'');

						my $modifier_value = $modifier_current->{'value'};
						if (defined($modifier_value)) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_value)');
							Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_value: \'' . $modifier_value . '\'');
							} # End if (defined($modifier_value)) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' !defined($modifier_value)');
							Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_value: \'\'');
							} # End else {

						# Define Regex Case Option
						my $regex_options;
						my $regex_pattern;
						switch ($modifier_option) {
							case 'upper' {
								$regex_options = 'i';
								} # End case 'upper' {


							case 'lower' {
								$regex_options = 'i';
								} # End case 'lower' {


							case 'insensitive' {
								$regex_options = 'i';
								} # End case 'insensitive' {


							else {
								$regex_options = 'i';
								} # End else {
							} # End switch ($modifier_option) {

												
						# Detect if a Reverse IP lookup is required
						Debug_Process('append', 'Line ' . __LINE__ . ' Detect if a Reverse DNS lookup is required');
						switch ($modifier_operation) {
							case 'reverseip' {
								Debug_Process('append', 'Line ' . __LINE__ . ' case \'reverseip\'');
								$target_value = Reverse_IP_Lookup($target_value);
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_value: \'' . $target_value . '\'');
								} # End case 'reverseip' {


							case 'reverseip_remove' {
								Debug_Process('append', 'Line ' . __LINE__ . ' case \'reverseip_remove\'');
								$target_value = Reverse_IP_Lookup($target_value);
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_value: \'' . $target_value . '\'');
								
								$modifier_operation = 'remove';
								Debug_Process('append', 'Line ' . __LINE__ . ' Changing modifier_operation to perform a remove');
								Debug_Process('append', 'Line ' . __LINE__ . ' $modifier_operation: \'' . $modifier_operation . '\'');
								} # End case 'reverseip_remove' {
							} # End switch ($modifier_operation) {


						# Now perform the modifier operation
						switch ($modifier_operation) {
							case 'add' {
								Debug_Process('append', 'Line ' . __LINE__ . ' case \'add\'');
								if (defined($modifier_value)) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_value)');
									# First see if the original value matchs the modifier value
									$regex_pattern = '(?' . $regex_options . ')' . $modifier_value;
									if ($modified_value =~ /$regex_pattern$/) {
										Debug_Process('append', 'Line ' . __LINE__ . ' MATCH');
										# Do Nothing
										} # End if ($modified_value =~ /$regex_pattern$/) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' NO MATCH');
										$modified_value = $modified_value . $modifier_value;
										} # End else {
									} # End if (defined($modifier_value)) {
								else {
									# Do Nothing
									} # End else {
								} # End case 'add' {
								

							case 'remove' {
								Debug_Process('append', 'Line ' . __LINE__ . ' case \'remove\'');
								if (defined($modifier_value)) {
									Debug_Process('append', 'Line ' . __LINE__ . ' defined($modifier_value)');
									# First see if the original value matchs the modifier value
									$regex_pattern = '(?' . $regex_options . ')' . $modifier_value;
									if ($modified_value =~ /$regex_pattern$/) {
										Debug_Process('append', 'Line ' . __LINE__ . ' MATCH');
										$modified_value = (split(/$regex_pattern/, $modified_value))[0];
										} # End if ($modified_value =~ /$regex_pattern$/) {
									else {
										Debug_Process('append', 'Line ' . __LINE__ . ' NO MATCH');
										# Do Nothing
										} # End else {
									} # End if (defined($modifier_value)) {
								else {
									# Do Nothing
									} # End else {
								} # End case 'remove' {
							} # End switch ($modifier_operation) {

						Debug_Process('append', 'Line ' . __LINE__ . ' $modified_value: \'' . $modified_value . '\'');

						# Determine if the case needs shifting
						switch ($modifier_option) {
							case 'upper' {
								$modified_value = uc($modified_value);
								} # End case 'upper' {


							case 'lower' {
								$modified_value = lc($modified_value);
								} # End case 'lower' {

							else {
								$modified_value = $modified_value;
								} # End else {
							} # End switch ($modifier_option) {
					
						
						} # End if ($modifier_current->{'type'} eq $modifier_type) {
					} # End foreach my $modifier_current (@Modifiers_Supplied_Global) {
				} # End if (scalar @Modifiers_Supplied_Global > 0) {
			else {
				# There was no modifier
				Debug_Process('append', 'Line ' . __LINE__ . ' No request modifier defined, returning original value');
				} # End else {

			return $modified_value;
			} # End sub Modifiers_Process {

			
		sub Perfdata_Option_Get {
			Debug_Process('append', 'Line ' . __LINE__ . ' Perfdata_Option_Get');
			my %Perfdata_Options;

			# Determine if user supplied perfdata options
			if (Opts::option_is_set('perfdata_option')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'perfdata_option\')');
				my @options = split(/,/, Opts::get_option('perfdata_option'));
				Debug_Process('append', 'Line ' . __LINE__ . ' @options: \'' . @options . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @options values: \'' . join(", ", @options) . '\'');

				foreach my $option_item (@options) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $option_item: \'' . $option_item . '\'');
					my @option_item_split = split(/:/, $option_item);
					Debug_Process('append', 'Line ' . __LINE__ . ' @option_item_split: \'' . @option_item_split . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @option_item_split values: \'' . join(", ", @option_item_split) . '\'');

					if (defined($option_item_split[0])) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($option_item_split[0])');
						Debug_Process('append', 'Line ' . __LINE__ . ' $option_item_split[0]: \'' . $option_item_split[0] . '\'');
						if (defined($option_item_split[1])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($option_item_split[1])');
							Debug_Process('append', 'Line ' . __LINE__ . ' $option_item_split[1]: \'' . $option_item_split[1] . '\'');
							my $option_value = $option_item_split[1];
							$Perfdata_Options{$option_item_split[0]} = $option_value;
							} # End if (defined($option_item_split[1])) {
						} #End if (defined($option_item_split[0])) {
					} # End foreach my $option_item (@options) {
				} # End if (Opts::option_is_set('perfdata_option')) {

			return %Perfdata_Options;
			} # End sub Perfdata_Option_Get {
			

		sub Perfdata_Option_Process {
			Debug_Process('append', 'Line ' . __LINE__ . ' Perfdata_Option_Process');
			my $perfdata_option_request = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $perfdata_option_request: \'' . $perfdata_option_request . '\'');
			
			my %Perfdata_Options = %{$_[1]};

			if (%Perfdata_Options) {
				Debug_Process('append', 'Line ' . __LINE__ . ' %Perfdata_Options: \'' . %Perfdata_Options . '\'');
				} # End if (%Perfdata_Options) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' %Perfdata_Options: \'\'');
				} # End else {
			
			switch ($perfdata_option_request) {
				case 'post_check' {
					my $exit_message_received = $_[2];
					my $check_received = $_[3];
					my $exit_message_returned;

					# Get the post_check option if it exists
					my $option_post_check;
					if (defined($Perfdata_Options{$perfdata_option_request})) {
						$option_post_check = $Perfdata_Options{$perfdata_option_request};
						} # End if (defined($Perfdata_Options{$perfdata_option_request})) {
					else {
						$option_post_check = '';
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' $option_post_check: \'' . $option_post_check . '\'');

					switch ($option_post_check) {
						case 'disabled' {
							Debug_Process('append', 'Line ' . __LINE__ . ' Don\'t append the check name to the end of the perfdata string');
							$exit_message_returned = $exit_message_received;
							} # End case 'disabled' {

						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' Append the check name to the end of the perfdata string');
							$exit_message_returned = "$exit_message_received [$check_received]";
							} # End else {
						} # End switch ($option_post_check) {

					return $exit_message_returned;
					} # End case 'post_check' {


				case 'metric_counters' {
					# Define some inital variables
					my $metric_supplied_by_user = 0;
					my @metric_array_all;
					my @metric_array_user;
					my %perfdata_options_selected_all;
					my %perfdata_options_selected_user;
					my $check = Opts::get_option('check');
					
					Debug_Process('append', 'Line ' . __LINE__ . ' $metric_supplied_by_user: \'' . $metric_supplied_by_user . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @metric_array_all total items: \'' . scalar @metric_array_all . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @metric_array_user total items: \'' . scalar @metric_array_user . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_all: \'' . %perfdata_options_selected_all . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_user: \'' . %perfdata_options_selected_user . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $check: \'' . $check . '\'');

					Debug_Process('append', 'Line ' . __LINE__ . ' Determining what metrics to return');
					foreach my $metric_available (keys %{$Metrics_Lookup{$check}}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $metric_available: \'' . $metric_available . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' Adding \'' . $metric_available . '\' to the %perfdata_options_selected_all');
						$perfdata_options_selected_all{$metric_available} = $metric_available;
						foreach my $metric_specific (@{$Metrics_Lookup{$check}->{$metric_available}}) {
							Debug_Process('append', 'Line ' . __LINE__ . ' Adding metric \'' . $metric_specific . '\' to the @metric_array_all');
							push (@metric_array_all, $metric_specific);
							# Determine if the user wants this metric
							if (defined($Perfdata_Options{$metric_available})) {
								if ($Perfdata_Options{$metric_available} == 1) {
									Debug_Process('append', 'Line ' . __LINE__ . ' Adding metric \'' . $metric_specific . '\' to the @metric_array_user');
									push (@metric_array_user, $metric_specific);
									Debug_Process('append', 'Line ' . __LINE__ . ' Adding \'' . $metric_available . '\' to the %perfdata_options_selected_user');
									$perfdata_options_selected_user{$metric_available} = $metric_available;
									$metric_supplied_by_user = 1;
									} # End if ($Perfdata_Options{$metric_available} == 1) {
								} # End if (defined($Perfdata_Options{$metric_available})) {
							} # End foreach my $metric_specific (@{%{$Metrics_Lookup{$check}}->{$metric_available}}) {
						} # End foreach my $metrics_available (keys %{$Metrics_Lookup{$check}}) {

					# Determine what to return
					if ($metric_supplied_by_user == 1) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $metric_supplied_by_user == 1');
						Debug_Process('append', 'Line ' . __LINE__ . ' @metric_array_user total items: \'' . scalar @metric_array_user . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_user: \'' . %perfdata_options_selected_user . '\'');
						return (\%perfdata_options_selected_user, \@metric_array_user);
						} # End if ($metric_supplied_by_user == 1) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $metric_supplied_by_user != 1');
						Debug_Process('append', 'Line ' . __LINE__ . ' @metric_array_all total items: \'' . scalar @metric_array_all . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_all: \'' . %perfdata_options_selected_all . '\'');
						return (\%perfdata_options_selected_all, \@metric_array_all);
						} # End else {
					} # End case 'metric_counters' {


				case 'metric_standard' {
					# Define some inital variables
					my $metric_supplied_by_user = 0;
					my %perfdata_options_selected_all;
					my %perfdata_options_selected_user;
					my $check = Opts::get_option('check');
					
					Debug_Process('append', 'Line ' . __LINE__ . ' $metric_supplied_by_user: \'' . $metric_supplied_by_user . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_all: \'' . %perfdata_options_selected_all . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_user: \'' . %perfdata_options_selected_user . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $check: \'' . $check . '\'');

					Debug_Process('append', 'Line ' . __LINE__ . ' Determining what metrics to return');
					foreach my $metric_available (@{$Metrics_Lookup{$check}}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $metric_available: \'' . $metric_available . '\'');
						Debug_Process('append', 'Line ' . __LINE__ . ' Adding \'' . $metric_available . '\' to the %perfdata_options_selected_all');
						$perfdata_options_selected_all{$metric_available} = $metric_available;
						# Determine if the user wants this metric
						if (defined($Perfdata_Options{$metric_available})) {
							if ($Perfdata_Options{$metric_available} == 1) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $Perfdata_Options{$metric_available} == 1');
								Debug_Process('append', 'Line ' . __LINE__ . ' Adding \'' . $metric_available . '\' to the %perfdata_options_selected_user');
								$perfdata_options_selected_user{$metric_available} = $metric_available;
								$metric_supplied_by_user = 1;
								} # End if ($Perfdata_Options{$metric_available} == 1) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' $Perfdata_Options{$metric_available} != 1');
								} # End else {
							} # End if (defined($Perfdata_Options{$metric_available})) {
						} # End foreach my $metrics_available (keys %{$Metrics_Lookup{$check}}) {

					# Determine what to return
					if ($metric_supplied_by_user == 1) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $metric_supplied_by_user == 1');
						Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_user: \'' . %perfdata_options_selected_user . '\'');
						return \%perfdata_options_selected_user;
						} # End if ($metric_supplied_by_user == 1) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' $metric_supplied_by_user != 1');
						Debug_Process('append', 'Line ' . __LINE__ . ' %perfdata_options_selected_all: \'' . %perfdata_options_selected_all . '\'');
						return \%perfdata_options_selected_all;
						} # End else {
					} # End case 'metric_standard' {
				} # End switch ($perfdata_option_request) {
			} # End sub Perfdata_Option_Process {
			

		sub Perfdata_Process {
			Debug_Process('append', 'Line ' . __LINE__ . ' Perfdata_Process');
			my $perf_data = $_[0];
			my $perf_counters_used = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $perf_data: \'' . $perf_data . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $perf_counters_used: \'' . $perf_counters_used . '\'');
			
			# Define the hash we will store the values in
			my $perf_data_hash;
			
			# Add the timestamp
			$perf_data_hash->{'timestamp'} = $perf_data->[0]->sampleInfo->[0]->timestamp;
			Debug_Process('append', 'Line ' . __LINE__ . ' $perf_data_hash->{\'timestamp\'}: \'' . $perf_data_hash->{'timestamp'} . '\'');
			
			# Loop through the perfdata and add each value to the hash
			foreach (@$perf_data) {
				foreach my $perf_counter_id (keys %$perf_counters_used) {
					foreach my $perf_data_value_hash (@{$_->value}) {
						if ($perf_counter_id == $perf_data_value_hash->id->counterId) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $perf_counter_id: \'' . $perf_counter_id . '\' : $perf_counters_used->{$perf_counter_id}: \'' . $perf_counters_used->{$perf_counter_id} . '\' : $perf_data_value_hash->value->[0]: \'' . $perf_data_value_hash->value->[0] . '\'');
							$perf_data_hash->{$perf_counters_used->{$perf_counter_id}} = $perf_data_value_hash->value->[0];
							last;
							} # End if ($perf_counter_id == $perf_data_value_hash->id->counterId) {
						} # End foreach my $perf_data_value_hash (@{$_->value}) {
					} # End foreach my $perf_counter_id (keys %$perf_counters_used) {
				} # End foreach (@$perf_data) {
			
			return $perf_data_hash;
			} # End sub Perfdata_Process {
			
			
		sub Perfdata_Retrieve {
			Debug_Process('append', 'Line ' . __LINE__ . ' Perfdata_Retrieve');
			my $entity_target = $_[0];
			my $requested_perf_counter_type = $_[1];
			my $instance = $_[2];
			my @requested_perf_counter_keys = @{$_[3]};
			Debug_Process('append', 'Line ' . __LINE__ . ' $entity_target: \'' . $entity_target . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $requested_perf_counter_type: \'' . $requested_perf_counter_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $instance: \'' . $instance . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' @requested_perf_counter_keys: \'' . @requested_perf_counter_keys . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' @requested_perf_counter_keys values: \'' . join(", ", @requested_perf_counter_keys) . '\'');
			
			my @filtered_counters_list;
			
			# Get the $perf_manager_view
			my $perf_manager_view = Vim::get_view(mo_ref => Vim::get_service_content()->perfManager);
			Debug_Process('append', 'Line ' . __LINE__ . ' $perf_manager_view: \'' . $perf_manager_view . '\'');
			
			# Need to determine the refresh rate
			my $provider_summary = $perf_manager_view->QueryPerfProviderSummary(entity => $entity_target);	
			Debug_Process('append', 'Line ' . __LINE__ . ' $provider_summary->refreshRate: \'' . $provider_summary->refreshRate . '\'');
			
			my $interval;
			# Determine the refresh rate
			if ($provider_summary->refreshRate == -1) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $provider_summary->refreshRate == -1');
				Debug_Process('append', 'Line ' . __LINE__ . ' No refresh rate defined, get the historical samplingPeriod for the past day instead');
				# No refresh rate defined, get the historical samplingPeriod for the past day instead
				my $historical_intervals = $perf_manager_view->historicalInterval;
				Debug_Process('append', 'Line ' . __LINE__ . ' $historical_intervals: \'' . $historical_intervals . '\'');
				foreach (@$historical_intervals) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
					if ($_->key == 1) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $_->key == 1');
						$interval = $_->samplingPeriod;
						Debug_Process('append', 'Line ' . __LINE__ . ' $interval: \'' . $interval . '\'');
						last;
						} # End if ($_->key == 1) {
					} # End foreach (@$historical_intervals) {
				} # End if ($provider_summary->refreshRate == -1) {
			else {
				# Use refresh rate from the $provider_summary
				$interval = $provider_summary->refreshRate;
				Debug_Process('append', 'Line ' . __LINE__ . ' Use refresh rate from the $provider_summary');
				Debug_Process('append', 'Line ' . __LINE__ . ' $interval: \'' . $interval . '\'');
				} # End else {
			
			my $available_perf_metrics = $perf_manager_view->QueryAvailablePerfMetric(
				entity		=> $entity_target,
				intervalId	=> $interval,
				); # End my $available_perf_metrics = $perf_manager_view->QueryAvailablePerfMetric(
			Debug_Process('append', 'Line ' . __LINE__ . ' $available_perf_metrics: \'' . $available_perf_metrics . '\'');
			
			# We will store the performance counters we want into $wanted_counters
			my $wanted_counters;

			Debug_Process('append', 'Line ' . __LINE__ . ' Loop through the array of @requested_perf_counter_keys');
			# Loop through the array of @requested_perf_counter_keys
			foreach my $requested_perf_counter_key (@requested_perf_counter_keys) {
				# Loop through all the available performance counters
				foreach my $available_perf_counter (@{$perf_manager_view->perfCounter}) {
					#Debug_Process('append', 'Line ' . __LINE__ . ' $available_perf_counter->groupInfo->key: \'' . $available_perf_counter->groupInfo->key . '\'');
					# Check to see if the $requested_perf_counter_type equals this performance counter
					if ($available_perf_counter->groupInfo->key eq $requested_perf_counter_type) {
						#Debug_Process('append', 'Line ' . __LINE__ . ' $available_perf_counter->groupInfo->key: \'' . $available_perf_counter->groupInfo->key . ' eq: $requested_perf_counter_type: \'' . $requested_perf_counter_type . '\'');
						# Now check to see if the $available_perf_counter->nameInfo->key matches $requested_perf_counter_key
						if ($available_perf_counter->nameInfo->key eq $requested_perf_counter_key) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $available_perf_counter->nameInfo->key: \'' . $available_perf_counter->nameInfo->key . ' eq: $requested_perf_counter_key: \'' . $requested_perf_counter_key . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' Match, add this to $wanted_counters for later use');
							# Match, add this to $wanted_counters for later use
							$wanted_counters->{$available_perf_counter->key} = $available_perf_counter;
							} # End if ($available_perf_counter->nameInfo->key eq $requested_perf_counter_key) {
						} # End if ($available_perf_counter->groupInfo->key eq $requested_perf_counter_type) {
					} # End foreach my $available_perf_counter (@{$perf_manager_view->perfCounter}) {
				} # End foreach my $requested_perf_counter_key (@requested_perf_counter_keys) {
			
			# We will store the performance counters we use into $perf_counters_used
			my $perf_counters_used;

			Debug_Process('append', 'Line ' . __LINE__ . ' Now loop through all the available performance metrics on the target');
			# Now loop through all the available performance metrics on the target
			foreach my $current_metric (@$available_perf_metrics) {
				#Debug_Process('append', 'Line ' . __LINE__ . ' $current_metric: \'' . $current_metric . '\'');
				#Debug_Process('append', 'Line ' . __LINE__ . ' $counterId: \'' . $current_metric->counterId . '\'');
				# Check to see if this metric exists in $wanted_counters
				if (exists $wanted_counters->{$current_metric->counterId}) {
					#Debug_Process('append', 'Line ' . __LINE__ . ' exists $wanted_counters->{$current_metric->counterId}');
					#Debug_Process('append', 'Line ' . __LINE__ . ' $wanted_counters->{$current_metric->counterId}: \'' . $wanted_counters->{$current_metric->counterId} . '\'');
					# Check to see if the current_metric matches $instance 
					if ($current_metric->instance eq $instance) {
						Debug_Process('append', 'Line ' . __LINE__ . ' MATCH! $current_metric->instance eq $instance');
						Debug_Process('append', 'Line ' . __LINE__ . ' $current_metric->instance: \'' . $current_metric->instance . '\' eq $instance: \'' . $instance . '\'');
						# Matches, create the metric
						my $metric = PerfMetricId->new (
							counterId => $current_metric->counterId,
							instance => $current_metric->instance,
							); # End my $metric = PerfMetricId->new (
						Debug_Process('append', 'Line ' . __LINE__ . ' $metric: \'' . $metric . '\'');
						# Add $metric to the @filtered_counters_list
						push @filtered_counters_list, $metric;
						# Add this to $perf_counters_used for later use
						$perf_counters_used->{$current_metric->counterId} = $wanted_counters->{$current_metric->counterId}->nameInfo->key;
						} # End if ($current_metric->instance eq $instance) {
					} # End if (exists $wanted_counters->{$current_metric->counterId}) {
				} # End foreach my $current_metric (@$available_perf_metrics) {
			
			Debug_Process('append', 'Line ' . __LINE__ . ' Now we need to create a PerfQuerySpec so we can query $perf_manager_view');
			# Now we need to create a PerfQuerySpec so we can query $perf_manager_view
			my $perf_query_spec = PerfQuerySpec->new(
				entity		=> $entity_target,
				metricId	=> \@filtered_counters_list, # <-- the backslash is required to pass the array!!!
				format		=> 'normal',
				intervalId	=> $interval,
				maxSample	=> 1,
				); # End my $perf_query_spec = PerfQuerySpec->new(

			Debug_Process('append', 'Line ' . __LINE__ . ' $perf_query_spec: \'' . $perf_query_spec . '\'');
			
			# Now we will retrieve the performance statistics we requested
			my $perf_data_retrieved;
			# Using a while loop so we can detect negative values
			my $perf_data_ok = 'no';
			Debug_Process('append', 'Line ' . __LINE__ . ' $perf_data_ok: \'' . $perf_data_ok . '\'');
			while ($perf_data_ok eq 'no') {
				my $perf_data_check;
				$perf_data_retrieved = $perf_manager_view->QueryPerf(
					querySpec	=> $perf_query_spec,
					); # End my $perf_data_retrieved = $perf_manager_view->QueryPerf(
				Debug_Process('append', 'Line ' . __LINE__ . ' $perf_data_retrieved: \'' . $perf_data_retrieved . '\'');
				# Loop through the perfdata and add each value to the hash (to dectect negative values)
				foreach (@$perf_data_retrieved) {
					foreach my $perf_counter_id (keys %$perf_counters_used) {
						foreach my $perf_data_value_hash (@{$_->value}) {
							if ($perf_data_value_hash->value->[0] < 0) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $perf_data_value_hash->value->[0] < 0');
								$perf_data_check = 'negative';
								Debug_Process('append', 'Line ' . __LINE__ . ' $perf_data_check: \'' . $perf_data_check . '\'');
								last;
								} # End if ($perf_data_value_hash->value->[0] < 0) {
							} # End foreach my $perf_data_value_hash (@{$_->value}) {
						} # End foreach my $perf_counter_id (keys %$perf_counters_used) {
					} # End foreach (@$perf_data_retrieved) {
				
				# Now check to see if a negative value was detected
				if (!defined($perf_data_check)) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !defined($perf_data_check)');
					Debug_Process('append', 'Line ' . __LINE__ . ' All is OK, exit the while loop');
					# All is OK, exit the while loop
					$perf_data_ok = 'yes';
					} # End if (!defined($perf_data_check)) {
				} # End while ($perf_data_ok eq 'no') {
			
			return ($perf_data_retrieved, $perf_counters_used);
			} # End sub Perfdata_Retrieve {
		

		sub Print_Help {
			print "\n" . $pod_usage . "\n";	
			} # End sub Print_Help {
		
		
		sub Print_License {
			print "\n";
			print "============================ PROGRAM LICENSE ==================================\n";
			print "    This program is free software: you can redistribute it and/or modify it under the terms of the GNU General Public License as published by the Free Software Foundation, either version 3 of the License, or (at your option) any later version.\n";
			print "\n";
			print "    This program is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU General Public License for more details.\n";
			print "\n";
			print "    You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.\n";
			print "\n";
			print "\n";
			print "                    GNU GENERAL PUBLIC LICENSE\n";
			print "                       Version 3, 29 June 2007\n";
			print "\n";
			print " Copyright (C) 2007 Free Software Foundation, Inc. <http://fsf.org/>\n";
			print " Everyone is permitted to copy and distribute verbatim copies of this license document, but changing it is not allowed.\n";
			print "\n";
			print "                            Preamble\n";
			print "\n";
			print "  The GNU General Public License is a free, copyleft license for software and other kinds of works.\n";
			print "\n";
			print "  The licenses for most software and other practical works are designed to take away your freedom to share and change the works.  By contrast, the GNU General Public License is intended to guarantee your freedom to share and change all versions of a program--to make sure it remains free software for all its users.  We, the Free Software Foundation, use the GNU General Public License for most of our software; it applies also to any other work released this way by its authors.  You can apply it to your programs, too.\n";
			print "\n";
			print "  When we speak of free software, we are referring to freedom, not price.  Our General Public Licenses are designed to make sure that you have the freedom to distribute copies of free software (and charge for them if you wish), that you receive source code or can get it if you want it, that you can change the software or use pieces of it in new free programs, and that you know you can do these things.\n";
			print "\n";
			print "  To protect your rights, we need to prevent others from denying you these rights or asking you to surrender the rights.  Therefore, you have certain responsibilities if you distribute copies of the software, or if you modify it: responsibilities to respect the freedom of others.\n";
			print "\n";
			print "   For example, if you distribute copies of such a program, whether gratis or for a fee, you must pass on to the recipients the same freedoms that you received.  You must make sure that they, too, receive or can get the source code.  And you must show them these terms so they know their rights.\n";
			print "\n";
			print "   Developers that use the GNU GPL protect your rights with two steps:\n";
			print " (1) assert copyright on the software, and (2) offer you this License giving you legal permission to copy, distribute and/or modify it.\n";
			print "\n";
			print "   For the developers\' and authors\' protection, the GPL clearly explains that there is no warranty for this free software.  For both users\' and authors\' sake, the GPL requires that modified versions be marked as changed, so that their problems will not be attributed erroneously to authors of previous versions.\n";
			print "\n";
			print "   Some devices are designed to deny users access to install or run modified versions of the software inside them, although the manufacturer can do so.  This is fundamentally incompatible with the aim of protecting users\' freedom to change the software.  The systematic pattern of such abuse occurs in the area of products for individuals to use, which is precisely where it is most unacceptable.  Therefore, we have designed this version of the GPL to prohibit the practice for those products.  If such problems arise substantially in other domains, we stand ready to extend this provision to those domains in future versions of the GPL, as needed to protect the freedom of users.\n";
			print "\n";
			print "   Finally, every program is threatened constantly by software patents. States should not allow patents to restrict development and use of  software on general-purpose computers, but in those that do, we wish to avoid the special danger that patents applied to a free program could make it effectively proprietary.  To prevent this, the GPL assures that patents cannot be used to render the program non-free.\n";
			print "\n";
			print "   The precise terms and conditions for copying, distribution and modification follow.\n";
			print "\n";
			print "                        TERMS AND CONDITIONS\n";
			print "\n";
			print "   0. Definitions.\n";
			print " \n";
			print "   \"This License\" refers to version 3 of the GNU General Public License.\n";
			print " \n";
			print "   \"Copyright\" also means copyright-like laws that apply to other kinds of works, such as semiconductor masks.\n";
			print "\n";
			print "   \"The Program\" refers to any copyrightable work licensed under this License.  Each licensee is addressed as \"you\".  \"Licensees\" and \"recipients\" may be individuals or organizations.\n";
			print "\n";
			print "   To \"modify\" a work means to copy from or adapt all or part of the work in a fashion requiring copyright permission, other than the making of an exact copy.  The resulting work is called a \"modified version\" of the earlier work or a work \"based on\" the earlier work.\n";
			print "\n";
			print "   A \"covered work\" means either the unmodified Program or a work based on the Program.\n";
			print "\n";
			print "   To \"propagate\" a work means to do anything with it that, without permission, would make you directly or secondarily liable for infringement under applicable copyright law, except executing it on a computer or modifying a private copy.  Propagation includes copying, distribution (with or without modification), making available to the public, and in some countries other activities as well.\n";
			print "\n";
			print "   To \"convey\" a work means any kind of propagation that enables other parties to make or receive copies.  Mere interaction with a user through a computer network, with no transfer of a copy, is not conveying.\n";
			print "\n";
			print "   An interactive user interface displays \"Appropriate Legal Notices\" to the extent that it includes a convenient and prominently visible feature that (1) displays an appropriate copyright notice, and (2) tells the user that there is no warranty for the work (except to the extent that warranties are provided), that licensees may convey the work under this License, and how to view a copy of this License.  If the interface presents a list of user commands or options, such as a menu, a prominent item in the list meets this criterion.\n";
			print "\n";
			print "   1. Source Code.\n";
			print "\n";
			print "   The \"source code\" for a work means the preferred form of the work for making modifications to it.  \"Object code\" means any non-source form of a work.\n";
			print "\n";
			print "   A \"Standard Interface\" means an interface that either is an official standard defined by a recognized standards body, or, in the case of interfaces specified for a particular programming language, one that is widely used among developers working in that language.\n";
			print "\n";
			print "   The \"System Libraries\" of an executable work include anything, other than the work as a whole, that (a) is included in the normal form of packaging a Major Component, but which is not part of that Major Component, and (b) serves only to enable use of the work with that Major Component, or to implement a Standard Interface for which an implementation is available to the public in source code form.  A \"Major Component\", in this context, means a major essential component (kernel, window system, and so on) of the specific operating system (if any) on which the executable work runs, or a compiler used to produce the work, or an object code interpreter used to run it.\n";
			print "\n";
			print "   The \"Corresponding Source\" for a work in object code form means all the source code needed to generate, install, and (for an executable work) run the object code and to modify the work, including scripts to control those activities.  However, it does not include the work\'s System Libraries, or general-purpose tools or generally available free programs which are used unmodified in performing those activities but which are not part of the work.  For example, Corresponding Source includes interface definition files associated with source files for the work, and the source code for shared libraries and dynamically linked subprograms that the work is specifically designed to require, such as by intimate data communication or control flow between those subprograms and other parts of the work.\n";
			print "\n";
			print "   The Corresponding Source need not include anything that users can regenerate automatically from other parts of the Corresponding Source.\n";
			print "\n";
			print "   The Corresponding Source for a work in source code form is that same work.\n";
			print "\n";
			print "   2. Basic Permissions.\n";
			print "\n";
			print "   All rights granted under this License are granted for the term of copyright on the Program, and are irrevocable provided the stated conditions are met.  This License explicitly affirms your unlimited permission to run the unmodified Program.  The output from running a covered work is covered by this License only if the output, given its content, constitutes a covered work.  This License acknowledges your rights of fair use or other equivalent, as provided by copyright law.\n";
			print "\n";
			print "   You may make, run and propagate covered works that you do not convey, without conditions so long as your license otherwise remains in force.  You may convey covered works to others for the sole purpose of having them make modifications exclusively for you, or provide you with facilities for running those works, provided that you comply with the terms of this License in conveying all material for which you do not control copyright.  Those thus making or running the covered works for you must do so exclusively on your behalf, under your direction and control, on terms that prohibit them from making any copies of your copyrighted material outside their relationship with you.\n";
			print "\n";
			print "   Conveying under any other circumstances is permitted solely under the conditions stated below.  Sublicensing is not allowed; section 10 makes it unnecessary.\n";
			print "\n";
			print "   3. Protecting Users\' Legal Rights From Anti-Circumvention Law.\n";
			print "\n";
			print "   No covered work shall be deemed part of an effective technological measure under any applicable law fulfilling obligations under article 11 of the WIPO copyright treaty adopted on 20 December 1996, or similar laws prohibiting or restricting circumvention of such measures.\n";
			print "\n";
			print "   When you convey a covered work, you waive any legal power to forbid circumvention of technological measures to the extent such circumvention is effected by exercising rights under this License with respect to the covered work, and you disclaim any intention to limit operation or modification of the work as a means of enforcing, against the work\'s users, your or third parties\' legal rights to forbid circumvention of technological measures.\n";
			print "\n";
			print "   4. Conveying Verbatim Copies.\n";
			print "\n";
			print "   You may convey verbatim copies of the Program\'s source code as you receive it, in any medium, provided that you conspicuously and appropriately publish on each copy an appropriate copyright notice; keep intact all notices stating that this License and any non-permissive terms added in accord with section 7 apply to the code; keep intact all notices of the absence of any warranty; and give all recipients a copy of this License along with the Program.\n";
			print "\n";
			print "   You may charge any price or no price for each copy that you convey, and you may offer support or warranty protection for a fee.\n";
			print "\n";
			print "   5. Conveying Modified Source Versions.\n";
			print "\n";
			print "   You may convey a work based on the Program, or the modifications to produce it from the Program, in the form of source code under the terms of section 4, provided that you also meet all of these conditions:\n";
			print "\n";
			print "     a) The work must carry prominent notices stating that you modified it, and giving a relevant date.\n";
			print "\n";
			print "     b) The work must carry prominent notices stating that it is released under this License and any conditions added under section 7.  This requirement modifies the requirement in section 4 to \"keep intact all notices\".\n";
			print "\n";
			print "     c) You must license the entire work, as a whole, under this License to anyone who comes into possession of a copy.  This License will therefore apply, along with any applicable section 7 additional terms, to the whole of the work, and all its parts, regardless of how they are packaged.  This License gives no permission to license the work in any other way, but it does not invalidate such permission if you have separately received it.\n";
			print "\n";
			print "     d) If the work has interactive user interfaces, each must display Appropriate Legal Notices; however, if the Program has interactive interfaces that do not display Appropriate Legal Notices, your work need not make them do so.\n";
			print "\n";
			print "   A compilation of a covered work with other separate and independent works, which are not by their nature extensions of the covered work, and which are not combined with it such as to form a larger program, in or on a volume of a storage or distribution medium, is called an \"aggregate\" if the compilation and its resulting copyright are not used to limit the access or legal rights of the compilation\'s users beyond what the individual works permit.  Inclusion of a covered work in an aggregate does not cause this License to apply to the other parts of the aggregate.\n";
			print "\n";
			print "   6. Conveying Non-Source Forms.\n";
			print "\n";
			print "   You may convey a covered work in object code form under the terms of sections 4 and 5, provided that you also convey the machine-readable Corresponding Source under the terms of this License, in one of these ways:\n";
			print "\n";
			print "     a) Convey the object code in, or embodied in, a physical product (including a physical distribution medium), accompanied by the Corresponding Source fixed on a durable physical medium customarily used for software interchange.\n";
			print "\n";
			print "     b) Convey the object code in, or embodied in, a physical product (including a physical distribution medium), accompanied by a written offer, valid for at least three years and valid for as long as you offer spare parts or customer support for that product model, to give anyone who possesses the object code either (1) a copy of the Corresponding Source for all the software in the product that is covered by this License, on a durable physical medium customarily used for software interchange, for a price no more than your reasonable cost of physically performing this conveying of source, or (2) access to copy the Corresponding Source from a network server at no charge.\n";
			print "\n";
			print "     c) Convey individual copies of the object code with a copy of the written offer to provide the Corresponding Source.  This alternative is allowed only occasionally and noncommercially, and only if you received the object code with such an offer, in accord with subsection 6b.\n";
			print "\n";
			print "     d) Convey the object code by offering access from a designated place (gratis or for a charge), and offer equivalent access to the Corresponding Source in the same way through the same place at no further charge.  You need not require recipients to copy the Corresponding Source along with the object code.  If the place to copy the object code is a network server, the Corresponding Source may be on a different server (operated by you or a third party) that supports equivalent copying facilities, provided you maintain clear directions next to the object code saying where to find the Corresponding Source.  Regardless of what server hosts the Corresponding Source, you remain obligated to ensure that it is available for as long as needed to satisfy these requirements.\n";
			print "\n";
			print "     e) Convey the object code using peer-to-peer transmission, provided you inform other peers where the object code and Corresponding Source of the work are being offered to the general public at no charge under subsection 6d.\n";
			print "\n";
			print "   A separable portion of the object code, whose source code is excluded from the Corresponding Source as a System Library, need not beincluded in conveying the object code work.\n";
			print "\n";
			print "   A \"User Product\" is either (1) a \"consumer product\", which means any tangible personal property which is normally used for personal, family, or household purposes, or (2) anything designed or sold for incorporation into a dwelling.  In determining whether a product is a consumer product, doubtful cases shall be resolved in favor of coverage.  For a particular product received by a particular user, \"normally used\" refers to a typical or common use of that class of product, regardless of the status of the particular user or of the way in which the particular user actually uses, or expects or is expected to use, the product.  A product is a consumer product regardless of whether the product has substantial commercial, industrial or non-consumer uses, unless such uses represent the only significant mode of use of the product.\n";
			print "\n";
			print "   \"Installation Information\" for a User Product means any methods, procedures, authorization keys, or other information required to install and execute modified versions of a covered work in that User Product from a modified version of its Corresponding Source.  The information must suffice to ensure that the continued functioning of the modified object code is in no case prevented or interfered with solely because modification has been made.\n";
			print "\n";
			print "   If you convey an object code work under this section in, or with, or specifically for use in, a User Product, and the conveying occurs as part of a transaction in which the right of possession and use of the User Product is transferred to the recipient in perpetuity or for a fixed term (regardless of how the transaction is characterized), the Corresponding Source conveyed under this section must be accompanied by the Installation Information.  But this requirement does not apply if neither you nor any third party retains the ability to install modified object code on the User Product (for example, the work hasbeen installed in ROM).\n";
			print "\n";
			print "   The requirement to provide Installation Information does not include a requirement to continue to provide support service, warranty, or updates for a work that has been modified or installed by the recipient, or for the User Product in which it has been modified or installed.  Access to a network may be denied when the modification itself materially and adversely affects the operation of the network or violates the rules and protocols for communication across the network.\n";
			print "\n";
			print "   Corresponding Source conveyed, and Installation Information provided, in accord with this section must be in a format that is publicly documented (and with an implementation available to the public in source code form), and must require no special password or key for unpacking, reading or copying.\n";
			print "\n";
			print "   7. Additional Terms.\n";
			print "\n";
			print "   \"Additional permissions\" are terms that supplement the terms of this License by making exceptions from one or more of its conditions.\n";
			print " Additional permissions that are applicable to the entire Program shall be treated as though they were included in this License, to the extent that they are valid under applicable law.  If additional permissions apply only to part of the Program, that part may be used separately under those permissions, but the entire Program remains governed by this License without regard to the additional permissions.\n";
			print "\n";
			print "   When you convey a copy of a covered work, you may at your option remove any additional permissions from that copy, or from any part of it.  (Additional permissions may be written to require their own removal in certain cases when you modify the work.)  You may place additional permissions on material, added by you to a covered work, for which you have or can give appropriate copyright permission.\n";
			print "\n";
			print "   Notwithstanding any other provision of this License, for material you add to a covered work, you may (if authorized by the copyright holders of that material) supplement the terms of this License with terms:\n";
			print "\n";
			print "     a) isclaiming warranty or limiting liability differently from the terms of sections 15 and 16 of this License; or\n";
			print "\n";
			print "     b) Requiring preservation of specified reasonable legal notices or author attributions in that material or in the Appropriate Legal Notices displayed by works containing it; or\n";
			print "\n";
			print "     c) Prohibiting misrepresentation of the origin of that material, or requiring that modified versions of such material be marked in reasonable ways as different from the original version; or\n";
			print "\n";
			print "     d) Limiting the use for publicity purposes of names of licensors or authors of the material; or\n";
			print "\n";
			print "     e) Declining to grant rights under trademark law for use of some trade names, trademarks, or service marks; or\n";
			print "\n";
			print "     f) Requiring indemnification of licensors and authors of that material by anyone who conveys the material (or modified versions of it) with contractual assumptions of liability to the recipient, for any liability that these contractual assumptions directly impose on those licensors and authors.\n";
			print "\n";
			print "   All other non-permissive additional terms are considered \"further restrictions\" within the meaning of section 10.  If the Program as you received it, or any part of it, contains a notice stating that it is governed by this License along with a term that is a further restriction, you may remove that term.  If a license document contains a further restriction but permits relicensing or conveying under this License, you may add to a covered work material governed by the terms of that license document, provided that the further restriction does not survive such relicensing or conveying.\n";
			print "\n";
			print "   If you add terms to a covered work in accord with this section, you must place, in the relevant source files, a statement of the additional terms that apply to those files, or a notice indicating where to find the applicable terms.\n";
			print "\n";
			print "   Additional terms, permissive or non-permissive, may be stated in the form of a separately written license, or stated as exceptions; the above requirements apply either way.\n";
			print "\n";
			print "   8. Termination.\n";
			print "\n";
			print "   You may not propagate or modify a covered work except as expressly provided under this License.  Any attempt otherwise to propagate or modify it is void, and will automatically terminate your rights under this License (including any patent licenses granted under the third paragraph of section 11).\n";
			print "\n";
			print "   However, if you cease all violation of this License, then your license from a particular copyright holder is reinstated (a) provisionally, unless and until the copyright holder explicitly and finally terminates your license, and (b) permanently, if the copyright holder fails to notify you of the violation by some reasonable means prior to 60 days after the cessation.\n";
			print "\n";
			print "   Moreover, your license from a particular copyright holder is reinstated permanently if the copyright holder notifies you of the violation by some reasonable means, this is the first time you have received notice of violation of this License (for any work) from that copyright holder, and you cure the violation prior to 30 days after your receipt of the notice.\n";
			print "\n";
			print "   Termination of your rights under this section does not terminate the licenses of parties who have received copies or rights from you under this License.  If your rights have been terminated and not permanently reinstated, you do not qualify to receive new licenses for the same material under section 10.\n";
			print "\n";
			print "   9. Acceptance Not Required for Having Copies.\n";
			print "\n";
			print "   You are not required to accept this License in order to receive or run a copy of the Program.  Ancillary propagation of a covered work occurring solely as a consequence of using peer-to-peer transmission to receive a copy likewise does not require acceptance.  However, nothing other than this License grants you permission to propagate or modify any covered work.  These actions infringe copyright if you do not accept this License.  Therefore, by modifying or propagating a covered work, you indicate your acceptance of this License to do so.\n";
			print "\n";
			print "   10. Automatic Licensing of Downstream Recipients.\n";
			print "\n";
			print "   Each time you convey a covered work, the recipient automatically receives a license from the original licensors, to run, modify and propagate that work, subject to this License.  You are not responsible for enforcing compliance by third parties with this License.\n";
			print "\n";
			print "   An \"entity transaction\" is a transaction transferring control of an organization, or substantially all assets of one, or subdividing an organization, or merging organizations.  If propagation of a covered work results from an entity transaction, each party to that transaction who receives a copy of the work also receives whatever licenses to the work the party\'s predecessor in interest had or could give under the previous paragraph, plus a right to possession of the Corresponding Source of the work from the predecessor in interest, if the predecessor has it or can get it with reasonable efforts.\n";
			print "\n";
			print "   You may not impose any further restrictions on the exercise of the rights granted or affirmed under this License.  For example, you may not impose a license fee, royalty, or other charge for exercise of rights granted under this License, and you may not initiate litigation (including a cross-claim or counterclaim in a lawsuit) alleging that any patent claim is infringed by making, using, selling, offering for sale, or importing the Program or any portion of it.\n";
			print "\n";
			print "   11. Patents.\n";
			print "\n";
			print "   A \"contributor\" is a copyright holder who authorizes use under this License of the Program or a work on which the Program is based.  The work thus licensed is called the contributor\'s \"contributor version\".\n";
			print "\n";
			print "   A contributor\'s \"essential patent claims\" are all patent claims owned or controlled by the contributor, whether already acquired or hereafter acquired, that would be infringed by some manner, permitted by this License, of making, using, or selling its contributor version, but do not include claims that would be infringed only as a consequence of further modification of the contributor version.  For purposes of this definition, \"control\" includes the right to grant patent sublicenses in a manner consistent with the requirements of this License.\n";
			print "\n";
			print "   Each contributor grants you a non-exclusive, worldwide, royalty-free patent license under the contributor\'s essential patent claims, to make, use, sell, offer for sale, import and otherwise run, modify and propagate the contents of its contributor version.\n";
			print "\n";
			print "   In the following three paragraphs, a \"patent license\" is any express agreement or commitment, however denominated, not to enforce a patent (such as an express permission to practice a patent or covenant not to sue for patent infringement).  To \"grant\" such a patent license to a party means to make such an agreement or commitment not to enforce a patent against the party.\n";
			print "\n";
			print "   If you convey a covered work, knowingly relying on a patent license, and the Corresponding Source of the work is not available for anyone to copy, free of charge and under the terms of this License, through a publicly available network server or other readily accessible means, then you must either (1) cause the Corresponding Source to be so available, or (2) arrange to deprive yourself of the benefit of the patent license for this particular work, or (3) arrange, in a manner consistent with the requirements of this License, to extend the patent license to downstream recipients.  \"Knowingly relying\" means you have actual knowledge that, but for the patent license, your conveying the covered work in a country, or your recipient\'s use of the covered work in a country, would infringe one or more identifiable patents in that country that you have reason to believe are valid.\n";
			print "\n";
			print "   If, pursuant to or in connection with a single transaction or arrangement, you convey, or propagate by procuring conveyance of, a covered work, and grant a patent license to some of the parties receiving the covered work authorizing them to use, propagate, modify or convey a specific copy of the covered work, then the patent license you grant is automatically extended to all recipients of the covered work and works based on it.\n";
			print "\n";
			print "   A patent license is \"discriminatory\" if it does not include within the scope of its coverage, prohibits the exercise of, or is conditioned on the non-exercise of one or more of the rights that are specifically granted under this License.  You may not convey a covered work if you are a party to an arrangement with a third party that is in the business of distributing software, under which you make payment to the third party based on the extent of your activity of conveying the work, and under which the third party grants, to any of the parties who would receive the covered work from you, a discriminatory patent license (a) in connection with copies of the covered work conveyed by you (or copies made from those copies), or (b) primarily for and in connection with specific products or compilations that contain the covered work, unless you entered into that arrangement, or that patent license was granted, prior to 28 March 2007.\n";
			print "\n";
			print "   Nothing in this License shall be construed as excluding or limiting any implied license or other defenses to infringement that may otherwise be available to you under applicable patent law.\n";
			print "\n";
			print "   12. No Surrender of Others\' Freedom.\n";
			print "\n";
			print "   If conditions are imposed on you (whether by court order, agreement or otherwise) that contradict the conditions of this License, they do not excuse you from the conditions of this License.  If you cannot convey a covered work so as to satisfy simultaneously your obligations under this License and any other pertinent obligations, then as a consequence you may not convey it at all.  For example, if you agree to terms that obligate you to collect a royalty for further conveying from those to whom you convey the Program, the only way you could satisfy both those terms and this License would be to refrain entirely from conveying the Program.\n";
			print "\n";
			print "   13. Use with the GNU Affero General Public License.\n";
			print "\n";
			print "   Notwithstanding any other provision of this License, you have permission to link or combine any covered work with a work licensed under version 3 of the GNU Affero General Public License into a single combined work, and to convey the resulting work.  The terms of this License will continue to apply to the part which is the covered work, but the special requirements of the GNU Affero General Public License, section 13, concerning interaction through a network will apply to the combination as such.\n";
			print "\n";
			print "   14. Revised Versions of this License.\n";
			print "\n";
			print "   The Free Software Foundation may publish revised and/or new versions of the GNU General Public License from time to time.  Such new versions will be similar in spirit to the present version, but may differ in detail to address new problems or concerns.\n";
			print "\n";
			print "   Each version is given a distinguishing version number.  If the Program specifies that a certain numbered version of the GNU General Public License \"or any later version\" applies to it, you have the option of following the terms and conditions either of that numbered version or of any later version published by the Free Software Foundation.  If the Program does not specify a version number of the GNU General Public License, you may choose any version ever published by the Free Software Foundation.\n";
			print "\n";
			print "   If the Program specifies that a proxy can decide which future versions of the GNU General Public License can be used, that proxy\'s public statement of acceptance of a version permanently authorizes you to choose that version for the Program.\n";
			print "\n";
			print "   Later license versions may give you additional or different permissions.  However, no additional obligations are imposed on any author or copyright holder as a result of your choosing to follow a later version.\n";
			print "\n";
			print "   15. Disclaimer of Warranty.\n";
			print "\n";
			print "   THERE IS NO WARRANTY FOR THE PROGRAM, TO THE EXTENT PERMITTED BY APPLICABLE LAW.  EXCEPT WHEN OTHERWISE STATED IN WRITING THE COPYRIGHT HOLDERS AND/OR OTHER PARTIES PROVIDE THE PROGRAM \"AS IS\" WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE PROGRAM PROVE DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR CORRECTION.\n";
			print "\n";
			print "   16. Limitation of Liability.\n";
			print "\n";
			print "   IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW OR AGREED TO IN WRITING WILL ANY COPYRIGHT HOLDER, OR ANY OTHER PARTY WHO MODIFIES AND/OR CONVEYS THE PROGRAM AS PERMITTED ABOVE, BE LIABLE TO YOU FOR DAMAGES, INCLUDING ANY GENERAL, SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE USE OR INABILITY TO USE THE PROGRAM (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY YOU OR THIRD PARTIES OR A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS), EVEN IF SUCH HOLDER OR OTHER PARTY HAS BEEN ADVISED OF THE POSSIBILITY OF SUCH DAMAGES.\n";
			print "\n";
			print "   17. Interpretation of Sections 15 and 16.\n";
			print "\n";
			print "   If the disclaimer of warranty and limitation of liability provided above cannot be given local legal effect according to their terms, reviewing courts shall apply local law that most closely approximates an absolute waiver of all civil liability in connection with the Program, unless a warranty or assumption of liability accompanies a copy of the Program in return for a fee.\n";
			print "\n";
			print "====================== END OF TERMS AND CONDITIONS ============================\n";
			print "\n";
			print "\n";
			print "To see the license type:\n";
			print "./box293_check_vmware.pl --license | more\n";
			print "\n";
			} # End sub Print_License {

			
		sub Process_Request_Type {
			Debug_Process('append', 'Line ' . __LINE__ . ' Process_Request_Type');
			$request_type = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $request_type: \'' . $request_type . '\'');
			switch ($request_type) {
				case 'Info' {
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[1]: \'' . $_[1] . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[2]: \'' . $_[2] . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' OK');
					return ($_[1], $_[2], 'OK');
					} # End case 'Info' {
				
				case 'Status' {
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[1]: \'' . $_[1] . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' $_[2]: \'' . $_[2] . '\'');
					return ($_[1], $_[2]);
					} # End case 'Status' {
				} # End switch ($sub_request_type) {
			} # End sub Request_Type {


		sub Process_Percentages {
			Debug_Process('append', 'Line ' . __LINE__ . ' Process_Percentages');
			my $object_a_value = $_[0];
			my $object_b_value = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $object_a_value: \'' . $object_a_value . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $object_b_value: \'' . $object_b_value . '\'');
			
			my $object_a_percentage;
			if (($object_a_value + $object_b_value) == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' ($object_a_value + $object_b_value) == 0');
				$object_a_percentage = 0;
				} # End if (($object_a_value + $object_b_value) == 0) {
			elsif ($object_a_value == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' ($object_a_value == 0');
				$object_a_percentage = 0;
				} # End elsif {
			else {
				$object_a_percentage = ceil(($object_a_value / ($object_a_value + $object_b_value)) * 100);
				} # End else {
			Debug_Process('append', 'Line ' . __LINE__ . ' $object_a_percentage: \'' . $object_a_percentage . '\'');
			
			my $object_b_percentage;
			if ($object_b_value == 0) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $object_b_value == 0');
				$object_b_percentage = 0;
				} # End if ($object_b_value == 0) {
			else {
				$object_b_percentage = 100 - $object_a_percentage;
				} # End else {
			Debug_Process('append', 'Line ' . __LINE__ . ' $object_b_percentage: \'' . $object_b_percentage . '\'');
			
			return ($object_a_percentage, $object_b_percentage)
			} # End sub Process_Percentages {


		sub Process_Plural {
			Debug_Process('append', 'Line ' . __LINE__ . ' Process_Plural');
			
			# The number we are testing against
			my $plural_value = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $plural_value: \'' . $plural_value . '\'');

			# What to return if the number is 0
			my $no_plural = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $no_plural: \'' . $no_plural . '\'');
			
			# What to return if the number is 1
			my $plural = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $plural: \'' . $plural . '\'');
			
			# What to return if the number is > 1
			my $plurals = $_[3];
			Debug_Process('append', 'Line ' . __LINE__ . ' $plurals: \'' . $plurals . '\'');
			
			# Do it
			switch ($plural_value) {
				case 0 {
					Debug_Process('append', 'Line ' . __LINE__ . ' $plural_value = 0');
					return $no_plural;
					} # End case 0 {

				case 1 {
					Debug_Process('append', 'Line ' . __LINE__ . ' $plural_value = 1');
					return $plural;
					} # End case 1 {

				default {
					Debug_Process('append', 'Line ' . __LINE__ . ' $plural_value > 1');
					return $plurals;
					} # End default {
				} # End switch ($plural_value) {
			} # End sub Process_Plural {
		

		sub Query_Get_Arguments {
			Debug_Process('append', 'Line ' . __LINE__ . ' Query_Test');

			# Check to make sure we received all the required options
			if (!Opts::option_is_set('query_url')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'query_url\')');
				Debug_Process('append', 'Line ' . __LINE__ . ' The --query_url argument was not provided, abort');
				# The --query_url argument was not provided, abort
				$exit_message_abort = "The --query_url argument was not provided, aborting!";
				$exit_state_abort = 'UNKNOWN';
				return ($exit_state_abort, $exit_message_abort);
				} # End if (!Opts::option_is_set('query_url')) {
			else {
				if (!Opts::option_is_set('query_username')) {
					Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'query_username\')');
					Debug_Process('append', 'Line ' . __LINE__ . ' The --query_username argument was not provided, abort');
					# The --query_username argument was not provided, abort
					$exit_message_abort = "The --query_username argument was not provided, aborting!";
					$exit_state_abort = 'UNKNOWN';
					return ($exit_state_abort, $exit_message_abort);
					} # End if (!Opts::option_is_set('query_username')) {
				else {
					if (!Opts::option_is_set('query_password')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'query_password\')');
						Debug_Process('append', 'Line ' . __LINE__ . ' The --query_password argument was not provided, abort');
						# The --query_password argument was not provided, abort
						$exit_message_abort = "The --query_password argument was not provided, aborting!";
						$exit_state_abort = 'UNKNOWN';
						return ($exit_state_abort, $exit_message_abort);
						} # End if (!Opts::option_is_set('query_password')) {
					else {
						# All the query parameters exist
						my $query_url = Opts::get_option('query_url');
						Debug_Process('append', 'Line ' . __LINE__ . ' $query_url: \'' . $query_url . '\'');

						my $query_username = Opts::get_option('query_username');
						Debug_Process('append', 'Line ' . __LINE__ . ' $query_username: \'' . $query_username . '\'');

						my $query_password = Opts::get_option('query_password');
						Debug_Process('append', 'Line ' . __LINE__ . ' $query_password: \'' . $query_password . '\'');

						$exit_message_abort = 'OK';
						$exit_state_abort = 'OK';
						
						return ($exit_state_abort, $exit_message_abort, $query_url, $query_username, $query_password);
						} # End else {
					} # End else {
				} # End else {
			} # End sub Query_Get_Arguments {


		sub Query_Perform {
			Debug_Process('append', 'Line ' . __LINE__ . ' Query_Perform');
			use LWP::UserAgent;
			my $query_type = $_[0];
			my $query_url = $_[1];
			my $query_username = $_[2];
			my $query_password = $_[3];
			my $query_to_perform = $_[4];
			
			# Contruct the Nagios query
			my $lwp_ua = LWP::UserAgent->new;
			my $lwp_request = HTTP::Request->new(GET => $query_url . $query_to_perform);
			$lwp_request->authorization_basic($query_username, $query_password);

			# Perform the query
			my $query_result = $lwp_ua->request($lwp_request);
			Debug_Process('append', 'Line ' . __LINE__ . ' $query_result:"' . "\n" . $query_result . '"');
			Debug_Process('append', 'Line ' . __LINE__ . ' $query_result->content:"' . "\n" . $query_result->content . '"');

			# This is what will be returned
			my $query_exit_status;
			my $query_exit_message;
			
			# Proceed if the query received valid data
			if ($query_result->content =~ /"type_code":/) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Query received valid data');
				if ($query_result->content =~ /"type_code": 0,/) {
					Debug_Process('append', 'Line ' . __LINE__ . ' Query was successfull');

					# Define the query status
					$query_exit_status = 'OK';
					$query_exit_message = 'OK';
					
					# Get the requested data from the query
					Debug_Process('append', 'Line ' . __LINE__ . ' Get the requested data from the query');
					switch ($query_type) {
						case 'host_object_exists' {
							Debug_Process('append', 'Line ' . __LINE__ . ' case \'host_object_exists\' {');
							return 'true';
							} # End case 'host_object_exists' {


						case 'parent_hosts' {
							Debug_Process('append', 'Line ' . __LINE__ . ' case \'parent_hosts\' {');
							my @query_result_parent_hosts_array;
			
							# Now get the parent_hosts from the query
							my $query_result_parent_hosts;
							if ($query_result->content =~ /"parent_hosts":\s*\[((.*\s*)+?)\],/) {
								Debug_Process('append', 'Line ' . __LINE__ . ' parent_hosts value found');
								$query_result_parent_hosts = $1;
								Debug_Process('append', 'Line ' . __LINE__ . ' $query_result_parent_hosts: \'' . $query_result_parent_hosts . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' Removing pre new lines from $query_result_parent_hosts');
								$query_result_parent_hosts =~ s/^\s*//g;
								Debug_Process('append', 'Line ' . __LINE__ . ' $query_result_parent_hosts: \'' . $query_result_parent_hosts . '\'');
								Debug_Process('append', 'Line ' . __LINE__ . ' Removing post new lines from $query_result_parent_hosts');
								$query_result_parent_hosts =~ s/\s*$//g;
								Debug_Process('append', 'Line ' . __LINE__ . ' $query_result_parent_hosts: \'' . $query_result_parent_hosts . '\'');
								} # End if ($query_result->content =~ /"parent_hosts":\s*\[\s*((.*\s*)+?)\],/) {
							
							# Put the results in an array
							if (defined($query_result_parent_hosts)) {
								push (@query_result_parent_hosts_array, split(/,\s+/, $query_result_parent_hosts));
								} # End if (defined($query_result_parent_hosts) {
							Debug_Process('append', 'Line ' . __LINE__ . ' @query_result_parent_hosts_array total items: \'' . scalar @query_result_parent_hosts_array . '\'');

							Debug_Process('append', 'Line ' . __LINE__ . ' $query_exit_status: "' . $query_exit_status . '"');
							Debug_Process('append', 'Line ' . __LINE__ . ' $query_exit_message: "' . $query_exit_message . '"');
							return (\@query_result_parent_hosts_array, $query_exit_status, $query_exit_message);
							} # End case 'parent_hosts' {
						} # End switch ($query_type) {
					} # End if ($query_result->content =~ /"type_code": 0,/) {
				elsif ($query_result->content =~ /"type_code": [46],/ && $query_type eq 'host_object_exists') {
					Debug_Process('append', 'Line ' . __LINE__ . ' Query was not successfull BUT this is a host_object_exists REQUEST');
					return 'false';
					} # End elsif ($query_result->content =~ /"type_code": [46],/ && $query_type eq 'host_object_exists') {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' Query was not successfull!');
					$query_exit_status = 'UNKNOWN';
					# Get the message
					if ($query_result->content =~ /"message":\s(.*)\s/) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $query_result->content =~ /"message":\s(.*)\s/');
						$query_exit_message = $1;
						} # End if ($query_result->content =~ /"message":\s(.*)\s/) {
					else {
						$query_exit_message = 'UNKNOWN';
						my @query_result_unknown = split(/\R/, $query_result->content);
						$query_exit_message = $query_result_unknown[0];
						} # End else {

					Debug_Process('append', 'Line ' . __LINE__ . ' $query_exit_status: "' . $query_exit_status . '"');
					Debug_Process('append', 'Line ' . __LINE__ . ' $query_exit_message: "' . $query_exit_message . '"');
					return ('', $query_exit_status, $query_exit_message);
					} # End else {
				} # End if ($query_result->content =~ /"type_code":/) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' Query was not successfull!');
				$query_exit_status = 'UNKNOWN';
				my @query_result_unknown = split(/\R/, $query_result->content);
				$query_exit_message = $query_result_unknown[0];

				Debug_Process('append', 'Line ' . __LINE__ . ' $query_exit_status: "' . $query_exit_status . '"');
				Debug_Process('append', 'Line ' . __LINE__ . ' $query_exit_message: "' . $query_exit_message . '"');
				return ('', $query_exit_status, $query_exit_message);
				} # End else {
			
			} # End sub Query_Perform {


		sub Reverse_IP_Lookup {
			Debug_Process('append', 'Line ' . __LINE__ . ' Reverse_IP_Lookup');
			my $ip_address_supplied = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $ip_address_supplied: \'' . $ip_address_supplied . '\'');
			use Socket;

			# Determine if this is an IPv4 or IPv6 Address
			my $reverse_ip_lookup_result;
			if ($ip_address_supplied =~ /:/) {
				Debug_Process('append', 'Line ' . __LINE__ . ' IPv6 Address Detected');
				#$reverse_ip_lookup_result = gethostbyaddr(inet_pton($ip_address_supplied),AF_INET6);
				Debug_Process('append', 'Line ' . __LINE__ . ' IPv6 functionality currently not implemented ... coming soon');
				} # End if ($ip_address_supplied =~ /:/) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' IPv4 Address Detected');
				$reverse_ip_lookup_result = gethostbyaddr(inet_aton($ip_address_supplied),AF_INET);
				} # End else {
			
			# Determine if the Reverse IP Lookup Succeeded
			if (defined($reverse_ip_lookup_result)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' defined($reverse_ip_lookup_result)');
				Debug_Process('append', 'Line ' . __LINE__ . ' $reverse_ip_lookup_result: \'' . $reverse_ip_lookup_result . '\'');
				return $reverse_ip_lookup_result;
				} # End if (defined($reverse_ip_lookup_result)) {
			else {
				return $ip_address_supplied;
				} # End else {
			} # End sub Reverse_IP_Lookup {

			
		sub Server_Type {
			Debug_Process('append', 'Line ' . __LINE__ . ' Server_Type');
			# Used to identify if we are connected to a vCenter Server or an ESX(i) Host
			my $target_service_content = Vim::get_service_content();
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_service_content: \'' . $target_service_content . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_service_content->about->apiType: \'' . $target_service_content->about->apiType . '\'');
			return $target_service_content->about->apiType;
			} # End sub Server_Type {


		sub SI_Get {
			Debug_Process('append', 'Line ' . __LINE__ . ' SI_Get');

			# Object Type = CPU_Speed, Latency, Datastore_Rate, Disk_Rate etc
			$si_object_type = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_object_type: \'' . $si_object_type . '\'');
			
			# Prefix = Hz/kHz/MHz/GHz/THz or B/kB/MB/GB/TB/PB/EB etc
			$si_prefix_default = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_default: \'' . $si_prefix_default . '\'');
			
			# Store the user provided values here
			my $reporting_si_hash;
			
			# Determine if the user provided the reporting_si argument
			if (Opts::option_is_set('reporting_si')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' --reporting_si option is set');
				
				# Put the options into an array
				my @reporting_si_array = split(/,/, Opts::get_option('reporting_si'));
				Debug_Process('append', 'Line ' . __LINE__ . ' @reporting_si_array: \'' . @reporting_si_array . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @reporting_si_array values: \'' . join(", ", @reporting_si_array) . '\'');
			
				# Now put the options into a hash as each option has two parts
				foreach (@reporting_si_array) {
					my @current_option = split(/:/, $_);
					$reporting_si_hash->{$current_option[0]} = $current_option[1];
					Debug_Process('append', 'Line ' . __LINE__ . ' @current_option: \'' . @current_option . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @current_option values: \'' . join(", ", @current_option) . '\'');
					} # End foreach (@reporting_si_array) {
				} # End if (Opts::option_is_set('reporting_si')) {
			
			# Now determine what the $si_prefix_to_return should be
			if ($reporting_si_hash->{$si_object_type}) {
				# Use the prefix defined by the user
				$si_prefix_to_return = $reporting_si_hash->{$si_object_type};
				Debug_Process('append', 'Line ' . __LINE__ . ' Use the SI prefix defined by the user');
				Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return = $reporting_si_hash->{$si_object_type}');
				} # End if ($reporting_si_hash->{$si_object_type}) {
			else {
				# Use the default prefix
				Debug_Process('append', 'Line ' . __LINE__ . ' Use the default SI prefix');
				$si_prefix_to_return = $si_prefix_default;
				} #End else {

			Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return: \'' . $si_prefix_to_return . '\'');
			return $si_prefix_to_return;
			} # End sub SI_Get {


		sub SI_Process {
			Debug_Process('append', 'Line ' . __LINE__ . ' SI_Process');
			# Process International System of Units for results manipulation
			# Type = CPU_Speed, Datastore_Cluster_Size, Datastore_Rate, Datastore_Size, Disk_Rate, Disk_Size, Memory_Rate, Memory_Size, NIC_Rate etc
			$si_type = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_type: \'' . $si_type . '\'');
			
			# Prefix = Hz/kHz/MHz/GHz/THz or B/kB/MB/GB/TB/PB/EB or Bps/kBps/MBps/GBps/TBps/PBps/EBps etc
			$si_prefix_current = $_[1];
			$si_prefix_to_return = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_current: \'' . $si_prefix_current . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_prefix_to_return: \'' . $si_prefix_to_return . '\'');
			
			# Value = The value you have provided
			$si_value_current = $_[3];
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_current: \'' . $si_value_current . '\'');
			
			switch ($si_type) {
				case 'CPU_Speed' {
					Debug_Process('append', 'Line ' . __LINE__ . ' CPU_Speed');
					$si_value_to_return = $si_value_current * $SI_Hertz{$si_prefix_current};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					$si_value_to_return = $si_value_to_return / $SI_Hertz{$si_prefix_to_return};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					
					# Work out if we want decimal places or not
					if ($SI_Hertz{$si_prefix_current} < $SI_Hertz{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Hertz{$si_prefix_current} < $SI_Hertz{$si_prefix_to_return');
						# The $si_prefix_current < $si_prefix_to_return
						$si_value_to_return = sprintf("%.1f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						# If it ends with a .0 then remove it
						if ($si_value_to_return =~ /.0$/) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return =~ /.0$/');
							$si_value_to_return = sprintf("%.0f", $si_value_to_return);
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
							} # End if ($si_value_to_return =~ /.0$/) {
						} # End if ($SI_Hertz{$si_prefix_current} < $SI_Hertz{$si_prefix_to_return}) {
					elsif ($SI_Hertz{$si_prefix_current} > $SI_Hertz{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Hertz{$si_prefix_current} > $SI_Hertz{$si_prefix_to_return}');
						$si_value_to_return = sprintf("%.0f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						} # End elsif ($SI_Hertz{$si_prefix_current} > $SI_Hertz{$si_prefix_to_return}) {
					} # End case 'CPU_Speed' {
				
				case 'Time' {
					$si_value_to_return = $si_value_current * $SI_Time{$si_prefix_current};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					$si_value_to_return = $si_value_to_return / $SI_Time{$si_prefix_to_return};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					
					# Work out if we want decimal places or not
					if ($SI_Time{$si_prefix_current} < $SI_Time{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Time{$si_prefix_current} < $SI_Time{$si_prefix_to_return}');
						# The $si_prefix_current < $si_prefix_to_return
						$si_value_to_return = sprintf("%.3f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						} # End if ($SI_Time{$si_prefix_current} < $SI_Time{$si_prefix_to_return}) {
					elsif ($SI_Time{$si_prefix_current} > $SI_Time{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Time{$si_prefix_current} > $SI_Time{$si_prefix_to_return}');
						$si_value_to_return = sprintf("%.0f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						} # End elsif ($SI_Time{$si_prefix_current} > $SI_Time{$si_prefix_to_return}) {
					} # End case 'Time' {
				
				case /^(Datastore_Cluster_Size|Datastore_Size|Disk_Size|Memory_Size)$/ {
					$si_value_to_return = $si_value_current * $SI_Bytes{$si_prefix_current};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					$si_value_to_return = $si_value_to_return / $SI_Bytes{$si_prefix_to_return};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					
					# Work out if we want decimal places or not
					if ($SI_Bytes{$si_prefix_current} < $SI_Bytes{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Bytes{$si_prefix_current} < $SI_Bytes{$si_prefix_to_return}');
						# The $si_prefix_current < $si_prefix_to_return
						$si_value_to_return = sprintf("%.1f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						# If it ends with a .0 then remove it
						if ($si_value_to_return =~ /.0$/) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return =~ /.0$/');
							$si_value_to_return = sprintf("%.0f", $si_value_to_return);
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
							} # End if ($si_value_to_return =~ /.0$/) {
						} # End if ($SI_Bytes{$si_prefix_current} < $SI_Bytes{$si_prefix_to_return}) {
					elsif ($SI_Bytes{$si_prefix_current} > $SI_Bytes{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Bytes{$si_prefix_current} > $SI_Bytes{$si_prefix_to_return}');
						$si_value_to_return = sprintf("%.0f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						} # End elsif ($SI_Bytes{$si_prefix_current} > $SI_Bytes{$si_prefix_to_return}) {
					} # End case /^(Datastore_Cluster_Size|Datastore_Size|Disk_Size|Memory_Size)$/ {
				
				case /^(Datastore_Rate|Disk_Rate|HBA_Rate|Memory_Rate|NIC_Rate)$/ {
					$si_value_to_return = $si_value_current * $SI_Bytes_PS{$si_prefix_current};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					$si_value_to_return = $si_value_to_return / $SI_Bytes_PS{$si_prefix_to_return};
					Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
					
					# Work out if we want decimal places or not
					if ($SI_Bytes_PS{$si_prefix_current} < $SI_Bytes_PS{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Bytes_PS{$si_prefix_current} < $SI_Bytes_PS{$si_prefix_to_return}');
						# The $si_prefix_current < $si_prefix_to_return
						$si_value_to_return = sprintf("%.1f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						# If it ends with a .0 then remove it
						if ($si_value_to_return =~ /.0$/) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return =~ /.0$/');
							$si_value_to_return = sprintf("%.0f", $si_value_to_return);
							Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
							} # End if ($si_value_to_return =~ /.0$/) {
						} # End if ($SI_Bytes_PS{$si_prefix_current} < $SI_Bytes_PS{$si_prefix_to_return}) {
					elsif ($SI_Bytes_PS{$si_prefix_current} > $SI_Bytes_PS{$si_prefix_to_return}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $SI_Bytes_PS{$si_prefix_current} > $SI_Bytes_PS{$si_prefix_to_return}');
						$si_value_to_return = sprintf("%.0f", $si_value_to_return);
						Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
						} # End elsif ($SI_Bytes_PS{$si_prefix_current} > $SI_Bytes_PS{$si_prefix_to_return}) {
					} # End case /^(Datastore_Rate|Disk_Rate|HBA_Rate|Memory_Rate|NIC_Rate)$/ {
				} # End switch ($si_type) {
			Debug_Process('append', 'Line ' . __LINE__ . ' $si_value_to_return: \'' . $si_value_to_return . '\'');
			return $si_value_to_return;
			} # End sub SI_Process {

			
		sub SI_Test {
			Debug_Process('append', 'Line ' . __LINE__ . ' SI_Test');
			$exit_state_abort = 'OK';
			# Determine if the user provided the reporting_si argument
			if (Opts::option_is_set('reporting_si')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'reporting_si\')');
				# Put the options into an array
				my @reporting_si_array = split(/,/, Opts::get_option('reporting_si'));

				Debug_Process('append', 'Line ' . __LINE__ . ' @reporting_si_array: \'' . @reporting_si_array . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @reporting_si_array values: \'' . join(", ", @reporting_si_array) . '\'');
				
				# Now put the options into a hash as each option has two parts
				foreach (@reporting_si_array) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');

					my @current_option = split(/:/, $_);
					Debug_Process('append', 'Line ' . __LINE__ . ' @current_option: \'' . @current_option . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @current_option values: \'' . join(", ", @current_option) . '\'');

					if (defined($current_option[0])) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($current_option[0])');
						Debug_Process('append', 'Line ' . __LINE__ . ' $current_option[0]: \'' . $current_option[0] . '\'');
						if (defined($current_option[1])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($current_option[1])');
							Debug_Process('append', 'Line ' . __LINE__ . ' $current_option[1]: \'' . $current_option[1] . '\'');

							# Check to make sure the provided prefix is valid
							if ($SI_Lookup{$current_option[0]}->{$current_option[1]}) {
								Debug_Process('append', 'Line ' . __LINE__ . ' The provided prefix is valid');
								# It's valid
								} # End if ($SI_Lookup{$current_option[0]}->{$current_option[1]}) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' The provided prefix is NOT valid');
								# It's not valid, abort!
								$exit_message_abort = Build_Message($exit_message_abort, "The --reporting_si prefix " . $current_option[1] . " for " . $current_option[0] . " is NOT valid!");
								$exit_state_abort = 'UNKNOWN';
								} # End else {
							} # End if (defined($current_option[1])) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' The provided prefix has been left BLANK');
							$exit_message_abort = Build_Message($exit_message_abort, "The --reporting_si prefix for " . $current_option[0] . " CANNOT be left blank!");
							$exit_state_abort = 'UNKNOWN';
							} # End else {
						} # End if (defined($current_option[0])) {
					} # End foreach (@reporting_si_array) {
				} # End if (Opts::option_is_set('reporting_si')) {
			
			return ($exit_message_abort, $exit_state_abort);
			} # End sub SI_Test {


		sub Test_Parents {
			Debug_Process('append', 'Line ' . __LINE__ . ' Test_Parents');
			
			my @parents_array = @{$_[0]};
			Debug_Process('append', 'Line ' . __LINE__ . ' @parents_array total items: \'' . scalar @parents_array . '\'');

			my $host_name_to_test = $_[1];
			Debug_Process('append', 'Line ' . __LINE__ . ' $host_name_to_test: \'' . $host_name_to_test . '\'');

			my $message_is = $_[2];
			Debug_Process('append', 'Line ' . __LINE__ . ' $message_is: \'' . $message_is . '\'');

			my $state_is = $_[3];
			Debug_Process('append', 'Line ' . __LINE__ . ' $state_is: \'' . $state_is . '\'');

			my $message_is_not = $_[4];
			Debug_Process('append', 'Line ' . __LINE__ . ' $message_is_not: \'' . $message_is_not . '\'');

			my $state_is_not = $_[5];
			Debug_Process('append', 'Line ' . __LINE__ . ' $state_is_not: \'' . $state_is_not . '\'');

			my $query_url = $_[6];
			my $query_username = $_[7];
			my $query_password = $_[8];
			
			my $exit_state_return;
			my $exit_message_return;

			#(\@parents_array, $host_name_to_test, $message_is, $message_is_not)

			
			# Determine if the $host_name_to_test IS one of the host parents defined
			my $host_parent_test = 0;
			foreach my $parent_host_item (@parents_array) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $parent_host_item: \'' . $parent_host_item . '\'');
				if ($parent_host_item eq '"' . $host_name_to_test . '"') {
					$host_parent_test = 1;
					} # End if ($parent_host_item eq '"' . $host_name_to_test . '"') {
				} # End foreach my $parent_host_item (@parents_array) {

			# Determine what the exit message / state should be
			if ($host_parent_test == 1) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_parent_test == 1');
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_name_to_test IS one of the Nagios parent_hosts');
				$exit_state_return = $state_is;
				$exit_message_return = $message_is . '=' . $host_name_to_test;
				} # End if ($host_parent_test == 1) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_parent_test != 1');
				Debug_Process('append', 'Line ' . __LINE__ . ' $host_name_to_test is NOT one of the Nagios parent_hosts');
				Debug_Process('append', 'Line ' . __LINE__ . ' Make sure the parent host actually exists');
				# Make sure the parent host actually exists
				my $host_object_check = Test_Parent_Exists_In_Nagios($host_name_to_test, $query_url, $query_username, $query_password);
				switch ($host_object_check) {
					case 'true' {
						$exit_state_return = $state_is_not;
						$exit_message_return = $message_is_not . '=' . $host_name_to_test;	
						} # End case 'true' {

					case 'false' {
						$exit_state_return = $state_is_not;
						$exit_message_return = 'Cannot_Find_Nagios_Host_Object_Hence_Cannot_Define_Parent' . '=' . $host_name_to_test;	
						} # End case 'false' {
					} # End switch ($host_object_check) {
				} # End else {

			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_return: \'' . $exit_state_return . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_message_return: \'' . $exit_message_return . '\'');
			return ($exit_state_return, $exit_message_return);
			} # End sub Test_Parents {


		sub Test_Parent_Exists_In_Nagios {
			Debug_Process('append', 'Line ' . __LINE__ . ' Test_Parent_Exists_In_Nagios');

			my $parent_host = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $parent_host: \'' . $parent_host . '\'');

			my $query_url = $_[1];
			my $query_username = $_[2];
			my $query_password = $_[3];
			
			my $query_to_perform_parent = '?query=host&hostname=' . $parent_host;
			Debug_Process('append', 'Line ' . __LINE__ . ' $query_to_perform_parent: \'' . $query_to_perform_parent . '\'');

			# Run the query to get the host Object
			my $parent_host_query_result = Query_Perform('host_object_exists', $query_url, $query_username, $query_password, $query_to_perform_parent);

			return $parent_host_query_result;
			} # End sub Test_Parent_Exists_In_Nagios {

		
		sub Test_User_Option {
			Debug_Process('append', 'Line ' . __LINE__ . ' Test_User_Option');
			my $user_option = $_[0];
			my $user_option_test_value = $_[1];
			my $user_option_failed_test_value_state = $_[2];
			my $failed_test_value_message = $_[3];
			my $passed_test_value_message = $_[4];
			my $user_option_default_value = $_[5];
			
			Debug_Process('append', 'Line ' . __LINE__ . ' $user_option: \'' . $user_option . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $user_option_test_value: \'' . $user_option_test_value . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $user_option_failed_test_value_state: \'' . $user_option_failed_test_value_state . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $failed_test_value_message: \'' . $failed_test_value_message . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $passed_test_value_message: \'' . $passed_test_value_message . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $user_option_default_value: \'' . $user_option_default_value . '\'');
			
			# Is the option set, should we test for it?
			if (Opts::option_is_set($user_option)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $user_option is set: \'' . $user_option . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::get_option($user_option): \'' . Opts::get_option($user_option) . '\'');
				# Option is set, check the provided $user_option_test_value against the $user_option
				if (Opts::get_option($user_option) ne $user_option_test_value) {
					Debug_Process('append', 'Line ' . __LINE__ . ' Opts::get_option($user_option) ne $user_option_test_value');
					return ($user_option_failed_test_value_state, "$failed_test_value_message $user_option_test_value but should be " . Opts::get_option($user_option));
					} # End if (Opts::get_option($user_option) ne $user_option_test_value) {
				else {
					# Return an OK state
					Debug_Process('append', 'Line ' . __LINE__ . ' Return an OK state');
					return ('OK', $passed_test_value_message);
					} # End else {
				} # End if (Opts::option_is_set($user_option)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' $user_option was not defined');
				# The $user_option was not defined
				# Check to see if there is no_default value
				if ($user_option_default_value eq 'no_default') {
					Debug_Process('append', 'Line ' . __LINE__ . ' $user_option_default_value eq no_default');
					Debug_Process('append', 'Line ' . __LINE__ . ' Return an OK state');
					# Return an OK state
					return ('OK', $passed_test_value_message);
					}
				else {
					# If the $user_option_default_value is not the same then return the $user_option_failed_test_value_state
					if ($user_option_default_value ne $user_option_test_value) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $user_option_default_value ne $user_option_test_value');
						return ($user_option_failed_test_value_state, "$failed_test_value_message $user_option_test_value but should be $user_option_default_value");
						} # End if ($user_option_default_value ne $user_option_test_value) {
					else {
						Debug_Process('append', 'Line ' . __LINE__ . ' Return an OK state');
						# Return an OK state
						return ('OK', $passed_test_value_message);
						} # End else {
					} # End } # End else {
				} # End else {
			} # End sub Test_User_Option {


		sub Test_User_Option_Always_OK {
			Debug_Process('append', 'Line ' . __LINE__ . ' Test_User_Option_Always_OK');
			my $user_option = $_[0];
			Debug_Process('append', 'Line ' . __LINE__ . ' $user_option: \'' . $user_option . '\'');
			
			my $test_user_option_always_ok_return;
			if (Opts::option_is_set($user_option)) {
				Debug_Process('append', 'Line ' . __LINE__ . ' $user_option is set: \'' . $user_option . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::get_option($user_option): \'' . Opts::get_option($user_option) . '\'');
				if (Opts::get_option($user_option) eq 'AlwaysOK') {
					Debug_Process('append', 'Line ' . __LINE__ . ' Opts::get_option($user_option) eq \'AlwaysOK\'');
					$test_user_option_always_ok_return = 1;
					} # End if (Opts::get_option($user_option) eq 'AlwaysOK') {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' Opts::get_option($user_option) ne \'AlwaysOK\'');
					$test_user_option_always_ok_return = 0;
					} # End else {
				} # End if (Opts::option_is_set($user_option)) {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set($user_option) WAS NOT SET');
				$test_user_option_always_ok_return = 0;
				} # End else {
			Debug_Process('append', 'Line ' . __LINE__ . ' $test_user_option_always_ok_return: \'' . $test_user_option_always_ok_return . '\'');
				
			return $test_user_option_always_ok_return;
			} # End sub Test_User_Option_Always_OK {


		sub Thresholds_Get {
			Debug_Process('append', 'Line ' . __LINE__ . ' Thresholds_Get');
			my %Thresholds_User;
			# Determine if user supplied warning thresholds
			if (Opts::option_is_set('warning')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'warning\')');
				my @warnings = split(/,/, Opts::get_option('warning'));
				Debug_Process('append', 'Line ' . __LINE__ . ' @warnings: \'' . @warnings . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @warnings values: \'' . join(", ", @warnings) . '\'');
				
				foreach my $warning_item (@warnings) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $warning_item: \'' . $warning_item . '\'');
					my @warning_item_split = split(/:/, $warning_item);
					Debug_Process('append', 'Line ' . __LINE__ . ' @warning_item_split: \'' . @warning_item_split . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @warning_item_split values: \'' . join(", ", @warning_item_split) . '\'');
				
					if (defined($warning_item_split[0])) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($warning_item_split[0])');
						Debug_Process('append', 'Line ' . __LINE__ . ' $warning_item_split[0]: \'' . $warning_item_split[0] . '\'');
						if (defined($warning_item_split[1])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($warning_item_split[1])');
							Debug_Process('append', 'Line ' . __LINE__ . ' $warning_item_split[1]: \'' . $warning_item_split[1] . '\'');
							my $warning_value = $warning_item_split[1];
							$Thresholds_User{'warning'}{$warning_item_split[0]} = $warning_value;
							} # End if (defined($warning_item_split[1])) {
						} #End if (defined($warning_item_split[0])) {
					} # End foreach my $warning_item (@warnings) {	
				} # End if (Opts::option_is_set('warning')) {
			
			# Determine if user supplied critical thresholds
			if (Opts::option_is_set('critical')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'critical\')');
				my @criticals = split(/,/, Opts::get_option('critical'));
				Debug_Process('append', 'Line ' . __LINE__ . ' @criticals: \'' . @criticals . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @criticals values: \'' . join(", ", @criticals) . '\'');
				
				foreach my $critical_item (@criticals) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $critical_item: \'' . $critical_item . '\'');
					my @critical_item_split = split(/:/, $critical_item);
					Debug_Process('append', 'Line ' . __LINE__ . ' @critical_item_split: \'' . @critical_item_split . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @critical_item_split values: \'' . join(", ", @critical_item_split) . '\'');
				
					if (defined($critical_item_split[0])) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($critical_item_split[0])');
						Debug_Process('append', 'Line ' . __LINE__ . ' $critical_item_split[0]: \'' . $critical_item_split[0] . '\'');
						if (defined($critical_item_split[1])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($critical_item_split[1])');
							Debug_Process('append', 'Line ' . __LINE__ . ' $critical_item_split[1]: \'' . $critical_item_split[1] . '\'');
							my $critical_value = $critical_item_split[1];
							$Thresholds_User{'critical'}{$critical_item_split[0]} = $critical_value;
							} # End if (defined($critical_item_split[1])) {
						} #End if (defined($critical_item_split[0])) {
					} # End foreach my $critical_item (@criticals) {	
				} # End if (Opts::option_is_set('critical')) {
			
			return %Thresholds_User;
			} # End sub Thresholds_Get {


		sub Thresholds_Process {
			Debug_Process('append', 'Line ' . __LINE__ . ' Thresholds_Process');
			my $threshold_check = $_[0];
			my $threshold_type = $_[1];
			my $threshold_value = $_[2];
			my $threshold_warning = $_[3];
			my $threshold_critical = $_[4];
			my $message_string;
			my $exit_state_to_return;

			Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_check: \'' . $threshold_check . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_type: \'' . $threshold_type . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value: \'' . $threshold_value . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning: \'' . $threshold_warning . '\'');
			Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical: \'' . $threshold_critical . '\'');
			
			switch ($threshold_check) {
				case 'ne' {
					# Testing to see if the thresholds are NOT EQUAL to the value
					# Determine if user supplied a warning threshold
					if (looks_like_number($threshold_warning)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning looks like a number');
						# Check to see see if $threshold_value is NOT EQUAL $threshold_warning
						if ($threshold_value != $threshold_warning) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value != $threshold_warning');
							$message_string = ' (WARNING != ' . Format_Number_With_Commas($threshold_warning) . ')';
							$exit_state_to_return = 'WARNING';
							last;
							} # End if ($threshold_value != $threshold_warning) {
						} # End if (looks_like_number($threshold_warning)) {
					elsif (looks_like_number($threshold_critical)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
						# Check to see see if $threshold_value exceeds $threshold_critical
						if ($threshold_value != $threshold_critical) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value != $threshold_critical');
							$message_string = ' (CRITICAL != ' . Format_Number_With_Commas($threshold_critical) . ')';
							$exit_state_to_return = 'CRITICAL';
							} # End if ($threshold_value != $threshold_critical) {
						} # End elsif (looks_like_number($threshold_critical)) {
					else {
						$message_string = '';
						$exit_state_to_return = 'OK';
						} # End else {
					} # End case 'ne' {
				
				
				case 'ge' {
					# Testing to see if the thresholds are GREATER than or equal to the value
					# Determine if user supplied a warning threshold
					if (looks_like_number($threshold_warning)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning looks like a number');
						# Determine if user supplied a critcial threshold
						if (looks_like_number($threshold_critical)) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
							# First check to make sure that $threshold_warning is less than $threshold_critical
							if ($threshold_warning < $threshold_critical) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning < $threshold_critical');
								# Check to see see if $threshold_value exceeds $threshold_critical
								if ($threshold_value >= $threshold_critical) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value >= $threshold_critical');
									$message_string = ' (CRITICAL >= ' . Format_Number_With_Commas($threshold_critical) . ')';
									$exit_state_to_return = 'CRITICAL';
									last;
									} # End if ($threshold_value >= $threshold_critical) {
								# Check to see see if $threshold_value exceeds $threshold_warning
								elsif ($threshold_value >= $threshold_warning) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value >= $threshold_warning');
									$message_string = ' (WARNING >= ' . Format_Number_With_Commas($threshold_warning) . ')';
									$exit_state_to_return = 'WARNING';
									last;
									} # End elsif ($threshold_value >= $threshold_warning) {
								else {
									$message_string = '';
									$exit_state_to_return = 'OK';
									last;
									} # End else {
								} # End if ($threshold_warning <= $threshold_critical) {
							else {
								# The user has provided incorrectly oriented warning and critical values
								Debug_Process('append', 'Line ' . __LINE__ . " The warning value '$threshold_warning' MUST be LESS than the critical value '$threshold_critical' for '$threshold_type'!");
								$message_string = " (The warning value ($threshold_warning) MUST be LESS than the critical value ($threshold_critical) for \'$threshold_type\'!)";
								$exit_state_to_return = 'UNKNOWN';
								last;
								} # End else {
							} # End if (looks_like_number($threshold_critical)) {
						# Check to see see if $threshold_value exceeds $threshold_warning
						if ($threshold_value >= $threshold_warning) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value >= $threshold_warning');
							$message_string = ' (WARNING >= ' . Format_Number_With_Commas($threshold_warning) . ')';
							$exit_state_to_return = 'WARNING';
							last;
							} # End if ($threshold_value >= $threshold_warning) {
						} # End if (looks_like_number($threshold_warning)) {
					elsif (looks_like_number($threshold_critical)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
						# Check to see see if $threshold_value exceeds $threshold_critical
						if ($threshold_value >= $threshold_critical) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value >= $threshold_critical');
							$message_string = ' (CRITICAL >= ' . Format_Number_With_Commas($threshold_critical) . ')';
							$exit_state_to_return = 'CRITICAL';
							} # End if ($threshold_value >= $threshold_critical) {
						} # End elsif (looks_like_number($threshold_critical)) {
					else {
						$message_string = '';
						$exit_state_to_return = 'OK';
						} # End else {
					} # End case 'ge' {
				
				
				case 'gt' {
					# Testing to see if the thresholds are GREATER than the value
					# Determine if user supplied a warning threshold
					if (looks_like_number($threshold_warning)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning looks like a number');
						# Determine if user supplied a critcial threshold
						if (looks_like_number($threshold_critical)) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
							# First check to make sure that $threshold_warning is less than $threshold_critical
							if ($threshold_warning < $threshold_critical) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning < $threshold_critical');
								# Check to see see if $threshold_value exceeds $threshold_critical
								if ($threshold_value > $threshold_critical) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value > $threshold_critical');
									$message_string = ' (CRITICAL > ' . Format_Number_With_Commas($threshold_critical) . ')';
									$exit_state_to_return = 'CRITICAL';
									last;
									} # End if ($threshold_value > $threshold_critical) {
								# Check to see see if $threshold_value exceeds $threshold_warning
								elsif ($threshold_value > $threshold_warning) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value > $threshold_warning');
									$message_string = ' (WARNING > ' . Format_Number_With_Commas($threshold_warning) . ')';
									$exit_state_to_return = 'WARNING';
									last;
									} # End elsif ($threshold_value > $threshold_warning) {
								else {
									$message_string = '';
									$exit_state_to_return = 'OK';
									last;
									} # End else {
								} # End if ($threshold_warning < $threshold_critical) {
							else {
								# The user has provided incorrectly oriented warning and critical values
								Debug_Process('append', 'Line ' . __LINE__ . " The warning value '$threshold_warning' MUST be LESS than the critical value '$threshold_critical' for '$threshold_type'!");
								$message_string = " (The warning value ($threshold_warning) MUST be LESS than the critical value ($threshold_critical) for \'$threshold_type\'!)";
								$exit_state_to_return = 'UNKNOWN';
								last;
								} # End else {
							} # End if (looks_like_number($threshold_critical)) {
						# Check to see see if $threshold_value exceeds $threshold_warning
						if ($threshold_value > $threshold_warning) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value > $threshold_warning');
							$message_string = ' (WARNING > ' . Format_Number_With_Commas($threshold_warning) . ')';
							$exit_state_to_return = 'WARNING';
							last;
							} # End if ($threshold_value > $threshold_warning) {
						} # End if (looks_like_number($threshold_warning)) {
					elsif (looks_like_number($threshold_critical)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
						# Check to see see if $threshold_value exceeds $threshold_critical
						if ($threshold_value > $threshold_critical) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value > $threshold_critical');
							$message_string = ' (CRITICAL > ' . Format_Number_With_Commas($threshold_critical) . ')';
							$exit_state_to_return = 'CRITICAL';
							} # End if ($threshold_value > $threshold_critical) {
						} # End elsif (looks_like_number($threshold_critical)) {
					else {
						$message_string = '';
						$exit_state_to_return = 'OK';
						} # End else {
					} # End case 'gt' {
				
				
				case 'le' {
					# Testing to see if the thresholds are LESS than or equal to the value
					# Determine if user supplied a warning threshold
					if (looks_like_number($threshold_warning)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning looks like a number');
						# Determine if user supplied a critcial threshold
						if (looks_like_number($threshold_critical)) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
							# First check to make sure that $threshold_critical is less than $threshold_warning
							if ($threshold_critical < $threshold_warning) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical < $threshold_warning');
								# Check to see see if $threshold_value is less than $threshold_critical
								if ($threshold_value <= $threshold_critical) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value <= $threshold_critical');
									$message_string = ' (CRITICAL <= ' . Format_Number_With_Commas($threshold_critical) . ')';
									$exit_state_to_return = 'CRITICAL';
									last;
									} # End if ($threshold_value <= $threshold_critical) {
								# Check to see see if $threshold_value is less than $threshold_warning
								elsif ($threshold_value <= $threshold_warning) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value <= $threshold_warning');
									$message_string = ' (WARNING <= ' . Format_Number_With_Commas($threshold_warning) . ')';
									$exit_state_to_return = 'WARNING';
									last;
									} # End elsif ($threshold_value <= $threshold_warning) {
								else {
									$message_string = '';
									$exit_state_to_return = 'OK';
									last;
									} # End else {
								} # End if ($threshold_warning < $threshold_critical) {
							else {
								# The user has provided incorrectly oriented warning and critical values
								Debug_Process('append', 'Line ' . __LINE__ . " The critical value '$threshold_critical' MUST be LESS than the warning value '$threshold_warning' for '$threshold_type'!");
								$message_string = " (The critical value ($threshold_critical) MUST be LESS than the warning value ($threshold_warning) for \'$threshold_type\'!)";
								$exit_state_to_return = 'UNKNOWN';
								last;
								} # End else {
							} # End if (looks_like_number($threshold_critical)) {
						# Check to see see if $threshold_value is less than $threshold_warning
						if ($threshold_value <= $threshold_warning) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value <= $threshold_warning');
							$message_string = ' (WARNING <= ' . Format_Number_With_Commas($threshold_warning) . ')';
							$exit_state_to_return = 'WARNING';
							last;
							} # End if ($threshold_value <= $threshold_warning) {
						} # End if (looks_like_number($threshold_warning)) {
					elsif (looks_like_number($threshold_critical)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
						# Check to see see if $threshold_value is less than $threshold_critical
						if ($threshold_value <= $threshold_critical) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value <= $threshold_critical');
							$message_string = ' (CRITICAL <= ' . Format_Number_With_Commas($threshold_critical) . ')';
							$exit_state_to_return = 'CRITICAL';
							} # End if ($threshold_value <= $threshold_critical) {
						} # End elsif (looks_like_number($threshold_critical)) {
					else {
						$message_string = '';
						$exit_state_to_return = 'OK';
						} # End else {
					} # End case 'le' {
				
				
				case 'lt' {
					# Testing to see if the thresholds are LESS than the value
					# Determine if user supplied a warning threshold
					if (looks_like_number($threshold_warning)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_warning looks like a number');
						# Determine if user supplied a critcial threshold
						if (looks_like_number($threshold_critical)) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
							# First check to make sure that $threshold_critical is less than $threshold_warning
							if ($threshold_critical < $threshold_warning) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical < $threshold_warning');
								# Check to see see if $threshold_value is less than $threshold_critical
								if ($threshold_value < $threshold_critical) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value < $threshold_critical');
									$message_string = ' (CRITICAL < ' . Format_Number_With_Commas($threshold_critical) . ')';
									$exit_state_to_return = 'CRITICAL';
									last;
									} # End if ($threshold_value < $threshold_critical) {
								# Check to see see if $threshold_value is less than $threshold_warning
								elsif ($threshold_value < $threshold_warning) {
									Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value < $threshold_warning');
									$message_string = ' (WARNING < ' . Format_Number_With_Commas($threshold_warning) . ')';
									$exit_state_to_return = 'WARNING';
									last;
									} # End elsif ($threshold_value < $threshold_warning) {
								else {
									$message_string = '';
									$exit_state_to_return = 'OK';
									last;
									} # End else {
								} # End if ($threshold_warning < $threshold_critical) {
							else {
								# The user has provided incorrectly oriented warning and critical values
								Debug_Process('append', 'Line ' . __LINE__ . " The critical value '$threshold_critical' MUST be LESS than the warning value '$threshold_warning' for '$threshold_type'!");
								$message_string = " (The critical value ($threshold_critical) MUST be LESS than the warning value ($threshold_warning) for \'$threshold_type\'!)";
								$exit_state_to_return = 'UNKNOWN';
								last;
								} # End else {
							} # End if (looks_like_number($threshold_critical)) {
						# Check to see see if $threshold_value is less than $threshold_warning
						if ($threshold_value < $threshold_warning) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value < $threshold_warning');
							$message_string = ' (WARNING < ' . Format_Number_With_Commas($threshold_warning) . ')';
							$exit_state_to_return = 'WARNING';
							last;
							} # End if ($threshold_value < $threshold_warning) {
						} # End if (looks_like_number($threshold_warning)) {
					elsif (looks_like_number($threshold_critical)) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_critical looks like a number');
						# Check to see see if $threshold_value is less than $threshold_critical
						if ($threshold_value < $threshold_critical) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $threshold_value < $threshold_critical');
							$message_string = ' (CRITICAL < ' . Format_Number_With_Commas($threshold_critical) . ')';
							$exit_state_to_return = 'CRITICAL';
							} # End if ($threshold_value < $threshold_critical) {
						} # End elsif (looks_like_number($threshold_critical)) {
					else {
						$message_string = '';
						$exit_state_to_return = 'OK';
						} # End else {
					} # End case 'lt' {
				
				
				case 'none' {
					$message_string = '';
					$exit_state_to_return = 'OK';
					} # End case 'none' {
				
				} # End switch ($threshold_check) {
			
			if (!defined($message_string)) {
				$message_string = '';
				} # End if (!defined($message_string)) {
			
			return ($message_string, $exit_state_to_return);
			} # End sub Thresholds_Process {


		sub Thresholds_Test {
			Debug_Process('append', 'Line ' . __LINE__ . ' Thresholds_Test');
			# Determine if user supplied warning thresholds
			if (Opts::option_is_set('warning')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'warning\')');
				my @warnings = split(/,/, Opts::get_option('warning'));
				Debug_Process('append', 'Line ' . __LINE__ . ' @warnings: \'' . @warnings . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @warnings values: \'' . join(", ", @warnings) . '\'');

				foreach my $warning_item (@warnings) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $warning_item: \'' . $warning_item . '\'');
					my @warning_item_split = split(/:/, $warning_item);
					Debug_Process('append', 'Line ' . __LINE__ . ' @warning_item_split: \'' . @warning_item_split . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @warning_item_split values: \'' . join(", ", @warning_item_split) . '\'');
				
					# Check to see if [0] exists
					if (defined($warning_item_split[0])) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($warning_item_split[0])');
						# Check to see if [0] is text
						if (looks_like_number($warning_item_split[0])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' looks_like_number($warning_item_split[0])');
							$exit_message = Build_Message($exit_message, 'Warning threshold option \'' . $warning_item_split[0] . '\' CANNOT be a number!', ', ');
							$exit_state = 'UNKNOWN';
							} # End if (looks_like_number($warning_item_split[0])) {
						# Check to see if [1] exists
						if (defined($warning_item_split[1])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($warning_item_split[1])');
							# Check to see if [1] is a number
							if (!looks_like_number($warning_item_split[1])) {
								Debug_Process('append', 'Line ' . __LINE__ . ' !looks_like_number($warning_item_split[1])');
								$exit_message = Build_Message($exit_message, 'Warning threshold option \'' . $warning_item_split[0] . '\' value \'' . $warning_item_split[1] . '\' MUST be a number!', ', ');
								$exit_state = 'UNKNOWN';
								} # End if (!looks_like_number($warning_item_split[1])) {
							} # End if (defined($warning_item_split[1])) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' Warning threshold option \'' . $warning_item_split[0] . '\' REQUIRES a numeric value!');
							$exit_message = Build_Message($exit_message, 'Warning threshold option \'' . $warning_item_split[0] . '\' REQUIRES a numeric value!', ', ');
							$exit_state = 'UNKNOWN';
							} # End else {
						} #End if (defined($warning_item_split[0])) {
					} # End foreach my $warning_item (@warnings) {	
				} # End if (Opts::option_is_set('warning')) {
			
			# Determine if user supplied critical thresholds
			if (Opts::option_is_set('critical')) {
				Debug_Process('append', 'Line ' . __LINE__ . ' Opts::option_is_set(\'critical\')');
				my @criticals = split(/,/, Opts::get_option('critical'));
				Debug_Process('append', 'Line ' . __LINE__ . ' @criticals: \'' . @criticals . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' @criticals values: \'' . join(", ", @criticals) . '\'');
				
				foreach my $critical_item (@criticals) {
					Debug_Process('append', 'Line ' . __LINE__ . ' $critical_item: \'' . $critical_item . '\'');
					my @critical_item_split = split(/:/, $critical_item);
					Debug_Process('append', 'Line ' . __LINE__ . ' @critical_item_split: \'' . @critical_item_split . '\'');
					Debug_Process('append', 'Line ' . __LINE__ . ' @critical_item_split values: \'' . join(", ", @critical_item_split) . '\'');
					
					# Check to see if [0] exists
					if (defined($critical_item_split[0])) {
						Debug_Process('append', 'Line ' . __LINE__ . ' defined($critical_item_split[0])');
						# Check to see if [0] is text
						if (looks_like_number($critical_item_split[0])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' looks_like_number($critical_item_split[0])');
							$exit_message = Build_Message($exit_message, 'Critical threshold option \'' . $critical_item_split[0] . '\' CANNOT be a number!', ', ');
							$exit_state = 'UNKNOWN';
							} # End if (looks_like_number($critical_item_split[0])) {
						# Check to see if [1] exists
						if (defined($critical_item_split[1])) {
							Debug_Process('append', 'Line ' . __LINE__ . ' defined($critical_item_split[1])');
							# Check to see if [1] is a number
							if (!looks_like_number($critical_item_split[1])) {
								Debug_Process('append', 'Line ' . __LINE__ . ' !looks_like_number($critical_item_split[1])');
								$exit_message = Build_Message($exit_message, 'Critical threshold option \'' . $critical_item_split[0] . '\' value \'' . $critical_item_split[1] . '\' MUST be a number!', ', ');
								$exit_state = 'UNKNOWN';
								} # End if (!looks_like_number($critical_item_split[1])) {
							} # End if (defined($critical_item_split[1])) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' Critical threshold option \'' . $critical_item_split[0] . '\' REQUIRES a numeric value!');
							$exit_message = Build_Message($exit_message, 'Critical threshold option \'' . $critical_item_split[0] . '\' REQUIRES a numeric value!', ', ');
							$exit_state = 'UNKNOWN';
							} # End else {
						} #End if (defined($critical_item_split[0])) {
					} # End foreach my $critical_item (@criticals) {	
				} # End if (Opts::option_is_set('critical')) {
			
			return ($exit_message, $exit_state);
			} # End sub Thresholds_Test {


		sub vCenter_License {
			Debug_Process('append', 'Line ' . __LINE__ . ' vCenter_License');
			# Get the $vcenter_service_content
			my $vcenter_service_content = Vim::get_service_content();
			Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_service_content: \'' . $vcenter_service_content . '\'');
			
			# Check if we are connected to a vCenter server
			if ($vcenter_service_content->about->apiType eq 'VirtualCenter') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_service_content->about->apiType eq \'VirtualCenter\'');
				# Get $vcenter_license_manager
				my $vcenter_license_manager = Vim::get_view(
					mo_ref => $vcenter_service_content->licenseManager,
					);
				Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_manager: \'' . $vcenter_license_manager . '\'');
				
				# Get $license_assignment_manager
				my $license_assignment_manager =  Vim::get_view(
					mo_ref => $vcenter_license_manager->licenseAssignmentManager
					);
				Debug_Process('append', 'Line ' . __LINE__ . ' $license_assignment_manager: \'' . $license_assignment_manager . '\'');
				
				# Get $assigned_licenses
				my $assigned_licenses = $license_assignment_manager->QueryAssignedLicenses(
					entityId => $vcenter_service_content->about->instanceUuid,
					);
				Debug_Process('append', 'Line ' . __LINE__ . ' $assigned_licenses: \'' . $assigned_licenses . '\'');
				
				# Get $assigned_license
				my $assigned_license = @{$assigned_licenses}[0]->assignedLicense;
				Debug_Process('append', 'Line ' . __LINE__ . ' $assigned_license: \'' . $assigned_license . '\'');
				
				# Check to see if we are in evaluation mode
				if ($assigned_license->name eq 'Evaluation Mode') {
					Debug_Process('append', 'Line ' . __LINE__ . ' $assigned_license->name eq \'Evaluation Mode\'');
					$exit_message = 'Evaluation Mode';
					$exit_state = Build_Exit_State($exit_state, 'WARNING');

					Debug_Process('append', 'Line ' . __LINE__ . ' Check to see if the evaluation has expired');
					# Check to see if the evaluation has expired
					my $eval_check = 0;
					Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check: \'' . $eval_check . '\'');
					foreach (@{$vcenter_license_manager->evaluation->properties}) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
						if ($_->value eq 'Evaluation period has expired, please install license.') {
							Debug_Process('append', 'Line ' . __LINE__ . ' $_->value eq \'Evaluation period has expired, please install license.\'');
							$eval_check = 1;
							Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check: \'' . $eval_check . '\'');
							} # End if ($_->value eq 'Evaluation period has expired, please install license.') {
						} # End foreach (@{$vcenter_license_manager->evaluation->properties}) {
					
					if ($eval_check == 1) {
						Debug_Process('append', 'Line ' . __LINE__ . ' $eval_check == 1');
						Debug_Process('append', 'Line ' . __LINE__ . ' Evaluation Period Expired');
						$exit_message = Build_Exit_Message('Exit', $exit_message, 'Evaluation Period Expired');
						$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
						} # End if ($eval_check == 1) {
					else {
						my $vcenter_license_expiration_hours;
						my $vcenter_license_expiration_minutes;
						foreach (@{$vcenter_license_manager->evaluation->properties}) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $_: \'' . $_ . '\'');
							Debug_Process('append', 'Line ' . __LINE__ . ' $_->key: \'' . $_->key . '\'');
							switch ($_->key) {
								case 'expirationHours' {
									$vcenter_license_expiration_hours = $_->value;
									Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_expiration_hours: \'' . $vcenter_license_expiration_hours . '\'');
									} # End case 'expirationHours' {
								
								case 'expirationMinutes' {
									$vcenter_license_expiration_minutes = $_->value;
									Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_expiration_minutes: \'' . $vcenter_license_expiration_minutes . '\'');
									} # End case 'expirationMinutes' {
								} # End switch ($_->key) {
							} # End foreach (@{$vcenter_license_manager->evaluation->properties}) {
						
						$exit_message = Build_Exit_Message('Exit', $exit_message, 'Evaluation Period Remaining:');
						if ($vcenter_license_expiration_hours > 0) {
							Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_expiration_hours > 0');
							if ($vcenter_license_expiration_hours <= 24) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_expiration_hours <= 24');
								if ($vcenter_license_expiration_hours == 1) {
									Debug_Process('append', 'Line ' . __LINE__ . '  ($vcenter_license_expiration_hours == 1');
									$exit_message = Build_Message($exit_message, "$vcenter_license_expiration_hours hour");
									} # End if ($vcenter_license_expiration_hours == 1) {
								else {
									Debug_Process('append', 'Line ' . __LINE__ . '  ($vcenter_license_expiration_hours != 1');
									$exit_message = Build_Message($exit_message, "$vcenter_license_expiration_hours hours");
									} # End else {
								$exit_message = Build_Message($exit_message, "$vcenter_license_expiration_minutes minutes");
								$exit_state = Build_Exit_State($exit_state, 'CRITICAL');
								} # End if ($vcenter_license_expiration_hours <= 24) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_expiration_hours > 24');
								$exit_message = Build_Message($exit_message, " " . floor($vcenter_license_expiration_hours/24) . " days");
								$exit_state = Build_Exit_State($exit_state, 'WARNING');
								} # End else {
							} # End if ($vcenter_license_expiration_hours > 0) {
						else {
							Debug_Process('append', 'Line ' . __LINE__ . ' $vcenter_license_expiration_hours <= 0');
							$exit_message = Build_Message($exit_message, "$vcenter_license_expiration_minutes minutes");
							$exit_state = Build_Exit_State($exit_state, 'WARNING');
							} # End else {
						} # End else {
					} # End if ($assigned_license->name eq 'Evaluation Mode') {
				else {
					Debug_Process('append', 'Line ' . __LINE__ . ' Report the current license version');
					# Report the current license version
					$exit_message = 'Licensed {Version: ' . $assigned_license->name . '}';
					# Only report the license key if the --hide_key argument was not used
					if (!Opts::option_is_set('hide_key')) {
						Debug_Process('append', 'Line ' . __LINE__ . ' !Opts::option_is_set(\'hide_key\')');
						$exit_message = Build_Message($exit_message, " {Key: " . $assigned_license->licenseKey . '}');
						} # End if (!Opts::option_is_set('hide_key')) {
					$exit_state = Build_Exit_State($exit_state, 'OK');
					} # End else {
				} # End if ($vcenter_service_content->about->apiType eq 'VirtualCenter') {
			else {
				Debug_Process('append', 'Line ' . __LINE__ . ' You cannot query a vCenter License via an ESX(i) host!');
				$exit_message = 'You cannot query a vCenter License via an ESX(i) host!';
				$exit_state = 'UNKNOWN';
				} # End else {
			
			return Process_Request_Type($_[0], $exit_message, $exit_state);
			} # End sub vCenter_License {


		sub vCenter_Name_Version {
			Debug_Process('append', 'Line ' . __LINE__ . ' vCenter_Name_Version');
			# Are we connected to a vCenter Server?
			$target_server_type = Server_Type();
			Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type: \'' . $target_server_type . '\'');
			if ($target_server_type ne 'VirtualCenter') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_server_type ne \'VirtualCenter\'');
				# Not connected to a vCenter Server
				$exit_message = "This check only works when connected to a vCenter server, you are connected directly to an ESX(i) host, aborting!";
				$exit_state = 'UNKNOWN';
				} # End if ($target_server_type ne 'VirtualCenter') {
			else {
				my $target_vcenter_view = Vim::get_service_content();	
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_vcenter_view: \'' . $target_vcenter_view . '\'');
				Debug_Process('append', 'Line ' . __LINE__ . ' $target_vcenter_view->about->fullName: \'' . $target_vcenter_view->about->fullName . '\'');
				$exit_message = $target_vcenter_view->about->fullName;
				$exit_state = 'OK';
				} # End else {
			
			return ($exit_message, $exit_state);
			} # End sub vCenter_Name_Version {
		
		
		sub Version {
			print "box293_check_vmware Version: " . $current_version . "\n";	
			} # End sub Version {
		# ------------------------------------------------------------------------------
		#				END Subroutines
		# ------------------------------------------------------------------------------

		# Now for some final checks before executing the check
		my $good_to_go_check = 0;

		Debug_Process('append', 'Line ' . __LINE__ . ' $good_to_go_check: \'' . $good_to_go_check . '\'');
		
		# Test any user supplied thresholds
		(my $exit_message_threshold, my $exit_state_threshold) = Thresholds_Test();
		if (defined($exit_state_threshold)) {
			Debug_Process('append', 'Line ' . __LINE__ . ' defined($exit_state_threshold)');
			if ($exit_state_threshold eq 'UNKNOWN') {
				Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_threshold eq \'UNKNOWN\'');
				# One of the user thresholds was not correct, abort
				$exit_message = $exit_message_threshold;
				$exit_state = $exit_state_threshold;
				$exit_message = "$exit_state: $exit_message";
				$good_to_go_check = 1;
				Debug_Process('append', 'Line ' . __LINE__ . ' $good_to_go_check: \'' . $good_to_go_check . '\'');
				} # End if ($exit_state_threshold eq 'UNKNOWN') {
			} # End if (defined($exit_state_threshold)) {

		# Test any user supplied SI
		($exit_message_abort, $exit_state_abort) = SI_Test();
		if ($exit_state_abort eq 'UNKNOWN') {
			Debug_Process('append', 'Line ' . __LINE__ . ' $exit_state_abort eq \'UNKNOWN\'');
			# Something was not right with the SI_Test, abort
			$exit_message = $exit_message_abort;
			$exit_state = $exit_state_abort;
			$exit_message = "$exit_state: $exit_message";
			$good_to_go_check = 1;
			Debug_Process('append', 'Line ' . __LINE__ . ' $good_to_go_check: \'' . $good_to_go_check . '\'');
			} # End if ($exit_state_abort eq 'UNKNOWN') {
		
		# Are we good to proceed?
		if ($good_to_go_check == 0) {
			# Now for the action to commence
			Debug_Process('append', 'Line ' . __LINE__ . ' $good_to_go_check == 0');
			Debug_Process('append', 'Line ' . __LINE__ . ' About to connect');
			
			# Connect to vCenter or ESX(i) Host
			Util::connect();
			Debug_Process('append', 'Line ' . __LINE__ . ' Connected');
			
			# Get any user supplied perfdata options
			my %Perfdata_Options = Perfdata_Option_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' %Perfdata_Options: \'' . %Perfdata_Options . '\'');

			# Get any user supplied modifiers
			@Modifiers_Supplied_Global = Modifiers_Get();
			Debug_Process('append', 'Line ' . __LINE__ . ' @Modifiers_Supplied_Global: \'' . @Modifiers_Supplied_Global . '\'');

			# Get any user supplied exclude_snapshots
			Guest_Snapshot('Exclude Snapshot - Get');
			Debug_Process('append', 'Line ' . __LINE__ . ' @Exclude_Snapshot_Supplied: \'' . @Exclude_Snapshot_Supplied . '\'');

			# Perform the check that was selected
			my $check = Opts::get_option('check');
			Debug_Process('append', 'Line ' . __LINE__ . " Running check: '$check'");
			
			switch ($check) {
				case 'Cluster_CPU_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.numCpuCores', 'summary.effectiveCpu', 'summary.totalCpu', 'host');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_CPU_Usage('Status', $target_cluster_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name'" . $exit_message;
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_CPU_Usage' {
				
				case 'Cluster_DRS_Status' {
					# Define the property filter
					push my @target_properties, ('configurationEx', 'overallStatus', 'configIssue');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_DRS('Status', $target_cluster_view);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name' $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_DRS_Status' {
				
				case 'Cluster_EVC_Status' {
					# Define the property filter
					push my @target_properties, ('summary');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_EVC('Status', $target_cluster_view);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name' $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_EVC_Status' {
				
				case 'Cluster_HA_Status' {
					# Define the property filter
					push my @target_properties, ('configurationEx', 'overallStatus', 'configIssue');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_HA('Status', $target_cluster_view);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name' $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_HA_Status' {
				
				case 'Cluster_Memory_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.effectiveMemory', 'summary.totalMemory', 'host');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_Memory_Usage('Status', $target_cluster_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name'" . $exit_message;
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_Memory_Usage' {
				
				case 'Cluster_Resource_Info' {
					# Define the property filter
					push my @target_properties, ('summary.numHosts', 'summary.numEffectiveHosts', 'summary.numCpuCores', 'summary.effectiveCpu', 'summary.totalCpu', 'host', 'summary.effectiveMemory', 'summary.totalMemory');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_Resource_Info($target_cluster_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_Resource_Info' {
				
				case 'Cluster_Status' {
					# Define the property filter
					push my @target_properties, ('overallStatus', 'configIssue');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_Status($target_cluster_view);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name' $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_Status' {
				
				case 'Cluster_Swapfile_Status' {
					# Define the property filter
					push my @target_properties, ('configurationEx.vmSwapPlacement');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_Swapfile('Status', $target_cluster_view);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name' $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_Swapfile_Status' {
				
				case 'Cluster_vMotion_Info' {
					# Define the property filter
					push my @target_properties, ('summary');
					($target_cluster_view, $exit_message_abort, $exit_state_abort) = Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Cluster_vMotion($target_cluster_view);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						my $cluster_name = Opts::get_option('cluster');
						Debug_Process('append', 'Line ' . __LINE__ . ' $cluster_name: \'' . $cluster_name . '\'');
						$exit_message = "$exit_state: '$cluster_name' $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Cluster_vMotion_Info' {

				case 'Datastore_Cluster_Status' {
					# Define the property filter
					push my @target_properties, ('summary.name', 'configIssue', 'alarmActionsEnabled', 'triggeredAlarmState', 'podStorageDrsEntry', 'overallStatus');
					($target_datastore_cluster_view, $exit_message_abort, $exit_state_abort) = Datastore_Cluster_Select(\@target_properties);
					
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Datastore_Cluster('Status', 'Status', $target_datastore_cluster_view);
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {

					} # End case 'Datastore_Cluster_Status' {

				case 'Datastore_Cluster_Usage' {
					# Define the property filter
					push my @target_properties, ('childEntity', 'summary.name', 'summary.capacity', 'summary.freeSpace');
					($target_datastore_cluster_view, $exit_message_abort, $exit_state_abort) = Datastore_Cluster_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Datastore_Cluster('Status', 'Usage', $target_datastore_cluster_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {

					} # End case 'Datastore_Cluster_Usage' {
					
				case 'Datastore_Performance' {
					# Define the property filter
					push my @target_properties, ('summary.name', 'summary.datastore');
					($target_datastore_view, $exit_message_abort, $exit_state_abort) = Datastore_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Datastore('Status', 'Performance', $target_datastore_view, \%Perfdata_Options);
						if ($exit_message !~ /^Host is in Standby mode/) {
							$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
							} # End if ($exit_message !~ /^Host is in Standby mode/) {
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Datastore_Performance' {

				case 'Datastore_Performance_Overall' {
					# Define the property filter
					push my @target_properties, ('host', 'summary.name', 'summary.datastore');
					($target_datastore_view, $exit_message_abort, $exit_state_abort) = Datastore_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Datastore('Status', 'Performance_Overall', $target_datastore_view, \%Perfdata_Options);
						if ($exit_message !~ /^ALL Hosts connected to this Datastore/) {
							$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
							} # End if ($exit_message !~ /^ALL Hosts connected to this Datastore/) {
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Datastore_Performance_Overall' {
					
				case 'Datastore_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.name', 'summary.capacity', 'summary.freeSpace');
					($target_datastore_view, $exit_message_abort, $exit_state_abort) = Datastore_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Datastore('Status', 'Usage', $target_datastore_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Datastore_Usage' {
				
				case 'Guest_CPU_Info' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.config.numCpu', 'summary.runtime.host', 'summary.config.cpuReservation', 'summary.runtime.maxCpuUsage', 'config.hardware');
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Guest_CPU_Info($target_guest_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state:" . "$exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_CPU_Info' {
				
				case 'Guest_CPU_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.config.numCpu', 'summary.runtime.host');
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Guest_CPU_Usage($target_guest_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state:" . "$exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_CPU_Usage' {
				
				case 'Guest_Disk_Performance' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'config.hardware.device', 'summary.runtime.host');
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Disk('Status', 'Performance', $target_guest_view, \%Perfdata_Options);
						if ($exit_state ne 'UNKNOWN') {
							$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
							} # End if ($exit_state ne 'UNKNOWN') {
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_Disk_Performance' {
				
				case 'Guest_Disk_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'config.hardware.device', 'summary.runtime.host', 'snapshot', 'layoutEx.file', 'summary.runtime.powerState');
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Disk('Status', 'Usage', $target_guest_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_Disk_Usage' {

				case 'Guest_Host' {
					# Check the query parameters
					($exit_state_abort, $exit_message_abort, my $query_url, my $query_username, my $query_password) = Query_Get_Arguments();
					if ($exit_state_abort ne 'UNKNOWN') {
						# Define the property filter
						push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.host');
						($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
						if ($exit_state_abort ne 'UNKNOWN') {
							($exit_message, $exit_state) = Guest_Host($target_guest_view, $query_url, $query_username, $query_password);
							} # End if ($exit_state_abort ne 'UNKNOWN') {
						else {
							$exit_state = $exit_state_abort;
							$exit_message = "$exit_state_abort: $exit_message_abort";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_Host' {
				
				case 'Guest_Memory_Info' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.runtime.host', 'summary.config.memorySizeMB', 'summary.runtime.maxMemoryUsage', 'summary.config.memoryReservation');
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Guest_Memory_Info($target_guest_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state:" . "$exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_Memory_Info' {
				
				case 'Guest_Memory_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.config.memorySizeMB', 'summary.runtime.host');
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Guest_Memory_Usage($target_guest_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_Memory_Usage' {
				
				case 'Guest_NIC_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'config.hardware.device', 'summary.config.numEthernetCards', 'summary.runtime.host');
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Guest_NIC('Status', 'Usage', $target_guest_view, \%Perfdata_Options);
						$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
						$exit_message = "$exit_state:" . "$exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_NIC_Usage' {
				
				case 'Guest_Snapshot' {
					($exit_message, $exit_state) = Guest_Snapshot('Find Snapshot');
					$exit_message = "$exit_state: $exit_message";
					} # End case 'Guest_Snapshot' {
				
				case 'Guest_Status' {
					# Define the property filter
					push my @target_properties, ('summary.runtime', 'summary.quickStats', 'summary.config.name', 'summary.guest', 'summary.guest', 'summary.guest', 'guest.toolsVersion', 'config.version', 'guest.net');
					
					($target_guest_view, $exit_message_abort, $exit_state_abort) = Guest_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Guest_Status($target_guest_view);
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Guest_Status' {
				
				case 'Host_CPU_Info' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.hardware.cpuModel', 'summary.hardware.cpuMhz', 'summary.hardware.numCpuCores', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, CPU Info check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_CPU_Info($target_host_view);
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_CPU_Info' {
				
				case 'Host_CPU_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.hardware.cpuMhz', 'summary.hardware.numCpuCores', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "Host is in Standby mode, CPU Usage check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_CPU_Usage($target_host_view, \%Perfdata_Options);
							$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
							} # End else {
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_CPU_Usage' {
				
				case 'Host_License_Status' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.host', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, License Status check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_License('Status', $target_host_view);
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_License_Status' {
				
				case 'Host_Memory_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.hardware.memorySize', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "Host is in Standby mode, Memory Usage check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_Memory_Usage($target_host_view, \%Perfdata_Options);
							$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
							} # End else {
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_Memory_Usage' {
				
				case 'Host_OS_Name_Version' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.config.product.fullName', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, OS Version check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_OS_Name_Version($target_host_view);
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_OS_Name_Version' {
				
				case 'Host_pNIC_Status' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'configManager.networkSystem', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, pNIC Status check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_NIC_Status('Status', $target_host_view, 'pnic');
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_pNIC_Status' {
				
				case 'Host_pNIC_Usage' {
					# Define the property filter
					push my @target_properties, ('summary.config.product.version', 'summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'configManager.networkSystem', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, pNIC Usage check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_NIC_Usage('Status', $target_host_view, 'pnic', \%Perfdata_Options);
							$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
							$exit_message = "$exit_state:" . "$exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_pNIC_Usage' {
				
				case 'Host_Status' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.runtime.inMaintenanceMode', 'summary.overallStatus', 'configIssue', 'triggeredAlarmState', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, Status check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_Status($target_host_view);
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_Status' {
							
				case 'Host_Storage_Adapter_Info' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'configManager.storageSystem', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, Storage Adapter Info check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_Storage_Adapter('Status', 'Info', $target_host_view);
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_Storage_Adapter_Info' {
				
				case 'Host_Storage_Adapter_Performance' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'configManager.storageSystem', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, Storage Adapter Performance check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							# Determine if the ESX host is version 4.1 or greater as no perfdata stats exist in older versions
							if ($target_host_view->get_property('summary.config.product.version') ge 4.1) {
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->get_property(\'summary.config.product.version\') ge 4.1');
								($exit_message, $exit_state) = Host_Storage_Adapter('Status', 'Performance', $target_host_view, \%Perfdata_Options);
								$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
								} # End if ($target_host_view->summary->config->product->version ge 4.1) {
							else {
								Debug_Process('append', 'Line ' . __LINE__ . ' $target_host_view->get_property(\'summary.config.product.version\') lt 4.1');
								# Performance Data was not added to the vSphere API until version 4.1
								$exit_state = 'UNKNOWN';
								$exit_message = 'The \'Host_Storage_Adapter_Performance\' check does not work with ESX(i) hosts earlier than version 4.1, aborting!';
								} # End else {
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_Storage_Adapter_Performance' {
				
				case 'Host_Switch_Status' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'configManager.networkSystem', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, Switch Status check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_Switch('Status', $target_host_view);
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_Switch_Status' {

				case 'Host_Up_Down_State' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'summary.runtime.inMaintenanceMode', 'summary.config.product.fullName', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						($exit_message, $exit_state) = Host_Up_Down_State($target_host_view);
						if ($exit_state eq 'UP') {
							# Determine if the ESX host is version 4.1 or greater for Perfdata (uptime related)
							if ($target_host_view->get_property('summary.config.product.version') ge 4.1) {
								$exit_message = Perfdata_Option_Process('post_check', \%Perfdata_Options, $exit_message, $check);
								} # End if ($target_host_view->summary->config->product->version ge 4.1) {
							} # End if ($exit_state eq 'UP') {
						$exit_message = "$exit_state: $exit_message";
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_Up_Down_State' {

				case 'Host_vNIC_Status' {
					# Define the property filter
					push my @target_properties, ('summary.runtime.connectionState', 'summary.runtime.powerState', 'summary.quickStats', 'configManager.networkSystem', 'configManager.virtualNicManager', 'summary.config.product.productLineId', 'summary.config.product.version');
					($target_host_view, $exit_message_abort, $exit_state_abort) = Host_Select(\@target_properties);
					if ($exit_state_abort ne 'UNKNOWN') {
						if ($exit_state_abort eq 'STANDBY') {
							$exit_state = 'OK';
							$exit_message = "$exit_state: Host is in Standby mode, vNIC Status check will not be performed!";
							} # End if ($exit_state_abort eq 'STANDBY') {
						else {
							($exit_message, $exit_state) = Host_NIC_Status('Status', $target_host_view, 'vnic');
							$exit_message = "$exit_state: $exit_message";
							} # End else {
						} # End if ($exit_state_abort ne 'UNKNOWN') {
					else {
						$exit_state = $exit_state_abort;
						$exit_message = "$exit_state_abort: $exit_message_abort";
						} # End else {
					} # End case 'Host_vNIC_Status' {
				
				case 'List_Datastore_Clusters' {
					List_Datastore_Clusters();
					exit;
					} # End case 'List_Datastore_Clusters' {

				case 'List_Datastores' {
					List_Datastores();
					exit;
					} # End case 'List_Datastores' {

				case 'List_Guests' {
					List_Guests();
					exit;
					} # End case 'List_Guests' {

				case 'List_Hosts' {
					List_Hosts();
					exit;
					} # End case 'List_Hosts' {

				case 'List_vCenter_Objects' {
					List_vCenter_Objects();
					exit;
					} # End case 'List_vCenter_Objects' {

				case 'vCenter_License_Status' {
					($exit_message, $exit_state) = vCenter_License('Status');
					$exit_message = "$exit_state: $exit_message";
					} # End case 'vCenter_License_Status' {
				
				case 'vCenter_Name_Version' {
					($exit_message, $exit_state) = vCenter_Name_Version();
					$exit_message = "$exit_state: $exit_message";
					} # End case 'vCenter_Name_Version' {
				
				case 'skip' {
					
					$exit_state = "OK";
					$exit_message = "";
					} # End case 'skip' {
				
				else {
					Debug_Process('append', 'Line ' . __LINE__ . "\'$check\' is not a valid --check argument!");
					$exit_message = "\'$check\' is not a valid --check argument!";
					$exit_state = 'UNKNOWN';
					$exit_message = "$exit_state: $exit_message";
					} # End else {
				} # End switch ($check) {

			Debug_Process('append', 'Line ' . __LINE__ . ' About to disconnect');
			
			# Disconnect from the vCenter Server / ESX(i) Host
			Util::disconnect();

			Debug_Process('append', 'Line ' . __LINE__ . ' Disconnected');
			} # End if ($good_to_go_check != 0) {
		
		# Record the time the plugin ended
		my $time_script_ended = time;

		# Determine how long the plugin took to run
		my $time_script_ran = $time_script_ended - $time_script_started;
		Debug_Process('create', 'Line ' . __LINE__ . ' Script ended @ ' . localtime($time_script_ended));
		Debug_Process('create', 'Line ' . __LINE__ . ' Script running time: ' . $time_script_ran . ' seconds');

		# Exit the script outputting the $exit_message and $exit_state.
		Debug_Process('append', 'Line ' . __LINE__ . " Exit Message: '$exit_message'");
		Debug_Process('append', 'Line ' . __LINE__ . " Exit Code: '$States{$exit_state}'");
		Debug_Process('append', 'Line ' . __LINE__ . ' Script ended @ ' . localtime(time));
		print "$exit_message\n";
		exit($States{$exit_state});
		} # End else {
	} # End if ($pre_flight_checks == 0) {

	

# ------------------------------------------------------------------------------
# 				BEGIN Documentation
# ------------------------------------------------------------------------------

=head1 NAME

box293_check_vmware.pl - VMware Plugin for Nagios

=head1 SYNOPSIS

box293_check_vmware.pl --check <check_to_be_performed> --server <vCenter_Server_or_ESX(i)_Host> <Other_arguments_as_required>

=head1 DESCRIPTION

The purpose of this Plugin is to monitor your VMware vCenter / ESX(i) environment using your Nagios monitoring solution.

IMPORTANT: This Plugin is NOT designed to be run on your Nagios host, instead it is offloaded to the VMware vSphere Management Assistant (vMA). This is due to some performance issues that occur with the VMware SDK which can easily overload your Nagios host. How all of this works (and how to set it all up) is explained in the manual. 

If you have not yet read through the manual I strongly urge you to do this now, it will save you time and headaches!

=head1 ARGUMENTS

=head2 REQUIRED

=head3 --check

The type of check you want to perform.

=over

=item Cluster_CPU_Usage

Report the specified Clusters' CPU Usage. Returned as GHz by default.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled, Cores:1, CPU_Free:1, CPU_Effective:1, CPU_Used:1, CPU_Total:1

--reporting_si CPU_Speed:<Hertz>

--warning and --critical cpu_free:<Hertz>, cpu_used:<Hertz>

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_CPU_Usage --server 192.168.1.211 --cluster HA

=back

Output for Example 1:

=over

OK: 'HA' {Cores (Total: 6) (Available: 4)} {CPU (Free: 9.8 GHz) (Used: 0.9 GHz) (Effective: 10.7 GHz) (Total: 22.8 GHz)}|'Cores Total'=6 'Cores Available'=4 'CPU Free'=9.8GHz 'CPU Used'=0.9GHz 'CPU Effective'=10.7GHz 'CPU Total'=22.8GHz [Cluster_CPU_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_CPU_Usage --server 192.168.1.211 --cluster HA --reporting_si CPU_Speed:MHz --warning cpu_used:200

=back

Output for Example 2:

=over

WARNING: 'HA' {Cores (Total: 6) (Available: 4)} {CPU (Free: 10,443 MHz) (Used: 273 MHz (WARNING >= 200)) (Effective: 10,716 MHz) (Total: 22,794 MHz)}|'Cores Total'=6 'Cores Available'=4 'CPU Free'=10443MHz 'CPU Used'=273MHz;200 'CPU Effective'=10716MHz 'CPU Total'=22794MHz [Cluster_CPU_Usage]

=back

=item Cluster_DRS_Status

Check the specified Distributed Resource Scheduler (DRS) Cluster.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--drs_state

--drs_automation_level

--drs_dpm_level

--exclude_issue

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_DRS_Status --server 192.168.1.211 --cluster "Empty Cluster"

=back

Output for Example 1:

=over

OK: 'Empty Cluster' DRS: {Enabled} {Automation Level: Fully Automated} {Migration Threshold: 1} {DPM: Off}

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_DRS_Status --server 192.168.1.211 --cluster "Empty Cluster" --drs_automation_level manual --drs_dpm_level on

=back

Output for Example 2:

=over

CRITICAL: 'Empty Cluster' DRS: {Enabled} {Automation Level is fullyAutomated but should be manual} {Migration Threshold: 1} {DPM is off but should be on}

=back

=item Cluster_EVC_Status

Check the specified Clusters' Enhanced vMotion Compatibility (EVC) Mode.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--evc_mode

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_EVC_Status --server 192.168.1.211 --cluster "Empty Cluster"

=back

Output for Example 1:

=over

OK: 'Empty Cluster' EVC: intel-westmere

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_EVC_Status --server 192.168.1.211 --cluster HA --evc_mode enabled

=back

Output for Example 2:

=over

CRITICAL: 'HA' EVC is disabled but should be enabled

=back

=item Cluster_HA_Status

Check the specified High Availability (HA) Cluster.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--ha_state

--ha_host_monitoring

--ha_admission_control

--exclude_issue

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_HA_Status --server 192.168.1.211 --cluster HA

=back

Output for Example 1:

=over

OK: 'HA' HA: {Enabled} {Host Monitoring: Enabled} {Admission Control: Enabled, Policy: Tolerates 1 Host Failure} {VM Options: Restart Priority: Medium, Isolation Response: Leave Powered On} {VM Monitoring: Disabled}

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_HA_Status --server 192.168.1.211 --cluster "Empty Cluster" --ha_admission_control disabled

=back

Output for Example 2:

=over

OK: 'Empty Cluster' HA: {Enabled} {Host Monitoring: Enabled} {Admission Control: Disabled} {VM Options: Restart Priority: Low, Isolation Response: Shutdown} {VM Monitoring: VM Only}

=back

=item Cluster_Memory_Usage

Report the specified Clusters' Memory Usage. Returned as GB by default.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled, Memory_Effective:1, Memory_Free:1, Memory_Total:1, Memory_Used:1

--reporting_si Memory_Size:<Bytes>

--warning and --critical memory_free:<Bytes>, memory_used:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_Memory_Usage --server 192.168.1.211 --cluster HA

=back

Output for Example 1:

=over

OK: 'HA' Memory {Free: 2.4 GB} {Used: 2 GB} {Effective: 4.4 GB} {Total: 12 GB}|'Memory Free'=2.4GB 'Memory Used'=2GB 'Memory Effective'=4.4GB 'Memory Total'=12GB [Cluster_Memory_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_Memory_Usage --server 192.168.1.211 --cluster HA --reporting_si Memory_Size:MB --warning memory_free:3000 --critical memory_free:2000

=back

Output for Example 2:

=over

WARNING: 'HA' Memory {Free: 2,492 MB (WARNING <= 3,000)} {Used: 1,983 MB} {Effective: 4,475 MB} {Total: 12,286.5 MB}|'Memory Free'=2492MB;3000;2000 'Memory Used'=1983MB 'Memory Effective'=4475MB 'Memory Total'=12286.5MB [Cluster_Memory_Usage]

=back

=item Cluster_Resource_Info

Reports the resources in a cluster such as Hosts, CPU and Memory. Always returns an OK state. Returned as GHz and GB by default.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled, Cores:1, CPU_Free:1, CPU_Effective:1, CPU_Used:1, CPU_Total:1, Hosts_Available:1, Hosts_Total:1, Memory_Effective:1, Memory_Free:1, Memory_Total:1, Memory_Used:1

--reporting_si CPU_Speed:<Hertz>, Memory_Size:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_Resource_Info --server 192.168.1.211 --cluster HA

=back

Output for Example 1:

=over

OK: 'HA' [Hosts {Total: 3} {Available: 2}] [{Cores (Total: 6) (Available: 4)} {CPU (Free: 10.4 GHz) (Used: 0.3 GHz) (Effective: 10.7 GHz) (Total: 22.8 GHz)}] [Memory {Free: 2.4 GB} {Used: 2 GB} {Effective: 4.4 GB} {Total: 12 GB}]|'Hosts Total'=3 'Hosts Available'=2 'Cores Total'=6 'Cores Available'=4 'CPU Free'=10.4GHz 'CPU Used'=0.3GHz 'CPU Effective'=10.7GHz 'CPU Total'=22.8GHz 'Memory Free'=2.4GB 'Memory Used'=2GB 'Memory Effective'=4.4GB 'Memory Total'=12GB [Cluster_Resource_Info]

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_Resource_Info --server 192.168.1.211 --cluster HA --reporting_si CPU_Speed:MHz,Memory_Size:MB

=back

Output for Example 2:

=over

OK: 'HA' [Hosts {Total: 3} {Available: 2}] [{Cores (Total: 6) (Available: 4)} {CPU (Free: 10,541 MHz) (Used: 175 MHz) (Effective: 10,716 MHz) (Total: 22,794 MHz)}] [Memory {Free: 2,492 MB} {Used: 1,983 MB} {Effective: 4,475 MB} {Total: 12,286.5 MB}]|'Hosts Total'=3 'Hosts Available'=2 'Cores Total'=6 'Cores Available'=4 'CPU Free'=10541MHz 'CPU Used'=175MHz 'CPU Effective'=10716MHz 'CPU Total'=22794MHz 'Memory Free'=2492MB 'Memory Used'=1983MB 'Memory Effective'=4475MB 'Memory Total'=12286.5MB [Cluster_Resource_Info]

=back

=item Cluster_Swapfile_Status

Checks the the Clusters' Swapfile Policy.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--swapfile_policy

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_Swapfile_Status --server 192.168.1.211 --cluster HA

=back

Output for Example 1:

=over

OK: 'HA' Swapfile Policy: Store In VM Directory

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_Swapfile_Status --server 192.168.1.211 --cluster HA --swapfile_policy hostLocal

=back

Output for Example 2:

=over

CRITICAL: 'HA' Swapfile Policy is vmDirectory but should be hostLocal

=back

=item Cluster_vMotion_Info

Reports the number of vMotions performed in the Cluster. Always returns an OK state. Useful for gathering performance data to observe trends over time.

Required Arguments:

=over

--cluster

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled

=back

Example 1:

=over

box293_check_vmware.pl --check Cluster_vMotion_Info --server 192.168.1.211 --cluster HA

=back

Output for Example 1:

=over

OK: 'HA' vMotions: 283|'Number of vMotions'=283 [Cluster_vMotion_Info]

=back

Example 2:

=over

box293_check_vmware.pl --check Cluster_vMotion_Info --server 192.168.1.211 --cluster HA --perfdata_option post_check:disabled

=back

Output for Example 2:

=over

OK: 'HA' vMotions: 283|'Number of vMotions'=283

=back

=item Datastore_Cluster_Status

Check the status of a Datastore Cluster and also reports it's configuration. Only valid in vSphere 5.0 onwards.

Required Arguments:

=over

--name

=back

Example 1:

=over

box293_check_vmware.pl --check Datastore_Cluster_Status --server 192.168.1.211 --name "15K Datastores"

=back

Output for Example 1:

=over

WARNING: Datastore Cluster '15K Datastores' {Overall Status is yellow=WARNING} {Alarms Total: 2 (#1: NOT Acknowledged, yellow=WARNING, Age: 263 Days) (#2: NOT Acknowledged, yellow=WARNING, Age: 277 Days)} {Storage DRS is Enabled (Guest Disks: Keep Together) (I/O Load Balancing: Enabled, I/O Imbalance Threshold: 5, I/O Latency Threshold: 15 ms) (Automation Level: Manual) (Space Load Balancing Threshold: 80% Used) (Load Balancing Runs Every: 8 Hours) (Affinity Rule Behaviour During Maintenance: Ignored)}

=back

=item Datastore_Cluster_Usage

Check the Usage of a Datastore Cluster. Returned as TB by default.  Only valid in vSphere 5.0 onwards

Required Arguments:

=over

--name

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled, Capacity:1, Children:1, Free:1, Used:1

--reporting_si Datastore_Cluster_Size:<Bytes>

--warning and --critical datastore_cluster_free:<Bytes>, datastore_cluster_used:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Datastore_Cluster_Usage --server 192.168.1.211 --name "7.2K Datastores"

=back

Output for Example 1:

=over

OK: Datastore Cluster '7.2K Datastores' {Free Space: 11.2 TB} {Used Space: 18.8 TB} {Capacity: 30 TB} {Child Datastores: 15}|'Free Space'=11.2TB 'Used Space'=18.8TB 'Capacity'=30TB 'Child Datastores'=15 [Datastore_Cluster_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Datastore_Cluster_Usage --server 192.168.1.211 --name "7.2K Datastores" --critical datastore_cluster_free:12288 --reporting_si Datastore_Cluster_Size:GB

=back

Output for Example 2:

=over

CRITICAL: Datastore Cluster '7.2K Datastores' {Free Space: 11,474.5 GB (CRITICAL <= 12,288)} {Used Space: 19,242.5 GB} {Capacity: 30,717 GB} {Child Datastores: 15}|'Free Space'=11474.5GB;;12288 'Used Space'=19242.5GB 'Capacity'=30717GB 'Child Datastores'=15 [Datastore_Cluster_Usage]

=back

=item Datastore_Performance

Check the performance of a specific Datastore connected to a specific host. Metrics returned are [Datastore Rate (Read and Write) as kBps], [Number of (Reads and Writes) (no thresholds checked)] and [Device Latency (Read and Write) as ms]. 

Required Arguments:

=over

--name

--host (the host that the datastore is connected to)

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Datastore_Rate:1, Latency:1, Number_Of:1

--reporting_si Datastore_Rate:<Bytes Per Second>, Latency:<Time>

--warning and --critical datastore_rate:<Bytes Per Second>, datastore_latency:<Time>

=back

Example 1:

=over

box293_check_vmware.pl --check Datastore_Performance --server 192.168.1.211 --host 192.168.1.210 --name "ESXi 5.1"

=back

Output for Example 1:

=over

OK: Datastore 'ESXi 5.1' {Rate (Read:32 kBps / 21%)(Write:122 kBps / 79%)} {Number of (Reads:20) (Writes:109)} {Latency (Read:0 ms)(Write:1 ms)}|'Read Rate'=32kBps 'Write Rate'=122kBps 'Number of Reads'=20 'Number of Writes'=109 'Read Latency'=0ms 'Write Latency'=1ms [Datastore_Performance]

=back

Example 2:

=over

box293_check_vmware.pl --check Datastore_Performance --server 192.168.1.211 --host 192.168.1.210 --name "ESXi 5.1" --reporting_si Datastore_Rate:Bps --warning datastore_rate:5000,datastore_latency:2 --critical datastore_rate:10000,datastore_latency:50

=back

Output for Example 2:

=over

CRITICAL: Datastore 'ESXi 5.1' {Rate (Read:6,144 Bps / 7% (WARNING >= 5,000))(Write:95,232 Bps / 93% (CRITICAL >= 10,000))} {Number of (Reads:4) (Writes:175)} {Latency (Read:4 ms (WARNING >= 2))(Write:1 ms)}|'Read Rate'=6144Bps;5000;10000 'Write Rate'=95232Bps;5000;10000 'Number of Reads'=4 'Number of Writes'=175 'Read Latency'=4ms;2;50 'Write Latency'=1ms;2;50 [Datastore_Performance]

=back

=item Datastore_Performance_Overall

Check the OVERALL performance of a specific Datastore (for ALL connected hosts). Metrics returned are [Total Connected Hosts], [Datastore Rate (Read and Write) as MBps], [Number of (Reads and Writes) (no thresholds checked)] and [Device Latency (Read and Write) as ms]. 

Required Arguments:

=over

--name

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled, Datastore_Rate:1, Hosts:1, Latency:1, Number_Of:1

--reporting_si Datastore_Rate:<Bytes Per Second>, Latency:<Time>

--warning and --critical datastore_rate:<Bytes Per Second>, datastore_latency:<Time>

=back

Example 1:

=over

box293_check_vmware.pl --check Datastore_Performance_Overall --server 192.168.1.211 --name "ESXi 5.1"

=back

Output for Example 1:

=over

OK: Datastore 'ESXi 5.1' {Total Connected Hosts: 1} {Rate (Read:38 MBps / 49%)(Write:40 MBps / 51%)} {Number of (Reads:24) (Writes:18)} {Latency (Read:0 ms)(Write:0 ms)}|'Total Connected Hosts'=1 'Read Rate'=38MBps 'Write Rate'=40MBps 'Number of Reads'=24 'Number of Writes'=18 'Read Latency'=0ms 'Write Latency'=0ms [Datastore_Performance_Overall]

=back

Example 2:

=over

box293_check_vmware.pl --check Datastore_Performance_Overall --server 192.168.1.211 --name "ESXi 5.1" --reporting_si Datastore_Rate:Bps --warning datastore_rate:5000,datastore_latency:2 --critical datastore_rate:10000,datastore_latency:50

=back

Output for Example 2:

=over

CRITICAL: Datastore 'ESXi 5.1' {Total Connected Hosts: 1} {Rate (Read:19,456 Bps / 49% (CRITICAL >= 10,000))(Write:20,480 Bps / 51% (CRITICAL >= 10,000))} {Number of (Reads:12) (Writes:9)} {Latency (Read:0 ms)(Write:0 ms)}|'Total Connected Hosts'=1 'Read Rate'=19456Bps;5000;10000 'Write Rate'=20480Bps;5000;10000 'Number of Reads'=12 'Number of Writes'=9 'Read Latency'=0ms;2;50 'Write Latency'=0ms;2;50 [Datastore_Performance_Overall]

=back

=item Datastore_Usage

Check the Usage of a specific Datastore. Returned as GB by default. 

Required Arguments:

=over

--name

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled, Datastore_Capacity:1, Datastore_Free:1, Datastore_Used:1

--reporting_si Datastore_Size:<Bytes>

--warning and --critical datastore_free:<Bytes>, datastore_used:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Datastore_Usage --server 192.168.1.211 --name "ESXi 5.1"

=back

Output for Example 1:

=over

OK: Datastore 'ESXi 5.1' {Free Space: 67.3 GB} {Used Space: 67.7 GB} {Capacity: 135 GB}|'Free Space'=67.3GB 'Used Space'=67.7GB 'Capacity'=135GB [Datastore_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Datastore_Usage --server 192.168.1.211 --name "ESXi 5.1" --critical datastore_free:70

=back

Output for Example 2:

=over

CRITICAL: Datastore 'ESXi 5.1' {Free Space: 67.3 GB (CRITICAL <= 70)} {Used Space: 67.7 GB} {Capacity: 135 GB}|'Free Space'=67.3GB;;70 'Used Space'=67.7GB 'Capacity'=135GB [Datastore_Usage]

=back

=item Guest_CPU_Info

Report Information about the Guests' CPU such as Cores, Total CPU, Reservation and Limit. Returned as MHz by default. Performance data can be useful for identifying when changes occurred, like adding CPU's or when a reservation or limit was defined. NOTE: cpu_reservation and cpu_limit thresholds are either --warning OR --critical, NOT both. Number of cores only reported in vSphere 5.0 onwards, CPU Reservation only reported on directly connected ESXi hosts v 5.0 onwards ... via vCenter works for 4.0 onwards.

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Cores:1 ,CPU_Limit:1, CPU_Reservation:1, CPU_Total:1

--reporting_si CPU_Speed:<Hertz>

--warning and --critical cpu_reservation:<Hertz>, cpu_limit:<Hertz>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_CPU_Info --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)"

=back

Output for Example 1:

=over

OK: {CPU (Cores Total: 4) (Cores Per Socket: 2) (Sockets: 2)} {Total MHz: 15,196 MHz} {Reservation MHz: 0 MHz} {Limit MHz: 12,236 MHz}|'Cores Total'=4 'Cores Per Socket'=2 'Sockets'=2 'CPU Total'=15196MHz 'CPU Reservation'=0MHz 'CPU Limit'=12236MHz [Guest_CPU_Info]

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_CPU_Info --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)" --warning cpu_reservation:512 --critical cpu_limit:10240

=back

Output for Example 2:

=over

CRITICAL: {CPU (Cores Total: 4) (Cores Per Socket: 2) (Sockets: 2)} {Total MHz: 15,196 MHz} {Reservation MHz: 0 MHz (WARNING != 512)} {Limit MHz: 12,236 MHz (CRITICAL != 10,240)}|'Cores Total'=4 'Cores Per Socket'=2 'Sockets'=2 'CPU Total'=15196MHz 'CPU Reservation'=0MHz;512 'CPU Limit'=12236MHz;;10240 [Guest_CPU_Info]

=back

=item Guest_CPU_Usage

Report the specified Guests' CPU Usage. Returned as MHz and ms by default. If the guest only has more than one core, performance data for each core is also gathered HOWEVER --warning and --critical thresholds will ONLY trigger on the total values (cpu_free, cpu_used, cpu_ready_time). 

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, CPU_Free:1, CPU_Used:1, CPU_Available:1, CPU_Ready_Time:1

--reporting_si CPU_Speed:<Hertz> Time:<Time>

--warning and --critical cpu_free:<Hertz>, cpu_used:<Hertz>, cpu_ready_time:<Time>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_CPU_Usage --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)"

=back

Output for Example 1:

=over

OK: {Free: 15,157 MHz} {Usage: (Total: 39 MHz) (CPU 0: 10 MHz) (CPU 1: 3 MHz) (CPU 2: 9 MHz) (CPU 3: 1 MHz)} {Total Available: 15,196 MHz} {Ready Time: (Total: 48 ms) (CPU 0: 14 ms) (CPU 1: 10 ms) (CPU 2: 15 ms) (CPU 3: 10 ms)}|'Total CPU Free'=15157MHz 'Total CPU Usage'=39MHz 'CPU 0: Usage'=10MHz 'CPU 1: Usage'=3MHz 'CPU 2: Usage'=9MHz 'CPU 3: Usage'=1MHz 'Total Available'=15196MHz 'Total Ready Time'=48ms 'CPU 0 Ready Time'=14ms 'CPU 1 Ready Time'=10ms 'CPU 2 Ready Time'=15ms 'CPU 3 Ready Time'=10ms [Guest_CPU_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_CPU_Usage --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)" --warning cpu_ready_time:10 --critical cpu_ready_time:20

=back

Output for Example 2:

=over

CRITICAL: {Free: 15,061 MHz} {Usage: (Total: 135 MHz) (CPU 0: 16 MHz) (CPU 1: 4 MHz) (CPU 2: 97 MHz) (CPU 3: 2 MHz)} {Total Available: 15,196 MHz} {Ready Time: (Total: 54 ms (CRITICAL >= 20)) (CPU 0: 18 ms) (CPU 1: 10 ms) (CPU 2: 16 ms) (CPU 3: 10 ms)}|'Total CPU Free'=15061MHz 'Total CPU Usage'=135MHz 'CPU 0: Usage'=16MHz 'CPU 1: Usage'=4MHz 'CPU 2: Usage'=97MHz 'CPU 3: Usage'=2MHz 'Total Available'=15196MHz 'Total Ready Time'=54ms;10;20 'CPU 0 Ready Time'=18ms 'CPU 1 Ready Time'=10ms 'CPU 2 Ready Time'=16ms 'CPU 3 Ready Time'=10ms [Guest_CPU_Usage]

=back

=item Guest_Disk_Performance

Check the Disk Performance of a Guests' virtual disk(s). NOTE: This check only works for guests running on ESX(i) hosts 4.1.0 onwards! Metrics returned are [Disk Rate (Read and Write) as kBps], [Averaged Number of (Reads and Writes) (no thresholds checked)] and Latency depending on ESX(i) host version = version 5.1.0 and later [Disk Latency (Read and Write) as us] OR version less than 5.1.0 [Total Latency (Read and Write) as ms].

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Latency:1, Disk_Rate:1, Averaged:1

--reporting_si Disk_Rate:<Bytes Per Second>, Latency:<Time>

--warning and --critical disk_rate:<Bytes Per Second>, disk_latency:<Time>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_Disk_Performance --server 192.168.1.211 --guest "VMware vCenter Server Appliance"

=back

Output for Example 1:

=over

OK: [Hard disk 1 (scsi0:0) on 'ESXi 5.1' {Rate (Read:0 kBps / 0%)(Write:36 kBps / 100%)} {Averaged Number of (Reads:0) (Writes:2)} {Latency (Read:0 us)(Write:3,364 us)}], [Hard disk 2 (scsi0:1) on 'ESXi 5.1' {Rate (Read:0 kBps / 0%)(Write:9 kBps / 100%)} {Averaged Number of (Reads:0) (Writes:1)} {Latency (Read:0 us)(Write:407 us)}]|'Hard disk 1 (scsi0:0) Read Rate'=0kBps 'Hard disk 1 (scsi0:0) Write Rate'=36kBps 'Hard disk 1 (scsi0:0) Averaged Number of Reads'=0 'Hard disk 1 (scsi0:0) Averaged Number of Writes'=2 'Hard disk 1 (scsi0:0) Read Latency'=0us 'Hard disk 1 (scsi0:0) Write Latency'=3364us 'Hard disk 2 (scsi0:1) Read Rate'=0kBps 'Hard disk 2 (scsi0:1) Write Rate'=9kBps 'Hard disk 2 (scsi0:1) Averaged Number of Reads'=0 'Hard disk 2 (scsi0:1) Averaged Number of Writes'=1 'Hard disk 2 (scsi0:1) Read Latency'=0us 'Hard disk 2 (scsi0:1) Write Latency'=407us [Guest_Disk_Performance]

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_Disk_Performance --server 192.168.1.211 --guest "VMware vCenter Server Appliance" --warning disk_rate:2000 --critical disk_latency:3000

=back

Output for Example 2:

=over

CRITICAL: [Hard disk 1 (scsi0:0) on 'ESXi 5.1' {Rate (Read:0 kBps / 0%)(Write:36 kBps / 100%)} {Averaged Number of (Reads:0) (Writes:2)} {Latency (Read:0 us)(Write:3,175 us (CRITICAL >= 3,000))}], [Hard disk 2 (scsi0:1) on 'ESXi 5.1' {Rate (Read:0 kBps / 0%)(Write:25 kBps / 100%)} {Averaged Number of (Reads:0) (Writes:1)} {Latency (Read:12,673 us (CRITICAL >= 3,000))(Write:717 us)}]|'Hard disk 1 (scsi0:0) Read Rate'=0kBps;2000 'Hard disk 1 (scsi0:0) Write Rate'=36kBps;2000 'Hard disk 1 (scsi0:0) Averaged Number of Reads'=0 'Hard disk 1 (scsi0:0) Averaged Number of Writes'=2 'Hard disk 1 (scsi0:0) Read Latency'=0us;;3000 'Hard disk 1 (scsi0:0) Write Latency'=3175us;;3000 'Hard disk 2 (scsi0:1) Read Rate'=0kBps;2000 'Hard disk 2 (scsi0:1) Write Rate'=25kBps;2000 'Hard disk 2 (scsi0:1) Averaged Number of Reads'=0 'Hard disk 2 (scsi0:1) Averaged Number of Writes'=1 'Hard disk 2 (scsi0:1) Read Latency'=12673us;;3000 'Hard disk 2 (scsi0:1) Write Latency'=717us;;3000 [Guest_Disk_Performance]

=back

=item Guest_Disk_Usage

Check the Disk Usage of a Guests' virtual disk(s). Returned as GB by default. Returns overall usage of all virtual disks and well as individual virtual disk usage. Includes provisioning type (Thin, Thick Eager, Thick Lazy), swap files, suspend files and snapshot files. For Thin provisioned disks, you can trigger thresholds on how much free disk space there is remaining (<total virtual disk size> - <current size on datastore>). Disk Total threshold is triggered on the overall total, not each individual disk.

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Disk_Capacity:1, Disk_Free:1, Disk_Size_On_Datastore:1, Disk_Snapshot_Space:1, Disk_Suspend_File:1, Disk_Swap_File:1, Disk_Swap_Userworld:1, Disk_Usage:1

--reporting_si Disk_Size:<Bytes>

--warning and --critical disk_free:<Bytes>, disk_total:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_Disk_Usage --server 192.168.1.211 --guest "VMware vCenter Server Appliance"

=back

Output for Example 1:

=over

OK: [Totals: {Disk Usage: 21.6 GB} {Swap File: 8 GB} {Userworld Swap File: 0.1 GB}], [Hard disk 1 (scsi0:0) on 'ESXi 5.1' {Provisioning: Thin} {Disk Capacity: 25 GB} {Size On Datastore: 8.6 GB} {Free Space: 16.4 GB / 66%}], [Hard disk 2 (scsi0:1) on 'ESXi 5.1' {Provisioning: Thin} {Disk Capacity: 60 GB} {Size On Datastore: 4.9 GB} {Free Space: 55.1 GB / 92%}]|'Total Disk Usage'=21.6GB 'Swap File'=8GB 'Userworld Swap File'=0.1GB 'Hard disk 1 (scsi0:0) Capacity'=25GB 'Hard disk 1 (scsi0:0) Size On Datastore'=8.6GB 'Hard disk 1 (scsi0:0) Free Space'=16.4GB 'Hard disk 2 (scsi0:1) Capacity'=60GB 'Hard disk 2 (scsi0:1) Size On Datastore'=4.9GB 'Hard disk 2 (scsi0:1) Free Space'=55.1GB [Guest_Disk_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_Disk_Usage --server 192.168.1.211 --guest "Windows 8 Development" --critical disk_free:60

=back

Output for Example 2:

=over

CRITICAL: [Totals: {Disk Usage: 35.3 GB} {Suspend File: 4 GB} {All Snapshot Space: 4.1 GB}], [Hard disk 1 (scsi0:0) on 'RAID1 (1)(3)' {Provisioning: Thin} {Disk Capacity: 80.5 GB} {Size On Datastore: 27.2 GB} {Free Space: 53.3 GB / 67% (CRITICAL <= 60)}]|'Total Disk Usage'=35.3GB 'Suspend File'=4GB 'All Snapshot Space'=4.1GB 'Hard disk 1 (scsi0:0) Capacity'=80.5GB 'Hard disk 1 (scsi0:0) Size On Datastore'=27.2GB 'Hard disk 1 (scsi0:0) Free Space'=53.3GB;;60 [Guest_Disk_Usage]

=back

=item Guest_Host

Compare the ESX(i) host the guest is running on against the parents directive defined for this Nagios host object. If ESX(i) and Nagios do not match then a WARNING state is triggered. This uses the Nagios objectjson.cgi to query Nagios directly to determine this. The purpose of this check is return the name of the ESX(i) host the guest is currently running on. IF a WARNING state is triggered then Nagios will execute the box293_event_handler to update the directive parents in this Nagios host object definition. NOTE: The box293_event_handler is currently a work in progress, stay tuned!

Required Arguments:

=over

--guest

--query_url

--query_username

--query_password

--service_status_info

=back

Optional Arguments:

=over

--modifier

=back

Other Requirements:

=over

Nagios Core 4.0.8 is required on your Nagios server for the objectjson.cgi query to work (it may work from 4.0.4 onwards however it has only been tested with 4.0.8).

=back

Example 1:

=over

box293_check_vmware.pl --server vcenter.box293.local --check Guest_Host --guest windows10preview.box293.local --query_url 'http://xitest.box293.local/nagios/cgi-bin/objectjson.cgi' --query_username 'readonly' --query_password 'AV3ryStr0ngP@ssw0rd' --service_status_info 'Current_Parent=esxi001.box293.local'

=back

Output for Example 1:

=over

Current_Parent=esxi001.box293.local

=back

Example 2:

=over

box293_check_vmware.pl --server vcenter.box293.local --check Guest_Host --guest HOST001 --query_url 'http://xitest.box293.local/nagios/cgi-bin/objectjson.cgi' --query_username 'readonly' --query_password 'AV3ryStr0ngP@ssw0rd' --service_status_info ''

=back

Output for Example 2:

=over

No_Parent_Defined_-_Should_Be=esxi001.box293.local

=back

=item Guest_Memory_Info

Report Information about the Guests' Memory such as Total, Reservation and Limit. Returned as MB by default. Performance data can be useful for identifying when changes occurred, like adding Memory or when a reservation or limit was defined. NOTE: memory_reservation and memory_limit thresholds are either --warning OR --critical, NOT both. Memory Reservation only reported on directly connected ESXi hosts v 5.0 onwards ... via vCenter works for 4.0 onwards.

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Memory_Limit:1, Memory_Reservation:1, Memory_Total:1

--reporting_si Memory_Size:<Bytes>

--warning and --critical memory_reservation:<Bytes>, memory_limit:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_Memory_Info --server 192.168.1.211 --guest "Windows 8 Development"

=back

Output for Example 1:

=over

OK: {Total: 4,096 MB} {Reservation MB: 0 MB} {Limit MB: 4,096 MB}|'Memory Total'=4096MB 'Memory Reservation'=0MB 'Memory Limit'=4096MB [Guest_Memory_Info]

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_Memory_Info --server 192.168.1.211 --guest "Windows 8 Development" --warning memory_limit:3096 --critical memory_reservation:1024

=back

Output for Example 2:

=over

CRITICAL: {Total: 4,096 MB} {Reservation MB: 0 MB (CRITICAL != 1,024)} {Limit MB: 4,096 MB (WARNING != 3,096)}|'Memory Total'=4096MB 'Memory Reservation'=0MB;;1024 'Memory Limit'=4096MB;3096 [Guest_Memory_Info]

=back

=item Guest_Memory_Usage

Report the specified Guests' Memory Usage. Returned as MB and kBps by default. Memory Swapping is reported depending on ESX(i) host version = version 4.0.0 and later [Swapping Rate (In and Out) as kBps] OR version less than 4.0.0 [Swapped (In and Out) as MB]. 

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Memory_Active:1, Memory_Ballooned:1, Memory_Consumed:1, Memory_Free:1, Memory_Overhead:1, Memory_Shared:1, Memory_Swap:1, Memory_Total:1

--reporting_si Memory_Size:<Bytes>, Memory_Rate:<Bytes Per Second>

--warning and --critical memory_free:<Bytes>, memory_consumed:<Bytes>, memory_ballooned:<Bytes>, memory_swap_rate:<Bytes Per Second>, memory_swapped:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_Memory_Usage --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)"

=back

Output for Example 1:

=over

OK: Guest Memory {Free: 3,468.0 MB} {Consumed: 628 MB} {Total: 4,096 MB} {Ballooned: 0 MB} {Overhead: 32.7 MB} {Active: 163.8 MB} {Shared: 0 MB} {Swap Rate (In: 0 kBps)(Out: 0 kBps)}|'Memory Free'=3468.0MB 'Memory Consumed'=628MB 'Memory Total'=4096MB 'Memory Ballooned'=0MB 'Memory Overhead'=32.7MB 'Memory Active'=163.8MB 'Memory Shared'=0MB 'Swapping Rate In'=0kBps 'Swapping Rate Out'=0kBps [Guest_Memory_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_Memory_Usage --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)" --warning memory_free:3500 --critical memory_free:2500

=back

Output for Example 2:

=over

WARNING: Guest Memory {Free: 3,468.0 MB (WARNING <= 3,500)} {Consumed: 628 MB} {Total: 4,096 MB} {Ballooned: 0 MB} {Overhead: 32.7 MB} {Active: 81.9 MB} {Shared: 0 MB} {Swap Rate (In: 0 kBps)(Out: 0 kBps)}|'Memory Free'=3468.0MB;3500;2500 'Memory Consumed'=628MB 'Memory Total'=4096MB 'Memory Ballooned'=0MB 'Memory Overhead'=32.7MB 'Memory Active'=81.9MB 'Memory Shared'=0MB 'Swapping Rate In'=0kBps 'Swapping Rate Out'=0kBps [Guest_Memory_Usage]

=back

=item Guest_NIC_Usage

Check the Guests' Network Interface Card(s) (NIC) usage. Returned as kBps by default. If the guest has more than one NIC then each NIC will be reported on individually. Metrics returned are [Rate (Received and Transmitted) as kBps] and [Packets (Received and Transmitted) (no thresholds checked)]. Packets only reported for VMs running on ESXi hosts 5.0 onwards.

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, NIC_Rate:1, NIC_Packets:1

--reporting_si NIC_Rate:<Bytes Per Second>

--warning and --critical nic_rate:<Bytes Per Second>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_NIC_Usage --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)"

=back

Output for Example 1:

=over

OK: {Rate (Rx:236 kBps / 96%)(Tx:11 kBps / 4%)} {Packets (Rx:3,669)(Tx:875)}|'Rate Rx'=236kBps 'Rate Tx'=11kBps 'Packets Rx'=3669 'Packets Tx'=875 [Guest_NIC_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_NIC_Usage --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)" --warning nic_rate:100 --critical nic_rate:200

=back

Output for Example 2:

=over

WARNING: {Rate (Rx:192 kBps / 93% (WARNING >= 100))(Tx:16 kBps / 7%)} {Packets (Rx:3,166)(Tx:1,043)}|'Rate Rx'=192kBps;100;200 'Rate Tx'=16kBps;100;200 'Packets Rx'=3166 'Packets Tx'=1043 [Guest_NIC_Usage]

=back

=item Guest_Snapshot

Check if a guest has snapshots and trigger warning or critical states if snapshot is X days old. If a guest has multiple snapshots, the oldest snapshot is checked. You can target an individual Guest or multiple guests via a Host, Cluster or Datacenter.

Required Arguments:

=over

--guest or --host or --cluster or --datacenter

=back

Optional Arguments:

=over

--exclude_snapshot

--modifier

--warning and --critical snapshot_age:<Day(s)>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_Snapshot --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)"

=back

Output for Example 1:

=over

OK: No snapshots found

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_Snapshot --server 192.168.1.211 --datacenter Box293 --warning snapshot_age:5 --critical snapshot_age:15

=back

Output for Example 2:

=over

CRITICAL: ['nagiosxi' (Notes: Tester) (Age: 2)], ['Windows XP' (Notes: Test) (Age: 15 (CRITICAL >= 15))], ['Windows Server 2003 x86' (Notes: Test) (Age: 20 (CRITICAL >= 15))], ['Debian 7 x86' (Notes: Another Test) (Age: 15 (CRITICAL >= 15))], ['Linux Mint 15' (Notes: asdas) (Age: 13 (WARNING >= 5))], ['vMA' (Notes: before configuring) (Age: 12 (WARNING >= 5))]

=back

=item Guest_Status

Check the status of a guest including Power State, Uptime, VMware Tools Version and Status, IP Address, Hostname, ESX(i) Host Guest Is Running On, Consolidation State and Guest Version.  Warning or critical states can be triggered for Power State, Uptime, Consolidation State and VMware Tools Status.

Required Arguments:

=over

--guest

=back

Optional Arguments:

=over

--modifier

--guest_consolidation_state

--guest_power_state

--guest_tools_version_state

--warning and --critical guest_uptime:<Day(s)>

=back

Example 1:

=over

box293_check_vmware.pl --check Guest_Status --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)"

=back

Output for Example 1:

=over

OK: {State: poweredOn} {Uptime: 13 d} {Tools (Version: 2147483647) (Status: guestToolsUnmanaged)} {IP Address: 10.25.6.22} {Guest Hostname: vmademo} {Host: esxi001.box293.local} {Guest Version: vmx-07}

=back

Example 2:

=over

box293_check_vmware.pl --check Guest_Status --server 192.168.1.211 --guest "vSphere Management Assistant (vMA)" --guest_tools_version_state guestToolsUnmanaged:WARNING --warning guest_uptime:15 --critical guest_uptime:1

=back

Output for Example 2:

=over

WARNING: {State: poweredOn} {Uptime: 13 d (WARNING <= 15)} {Tools (Version: 2147483647) (Status: guestToolsUnmanaged (WARNING))} {IP Address: 10.25.6.22} {Guest Hostname: vmademo} {Host: esxi001.box293.local} {Guest Version: vmx-07}

=back

=item Host_CPU_Info

Report Information about the Hosts' CPU such as Model, Cores and Total CPU. Returned as GHz by default.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled

--reporting_si CPU_Speed:<Hertz>

=back

Example 1:

=over

box293_check_vmware.pl --check Host_CPU_Info --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

OK: AMD A10-5800K APU with Radeon(tm) HD Graphics, 4 cores @ 3.8GHz

=back

Example 2:

=over

box293_check_vmware.pl --check Host_CPU_Info --server 192.168.1.211 --host 192.168.1.210 --reporting_si CPU_Speed:MHz

=back

Output for Example 2:

=over

OK: AMD A10-5800K APU with Radeon(tm) HD Graphics, 4 cores @ 3799MHz

=back

=item Host_CPU_Usage

Report the specified Hosts' CPU Usage. Returned as GHz by default.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, CPU_Free:1, CPU_Total:1, CPU_Used:1

--reporting_si CPU_Speed:<Hertz>

--warning and --critical cpu_free:<Hertz>, cpu_used:<Hertz>

=back

Example 1:

=over

box293_check_vmware.pl --check Host_CPU_Usage --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

OK: Host CPU {Free: 12.9 GHz} {Used: 2.3 GHz} {Total: 15.2 GHz}|'CPU Free'=12.9GHz 'CPU Used'=2.3GHz 'CPU Total'=15.2GHz [Host_CPU_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_CPU_Usage --server 192.168.1.211 --host 192.168.1.210 --warning cpu_used:2 --critical cpu_used:10

=back

Output for Example 2:

=over

WARNING: Host CPU {Free: 12.5 GHz} {Used: 2.7 GHz (WARNING >= 2)} {Total: 15.2 GHz}|'CPU Free'=12.5GHz 'CPU Used'=2.7GHz;2;10 'CPU Total'=15.2GHz [Host_CPU_Usage]

=back

=item Host_License_Status

Reports the specified Hosts license status along with the license key. If the host is in evaluation mode and has less than 24 hours remaining a CRITICAL state is returned otherwise a WARNING state is returned. When host is queried using an account that has read only privileges, only a portion of the key is displayed.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--hide_key

=back

Example 1:

=over

box293_check_vmware.pl --check Host_License_Status --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

OK: Licensed {Version: VMware vSphere 5 Enterprise Plus}{Key: ABCDE-#####-#####-#####-VWXYZ}

=back

Example 2:

=over

box293_check_vmware.pl --check Host_License_Status --server 192.168.1.43

=back

Output for Example 2:

=over

WARNING: Evaluation Mode, Evaluation Period Remaining: 43 days

=back

=item Host_Memory_Usage

Report the specified Hosts' Memory Usage. Returned as GB by default.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Memory_Free:1, Memory_Total:1,  Memory_Used:1

--reporting_si Memory_Size:<Bytes>

--warning and --critical memory_free:<Bytes>, memory_used:<Bytes>

=back

Example 1:

=over

box293_check_vmware.pl --check Host_Memory_Usage --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

OK: Host Memory {Free: 9.2 GB} {Used: 22.8 GB} {Total: 32 GB}|'Memory Free'=9.2GB 'Memory Used'=22.8GB 'Memory Total'=32GB [Host_Memory_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_Memory_Usage --server 192.168.1.211 --host 192.168.1.210 --reporting_si Memory_Size:MB --warning memory_free:10000 --critical memory_free:5000

=back

Output for Example 2:

=over

WARNING: Host Memory {Free: 8,549 MB (WARNING <= 10,000)} {Used: 23,396 MB} {Total: 31,945 MB}|'Memory Free'=8549MB;10000;5000 'Memory Used'=23396MB 'Memory Total'=31945MB [Host_Memory_Usage]

=back

=item Host_OS_Name_Version

Report the specified Hosts' product Name and Version.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

=back

Example 1:

=over

box293_check_vmware.pl --check Host_OS_Name_Version --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

OK: VMware ESXi 5.1.0 build-1065491

=back

=item Host_pNIC_Status

Check the Status of the Hosts' Physical Network Interface Card(s) (pNIC). All pNICs are returned by default however you can target specific pNIC(s). If any pNIC is disconnected it will trigger a CRITICAL state.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--name

--nic_state

--nic_speed

--nic_duplex

=back

Example 1:

=over

box293_check_vmware.pl --check Host_pNIC_Status --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

CRITICAL: NICs [Total: 3, Connected: 1, Disconnected: 2], [vmnic1 on Local vSwitch 'vSwitch0', Driver: e1000e, NOT Connected], [vmnic0 on Local vSwitch 'vSwitch0', Driver: r8168, NOT Connected], [vmnic2 on Local vSwitch 'vSwitch0', Driver: e1000e, 1,000 MB, Full Duplex]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_pNIC_Status --server 192.168.1.211 --host 192.168.1.210 --name vmnic2

=back

Output for Example 2:

=over

OK: NICs [Total: 3, Connected: 1], [vmnic2 on Local vSwitch 'vSwitch0', Driver: e1000e, 1,000 MB, Full Duplex]

=back

=item Host_pNIC_Usage

Check the Hosts' Physical Network Interface Card(s) (pNIC) usage. Returned as kBps by default. All pNICs are returned by default however you can target specific pNIC(s). Metrics returned are [Rate (Received and Transmitted) as kBps] and [Packets (Received and Transmitted) (no thresholds checked)]. ESX(i) host version 5.0.0 and later also reports [Packet Errors (Received and Transmitted)]. TIP: group pNICs that are in the same vSwitch (like a dedicated iSCSI vSwitch) and create separate checks for different roles, this makes viewing performance data easier.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--name

--perfdata_option post_check:disabled, NIC_Rate:1, NIC_Packets:1, NIC_Packet_Errors:1

--reporting_si NIC_Rate:<Bytes Per Second>

--warning and --critical nic_rate:<Bytes Per Second>, packet_errors:<Number>

=back

Example 1:

=over

box293_check_vmware.pl --check Host_pNIC_Usage --server 192.168.1.211 --host 192.168.1.21

=back

Output for Example 1:

=over

OK: [vmnic0 {Rate (Rx:1 kBps / 100%)(Tx:0 kBps / 0%)} {Packets (Rx:138)(Tx:24)} {Packet Errors (Rx:0)(Tx:0)}]|'vmnic0 Rate Rx'=1kBps 'vmnic0 Rate Tx'=0kBps 'vmnic0 Packets Rx'=138 'vmnic0 Packets Tx'=24 'vmnic0 Packet Errors Rx'=0 'vmnic0 Packet Errors Tx'=0 [Host_pNIC_Usage]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_pNIC_Usage --server 192.168.1.211 --host 192.168.1.210 --name vmnic2 --reporting_si NIC_Rate:Bps

=back

Output for Example 2:

=over

OK: [vmnic2 {Rate (Rx:2,048 Bps / 50%)(Tx:2,048 Bps / 50%)} {Packets (Rx:320)(Tx:283)} {Packet Errors (Rx:0)(Tx:0)}]|'vmnic2 Rate Rx'=2048Bps 'vmnic2 Rate Tx'=2048Bps 'vmnic2 Packets Rx'=320 'vmnic2 Packets Tx'=283 'vmnic2 Packet Errors Rx'=0 'vmnic2 Packet Errors Tx'=0 [Host_pNIC_Usage]

=back

=item Host_Status

Check the overall status of a Host and report any known issues. 

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--exclude_issue

=back

Example 1:

=over

box293_check_vmware.pl --check Host_Status --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

WARNING: Host has a YELLOW status {Local Tech Support Mode ENABLED, Remote Tech Support Mode ENABLED}

=back

Example 2:

=over

box293_check_vmware.pl --check Host_Status --server 192.168.1.211 --host 192.168.1.210 --exclude_issue LocalTSMEnabledEvent,RemoteTSMEnabledEvent

=back

Output for Example 2:

=over

OK: No problems detected

=back

=item Host_Storage_Adapter_Info

Report Information about the Hosts' Storage Adapter(s) such as Model, Device Name and Driver Name (driver version not available at this point in time).

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--name

=back

Example 1:

=over

box293_check_vmware.pl --check Host_Storage_Adapter_Info --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

OK: [LSI 3ware 9750 (vmhba1) {Driver: 3w-sas}], [AMD Hudson SATA Controller [AHCI Mode] (vmhba0) {Driver: ahci}]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_Storage_Adapter_Info --server 192.168.1.211 --host 192.168.1.210 --name vmhba1

=back

Output for Example 2:

=over

OK: [LSI 3ware 9750 (vmhba1) {Driver: 3w-sas}]

=back

=item Host_Storage_Adapter_Performance

Check the performance of a specific Hosts' Storage Adapter. Metrics returned are [Rate (Read and Write) as kBps], [Average Number of (Reads and Writes) (no thresholds checked)] and [Latency Total (Read and Write) as ms]. You need to provide the Device Name of at least one Storage Adapter to check. NOTE: This check will not work on hosts less than version 4.1.

Required Arguments:

=over

--host (if connected via a vCenter server)

--name

=back

Optional Arguments:

=over

--modifier

--perfdata_option post_check:disabled, Averaged:1, HBA_Latency:1, HBA_Rate:1

--reporting_si HBA_Rate:<Bytes Per Second>, Latency:<Time>

--warning and --critical hba_rate:<Bytes Per Second>, hba_latency:<Time>

=back

Example 1:

=over

box293_check_vmware.pl --check Host_Storage_Adapter_Performance --server 192.168.1.211 --host 192.168.1.210 --name vmhba1

=back

Output for Example 1:

=over

OK: [LSI 3ware 9750 (vmhba1) {Rate (Read:493 kBps / 23%)(Write:1,720 kBps / 77%)} {Averaged Number of (Reads:81) (Writes:168)} {Total Latency (Read:2 ms)(Write:0 ms)}]|'vmhba1 Rate Read'=493kBps 'vmhba1 Rate Write'=1720kBps 'vmhba1 Average Number of Reads'=81 'vmhba1 Average Number of Writes'=168 'vmhba1 Latency Total Read'=2ms 'vmhba1 Latency Total Write'=0ms [Host_Storage_Adapter_Performance]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_Storage_Adapter_Performance --server 192.168.1.211 --host 192.168.1.210 --name vmhba1 --warning hba_rate:500 --critical hba_rate:1000

=back

Output for Example 2:

=over

CRITICAL: [LSI 3ware 9750 (vmhba1) {Rate (Read:227 kBps / 13%)(Write:1,595 kBps / 87% (CRITICAL >= 1,000))} {Averaged Number of (Reads:13) (Writes:157)} {Total Latency (Read:2 ms)(Write:0 ms)}]|'vmhba1 Rate Read'=227kBps;500;1000 'vmhba1 Rate Write'=1595kBps;500;1000 'vmhba1 Average Number of Reads'=13 'vmhba1 Average Number of Writes'=157 'vmhba1 Latency Total Read'=2ms 'vmhba1 Latency Total Write'=0ms [Host_Storage_Adapter_Performance]

=back

=item Host_Switch_Status

Check the Status of a Hosts' vSwitch or Distributed Switch including all pNICs that are connected to the switch.

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--mtu

--name

--nic_state

--nic_speed

--nic_duplex

=back

Example 1:

=over

box293_check_vmware.pl --check Host_Switch_Status --server 192.168.1.211 --host 192.168.1.22

=back

Output for Example 1:

=over

OK: [vSwitch0 {Local}, Ports {Total: 128} {Available: 127}, MTU: {1,500}, NICs: {No Physical NICs}], [dvSwitch {Distributed}, Ports {Total: 256} {Available: 248}, MTU: {1,500}, NICs: {Total: 2, Connected: 2} {vmnic0, Driver: e1000, 1,000 MB, Full Duplex} {vmnic1, Driver: e1000, 1,000 MB, Full Duplex}]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_Switch_Status --server 192.168.1.211 --host 192.168.1.22 --name dvSwitch --mtu 9000

=back

Output for Example 2:

=over

CRITICAL: [dvSwitch {Distributed}, Ports {Total: 256} {Available: 248}, MTU is 1500 but should be 9000, NICs: {Total: 2, Connected: 2} {vmnic0, Driver: e1000, 1,000 MB, Full Duplex} {vmnic1, Driver: e1000, 1,000 MB, Full Duplex}]

=back

=item Host_Up_Down_State

This check is to be used as a host object check, helpful for hosts can go in Standby Mode and you don't want to be alerted about this as Standby Mode is normal behaviour (a standard ping check will report the host as down when in standby mode). NOTE: there is no uptime or performance data on hosts less than 4.1.

Required Arguments:

=over

--host

=back

Optional Arguments:

=over

--perfdata_option post_check:disabled

--reporting_si Time:<Time>

--standby_exit_state

--warning and --critical uptime:<Time>

=back

NOTE: This check only works when you are checking the host through vCenter

Example 1:

=over

box293_check_vmware.pl --check Host_Up_Down_State --server 192.168.1.211 --host 192.168.1.22

=back

Output for Example 1:

=over

UP: Host is Up, Uptime: 13.7 days, Version: VMware ESXi 5.5.0 build-2143827|'Uptime'=13.7d [Host_Up_Down_State]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_Up_Down_State --server 192.168.1.211 --host 192.168.1.22

=back

Output for Example 2:

=over

STANDBY: Host in StandBy mode, in Maintenance Mode

=back

Example 3:

=over

box293_check_vmware.pl --check Host_Up_Down_State --server 192.168.1.211 --host 192.168.1.22 --standby_exit_state down

=back

Output for Example 3:

=over

DOWN: Host in StandBy mode, in Maintenance Mode

=back

Special Behaviour

=over

The --warning or --critical thresholds for “uptime” work with this check, useful if you want to be alerted if the host has been up for less than x amount of time (maybe it was rebooted and you want to know about that)

HOWEVER in relation to a host Up/Down check, there is no warning or critical status, it will be reported in Nagios as DOWN.

Example 4:

box293_check_vmware.pl --check Host_Up_Down_State --server 192.168.1.211 --host 192.168.1.22 --warning uptime:27

Output for Example 4:

WARNING: Host is Up, Uptime: 13.7 days (WARNING <= 27), Version: VMware ESXi 5.5.0 build-2143827|'Uptime'=13.7d;27

=back

=item Host_vNIC_Status

Check the Status of the Hosts' Virtual Network Interface Card(s) (vNIC) and report the role(s). All vNICs are returned by default however you can target specific vNIC(s).

Required Arguments:

=over

--host (if connected via a vCenter server)

=back

Optional Arguments:

=over

--modifier

--mtu

--name

=back

Example 1:

=over

box293_check_vmware.pl --check Host_vNIC_Status --server 192.168.1.211 --host 192.168.1.210

=back

Output for Example 1:

=over

OK: [{Management Network (vmk0 on Local vSwitch 'vSwitch0')} {MTU: 1,500} {Roles: Management}], [{VMkernel test (vmk1 on Local vSwitch 'vSwitch1')} {MTU: 1,500} {Roles: vMotion, Management, Fault Tolerance}]

=back

Example 2:

=over

box293_check_vmware.pl --check Host_vNIC_Status --server 192.168.1.211 --host 192.168.1.43 --name vswif0

=back

Output for Example 2:

=over

OK: [{vswif0 on Distributed vSwitch 'dvSwitch'} {MTU: 1,500} {Roles: Service Console}]

=back

=item vCenter_License_Status

Reports the specified vCenters' license status along with the license key. If vCenter is in evaluation mode and has less than 24 hours remaining a CRITICAL state is returned otherwise a WARNING state is returned. When vCenter is queried using an account that has read only privileges, only a portion of the key is displayed.

Required Arguments:

=over

--server

=back

Optional Arguments:

=over

--hide_key

=back

Example 1:

=over

box293_check_vmware.pl --check vCenter_License_Status --server 192.168.1.211

=back

Output for Example 1:

=over

OK: Licensed {Version: vCenter Server 5 Standard} {Key: ABCDE-#####-#####-#####-UVWXY}

=back

Example 2:

=over

box293_check_vmware.pl --check vCenter_License_Status --server 192.168.1.211 --hide_key

=back

Output for Example 2:

=over

OK: Licensed {Version: vCenter Server 5 Standard}

=back

=item vCenter_Name_Version

Report the specified vCenter product Name and Version.

Required Arguments:

=over

--server

=back

Example 1:

=over

box293_check_vmware.pl --check vCenter_Name_Version --server 192.168.1.211

=back

Output for Example 1:

=over

VMware vCenter Server 5.1.0 build-1123961

=back

=back

=head3 --server

The vCenter server or ESX(i) host to connect to. Most checks will work on either however some checks that rely on vCenter will only work against a vCenter server (such as cluster checks).

=head3 CREDENTIALS

Credentials are required to connect to the vCenter Server / ESX(i) Host. This is explained in detail in the Credentials Overview section.

=head2 OPTIONAL / AS REQUIRED

=over

=item --concurrent_checks

Maximum amount of concurrent checks that can run at any one time. Default is 15. This option helps prevent the vMA appliance from being overloaded.

=item --cluster

This is the Cluster you wish to perform the check against. If the name of the Cluster has spaces, enclose the name in "double quotes".

=item --critical

Allows you to provide a critical threshold for the check. Multiple thresholds can be defined as some checks have thresholds for different metrics (like "disk rate" and "latency"). Each critical threshold is in the format <type>:<value> such as "cpu_free:10". The value is relative to the default metric(s) used by the check OR the type defined using the --reporting_si argument. Multiple thresholds are separated with a comma such as "disk_rate:150,disk_latency:30". If the --critical argument is not supplied then it will not return a critical state. Supplying the --critical argument does not require the --warning argument however if both arguments are supplied then both thresholds are checked and triggered accordingly.

=item --datacenter

This is the Datacenter you wish to perform the check against. If the name of the Datacenter has spaces, enclose the name in "double quotes".

=item --debug

Generates a LOT of verbose information about what the plugin is doing. Creates the file /home/vi-admin/box293_check_vmware_debug_log.txt. If the debug file exists it will be overwritten.

=item --drs_automation_level

Allows you to check what a DRS Clusters' Automation level is currently set to. The options are "manual", "partiallyAutomated", "fullyAutomated" or "AlwaysOK". If the Cluster does not match the supplied parameter then a critical state is triggered. AlwaysOK is used to always return an OK state. If the --drs_automation_level argument is not supplied it will check for "fullyAutomated".

=item --drs_dpm_level

Allows you to check how a Clusters' Power Management (DPM) is configured. The options are "off", "manual", "automated" or "AlwaysOK". If the Cluster does not match the supplied parameter then a critical state is triggered. AlwaysOK is used to always return an OK state. If the --drs_dpm_level argument is not supplied it will check for "off".

=item --drs_state

Allows you to check if a Cluster has the Distributed Resource Scheduler (DRS) enabled or disabled. The options are "enabled" or "disabled". If the Cluster does not match the supplied parameter then a critical state is triggered. If the --drs_state argument is not supplied it will check for "enabled".

=item --exclude_issue

Prevent certain HOST or CLUSTER event states from causing a warning or critical status (like enabling SSH). Exclude options are "ClusterOvercommittedEvent", "DasClusterIsolatedEvent", "DasHostFailedEvent", "DasHostIsolatedEvent", "HeartbeatDatastoreNotSufficient", "HostNoRedundantManagementNetworkEvent", "InsufficientFailoverResourcesEvent", "LocalTSMEnabledEvent" or "RemoteTSMEnabledEvent". You can supply multiple options by separating them with a comma like: "LocalTSMEnabledEvent,RemoteTSMEnabledEvent".

=item --exclude_snapshot

Exclude snapshots that contain specific text, useful for backup products that create/remove snapshots freuqently. Examples are GX_BACKUP or VEEAM and you can supply multiple options by separating them with a comma like: GX_BACKUP,VEEAM. NOTE: text is CaSe sEnSaTiVe!

=item --evc_mode

Should a Clusters' Enhanced vMotion Compatibility (EVC) Mode be enabled or disabled? The options are "enabled" or "disabled". If the Cluster does not match the supplied parameter then a critical state is triggered.

=item --guest

The name of the virtual machine you are performing a check against.  If the name of the Guest has spaces, enclose the name in "double quotes".

=item --guest_consolidation_state

Allows you to define what service state (OK, WARNING, CRITICAL) should be returned if the guest disks require consolidation (true, false). The option is in the format <consolidation_state>:<service_state> such as "true:WARNING". Both states can be defined by separating with a comma such as "true:WARNING,false:OK". Default states are: true:CRITICAL, false:OK.

=item --guest_power_state

Allows you to define what service state (OK, WARNING, CRITICAL) should be returned for different guest power states (poweredOn, poweredOff, suspended). Each option is in the format <power_state>:<service_state> such as "poweredOff:CRITICAL". Multiple options are separated with a comma such as "poweredOn:OK,poweredOff:CRITICAL,suspended:WARNING". Default states are: poweredOn:OK, poweredOff:CRITICAL, suspended:CRITICAL.

=item --guest_tools_version_state

Allows you to define what service state (OK, WARNING, CRITICAL) should be returned for different guest tools version status (guestToolsBlacklisted, guestToolsCurrent, guestToolsNeedUpgrade, guestToolsNotRunning, guestToolsSupportedNew, guestToolsSupportedOld, guestToolsTooNew, guestToolsTooOld, guestToolsUnmanaged). Each option is in the format <tools_state>:<service_state> such as "guestToolsUnmanaged:OK". Multiple options are separated with a comma such as "guestToolsNeedUpgrade:CRITICAL,guestToolsSupportedOld:CRITICAL,". Default states are: guestToolsBlacklisted:CRITICAL, guestToolsCurrent:OK, guestToolsNeedUpgrade:WARNING, guestToolsNotRunning:CRITICAL, guestToolsSupportedNew:OK, guestToolsSupportedOld:WARNING, guestToolsTooNew:CRITICAL, guestToolsTooOld:CRITICAL, guestToolsUnmanaged:OK.

=item --ha_state

Allows you to check if a Cluster has High Availability (HA) enabled or disabled. The options are "enabled" or "disabled". If the Cluster does not match the supplied parameter then a critical state is triggered. If the --ha_state argument is not supplied it will check for "enabled".

=item --ha_admission_control

Should a HA Clusters' Admission Control option be enabled or disabled? The options are "enabled", "disabled" or "AlwaysOK". If the Cluster does not match the supplied parameter then a critical state is triggered. AlwaysOK is used to always return an OK state. If the --ha_admission_control argument is not supplied it will check for "enabled".

=item --ha_host_monitoring

Should a HA Clusters' Host Monitoring option be enabled or disabled? The options are "enabled", "disabled" or "AlwaysOK". If the Cluster does not match the supplied parameter then a critical state is triggered. AlwaysOK is used to always return an OK state. If the --ha_host_monitoring argument is not supplied it will check for "enabled".

=item --help

Display the help. To see the help type:

=over

box293_check_vmware.pl --help | more

=back

=item --host

The name of the ESX(i) host you are performing the check against. If connecting directly to an ESX(i) host without going via a vCenter server DO not define the --host argument, the --server argument will be used instead. NOTE: This is the NAME of the host as it appears in the inventory such as "ESX10.local" or "192.168.1.210". Using a Hosts' IP address will NOT work unless this is the NAME of the host as it appears in the inventory!

=item --hide_key

Do not display the license key for Host_License_Status or vCenter_License_Status checks. Used when this information is deemed highly sensitive

=item --license

Display the GNU General Public License. To see the license type:

=over

box293_check_vmware.pl --license | more

=back

=item --modifier

The modifier argument allows manipulation of input and output values in Guest and Host checks. Each modifier is in the format <type>:<operation>:<option>:<value> such as "request:add:insensitive:.box293.local" or "response:remove:insensitive:.box293.local". Multiple modifiers are separated with a comma such as "request:reverseip:insensitive,response:shift:upper:shift". <type> = request OR response | <operation> = add OR remove OR reverseip OR reverseip_remove OR shift | <option> = upper OR lower OR insensitive | <value> = the VALUE to add / remove / reverseip_remove, NOT REQUIRED for reverseip OR shift operations. Refer to the manual for more detailed information on this argument.

=item --mtu

For vSwitch and NIC checks you can query the MTU size like: 1500 or 9000. This will determine the service state, no default value.

=item --name

You may need to provide a name for checks like: "Datastore", "Host_pNIC_Status", "Host_pNIC_Usage", "Host_vNIC_Status", "Host_Storage_Adapter_Performance". For switch checks, a host can have multiple vSwitches, so you can specify which vSwitches you want checked (otherwise all vSwitches will be checked). Same applies for pNIC, vNIC and Host Storage Adapter checks. You can check multiple objects by separating them with a comma such as "vmnic0,vmnic1". If the name of the object has spaces, enclose the name in "double quotes".

=item --nic_state

For NIC checks (including NICs in a vSwitch) you can query if a NIC is connected or disconnected. The options are "connected" or "disconnected". If the --nic_state argument is not supplied it will check for "connected".

=item --nic_duplex

For NIC checks (including NICs in a vSwitch) you can query the duplex setting which can be full or half. The options are "full" or "half". If the --nic_duplex argument is not supplied it will check for "full".

=item --nic_speed

For NIC checks (including NICs in a vSwitch) you can query the NIC speed. The options can be "10", "100", "1000", "10000", "40000" (any value is allowed). If the --nic_speed argument is not supplied then it will not be checked however the speed will still be reported.

=item --perfdata_option

Allows you to modify the perfdata string where applicable. Each option is in the format <option>:<value> such as "post_check:disabled". By default, checks that return a performance data string have the check name appended to the end of the performance data string in square brackets (PNP4Nagios uses this for templates) ... post_check:disabled prevents this from happening as some monitoring systems like Centreon do not like this. Other options can be used to select what performance data you want checked / reported on such as "Latency:1". Multiple options are separated with a comma such as "Latency:1,post_check:disabled". Refer to the manual for what options are specific to which check.

=item --query_url

This is the URL of the Nagios server's objectjson.cgi. Required for the Guest_Host check. Nagios Core 4.0.8 is required on your Nagios Server. Example: http://xitest.box293.local/nagios/cgi-bin/objectjson.cgi

=item --query_username

This is the username for accessing the Nagios server's objectjson.cgi. Required for the Guest_Host check.

=item --query_password

This is the password for accessing the Nagios server's objectjson.cgi. Required for the Guest_Host check.

=item --reporting_si

The International System of Unit to use for results that are returned for checks like CPU Usage, Memory Usage etc. Argument format is <type>:<SI>, for example CPU_Speed:GHz or Datastore_Rate:kBps. Multiple arguments are allowed, separated with a comma, for example Datastore_Rate:kBps,Latency:ms . This is an optional argument as all checks will use a default unit unless specified. In the Checks section, each check explains what default unit is used. The unit types are: [Bytes: B, kB, MB, GB, TB, PB, EB] [Bytes Per Second: Bps, kBps, MBps, GBps, TBps, PBps, EBps] [Hertz: Hz, kHz, MHz, GHz, THz] [Time: us, ms, s, m, h, d].

=item --service_status_info

The current "Status Information" of the Nagios service which is running the Guest_Host check (required for the Guest_Host check). In a Nagios service object definition use the macro $SERVICEOUTPUT$, refer to the manual for a detailed explanation.

=item --standby_exit_state

If an ESX(i) host is in Standby mode, the default exit state is UP. If you want it to report a DOWN state, use this argument with the value down. Example: --standby_exit_state down 

=item --swapfile_policy

Should a Clusters' Swapfile Policy option be vmDirectory or hostLocal? The options are "vmDirectory" or "hostLocal". If the Cluster does not match the supplied parameter then a critical state is triggered. If the --swapfile_policy argument is not supplied it will check for "vmDirectory".

=item --timeout

Specify the time a check is allowed to execute for. 60 seconds by default.

=item --version

Reports the plugin version.

=item --warning

Allows you to provide a warning threshold for the check. Multiple thresholds can be defined as some checks have thresholds for different metrics (like "disk rate" and "latency"). Each warning threshold is in the format <type>:<value> such as "cpu_free:10". The value is relative to the default metric(s) used by the check OR the type defined using the --reporting_si argument. Multiple thresholds are separated with a comma such as "disk_rate:150,disk_latency:30". If the --warning argument is not supplied then it will not return a warning state. Supplying the --warning argument does not require the --critical argument however if both arguments are supplied then both thresholds are checked and triggered accordingly.

=back

=head1 CREDENTIALS OVERVIEW

When executing a check, you will need to supply a username and password to access to the vCenter server or ESX(i) host. When you connect to a vCenter server, you do NOT need to supply additional credentials to perform checks against ESX(i) systems managed by that vCenter server.

There are a couple of options available for providing credentials when connecting to a vCenter server or ESX(i) host.

=head2 USING THE CREDENTIALS STORE

On the vMA appliance you can use the "Credentials Store" to save a username and passwords for each relevant vCenter server or ESX(i) host. This means that when the check is executed, vMA looks in the Credentials Store to see if it has saved credentials for that vCenter server or ESX(i) host. 

The benefits of using the Credentials Store are:

=over

=item

Makes it easier to change a password in the future, it only needs to be updated once on the vMA appliance and all checks from then on use the new password (which means you don't need to update any service definitions on your Nagios host).

=item

No credentials are exposed on the Nagios host for other admins to see

=back

To add credentials to the credentials store:

=over

=item

SSH to the vMA appliance as vi-admin

=item

Type /usr/lib/vmware-vcli/apps/general/credstore_admin.pl add --server <vCenter server or ESX(i) host> --username readonly --password "A V3ry Str0ng P@ssw0rd"

=back

=head2 USING THE --username AND --password ARGUMENTS

If you do not want to use the credentials store you can provide the --username and --password arguments instead. NOTE: If your password has special characters like spaces or hash symbols you will need to enclose the password in "double quotes".

=head1 LICENSE

You should have received a copy of the GNU General Public License along with this program.  If not, see <http://www.gnu.org/licenses/>.

To see the license type:

=over

box293_check_vmware.pl --license | more

=back

=head1 PROJECT DETAILS

About 368 hours has been spent on this project!

Contributions and feedback is welcome and encouraged.

=head1 AUTHOR

Troy Lea AKA Box293

Email: <plugins@box293.com>

Twitter: @Box293

See all my Nagios Projects on the Nagios Exchange: http://exchange.nagios.org/directory/Owner/Box293/1

I also have some other Nagios related information here: http://sites.box293.com/nagios

=cut

# ------------------------------------------------------------------------------
# 				END Documentation
# ------------------------------------------------------------------------------
