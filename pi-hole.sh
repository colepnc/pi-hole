# Set your static IP information in the variables below
ip="192.168.1.3"
netmask="255.255.255.0"
gateway="192.168.1.1"
dns="192.168.1.2"
# Start the script proper
# Update Ubuntu before starting pi-hole install, and install cron-apt/htop for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt htop linux-virtual-lts-xenial linux-tools-virtual-lts-xenial linux-cloud-tools-virtual-lts-xenial php-zip -y
# Set static IP, this may need changed if using ipv6
sed -i -e 's/iface eth0 inet dhcp/#iface eth0 inet dhcp/g' /etc/network/interfaces
echo "iface eth0 inet static" >> /etc/network/interfaces
echo "address $ip" >> /etc/network/interfaces
echo "netmask $netmask" >> /etc/network/interfaces
echo "gateway $gateway" >> /etc/network/interfaces
echo "dns-nameservers $dns" >> /etc/network/interfaces
# Firewall config
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh/tcp
ufw allow http/tcp
ufw allow 53/tcp
ufw allow 53/udp
reboot
