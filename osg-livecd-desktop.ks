lang en_US.UTF-8
keyboard us
timezone US/Eastern
auth --useshadow --enablemd5
selinux --enforcing
firewall --enabled
repo --name=a-base    --baseurl=http://mirror.centos.org/centos/5/os/$basearch
repo --name=a-updates --baseurl=http://mirror.centos.org/centos/5/updates/$basearch
#repo --name=a-extras  --baseurl=http://mirror.centos.org/centos/5/extras/$basearch
repo --name=a-live    --baseurl=http://www.nanotechnologies.qc.ca/propos/linux/centos-live/$basearch/live
repo --name=osg       --mirrorlist=http://repo.grid.iu.edu/mirror/osg-release/$basearch
repo --name=osg-contrib       --mirrorlist=http://repo.grid.iu.edu/mirror/osg-contrib/$basearch
repo --name=epel      --mirrorlist=http://mirrors.fedoraproject.org/mirrorlist?repo=epel-5&arch=$basearch
repo --name=a-installer --baseurl=http://www.nanotechnologies.qc.ca/propos/linux/centos-live/$basearch/unsupported
xconfig --startxonboot
part / --size 4096
services --enabled=cups,haldaemon,mcstrans,NetworkManager,portmap,restorecond --disabled=anacron,auditd,bluetooth,cpuspeed,gpm,hidd,ip6tables,mdmonitor,microcode_ctl,netfs,network,nfslock,pcscd,readahead_early,readahead_later,rpcgssd,rpcidmapd,sshd


%packages
syslinux
kernel

@admin-tools
#packages removed from @admin-tools
-sabayon
-system-config-kdump
#@admin-tools <end of package list>


@base
#package added to @base
squashfs-tools
#packages removed from @base
-amtu
-bind-utils
-ccid
-conman
-coolkey
-crash
-dump
-ibmasm
-iptstate
-jwhois
-kexec-tools
-ksh
-lftp
-libaio
-logwatch
-mailcap
-nc
-nss_db
-nss_ldap
-oddjob
-pax
-pkinit-nss
-psacct
-quota
-redhat-lsb
-sendmail
-specspo
-stunnel
-talk
-tcpdump
-tree
-yum-updatesd
-vixie-cron
#@base <end of package list>


@base-x
#packages removed from @base-x
-bitstream-vera-fonts
-linuxwacom
-rhgb
-vnc-server
-xorg-x11-server-Xnest
-xorg-x11-twm
-xterm
#@base-x <end of package list>


@core
#packages removed from @core
-ed
-gnu-efi
-libhugetlbfs
#@core <end of package list>


@dialup
#packages added to @dialup
statserial
#@dialup <end of package list>


@gnome-desktop
#packages added to @gnome-desktop
gnome-bluetooth
gnome-pilot-conduits
gnome-themes
#packages removed from @gnome-desktop
-esc
-eog
-gimp-print-utils
-gtkhtml3
-gnome-backgrounds
-gnome-user-share
-gok
-nautilus-sendto
-orca
-sabayon-apply
-vino
#@gnome-desktop <end of package list>


@graphical-internet
#packages removed from @graphical-internet
-evolution
-evolution-connector
-evolution-webcal
-ekiga
#packages added to @graphical-internet
gftp
pidgin
thunderbird
#@graphical-internet <end of package list>


@office
#packages removed from @office
-openoffice.org-draw
-openoffice.org-graphicfilter
-openoffice.org-math
-openoffice.org-xsltfilter
-openoffice.org-calc
-openoffice.org-writer
-openoffice.org-impress
-openoffice.org-core
-openoffice.org-ure
#@office <end of package list>


@printing
#packages added to @printing
bluez-utils-cups
#@printing <end of package list>


@sound-and-video
#packages removed from @sound-and-video
-rhythmbox
-vorbis-tools
#@sound-and-video <end of package list>


@system-tools
#packages added to @system-tools
nmap-frontend
rdesktop
tsclient
#packages removed from @system-tools
-bluez-hcidump
-hwbrowser
-OpenIPMI
-openldap-clients
-xdelta
-zisofs-tools
-zsh
#@system-tools <end of package list>


@text-internet
#packages removed from @text-internet
-elinks
-fetchmail
-mutt
-slrn
#@text-internet <end of package list>


