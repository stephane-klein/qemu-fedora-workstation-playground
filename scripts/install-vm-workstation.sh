#!/usr/bin/env bash
set -e

cd "$(dirname "$0")/../"

ssh-keygen -R "[localhost]:2222"
ssh -t -o StrictHostKeyChecking=no -p 2222 fedora@localhost "bash -s" < _payload_install-vm-workstation.sh

while ! ssh -q -o ConnectTimeout=5 -o BatchMode=yes -o StrictHostKeyChecking=no -p 2222 fedora@localhost exit&>/dev/null; do
  echo "Wait SSH ready..."
  sleep 5
done
echo "SSH is ready, VM is up!"
