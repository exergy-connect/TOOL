# SR Linux EVPN based Multi-Chassis LAG configuration

SR Linux supports link aggregation across multiple (up to 4) leaves, using BGP EVPN Multi-Homing for synchronizing state (like signalling MAC addresses).

The following CLI snippets configure a pair of SR Linux Leaves for BGP EVPN MC-LAG, assuming the underlay with EVPN peering is already setup.
Before you start, you can select the interface to work on by annotating with its relative ID.

For ethernet-1/3:
```
enter candidate
/interfaces !!! 3
commit now
```
For ethernet-1/4:
```
enter candidate
/interfaces !!! 4
commit now
```
(etc.)

