# Goals
#   1. Have two networks with each has their own DHCP server
#   2. Allow one node from one network to access every node in the other. (VPN)

cleanup() {
  sudo ip netns del A-router 2> /dev/null
  sudo ip netns del A-node 2> /dev/null
}

cleanup

# Create containers: A1 and A2 belongs to network A
# B3 and B4 belongs to network B
sudo ip netns add A-router
sudo ip netns add A-node

# Routers have bridges to join the networks via veth pairs
sudo ip netns exec A-router brctl addbr bridge0
# Bring bridge interface up
sudo ip netns exec A-router ifconfig bridge0 "10.0.3.1/24" up
sudo ip netns exec A-router ip route flush dev bridge0
sudo ip netns exec A-router ip route add "10.0.3.0/24" dev bridge0

# Setting up dhcp using `dnsmasq`
sudo ip netns exec A-router dnsmasq \
  --dhcp-range=10.0.3.2,10.0.3.254,255.255.255.0 --interface=bridge0

# Linking A-router and A-node
sudo ip netns exec A-router ip link add eth0 type veth peer name veth0
sudo ip netns exec A-router ip link set veth0 up
sudo ip netns exec A-router ip link set eth0 netns A-node
sudo ip netns exec A-router brctl addif bridge0 veth0

# Get an address from the dhcp server using `dhclient`
sudo ip netns exec A-node ip link set eth0 up
sudo ip netns exec A-node dhclient -v eth0
