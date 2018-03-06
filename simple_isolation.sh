# The goal of this script is to:
#   1. Have a VM with 3 containers
#   2. container 1 is routable publically
#   3. container 2 and 3 can only talk to each other.

# Clean up

cleanup() {
  # Clean up namespaces
  sudo ip netns delete cont1 2> /dev/null
  sudo ip netns delete cont2 2> /dev/null
  sudo ip netns delete cont3 2> /dev/null

  echo successfully cleaned up namespaces
}

cleanup

export NS0_VETH0_IP="10.0.3.1/24"
export NS1_VETH1_IP="10.0.3.2/24"
export NS2_VETH0_IP="10.0.4.1/24"
export NS3_VETH1_IP="10.0.4.2/24"

# Create network namespaces for container 1, 2 and 3.
sudo ip netns add cont1
sudo ip netns add cont2
sudo ip netns add cont3


# Create a link between host and cont1
sudo ip netns exec cont1 ip link add veth0 type veth peer name veth1
sudo ip netns exec cont1 ifconfig veth1 "$NS1_VETH1_IP" up
sudo ip netns exec cont1 ip link set veth0 netns 1
sudo ifconfig veth0 "$NS0_VETH0_IP" up

echo link between host and cont1 set

# Create a link between cont2 and cont3
sudo ip netns exec cont3 ip link add veth0 type veth peer name veth1
sudo ip netns exec cont3 ifconfig veth1 "$NS3_VETH1_IP" up
sudo ip netns exec cont3 ip link set veth0 netns cont2
sudo ip netns exec cont2 ifconfig veth0 "$NS2_VETH0_IP" up

echo link between cont2 and cont3 set
