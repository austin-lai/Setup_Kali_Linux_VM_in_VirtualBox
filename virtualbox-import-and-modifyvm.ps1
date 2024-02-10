# Define paths and variables
$archivePath = "C:\kali-linux-2023.4-virtualbox-amd64.7z"
$extractedPath = "C:\virtual-machines-storage"
$vboxFilePath = "C:\virtual-machines-storage\kali-linux-2023.4-virtualbox-amd64\kali-linux-2023.4-virtualbox-amd64.vbox"
$diskName = "kali-linux-2023.4-virtualbox-amd64.vdi"

# Extract the 7z archive using Bandizip CLI
# Start-Process -FilePath "bandizip.exe" -ArgumentList "/extract:$archivePath /dest:$extractedPath"
bandizip.exe x -y $archivePath $extractedPath



# Enable hot-pluggable hard disk

# Read the content from the file
$content = Get-Content -Path $vboxFilePath

# Replace the old string with the new one
$content = $content -replace '<AttachedDevice type="HardDisk" hotpluggable="false" port="0" device="0">', '<AttachedDevice type="HardDisk" hotpluggable="true" port="0" device="0">'

# Write the updated content back to the file
$content | Set-Content -Path $vboxFilePath



# Select USB3 Controller

# Read the content from the file
$content = Get-Content -Path $vboxFilePath

# Replace the old string with the new one
$content = $content -replace '<Controller name="OHCI" type="OHCI"/>', '<Controller name="xHCI" type="XHCI"/>'

# Write the updated content back to the file
$content | Set-Content -Path $vboxFilePath



# Register the virtual machine to VirtualBox
VBoxManage registervm "$vboxFilePath"

# Enable 3D acceleration
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --accelerate3d on

# Configure remote server
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --vrde on
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --vrdeport 5954
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --vrdeauthtype guest
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --vrdemulticon on

# Enable audio input
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --audioin on

# Configure network adapters
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --nic1 hostonly --hostonlyadapter1 "VirtualBox Host-Only Ethernet Adapter"
# VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --nic2 natnetwork --nat-network2 "$networkName"
VBoxManage modifyvm "kali-linux-2023.4-virtualbox-amd64" --nic2 nat 

# Enable shared folder
# VBoxManage sharedfolder add "kali-linux-2023.4-virtualbox-amd64" --name "virtual-machines-storage" --hostpath "$extractedPath" --automount
VBoxManage sharedfolder add "kali-linux-2023.4-virtualbox-amd64" --name "host-c" --hostpath "C:\" --automount
VBoxManage sharedfolder add "kali-linux-2023.4-virtualbox-amd64" --name "virtual-machines-storage" --hostpath "C:\virtual-machines-storage" --automount

Write-Host "Kali Linux virtual machine configuration completed."
