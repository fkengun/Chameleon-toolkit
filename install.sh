#!/bin/bash

echo Installing Chameleon Toolkit ...

# Install SSH key
if [ -a keys/id_rsa ] && [ -a keys/id_rsa.pub ]
then
  cp keys/id_rsa ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  cp keys/id_rsa.pub ~/.ssh/id_rsa.pub
  chmod 644 ~/.ssh/id_rsa.pub
else
  echo Please put your SSH keys into folder keys
  exit
fi

# Install aliases (sync_file, sync_folder)
cp src/bash_aliases ~/.bash_aliases

# Install sync_hosts.sh
cp src/novahosts.py ~/
cp src/sync_hosts.sh ~/
