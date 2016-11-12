#!/bin/bash
#-------------------------------------------------------------------------------
#  <Create Fake swap partition to correct hibernation bug>
#-------------------------------------------------------------------------------
#-------------------------------------------------------------------------------
# usage : su - -c "./fake_swap_partition.sh"

if [ "$EUID" -ne '0' ]; then
    echo "Script must be launch by root: # su - -c $0" 1>&2
    exit 1
fi

# Get MemTotal in kB
MEM_SIZE=`cat /proc/meminfo | grep MemTotal | tr -s ' ' | cut -d' ' -f2`
echo "Total memory : "$MEM_SIZE

# Hal MemTotal in mB
HALF_MEM=`python -c "print $MEM_SIZE/2000"`m
echo "Half total memory : "$HALF_MEM

# Swap file creation
echo -n "Swap file creation..."
fallocate -l $HALF_MEM /swap
if [ -f /swap ]; then
    echo -n "["
    echo -en '\E[0;32m'"\033[1mok\033[0m"
    echo "]"
else
    echo -n "["
    echo -en '\E[0;31m'"\033[1mfail\033[0m"
    echo "]"
    exit 0
fi

echo "Setup swap area..."
mkswap /swap

# Patch /etc/fstab
echo -n "Patch /etc/fstab..."
echo -e "\n# Fake swap partition for hibernation insert by $0" >> /etc/fstab
echo -e "/swap   swap    swap    defaults        0       0" >> /etc/fstab
TEST_FSTAB=`grep "/swap   swap    swap    defaults        0       0" /etc/fstab`
if [ -n "$TEST_FSTAB" ]; then
    echo -n "["
    echo -en '\E[0;32m'"\033[1mok\033[0m"
    echo "]"
else
    echo -n "["
    echo -en '\E[0;31m'"\033[1mfail\033[0m"
    echo "]"
    exit 0
fi

# Stop kernel
echo -n "Authorize kernel to use swap..."
sysctl -w vm.swappiness=1
echo -n "["
echo -en '\E[0;32m'"\033[1mok\033[0m"
echo "]"

# Create local.conf
echo -n "Create local.conf..."
echo "vm.swappiness=1" > /etc/sysctl.d/local.conf
if [ -f /etc/sysctl.d/local.conf ]; then
    echo -n "["
    echo -en '\E[0;32m'"\033[1mok\033[0m"
    echo "]"
else
    echo -n "["
    echo -en '\E[0;31m'"\033[1mfail\033[0m"
    echo "]"
    exit 0
fi

# Swap activation
echo -n "Swap activation..."
swapon /swap
TEST_SWAP=`swapon -s | grep /swap`
if [ -n "$TEST_SWAP" ]; then
    echo -n "["
    echo -en '\E[0;32m'"\033[1mok\033[0m"
    echo "]"
else
    echo -n "["
    echo -en '\E[0;31m'"\033[1mfail\033[0m"
    echo "]"
    exit 0
fi

# Install uswsusp if not exist
echo -n "uswsusp installation..."
TEST_INSTALL_USWSUSP=`dpkg --get-selections | grep uswsusp`
if [ ! -n "$TEST_SWAP" ]; then
    echo -n "["
    echo -en '\E[0;32m'"\033[1malready install\033[0m"
    echo "]"
else
    echo -n "["
    echo -en '\E[0;31m'"\033[1mnot install\033[0m"
    echo "]"
    echo -e "\tInstallation of uswsusp..."
    apt-get install uswsusp
    dpkg-reconfigure -pmedium uswsusp
fi

echo "Test fake swap and hibernation with command s2disk..."
echo "-- End of $0 --"

# END of fake_swap_partition.sh 
