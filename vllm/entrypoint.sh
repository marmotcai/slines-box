 #!/bin/bash

echo "Starting Ray with ${NODE_TYPE}"
echo "Head node address: ${HEAD_NODE_ADDRESS}"

# Command setup for head or worker node
if [[ "${NODE_TYPE}" == "head" ]]; then
    echo "Starting head node..."
    ray start --block --head --port=${SERVICE_PORT}
else
    echo "Starting worker node..."
    ray start --block --address="${HEAD_NODE_ADDRESS}"
fi
tail -f /dev/null