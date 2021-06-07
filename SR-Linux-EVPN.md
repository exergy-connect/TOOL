# SR Linux BGP EVPN configuration

The following CLI snippets configure an SR Linux Leaf/Spine topology for BGP EVPN IPv4, assuming the underlay is already setup

```js script  
TODO: Script that presents an input field to customize IP addresses in the snippets below
```  
## Spines

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
allowed-peer-as [${/network-instance[name=default]/protocols/bgp/autonomous-system}]
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

1. Create a VXLAN system interface on each leaf, and a tunnel interface
```
enter candidate
/interface system0 subinterface 0
ipv4 address ${/network-instance[name=default]/protocols/bgp/router-id}/32
/interface lo0 subinterface 0 delete ipv4
/network-instance default interface system0.0
/tunnel-interface vxlan1
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
ecmp 8
evi 10000
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
```

Add a client interface, and commit:
```
/interface ethernet-1/3
vlan-tagging true
subinterface 1000
type ${/network-instance[name=overlay-vrf]/type!!!}
ipv4 address 10.10.10.1/24
exit
exit
vlan encap single-tagged vlan-id 1000
admin-state enable
/network-instance overlay-vrf
interface ethernet-1/3.1000
commit now
```

If the system complains about a mismatch of tagged and untagged traffic on the same interface, change the subinterface to be tagged:
```
enter candidate
/interface ethernet-1/3 subinterface 0 vlan encap 
delete untagged
single-tagged vlan-id 1
commit now
```

Alternatively, one vlan can remain untagged, but in that case this vlan must be bridged, and cannot also have an IP on the interface:
```
enter candidate
/interface ethernet-1/3 subinterface 0
type bridged
delete ipv4
delete ipv6
delete vlan encap
vlan encap untagged
commit now
```

To verify that EVPN routes are being sent to the Route Reflector (spines):
```
/show network-instance default protocols bgp neighbor 1.1.0.1 advertised-routes evpn
```
