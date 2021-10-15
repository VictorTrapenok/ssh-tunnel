# ssh-tunnel-configuration

ssh tunnel configuration script 

# How to use

## On customers machine

- copy imstall.sh to remote computer
- run it from root `sh ./install.sh 2234`

Enter
```
/root/support-tunnel/id_rsa
```

answer yes

```
yes
```

Do not add a password. Just enter the empty line twice.


Copy the output to your local machine and save it.

Run `/usr/bin/ssh -N support-tunnel` and approve connection

Run 

```
systemctl start support-tunnel
systemctl status support-tunnel
```


## On jump server

- add public key from output to the file `/home/sbd/.ssh/authorized_keys`
- add a private key from output to any other file
- check connection from your server to customers machine `ssh -p2234 root@127.0.0.1 -i ./id_rsa`

## Note

use different port number instead of `2234` per each new customers machine


# Jump server configuration

This should be done only once

- Create new server
- run `printf "ClientAliveInterval 5\nClientAliveCountMax 3\nGatewayPorts yes" >> /etc/ssh/sshd_config`
- run `service ssh restart`
- create new user `useradd -r -m -k /dev/null sbd && cd /home/sbd/ && mkdir .ssh && chown sbd:sbd .ssh/ && chmod 700 .ssh/`


# Debug

All active connections you can see by command `netstat -ntlp`




