import os
import subprocess
import collections
import multiprocessing as mp

CLIENT_HOME = "/home/cc/blazarclient"
MIN_HOST_ID = 1
MAX_HOST_ID = 1024

class Node:
  id = ""
  mac = ""
  rack = ""

  def __init__(self, id, mac, rack):
    self.id = id
    self.mac = mac
    self.rack = rack

  def __str__(self):
    return "%4d\t\t%s\t\t%s" % (self.id, self.mac, self.rack)

def get_mac_rack_by_id(id, nodes):
  command = "(%s/bin/climate host-show %s 2>&1) | grep \"network_adapters.0.mac\" | awk '{print $4}'" % (CLIENT_HOME, id)
  process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
  mac, error = process.communicate()
  command = "(%s/bin/climate host-show %s 2>&1) | grep \"placement.rack\" | awk '{print $4}'" % (CLIENT_HOME, id)
  process = subprocess.Popen(command, stdout=subprocess.PIPE, shell=True)
  rack, error = process.communicate()
  if mac:
    node = Node(id, mac.rstrip(), rack.rstrip())
    nodes[id] = node

if __name__ == "__main__":
  if os.path.isfile("./id.mac.rack"):
    os.remove("./id.mac.rack")

  step = 12
  step_count = (MAX_HOST_ID - MIN_HOST_ID) / step
  for s in range(0, step_count):
    ids = range(MIN_HOST_ID + s * step, min(MAX_HOST_ID, MIN_HOST_ID + (s+1) * step))
    manager = mp.Manager()
    nodes = manager.dict()
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
