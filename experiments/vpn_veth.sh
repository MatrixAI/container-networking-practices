# Goals
#   1. Have two networks with each has their own DHCP server
#   2. Allow one node from one network to access every node in the other. (VPN)

# Clean up
cleanup() {
  ip netns del A-router 2> /dev/null
  ip netns del A-node 2> /dev/null
  ip netns del B-router 2> /dev/null
}

# configure network A

  cleanup

  # Create namespaces for network A
  ip netns add A-router
  ip netns add A-node
  ip netns add B-router

  # Routers have bridges to join the networks via veth pairs
  ip netns exec A-router brctl addbr bridge0
  # Bring bridge interface up
  ip netns exec A-router ifconfig bridge0 "10.0.3.1/24" up
  ip netns exec A-router ip route flush dev bridge0
  ip netns exec A-router ip route add "10.0.3.0/24" dev bridge0

  # Setting up dhcp using `dnsmasq`
  ip netns exec A-router dnsmasq \
    --dhcp-range=10.0.3.3,10.0.3.254,255.255.255.0 --interface=bridge0

  # Linking A-router and A-node
  ip netns exec A-router ip link add eth0 type veth peer name veth0
  ip netns exec A-router ip link set veth0 up
  ip netns exec A-router ip link set eth0 netns A-node
  ip netns exec A-router brctl addif bridge0 veth0

  # Get an address from the dhcp server using `dhclient`
  ip netns exec A-node ip link set eth0 up
  ip netns exec A-node dhclient -v eth0

# configure network B
  ip netns exec B-router brctl addbr bridge0
  ip netns exec B-router ifconfig bridge0 "10.0.4.0/24" up

# configure router

  # Set up a default gateway for A-router
  ip netns exec A-router ip link add eth0 type veth peer name veth2

  # Bring up the devices
  ip netns exec A-router ifconfig eth0 "10.0.5.1" up # Gateway
  ip netns exec A-router ip link set veth2 netns B-router
  ip netns exec B-router ip link set veth2 up
  ip netns exec B-router brctl addif bridge0 veth2

  # Set A-route's default gateway to "10.0.5.1"
  ip netns exec A-router ip route add default via "10.0.5.1"

  # Configure NAT and port forwarding
  sysctl net.ipv4.conf.all.forwarding=1
  ip netns exec A-router iptables --flush
  ip netns exec A-router iptables --flush
  ip netns exec A-router iptables --table nat --flush
  ip netns exec A-router iptables --table nat --delete-chain


  ip netns exec A-router iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
