# SR Linux BGP EVPN configuration

The following CLI snippets configure an SR Linux Leaf/Spine topology for BGP EVPN IPv4, assuming the underlay is already setup

```js script  
import './demo-wc-card.js';  
import { html } from 'lit-html';  
```  

# This is my component  

```js story  
export const demo = () => html`  
<demo-wc-card header="HEADER"></demo-wc-card>
<input type="text">Enter spine loopback IP</input>
`;  
```

## Spines

1. Configure each spine as an iBGP Route Reflector, using the default network instance:
```
enter candidate
/network-instance default
group evpn
evpn
admin-state enable
route-reflector client true cluster-id 1.1.1.1
commit now
```

2. Add multi-hop iBGP peering for each leaf, using loopback IPs
```
enter candidate
/network-instance default
neighbor 1.1.2.1
admin-state enable
peer-group evpn
commit now
```

## Leaves

1. Add a Route Reflector iBGP group
```
enter candidate
/network-instance default
group evpn-rr
peer-as 65000
evpn
admin-state enable
commit now
```