# Other packages we don't want to include in the Live CD
-*debuginfo
-bind-libs
-compat*
-exim
-gamin-python
-nscd
-oddjob-libs
-procmail
-python-ldap
-rmt
-tclx
-yp-tools

# For the x86_64 version, one could want to remove i386 and i686 libs
#-*.i386
#-*.i686

# other usefull packages
Cluster_Administration-en-US
Deployment_Guide-en-US
Global_File_System-en-US
Virtualization-en-US
busybox
mailx
memtest86+
patch
yum-fastestmirror
yum-metadata-parser
yum-priorities
epel-release
osg-release
osg-client-condor
osg-background

# LiveCD bits to set up the livecd and be able to install
# Installation from the livecd requires anaconda >= 11.2.0.66
anaconda
anaconda-runtime
livecd-installer

%post

## LiveCD version for the link toward the release notes
VERSION="5.6"

## locales for the Live CD
PRIMARY_LANGUAGE="en"
PRIMARY_LOCALE="en_US"
SECONDARY_LANGUAGE="fr"
SECONDARY_LOCALE="fr_CA"

## default LiveCD user
LIVECD_USER="centos"

########################################################################
# Create a sub-script so the output can be captured
# Must change "$" to "\$" and "`" to "\`" to avoid shell quoting
########################################################################
cat > /root/post-install << EOF_post
#!/bin/bash

echo ###################################################################
echo ## Creating the livesys init script
echo ###################################################################

cat > /etc/rc.d/init.d/livesys << EOF_initscript
#!/bin/bash
#
# live: Init script for live image
#
# chkconfig: 345 00 99
# description: Init script for live image.

. /etc/init.d/functions

if ! strstr "\\\`cat /proc/cmdline\\\`" liveimg || [ "\\\$1" != "start" ] || [ -e /.liveimg-configured ] ; then
    exit 0
fi

exists() {
    which \\\$1 >/dev/null 2>&1 || return
    \\\$*
}

