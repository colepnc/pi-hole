# Begin log file, this will be placed on the client the script is being run from, do not modify unless you want to disable logging
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\Pi-Hole.txt -append

# Script variables, change as needed
# If you want to run this against a remote Hyper-V host, change $ServerName to a proper computer name.
# If you have multiple External vSwitches you'll probably also have to manually input the name of the desired vSwitch in $VMSwitch
$ISO = "C:\admin\iso\ubuntu-16.04.3-server-amd64.iso"
$ISOPath = "c:\admin\ISO\"
$VMName = "Pi-Hole"
$VHDpath = "c:\Hyper-V\$VMName.vhdx"
$ServerName = "$env:computername"
$VMSwitch = Get-VMSwitch -SwitchType External |
              Select-Object -First 1 |
              ForEach-Object Name

# Test for ISO folder existence
If (!(Test-Path $ISOpath) -And !(Test-Path "C:\admin\ISOs\")) {
New-Item -Path $ISOpath -ItemType Directory
}
else {
echo "ISO directory already exists!"
}

# Download Ubuntu ISO
If (!(Test-Path $ISO)) {
echo "Downloading Ubuntu Server 16.04.3 LTS ISO"
Invoke-WebRequest "http://releases.ubuntu.com/16.04.3/ubuntu-16.04.3-server-amd64.iso" -UseBasicParsing -OutFile "$ISO"
}
else {
echo "Ubuntu Server 16.04.3 LTS ISO already exists!"
}

# Create VHDX, VM, attach vSwitch, mount Ubuntu ISO
New-VHD -Path $VHDpath -SizeBytes 20GB -Fixed
New-VM -Name $VMName -MemoryStartupBytes 2048MB -Generation 2
Set-VMMemory -VMName pi-hole -DynamicMemoryEnabled 0
Add-VMHardDiskDrive -VMName $VMName -Path $VHDpath
Add-VMDvdDrive -VMName $VMName
Set-VMDvdDrive -VMName $VMName -Path $ISO
$dvd = Get-VMDvdDrive -VMName $VMName
if ($VMSwitch -ne $null) {
  Get-VMNetworkAdapter -VMName $VMName |
    Connect-VMNetworkAdapter -SwitchName $VMSwitch
}
Set-VMFirmware -VMName $VMName -EnableSecureBoot Off -FirstBootDevice $dvd
Set-VM -Name $VMName -CheckpointType Production -AutomaticStartAction Start -AutomaticCheckpointsEnabled 0
Set-VMProcessor -VMName $VMName -Count 4

# Start and connect to VM
Start-VM -Name $VMName
vmconnect $ServerName $VMName

echo "Configure Ubuntu unencrypted, with automatic security updates and OpenSSH server, hostname pi-hole, username pi-hole. Inside the VM, run Pi-Hole.sh first
 (wget and chmod +x the two scripts, also download the appropriate teleport.zip)
 After Pi-Hole.sh install Pi-Hole 'curl -sSL https://install.pi-hole.net | bash'
 Then run BlockPage.sh
 Customize files for the Blocking page as needed 'sudo nano /var/phbp.ini' then 'sudo service lighttpd force-reload'
 Import the appropritae teleport.zip
 Create crontab job to update Pi-Hole 'crontab -e' '0 7 * * * pihole -up'
 Run 'pihole -g'
 Set the domain controller to forward to the Pi-Hole.
 Relevant links to wget:
 https://raw.githubusercontent.com/pointandclicktulsa/pi-hole/master/Pi-Hole.sh
 https://raw.githubusercontent.com/pointandclicktulsa/pi-hole/master/BlockPage.sh
 Relevant to download on Hyper-V host or management PC:
 https://github.com/pointandclicktulsa/pi-hole/raw/master/teleport.zip
 https://github.com/pointandclicktulsa/pi-hole/raw/master/teleport_with_porn.zip

 add lists to adlist.list 'sudo nano /etc/pihole/adlists.list' remove the porn tracker at bottom if it needs removed.
 
##from https://v.firebog.net/hosts/lists.php?type=tick, blocks everything and porn! This is the verified false
##positive free list
https://hosts-file.net/grm.txt
https://reddestdream.github.io/Projects/MinimalHosts/etc/MinimalHostsBlocker/minimalhosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/KADhosts/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Spam/hosts
https://v.firebog.net/hosts/static/w3kbl.txt
https://adaway.org/hosts.txt
https://v.firebog.net/hosts/AdguardDNS.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_ad.txt
https://hosts-file.net/ad_servers.txt
https://v.firebog.net/hosts/Easylist.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/SpotifyAds/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/UncheckyAds/hosts
https://v.firebog.net/hosts/Airelle-trc.txt
https://gist.githubusercontent.com/CHEF-KOCH/080efada22b9659ef61241029122873b/raw/7f9bd984d3c46b3dba2de7606da579bc0ac6780c/Canvas%2520Font%2520Fingerprinting%2520pages%2520%255B2017%2520Edition%255D
https://gist.githubusercontent.com/CHEF-KOCH/5a7b1593d1880f906b12a3c87cee4500/raw/3ba028508feb2ef67a3d7ab75f428fd284223e8b/WebRTC%2520tracking%2520list%2520%255B2017%2520Edition%255D.txt
https://gist.githubusercontent.com/CHEF-KOCH/63fd2e506cb34a2378ad2620ab06d2e0/raw/fb9f16e3ac998d3f773ebdfee4aa3bfd10a5d763/Audio%2520fingerprint%2520pages%2520%255B2017%2520Edition.exe
https://gist.githubusercontent.com/CHEF-KOCH/2dea75d43b2184f228ae94b168d275b1/raw/35d7a4447a198449bbb3280e1c3d7a57517350de/Canvas%2520fingerprinting%2520pages%2520%255B2017%2520Edition%255D.exe
https://v.firebog.net/hosts/Easyprivacy.txt
https://v.firebog.net/hosts/Prigent-Ads.txt
https://raw.githubusercontent.com/quidsup/notrack/master/trackers.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.2o7Net/hosts
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/tyzbit/hosts
https://v.firebog.net/hosts/Airelle-hrsk.txt
https://s3.amazonaws.com/lists.disconnect.me/simple_malvertising.txt
https://mirror1.malwaredomains.com/files/justdomains
https://hosts-file.net/exp.txt
https://hosts-file.net/emd.txt
https://hosts-file.net/psh.txt
https://mirror.cedia.org.ec/malwaredomains/immortal_domains.txt
https://www.malwaredomainlist.com/hostslist/hosts.txt
https://bitbucket.org/ethanr/dns-blacklists/raw/8575c9f96e5b4a1308f2f12394abd86d0927a4a0/bad_lists/Mandiant_APT1_Report_Appendix_D.txt
https://openphish.com/feed.txt
https://v.firebog.net/hosts/Prigent-Malware.txt
https://v.firebog.net/hosts/Prigent-Phishing.txt
https://raw.githubusercontent.com/quidsup/notrack/master/malicious-sites.txt
https://ransomwaretracker.abuse.ch/downloads/RW_DOMBL.txt
https://v.firebog.net/hosts/Shalla-mal.txt
https://raw.githubusercontent.com/StevenBlack/hosts/master/data/add.Risk/hosts
https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist
https://github.com/chadmayfield/pihole-blocklists/raw/master/lists/pi_blocklist_porn_all.list
 "

# End log file
Stop-Transcript
