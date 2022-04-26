#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 05:00:00.0000 UTC"
VERGEN_BUILD="0.2.1851.164063"
VERGEN_BUILT="2022-04-26 07:30:51.1640 UTC"

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
