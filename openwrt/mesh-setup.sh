#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="0.280.2925.784414"
VERGEN_BUILT="2022-05-08 00:04:45.7844 UTC"

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

if [ $argHelp = $TRUE ] || [ $(($#)) = $((0)) ] ; then
    echo "Script:  mesh-setup"
    echo "Usage:   ./$(basename "$0") -a FILE|RANGE|LIST [OPTIONS]"
    echo "Build: $VERGEN_BUILD"
    echo "Purpose: Purpose"
    echo "Remarks: Remarks"
    echo "Options:"
    echo "  -x, --example           # fping ip targets, required, script detects type from input"
    echo "Examples:"
    echo "  ./$(basename "$0") -a ip.dat                    # fping imported ips"
    exit $(error 0)
fi

main() {
    local ecode=$((0))
    
    if [ $(isEmpty "$argHostname") = $FALSE ]; then uci set system.@system[0].hostname="$argHostname"; fi
    
    
    
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

