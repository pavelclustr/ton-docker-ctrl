#!/bin/bash

if [ "$TELEMETRY" == "false" ]; then
    T_FLAG="-t";
fi

if [ "$IGNORE_MINIMAL_REQS" == "true" ]; then
    I_FLAG="-i";
fi

if [ "$DUMP" == "true" ] ; then
    D_FLAG="-d";
fi

echo "install.sh $T_FLAG $I_FLAG $D_FLAG -b mytonctrl2 -c $GLOBAL_CONFIG_URL"

/bin/bash install.sh $T_FLAG $I_FLAG $D_FLAG -b mytonctrl2 -c $GLOBAL_CONFIG_URL