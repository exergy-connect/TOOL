# Basic underlay configuration for spine and leaf

The snippets below can be used to configure a pair of SR Linux nodes with basic underlay connectivity and BGP between spines and leaves:

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
        ipv4 { address 1.1.0.1/32 { } }
        ipv6 { address 2001::1:1:0:1/128 { } }
    }
/delete network-instance default
/network-instance default
type default
admin-state enable
interface lo0.0 { }
interface ethernet-1/1.0 { }
commit now
```

Using BGP as IGP, with dynamic neighbors:
```
enter candidate
/network-instance default
delete protocols bgp
protocols bgp {
        admin-state enable
        router-id 1.1.0.1
        autonomous-system 65000
        dynamic-neighbors {
            accept {
                match 192.168.0.0/24 {
                    peer-group leaves
                    allowed-peer-as [
                        65001
                    ]
                }
            }
        }
        group leaves {
            admin-state enable
            peer-as 65001
        }
        ebgp-default-policy {
           import-reject-all false
           export-reject-all false
        }
    }
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
/delete interface lo0
/interface lo0
    description "Loopback on Leaf1"
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

Using BGP as IGP:
```
enter candidate
/network-instance default
delete protocols bgp
protocols bgp {
        admin-state enable
        router-id 1.1.1.1
        autonomous-system 65001
        group spines {
            admin-state enable
            peer-as 65000
        }
        neighbor 192.168.0.0 {
            admin-state enable
            peer-group spines
        }
        ebgp-default-policy {
           import-reject-all false
           export-reject-all false
        }
    }
commit now
```

Check BGP peering:
```
/show network-instance default protocols bgp neighbor
```
