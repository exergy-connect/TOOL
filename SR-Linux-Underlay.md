# Basic underlay configuration for spine and leaf

The snippets below can be used to configure an SR Linux node with basic underlay connections between spines and leaves:

Spine1:
```
enter candidate
/delete interface ethernet-1/1
/interface ethernet-1/1
    description "Basic underlay connection to Leaf1"
    admin-state enable
    subinterface 0 {
        type routed
        admin-state enable
        ipv4 { address 192.168.0.0/31 { } }
        ipv6 { address 2001::192:168:0:0/127 { } }
    }
/delete interface lo0
/interface lo0
    description "Loopback on Spine1"
    admin-state enable
    subinterface 0 {
        admin-state enable
        ipv4 { address 1.1.1.1/32 { } }
        ipv6 { address 2001::1:1:1:1/128 { } }
    }
/delete network-instance default
/network-instance default
type default
admin-state enable
interface lo0.0 { }
interface ethernet-1/1.0 { }
commit now
```

Leaf1:
```
enter candidate
/delete interface ethernet-1/1
/interface ethernet-1/1
    description "Basic underlay connection to Spine1"
    admin-state enable
    subinterface 0 {
        type routed
        admin-state enable
        ipv4 { address 192.168.0.1/31 { } }
        ipv6 { address 2001::192:168:0:1/127 { } }
    }
/delete network-instance default
/network-instance default
type default
admin-state enable
interface ethernet-1/1.0 { }
commit now
```
