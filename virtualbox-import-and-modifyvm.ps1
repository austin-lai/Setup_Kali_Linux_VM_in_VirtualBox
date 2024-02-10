# Define paths and variables
$archivePath = "C:\kali-linux-2023.4-virtualbox-amd64.7z"
$extractedPath = "C:\virtual-machines-storage"
$vboxFilePath = "C:\virtual-machines-storage\kali-linux-2023.4-virtualbox-amd64\kali-linux-2023.4-virtualbox-amd64.vbox"
$diskName = "kali-linux-2023.4-virtualbox-amd64.vdi"

# Set VM name
$vmName = "kali-linux-2023.4-virtualbox-amd64"

# Extract the 7z archive using Bandizip CLI
bandizip.exe x -y $archivePath $extractedPath

# Enable hot-pluggable hard disk
VBoxManage storageattach $vmName --storagectl "SATA Controller" --device 0 --port 0 --type hdd --hotpluggable on

# Select USB3 Controller
VBoxManage modifyvm $vmName --usbxhci on

# Register the virtual machine to VirtualBox
VBoxManage registervm "$vboxFilePath"

# Enable 3D acceleration
VBoxManage modifyvm $vmName --accelerate3d on

# Configure remote server
VBoxManage modifyvm $vmName --vrde on
VBoxManage modifyvm $vmName --vrdeport 5954
VBoxManage modifyvm $vmName --vrdeauthtype guest
VBoxManage modifyvm $vmName --vrdemulticon on

# Enable audio input
VBoxManage modifyvm $vmName --audioin on

# Configure network adapters
VBoxManage modifyvm $vmName --nic1 hostonly --hostonlyadapter1 "VirtualBox Host-Only Ethernet Adapter"
# VBoxManage modifyvm $vmName --nic2 natnetwork --nat-network2 "$networkName"
VBoxManage modifyvm $vmName --nic2 nat 

# Enable shared folder
# VBoxManage sharedfolder add $vmName --name "virtual-machines-storage" --hostpath "$extractedPath" --automount
VBoxManage sharedfolder add $vmName --name "host-c" --hostpath "C:\" --automount
VBoxManage sharedfolder add $vmName --name "virtual-machines-storage" --hostpath "C:\virtual-machines-storage" --automount

Write-Host "Kali Linux virtual machine configuration completed."
