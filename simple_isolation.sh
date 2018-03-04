# The goal of this script is to:
#   1. Have a VM with 3 containers
#   2. container 1 is routable publically
#   3. container 2 and 3 can only talk to each other.

# Clean up

cleanup() {
  # Clean up namespaces
  sudo ip netns delete cont1 || true
  sudo ip netns delete cont2 || true
  sudo ip netns delete cont3 || true

  # Clean up host bridges
  sudo ifconfig bridge0 down
  sudo brctl delbr bridge0

  echo successful cleanup
}

cleanup

export HOST_BRIDGE0_IP="10.0.3.1/24"
export CONT1_ETH0_IP="10.0.3.2/24"
export CONT2_BRIDGE0_IP="10.0.4.1/24"
export CONT3_ETH0_IP="10.0.4.2/24"

# Create network namespaces for container 1, 2 and 3.
sudo ip netns add cont1
sudo ip netns add cont2
sudo ip netns add cont3

# Create a bridge to be used at host vm
sudo brctl addbr bridge0
sudo ifconfig bridge0 "$HOST_BRIDGE0_IP" up

# Create a link between host and cont1
sudo ip netns exec cont1 ip link add veth0 type veth peer name eth0
sudo ip netns exec cont1 ifconfig eth0 "$CONT1_ETH0_IP" up
sudo ip netns exec cont1 ip link set veth0 netns 1
sudo ifconfig veth0 up
sudo brctl addif bridge0 veth0

echo link between host and cont1 set

# Create a bridge to be used at cont2
sudo ip netns exec cont2 brctl addbr bridge0
sudo ip netns exec cont2 ifconfig bridge0 "$CONT2_BRIDGE0_IP" up

# Create a link between cont2 and cont3
sudo ip netns exec cont3 ip link add veth0 type veth peer name eth0
sudo ip netns exec cont3 ifconfig eth0 "$CONT3_ETH0_IP" up
sudo ip netns exec cont3 ip link set veth0 netns cont2
sudo ip netns exec cont2 ifconfig veth0 up
sudo ip netns exec cont2 brctl addif bridge0 veth0

echo link between cont2 and cont3 set
