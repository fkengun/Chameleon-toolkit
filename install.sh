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
sline=`cat ~/.bash_aliases | grep -n 'directory synchronization' | head -1 | cut -d':' -f1`
eline=`cat ~/.bash_aliases | grep -n 'directory synchronization' | tail -1 | cut -d':' -f1`
sed -i "$sline,$eline d" ~/.bash_aliases
echo "# Start of commands for file and directory synchronization" >> ~/.bash_aliases
cat src/bash_aliases >> ~/.bash_aliases
echo "# End of commands for file and directory synchronization" >> ~/.bash_aliases

# Install sync_hosts.sh
cp src/novahosts.py ~/
cp src/sync_hosts.sh ~/

echo "Chameleon Toolkit is installed"
echo "*****************************************************************************"
echo -e "Scripts and Commands\t\tNotes"
echo "-----------------------------------------------------------------------------"
echo -e "sync_hosts.sh: \t\t\tgenerate /etc/hosts file to wire up instances"
echo -e "sync_file/sync_folder: \t\tsynchronize file/path"
echo -e "cc-snapshot: \t\t\tmake an image"
echo "*****************************************************************************"
