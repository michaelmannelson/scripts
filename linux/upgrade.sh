#/bin/bash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="1.462.296.150888"
VERGEN_BUILT="2022-06-14 23:20:56.1508 UTC"

sudo dpkg --configure -a
sudo apt install --fix-broken -y 
sudo apt update --fix-missing
sudo apt upgrade -y

