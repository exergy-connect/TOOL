# SR Linux BGP EVPN configuration

The following CLI snippets configure an SR Linux Leaf/Spine topology for BGP EVPN IPv4, assuming the underlay is already setup

```js script  
TODO: Script that presents an input field to customize IP addresses in the snippets below
```  
## Spines

1. Configure each spine as an iBGP EVPN Route Reflector, using the default network instance:
```
enter candidate
/network-instance default protocols bgp 
evpn rapid-update true
group evpn
ipv4-unicast admin-state disable
ipv6-unicast admin-state disable
evpn admin-state enable
route-reflector client true cluster-id 1.1.0.1
commit now
```

2. Add multi-hop iBGP peering for each leaf, using loopback IPs
```
enter candidate
/network-instance default protocols bgp
neighbor 1.1.1.1
admin-state enable
peer-group evpn
commit now
```
Alternatively, use dynamic peering:
```
enter candidate
/network-instance default protocols bgp
dynamic-neighbors accept match 1.1.1.0/24
peer-group evpn
allowed-peer-as [65000]
commit now
```

## Leaves

1. Add a Route Reflector iBGP group, EVPN-only
```
enter candidate
/network-instance default protocols bgp
evpn rapid-update true
group evpn-rr
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

1. Create a VXLAN system interface on each leaf
```
enter candidate
/tunnel-interface vxlan1
commit now
```

2. Create a sample overlay L3 VRF on 2 leaves, and verify connectivity
```
enter candidate
/tunnel-interface vxlan1
vxlan-interface 0
type routed
ingress vni 10000
egress source-ip use-system-ipv4-address

/interface ethernet-1/3
vlan-tagging true
subinterface 1000
admin-state enable
vlan encap single-tagged vlan-id 1000

/network-instance overlay-vrf
type ip-vrf
interface ethernet-1/3.1000
exit
vxlan-interface vxlan1.0
exit
protocols bgp-vpn bgp-instance 1 
route-distinguisher rd 65000:10000
route-target import-rt target:65000:10000 export-rt target:65000:10000
exit
exit
bgp-evpn bgp-instance 1
ecmp 8
evi 10000
vxlan-interface vxlan1.0
exit
exit
admin-state enable
commit now
```
