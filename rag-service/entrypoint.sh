#!/bin/bash

set -e

if [[ "${MODE}" == "keep" ]]; then
  echo "Starting keep debug process"
  tail -f /dev/null
else
  echo "Starting in ${MODE} mode"

  jupyter notebook --ip=0.0.0.0 --no-browser --allow-root
fi
