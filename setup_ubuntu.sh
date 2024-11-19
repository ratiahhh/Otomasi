#!/bin/bash

# Fungsi cetak teks di tengah layar
print_center() {
  termwidth=$(tput cols)
  padding=$(printf '%0.1s' " "{1..500})
  while IFS= read -r line; do
    printf '%*.*s%s\n' 0 $(((termwidth - ${#line}) / 2)) "$padding" "$line"
  done <<< "$1"
}

# ASCII Art dari input
ascii_art="
 ____      ____ ____ _____   ______        _____       ______ _____   ______  _________________ 
|    |    |    |    |\    \ |\     \   ___|\    \  ___|\     |\    \ |\     \/                 \
|    |    |    |    |\\    \| \     \ /    /\    \|     \     \\    \| \     \______     ______/
|    |    |    |    | \|    \  \     |    |  |    |     ,_____/\|    \  \     | \( /    /  )/   
|    |    |    |    |  |     \  |    |    |  |____|     \--'\_|/|     \  |    |  ' |   |   '    
|    |    |    |    |  |      \ |    |    |   ____|     /___/|  |      \ |    |    |   |        
|\    \  /    /|    |  |    |\ \|    |    |  |    |     \____|\ |    |\ \|    |   /   //        
| \ ___\/___ / |____|  |____||\_____/|\ ___\/    /|____ '     /||____||\_____/|  /___//         
 \ |   ||   | /|    |  |    |/ \|   || |   /____/ |    /_____/ ||    |/ \|   || |`   |          
  \|___||___|/ |____|  |____|   |___|/\|___|    | |____|     | /|____|   |___|/ |____|          
    \(    )/     \(      \(       )/    \( |____|/  \( |_____|/   \(       )/     \(            
     '    '       '       '       '      '   )/      '    )/       '       '       '            
                                             '            '                                     
"

# Clear screen and display ASCII art
clear
print_center "$ascii_art"
print_center "           TAMPIL KECE 😹 VINCENT              "
print_center "+-------------------------------------------+"
print_center "|            CONFIGURE UBUNTU 20.04         |"
print_center "|       DHCP + VLAN + NAT + Kartolo         |"
print_center "+-------------------------------------------+"
print_center ""

echo "Halo Vincent! Siap setup Ubuntu gaya hacker elite? Let's go! 😹"

# Pastikan skrip dijalankan dengan sudo
if [[ $EUID -ne 0 ]]; then
   echo "Jalankan skrip ini sebagai root atau dengan sudo. 😹"
   exit 1
fi

# Konfigurasi jaringan
echo "Mengkonfigurasi IP, VLAN, dan NAT..."
cat <<EOF > /etc/netplan/01-netcfg.yaml
network:
  version: 2
  renderer: networkd
  ethernets:
    eth1:
      dhcp4: no
      addresses:
        - 192.168.6.1/24
  vlans:
    eth1.10:
      id: 10
      link: eth1
      addresses:
        - 192.168.10.1/24
EOF

netplan apply

# Install DHCP server
echo "Menginstal DHCP server... 😹"
apt update
apt install -y isc-dhcp-server

cat <<EOT > /etc/dhcp/dhcpd.conf
subnet 192.168.6.0 netmask 255.255.255.0 {
    range 192.168.6.50 192.168.6.100;
    option routers 192.168.6.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}

subnet 192.168.10.0 netmask 255.255.255.0 {
    range 192.168.10.50 192.168.10.100;
    option routers 192.168.10.1;
    option domain-name-servers 8.8.8.8, 8.8.4.4;
}
EOT

# DHCP server untuk eth1
sed -i 's/INTERFACESv4=""/INTERFACESv4="eth1 eth1.10"/' /etc/default/isc-dhcp-server

# Forwarding dan NAT
echo 1 > /proc/sys/net/ipv4/ip_forward
sed -i 's/#net.ipv4.ip_forward=1/net.ipv4.ip_forward=1/' /etc/sysctl.conf
iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
iptables-save > /etc/iptables/rules.v4

# Tambahkan Kartolo repo
echo "Nambah Kartolo Repo... 😹"
cat <<EOF >> /etc/apt/sources.list
# Kartolo Repo untuk Ubuntu 20.04
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-updates main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-security main restricted universe multiverse
deb http://kartolo.sby.datautama.net.id/ubuntu/ focal-backports main restricted universe multiverse
EOF

# Update sistem
echo "Update sistem nganggo repo Kartolo... 😹"
apt update

# Restart layanan
echo "Restarting networking dan DHCP services... 😹"
systemctl restart isc-dhcp-server

echo "Konfigurasi rampung, Vincent! Sekarang jaringannya udah siap tempur! 😹"
