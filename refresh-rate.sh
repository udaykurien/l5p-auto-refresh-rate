
#!/usr/bin/env bash

set -u

OUTPUT="eDP-1"
RESOLUTION="2560x1600"
LAST_RATE=""

on_ac_power() {
    for supply in /sys/class/power_supply/*; do
        [ -r "$supply/type" ] || continue
        [ -r "$supply/online" ] || continue

        if [ "$(cat "$supply/type")" = "Mains" ] &&
           [ "$(cat "$supply/online")" = "1" ]; then
            return 0
        fi
    done

    return 1
}

while true; do
    if on_ac_power; then
        RATE="165.018997"
    else
        RATE="60.007999"
    fi

    if [ "$RATE" != "$LAST_RATE" ]; then
        if wlr-randr \
            --output "$OUTPUT" \
            --mode "$RESOLUTION@${RATE}Hz"; then

            echo "Display refresh rate changed to $RATE Hz"
            LAST_RATE="$RATE"
        else
            echo "Failed to set refresh rate to $RATE Hz"
        fi
    fi

    sleep 5
done

