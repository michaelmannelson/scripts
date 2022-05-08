#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="0.283.1331.418815"
VERGEN_BUILT="2022-05-08 02:38:11.4188 UTC"

# https://github.com/michaelmannelson/scripts
# No warranty is expressed or implied. Run at your own risk.

### Set up by hand with the following commands
# mkdir -p /usr/local/sbin && cd /usr/local/sbin
# wget https://raw.githubusercontent.com/michaelmannelson/scripts/main/openwrt/kabrap.sh
# chmod +x update-opkg.sh
# crontab -e
# * * * * * /usr/local/sbin/kabrap.sh -a 192.168.1.10-192.168.1.16 -b 4-32 -p 3000-7000 -m 45000-60000 -l /www/kabrap.log
# ./kabrap.sh

readonly TRUE=$((1))
readonly FALSE=$((0))

readonly DIGITS="0123456789"

readonly ARGADDRESS=""                                  ; argAddress=$ARGADDRESS
readonly ARGBYTE="32-64"                                ; argByte=$ARGBYTE
readonly ARGHELP=$FALSE                                 ; argHelp=$ARGHELP
readonly ARGLOG=""                                      ; argLog=$ARGLOG #="$(dirname $(readlink -f $0))/$(basename "$0").log"
readonly ARGMAX="45000-60000"                           ; argMax=$ARGMAX
readonly ARGOPTION="-e -m -n -o -q -r 0 -s -A -D -M -R" ; argOption=$ARGOPTION # see fping --help for full options list
readonly ARGPERIOD="4000-6000"                          ; argPeriod=$ARGPERIOD
readonly ARGTIMEOUT="100-500"                           ; argTimeout=$ARGTIMEOUT

readonly TMP="/tmp/$(basename "$0").log"
true > "$TMP"

rd() { # random digit from a given sequence
    local ret=""
    while [ -z "$ret" -a "$ret" != " " ]; do ret="$(head -1 /dev/urandom | tr -dc "${1:-"$DIGITS"}" | head -c1)"; done
    echo $(($ret))
}

rz () { # remove zeros leading
    if [ "$(echo "$1" | tr -d '0')" = "" ]; then echo $((0)); else echo $(($(echo "$1" | grep -o -E "[1-9][0-9]*"))); fi
}

