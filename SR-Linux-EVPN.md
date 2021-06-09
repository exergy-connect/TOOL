# SR Linux BGP EVPN configuration

The following CLI snippets configure an SR Linux Leaf/Spine topology for BGP EVPN IPv4, assuming the underlay is already setup.
Before you start, make sure that the node you're working on is annotated with its relative ID.

For spine1/leaf1:
```
enter candidate
/system !!! 1
commit now
```
For spine2/leaf2:
```
enter candidate
/system !!! 2
commit now
```
(etc.)

## Spines

Before we begin, let's take a look at the starting configuration on the spine:
```
/show network-instance default protocols bgp neighbor
```

This should look something like this:
```
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
BGP neighbor summary for network-instance "default"
Flags: S static, D dynamic, L discovered by LLDP, B BFD enabled, - disabled, * slow
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
+-----------------------+---------------------------------+-----------------------+--------+------------+------------------+------------------+----------------+---------------------------------+
|       Net-Inst        |              Peer               |         Group         | Flags  |  Peer-AS   |      State       |      Uptime      |    AFI/SAFI    |         [Rx/Active/Tx]          |
+=======================+=================================+=======================+========+============+==================+==================+================+=================================+
| default               | 192.168.0.1                     | leaves                | DB     | 65001      | established      | 0d:0h:2m:48s     | ipv4-unicast   | [1/1/2]                         |
|                       |                                 |                       |        |            |                  |                  | ipv6-unicast   | [1/1/2]                         |
| default               | 192.168.0.3                     | leaves                | DB     | 65002      | established      | 0d:0h:3m:3s      | ipv4-unicast   | [1/1/2]                         |
|                       |                                 |                       |        |            |                  |                  | ipv6-unicast   | [1/1/2]                         |
+-----------------------+---------------------------------+-----------------------+--------+------------+------------------+------------------+----------------+---------------------------------+
-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
Summary:
0 configured neighbors, 0 configured sessions are established,0 disabled peers
2 dynamic peers
```

Note how each leaf and spine are advertising their loopback IPs, the spine is using all the routes it receives, and sends back both its own loopback and the loopback of the other leaves (1 other in this case)

1. Configure each spine as an iBGP EVPN Route Reflector, using the default network instance (uses CLI enhancement to resolve router-id):
```
enter candidate
/network-instance default protocols bgp 
evpn rapid-update true
group evpn
ipv4-unicast admin-state disable
ipv6-unicast admin-state disable
evpn admin-state enable
route-reflector client true cluster-id ${/network-instance[name=default]/protocols/bgp/router-id}
commit now
```

2. Add multi-hop iBGP peering for each leaf, using loopback IPs and dynamic peering
```
enter candidate
/network-instance default protocols bgp
dynamic-neighbors accept match 1.1.1.0/24
peer-group evpn
allowed-peer-as [${/network-instance[name=default]/protocols/bgp/autonomous-system}]
commit now
```

Alternatively, add each peer by its IP address; this is more cumbersome in operations, as spine configs must be modified each time a leaf is added
```
enter candidate
/network-instance default protocols bgp
neighbor 1.1.1.1
admin-state enable
peer-group evpn
commit now
```

## Leaves

1. Add a Route Reflector iBGP group, EVPN-only, using loopback interface as source
```
enter candidate
/network-instance default protocols bgp
evpn rapid-update true
group evpn-rr
transport local-address ${/network-instance[name=default]/protocols/bgp/router-id}
local-as 65000
exit
peer-as 65000
ipv4-unicast admin-state disable
ipv6-unicast admin-state disable
evpn
admin-state enable
commit now
```

2. Add each Route Reflector as an iBGP peer
```
enter candidate
/network-instance default protocols bgp
neighbor 1.1.0.1
admin-state enable
peer-group evpn-rr
commit now
```

3. Check that iBGP peering came up (assumes loopback IPs are advertised)
```
/show network-instance default protocols bgp neighbor
```

## VXLAN Datapath between leaves

1. Create a VXLAN system interface on each leaf, and put it in the default global routing context
```
enter candidate
/interface system0 subinterface 0
ipv4 address ${/network-instance[name=default]/protocols/bgp/router-id}/32
/interface lo0 subinterface 0 delete ipv4
/network-instance default interface system0.0
commit now
```

2. Create a sample overlay L2 or L3 VRF on 2 leaves, and verify connectivity

Either L2 (annotated):
```
enter candidate
/network-instance overlay-vrf
type mac-vrf !!! bridged
```

Or L3 (annotated):
```
enter candidate
/network-instance overlay-vrf
type ip-vrf !!! routed
```

Configure BGP EVPN:
```
/network-instance overlay-vrf
protocols bgp-vpn bgp-instance 1 
route-target import-rt target:65000:10000 export-rt target:65000:10000
exit
exit
bgp-evpn bgp-instance 1
evi 10000
ecmp 8
admin-state enable
exit
exit
exit
admin-state enable
```

Add a VXLAN interface, with the correct type:
```
/tunnel-interface vxlan1
vxlan-interface 0
type ${/network-instance[name=overlay-vrf]/type!!!}
ingress vni 10000
egress source-ip use-system-ipv4-address
/network-instance overlay-vrf 
vxlan-interface vxlan1.0
exit
protocols bgp-evpn bgp-instance 1 vxlan-interface vxlan1.0
```

Add a client interface, and commit:
```
/interface ethernet-1/3
vlan-tagging true
subinterface 1000
type ${/network-instance[name=overlay-vrf]/type!!!}
delete ipv4
delete ipv6
vlan encap single-tagged vlan-id 1000
admin-state enable
/network-instance overlay-vrf
interface ethernet-1/3.1000
commit now
```

For L3 you can add an IP address: ( could annotate !!!type=bridged,ip=# for L2, and comment out )
Note that '${/system!!!}' resolves to the node's relative ID (leaf1=1, leaf2=2, etc.)
```
enter candidate
/interface ethernet-1/3 subinterface 1000
ipv4 address 10.10.${/system!!!}.1/24
commit now
# use 'discard now' to undo
```

## Verification
To verify that EVPN routes are being sent to the Route Reflector (spines):
```
/show network-instance default protocols bgp neighbor 1.1.0.1 advertised-routes evpn
```
### Testing L2 with Linux hosts
For example using Alpine Linux:
```
docker exec -it clab-evpn-lab-h1 /bin/sh
HOST_ID=$(echo `hostname -s` | sed 's/[^0-9]*//g')

ip link add link e1-1 name e1-1.1000 type vlan id 1000
ip link set e1-1.1000 up
ip a add 192.168.1.${HOST_ID}/24 dev e1-1.1000
ip -6 a add 2000:192:168:1::${HOST_ID}/64 dev e1-1.1000
```

### Testing L3 from SR Linux
After assigning each leaf a unique /24 subnet:
```
/network-instance overlay-vrf
ping 10.10.${/system!!!|2 if int(_)==1 else 1}.1
```
