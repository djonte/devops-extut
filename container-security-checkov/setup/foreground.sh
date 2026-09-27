#!/bin/bash

clear
echo -n "Preparing the tutorial"

while [[ ! -f /tmp/tutorial-ready && ! -f /tmp/tutorial-setup-failed ]]; do
  echo -n "."
  sleep 1
done

echo

if [[ -f /tmp/tutorial-setup-failed ]]; then
  echo "Setup failed. Restart the scenario or ask the tutorial authors for help."
  exit 1
fi

echo "Ready. The tutorial files are in /root/tutorial."
