# setup network namespaces for server and client
ip netns add net_server
ip netns add net_client

# create veth devices and assign ip addresses
ip link add veth1 netns net_server type veth peer name veth2 netns net_client
ip netns exec net_server ip addr add 10.96.189.98/24 dev veth1
ip netns exec net_client ip addr add 10.96.189.99/24 dev veth2


# bring devices up
ip netns exec net_server ip link set veth1 up
ip netns exec net_client ip link set veth2 up

# setup dns server on net_server with static route for qotd.server
ip netns exec net_server dnsmasq -d -A /qotd.server/10.96.189.98 &
# configure net_client to use dns server on net_server
sudo mkdir -p /etc/netns/net_client/
echo "nameserver 10.96.189.98" | sudo tee /etc/netns/net_client/resolv.conf

# run wireshark on client namespace
ip netns exec net_client wireshark &
echo "waiting for input"
read 

# run server & client to perform 1 qotd request
ip netns exec net_server /usr/local/lib/sdkman/candidates/java/current/bin/java -cp server/bin/main sc2008_lab.App &
ip netns exec net_client /usr/local/lib/sdkman/candidates/java/current/bin/java -cp client/bin/main sc2008_lab.App

# wait for user input, then cleanup
echo "waiting for input"
read 
# kill server & wireshark & dns server
kill %1
kill %2
kill %3
# delete network namespaces
ip netns delete net_server
ip netns delete net_client
sudo rm -rf  /etc/netns/net_client/
