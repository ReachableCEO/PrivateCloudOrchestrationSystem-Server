#!/bin/bash
#A script to create LXC virtual machines 

#Takes two mandatory arguments
#Hostname
#IP address

#Takes two optional arguments
#Template to provision from
#Path to create instance


#Usage message
usage()
{
echo "$0 needs to be invoked with two arguments:\

	Argument 1:Hostname
	Argument 2:IP Address

It can also take two optional arguments:

Path to a template you wish to provision from
Path to a directory to store a virtual machine in"
exit 0
}

#Error handling code
error_out() 
{
echo "A critical error has occured. Please see above line for portion that failed."
exit 1
}

bail_out()
{
echo "Exiting at user request."
exit 0
}

preflight()
{
#Ensure script is running as lxcmgmt user
if [ "$(whoami)" != 'lxcmgmt' ]; then
        echo "You must be the lxcmgmt user to run $0"
        exit 1;
fi


#Check for hostname argument
echo "Ensuring hostname is properly set..."
if [ -z "$1" ]; then
error_out
else
VMHOSTNAME="$1"
fi

#Check for IP
echo "Ensuring ip is properly set..."
if [ -z "$2" ]; then
error_out
else
VMIP=$2
fi

#Check for template specification, otherwise set to default
if [ -n "$3"  ]; then
VMTEMPLATE="$3"
else 
VMTEMPLATE="/lxc/templates/ariesvm.tar.gz"
fi

#Check for path specification, otherwise set to default
if [ -n "$4" ]; then
VMPATH="$4"
else 
VMPATH="/lxc/instances/$VMHOSTNAME"
fi

echo "VM will be created with the following paramaters."
echo "Hostname: $VMHOSTNAME"
echo "IPv4 Address: $VMIP"
echo "Template: $VMTEMPLATE"
echo "Path: $VMPATH"
echo "Do you wish to proceed? (Y/N)"
read proceed

if [ $proceed = "Y" ]; then
createvm VMHOSTNAME VMIP VMTEMPLATE VMPATH
elif [ $proceed = "N" ]; then
bail_out
else
echo "Please specify Y or N"
error_out
fi
}

createvm()
{
#Provision a vm
#If we are here, preflight check passed, user confirmed paramaters and we are good to go

#SOME variables...
CONFIGTEMPLATES="/lxc/templates"
VMMAC=$(echo $VMIP | awk -F . '{print $4}')

#First we create a directory for the instance
echo "Creating storage location for $VMHOSTNAME..."
mkdir $VMPATH
mkdir $VMPATH/rootfs

#Second we uncompress the VM template
echo "Uncompressing template..."
tar xfz $VMTEMPLATE -C $VMPATH/rootfs

#Dynamically create fstab and config file in /lxc/instances/vminstance:
echo "Creating configuration files..."

#Create fstab:
echo "Creating fstab..."
cat > $VMPATH/$VMHOSTNAME.fstab <<FSTAB
proc            /lxc/instances/$VMHOSTNAME/rootfs/proc         proc    nodev,noexec,nosuid 0 0
sysfs           /lxc/instances/$VMHOSTNAME/rootfs/sys          sysfs defaults  0 0
/dev            /lxc/instances/$VMHOSTNAME/rootfs/dev              none    bind    0 0
FSTAB

echo "Creating config file..."
cat > $VMPATH/$VMHOSTNAME.config <<CONFIG
lxc.utsname = $VMHOSTNAME
lxc.mount = $VMPATH/$VMHOSTNAME.fstab
lxc.rootfs = $VMPATH/rootfs
lxc.network.hwaddr = $VMMAC
lxc.network.ipv4 = $VMIP
lxc.tty = 6
lxc.network.type = veth
lxc.network.flags = up
lxc.network.link = br0
lxc.network.name = eth0
CONFIG

#Start VM:
echo "Starting your virtual machine $VMHOSTNAME..."

#Verify VM is running: 
echo "Verifying successful boot of $VMHOSTNAME..."

exit 0
}

if [ "$1" = "--help" ]; then
usage
fi

preflight $1 $2 $3 $4

exit 0
