VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="1.437.3213.869518"
VERGEN_BUILT="2022-06-13 23:09:33.8695 UTC"
#/bin/bash
sudo dpkg --configure -a
sudo apt --fix-broken install
sudo apt update --fix-missing
sudo apt upgrade -y
