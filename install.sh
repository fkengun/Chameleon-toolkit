#!/bin/bash

echo Installing Chameleon Toolkit ...

# Install SSH key
if [ -f keys/id_rsa ] && [ -f keys/id_rsa.pub ]
then
  if [ -f ~/.ssh/id_rsa ] && [ -f ~/.ssh/id_rsa.pub ]
  then
    diff_pri=`diff keys/id_rsa ~/.ssh/id_rsa 2>&1`
    diff_pub=`diff keys/id_rsa.pub ~/.ssh/id_rsa.pub 2>&1`
    if [[ ${#diff_pri} != 0 || ${#diff_pub} != 0 ]]
    then
      echo "Keys in ./keys and ~/.ssh are different"
      echo "Continue to install? [yes/no]"
      read cont
      if [[ "$cont" == "yes" ]]
      then
        echo 'Overwriting ...'
        cp keys/id_rsa ~/.ssh/id_rsa
        chmod 600 ~/.ssh/id_rsa
        cp keys/id_rsa.pub ~/.ssh/id_rsa.pub
        chmod 644 ~/.ssh/id_rsa.pub
      else
        echo 'No overwrite, exit'
        exit
      fi
    else
      echo 'Keys already exist and match with the pair in ./keys'
    fi
  else
    echo 'Copying keys into ~/.ssh ...'
    cp keys/id_rsa ~/.ssh/id_rsa
    chmod 600 ~/.ssh/id_rsa
    cp keys/id_rsa.pub ~/.ssh/id_rsa.pub
    chmod 644 ~/.ssh/id_rsa.pub
  fi
else
  echo Please put your SSH keys into folder keys
  exit
fi

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

echo ""
echo "Chameleon Toolkit is installed"
echo ""
echo "*****************************************************************************"
echo -e "Scripts and Commands\t\tNotes"
echo "-----------------------------------------------------------------------------"
echo -e "~/sync_hosts.sh: \t\tgenerate /etc/hosts file to wire up instances"
echo -e "~/cc-snapshot: \t\t\tmake an image"
echo -e "sync_file/sync_folder: \t\tsynchronize file/path"
echo "*****************************************************************************"
