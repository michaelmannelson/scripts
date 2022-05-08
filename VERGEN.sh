#!/bin/ash
VERGEN_BASED="%m.%H.%S.%O"
VERGEN_BIRTH="2022-04-26 07:16:00.0000 UTC"
VERGEN_BUILD="0.283.1331.418815"
VERGEN_BUILT="2022-05-08 02:38:11.4188 UTC"

# https://github.com/michaelmannelson/scripts
# No warranty is expressed or implied. Run at your own risk.

readonly TRUE=$((1))
readonly FALSE=$((0))

readonly BASEYEAR="%Y";     readonly NSPERYEAR=$((31557600000000000))
readonly BASEMONTH="%m";    readonly NSPERMONTH=$((2628000000000000))
readonly BASEDAY="%d";      readonly NSPERDAY=$((86400000000000))
readonly BASEHOUR="%H";     readonly NSPERHOUR=$((3600000000000))
readonly BASEMINUTE="%M";   readonly NSPERMINUTE=$((60000000000))
readonly BASESECOND="%S";   readonly NSPERSECOND=$((1000000000))
readonly BASEMILLI="%L";    readonly NSPERMILLI=$((1000000))
readonly BASEMICRO="%O";    readonly NSPERMICRO=$((1000))
readonly BASENANO="%N";     readonly NSPERNANO=$((1))
readonly BASEALL="$BASEYEAR|$BASEMONTH|$BASEDAY|$BASEHOUR|$BASEMINUTE|$BASESECOND|$BASEMILLI|$BASEMICRO|$BASENANO"

readonly ARGBASED="%m.%H.%S.%O" ; argBased=$ARGBASED    #"%Y.%m.%d.%H.%M.%S.%L.%O.%N"
readonly ARGBIRTH=""            ; argBirth=$ARGBIRTH
readonly ARGHELP=$FALSE         ; argHelp=$ARGHELP
readonly ARGINPUT=""            ; argInput=$ARGINPUT    #="$(dirname $(readlink -f $0))/$(basename "$0").version"
readonly ARGOUTPUT=""           ; argOutput=$ARGOUTPUT  #="$(dirname $(readlink -f $0))/$(basename "$0").version"

readonly TMP="/tmp/scripts/$(basename "$0")/$(basename "$0").log"
mkdir -p "$(dirname $TMP)"
true > "$TMP"

pcf () { # print to console and file
    echo "$2" 1>&2; echo "$2" >> "$1";
}

ex () { # error and exit
    local code=$(($1)) && readonly code
    local msg="$2" && readonly msg

    if [ $code = $((1)) ]; then $(pcf "$TMP" "error($code) = Invalid argument : \"$msg\"");
    fi

    echo $code;
}

ise () { # is empty
    if [ -z "$1" -a "$1" != " " ]; then echo $TRUE; else echo $FALSE; fi
}

out () { # find and replace or add to beginning of file if not found
    local find="$1" && readonly find
    local replace="$2" && readonly replace
    local output="$3" && readonly output

    if [ "$(grep -Eio "$find" "$output" | head -1)" != "" ]; then
        sed -i -E "s/$find/$replace/g" "$output"
    elif [ "$(grep -Eio '^#!.*' "$output" | head -1)" != "" ]; then
        code="$(grep -Eio '^#!.*' "$output" | head -1)"
        sed -i -E 's/^#!.*//g' "$output"
        echo "
$replace$(cat "$output")" > "$output"
        echo "$code$(cat "$output")" > "$output"
    else
        echo "$replace
$(cat "$output")" > "$output"
    fi
}

