## Copyright (C) 2013 Antonio Murdaca <antonio.murdaca@hadlab.com>
##
## This file is part of dotfiles.
##
## dotfiles is free software: you can redistribute it and/or modify
## it under the terms of the GNU General Public License as published by
## the Free Software Foundation, either version 3 of the License, or
## (at your option) any later version.
##
## dotfiles is distributed in the hope that it will be useful,
## but WITHOUT ANY WARRANTY; without even the implied warranty of
## MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
## GNU General Public License for more details.
##
## You should have received a copy of the GNU General Public License
## along with dotfiles. If not, see <http://www.gnu.org/licenses/>.

#

# REMEMBER TO USE amurdaca NEXT TIME I INSTALL FEDORA! (for kerberos)
# and follow mojo guide to configure fedora with RH

#

#!/usr/bin/env bash

reldir=`dirname $0`
cd $reldir
DOTFILES_ROOT=`pwd`

# not sure about this, Dan will fire me :P
#sudo sed -i.bak s/SELINUX=enforcing/SELINUX=disabled/g /etc/selinux/config
#echo "Reboot your system to fully disable selinux..."
#sudo rpm --import https://d2t3ff60b2tol4.cloudfront.net/repomd.xml.key
#sudo sh -c 'cat << EOF > /etc/yum.repos.d/google-chrome.repo
#[google-chrome]
#name=google-chrome - x86_64
#baseurl=http://dl.google.com/linux/chrome/rpm/stable/\$basearch
#enabled=1
#gpgcheck=1
#gpgkey=https://dl-ssl.google.com/linux/linux_signing_key.pub
#EOF'
#sudo sh -c 'cat >/etc/yum.repos.d/docker.repo <<-EOF
#[dockerrepo]
#name=Docker Repository
#baseurl=https://yum.dockerproject.org/repo/main/fedora/\$releasever
#enabled=1
#gpgcheck=1
#gpgkey=https://yum.dockerproject.org/gpg
#EOF'
#sudo dnf clean all
sudo dnf -y update
sudo dnf install mosh git-email terminator zsh cmake htop python-devel ctags vim-enhanced jq the_silver_searcher vim-X11 ruby ruby-devel gnome-tweak-tool gnome-shell-extension-pomodoro graphviz perl-Text-CharWidth krb5-workstation google-chrome-stable golang libvirt-sandbox mercurial recode python-ldap pastebinit 'dnf-command(system-upgrade)' keepassx terminus-fonts pidgin overpass-fonts tokei unrar

sudo systemctl enable --now fstrim.timer

#sudo pip install --upgrade pip
#sudo pip install virtualenvwrapper

# XXX(runcom): terminus-fonts in terminator! set to 15 size!!!!!!!!!
echo "set size=15 in terminator for terminus-fonts"

#sudo dnf install nodejs npm

#sudo dnf install feh i3 i3lock i3status i3-ipc arandr network-manager-applet
#sudo dnf install rxvt-unicode-256color

#sudo dnf install mutt python-inotify goobook
#install offline imap
port tmp="$(mktemp -d)"
#git clone git://github.com/OfflineIMAP/offlineimap.git $tmp
#pushd $tmp
#make build
#sudo python setup.py install
#popd
#rm -rf $tmp
#mkdir $HOME/.mutt
#mkdir -p $HOME/.config/systemd/user
#cp $DOTFILES_ROOT/mutt/_gpg.rc $HOME/.gpg.rc
#cp $DOTFILES_ROOT/mutt/_offlineimaprc $HOME/.offlineimaprc
#cp $DOTFILES_ROOT/mutt/_muttrc $HOME/.muttrc
#cp $DOTFILES_ROOT/mutt/mutt-colors-solarized-dark-16.muttrc $HOME/.mutt/mutt-colors-solarized-dark-16.muttrc
#cp $DOTFILES_ROOT/mutt/mutt-patch-highlighting.muttrc $HOME/.mutt/mutt-patch-highlighting.muttrc
#cp $DOTFILES_ROOT/mutt/signature $HOME/.mutt/signature
#cp $DOTFILES_ROOT/mutt/mail.target $HOME/.config/systemd/user
#cp $DOTFILES_ROOT/mutt/offlineimap@.service $HOME/.config/systemd/user
#cp $DOTFILES_ROOT/mutt/offlineimap@.timer $HOME/.config/systemd/user
#sudo cp $DOTFILES_ROOT/mutt/email_notifier /usr/local/bin/
#cp $DOTFILES_ROOT/mutt/emailnotifier.service $HOME/.config/systemd/user
#cp $DOTFILES_ROOT/mutt/_goobookrc $HOME/.goobookrc

