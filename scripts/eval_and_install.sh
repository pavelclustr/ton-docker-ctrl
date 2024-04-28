#!/bin/bash

if [ "$TELEMETRY" == "false" ] && \
    [ "$IGNORE_MINIMAL_REQS" == "true" ] && \
    [ "$DUMP" == "true" ] ; then \
          T_FLAG="-t"; \
          I_FLAG="-i"; \
          D_FLAG="-d"; \
fi

echo "install.sh $T_FLAG $I_FLAG $D_FLAG -b mytonctrl2 -c $GLOBAL_CONFIG_URL"

/bin/bash install.sh $T_FLAG $I_FLAG $D_FLAG -b mytonctrl2 -c $GLOBAL_CONFIG_URL