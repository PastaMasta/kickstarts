### INSTALL ###
text
install
url --url=http://repo/repo/os/Linux/CentOS/6/os/x86_64
reboot

### SECURITY ###
selinux --disabled
authconfig --enableshadow --enablemd5
rootpw  --iscrypted $6$5dk70PR3718kwOb5$VILypUGYpORfOx4u4BbXckiGTFvP7u6Afq9nx7qwaqok9meKDCBO3oubT76XtoMalIOcZ4mAyGfgov/nRMrib/

### NETWORK CONF ###
network --onboot yes --device eth0 --bootproto dhcp --noipv6
firewall --service=ssh

### LOCAL ###
lang en_US.UTF-8
keyboard uk
timezone --utc Europe/London

### STORAGE ###

%include /tmp/part-include # Generated in find-disks.sh

volgroup rootvg --pesize=4096 pv.0
logvol swap --name=lv_swap --vgname=rootvg --size=2048
logvol / --fstype=ext4 --name=lv_root --vgname=rootvg --size=2048
logvol /tmp --fstype=ext4 --name=lv_tmp --vgname=rootvg --size=1024
logvol /home --fstype=ext4 --name=lv_home --vgname=rootvg --size=128
logvol /var --fstype=ext4 --name=lv_var --vgname=rootvg --size=1024
logvol /var/log --fstype=ext4 --name=lv_log --vgname=rootvg --size=1024

### PACKAGES ###
%packages
@Base
@Core
@core
@server-policy
openssh-clients
%end

### PRE-INSTALL ###
%pre --interpreter /bin/bash --logfile /root/install-pre.log
###############################################################################

# Move to other tty so we can display stuff
exec < /dev/tty6 > /dev/tty6
chvt 6
clear

# Download and run all the misc scripts
baseurl="repo.localdomain/build/kickstarts/scripts"
mkdir /tmp/build

wget ${baseurl}/find-disks.sh -O /tmp/build/find-disks.sh
chmod +x /tmp/build/*.sh

/tmp/build/find-disks.sh

# Go back to tty1
exec < /dev/tty1 > /dev/tty1
chvt 1

###############################################################################
%end

### POST-INSTALL ###
%post --logfile /root/install-post.log
(

# Setup SSH key
mkdir /root/.ssh
echo 'ssh-rsa AAAAB3NzaC1yc2EAAAABJQAAAQEAxiaxYdjTN+A3Zus5iFtbtkKWBh8iaxNK9Pfhg1L1PevcJmqjhSNnVSVv07BeNtRCq5l6EyULboVFC0hfn2ek+VcbxITOgfa/otzLw3Qyza2/vZRYxUhGOTlLGteDC+V+1m9NXD0IH/VE0XEpabZ97C4VJDXK+Pclkhv4cn/wEP8BADh2W5sg+UwUghS7WqCoSkCycq2iJwWujW/xZ+AslHVFqeKrEKWklh2zkJzs0DW7b1yiLhzH8a3TBAEbGuk6dBUXMnKj9ksdgDnA5QScC8lDXLxBr3p3yU8UVUzbJz0EFoJvsHsYq7k25J269nN0+xZEn7y/u9OduTZADfOqIw== SBT' >> /root/.ssh/authorized_keys
chmod -R 700 /root/.ssh

) 2>&1 >/root/install-post-sh.log
%end
### EOF ###