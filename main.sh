# PiDOH
#DNS over HTTPS over PiHole for Raspbian

# This code is taken directly from https://docs.pi-hole.net/guides/dns-over-https/
# A few items have been modified and it has been all combined into a single script

# Here we are downloading the precompiled binary and copying it to the /usr/local/bin/ directory to 
# allow execution by the cloudflared user. Proceed to run the binary with the -v flag to check it is all working:

wget https://bin.equinox.io/c/VdrWdbjqyF/cloudflared-stable-linux-arm.tgz
tar -xvzf cloudflared-stable-linux-arm.tgz
sudo cp ./cloudflared /usr/local/bin
sudo chmod +x /usr/local/bin/cloudflared
cloudflared -v

# Create a cloudflared user to run the daemon

sudo useradd -s /usr/sbin/nologin -r -M cloudflared

# Proceed to create a configuration file for cloudflared by copying the following in to /etc/default/cloudflared. 
# This file contains the command-line options that get passed to cloudflared on startup

echo "# Commandline args for cloudflared
CLOUDFLARED_OPTS=--port 5053 --upstream https://1.1.1.1/dns-query --upstream https://1.0.0.1/dns-query" | sudo tee -a /etc/default/a.txt > /dev/null

# Then create the systemd script by copying the following in to /etc/systemd/system/cloudflared.service. 
# This will control the running of the service and allow it to run on startup:

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

# Enable the systemd service to run on startup

sudo systemctl enable cloudflared
sudo systemctl start cloudflared
