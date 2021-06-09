# SR Linux BGP EVPN UCMP configuration - emulated hosts

Based on the BGP/EVPN overlay configuration for a leaf/spine topology, this snippet adds host configurations

## SRL Hosts

Add a client interface to the default VRF, and commit:
```
enter candidate
/interface ethernet-1/1
vlan-tagging true
subinterface 1000
type routed
ipv4 address 10.10.10.10/32
exit
ipv6 address 2001::10:10:10:10/128
exit
vlan encap single-tagged vlan-id 1000
admin-state enable
/network-instance default
interface ethernet-1/1.1000
commit now
```
