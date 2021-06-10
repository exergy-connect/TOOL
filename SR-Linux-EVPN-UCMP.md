# SR Linux BGP EVPN UCMP configuration - emulated hosts

Based on the BGP/EVPN overlay configuration for a leaf/spine topology, this snippet adds host configurations

## SRL Hosts

Add a tagged client interface to the default VRF, and commit:
```
enter candidate
/interface ethernet-1/1
vlan-tagging true
subinterface 1000
type routed
ipv4 address ${/interface[name=ethernet-1/1]/subinterface[index=0]/ipv4/address/ip-prefix}
exit
exit
ipv6 address ${/interface[name=ethernet-1/1]/subinterface[index=0]/ipv6/address/ip-prefix}
exit
exit
vlan encap single-tagged vlan-id 1000
admin-state enable
/network-instance default
interface ethernet-1/1.1000
delete interface ethernet-1/1.0
commit now
```

## Leaves

Move host BGP sessions from the default VRF to the overlay, using dynamic neighbors: TODO get peer IPs from state?
```
enter candidate
/network-instance default protocols bgp delete neighbor 192.168.0.133
/network-instance overlay-vrf protocols bgp 
autonomous-system ${/network-instance[name=default]/protocols/bgp/autonomous-system}
router-id ${/network-instance[name=default]/protocols/bgp/router-id}
group hosts admin-state enable peer-as ${/network-instance[name=default]/protocols/bgp/group[group-name=hosts]/peer-as}
dynamic-neighbors accept match 192.168.0.0/24 
allowed-peer-as [${/network-instance[name=default]/protocols/bgp/group[group-name=hosts]/peer-as}] 
peer-group hosts
commit now
```