# manually do this
#sudo -i -u amurdaca systemctl --user enable mail.target
#sudo -i -u amurdaca systemctl --user enable offlineimap@amurdaca.timer
#sudo -i -u amurdaca systemctl --user start offlineimap@amurdaca.timer
#sudo -i -u amurdaca systemctl --user enable emailnotifier.service
#sudo -i -u amurdaca systemctl --user start emailnotifier.service

# needed to compile docker with hack/make.sh on host
#sudo dnf install device-mapper-devel audit-libs-devel glibc-static systemd-devel libseccomp-static
# needed to compile docker with rpmbuild
#sudo dnf install btrfs-progs-devel selinux-policy-devel sqlite-devel
# needed to compile rkt
#sudo dnf install squashfs-tools libacl-devel trousers-devel
# needed for --size 10G in virt-builder
sudo dnf install libguestfs-xfs
# using rh shell now
#sudo dnf install irssi
sudo dnf group install with-optional virtualization
sudo dnf install -y @development-tools
sudo dnf group install with-optional "C Development Tools and Libraries"
###
# TODO(runcom): no real need
#sudo dnf install docker-engine
#sudo dnf install docker
#sudo groupadd docker
#sudo usermod -aG docker amurdaca
su -c 'usermod -aG wheel amurdaca'
#sudo cp $DOTFILES_ROOT/sysconfig/docker /etc/sysconfig/docker
#sudo systemctl enable docker
#sudo cp $DOTFILES_ROOT/docker.service /etc/systemd/system/docker.service
#sudo cp $DOTFILES_ROOT/docker.socket /etc/systemd/system/docker.socket
#sudo systemctl start docker

curl https://sh.rustup.rs -sSf | sh

# enable updates-testing
#sudo dnf config-manager --set-enabled updates-testing

# kojirepo! FTW
# ueage: dnf install/update something --enablerepo koji
#sudo sh -c 'cat >/etc/yum.repos.d/koji.repo <<-EOF
#[koji]
#name=Koji Repository
#baseurl=http://kojipkgs.fedoraproject.org/repos/f\$releasever-build/latest/\$basearch/
#enabled=0
#gpgcheck=0
#EOF'

# needed for rhpkg
sudo sh -c 'cat >/etc/yum.repos.d/brew.repo <<-EOF
[brew]
name=Repository for rhpkg
# harcoded 7 - on rhel should be \$releasever
baseurl=http://download.lab.bos.redhat.com/rel-eng/brew/rhel/7/
enabled=1
gpgcheck=0
EOF'
sudo dnf install --enablerepo brew rhpkg
mkdir $HOME/rh-scm

# http://www.if-not-true-then-false.com/2010/install-virtualbox-with-yum-on-fedora-centos-red-hat-rhel/
su -c 'curl -o /etc/yum.repos.d/virtualbox.repo http://download.virtualbox.org/virtualbox/rpm/fedora/virtualbox.repo'
sudo sed -i.bak s/gpgcheck=1/gpgcheck=0/g /etc/yum.repos.d/virtualbox.repo
sudo dnf -y update
sudo dnf install -y binutils gcc make patch libgomp glibc-headers glibc-devel kernel-headers kernel-devel dkms
sudo dnf install VirtualBox-5.0
sudo usermod -a -G vboxusers amurdaca
# http://www.if-not-true-then-false.com/2010/install-virtualbox-guest-additions-on-fedora-centos-red-hat-rhel/
# GUEST ADDITIONS

