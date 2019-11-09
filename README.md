# PiDOH
DNS over HTTPS over PiHole for Raspbian.  This is for a https://github.com/pi-hole @pi-hole

This has been pulled from https://docs.pi-hole.net/guides/dns-over-https/ and modified so that it can be run as a single script.

Before running the script it's recommended to run `sudo -v` may be needed to run to cache the password, depending on how your Pi is setup.

## Just give me the script

https://github.com/vanderblugen/PiDOH/blob/master/main.sh 

You still have to update the PiHole per the image below.

## This is the jist of the script

Here we are downloading the precompiled binary and copying it to the /usr/local/bin/ directory to allow execution by the cloudflared user. 
```bash
wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz
tar -xvzf cloudflared-stable-linux-arm.tgz
sudo cp ./cloudflared /usr/local/bin
sudo chmod +x /usr/local/bin/cloudflared
cloudflared -v
```

Create a cloudflared user to run the daemon
```bash
sudo useradd -s /usr/sbin/nologin -r -M cloudflared
```

Proceed to create a configuration file for cloudflared by copying the following in to /etc/default/cloudflared. 
This file contains the command-line options that get passed to cloudflared on startup
```bash
echo "# Commandline args for cloudflared
CLOUDFLARED_OPTS=--port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query" | sudo tee -a /etc/default/a.txt > /dev/null
```

Create the systemd script in to /etc/systemd/system/cloudflared.service
This controls the running of the service and allow it to run on startup
```bash
echo "[Unit]
Description=cloudflared DNS over HTTPS proxy
After=syslog.target network-online.target
[Service]
Type=simple
User=cloudflared
EnvironmentFile=/etc/default/cloudflared
ExecStart=/usr/local/bin/cloudflared proxy-dns $CLOUDFLARED_OPTS
Restart=on-failure
RestartSec=10
KillMode=process
[Install]
WantedBy=multi-user.target" | sudo tee -a /etc/systemd/system/alpha > /dev/null
```

Enable the systemd service to run on startup
```bash
sudo systemctl enable cloudflared
sudo systemctl start cloudflared
```


## Navigate a browser to the PiHole and update the DNS settings per the image

<img src=https://docs.pi-hole.net/images/DoHConfig.png>
