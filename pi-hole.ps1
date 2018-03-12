# Begin log file, this will be placed on the client the script is being run from, do not modify unless you want to disable logging
$ErrorActionPreference = "SilentlyContinue"
Stop-Transcript | out-null
$ErrorActionPreference = "Continue"
Start-Transcript -path C:\Pi-Hole.txt -append

# Script variables, change as needed
# If you want to run this against a remote Hyper-V host, change $ServerName to a proper computer name.
# If you have multiple External vSwitches you'll probably also have to manually input the name of the desired vSwitch in $VMSwitch
$ISO = "C:\admin\iso\ubuntu-16.04.4-server-amd64.iso"
$ISOPath = "c:\admin\ISO\"
$URL = "http://releases.ubuntu.com/16.04.4/ubuntu-16.04.4-server-amd64.iso"
$start_time = Get-Date
$WebClient = New-Object System.Net.WebClient
$VMName = "Pi-Hole"
$VHDpath = "c:\Hyper-V\Virtual Hard Disks\$VMName.vhdx"
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
echo "Downloading Ubuntu Server 16.04.4 LTS ISO"
$WebClient.DownloadFile($url, $ISO)
Write-Output "Time Taken: $((Get-Date).Subtract($start_time).seconds) second(s)"
}
else {
echo "Ubuntu Server 16.04.4 LTS ISO already exists!"
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

echo "
 Configure Ubuntu unencrypted, with automatic security updates and OpenSSH server, hostname pi-hole, username pi-hole. Inside the VM, run Pi-Hole.sh first
 (wget and chmod +x the script)
 After Pi-Hole.sh install Pi-Hole 'curl -sSL https://install.pi-hole.net | bash'
 Customize files for the Blocking page as needed 'sudo nano /var/phbp.ini' then 'sudo service lighttpd force-reload'
 Create crontab job to update Pi-Hole 'crontab -e' '0 7 * * * pihole -up'
 Run 'pihole -g'
 Set the domain controller to forward to the Pi-Hole.
 Relevant links to wget:
 https://raw.githubusercontent.com/pointandclicktulsa/pi-hole/master/Pi-Hole.sh

 See adlists.list on the repo for lists to add.
 https://raw.githubusercontent.com/pointandclicktulsa/pi-hole/master/adlists.list
 "

# End log file
Stop-Transcript
