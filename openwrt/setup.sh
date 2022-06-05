#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="1.225.3381.655549"
VERGEN_BUILT="2022-06-05 03:12:21.6555 UTC"

# https://github.com/michaelmannelson/scripts
# No warranty is expressed or implied. Run at your own risk.

### THIS IS A WORK IN PROGRESS AND NOT READY FOR PRODUCTION USE ###

readonly TMP="/tmp/$(basename "$0").log"; true > "$TMP"
readonly TRUE=$((1)); readonly FALSE=$((0))

readonly ARGHOSTNAME="" ; argHostname=$ARGHOSTNAME

for arg in "$@"; do
    args=$(echo "$args $arg" | xargs);
    
    if [ "$arg" = "--help"  ]; then argHelp=$TRUE; break; fi

    if [ "$arg" = "-h" ] || [ "$arg" = "--hostname" ]; then opt="hostname"; argHostname=""; continue; fi
 
    if [ "$opt" = "hostname" ]; then argHostname=$(echo "$argHostname $arg" | xargs); continue; fi
    
    exit $(error 1 $arg)
done

readonly argHostname;

main() {
    local ecode=$((0))
    
    if [ $(isEmpty "$argHostname") = $FALSE ]; then uci set system.@system[0].hostname="$argHostname"; fi
    
    #uci set system.cfg01e48a.hostname='WhyPhi-Barn'
    
    #uci set system.cfg01e48a.zonename='America/Chicago'
    #uci set system.cfg01e48a.timezone='CST6CDT,M3.2.0,M11.1.0'
    
    #uci set [router password command not given]
    
    #pull in dat file with all packages to install and/or remove
        #opkg update
        #opkg remove wpad-basic-wolfssl
        #opkg install wpad-mesh-wolfssl
        #etc.
    
    #startup
        #if dummy access point, disable firewall, dnsmasq, and odhcpd
    
    #interfaces
        #if dummy access point, 
    
            #/etc/config/dhcp
            #uci del dhcp.wan
    
        #/etc/config/firewall
            #uci del firewall.cfg02dc81.network
            #uci add_list firewall.cfg02dc81.network='lan'
            #uci del firewall.cfg03dc81.network
            #uci add_list firewall.cfg03dc81.network='wan6'
            #uci del firewall.cfg03dc81.network
            #uci del firewall.cfg02dc81.network
            #uci add_list firewall.cfg02dc81.network='lan'
    
        #/etc/config/network
            #uci del network.wan
            #uci del network.wan6
    
        #/etc/config/dhcp
            #uci del dhcp.lan.ra_slaac
            #uci del dhcp.lan.ra
            #uci del dhcp.lan.dhcpv6
            #uci set dhcp.lan.ignore='1'
            #uci del dhcp.lan.ra_flags
            #uci add_list dhcp.lan.ra_flags='none'

        #/etc/config/network
            #uci del network.lan.ipaddr
            #uci del network.lan.netmask
            #uci del network.lan.ip6assign
            #uci set network.lan.proto='dhcp'    
    
        # /etc/config/network
            #uci set network.cfg030f15.stp='1'
    
    #dhcp and dns
        # /etc/config/dhcp
            #uci del dhcp.cfg01411c.authoritative
            #uci del dhcp.cfg01411c.boguspriv
            #uci del dhcp.cfg01411c.filterwin2k
            #uci del dhcp.cfg01411c.nonegcache
            #uci del dhcp.cfg01411c.nonwildcard
            
    #firewall
        # /etc/config/firewall
            #uci del firewall.cfg01e63d.syn_flood
            #uci set firewall.cfg01e63d.synflood_protect='1'
            #uci set firewall.cfg01e63d.forward='ACCEPT'
            #uci del firewall.cfg02dc81
            #uci del firewall.cfg04ad58
            #uci del firewall.cfg0c92bd
            #uci del firewall.cfg0d92bd
            #uci del firewall.cfg03dc81
            #uci del firewall.cfg0592bd
            #uci del firewall.cfg0692bd
            #uci del firewall.cfg0792bd
            #uci del firewall.cfg0892bd
            #uci del firewall.cfg0992bd
            #uci del firewall.cfg0a92bd
            #uci del firewall.cfg0b92bd
            #uci del firewall.cfg0e92bd

    #wireless
        # /etc/config/wireless
            #uci del wireless.default_radio0
            #uci del wireless.default_radio1

        # /etc/config/wireless
            #uci del wireless.radio0.disabled
            #uci set wireless.wifinet0=wifi-iface
            #uci set wireless.wifinet0.device='radio0'
            #uci set wireless.wifinet0.mode='mesh'
            #uci set wireless.wifinet0.encryption='sae'
            #uci set wireless.wifinet0.mesh_id='SSID'
            #uci set wireless.wifinet0.mesh_fwding='1'
            #uci set wireless.wifinet0.mesh_rssi_threshold='0'
            #uci set wireless.wifinet0.key='PASSWORD'
            #uci set wireless.wifinet0.network='lan'
            #uci set wireless.radio0.cell_density='0'
            #uci set wireless.wifinet1=wifi-iface
            #uci set wireless.wifinet1.device='radio0'
            #uci set wireless.wifinet1.mode='ap'
            #uci set wireless.wifinet1.ssid='SSID'
            #uci set wireless.wifinet1.encryption='psk-mixed'
            #uci set wireless.wifinet1.key='PASSWORD'
            #uci set wireless.wifinet1.ieee80211r='1'
            #uci set wireless.wifinet1.mobility_domain='fade'
            #uci set wireless.wifinet1.ft_over_ds='0'
            #uci set wireless.wifinet1.ft_psk_generate_local='1'
            #uci set wireless.wifinet1.network='lan'
            #uci del wireless.radio1.disabled
            #uci set wireless.wifinet2=wifi-iface
            #uci set wireless.wifinet2.device='radio1'
            #uci set wireless.wifinet2.mode='ap'
            #uci set wireless.wifinet2.ssid='SSID'
            #uci set wireless.wifinet2.encryption='psk-mixed'
            #uci set wireless.wifinet2.key='PASSWORD'
            #uci set wireless.wifinet2.ieee80211r='1'
            #uci set wireless.wifinet2.mobility_domain='fade'
            #uci set wireless.wifinet2.ft_over_ds='0'
            #uci set wireless.wifinet2.ft_psk_generate_local='1'
            #uci set wireless.wifinet2.network='lan'
            #uci set wireless.radio1.channel='3'
            #uci set wireless.radio1.cell_density='0'

    if [ $ecode = $((0)) ]; then 
        uci commit
    else
        # https://stackoverflow.com/a/46532088
        for change in $(uci changes); do
            uci revert "$(echo ${change} | grep -o '^\(\w\|[._-]\)\+')"
        done
    fi
    
    echo $ecode;
}

error() { # error
    local code=$(($1)) && readonly code
    local msg="$2" && readonly msg
    
    if   [ $code = $((1)) ]; then $(print "$TMP" "error($code) = argument invalid : \"$msg\"");
    elif [ $code = $((2)) ]; then $(print "$TMP" "error($code) = argument required : \"$msg\"");
    elif [ $code = $((3)) ]; then $(print "$TMP" "error($code) = missing dependency : \"$msg\"");
    fi

    echo $code;
}

print() { # print to console and file
    echo "$2" 1>&2; echo "$2" >> "$1";
}

isEmpty() { # is empty
    if [ -z "$1" -a "$1" != " " ]; then echo $TRUE; else echo $FALSE; fi
}

exit $(main)

