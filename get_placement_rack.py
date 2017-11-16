import os
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
  command = "(%s/bin/climate host-list 2>&1) | grep \"|\" | grep -v cpu | awk '{print $2}' | sort -n" % (client_home)
  process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
  output, error = process.communicate()
  node_list = output.splitlines()
  return node_list

def get_mac_rack_by_id(id, nodes):
  command = "(%s/bin/climate host-show %s 2>&1) | grep \"network_adapters.0.mac\" | awk '{print $4}'" % (client_home, id)
  process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
  mac, error = process.communicate()
  command = "(%s/bin/climate host-show %s 2>&1) | grep \"placement.rack\" | awk '{print $4}'" % (client_home, id)
  process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
  rack, error = process.communicate()
  node = Node(id, mac.rstrip(), rack.rstrip())
  nodes[id] = node

if __name__ == "__main__":
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

  with open('./id.mac.rack', 'a') as f:
    for node in nodes.values():
      f.write("%s\n" % node.__str__())
    f.flush()
    f.close()

  print "host id, MAC and rack id have been stored in %s\n" % output_file
