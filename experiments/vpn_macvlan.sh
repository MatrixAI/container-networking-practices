# Goals
#   1. Have two networks with each has their own DHCP server
#   2. Allow one node from one network to access every node in the other. (VPN)

# Clean up
cleanup() {
  ip netns exec A-node dhclient -r -v
  kill -9 $(ps -eopid,cmd | grep dnsmasq | cut -f 2 -d ' ' | head -n -1) 2> /dev/null
  kill -9 $(ps -eopid,cmd | grep dhclient | cut -f 2 -d ' ' | head -n -1) 2> /dev/null
  ip netns del A-router 2> /dev/null
  ip netns del A-node 2> /dev/null
  ip netns del B-node 2> /dev/null
}

# configure network A

  cleanup

  # Create namespaces for network A
  ip netns add A-router
  ip netns add A-node
  ip netns add B-node

  # Routers have bridges to join the networks via veth pairs
  ip netns exec A-router ip link add a-router-br0 type bridge
  # Bring bridge interface up
  ip netns exec A-router ip addr add "10.0.3.1/24" dev a-router-br0
  ip netns exec A-router ip link set a-router-br0 up
  ip netns exec A-router ip route flush dev a-router-br0
  ip netns exec A-router ip route add "10.0.3.0/24" dev a-router-br0

  # Setting up dhcp using `dnsmasq`
  ip netns exec A-router dnsmasq \
    --dhcp-range=10.0.3.3,10.0.3.254,255.255.255.0 --interface=a-router-br0

  # Linking A-router and A-node
  ip netns exec A-router ip link add veth0 type veth peer name veth1
  ip netns exec A-router ip link set veth1 up
  ip netns exec A-router ip link set veth0 netns A-node
  ip netns exec A-router ip link set dev veth1 master a-router-br0

  # Get an address from the dhcp server using `dhclient`
  ip netns exec A-router ip link set lo up
  ip netns exec A-node ip link set veth0 up
  ip netns exec A-node dhclient -v veth0

# configure network B
  ip netns exec A-router ip link add mvlan0 \
                            type macvlan mode vepa
  ip netns exec A-router ip link set mvlan0 netns B-node
  ip netns exec B-node ip link set mvlan0 up
  ip netns exec B-node dhclient -v mvlan0
