#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="1.447.1916.428090"
VERGEN_BUILT="2022-06-14 08:47:56.4280 UTC"

### Set up by hand with the following commands
# mkdir -p /usr/local/sbin && cd /usr/local/sbin
# wget https://raw.githubusercontent.com/michaelmannelson/scripts/main/openwrt/update-opkg.sh
# chmod +x update-opkg.sh
# crontab -e
# 0 2 * * * /usr/local/sbin/update-system.sh
# ./update-opkg.sh

opkg update
# upgrade netifd first as it causes drop out and system upgrade fails

opkg upgrade netifd
# install luci-ssl, so we get web back after upgrades

opkg install luci-ssl
/etc/init.d/uhttpd restart

# do package upgrades
PACKAGES="$(opkg list-upgradable |awk '{print $1}')"
if [ -n "${PACKAGES}" ]; then
  echo "$(date -I"seconds") - update attempt," >> /www/update.log
  echo "${PACKAGES}" >> /www/update.log  
  opkg upgrade ${PACKAGES}
  if [ "$?" -eq 0 ]; then
    echo "$(date -I"seconds") - update success, rebooting" >> /www/update.log
    sleep 60
    exec reboot
  else
    echo "$(date -I"seconds") - update failed" >> /www/update.log
  fi
else
  echo "$(date -I"seconds") - nothing to update" >> /www/update.log
fi
