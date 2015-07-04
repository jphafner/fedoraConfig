#!/bin/bash

WORKING_DIR=`pwd`
RESUME_LOG="/var/tmp/post_install"

## Figure out resume point
if [ -r "$RESUME_LOG" -a "$1" = '--resume' ]; then
    RESUME_POINT=`cat $RESUME_LOG`
else
    RESUME_POINT=0
fi

function pause()
{
   read -p "$*"
}

function user_input
{
    WORKDIR=`pwd`
    echo "Enter hostname"
    read HOSTNAME
    ## remove whitespace and keep first word only
}

function perform_action
{
    if [ ! $1 -lt $RESUME_POINT ]; then
        echo $1 > $RESUME_LOG
        action_$1
        if [ $? -ne 0 ]; then
            echo "Action $1 failed"
            exit 1
        fi
    fi
}

function action_1
{
    echo "Add Repositories"

    ## Needed Packages
    yum -y install perl
    if [ $? -ne 0 ]; then
        echo "yum doesn't seem to be working!!"
        return 1
    fi

    ## Skype repository
    #cp ./repos/skype.repo /etc/yum.repos.d/
    #rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub

    ## Google repository
    cp ./repos/google-chrome.repo /etc/yum.repos.d/
    cp ./repos/google-earth.repo /etc/yum.repos.d/
    rpm --import https://dl-ssl.google.com/linux/linux_signing_key.pub

    ## Adobe Repository 64-bit x86_64 ##
    rpm -Uvh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux

    ## Adobe Repository 32-bit i386 ##
    #rpm -Uvh http://linuxdownload.adobe.com/adobe-release/adobe-release-i386-1.0-1.noarch.rpm
    #rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux

    ## Add JoJoBoulix
    echo  "Adding JoJoBoulix (auto-multiple-choice)"
    cp ./repos/JoJoBoulix.repo /etc/yum.repos.d/


    ## Add OpenAFS
    #echo  "Adding OpenAFS Repository"
    #rpm -Uvh http://dl.openafs.org/dl/openafs/1.6.1/openafs-repository-1.6.1-5.noarch.rpm

    ## Add RPM Fusion
    echo "Adding RPM Fusion Repository"
    #su -c 'yum install --nogpgcheck http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm'
    rpm -Uvh http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm
    rpm -Uvh http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm
    rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-rpmfusion-*

    ## Add Globus repository
    #rpm -Uvh http://www.globus.org/ftppub/gt5/5.2/5.2.2/installers/repo/Globus-5.2.stable-config.fedora-17-1.noarch.rpm
    #rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-Globus

    ## NOTE: No longer needed

    ## Protect repositories
    #echo "Protecting repositories"
    #yum -y install yum-plugin-protectbase
    #perl -i -pe "s/(\[.*\])/\1\nprotect=yes/" /etc/yum.repos.d/{adobe*,fedora*,google*,rpmfusion*,Globus*}

    ## Prioritize repositories
    #echo "Prioritizing repositories"
    #yum -y install yum-plugin-priorities
    #perl -i -pe "s/(\[.*\])/\1\npriority=1/" /etc/yum.repos.d/Globus*
    #perl -i -pe "s/(\[.*\])/\1\npriority=25/" /etc/yum.repos.d/adobe*
    #perl -i -pe "s/(\[.*\])/\1\npriority=25/" /etc/yum.repos.d/google*
    #perl -i -pe "s/(\[.*\])/\1\npriority=50/" /etc/yum.repos.d/fedora*
    #perl -i -pe "s/(\[.*\])/\1\npriority=75/" /etc/yum.repos.d/rpmfusion*

    ## Disable unwanted
    #perl -i -pe "s/(enabled)=1/\1=0/" /etc/yum.repos.d/Globus*
    #perl -i -pe "s/(enabled)=1/\1=0/" /etc/yum.repos.d/openafs*

    echo "Update system"
    yum -y update

    if [ $? -ne 0 ]; then
        echo "System upgrade NOT successful"
        return 1
    else
        echo "System upgrade successful"
        return 0
    fi
}

