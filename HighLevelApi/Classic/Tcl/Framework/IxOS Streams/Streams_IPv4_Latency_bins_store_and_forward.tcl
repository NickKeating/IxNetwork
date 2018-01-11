################################################################################
# Version 1.0    $Revision: 1 $
# $Author: L.Raicea $
#
#    Copyright � 1997 - 2005 by IXIA
#    All Rights Reserved.
#
#    Revision Log:
#    7-29-2005 L.Raicea - latency bins stats with store and forward.
#
# Description:
#
################################################################################

################################################################################
#                                                                              #
#                                LEGAL  NOTICE:                                #
#                                ==============                                #
# The following code and documentation (hereinafter "the script") is an        #
# example script for demonstration purposes only.                              #
# The script is not a standard commercial product offered by Ixia and have     #
# been developed and is being provided for use only as indicated herein. The   #
# script [and all modifications, enhancements and updates thereto (whether     #
# made by Ixia and/or by the user and/or by a third party)] shall at all times #
# remain the property of Ixia.                                                 #
#                                                                              #
# Ixia does not warrant (i) that the functions contained in the script will    #
# meet the user's requirements or (ii) that the script will be without         #
# omissions or error-free.                                                     #
# THE SCRIPT IS PROVIDED "AS IS" WITHOUT WARRANTY OF ANY KIND, AND IXIA        #
# DISCLAIMS ALL WARRANTIES, EXPRESS, IMPLIED, STATUTORY OR OTHERWISE,          #
# INCLUDING BUT NOT LIMITED TO ANY WARRANTY OF MERCHANTABILITY AND FITNESS FOR #
# A PARTICULAR PURPOSE OR OF NON-INFRINGEMENT.                                 #
# THE ENTIRE RISK AS TO THE QUALITY AND PERFORMANCE OF THE SCRIPT  IS WITH THE #
# USER.                                                                        #
# IN NO EVENT SHALL IXIA BE LIABLE FOR ANY DAMAGES RESULTING FROM OR ARISING   #
# OUT OF THE USE OF, OR THE INABILITY TO USE THE SCRIPT OR ANY PART THEREOF,   #
# INCLUDING BUT NOT LIMITED TO ANY LOST PROFITS, LOST BUSINESS, LOST OR        #
# DAMAGED DATA OR SOFTWARE OR ANY INDIRECT, INCIDENTAL, PUNITIVE OR            #
# CONSEQUENTIAL DAMAGES, EVEN IF IXIA HAS BEEN ADVISED OF THE POSSIBILITY OF   #
# SUCH DAMAGES IN ADVANCE.                                                     #
# Ixia will not be required to provide any software maintenance or support     #
# services of any kind (e.g., any error corrections) in connection with the    #
# script or any part thereof. The user acknowledges that although Ixia may     #
# from time to time and in its sole discretion provide maintenance or support  #
# services for the script, any such services are subject to the warranty and   #
# damages limitations set forth herein and will not obligate Ixia to provide   #
# any additional maintenance or support services.                              #
#                                                                              #
################################################################################

################################################################################
#                                                                              #
# Description:                                                                 #
#    This sample creates 10 IPv4 interfaces on two ports. Also a stream is     #
#    created in order to transmit from the 10 interfaces on the Tx port to the #
#    10 interfaces created on the Rx port. The Tx and Rx ports must be         #
#    connected to a Cisco DUT with appropriate interface configuration.        #
#                                                                              #
#    Transmision lasts for 5 seconds then statiscs are retrieved. The latency  #
#    control mode is set to store and forward in order to measure the time     #
#    interval between the last data bit out of the Ixia transmit port and the  #
#    first data bit received by the Ixia receive port.                         #
#                                                                              #
# Module:                                                                      #
#    The sample was tested on a LM1000STXS4 module.                            #
#    The sample was tested with HLTSET26.                                      #
#                                                                              #
################################################################################

package require Ixia

set test_name [info script]

set chassisIP sylvester

set num_hosts 10

set ipV4_port_list    "1/3         1/4"
set ipV4_netmask_list "255.255.255.0  "
set ipV4_version_list "4                 "
set ipV4_autoneg_list "0                 "
set ipV4_duplex_list  "full              "
set ipV4_speed_list   "ether100       "
set ipV4_qos_list     "0              "
set ipV4_rx_mode_list "wide_packet_group"


#################################################################################
#                              START TEST                                       #
#################################################################################

# Connect to the chassis, reset to factory defaults and take ownership
set connect_status [::ixia::connect  \
        -reset                     \
        -device    $chassisIP      \
        -port_list $ipV4_port_list \
        -username  ixiaApiUser     ]
if {[keylget connect_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget connect_status log]"
}

set port_handle_tx [keylget connect_status \
        port_handle.$chassisIP.[lindex $ipV4_port_list 0]]
set port_handle_rx [keylget connect_status \
        port_handle.$chassisIP.[lindex $ipV4_port_list 1]]
set port_handle [list $port_handle_tx $port_handle_rx]


########################################
# Configure interface in the test      #
# IPv4                                 #
########################################
for {set i 1} {$i <= $num_hosts} {incr i} {
    set ipV4_ixia_list    "14.1.1.$i                 13.1.1.$i"
    set ipV4_gateway_list "14.1.1.100                13.1.1.100"
    set ipV4_mac_list     "0000.deaa.000[expr $i -1] 0000.debb.000[expr $i -1]"
    
    set interface_status [::ixia::interface_config \
            -port_handle     $port_handle        \
            -intf_ip_addr    $ipV4_ixia_list     \
            -gateway         $ipV4_gateway_list  \
            -netmask         $ipV4_netmask_list  \
            -src_mac_addr    $ipV4_mac_list      \
            -qos_stats       $ipV4_qos_list      \
            -port_rx_mode    $ipV4_rx_mode_list  \
            -autonegotiation $ipV4_autoneg_list  \
            -duplex          $ipV4_duplex_list   \
            -speed           $ipV4_speed_list]
    
    if {[keylget interface_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget interface_status log]"
    }
}

