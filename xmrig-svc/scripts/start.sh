#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="1.439.364.467227"
VERGEN_BUILT="2022-06-14 00:22:04.4672 UTC"

# https://github.com/michaelmannelson/scripts
# No warranty is expressed or implied. Run at your own risk.

if [ $(/usr/bin/id -u) != 0 ]; then
    echo "Script requires execution as root. Re-run with sudo."
    exit
fi

readonly SVC="/root/scripts/xmrig-svc"; mkdir -p "$SVC"; cd "$SVC"
readonly GIT="$SVC/github"; mkdir -p "$GIT"
readonly RUN="$SVC/xmrig"; mkdir -p "$RUN"
readonly CFG="$SVC/config"; mkdir -p "$CFG"
readonly LOG="$SVC/log/service.log"; mkdir -p "$(dirname "$LOG")" #; true > "$LOG" # readonly LOG="$SVC/$(basename "$0").log" #; true > "$LOG"
readonly TRUE=$((1)); readonly FALSE=$((0))

error() {
    local code=$(($1)) && readonly code
    local msg="$2" && readonly msg
    
    if   [ $code = $((1)) ]; then $(print "error($code) = argument invalid : \"$msg\"");
    elif [ $code = $((2)) ]; then $(print "error($code) = argument required : \"$msg\"");
    elif [ $code = $((3)) ]; then $(print "error($code) = missing dependency : \"$msg\"");
    fi

    echo $code;
}
print() { echo "$1" 1>&2; if [ $(empty "$2") = $FALSE ]; then echo "$1" >> "$2"; fi }
log() { $(print "$(date +%Y%m%d@%H%M%S%z) $1" "$LOG"); }
empty() { if [ -z "$1" -a "$1" != " " ]; then echo $TRUE; else echo $FALSE; fi }
upgrade() { for arg in "$@"; do $(apt-get upgrade -qq "$arg" < /dev/null > /dev/null); done }
exists() { if [ -f "$1" ]; then echo $TRUE; else echo $FALSE; fi }

if [ $(exists "$CFG/config.json") = $FALSE ]; then exit $(error 3 "Generate config file at \"https://xmrig.com/wizard\" and save to \"$CFG/config.json\""); fi

mkdir -p "$GIT/src"; $(wget "https://raw.githubusercontent.com/xmrig/xmrig/master/src/version.h" -qO "$GIT/src/version.h" &>/dev/null)

if [ $(empty "$(diff "$GIT/src/version.h" "$RUN/src/version.h" 2>&1)") = $FALSE ] || [ $(exists "$RUN/build/xmrig") = $FALSE ]; then
    $(log "build attempt")
    $(upgrade git build-essential cmake libuv1-dev libssl-dev libhwloc-dev jq dmidecode)
    rm -rf "$GIT"; $(git clone https://github.com/xmrig/xmrig.git "$GIT")
    sed -i 's/constexpr const int kDefaultDonateLevel = .*;/constexpr const int kDefaultDonateLevel = 0;/' "$GIT/src/donate.h"
    sed -i 's/constexpr const int kMinimumDonateLevel = .*;/constexpr const int kMinimumDonateLevel = 0;/' "$GIT/src/donate.h"
    mkdir -p "$GIT/build" && cd "$GIT/build"
    
    cmakeargs=""
    for i in $(grep -Ewv '^#' "$CFG/start.sh.cmake"); do
        cmakeargs="$(echo "$cmakeargs $i" | xargs)";
    done
    cmake .. $cmakeargs
    
    make -j$(nproc)
    
    if [ $(exists "$GIT/build/xmrig") = $FALSE ]; then
        $(log "build failed")
        $(editor "$CFG/start.sh.cmake")
    else
        $(log "build success")
        kill $(pidof xmrig) 2>/dev/null
        rm -rf "$RUN"
        mv -f "$GIT" "$RUN"
        ash -c "$RUN/scripts/enable_1gb_pages.sh"
        ash -c "$RUN/scripts/randomx_boost.sh"
    fi
else
    $(log "build skipped")
fi

$(jq ".pools[0].pass |= \"$($RUN/build/xmrig --version | head -1 | sed 's/.* //')/$(uname -n)/$(sudo dmidecode | grep -A2 '^System Information' | tail -1 | sed 's/.*: //')\"" "$CFG/config.json" > "$CFG/config.pass.json")
cp -f "$CFG/config.pass.json" "$RUN/build/config.json"

if [ $(empty "$(pidof xmrig)") = $TRUE ]; then
    $(log "start")
    ash -c "$RUN/build/xmrig --version | grep -i \"xmrig\"" >> "$LOG"
    ash -c "$RUN/build/xmrig"
fi

exit
