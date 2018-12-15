#!/bin/bash

echo Installing Chameleon Toolkit ...

# Install SSH key
echo Installing SSH keys ...
if [ -f ssh_keys/id_rsa ] && [ -f ssh_keys/id_rsa.pub ]
then
  if [ -f ~/.ssh/id_rsa ] && [ -f ~/.ssh/id_rsa.pub ]
  then
    diff_pri=`diff ssh_keys/id_rsa ~/.ssh/id_rsa 2>&1`
    diff_pub=`diff ssh_keys/id_rsa.pub ~/.ssh/id_rsa.pub 2>&1`
    if [[ ${#diff_pri} != 0 || ${#diff_pub} != 0 ]]
    then
      echo "SSH keys in ./ssh_keys and ~/.ssh are different"
      echo "Continue to install? [yes/no]"
      read cont
      if [[ "$cont" == "yes" ]]
      then
        echo 'Overwriting ...'
        cp ssh_keys/id_rsa ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        cp ssh_keys/id_rsa.pub ~/.ssh/id_rsa.pub
        chmod 644 ~/.ssh/id_rsa.pub
      else
        echo 'No overwrite, exit'
        exit
      fi
    else
      echo 'SSH keys already exist and match with the pair in ./ssh_keys'
    fi
  else
    echo 'Copying SSH keys into ~/.ssh ...'
    cp ssh_keys/id_rsa ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    cp ssh_keys/id_rsa.pub ~/.ssh/id_rsa.pub
    chmod 644 ~/.ssh/id_rsa.pub
  fi
else
  echo "Cannot find SSH keys in ./ssh_keys"
  echo "Please make sure your private and public keys are stored in ./ssh_keys/id_rsa and ./ssh_keys/id_rsa.pub respectively"
  exit
fi

# Install fm.sh
echo Installing helper script to flush memory cache ...
cp src/fm.sh ~/fm.sh

# Install aliases (sync_file, sync_folder)
echo "Installing helper command (sync_file, sync_folder etc) ..."
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
echo Installing helper script to wire up instances ...
cp src/novahosts.py ~/
cp src/sync_hosts.sh ~/
cp src/cc-snapshot ~/

# Install get_placement_rack.py
echo Installing helper script to get rack id of instance ...
cp src/get_placement_rack.py ~/

echo ""
echo "Chameleon Toolkit is installed"
echo ""
echo "**************************************************************************************"
echo -e "Helper Scripts and Commands\tNotes"
echo "--------------------------------------------------------------------------------------"
echo -e "~/sync_hosts.sh\t\t\tgenerate /etc/hosts file to wire up instances"
echo -e "~/get_placement_rack.py\t\tget rack id of instance"
echo -e "~/cc-snapshot\t\t\tmake a snapshot image"
echo -e "sync_file\t\t\tsynchronize file across all instances"
echo -e "sync_folder\t\t\tsynchronize files in path across all instances"
echo -e "collect\t\t\t\tcollect files from all instaces to current instance"
echo "**************************************************************************************"
