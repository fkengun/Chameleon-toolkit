#!/usr/bin/env python

import os
import socket
import argparse
import subprocess
import collections
import multiprocessing as mp

client_home = "/home/cc/blazarclient"
output_file = "./id.mac.rack"
step = mp.cpu_count() / 2

class Node:
  id = ""
  mac = ""
  rack = ""

  def __init__(self, id, mac, rack):
    self.id = id
    self.mac = mac
    self.rack = rack

  def __str__(self):
    if not self.mac:
      self.mac = "\t\t\t"
    if not self.rack:
      self.rack = "\t"
    return "%s\t\t%s\t\t%s" % (self.id, self.mac, self.rack)

def get_node_list():
  output, error = run_cmd("(%s/bin/climate host-list 2>&1) | grep \"|\" \
      | grep -v cpu | awk '{print $2}' | sort -n" % (client_home))
  node_list = output.splitlines()
  return node_list

def get_mac_rack_by_id(id, nodes):
  mac, error = run_cmd("(%s/bin/climate host-show %s 2>&1) | \
      grep \"network_adapters.0.mac\" | awk '{print $4}'" % (client_home, id))
  rack, error = run_cmd("(%s/bin/climate host-show %s 2>&1) | \
      grep \"placement.rack\" | awk '{print $4}'" % (client_home, id))
  node = Node(id, mac.rstrip(), rack.rstrip())
  nodes[id] = node

def parse_cmd_args():
  parser = argparse.ArgumentParser()
  group = parser.add_mutually_exclusive_group()
  group.add_argument("-a", "--all", action="store_true",
      help="get host id, MAC and rack id of all nodes")
  group.add_argument("-i", "--hostid",
      help="get host id, MAC and rack id of host with given id")
  group.add_argument("-m", "--mac",
      help="get host id, MAC and rack id of host with MAC")
  group.add_argument("-f", "--hostfile", type=str,
      help="get host id, MAC and rack id of hosts in host file")
  args = parser.parse_args()
  return args.all, args.hostid, args.mac, args.hostfile

def run_cmd(command):
  process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
  output, error = process.communicate()
  return output, error

def write_list_to_file(l, file_name):
  with open(file_name, 'a') as f:
    for e in l.values():
      f.write("%s\n" % e.__str__())
    f.flush()
    f.close()

def searchHosts(hostfile):
  with open(hostfile, 'r') as f:
    for host in f:
      mac, error = run_cmd("ssh %s 'if [ -e /sys/class/net/eth0/address ]; \
          then cat /sys/class/net/eth0/address; fi'" % host.rstrip())
      if not mac:
        mac, error = run_cmd("ssh %s 'if [ -e /sys/class/net/eno1/address ]; \
            then cat /sys/class/net/eno1/address; fi'" % host.rstrip())
      output, error = run_cmd("(grep -i %s %s)" % (mac.rstrip(), output_file))
      if output:
        print "%s:\t\t%s" % (host.rstrip(), output.rstrip())
    f.close()

if __name__ == "__main__":
  all, hostid, mac, hostfile = parse_cmd_args()

  if all:
    print "getting all info, it takes 1~2 mins ..."
    if os.path.isfile(output_file):
      os.remove(output_file)

    node_list = get_node_list()
    step_count = len(node_list) / step
    manager = mp.Manager()
    nodes = manager.dict()
    for s in range(0, step_count):
      ids = node_list[s*step : (s+1)*step]
      jobs = []
      for i in ids:
        p = mp.Process(target=get_mac_rack_by_id, args=(i, nodes))
        jobs.append(p)
        p.start()

      for proc in jobs:
        proc.join()
    write_list_to_file(nodes, output_file)
    print "host id, MAC and rack id have been stored in %s\n" % output_file
  else:
    if not os.path.isfile(output_file):
      print "%s does not exist, re-run with -a first" % output_file
    else:
      output = ''
      error = ''
      if hostid or mac:
        if hostid:
          print "searching with host id ..."
          output, error = run_cmd("grep -i %s %s" % (hostid, output_file))
        elif mac:
          print "searching with MAC ..."
          output, error = run_cmd("grep -i %s %s" % (mac, output_file))
        if output:
          print output.rstrip()
        else:
          print "No host found"
      if hostfile:
        print "searching for hosts in %s ..." % hostfile
        searchHosts(hostfile)