# tlp for thinkpad
# TODO: does not install akmod-* pkgs below?!?!
sudo dnf install -y --nogpgcheck http://repo.linrunner.de/fedora/tlp/repos/releases/tlp-release-1.0-0.noarch.rpm
su -c 'dnf install http://download1.rpmfusion.org/free/fedora/rpmfusion-free-release-$(rpm -E %fedora).noarch.rpm http://download1.rpmfusion.org/nonfree/fedora/rpmfusion-nonfree-release-$(rpm -E %fedora).noarch.rpm'
sudo dnf config-manager --set-enabled tlp-updates
sudo dnf config-manager --set-enabled tlp-updates-testing
sudo dnf -y update
sudo dnf install tlp tlp-rdw
sudo sed -i.bak s/RESTORE_DEVICE_STATE_ON_STARTUP=0/RESTORE_DEVICE_STATE_ON_STARTUP=1/g /etc/default/tlp
# why nothing on fedora 23?!
sudo dnf install akmod-tp_smapi akmod-acpi_call

sudo sed -i.bak s/SystemMaxUse=/SystemMaxUse=16M/g /etc/systemd/journald.conf
sudo systemctl daemon-reload

sudo dnf -y install vagrant-libvirt

# fedora pkgs
sudo dnf install fedora-packager 
fedora-packager-setup
sudo usermod -a -G mock amurdaca
mkdir $HOME/fedora-scm

#flash player
sudo rpm -ivh http://linuxdownload.adobe.com/adobe-release/adobe-release-x86_64-1.0-1.noarch.rpm
sudo rpm --import /etc/pki/rpm-gpg/RPM-GPG-KEY-adobe-linux
sudo dnf install flash-plugin nspluginwrapper alsa-plugins-pulseaudio libcurl

sudo sed -i.bak s/#user = "root"/user = "amurdaca"/g /etc/libvirt/qemu.conf
# add group as well??? group="qemu"should work though
sudo usermod -aG qemu amurdaca
sudo systemctl restart libvirtd
#sudo dnf install vlc

# install gnome-system-monitor applet
#sudo dnf install libgtop2-devel NetworkManager-glib-devel
#git clone git://github.com/paradoxxxzero/gnome-shell-system-monitor-applet.git $HOME/koding/gnome-shell-system-monitor-applet
#mkdir -p $HOME/.local/share/gnome-shell/extensions
#cd $HOME/.local/share/gnome-shell/extensions
#ln -s $HOME/koding/gnome-shell-system-monitor-applet/system-monitor@paradoxxx.zero.gmail.com

# /etc/krb5.conf -> https://engineering.redhat.com/trac/Libra/wiki/Development_Tools#KerberosSetup

#sudo dnf install fedora-repos-rawhide
# NO -> sudo dnf install git git-email --enablerepo rawhide
#sudo npm -g install instant-markdown-d
#sudo gem install git-up

# sysdig FTW
#curl -s https://s3.amazonaws.com/download.draios.com/stable/install-sysdig | sudo bash

# build-essential kernel-package
#sudo apt-get install libncurses5-dev
set -e

echo ''

install_kem () {
	cp $DOTFILES_ROOT/kem.sh $HOME/.kem.sh
	if [ ! -d "$HOME/.config/autostart" ]; then
		mkdir $HOME/.config/autostart
	fi
	cp $DOTFILES_ROOT/kensigton_expert_mouse.desktop $HOME/.config/autostart/
}

