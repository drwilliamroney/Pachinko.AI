podman build -t pachinko -f Dockerfile .
podman network create pachinko 
podman run --detach --network pachinko -p 6817:6817 -v pachinko:/root/.pachinko --name slurmctl -h slurmctl pachinko  /bin/sh -c "/usr/local/bin/start_controller.sh"
podman run --detach --network pachinko -p 8888:8888 -v pachinko:/root/.pachinko --name slurmjupyter -h slurmjupyter pachinko  /bin/sh -c "/usr/local/bin/start_jupyter.sh"
podman run --detach --network pachinko -v pachinko:/root/.pachinko --name slurmnode1 -h slurmnode1 --memory=4g --cpus=2 pachinko  /bin/sh -c "/usr/local/bin/start_node.sh"
podman run --detach --network pachinko -v pachinko:/root/.pachinko --name slurmnode2 -h slurmnode2 --memory=4g --cpus=2 pachinko  /bin/sh -c "/usr/local/bin/start_node.sh"
podman run --detach --network pachinko --name ollama --gpus=all -p 11434:11434 -v ollama:/root/.ollama ollama
