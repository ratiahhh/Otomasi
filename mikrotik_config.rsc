# Script Otomatisasi
/system script add name=autoConfig source={
    /ip route add dst-address=192.168.6.50/0 gateway=192.168.6.1
    /ip dhcp-client add interface=eth2 disabled=no
}

# Jadwal Script Biar Otomatis Waktu Startup
/system scheduler add name=runAutoConfig on-event=autoConfig start-time=startup