# read some variables out of /proc/cmdline
for o in \\\`cat /proc/cmdline\\\` ; do
    case \\\$o in
    xdriver=*)
        xdriver="--set-driver=\\\${o#xdriver=}"
        ;;
    esac
done

touch /.liveimg-configured

# mount live image
if [ -b /dev/live ]; then
   mkdir -p /mnt/live
   mount -o ro /dev/live /mnt/live
fi

# enable swaps unless requested otherwise
swaps=\\\`blkid -t TYPE=swap -o device\\\`
if ! strstr "\\\`cat /proc/cmdline\\\`" noswap -a [ -n "\\\$swaps" ] ; then
  for s in \\\$swaps ; do
    action "Enabling swap partition \\\$s" swapon \\\$s
  done
fi

## fix various bugs and issues
# configure X, allowing user to override xdriver
exists system-config-display --noui --reconfig --set-depth=24 \\\$xdriver

# unmute sound card
exists alsaunmute 0 2> /dev/null

# turn off firstboot for livecd boots
echo "RUN_FIRSTBOOT=NO" > /etc/sysconfig/firstboot

# create a patch for kudzu init script
cat > /tmp/kudzu.patch << EOF_kudzupatch
--- kudzu.orig	2007-07-27 20:27:03.000000000 -0400
+++ kudzu	2007-07-27 20:27:23.000000000 -0400
@@ -35,6 +35,10 @@
 	   action "" /bin/false
 	fi
 
+        # Reconfigure the keyboard
+        . /etc/sysconfig/keyboard
+        /usr/bin/system-config-keyboard \\\\\\\$KEYTABLE 2&> /dev/null
+
 	# We don't want to run this on random runlevel changes.
 	touch /var/lock/subsys/kudzu
 	# However, if they did configure X and want runlevel 5, let's
EOF_kudzupatch

# patch kudzu init script
/usr/bin/patch /etc/rc.d/init.d/kudzu /tmp/kudzu.patch > /dev/null
rm -f /tmp/kudzu.patch

# stopgap fix for RH #217966; should be fixed in HAL instead
touch /media/.hal-mtab

# workaround clock syncing on shutdown that we don't want (RH #297421)
sed -i -e 's/hwclock/no-such-hwclock/g' /etc/rc.d/init.d/halt

# workaround avahi segfault (RH #273301)
touch /etc/resolv.conf
/sbin/restorecon /etc/resolv.conf

# set the LiveCD hostname
sed -i -e 's/HOSTNAME=localhost.localdomain/HOSTNAME=livecd.localdomain/g' /etc/sysconfig/network
/bin/hostname livecd.localdomain

## create the LiveCD default user
# add default user with no password
/usr/sbin/useradd -c "LiveCD default user" $LIVECD_USER
/usr/bin/passwd -d $LIVECD_USER > /dev/null
# give default user sudo privileges
echo "$LIVECD_USER     ALL=(ALL)     NOPASSWD: ALL" >> /etc/sudoers

## configure default user's desktop
# set up timed auto-login at 10 seconds
sed -i -e 's/\[daemon\]/[daemon]\nTimedLoginEnable=true\nTimedLogin=$LIVECD_USER\nTimedLoginDelay=10/' /etc/gdm/custom.conf
# disable screensaver locking
gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -s -t bool /apps/gnome-screensaver/lock_enabled false >/dev/null
# add documentation shortcuts
mkdir -p /home/$LIVECD_USER/Desktop/Documentation
cp /usr/share/applications/Cluster_Administration-en-US.desktop /home/$LIVECD_USER/Desktop/Documentation/
cp /usr/share/applications/Deployment_Guide-en-US.desktop       /home/$LIVECD_USER/Desktop/Documentation/
cp /usr/share/applications/Global_File_System-en-US.desktop     /home/$LIVECD_USER/Desktop/Documentation/
cp /usr/share/applications/Virtualization-en-US.desktop         /home/$LIVECD_USER/Desktop/Documentation/
cat > /home/$LIVECD_USER/Desktop/Documentation/Additional_Documentation.desktop << EOF_documentation
[Desktop Entry]
Name=Additional Documentation
Comment=Enterprise Linux
Exec=firefox http://www.centos.org/docs/5/
Icon=/usr/share/pixmaps/redhat-web-browser.png
Categories=Documentation;
Type=Application
Encoding=UTF-8
Terminal=false
EOF_documentation
cat > /home/$LIVECD_USER/Desktop/Documentation/Release_Notes.desktop << EOF_release_notes
[Desktop Entry]
Name=How To Install
Comment=Enterprise Linux
Exec=firefox http://wiki.centos.org/Manuals/ReleaseNotes/CentOSLiveCD$VERSION
Icon=/usr/share/pixmaps/redhat-web-browser.png
Categories=Documentation;
Type=Application
Encoding=UTF-8
Terminal=false
EOF_release_notes

cat > /home/$LIVECD_USER/Desktop/OSG_Documentation.desktop << OSG_user_docs
[Desktop Entry]
Name=OSG User Docs
Comment=OSG User Documentation
Exec=firefox http://twiki.grid.iu.edu/bin/view/Documentation/UsingTheGrid
Icon=/usr/share/pixmaps/redhat-web-browser.png
Categories=Documentation;
Type=Application
Encoding=UTF-8
Terminal=false
OSG_user_docs


cat > /home/$LIVECD_USER/Desktop/OSG_Cert_Docs.desktop << OSG_cert_docs
[Desktop Entry]
Name=How To Get A Certificate
Comment=How to get a Certificate
Exec=firefox http://twiki.grid.iu.edu/bin/view/Documentation/CertificateGetWeb
Icon=/usr/share/pixmaps/redhat-web-browser.png
Categories=Documentation;
Type=Application
Encoding=UTF-8
Terminal=false
OSG_user_docs

# add keyboard configuration utility to the desktop
mkdir -p /home/$LIVECD_USER/Desktop >/dev/null
cp /usr/share/applications/system-config-keyboard.desktop /home/$LIVECD_USER/Desktop/

CreateDesktopIconHD()
{
cat > /home/$LIVECD_USER/Desktop/Local\ hard\ drives.desktop << EOF_HDicon
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Link
Name=Local hard drives
Name[en_US]=Local hard drives
Name[fr_CA]=Disques durs locaux
URL=/mnt/disc
Icon=/usr/share/icons/Bluecurve/48x48/devices/gnome-dev-harddisk.png
EOF_HDicon

chmod 755 /home/$LIVECD_USER/Desktop/Local\ hard\ drives.desktop
}

CreateDesktopIconLVM()
{
cat > /home/$LIVECD_USER/Desktop/Local\ logical\ volumes.desktop << EOF_LVMicon
[Desktop Entry]
Encoding=UTF-8
Version=1.0
Type=Link
Name=Local logical volumes
Name[en_US]=Local logical volumes
Name[fr_CA]=Volumes logiques locaux
URL=/mnt/lvm
Icon=/usr/share/icons/Bluecurve/48x48/devices/gnome-dev-harddisk.png
EOF_LVMicon

chmod 755 /home/$LIVECD_USER/Desktop/Local\ logical\ volumes.desktop
}

# don't mount disk partitions if 'nodiskmount' is given as a boot option
if ! strstr "\\\`cat /proc/cmdline\\\`" nodiskmount ; then
MOUNTOPTION="ro"
HARD_DISKS=\\\`egrep "[sh]d.\\\$" /proc/partitions | tr -s ' ' | sed 's/^  *//' | cut -d' ' -f4\\\`

echo "Mounting hard disk partitions... "
for DISK in \\\$HARD_DISKS; do 
    # Get the device and system info from fdisk (but only for fat and linux partitions).
    FDISK_INFO=\\\`fdisk -l /dev/\\\$DISK | tr [A-Z] [a-z] | egrep "fat|linux" | egrep -v "swap|extended|lvm" | sed 's/*//' | tr -s ' ' | tr ' ' ':' | cut -d':' -f1,6-\\\`
    for FDISK_ENTRY in \\\$FDISK_INFO; do 
        PARTITION=\\\`echo \\\$FDISK_ENTRY | cut -d':' -f1\\\`
        MOUNTPOINT="/mnt/disc/\\\${PARTITION##/dev/}"
        mkdir -p \\\$MOUNTPOINT
        MOUNTED=FALSE
    
        # get the partition type
        case \\\`echo \\\$FDISK_ENTRY | cut -d':' -f2-\\\` in
        *fat*)  
            FSTYPES="vfat"
            EXTRAOPTIONS=",uid=500";;
        *)
            FSTYPES="ext4 ext3 ext2"
            EXTRAOPTIONS="";;
        esac
    
        # try to mount the partition
        for FSTYPE in \\\$FSTYPES; do
            if mount -o "\\\${MOUNTOPTION}\\\${EXTRAOPTIONS}" -t \\\$FSTYPE \\\$PARTITION \\\$MOUNTPOINT &>/dev/null; then
                echo "\\\$PARTITION \\\$MOUNTPOINT \\\$FSTYPE noauto,\\\${MOUNTOPTION}\\\${EXTRAOPTIONS} 0 0" >> /etc/fstab
                echo -n "\\\$PARTITION "
                MOUNTED=TRUE
                CreateDesktopIconHD
            fi
        done
        [ \\\$MOUNTED = "FALSE" ] && rmdir \\\$MOUNTPOINT
    done
done
echo


FSTYPES="ext4 ext3 ext2"

echo "Scanning for logical volumes..."
if ! lvm vgscan 2>&1 | grep "No volume groups"; then
    echo "Activating logical volumes ..."
    modprobe dm_mod >/dev/null
    echo "mkdmnod" | nash --quiet
    lvm vgchange -ay
    LOGICAL_VOLUMES=\\\`lvm lvdisplay -c | sed "s/^  *//" | cut -d: -f1\\\`
    if [ ! -z "\\\$LOGICAL_VOLUMES" ]; then
        echo "Making device nodes ..."
        lvm vgmknodes
        echo -n "Mounting logical volumes ... "
        for VOLUME_NAME in \\\$LOGICAL_VOLUMES; do
            VG_NAME=\\\`echo \\\$VOLUME_NAME | cut -d/ -f3\\\`
            LV_NAME=\\\`echo \\\$VOLUME_NAME | cut -d/ -f4\\\`
            MOUNTPOINT="/mnt/lvm/\\\${VG_NAME}-\\\${LV_NAME}"
            mkdir -p \\\$MOUNTPOINT

            MOUNTED=FALSE
            for FSTYPE in \\\$FSTYPES; do
                if mount -o \\\$MOUNTOPTION -t \\\$FSTYPE \\\$VOLUME_NAME \\\$MOUNTPOINT &>/dev/null; then
                    echo "\\\$VOLUME_NAME \\\$MOUNTPOINT \\\$FSTYPE defaults,\\\${MOUNTOPTION} 0 0" >> /etc/fstab
                    echo -n "\\\$VOLUME_NAME "
                    MOUNTED=TRUE
                    CreateDesktopIconLVM
                    break
                fi
            done
            [ \\\$MOUNTED = FALSE ] && rmdir \\\$MOUNTPOINT
        done
        echo
        
    else
        echo "No logical volumes found"
    fi
fi
fi

# give back ownership to the default user
chown -R $LIVECD_USER:$LIVECD_USER /home/$LIVECD_USER
EOF_initscript

chmod 755 /etc/rc.d/init.d/livesys
/sbin/restorecon /etc/rc.d/init.d/livesys
/sbin/chkconfig --add livesys


echo ###################################################################
echo ##         Configure the firewall
echo ###################################################################
cat > /etc/sysconfig/iptables << EOF_iptables
# Firewall configuration
*filter
:INPUT ACCEPT [0:0]
:FORWARD ACCEPT [0:0]
:OUTPUT ACCEPT [0:0]
:RH-Firewall-1-INPUT - [0:0]
-A INPUT -j RH-Firewall-1-INPUT
-A FORWARD -j RH-Firewall-1-INPUT
-A RH-Firewall-1-INPUT -i lo -j ACCEPT
-A RH-Firewall-1-INPUT -p icmp --icmp-type any -j ACCEPT
-A RH-Firewall-1-INPUT -p 50 -j ACCEPT
-A RH-Firewall-1-INPUT -p 51 -j ACCEPT
-A RH-Firewall-1-INPUT -p udp --dport 5353 -d 224.0.0.251 -j ACCEPT
-A RH-Firewall-1-INPUT -m state --state ESTABLISHED,RELATED -j ACCEPT
-A RH-Firewall-1-INPUT -j REJECT --reject-with icmp-host-prohibited
COMMIT
EOF_iptables

# Turn off iptables for grid stuff
chkconfig iptables off




echo ###################################################################
echo ## Trim down the LiveCD to save some space
echo ###################################################################
# remove unneeded initrd file(s)
rm -f /boot/initrd*
# temporary RPM databases can be removed
rm -f /usr/var/lib/rpm/__db.00*
# make sure there aren't core files lying around
rm -f /core*

# remove files for unsupported languages in various applications
(cd /var/lib/scrollkeeper; \
 if [ \`ls | wc -w\` -gt 11 ]; then \
     mkdir ../temp_dir; \
     mv C $PRIMARY_LANGUAGE $SECONDARY_LANGUAGE index scrollkeeper_docs TOC ../temp_dir; \
     rm -rf *; mv ../temp_dir/* .; rmdir ../temp_dir; \
     sync; \
 fi)
(cd /usr/lib/locale; \
 if [ \`ls | wc -w\` -gt 8 ]; then \
     mkdir ../temp_dir; \
     mv $PRIMARY_LOCALE* $SECONDARY_LOCALE* ../temp_dir; \
     rm -rf *; mv ../temp_dir/* .; rmdir ../temp_dir; \
     /usr/sbin/build-locale-archive; \
     sync; \
 fi)
(cd /usr/share/locale; \
 if [ \`ls | wc -w\` -gt 10 ]; then \
     mkdir ../temp_dir; \
     mv locale.alias ../temp_dir; \
     mv $PRIMARY_LANGUAGE $PRIMARY_LOCALE $SECONDARY_LANGUAGE $SECONDARY_LOCALE ../temp_dir; \
     rm -rf *; mv ../temp_dir/* .; rmdir ../temp_dir; \
     sync; \
 fi)

# remove rarely used documentation files
(cd /usr/share/doc; \
 if find . -maxdepth 1 -mmin -60 >/dev/null; then \
     find . -iname changelog* -exec rm -f {} \; ;\
     find . -iname changes -exec rm -f {} \; ;\
     find . -iname news -exec rm -f {} \; ;\
     sync; \
 fi)

# remove manual pages for unsupported languages 
(cd /usr/share/man; \
 if [ \`ls | wc -w\` -gt 16 ]; then \
     mkdir ../temp_dir; \
     mv man* $PRIMARY_LANGUAGE $SECONDARY_LANGUAGE ../temp_dir; \
     rm -rf *; mv ../temp_dir/* .; rmdir ../temp_dir; \
     sync; \
 fi)


##################
# Install OSG
##################
# yum install -y osg-client-condor


# Install new background
#gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -t str -s /desktop/gnome/background/color_shading_type "solid" 
#gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -t str -s /desktop/gnome/background/primary_color "#000000000000" 
#gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -t str -s /desktop/gnome/background/secondary_color "#ffffffffffff" 
#gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -t str -s /desktop/gnome/background/picture_filename "/usr/local/share/osg-background.png" 
#gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -t str -s /desktop/gnome/background/picture_options "centered" 
#gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -t str -s /desktop/gnome/background/picture_opacity "100" 
#gconftool-2 --direct --config-source=xml:readwrite:/etc/gconf/gconf.xml.defaults -t bool -s /desktop/gnome/background/draw_background true


EOF_post

/bin/bash -x /root/post-install 2>&1 | tee /root/post-install.log

%post --nochroot

########################################################################
# Create a sub-script so the output can be captured
# Must change "$" to "\$" and "`" to "\`" to avoid shell quoting
########################################################################
cat > /root/postnochroot-install << EOF_postnochroot
#!/bin/bash

# add livecd-iso-to-disk utility on the LiveCD
# only works on x86, x86_64
if [ "\$(uname -i)" = "i386" -o "\$(uname -i)" = "x86_64" ]; then
  if [ ! -d \$LIVE_ROOT/LiveOS ]; then mkdir -p \$LIVE_ROOT/LiveOS ; fi
  cp /usr/bin/livecd-iso-to-disk \$LIVE_ROOT/LiveOS
fi

# customize boot menu entries
grep -A4 'label linux0'  \$LIVE_ROOT/isolinux/isolinux.cfg > \$LIVE_ROOT/isolinux/default.txt
grep -A2 'label memtest' \$LIVE_ROOT/isolinux/isolinux.cfg > \$LIVE_ROOT/isolinux/memtest.txt
grep -A2 'label local'   \$LIVE_ROOT/isolinux/isolinux.cfg > \$LIVE_ROOT/isolinux/localboot.txt

sed "s/label linux0/label linuxtext0/" \$LIVE_ROOT/isolinux/default.txt > \$LIVE_ROOT/isolinux/textmode.txt
sed -i "s/Boot/Boot (text mode)/"                                         \$LIVE_ROOT/isolinux/textmode.txt
sed -i "s/liveimg/liveimg 3/"                                             \$LIVE_ROOT/isolinux/textmode.txt
sed -i "/menu default/d"                                                  \$LIVE_ROOT/isolinux/textmode.txt

touch \$LIVE_ROOT/isolinux/installer.txt
if [ -e \$INSTALL_ROOT/boot/livecd-installer.img -a -e \$INSTALL_ROOT/boot/vmlinuz-installer* ]; then
   mv \$INSTALL_ROOT/boot/livecd-installer.img \$LIVE_ROOT/isolinux/install.img
   mv \$INSTALL_ROOT/boot/vmlinuz-installer*   \$LIVE_ROOT/isolinux/vminst
   cat > \$LIVE_ROOT/isolinux/installer.txt << EOF_installer
label installer
  menu label Network Installation
  kernel vminst
  append initrd=install.img text
EOF_installer
fi

cat \$LIVE_ROOT/isolinux/default.txt \$LIVE_ROOT/isolinux/memtest.txt \$LIVE_ROOT/isolinux/localboot.txt > \$LIVE_ROOT/isolinux/current.txt
diff \$LIVE_ROOT/isolinux/isolinux.cfg \$LIVE_ROOT/isolinux/current.txt | sed '/^[0-9][0-9]*/d; s/^. //; /^---$/d' > \$LIVE_ROOT/isolinux/cleaned.txt
cat \$LIVE_ROOT/isolinux/cleaned.txt \$LIVE_ROOT/isolinux/default.txt \$LIVE_ROOT/isolinux/textmode.txt \$LIVE_ROOT/isolinux/installer.txt \$LIVE_ROOT/isolinux/memtest.txt \$LIVE_ROOT/isolinux/localboot.txt > \$LIVE_ROOT/isolinux/isolinux.cfg
rm -f \$LIVE_ROOT/isolinux/*.txt

# Change the background picture to OSG
#mkdir -p $LIVE_ROOT/usr/local/share
#wget -O $LIVE_ROOT/usr/local/share/osg-logo-background.png "http://osg-docdb.opensciencegrid.org/0006/000602/001/osg_logo_4c_white%20%5BConverted%5D.png"

EOF_postnochroot

/bin/bash -x /root/postnochroot-install 2>&1 | tee /root/postnochroot-install.log
