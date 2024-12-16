#!/bin/bash

VMHOSTFULL="$1"
USER_SUPPLIED_VMNAME="$2"
SSH_ALIAS="ssh -q"

VIRSH_ALIAS="virsh -c qemu+ssh://root@$VMHOSTFULL/system?no_verify=1"


$VIRSH_ALIAS start $USER_SUPPLIED_VMNAME