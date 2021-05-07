# Start the script proper
# Update Ubuntu before starting pi-hole install, and install cron-apt/htop for maintenance purposes
apt update
apt dist-upgrade -y
apt install cron-apt htop php-zip -y
# Disable ipv6 on all interfaces, remove if your network is actually using ipv6
sed -i 's/GRUB_CMDLINE_LINUX_DEFAULT="[^"]*/&ipv6.disable=1/' /etc/default/grub
update-grub
# Firewall config
ufw --force enable
ufw default deny incoming
ufw default allow outgoing
ufw allow ssh/tcp
ufw allow http/tcp
ufw allow https/tcp
ufw allow 53/tcp
ufw allow 53/udp
reboot