install_fonts () {
  if [ -d "$HOME/.fonts" ]; then
    rm -rf $HOME/.fonts/*
  fi
  if [ -d "$HOME/.config/fontconfig/conf.d" ]; then
    rm -rf $HOME/.config/fontconfig/conf.d
  fi
  mkdir -p $HOME/.config/fontconfig/conf.d
  cd $HOME/.fonts && wget https://github.com/Lokaltog/powerline/raw/develop/font/PowerlineSymbols.otf
  cd $HOME/.config/fontconfig/conf.d && wget https://github.com/Lokaltog/powerline/raw/develop/font/10-powerline-symbols.conf
  fc-cache -vf $HOME/.fonts
  cp -R $DOTFILES_ROOT/fonts $HOME/.fonts
  fc-cache -vf $HOME/.fonts
  echo '==============='
  echo 'fonts installed'
  echo '==============='
}

install_git_config () {
  if [ -f "$HOME/.gitconfig" ]; then
    rm -rf $HOME/.gitconfig
  fi
  if [ -f "$HOME/.git-credentials" ]; then
    rm -rf $HOME/.git-credentials
  fi
  if [ -f "$HOME/.cvsignore" ]; then
    rm -rf $HOME/.cvsignore
  fi
  cp -R $DOTFILES_ROOT/git/gitconfig $HOME/.gitconfig
  cp -R $DOTFILES_ROOT/git/git-credentials $HOME/.git-credentials
  git config --global core.excludesfile '~/.cvsignore'
  echo tags >> $HOME/.cvsignore
  echo '.idea' >> $HOME/.cvsignore
  echo '==================='
  echo 'gitconfig installed, edit $HOME/.git-credentials with GOOGLE APP password for git email-send'
  echo '==================='
}
install_oh_my_zsh () {
  if [ -d "$HOME/.oh-my-zsh" ]; then
    rm -rf $HOME/.oh-my-zsh
  fi
  git clone git://github.com/robbyrussell/oh-my-zsh.git $HOME/.oh-my-zsh
  cp -R $DOTFILES_ROOT/zsh/zshrc $HOME/.zshrc
  #chsh -s /bin/zsh
  cp -R $DOTFILES_ROOT/zsh/oh-my-zsh/custom $HOME/.oh-my-zsh
  cp -R $DOTFILES_ROOT/zsh/oh-my-zsh/themes/* $HOME/.oh-my-zsh/themes/
  cp $DOTFILES_ROOT/zsh/zshenv $HOME/.zshenv
  echo '=========================================================================================='
  echo 'oh-my-zsh installed and shell changed to zsh, you may need to restart your terminal/system'
  echo '=========================================================================================='
}

install_gvim_config () {
  if [ -f "$HOME/.vimrc" ]; then
    rm -rf $HOME/.vimrc
  fi
  if [ -d "$HOME/.vim" ]; then
    rm -rf $HOME/.vim
  fi
  cp $DOTFILES_ROOT/vim/vimrc $HOME/.vimrc
  cp -R $DOTFILES_ROOT/vim/vim $HOME/.vim/
  curl -sSfLo ~/.vim/autoload/plug.vim --create-dirs https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  gvim -v -c "execute \"PlugInstall\" | q | q"
  echo '================================='
  echo 'vim config and plugins installed'
  echo '================================='
}

install_config () {
  cp $DOTFILES_ROOT/config/* $HOME/.config/ -R
  echo '================================='
  echo 'config installed'
  echo '================================='
}

# using rh shell now
#install_irssi_config () {
  #rm -rf $HOME/.irssi/
  #cp $DOTFILES_ROOT/irssi $HOME/.irssi -R
  #echo '================================='
  #echo 'irssi config installed now edit passwords!!!!!!!'
  #echo '================================='
#}

install_xstuff () {
  rm -rf $HOME/.Xdefaults
  rm -rf $HOME/.Xresources
  cp $DOTFILES_ROOT/.Xdefaults $HOME/.Xdefaults
  cp $DOTFILES_ROOT/.Xresources $HOME/.Xresources
  xrdb ~/.Xresources
  if [ -f "/usr/share/applications/rxvt-unicode.desktop"  ]; then
	sudo mv /usr/share/applications/rxvt-unicode.desktop /usr/share/applications/rxvt-unicode.desktop_
  fi
  # ugly hack for the filco keypad... and equal sign doesn't work at all...
  sudo cp $DOTFILES_ROOT/00-cypress.conf /usr/share/X11/xorg.conf.d
}

install_rhpaste () {
  rm -rf $HOME/.pastebinit.xml
  cp $DOTFILES_ROOT/.pastebinit.xml $HOME/.pastebinit.xml
  sudo rm -rf /etc/pastebinit/pastebin.test.redhat.com
  sudo cp $DOTFILES_ROOT/pastebin.test.redhat.com /etc/pastebinit
}

install_rhpaste
install_kem
install_fonts
install_git_config
install_oh_my_zsh
install_gvim_config
install_config
#install_irssi_config
install_irssi_fnotify
install_rpmmacros
install_xstuff
#install_i3stuff

echo '========================================================'
echo '========================================================'
echo 'Now, gnome-tweak-tool edits, insync setup, ssh keys from insync'
echo 'rh vpn setup, google-chrome accounts setup'
echo 'kerbersos setup, left menu gnome, twitter/facebook/github other?'
echo 'ENABLE SYSTEM MONITOR IN GNOME-TWEAK-TOOL, adjust graph width of system-monitor!!!'
echo 'reboot...'
echo '========================================================'
echo '========================================================'
echo 'Done, you may now remove this directory from your system'
echo '========================================================'
echo '========================================================'
