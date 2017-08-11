# Set your static IP information in the variables below
ip="192.168.14.8"
netmask="255.255.255.0"
gateway="192.168.14.1"
dns="192.168.14.6"
# Start the script proper
# Update Ubuntu before starting pi-hole install, and install cron-apt/htop for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt htop -y
apt-get install linux-virtual-lts-xenial -y
apt-get install linux-tools-virtual-lts-xenial -y
apt-get install linux-cloud-tools-virtual-lts-xenial -y
# Disable ipv6 on all interfaces, remove if your network is actually using ipv6
echo "net.ipv6.conf.all.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.default.disable_ipv6 = 1" >> /etc/sysctl.conf
echo "net.ipv6.conf.lo.disable_ipv6 = 1" >> /etc/sysctl.conf
sysctl -p
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
iptables -A INPUT -p tcp -m tcp --dport 443 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 80 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 22 -j ACCEPT
iptables -A INPUT -p udp -m udp --dport 53 -j ACCEPT
iptables -A INPUT -p tcp -m tcp --dport 53 -j ACCEPT
iptables -A INPUT -j DROP
# Iptables persistance through reboot
su -c "iptables-save > /etc/iptables.conf"
sed -i "13i iptables-restore < /etc/iptables.conf" /etc/rc.local
reboot
