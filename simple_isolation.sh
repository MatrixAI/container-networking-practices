# The goal of this script is to:
#   1. Have a VM with 3 containers
#   2. container 1 is routable publically
#   3. container 2 and 3 can only talk to each other.

env HOST_BRIDGE_IP="10.0.3.0/24"
env CONT1_HOST_IP="10.0.3.1/24"
env CONT1_BRIDGE_IP="10.0.4.0/24"
env CONT2_CONT1_IP="10.0.4.1/24"
env CONT3_CONT1_IP="10.0.4.2/24"

# Create network namespaces for container 1, 2 and 3.
sudo ip netns add cont1
sudo ip netns add cont2
sudo ip netns add cont3

# Create a bridge to be used at host vm
sudo brctl addbr bridge0
sudo ifconfig bridge0 "10.0.3.0/24" up

creat_pair() {
  THIS_NS=$1 # Namespace of which the veth pair should be created
  OTHER_NS=$1 # Namespace of whcih the veth pair is joining to
  VETH0_NAME=$2 # name of the veth pair that stays in THIS_NS
  VETH1_NAME=$3 # name of the veth pair that is passed to OTHER_NS

  # Create a veth pair to be used in between host and cont1
  sudo ip netns exec $THIS_NS ip link add veth0 type veth peer name eth0
  # Configure addresses, namespaces and fire them up
  sudo ip netns exec $THIS_NS ifconfig eth0 "$CONT1_HOST_IP" up
  sudo ip netns exec $THIS_NS ip link set veth0 netns $OTHER_NS
  sudo ip netns exec $OTHER_NS ip link set veth0 up

  # Connect veth0 to the bridge
  sudo ip netns exec $OTHER_NS brctl addif bridge0 veth0
}

join_pair()


sudo ip link add veth0 type veth peer name
