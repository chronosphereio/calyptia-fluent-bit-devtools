#!/bin/bash
set -eux
SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

SOURCE_DIR=${SOURCE_DIR:-$SCRIPT_DIR}
CONTAINER_RUNTIME=${CONTAINER_RUNTIME:-docker}

# Refer to https://github.com/lpenz/ghaction-cmake for more details on options
TEST_PRESET=${TEST_PRESET:-coverage}

# From the Fluent Bit Dockerfile
FLB_CMAKE_OPTIONS=${FLB_CMAKE_OPTIONS:--DFLB_BACKTRACE=Off -DFLB_SHARED_LIB=Off -DFLB_DEBUG=On -DFLB_ALL=On -DFLB_EXAMPLES=Off -DFLB_TESTS_INTERNAL=On -DFLB_TESTS_RUNTIME=On}
ADDITIONAL_DEPS=${ADDITIONAL_DEPS:-libssl-dev libsasl2-dev pkg-config libsystemd-dev zlib1g-dev libpq-dev postgresql-server-dev-all flex bison libyaml-dev}

# From the Unit Tests script
SKIP_TESTS=${SKIP_TESTS:-flb-rt-out_elasticsearch flb-it-network flb-it-fstore flb-rt-out_elasticsearch flb-rt-out_td flb-rt-out_forward flb-rt-in_disk flb-rt-in_proc}

SKIP=""
for skip in $SKIP_TESTS
do
    SKIP="$SKIP -DFLB_WITHOUT_${skip}=1"
done

# Check we have an actual Fluent Bit source directory
if [[ ! -d "$SOURCE_DIR" ]]; then
    echo "ERROR: no SOURCE_DIR directory"
    exit 1
elif [[ ! -f "$SOURCE_DIR"/CMakeLists.txt ]]; then
    echo "ERROR: no CMakeLists.txt found in SOURCE_DIR"
    exit 1
fi

# Run the action we want on it
"$CONTAINER_RUNTIME" run --rm -t -u "$UID" -w "/source" -v "${SOURCE_DIR}:/source" \
    -e INPUT_PRESET="$TEST_PRESET" \
    -e INPUT_DEPENDENCIES_DEBIAN="$ADDITIONAL_DEPS" \
    -e INPUT_CMAKEFLAGS="$FLB_CMAKE_OPTIONS $SKIP" \
    lpenz/ghaction-cmake:0.16
