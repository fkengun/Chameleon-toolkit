# Tools
* cc-snapshot
* sync_file and sync_folder command
* sync_hosts.sh
***

# cc-snapshot

cc-snapshot takes snapshots of baremetal instances on the Chameleon testbed.

## Dependencies

The script requires the following dependencies:

* Ubuntu or CentOS system
* Baremetal instance

## Usage

**Use this script from a Chameleon baremetal instance**. To snapshot a baremetal instance, when logged into the instance via SSH, run cc-snapshot with the following command:

```
sudo cc-snapshot [snapshot_name]
```

You can optionally specify a snapshot name. If no argument is present, the snapshot name follows the format of yourname-snapshot-date.

cc-snapshot will ask for your Chameleon password, and after a few minutes, a snapshot will be uploaded in the image repository of the instance's site (UC or TACC).

# sync_file and sync_folder

## ~/nodes file

~/nodes plays an very important role. It is expected to keep record of hostnames of all nodes created by you. sync_file and sync_folder replie on it. **You need to be sure that all nodes are listed in the file.**

sync_file and sync_folder are two command created to synchronize files across all nodes. Since there is no shared global file system in Chameleon, files which are supposed to the same across all nodes (e.g. executables, configurations)  need to be synchronized.

## Usage:

```
sync_file [-q|--quiet] file
sync_folder [-q|--quiet] path
```

**Only one file/path is supported currently. If multiple files/paths are given, only the first one will be synchronized**

# sync_hosts.sh

sync_hosts.sh is script to generate /etc/hosts file and synchronize across all nodes so that each node knows its siblings. sync_hosts.sh relies on ~/nodes file as well. **Please be sure ~/nodes has all nodes listed.**
