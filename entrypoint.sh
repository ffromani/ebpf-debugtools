#!/bin/bash
set -e -o pipefail
# mount Kernel debugfs (needed by bcc and tracing)
/bin/mount -t debugfs none /sys/kernel/debug/
exec "$@"