function action_2
{
    echo "Installing desired user packages"
    yum -y install `cat config/install-basic.txt`
    if [ $? -ne 0 ]; then
        echo "Error while installing desired user packages!!"
        return 1
    fi

    echo "Installing desired devel packages"
    yum -y install `cat config/install-devel.txt`
    if [ $? -ne 0 ]; then
        echo "Error while installing desired devel packages!!"
        return 1
    fi

    #echo "Installing desired HPC packages"
    #yum -y install `cat config/install-hpc.txt`
    #if [ $? -ne 0 ]; then
    #    echo "Error while installing desired HPC packages!!"
    #    return 1
    #fi

    ## NOTE: Consider http://www.stockfishchess.com

    echo "Installing desired games packages"
    yum -y install `cat config/install-games.txt`
    if [ $? -ne 0 ]; then
        echo "Error while installing desired games packages!!"
        return 1
    fi

    echo "Installing desired media packages"
    yum -y install `cat config/install-media.txt`
    if [ $? -ne 0 ]; then
        echo "Error while installing desired media packages!!"
        return 1
    fi

    #echo "Installing desired research packages"
    #yum -y install `cat config/install-research.txt`
    #if [ $? -ne 0 ]; then
    #    echo "Error while installing desired research packages!!"
    #    return 1
    #fi

    #echo "Removing undesired default packages"
    #yum -y remove `cat config/remove.txt`
    #if [ $? -ne 0 ]; then
    #    echo "Error while removing undesired packages!!"
    #    return 1
    #fi
}

function action_3
{
    echo "Installing desired font packages"
    yum -y install `cat config/install-fonts.txt`
    if [ $? -ne 0 ]; then
        echo "Error while installing desired font packages!!"
        return 1
    fi

    echo "Install needed software to install msttcorefonts"
    yum -y install rpm-build cabextract ttmkfdir
    if [ $? -ne 0 ]; then
        echo "Error while rpm-build, cabextract and ttmkfdir!!"
        return 1
    fi

    ## NOTE: Defintions in spec file are too old to work

    #echo "Downloading needed msttcorefonts-X.spec file"
    #wget http://corefonts.sourceforge.net/msttcorefonts-2.0-1.spec
    #if [ $? -ne 0 ]; then
    #    echo "Could not download msttcorefonts spec file!!"
    #    return 1
    #fi

    #echo "Build msttcorefont package for installation"
    #rpmbuild -bb msttcorefonts-2.0-1.spec
    #if [ $? -ne 0 ]; then
    #    echo "Could not build msttcorefonts rpm package!!"
    #    return 1
    #fi

    #echo "Instal msttcorefonts, you can safely ignore error messages"
    #echo "  relating to /usr/sbin/chkfontpath not being found"
    #rpm -ivh --nodeps rpmbuild/RPMS/noarch/msttcorefonts-2.0-1.noarch.rpm
    #if [ $? -ne 0 ]; then
    #    echo "Failed to install msttcorefonts!!"
    #    return 1
    #fi

    return 0
}

function action_4
{
    echo "Installing LaTex packages"
    yum -y install `cat config/install-latex.txt`
    if [ $? -ne 0 ]; then
        echo "Error while installing desired LaTex packages!!"
        return 1
    fi

    TEXMF_DIR=/usr/local/share/texmf

    ## Goto working directory
    mkdir -p ${TEXMF_DIR}
    cd ${TEXMF_DIR}

    ##
    ## LATEX FONTS
    ##

    ## Winfonts
    #wget http://tug.ctan.org/tex-archive/fonts/winfonts/winfonts.zip
    #if [ $? -ne 0 ]; then
    #    echo "Error downloading winfonts!!"
    #    return 1
    #else
    #    ## TDS format
    #    unzip winfonts.zip
    #    rm winfonts.zip
    #    mktexlsr
    #    updmap-sys --enable Map winfonts.map
    #fi

    ## Trajan
    #wget http://mirror.ctan.org/fonts/trajan.zip

    ## LuxiMono, needed by memoir chapter styles
    #wget http://mirror.ctan.org/fonts/LuxiMono.zip
    #if [ $? -ne 0 ]; then
    #    echo "Error downloading LuxiMono!!"
    #    return 1
    #else
    #    unzip LuxiMono.zip
    #    mkdir -p fonts/type1/public/luxi
    #    cp LuxiMono/*pfb fonts/type1/public/luxi
    #    mkdir -p fonts/afm/public/luxi
    #    cp LuxiMono/*afm fonts/afm/public/luxi
    #    ## contains second zip
    #    unzip LuxiMono/ul9.zip -d ./
    #    rm -rf LuxiMono/*
    #    ## uses legacy location
    #    mkdir fonts/maps/dvips/luxi
    #    mv dvips/config/ul9.map fonts/maps/dvips/luxi/
    #    mktexlsr
    #    updmap-sys --enable Map ul9.map
    #fi

    ##
    ## MISC LATEX
    ##

    ## Beamer Poster
    #wget http://www-i6.informatik.rwth-aachen.de/~dreuw/download/beamerposter.sty

    ## Go back to orig directory
    cd $WORKDIR

    return 0
}

function action_5
{
    echo "Adding appropriate printers"
    #yum -y install cups cups-libs libgnomecups system-config-printer foomatic foomatic-db
    yum -y install cups cups-libs libgnomecups system-config-printer

    mkdir -p /usr/local/share/ppd/

    case $HOSTNAME in
        "pioneer" )
            printer_hubble
            printer_kepler
            ;;
        "hedonism" )
            echo "No printers are available for hedonism"
            ;;
        * )
            echo "hostname \"$HOSTNAME\" does not match any known names"
            return 1
            ;;
    esac

    return 0
}

