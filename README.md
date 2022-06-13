# scripts

sudo -i

kill -9 $(pidof xmrig) && cd ~ && rm -rf scripts && git clone https://github.com/michaelmannelson/scripts.git && cd scripts && find . -name "*.sh" -exec chmod +x {} + && crontab -e

@reboot /root/scripts/linux/upgrade.sh

@hourly /root/scripts/linux/upgrade.sh

@reboot /root/scripts/xmrig-svc/scripts/start.sh

@hourly /root/scripts/xmrig-svc/scripts/start.sh

/etc/init.d/cron restart
