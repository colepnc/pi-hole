# Set your static IP information in the variables below
ip="192.168.1.22/24"
gateway="192.168.1.1"
dns="192.168.1.2"
# Start the script proper
# Update Ubuntu before starting pi-hole install, and install cron-apt for maintenance purposes
apt-get update
apt-get dist-upgrade -y
apt-get install cron-apt php-zip -y
# Set static IP, this may need changed if using ipv6
sed -i -e 's/dhcp4: yes/dhcp4: no/g' /etc/netplan/01-netcfg.yaml
echo "      addresses: [$ip]" >> /etc/netplan/01-netcfg.yaml
echo "      gateway4: $gateway" >> /etc/netplan/01-netcfg.yaml
echo "      nameservers:" >> /etc/netplan/01-netcfg.yaml
echo "       addresses: [$dns]" >> /etc/netplan/01-netcfg.yaml
netplan apply
sleep 30
reboot
