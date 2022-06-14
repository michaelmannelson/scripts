# scripts

sudo -i

kill -9 $(pidof xmrig) & apt install ash -y && cd ~ && rm -rf scripts && git clone https://github.com/michaelmannelson/scripts.git && cd scripts && find . -name "*.sh" -exec chmod +x {} + && crontab -e && editor ~/scripts/xmrig-svc/config/config.json && editor ~/scripts/xmrig-svc/config/start.sh.cmake && /etc/init.d/cron restart && ~/scripts/xmrig-svc/scripts/start.sh

@reboot /root/scripts/linux/upgrade.sh

@hourly /root/scripts/linux/upgrade.sh

@reboot /root/scripts/xmrig-svc/scripts/start.sh

@hourly /root/scripts/xmrig-svc/scripts/start.sh
