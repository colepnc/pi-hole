# Set your static IP information in the variables below
# Make sure to run "crontab -e" and add "0 7 * * * pihole -up"
# To install pi-hole after this script: "curl -sSL https://install.pi-hole.net | bash"
# Import "https://raw.githubusercontent.com/pointandclicktulsa/pi-hole/master/teleport_with_porn.zip" for porn blocking
# aka clients with no paid OpenDNS. "https://raw.githubusercontent.com/pointandclicktulsa/pi-hole/master/teleport.zip" to exclude porn blocking.
# Also run "https://raw.githubusercontent.com/pointandclicktulsa/pi-hole/master/BlockPage.sh" to make the blocking more user-friendly
# Make sure to customize '/var/phbp.ini' then "sudo service lighttpd force-reload" for the client.
ip="192.168.1.22"
netmask="255.255.255.0"
gateway="192.168.1.1"
dns="192.168.1.1"
# Start the script proper
# Update Ubuntu before starting pi-hole install, and install cron-apt/htop for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt htop -y
apt-get install linux-virtual-lts-xenial -y
apt-get install linux-tools-virtual-lts-xenial -y
apt-get install linux-cloud-tools-virtual-lts-xenial -y
apt-get install php-zip -y
# Set static IP, this may need changed if using ipv6
sed -i -e 's/iface eth0 inet dhcp/#iface eth0 inet dhcp/g' /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
echo "address $ip" >> /etc/network/interfaces
echo "netmask $netmask" >> /etc/network/interfaces
echo "gateway $gateway" >> /etc/network/interfaces
echo "dns-nameservers $dns" >> /etc/network/interfaces
# Iptables hardening to only allow the ports you need
iptables -F
iptables -P INPUT DROP
iptables -A INPUT -i lo -p all -j ACCEPT
iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -j DROP
# Iptables persistance through reboot
su -c "iptables-save > /etc/iptables.conf"
sed -i "13i iptables-restore < /etc/iptables.conf" /etc/rc.local
reboot
