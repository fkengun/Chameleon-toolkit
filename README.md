# Tools
* cc-snapshot
* commands (`sync_file`, `sync_folder`, `collect`)
* sync_hosts.sh

# cc-snapshot

cc-snapshot takes snapshots of baremetal instances on the Chameleon testbed.

### Dependencies

The script requires the following dependencies:

* Ubuntu or CentOS system
* Baremetal instance

### Usage

**Use this script from a Chameleon baremetal instance**. To snapshot a baremetal instance, when logged into the instance via SSH, run cc-snapshot with the following command:

```
sudo cc-snapshot [snapshot_name]
```

You can optionally specify a snapshot name. If no argument is present, the snapshot name follows the format of yourname-snapshot-date.

cc-snapshot will ask for your Chameleon password, and after a few minutes, a snapshot will be uploaded in the image repository of the instance's site (UC or TACC).

# Commands

### Dependencies

* **~/nodes file**.
`~/nodes` plays an very important role. It is expected to keep record of hostnames of all nodes created by you. All following commands rely on it. **You need to be sure that all nodes are listed in the file.**

### sync_file and sync_folder

`sync_file` and `sync_folder` are two commands created to synchronize files across all nodes. Since there is no shared global file system in Chameleon, files which are supposed to the same across all nodes (e.g. executables, configurations) need to be synchronized when any copy on any node is modified.

### collect

`collect` is the command to gather files in the same path across all nodes to one node. This is usually used when node-local files (e.g. data, logs, configurations) need to be opened in one node.

### Usage:

```
sync_file [-q|--quiet] file
sync_folder [-q|--quiet] path
```

**Only one file/path is supported currently. If multiple files/paths are given, only the first one will be synchronized**

```
collect [-q|--quiet] file [{-t|--target} target_path]
```

**If the target path is not specified, the current directory will be set as the default target path**

### Optional packages

**[MPSSH - Mass Parallel Secure Shell](https://github.com/ndenev/mpssh)**
MPSSH can spawn multiple processes to SSH to nodes and run commands in parallel. To install MPSSH:

* On CentOS:
    ```
    sudo yum install mpssh
    ```
* On Ubuntu:
    There is no MPSSH in official repo. Please build it from source code.
    
# sync_hosts.sh

### Dependencies

Your OpenStack RC file from Chameleon needs to sourced to collect your username and password. Please download it from [HERE (TACC)](https://chi.tacc.chameleoncloud.org/dashboard/project/access_and_security/) or [HERE (UC)](https://chi.uc.chameleoncloud.org/dashboard/project/access_and_security/) using the "Download OpenStack RC File" button in "API Access" tab.

`sync_hosts.sh` is script to generate `/etc/hosts` file and synchronize across all nodes so that each node knows its siblings. It needs to be run once when all nodes boot up or new nodes are added. `sync_hosts.sh` relies on `~/nodes` file as well. **Please be sure `~/nodes` has all nodes listed.**
