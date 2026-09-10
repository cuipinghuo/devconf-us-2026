#!/bin/bash
set -euo pipefail

if [ $# -eq 0 ]; then
    echo "Error: Demo number is required."
    echo "Usage: docker run <image> [1|2|3|4]"
    exit 1
fi

DEMO_NUM="$1"

case "$DEMO_NUM" in
    1)
        cd /demos/demo1
        ./demo1.sh
        ;;
    2)
        cd /demos/demo2
        ./demo2.sh
        ;;
    3)
        cd /demos/demo3
        ./demo3.sh
        ;;
    4)
        cd /demos/demo4
        ./demo4.sh
        ;;
    *)
        echo "Error: Invalid demo number. Please specify 1, 2, 3, or 4."
        echo "Usage: docker run <image> [1|2|3|4]"
        exit 1
        ;;
esac
