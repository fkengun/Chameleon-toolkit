# Introduction
Chameleon toolkit is designed to facilitate using the Chameleon Cloud cluster. It provides several helper commands and scripts to assist users on basic operations on Chameleon, such as authentication, network connection, file synchronization etc. It includes three commands and three scripts:
## Helper Commands
* sync_file: synchronize file on current instance to all instances
* sync_folder: synchronize files in a directory on current instance to all instances
* collect: collect files on all instances to current instance
## Helper Scripts
* cc-snapshot: make a snapshot image
* sync_hosts.sh: generates /etc/hosts file to wire up instances
* fm.sh: flush memory cache
---

# Installation
To download the toolkit, run
```
git clone https://github.com/fkengun/Chameleon-toolkit.git
```
**Put the SSH keys you use to access Chameleon into the directory ssh_keys (including both private and public keys)** and run
```
cd Chameleon-toolkit
./install.sh
```

---
# User Guide
## Required Dependencies
The script requires the following dependencies:
* Baremetal instance running Ubuntu or CentOS
* OpenStack RC file. It needs to sourced to collect your username and password. Please download it from [HERE (TACC)](https://chi.tacc.chameleoncloud.org/dashboard/project/access_and_security/) or [HERE (UC)](https://chi.uc.chameleoncloud.org/dashboard/project/access_and_security/) using the "Download OpenStack RC File" button in "API Access" tab.
* `~/nodes` file. `~/nodes` plays an very important role. It is expected to keep record of hostnames of all instances created by you. All following commands and scripts rely on it. **You need to be sure that all instances are listed in the file.**
## Optional Dependencies
**[MPSSH - Mass Parallel Secure Shell](https://github.com/ndenev/mpssh)**
MPSSH can spawn multiple SSH processes to instances and run commands in parallel. It will help speeding up remote commands over SSH to multiple instances. It can reduce the time to execute all helper commands and scripts especially when the number of instances goes very large. To install MPSSH:
* On CentOS:
    ```
    sudo yum install mpssh
    ```
* On Ubuntu:
    There is no MPSSH in official repo. Please build it from source code.

## Usage
### Helper Scripts
* #### cc-snapshot
    **Use this script from a Chameleon baremetal instance**. To snapshot a baremetal instance, when logged into the instance via SSH, run cc-snapshot with the following command:
    ```
    sudo cc-snapshot [snapshot_name]
    ```
    You can optionally specify a snapshot name. If no argument is present, the snapshot name follows the format of yourname-snapshot-date.
    cc-snapshot will ask for your Chameleon password, and after a few minutes, a snapshot will be uploaded in the image repository of the instance's site (UC or TACC).
* #### sync_hosts.sh
    `sync_hosts.sh` is a script to generate `/etc/hosts` file and synchronize across all instances so that each instance knows its siblings. It needs to be run once when all instances boot up or new instances are added. `sync_hosts.sh` relies on `~/nodes` file as well. **Please be sure `~/nodes` has all instances listed.**
* #### fm.sh
    `fm.sh` is a script to flush the memory cache to guarantee all files are actually read from the storage devices. To use it, simply run
    ```
    sudo ~/fm.sh
    ```
    You can combine it with MPSSH to flush memory cache on all instances as follows:
    ```
    mpssh -f ~/nodes "sudo ~/fm.sh"
    ```
### Helper Commands
* #### sync_file and sync_folder
    `sync_file` and `sync_folder` are two commands created to synchronize files across all instances. Since there is no shared global file system in Chameleon, files which are supposed to the same across all instances (e.g. executables, configurations) need to be synchronized when any copy on any instance is modified.
    ```
    sync_file [-q|--quiet] file
    sync_folder [-q|--quiet] path
    ```
    **Only one file/path is supported currently. If multiple files/paths are given, only the first one will be synchronized**
* #### collect
    `collect` is the command to gather files in the same path across all instances to one instance. This is usually used when instance-local files (e.g. data, logs, configurations) need to be opened in one instance.
    ```
    collect [-q|--quiet] file [{-t|--target} target_path]
    ```
    **If the target path is not specified, the current directory will be set as the default target path**
