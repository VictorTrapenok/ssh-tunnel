#!/bin/sh

port_on_remote_server="$2"
jumpServer="$1"


printf "Support tunnel instalation"
 

mkdir -p /root/support-tunnel
cd /root/support-tunnel


id_rsa="/root/support-tunnel/id_rsa"
id_rsa_pub="/root/support-tunnel/id_rsa.pub"

FILE=/root/support-tunnel/id_rsa.pub
if test -f "$FILE"; then
    echo "id_rsa.pub exists."
else 
    ## Create keys
    printf "" > ./id_rsa 
    printf "\n/root/support-tunnel/id_rsa\n"
    ssh-keygen -t rsa 
fi


id_rsa_private_key=`cat $id_rsa`
id_rsa_public_key=`cat $id_rsa_pub`


## Add ssh config
sshConfig="Host support-tunnel
      Hostname $jumpServer
      User sbd
      RemoteForward $port_on_remote_server 127.0.0.1:22
      ServerAliveInterval 30
      ServerAliveCountMax 5
      ExitOnForwardFailure yes
      IdentityFile $id_rsa
"

printf "$sshConfig"

mkdir -p "/root/.ssh"

printf "\n$sshConfig\n" >  /root/.ssh/config

## Add this key to allow list on local machine
printf "\n$id_rsa_public_key\n" > /root/.ssh/authorized_keys


## Ask to add this public key to allow list on remote jump ssh server
printf "Add this key to jump server:\n$id_rsa_public_key\n\n"

## Ask to add this private key to allow list on remote jump ssh server
printf "Add this key to jump server:\n$id_rsa_private_key\n\n"

## Change mod to 600 to private key
chmod 600 $id_rsa
chmod -R 600 "/root/.ssh"

mkdir -p /etc/support-tunnel
printf "#!/bin/sh 
SSHCMD=\"/usr/bin/ssh -N support-tunnel\"
echo \$SSHCMD;
while true; do
    echo \"conecting\"
    \$SSHCMD
    echo \"conect in 5 seconds...\"
    sleep 5
done

" > /etc/support-tunnel/service.sh
chmod +x /etc/support-tunnel/service.sh

serviceConfig="
[Unit]
Description = SSH Tunnel to local over tunnel to remote support ssh jump server
After = network-online.target
Wants = network-online.target
#
[Service]
User = root
Type = simple
ExecStart = /bin/sh /etc/support-tunnel/service.sh
Restart = always
RestartSec = 30s
#
[Install]
WantedBy = multi-user.target
"
 
printf "$serviceConfig" > /etc/systemd/system/support-tunnel.service 

#printf "PermitRootLogin yes" >>  /etc/ssh/sshd_config
sed -i 's/PermitRootLogin no/PermitRootLogin yes/g'  /etc/ssh/sshd_config

#service ssh restart or service sshd restart
service sshd restart


systemctl daemon-reload
systemctl enable support-tunnel

printf " Run it now:

/usr/bin/ssh -N support-tunnel
systemctl start support-tunnel
systemctl status support-tunnel

service support-tunnel start

"

 

