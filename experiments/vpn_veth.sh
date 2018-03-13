# Goals
#   1. Have two networks with each has their own DHCP server
#   2. Allow one node from one network to access every node in the other. (VPN)

# Clean up
cleanup() {
  # Clean lease files for dhclient
  rm /var/lib/dhcp/dhclient.*
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
  ip netns exec A-router ip link add bridge0 type bridge
  # Bring bridge interface up
  ip netns exec A-router ip addr add "10.0.3.1/24" dev bridge0
  ip netns exec A-router ip link set bridge0 up
  ip netns exec A-router ip route flush dev bridge0
  ip netns exec A-router ip route add "10.0.3.0/24" dev bridge0

  # Setting up dhcp using `dnsmasq`
  ip netns exec A-router dnsmasq \
    --dhcp-range=10.0.3.3,10.0.3.254,255.255.255.0 --interface=bridge0

  # Linking A-router and A-node
  ip netns exec A-router ip link add eth0 type veth peer name veth0
  ip netns exec A-router ip link set veth0 up
  ip netns exec A-router ip link set eth0 netns A-node
  ip netns exec A-router ip link set dev veth0 master bridge0

  # Get an address from the dhcp server using `dhclient`
  ip netns exec A-node ip link set eth0 up
  ip netns exec A-node dhclient -v eth0

# configure network B
  ip netns exec B-node ip link add eth0 type veth peer name veth1
  ip netns exec B-node ip addr add "10.0.4.2/24" dev eth0
  ip netns exec B-node ip link set eth0 up
  ip netns exec B-node ip link set veth1 netns A-router

  # Set the default gateway for B-node
  ip netns exec B-node ip route add default via "10.0.4.1" dev eth0

# configure A-router
  ip netns exec A-router ip addr add "10.0.4.1/24" dev veth1
  ip netns exec A-router ip link set veth1 up

  # Configure NAT and port forwarding
  sysctl net.ipv4.conf.all.forwarding=1
  ip netns exec A-router iptables --flush
  ip netns exec A-router iptables --table nat --flush
  ip netns exec A-router iptables --table nat --delete-chain

  ip netns exec A-router iptables -t nat -A POSTROUTING -o bridge0 -j MASQUERADE
  ip netns exec A-router iptables -A FORWARD -i bridge0 -o veth1 -j ACCEPT
  ip netns exec A-router iptables -A FORWARD -o bridge0 -i veth1 -j ACCEPT
