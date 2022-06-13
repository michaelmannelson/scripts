# scripts

sudo -i

git clone https://github.com/michaelmannelson/scripts.git

cd scripts

find . -type d -exec chmod +rx {} \;

crontab -e

@reboot /root/scripts/linux/upgrade.sh

@hourly /root/scripts/linux/upgrade.sh

@reboot /root/scripts/xmrig-svc/scripts/start.sh

@hourly /root/scripts/xmrig-svc/scripts/start.sh