function printer_kepler {
    echo "Adding Kepler Printer"


    /usr/sbin/lpadmin -p kepler -E \
                      -v lpd://134.192.69.211:515/LPT1 \
                      -D "Dell 2155cdn Color MFP" \
                      -L "HSFII S612"

    /usr/bin/lpoptions -p kepler \
                       -o sides=two-sided-long-edge \
                       -o media=letter \
                       -o Duplex=DuplexNoTumble

    if [ $? -ne 0 ]; then
        echo "Printer NOT added"
        return 1
    fi
    ## Make default
    #/usr/sbin/lpadmin -d Kepler
    return 0
}

function printer_hubble_ou {
    echo "Adding Hubble Printer"
    cp ./ppd/dl3115cn.ppd /usr/local/share/ppd/
    /usr/sbin/lpadmin -p Hubble -E \
                      -v lpd://hubble.ccb.ou.edu:515/LPT1 \
                      -D "Dell 3115cn Color Laser MFP" \
                      -L "101 Stephenson Pkwy Room 1100" \
                      -o sides=two-sided-long-edge \
                      -o media=letter \
                      -o Duplex=DuplexNoTumble \
                      -o DLColorMode=Black \
                      -o DLTonerSaver=True \
                      -P /usr/local/share/ppd/dl3115cn.ppd
    if [ $? -ne 0 ]; then
        echo "Printer NOT added"
        return 1
    fi
    ## Make default
    /usr/sbin/lpadmin -d Hubble
    return 0
}

function printer_kepler_ou {
    echo "Adding Kepler Printer"
    cp ./ppd/dp2145.ppd /usr/local/share/ppd/
    /usr/sbin/lpadmin -p Kepler -E \
                      -v lpd://kepler.ccb.out.edu:515/LPT1 \
                      -D "Dell 2145cn Color Laser MFP" \
                      -L "101 Stephenson Pkwy Room 1100" \
                      -o sides=two-sided-long-edge \
                      -o media=letter \
                      -o Duplex=DuplexNoTumble \
                      -P /usr/local/share/ppd/dp2145.ppd
    if [ $? -ne 0 ]; then
        echo "Printer NOT added"
        return 1
    fi
    return 0
}

function action_6 {
    echo "Configuring Servers and Firewall"

    case $HOSTNAME in
        "pioneer" )
            enable_ssh
            ;;
        "hedonism" )
            echo "No extra server or firewall settings needed for hedonism"
            ;;
        * )
            echo "hostname \"$HOSTNAME\" does not match any known names"
            return 1
            ;;
    esac

    #lokkit -s mdns
    #lokkit -s ipsec

    return 0
}

function enable_ssh {
    echo "Enabling SSHD server"
    systemctl enable sshd.service
    if [ $? -ne 0 ]; then
        echo "Failed to enable SSHD!!"
        return 1
    else
        lokkit -s ssh
    fi

    return 0
}

function action_7 {
    echo "Adding DVD and Bluray Support"
    echo "check http://wiki.videolan.org/Subversion"
    echo "      http://wiki.videolan.org/Git"

    echo "Downloading libbluray from git.videolan.or"
    git clone git://git.videolan.org/libbluray.git
    cd libaacs && ./bootstrap && ./configure --prefix=/usr/local && make && make install
    if [ $? -ne 0 ]; then
        echo "Failed to build libbluray!!"
        return 1
    fi
    cd $WORKDIR

    echo "Downloading libaacs from git.videolan.org"
    git clone http://git.videolan.org/git/libaacs.git
    cd libaacs && ./bootstrap && ./configure --prefix=/usr/local && make && make install
    if [ $? -ne 0 ]; then
        echo "Failed to build libaacs!!"
        return 1
    fi
    cd $WORKDIR

    echo "Downloading libdvdcss from svn.videolan.org"
    svn checkout svn://svn.videolan.org/libdvdcss/trunk libdvdcss
    cd libdvdcss && ./bootstrap && ./configure --prefix=/usr/local && make && make install
    if [ $? -ne 0 ]; then
        echo "Failed to build libdvdcss!!"
        return 1
    fi
    cd $WORKDIR

    #svn checkout svn://svn.mplayerhq.hu/mplayer/trunk mplayer

    echo "Adding /usr/local to ldconfig"
    cp ./config/local-x86_56.conf /etc/ld.so.conf.d/
    ldconfig

    return 0
}

