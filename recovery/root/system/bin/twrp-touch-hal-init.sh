#!/system/bin/sh

HBP=/sys/devices/platform/soc/soc:hbp@0
ODM_SERVICE=/odm/bin/hw/vendor-oplus-hardware-touch-V2-hbp5-service
ODM_CONFIG=/odm/firmware/tp/prado/vnd_touch_project_config.xml
SLOT="$(getprop ro.boot.slot_suffix)"

if [ -z "$SLOT" ]; then
    SLOT="_b"
fi

ODM_DEV="/dev/block/mapper/odm${SLOT}"

i=0
while [ "$i" -lt 10 ] && [ ! -e "$ODM_DEV" ]; do
    sleep 1
    i=$((i + 1))
done

if ! grep -q " /odm " /proc/mounts 2>/dev/null && [ -e "$ODM_DEV" ]; then
    mkdir -p /odm
    mount -t erofs -o ro "$ODM_DEV" /odm
fi

if [ -e "$HBP/irq_enable" ]; then
    echo 0,1 > "$HBP/irq_enable"
fi

if [ -e "$HBP/debug_level" ]; then
    echo 2 > "$HBP/debug_level"
fi

dmesg -n 1 >/dev/null 2>&1

i=0
while [ "$i" -lt 5 ] && { [ ! -x "$ODM_SERVICE" ] || [ ! -f "$ODM_CONFIG" ]; }; do
    sleep 1
    i=$((i + 1))
done

if [ -x "$ODM_SERVICE" ] && [ -f "$ODM_CONFIG" ] && [ -f /vendor/manifest.xml ]; then
    setprop ctl.restart servicemanager
    setprop ctl.restart vndservicemanager
    setprop ctl.restart hwservicemanager
    sleep 3
    setprop sys.twrp_touch_ready 1
    sleep 2
    if [ -e "$HBP/irq_enable" ]; then
        echo 0,1 > "$HBP/irq_enable"
    fi
    if [ -e "$HBP/debug_level" ]; then
        echo 2 > "$HBP/debug_level"
    fi
fi
