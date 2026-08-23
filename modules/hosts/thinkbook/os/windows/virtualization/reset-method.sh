set -eu

domain="$1"
operation="$2"
phase="$3"

resetMethod="/sys/bus/pci/devices/0000:56:00.0/reset_method"

if [ "$domain" != "windows" ]; then
    exit 0
fi

case "$operation:$phase" in
    "prepare:begin")
        echo bus > "$resetMethod"
        ;;

    "release:end")
        echo default > "$resetMethod"
        ;;
esac