function action_8 {
    ## Note: this is not necessary if extensions
    ##       were originally installed in $HOME
    echo "Begin configuration of Firefox"

    echo "Install Adobe Flash Plugin"
    yum -y install flash-plugin
    if [ $? -ne 0 ]; then
        echo "failed to install adobe flash-plugin"
        return 1
    fi

    #echo 
    #read -p "Would you like to install Java support (y/n)?"
    #if [ $REPLY = "y" ] || [ $REPLY = "Y" ]; then
    #    echo "Installing Java!!"
    #    install_java
    #else
    #    echo "Not installing Java!!"
    #fi

    #echo
    #read -p "Would you like to install Standard extensions (y/n)?"
    #if [ $REPLY = "y" ] || [ $REPLY = "Y" ]; then
    #    echo "Configuring Firefox!!"
    #    firefox_config
    #else
    #    echo "Not configuring Firefox!!"
    #fi

    return 0
}

function install_java {
    #rpm -Uvh rpms/jre-6u30-linux-amd64.rpm
    yum -y localinstall rpms/jre-6u30-linux-amd64.rpm
    #ln -s /usr/java/default/lib/amd64/libnpjp2.so /home/$user/.mozilla/plugins/
    ln -s /usr/java/default/lib/amd64/libnpjp2.so /usr/lib64/mozilla/plugins/

    return 0
}

function firefox_config {
    ## https://developer.mozilla.org/en/Installing_extensions

    ## HTTPS Everywhere
    wget https://www.eff.org/files/https-everywhere-latest.xpi /usr/lib64/mozilla/extensions/
    if [ $? -ne 0 ]; then
        echo "HTTPS Everywhere failed to download"
        return 1
    fi

    ## No Script
    wget https://addons.mozilla.org/en-US/firefox/downloads/latest/722/addon-722-latest.xpi /usr/lib64/mozilla/extensions/
    if [ $? -ne 0 ]; then
        echo "No Script failed to download"
        return 1
    fi

    ## Collusion http://collusion.toolness.org/
    #wget https://secure.toolness.com/xpi/collusion.xpi ./usr/lib64/mozilla/extensions/
    #if [ $? -ne 0 ]; then
    #    echo "Collusion failed to download"
    #    return 1
    #fi

    return 0
}

function action_9 {
    echo "Install research specific software"

    echo "Install Modeller v9!!"
    yum -y localinstall rpms/modeller-9.10-1.x86_64.rpm
    if [ $? -ne 0 ]; then
        echo "Failed to install modeller!!"
        return 1
    fi

    echo "Install VMD!!"
    cd soft && tar xvzf vmd-1.9.1.bin.LINUXAMD64.opengl.tar.gz
    if [ $? -ne 0 ]; then
        cd $WORKDIR
        echo "Failed to find VMD tarbal!!"
        return 1
    fi
    cd vmd-1.9.9 && ./configure
    if [ $? -ne 0 ]; then
        cd $WORKDIR
        echo "Failed to configure VMD!!"
        return 1
    fi
    cd ./src && make install
    if [ $? -ne 0 ]; then
        cd $WORKDIR
        echo "Failed to install VMD!!"
        return 1
    fi

    cd $WORKDIR
    
    return 0
}

function action_10
{
    echo "Configure Kerberos and OpenAFS"

    yum -y install `cat config/install-SSO.txt`
    if [ $? -ne 0 ]; then
        echo "Error while installing Single Sign On software!!"
        return 1
    fi

    ## Configure OpenAFS
    echo "physics.buffalo.edu physics" > /etc/openafs/CellAlias
    echo "physics.buffalo.edu" > /etc/openafs/ThisCell

    ## Check for original files and backup
    if [ -a /etc/krb5.conf ]; then
        echo "Creating backup of original krb5.conf file"
        cp -a /etc/krb5.conf /etc/krb5.conf,orig
    fi

    echo "Configure Single Sign On"
    cp config/krb5.conf /etc/krb5.conf
    cp config/CellServDB.local /etc/openafs/CellServDB.local

    ## Make openafs-client run at boot
    systemctl enable openafs.service
    systemctl enable ntpd.service

    return 0
}

mkdir -p `dirname $RESUME_LOG`
rm -f $RESUME_LOG

## #####################################
## Check that everything is good
echo 'Please check that there are no version depenedent issues'
pause 'Press [Enter] key to continue...'
## #####################################

## #####################################
## Do some stuff
user_input
perform_action 1  # Repos / Update
perform_action 2  # Install / Remove
perform_action 3  # Fonts
perform_action 4  # Latex
#perform_action 5  # Printer
#perform_action 6  # Servers/Firewall
#perform_action 7  # DVD / Bluray
#perform_action 8  # Firefox
#perform_action 9  # Research
#perform_action 10 # KRB/OpenAFS
## #####################################

rm -f $RESUME_LOG

echo
echo "Post installation configuration has completed"
echo "Please reboot system for changes to take effect"
echo
echo "Note, if you want epd installed, please do that"
echo "manually by running ./soft/epd-7.3-1-rh5-x86_64.sh"
echo


