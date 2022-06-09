#!/bin/bash

# shellcheck disable=SC1091

set -o errexit
set -o nounset
set -o pipefail
# set -o xtrace # Uncomment this line for debugging purposes

# Load libraries
. /opt/drycc/scripts/liblog.sh
. /opt/drycc/scripts/libzookeeper.sh

# Load ZooKeeper environment variables
. /opt/drycc/scripts/zookeeper-env.sh

if [[ "$*" = *"/opt/drycc/scripts/zookeeper/run.sh"* || "$*" = *"/run.sh"* ]]; then
    info "** Starting ZooKeeper setup **"
    /opt/drycc/scripts/zookeeper/setup.sh
    info "** ZooKeeper setup finished! **"
fi

echo ""
exec "$@"
