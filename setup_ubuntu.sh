#!/bin/bash

# Update Sama install DHCP server
sudo apt update && sudo apt install -y isc-dhcp-server iptables-persistent

# Konfigurasi VLAN
echo "Mengkonfigurasi VLAN..."
sudo bash -c 'cat > /etc/netplan/01-netcfg.yaml' << EOF
network:
  version: 2
  ethernets:
    eth0:
      dhcp4: no
  vlans:
    eth0.10:
      id: 10
      link: eth0
      addresses: [192.168.6.1/24]
      dhcp4: no
EOF

# Konfigurasi Netplan
sudo netplan apply

# Konfigurasi DHCP
echo "Mengkonfigurasi DHCP..."
sudo bash -c 'cat > /etc/dhcp/dhcpd.conf' << EOF
subnet 192.168.6.0 netmask 255.255.255.0 {
  range 192.168.6.10 192.168.6.100;
  option routers 192.168.6.1;
  option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOF

# Restart DHCP Server
sudo systemctl restart isc-dhcp-server

# Aktifin IP forwarding
echo "Mengaktifkan IP forwarding..."
sudo sysctl -w net.ipv4.ip_forward=1
sudo bash -c 'echo "net.ipv4.ip_forward=1" >> /etc/sysctl.conf'

# Konfigurasi NAT biar client dapat akses internet
echo "Mengkonfigurasi NAT..."
sudo iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
sudo netfilter-persistent save

echo "Konfigurasi Ubuntu Server suksess WELL."
