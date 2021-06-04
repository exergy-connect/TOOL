# SR Linux BGP EVPN configuration

The following CLI snippets configure an SR Linux Leaf/Spine topology for BGP EVPN IPv4, assuming the underlay is already setup

```js script  
TODO: Script that presents an input field to customize IP addresses in the snippets below
```  
## Spines

1. Configure each spine as an iBGP EVPN Route Reflector, using the default network instance:
```
enter candidate
/network-instance default protocols bgp group evpn
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

3. Check that iBGP peering came up
```
/show network-instance default protocols bgp neighbor
```
