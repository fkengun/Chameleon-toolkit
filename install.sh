#!/bin/bash

echo Installing Chameleon Toolkit ...

# Install SSH key
if [ -f keys/id_rsa ] && [ -f keys/id_rsa.pub ]
then
  cp keys/id_rsa ~/.ssh/id_rsa
  chmod 600 ~/.ssh/id_rsa
  cp keys/id_rsa.pub ~/.ssh/id_rsa.pub
  chmod 644 ~/.ssh/id_rsa.pub
else
  echo Please put your SSH keys into folder keys
  exit
fi

# Check if MPSSH is installed
command -v mpssh > /dev/null 2>&1 || { echo >&2 "MPSSH is required. Aborting."; exit 1; }

# Install fm.sh
cp src/fm.sh ~/fm.sh

# Install aliases (sync_file, sync_folder)
if [[ -f ~/.bash_aliases ]]
then
  sline=`cat ~/.bash_aliases | grep -n 'directory synchronization' | head -1 | cut -d':' -f1`
  eline=`cat ~/.bash_aliases | grep -n 'directory synchronization' | tail -1 | cut -d':' -f1`
  if [[ $sline ]] && [[ $eline ]]; then
    sed -i "$sline,$eline d" ~/.bash_aliases
  fi
fi
echo "# Start of commands for file and directory synchronization" >> ~/.bash_aliases
cat src/bash_aliases >> ~/.bash_aliases
echo "# End of commands for file and directory synchronization" >> ~/.bash_aliases
source ~/.bashrc

# Enable aliases
if [[ -f ~/.bashrc ]] && ! grep -Fq ". ~/.bash_aliases" ~/.bashrc
then
  echo "if [[ -f ~/.bash_aliases ]]; then" >> ~/.bashrc
  echo -e "\t. ~/.bash_aliases" >> ~/.bashrc
  echo "fi" >> ~/.bashrc
fi

# Install sync_hosts.sh
cp src/novahosts.py ~/
cp src/sync_hosts.sh ~/
cp src/cc-snapshot ~/

echo "Chameleon Toolkit is installed"
echo ""
echo "*****************************************************************************"
echo -e "Scripts and Commands\t\tNotes"
echo "-----------------------------------------------------------------------------"
echo -e "~/sync_hosts.sh: \t\t\tgenerate /etc/hosts file to wire up instances"
echo -e "~/cc-snapshot: \t\t\tmake an image"
echo -e "sync_file/sync_folder: \t\tsynchronize file/path"
echo "*****************************************************************************"
