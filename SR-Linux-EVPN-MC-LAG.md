# SR Linux EVPN based Multi-Chassis LAG configuration

SR Linux supports link aggregation across multiple (up to 4) leaves, using BGP EVPN Multi-Homing for synchronizing state (like signalling MAC addresses).

The following CLI snippets configure a pair of SR Linux Leaves for BGP EVPN MC-LAG, assuming the underlay with EVPN peering is already setup.
Before you start, configure an environment variable with the port number (using a CLI extension)

For ethernet-1/3:
```
${PORT|3}
```
For ethernet-1/4:
```
${PORT|4}
```
(etc.)

## Creating a Link Aggregation Interface (LAG)

The number of LAG interfaces depends on the SR Linux hardware platform: 
lag\<N\> where N=1..32 for 7220-D1, 7220-D2, 7220-D3. N=1..127 for 7220-H2, 7220-H3

```
/interface lag${PORT}
admin-state enable
    vlan-tagging true
    subinterface 0 {
        type bridged
        vlan {
            encap {
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
