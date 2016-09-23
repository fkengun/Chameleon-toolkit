#!/bin/bash

python ~/novahosts.py | sort > /etc/hosts
cat /etc/hosts | awk '{print $2}' > ~/nodes

HOSTS=`cat /etc/hosts | grep -v ib | awk '{print $2}'`
IPS=`cat /etc/hosts | grep -v ib | awk '{print $1}'`

rm ~/.ssh/known_hosts
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
mpssh -bf ~/nodes "sudo mv ~/hosts /etc/hosts" > /dev/null 2>&1
