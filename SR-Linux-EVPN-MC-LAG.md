# SR Linux EVPN based Multi-Chassis LAG configuration

SR Linux supports link aggregation across multiple (up to 4) leaves, using BGP EVPN Multi-Homing for synchronizing state (like signalling MAC addresses).

The following CLI snippets configure a pair of SR Linux Leaves for BGP EVPN MC-LAG, assuming the underlay with EVPN peering is already setup.
Before you start, configure an environment variable with the port number to use (using a CLI extension)

For ethernet-1/3:
```
${PORT=3}
```
For ethernet-1/4:
```
${PORT=4}
```
(etc.)

## Creating a Link Aggregation Interface (LAG) with a subinterface

The maximum number of LAG interfaces supported depends on the SR Linux hardware platform: 
lag\<N\> where N=1..32 for 7220-D1, 7220-D2, 7220-D3. N=1..127 for 7220-H2, 7220-H3

```
/interface lag${PORT}
admin-state enable
    vlan-tagging true
    subinterface 0 {
        type bridged
        vlan {
            encap {
                # Alternative: untagged
                single-tagged {
                  vlan-id 1
                }
            }
        }
    }
    lag {
        lag-type static
        member-speed 25G
    }
```

## Associating an Ethernet interface with a LAG

Remove VLAN tagging and any subinterfaces from the physical interface first
```
/interface ethernet-1/${PORT}
delete vlan-tagging
delete subinterface 0
ethernet {
  aggregate-id lag${PORT}
}
```

## Creating a system-wide Ethernet segment

The EVPN route-target and route-distinguisher can be automatically derived from the ESI and local router ID
```
/system network-instance protocols 
evpn {
  ethernet-segments {
        bgp-instance 1 {
            ethernet-segment es-lag${PORT} {
                admin-state enable
                esi 00:12:12:12:12:12:12:00:00:0${PORT}
                interface lag${PORT}
                multi-homing-mode all-active
            }
        }
    }
 }
bgp-vpn {
        bgp-instance 1 {
        }
    }
```

## Creating a L2 VXLAN interface

Here we use a simple convention VNI=port, this is not required
```
/tunnel-interface vxlan0
vxlan-interface ${PORT} {
        type bridged
        ingress {
            vni ${PORT}
        }
        egress {
            source-ip use-system-ipv4-address
        }
    }
```
## Create an Integrated Routing and Bridging (IRB) interface
To connect the L2 LAG with the rest of the network, an IRB\<N\> (N=0..255) interface to a routed VRF can be used, using an anycast gateway construct:
```
/interface irb0
admin-state enable
subinterface ${PORT} {
    admin-state enable
    ipv4 {
        address 10.10.10.1/24 {
           anycast-gw true
           primary
        }
    }
    ipv6 {
    }
    anycast-gw {
    }
}
```

## Create a MAC-VRF (broadcast domain)

If the physical interface is associated with a VRF, remove it:
```
/network-instance overlay delete interface ethernet-1/${PORT}.0
```

Naming is arbitrary
```
/network-instance mac-vrf-lag${PORT}
    type mac-vrf
    admin-state enable
    interface lag${PORT}.0 {
    }
    interface irb0.${PORT} {
    }
    vxlan-interface vxlan0.${PORT} {
    }
    protocols {
        bgp-evpn {
            bgp-instance 1 {
                admin-state enable
                vxlan-interface vxlan0.${PORT}
                evi ${PORT}
                ecmp 8
            }
        }
        bgp-vpn {
          bgp-instance 1 {
            }
        }
    }
 ```
 
 # Conclusion
 And that's it! You can verify the LAG interface and MAC learning for the newly created LAG as follows:
 ```
 /show lag lag${PORT}
 /show network-instance mac-vrf-lag${PORT} bridge-table mac-table mac
 ```