##################################
#  Configure streams on TX port  #
##################################
set stream_index_list ""

# Configure the stream on the first IpV4 port
set traffic_status  [::ixia::traffic_config          \
        -mode                      create          \
        -port_handle               $port_handle_tx \
        -l3_protocol               ipv4            \
        -ip_src_addr               14.1.1.1        \
        -ip_src_mode               increment       \
        -ip_src_step               0.0.0.1         \
        -ip_src_count              $num_hosts      \
        -ip_dst_addr               13.1.1.1        \
        -ip_dst_mode               increment       \
        -ip_dst_step               0.0.0.1         \
        -ip_dst_count              $num_hosts      \
        -l3_length                 1024            \
        -rate_percent              50              \
        -mac_dst_mode              discovery       \
        ]
if {[keylget traffic_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_status log]"
}

# This should be uncommented when using a valid gateway for the interface
# configured above through the interface_config call.
if {0} {
    set interface_status [::ixia::interface_config  \
            -port_handle     $port_handle_tx           \
            -arp_send_req    1                      ]
    if {[keylget interface_status status] != $::SUCCESS} {
        return "FAIL - $test_name - [keylget interface_status log]"
    }
    if {[catch {set failed_arp [keylget interface_status \
            $port_handle_tx.arp_request_success]}] || $failed_arp == 0} {
        set returnLog "FAIL - $test_name arp send request failed. "
        if {![catch {set intf_list [keylget interface_status \
            $port_handle_tx.arp_ipv4_interfaces_failed]}]} {
            append returnLog "ARP failed on interfaces: $intf_list."
        }
        return $returnLog
    }
}

set stream_id_list [keylget traffic_status stream_id]
set number_of_streams [llength $stream_id_list]
set number_of_bins  3

#########################
# Start traffic on port #
#########################
# Clear stats before sending traffic
set clear_stats_status [::ixia::traffic_control  \
        -port_handle     $port_handle          \
        -action          clear_stats           \
        -latency_bins    $number_of_bins       \
        -latency_values  2 3.45                \
        -latency_control store_and_forward     ]
if {[keylget clear_stats_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget clear_stats_status log]"
}

set traffic_control_status [::ixia::traffic_control \
        -port_handle $port_handle_tx              \
        -action      run                          ]
if {[keylget traffic_control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_control_status log]"
}

# Sleep n seconds for traffic to run
ixia_sleep 5000

set traffic_control_status [::ixia::traffic_control \
        -port_handle $port_handle_tx              \
        -action      stop                         ]
if {[keylget traffic_control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_control_status log]"
}

# Sleep n seconds for traffic to run
ixia_sleep 1000

############################################
# Get traffic statistics for all the PGIDs #
############################################
set pgid_statistics_list [::ixia::traffic_stats \
        -port_handle     $port_handle_rx      \
        -mode            streams              \
        ]

#############################
#   Format the statistics   #
#############################



puts  "\n"
puts  "+---------------------------------------------------------------+"
puts  "+                       Statistic Results                       +"
puts  "+---------------------------------------------------------------+"
puts  "+ Time                   : [clock format [clock seconds]]"
puts  "+ Number of Streams      : $number_of_streams"
puts  "+ Number of Latency Bins : $number_of_bins"
puts  "+ Note                   : Latency values are in nsec"
puts  "+---------------------------------------------------------------+"
puts  [format "%8s  %8s  %15s  %15s  %8s  %8s  %8s" \
        Stream Bin# FirstTS LastTS MaxLat MinLat TotalPackets]

 
for {set stream_index 0} {$stream_index < $number_of_streams} {incr stream_index} { 
    set stream_id [lindex $stream_id_list $stream_index]
    for {set l 1} {$l <= $number_of_bins} {incr l} {

        puts  [format "%8d  %8d  %15.1f  %15.1f  %8.1f  %8.1f  %8d" $stream_id   $l    \
            [keylget pgid_statistics_list \
       $port_handle_rx.stream.$stream_id.rx.latency_bin.$l.first_tstamp] \
            [keylget pgid_statistics_list \
       $port_handle_rx.stream.$stream_id.rx.latency_bin.$l.last_tstamp] \
            [keylget pgid_statistics_list \
       $port_handle_rx.stream.$stream_id.rx.latency_bin.$l.max] \
            [keylget pgid_statistics_list \
       $port_handle_rx.stream.$stream_id.rx.latency_bin.$l.min] \
            [keylget pgid_statistics_list \
       $port_handle_rx.stream.$stream_id.rx.latency_bin.$l.total_pkts] \
            [keylget pgid_statistics_list ]]
    }
}


ixia_sleep 1000

########################
# Stop traffic on port #
########################
set traffic_control_status [::ixia::traffic_control \
        -port_handle $port_handle_tx              \
        -action      stop                         ]
if {[keylget traffic_control_status status] != $::SUCCESS} {
    return "FAIL - $test_name - [keylget traffic_control_status log]"
}

return "SUCCESS - $test_name - [clock format [clock seconds]]"
