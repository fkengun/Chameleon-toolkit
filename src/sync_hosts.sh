#!/bin/bash

while true
do
  echo "Enter the string used to filter out your instances: "
  read grep_str
  res=`python ~/novahosts.py $grep_str 2>&1`
  if [[ $res ]]
  then
    echo $res
    echo "Fail to run novahosts.py"
    exit -1
  fi
  nins=`cat /dev/shm/hosts | wc -l`
  if [[ $nins == 0 ]]
  then
    echo No instance found
    continue
  fi
  echo "These are the instances:"
  cat /dev/shm/hosts
  echo "Are they correct? [yes/no]:"
  read correct
  if [[ "$correct" == "yes" ]]
  then
    sudo sh -c "cat /dev/shm/hosts > /etc/hosts" && rm -f /dev/shm/hosts
    break
  elif [[ "$correct" == "no" ]]
  then
    continue
  fi
done
cat /etc/hosts | awk '{print $2}' > ~/nodes

HOSTS=`cat /etc/hosts | grep -v ib | awk '{print $2}'`
IPS=`cat /etc/hosts | grep -v ib | awk '{print $1}'`

rm -f ~/.ssh/known_hosts
for host in $HOSTS
do
  ssh-keyscan -H $host >> ~/.ssh/known_hosts
done

for ip in $IPS
do
  ssh-keyscan -H $ip >> ~/.ssh/known_hosts
done

for host in $HOSTS
do
  echo "Copying to node $host ..."
  scp -q /etc/hosts $host:/home/cc/hosts
  scp -q ~/nodes $host:/home/cc/nodes
  scp -q ~/.ssh/* $host:/home/cc/.ssh/
  scp -q ~/.bashrc $host:/home/cc/.bashrc
  scp -q ~/.bash_aliases $host:/home/cc/.bash_aliases
done

echo "Synchronizing ..."
mpssh -bf ~/nodes "sudo mv /home/cc/hosts /etc/hosts" > /dev/null 2>&1
