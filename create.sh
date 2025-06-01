#!/bin/bash

set -e

echo "[*] Building Docker image for hytracer/pwndocker..."
docker build --platform=linux/amd64 . -t hytracer/pwndocker

read -p "[?] Bind $HOME/CTF to /CTF in the container? [y/n] " -n 1 -r bind
echo
read -p "[?] Start in background? [y/n] " -n 1 -r bg
echo

if [[ $bind =~ ^[Yy]$ ]]; then
    echo "[*] Mounting ~/CTF into the container..."
    mkdir -p "$HOME/CTF"
    volume="-v $HOME/CTF:/CTF:rw"
    destroy=""
else
    echo "[*] Mounting current directory into the container (ephemeral)..."
    volume="-v $(pwd):/CTF:rw"
    destroy="--rm"
fi

if [[ $bg =~ ^[Yy]$ ]]; then
    mode="-d"
    startup_mode="daemon"
else
    mode=""
    startup_mode="interactive"
fi

if docker ps -a --format '{{.Names}}' | grep -q '^pwndocker$'; then
    echo "[!] Removing existing container named 'pwndocker'..."
    docker rm -f pwndocker
fi

echo "[+] Starting container with mode: $startup_mode"

docker run --interactive --tty \
    $volume \
    $destroy \
    --platform linux/amd64 \
    --security-opt seccomp=unconfined \
    --cap-add=SYS_PTRACE \
    -p 1337:1337 \
    -p 2222:22 \
    --name pwndocker \
    hytracer/pwndocker \
    /startup.sh "$startup_mode"

if [[ $bg =~ ^[Yy]$ ]]; then
    echo "[+] Started in background."
    echo "[*] Connect via: ssh -p 2222 -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no root@localhost"
fi
