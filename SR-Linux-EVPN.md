# SR Linux BGP EVPN configuration

The following CLI snippets configure an SR Linux Leaf/Spine topology for BGP EVPN IPv4, assuming the underlay is already setup

```js script  
TODO: Script that presents an input field to customize IP addresses in the snippets below
```  
## Spines

1. Configure each spine as an iBGP Route Reflector, using the default network instance:
```
enter candidate
/network-instance default protocols bgp group evpn
evpn admin-state enable
route-reflector client true cluster-id 1.1.1.1
commit now
```

2. Add multi-hop iBGP peering for each leaf, using loopback IPs (note: at least up to R21.3 dynamic neighbors are not supported for BGP-VPN)
```
enter candidate
/network-instance default protocols bgp
neighbor 1.1.2.1
admin-state enable
peer-group evpn
commit now
```

## Leaves

1. Add a Route Reflector iBGP group
```
enter candidate
/network-instance default protocols bgp
group evpn-rr
peer-as 65000
evpn
admin-state enable
commit now
```

2. Add each Route Reflector as an iBGP peer
```
enter candidate
/network-instance default protocols bgp
neighbor 1.1.1.1
admin-state enable
peer-group evpn-rr
commit now
```

3. Check that iBGP peering came up
```
/show network-instance default protocols bgp-evpn bgp-instance 1
```
