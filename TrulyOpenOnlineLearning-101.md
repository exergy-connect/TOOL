# A sample scenario based on [Ivan Pepelnjak's Katacoda example](https://katacoda.com/ipspace/scenarios/netsim-containerlab-101)

1. Follow the [Setup](https://github.com/exergy-connect/TOOL/wiki/Setup) instructions to open an SSH session to a server you control

2. Validate that the environment provides sufficient resources for this exercise:
```
curl -s https://raw.githubusercontent.com/exergy-connect/TOOL/main/check_resources.sh | \
bash -s -- --memory_mb=1024 --cpus=1 --disk_mb=1024
```
3. Install Netsim tools and Ansible 2.9
```
git clone https://github.com/ipspace/netsim-tools/ && pip3 install -r netsim-tools/requirements.txt --ignore-installed && \
pip3 install ansible==2.9
```

4. Install Containerlab
```
sudo bash -c "$(curl -sL https://get-clab.srlinux.dev)"
```

5. Set PATH
```
export PATH="netsim-tools:$PATH"
```

6. Create the topology & launch the lab
```
create-topology -t frr-topology.yml -p -i -c && sudo containerlab deploy -t clab.yml
```

7. Configure the routers
```
initial-config.ansible -t initial && initial-config.ansible -t module -v
```

8. Connect to R2
```
connect.sh r2
```

9. Inspect its state, etc.
```
ip link
```
```
ip addr
```
