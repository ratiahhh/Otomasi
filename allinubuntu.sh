#!/bin/bash

# 🛠 VINCENT AUTOMATION SCRIPT 🛠
# Untuk konfigurasi Ubuntu Server, Cisco Switch, dan Mikrotik
# By Vincent

echo "==============================="
echo "       🔥 VINCENT SCRIPT 🔥       "
echo "==============================="

# 🌟 STEP 1: Konfigurasi di Ubuntu Server 🌟
echo "Configuring Ubuntu Server..."
sudo apt update && sudo apt upgrade -y
sudo apt install -y isc-dhcp-server vlan net-tools iptables-persistent

# VLAN Configuration
echo "Setting up VLAN interface eth1.10..."
sudo ip link add link eth1 name eth1.10 type vlan id 10
sudo ip addr add 192.168.6.1/24 dev eth1.10
sudo ip link set eth1.10 up

# DHCP Server Configuration
echo "Configuring DHCP Server..."
sudo bash -c 'cat <<EOF > /etc/dhcp/dhcpd.conf
subnet 192.168.6.0 netmask 255.255.255.0 {
  range 192.168.6.100 192.168.6.200;
  option routers 192.168.6.1;
  option domain-name-servers 8.8.8.8;
}
EOF'

sudo sed -i 's/INTERFACESv4=""/INTERFACESv4="eth1.10"/g' /etc/default/isc-dhcp-server
sudo systemctl restart isc-dhcp-server
sudo systemctl enable isc-dhcp-server

# Enable IP Forwarding and NAT
echo "Enabling IP Forwarding and NAT..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo iptables-save | sudo tee /etc/iptables/rules.v4

# Test connection
echo "Testing Internet connection..."
ping -c 4 8.8.8.8

echo "Ubuntu Server configuration completed!"
echo "==============================="

# 🌟 STEP 2: Cisco Switch Configuration 🌟
echo "Copy the following configuration to your Cisco Switch CLI:"
echo "
enable
configure terminal
vlan 10
name VINCENT_VLAN
interface Ethernet0/1
switchport mode access
switchport access vlan 10
end
wr
"
echo "==============================="

# 🌟 STEP 3: Mikrotik Configuration 🌟
echo "Copy the following configuration to your Mikrotik Router CLI:"
echo "
/system identity set name=\"Vincent-Router\"
/ip address add address=192.168.6.2/24 interface=ether1
/ip address add address=192.168.200.1/24 interface=ether2
/ip route add dst-address=0.0.0.0/0 gateway=192.168.6.1
/ip dhcp-relay add name=relay interface=ether1 dhcp-server=192.168.6.1 local-address=192.168.6.2
/ping 8.8.8.8 count=4
/system script run [system script find name=\"save-config\"]
"
echo "==============================="

# Selesai
echo "🔥 All configurations are completed! 🔥"
echo "Make sure to verify the setup for DHCP and Internet connectivity on the client devices."
