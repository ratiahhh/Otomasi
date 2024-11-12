# Buat script otomatisasi dengan konfigurasi yang diinginkan
/system script add name=autoConfig source={
    /ip route add dst-address=192.168.6.100/0 gateway=192.168.6.1
    /ip dhcp-client add interface=eth2 disabled=no
}

# Jadwalkan script untuk berjalan otomatis saat startup
/system scheduler add name=runAutoConfig on-event=autoConfig start-time=startup