for arg in "$@"; do
    args=$(echo "$args $arg" | xargs);

    if [ "$arg" = "--help"  ]; then argHelp=$TRUE; break; fi

    if [ "$arg" = "-a" ] || [ "$arg" = "--based"  ]; then opt="based";  argBased="";  continue; fi
    if [ "$arg" = "-b" ] || [ "$arg" = "--birth"  ]; then opt="birth";  argBirth="";  continue; fi
    if [ "$arg" = "-i" ] || [ "$arg" = "--input"  ]; then opt="input";  argInput="";  continue; fi
    if [ "$arg" = "-o" ] || [ "$arg" = "--output" ]; then opt="output"; argOutput=""; continue; fi

    if [ "$opt" = "based"  ]; then argBased="$(echo "$argBased $arg" | xargs)";   continue; fi
    if [ "$opt" = "birth"  ]; then argBirth="$(echo "$argBirth $arg" | xargs)";   continue; fi
    if [ "$opt" = "input"  ]; then argInput="$(echo "$argInput $arg" | xargs)";   continue; fi
    if [ "$opt" = "output" ]; then argOutput="$(echo "$argOutput $arg" | xargs)"; continue; fi

    if [ "$(echo "$(date -d "$arg" 2>&1)" | grep -Eio 'invalid' | head -1)" = "" ]; then argBirth="$arg"; continue; fi
    if [ "$(echo "$arg" | grep -Eio "$BASEALL" | head -1)" != "" ]; then argBased="$arg"; continue; fi

    exit $(ex 1 $arg)
done

if [ $argHelp = $TRUE ]; then       #if [ $argHelp = $TRUE ] || [ $(($#)) = $((0)) ] ; then
    echo "Usage: ./$(basename "$0") [OPTIONS]"
    echo "Build: $VERGEN_BUILD"
    echo "Purpose: Generates version number based on provided pattern and date"
    echo "Options:"
    echo "  -a, --based     FORMAT  # Build number format cascading nanoseconds from birth to now"
    echo "                          # Default: \"$ARGBASED\""
    echo "                          # %Y=year        , %m=month       , %d=date"
    echo "                          # %H=hour        , %M=minute      , %S=second"
    echo "                          # %L=millisecond , %O=microsecond , %N=nanosecond"
    echo "  -b, --birth     DATE    # First build date from which build number is generated to now"
    echo "                          # Default: \"$ARGBIRTH\""
    echo "  -i, --input     FILE    # File that does contain previous build information"
    echo "  -o, --output    FILE    # File that will contain previous build information"
    echo "Examples:"
    echo "  ./$(basename "$0")"
    echo "      # generate build from local midnight till now"
    echo "  ./$(basename "$0") now"
    echo "      # generate build as close as possible to now"
    echo "  ./$(basename "$0") -a \"%Y.%m.%d.%H.%M.%S.%L.%O.%N\" -b \"5 years ago\""
    echo "      # generate build using the given format from given date till now"
    echo "  ./$(basename "$0") -b \"\" -o $(basename "$0").version"
    echo "      # generate build from local midnight till now and save output to file"
    echo "  ./$(basename "$0") -i $(basename "$0").version"
    echo "      # generate build using file info for based and birth to now"
    echo "  ./$(basename "$0") -i $(basename "$0").version -o $(basename "$0").version"
    echo "      # generate build using file info for based and birth to now and save output to file"
    exit $(ex 0)
fi

if [ "$argInput" != "" ]; then
    if [ ! -f "$argInput" ]; then exit $(ex 1 "argInput=$argInput does not exist");
    else
        while read -r arg; do
            if [ "$(echo "$arg" | grep -Eio "VERGEN_BASED=\".*\"" | head -1)" != "" ]; then 
                argBased="$(echo "$arg" | sed -E "s/.*VERGEN_BASED=//" | tr -d "\"")"; continue; fi
            if [ "$(echo "$arg" | grep -Eio "VERGEN_BIRTH=\".*\"" | head -1)" != "" ]; then 
                argBirth="$(echo "$arg" | sed -E "s/.*VERGEN_BIRTH=//" | tr -d "\"")"; continue; fi
            if [ "$argBased" != "" ] && [ "$argBirth" != "" ]; then break; fi
        done <"$argInput"
    fi
fi

readonly argBased; readonly argBirth; readonly argInput; readonly argOutput;

if [ "$argBased" = "" ]; then exit $(ex 1 "argBased=\"$argBased\""); fi
if [ "$(echo "$(date -d "$argBirth" 2>&1)" | grep -Eio 'invalid' | head -1)" != "" ]; then exit $(ex 1 "argBirth=\"$argBirth\""); fi

if [ "$(echo "$argBirth" | grep -Eio "UTC|0000" | head -1)" != "" ];
    then birth="$(($(date -u -d "$argBirth" +%s%N 2>&1)))"; now=$(($(date -u +%s%N)));
    else birth="$(($(date -d "$argBirth" +%s%N 2>&1)))"; now=$(($(date +%s%N)));