ri () { # random integer between two integers
    local lhs=$1
    local rhs=$2

    if [ $lhs -eq $rhs ]; then 
        echo $lhs        
        return
    elif [ $lhs -gt $rhs ]; then 
        local ths=$lhs
        lhs=$rhs
        rhs=$ths
    fi

    local dif=$(($rhs-$lhs))
    local len=${#dif}
    local mov=""
    
    # random select each digit within its appropriate tens place based on previous selection
    local i=$((1)); local all=$FALSE; while [ $i -le $len ]
    do 
        local digit=$(($(echo "$dif" | cut -c $i-$i)))
        local sequence="$DIGITS"
        local rand=$(rd "$sequence")
        
        if [ $all -eq $FALSE ]; then
            while [ $rand -gt $digit ]
            do
                sequence="$(echo "$sequence" | tr -d "$rand" )"
                rand=$(rd "$sequence")
            done
            if [ $rand -lt $digit ]; then all=$TRUE; fi
        fi
        
        mov="$mov"$rand""
       
        i=$(($i+1))
    done
    mov=$(rz $mov)
    
    # random select value up from lhs or down from rhs
    local ret=""
    if [ $(rd "01") -eq $((0)) ]; then
        ret=$(($lhs+$mov))
    else
        ret=$(($rhs-$mov))
    fi
    
    echo $(rz $ret)
}

ise () { # is empty
    if [ -z "$1" -a "$1" != " " ]; then echo $TRUE; else echo $FALSE; fi
}

isn () { # is number
    if [ "$(echo "$1" | grep -o -E '^[0-9]+$' | head -1)" != "" ]; then echo $TRUE; else echo $FALSE; fi
}

e() { # error
    local code=$(($1)) && readonly code
    local msg="$2" && readonly msg
    
    if   [ $code = $((1)) ]; then $(p "$TMP" "error($code) = argument required : \"$msg\"");
    elif [ $code = $((2)) ]; then $(p "$TMP" "error($code) = argument invalid : \"$msg\"");
    elif [ $code = $((3)) ]; then $(p "$TMP" "error($code) = dependency missing : \"$msg\"");
    fi

    echo $code;
}

gf () { # get first integer in range
    echo $(($(rz $(echo "$1" | grep -o -E '^[0-9]+\-?' | head -1 | tr -d "-" ))))
}

gl () { # get last integer in range
    echo $(($(rz $(echo "$1" | grep -o -E '\-?[0-9]+$' | tail -1 | tr -d "-" ))))
}

p () { # print to console and file
    echo "$2" 1>&2; echo "$2" >> "$1";
}

if ! [ -x "$(command -v fping)" ]; then exit $(e 3 "fping"); fi

for arg in "$@"; do
    args=$(echo "$args $arg" | xargs);
    
    if [ "$arg" = "--help"  ]; then argHelp=$TRUE; break; fi

    if [ "$arg" = "-a" ] || [ "$arg" = "--address" ]; then opt="address"; argAddress=""; continue; fi
    if [ "$arg" = "-b" ] || [ "$arg" = "--byte"    ]; then opt="byte";    argByte="";    continue; fi
    if [ "$arg" = "-l" ] || [ "$arg" = "--log"     ]; then opt="log";     argLog="";     continue; fi
    if [ "$arg" = "-m" ] || [ "$arg" = "--max"     ]; then opt="max";     argMax="";     continue; fi
    if [ "$arg" = "-o" ] || [ "$arg" = "--option"  ]; then opt="option";  argOption="";  continue; fi
    if [ "$arg" = "-p" ] || [ "$arg" = "--period"  ]; then opt="period";  argPeriod="";  continue; fi
    if [ "$arg" = "-t" ] || [ "$arg" = "--timeout" ]; then opt="timeout"; argTimeout=""; continue; fi
 
    if [ "$opt" = "address" ]; then argAddress=$(echo "$argAddress $arg" | xargs); continue; fi
    if [ "$opt" = "byte"    ]; then argByte=$(echo "$argByte $arg" | xargs);       continue; fi
    if [ "$opt" = "log"     ]; then argLog=$(echo "$argLog $arg" | xargs);         continue; fi
    if [ "$opt" = "max"     ]; then argMax=$(echo "$argMax $arg" | xargs);         continue; fi
    if [ "$opt" = "option"  ]; then argOption=$(echo "$argOption $arg" | xargs);   continue; fi
    if [ "$opt" = "period"  ]; then argPeriod=$(echo "$argPeriod $arg" | xargs);   continue; fi
    if [ "$opt" = "timeout" ]; then argTimeout=$(echo "$argTimeout $arg" | xargs); continue; fi
    
    exit $(e 2 $arg)
done
readonly argAddress; readonly argByte; readonly argHelp; readonly argMax; readonly argLog; readonly argOption; readonly argPeriod;
#echo "argAddress=$argAddress"; echo "argByte=$argByte"; echo "argHelp=$argHelp"; echo "argMax=$argMax"; echo "argLog=$argLog"; echo "argOption=$argOption"; echo "argPeriod=$argPeriod";

if [ $argHelp = $TRUE ] || [ $(($#)) = $((0)) ] ; then
    echo "Script:  Keep Awake By Repeated Automated Pings (kabrap)"
    echo "Usage:   ./$(basename "$0") -a FILE|RANGE|LIST [OPTIONS]"
    echo "Build: $VERGEN_BUILD"
    echo "Purpose: Calls fping to given addresses using random values from given ranges"
    echo "Remarks: Script created to keep awake all routers on network by ping via asynchronous cron"
    echo "Options:"
    echo "  -a, --address   FILE|RANGE|LIST # fping ip targets, required, script detects type from input"
    echo "          FILE                    # file path to list of line seperated ips, fping -f"
    echo "          RANGE                   # generated ip range, format \"X.X.X.X-Y.Y.Y.Y\", fping -g"
    echo "          LIST                    # space delimited ip addresses, format \"X.X.X.X Y.Y.Y.Y\""
    echo "  -b, --byte      INT[-][INT]     # fping size random selected, default \"$ARGBYTE\""
    echo "  -l, --log       PATH            # export log to file"
    echo "  -m, --max       INT[-][INT]     # max time in ms fping will run, default \"$ARGMAX\""
    echo "  -o, --option    STRING          # fping option, default \"$ARGOPTION\""
    echo "                                  # note fping -c/--count is calculated from -m, -p, and -t"
    echo "  -p, --period    INT[-][INT]     # time in ms between pings, default \"$ARGPERIOD\""
    echo "  -t, --timeout   INT[-][INT]     # time in ms between pings, default \"$ARGTIMEOUT\""
    echo "Examples:"
    echo "  ./$(basename "$0") -a ip.dat                    # fping imported ips"
    echo "  ./$(basename "$0") -a 192.168.1.1-192.168.1.9   # fping entire ip range"
    echo "  ./$(basename "$0") -a 192.168.1.1 192.168.1.2   # fping specific ips"
    echo "  ./$(basename "$0") -a ip.dat -b 56              # fping standard bytes"
    echo "  ./$(basename "$0") -a ip.dat -b 32 128          # fping bytes random pick in range"
    echo "  ./$(basename "$0") -a ip.dat -b 32-128          # fping bytes random pick in range"
    echo "  ./$(basename "$0") -a ip.dat -m 30000-60000     # fping total time random pick in range"
    echo "  ./$(basename "$0") -a ip.dat -o \"-r 1\"          # fping option override default"
    echo "  ./$(basename "$0") -a ip.dat -p 2500-3000       # fping period random pick in range"
    echo "  ./$(basename "$0") -a ip.dat -t 100-500         # fping timeout random pick in range"
    echo "  ./$(basename "$0") -a 192.168.1.1-192.168.1.254 -b 32-64 -m 30000-60000 -p 3000-5000 -t 500-1000"
    exit $(e 0)
fi

if   [ $(ise "$argAddress") = $TRUE ]; then exit $(e 1 "address");
elif [ -f "$argAddress" ]; then a="-f $argAddress";
elif [ $(ise $(echo "$argAddress" | grep -o -E '^\S+\-\S+$')) = $FALSE ]; then a="-g $(echo "$argAddress" | sed -r 's/-/ /g')";
else a="$argAddress";
fi

if [ $(ise "$argByte") = $TRUE ]; then exit $(e 1 "byte"); fi
b1=$(gf "$argByte"); if [ $b1 -le $((0)) ]; then exit $(e 2 "byte1 must be greater than zero"); fi 
b2=$(gl "$argByte"); if [ $b2 -le $((0)) ]; then exit $(e 2 "byte2 must be greater than zero"); fi 
if [ $b1 -gt $b2 ]; then ths=$b1; b1=$b2; b2=$ths; fi
b=$(ri $b1 $b2)

if [ $(ise "$argPeriod") = $TRUE ]; then exit $(e 1 "period"); fi
p1=$(gf "$argPeriod"); if [ $p1 -le $((0)) ]; then exit $(e 2 "period1 must be greater than zero"); fi 
p2=$(gl "$argPeriod"); if [ $p2 -le $((0)) ]; then exit $(e 2 "period2 must be greater than zero"); fi 
if [ $p1 -gt $p2 ]; then ths=$p1; p1=$p2; p2=$ths; fi
p=$(ri $p1 $p2)

if [ $(ise "$argTimeout") = $TRUE ]; then exit $(e 1 "timeout"); fi
t1=$(gf "$argTimeout"); if [ $t1 -le $((0)) ]; then exit $(e 2 "timeout1 must be greater than zero"); fi 
t2=$(gl "$argTimeout"); if [ $t2 -le $((0)) ]; then exit $(e 2 "timeout2 must be greater than zero"); fi 
if [ $t1 -gt $t2 ]; then ths=$t1; t1=$t2; t2=$ths; fi
t=$(ri $t1 $t2)

if [ $(ise "$argMax") = $TRUE ]; then exit $(e 1 "max"); fi
m1=$(gf "$argMax"); if [ $m1 -le $((0)) ]; then exit $(e 2 "max1 must be greater than zero"); fi 
m2=$(gl "$argMax"); if [ $m2 -le $((0)) ]; then exit $(e 2 "max2 must be greater than zero"); fi 
if [ $m1 -gt $m2 ]; then ths=$m1; m1=$m2; m2=$ths; fi
m=$(ri $m1 $m2)

if [ $(($p2+t2)) -ge $m1 ]; then exit $(e 2 "greatest possible period plus timeout must be less maximum"); fi

c=$(($m/($p+$t)))
if [ $c -eq $((0)) ]; then c=$((1)); fi

o="$argOption"

command=$(echo "fping $a -b $b -c $c -p $p -t $t $o 2>&1 | tee -a \"$TMP\"" | xargs);

$(p "$TMP" "$(date +"%Y-%m-%d@%H:%M:%S%z-%Z")"); $(p "$TMP" " ")
$(p "$TMP" "$(basename "$0") $args"); $(p "$TMP" " ")
$(p "$TMP" "max $m / (period $p + timeout $t) = count $c"); $(p "$TMP" " ")
$(p "$TMP" "$command"); $(p "$TMP" " ")

ash -c "$command"

if [ $(ise "$argLog") = $FALSE ]; then cp -f "$TMP" "$argLog"; fi

exit $(e 0)