fi
if [ $birth -gt $now ]; then exit $(ex 1 "argBirth=\"$argBirth\" is greater than now"); fi
readonly birth

bns=$(($now-$birth))
build="$argBased"
if [ "$(echo "$build" | grep -Eio "$BASEYEAR" | head -1)" != ""   ]; then bt=$(($bns/$NSPERYEAR));   bns=$(($bns-($bt*$NSPERYEAR)));   build="$(echo "$build" | sed "s/$BASEYEAR/$bt/g")";   fi
if [ "$(echo "$build" | grep -Eio "$BASEMONTH" | head -1)" != ""  ]; then bt=$(($bns/$NSPERMONTH));  bns=$(($bns-($bt*$NSPERMONTH)));  build="$(echo "$build" | sed "s/$BASEMONTH/$bt/g")";  fi
if [ "$(echo "$build" | grep -Eio "$BASEDAY" | head -1)" != ""    ]; then bt=$(($bns/$NSPERDAY));    bns=$(($bns-($bt*$NSPERDAY)));    build="$(echo "$build" | sed "s/$BASEDAY/$bt/g")";    fi
if [ "$(echo "$build" | grep -Eio "$BASEHOUR" | head -1)" != ""   ]; then bt=$(($bns/$NSPERHOUR));   bns=$(($bns-($bt*$NSPERHOUR)));   build="$(echo "$build" | sed "s/$BASEHOUR/$bt/g")";   fi
if [ "$(echo "$build" | grep -Eio "$BASEMINUTE" | head -1)" != "" ]; then bt=$(($bns/$NSPERMINUTE)); bns=$(($bns-($bt*$NSPERMINUTE))); build="$(echo "$build" | sed "s/$BASEMINUTE/$bt/g")"; fi
if [ "$(echo "$build" | grep -Eio "$BASESECOND" | head -1)" != "" ]; then bt=$(($bns/$NSPERSECOND)); bns=$(($bns-($bt*$NSPERSECOND))); build="$(echo "$build" | sed "s/$BASESECOND/$bt/g")"; fi
if [ "$(echo "$build" | grep -Eio "$BASEMILLI" | head -1)" != ""  ]; then bt=$(($bns/$NSPERMILLI));  bns=$(($bns-($bt*$NSPERMILLI)));  build="$(echo "$build" | sed "s/$BASEMILLI/$bt/g")";  fi
if [ "$(echo "$build" | grep -Eio "$BASEMICRO" | head -1)" != ""  ]; then bt=$(($bns/$NSPERMICRO));  bns=$(($bns-($bt*$NSPERMICRO)));  build="$(echo "$build" | sed "s/$BASEMICRO/$bt/g")";  fi
if [ "$(echo "$build" | grep -Eio "$BASENANO" | head -1)" != ""   ]; then bt=$(($bns/$NSPERNANO));   bns=$(($bns-($bt*$NSPERNANO)));   build="$(echo "$build" | sed "s/$BASENANO/$bt/g")";   fi
readonly build

basedOut="VERGEN_BASED=\"$argBased\""
birthOut="VERGEN_BIRTH=\"$(TZ=UTC date -u -d@$(echo "$birth" | head -c -10).$(echo "$birth" | tail -c -10) +"%Y-%m-%d %H:%M:%S.%4N %Z")\""
buildOut="VERGEN_BUILD=\"$build\""
builtOut="VERGEN_BUILT=\"$(TZ=UTC date -u -d@$(echo "$now" | head -c -10).$(echo "$now" | tail -c -10) +"%Y-%m-%d %H:%M:%S.%4N %Z")\""

if [ "$argOutput" != "" ]; then
    for file in $argOutput; do 
        if [ ! -f "$file" ]; then
            true > "$file"
            echo "Output file created: \"$file\""
        fi

        $(out "VERGEN_BUILT=\".*\"" "$builtOut" "$file")
        $(out "VERGEN_BUILD=\".*\"" "$buildOut" "$file")
        $(out "VERGEN_BIRTH=\".*\"" "$birthOut" "$file")
        $(out "VERGEN_BASED=\".*\"" "$basedOut" "$file")
    done
fi

$(pcf "$TMP" "$basedOut");
$(pcf "$TMP" "$birthOut");
$(pcf "$TMP" "$buildOut");
$(pcf "$TMP" "$builtOut");

exit $(ex 0)
