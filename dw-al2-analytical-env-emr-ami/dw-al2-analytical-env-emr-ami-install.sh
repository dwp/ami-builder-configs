#!/bin/sh
#set -eEu

# Make changes to hardened-ami that are required for EMR to work

# Set Proxy
echo "HTTP_PROXY=$HTTP_PROXY"
echo "HTTPS_PROXY=$HTTPS_PROXY"
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "NO_PROXY=$NO_PROXY"
echo "no_proxy=$no_proxy"

export https_proxy=$https_proxy
export http_proxy=$http_proxy
export no_proxy=$no_proxy


apk update
apk add make automake gcc g++ subversion python3-dev

# Change SELinux config to be permissive
cat > /etc/selinux/config << EOF
SELINUX=permissive
SELINUXTYPE=targeted
EOF
#sed -i -e 's/selinux=0/selinux=1 enforcing=0/' /boot/grub/menu.lst

# Relax umask settings and defaults
sed -i 's/^.*umask 0.*$/umask 002/' /etc/bashrc
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile
sed -i 's/^.*umask 0.*$/umask 002/' /etc/profile.d/*.sh
sed -i 's/^umask 027/umask 002/' /etc/init.d/functions

cat <<EOF > ~/py_requirements.txt
nltk==3.6.1
yake==0.4.7
spark-nlp==3.0.1
scikit-learn==0.24.1
scikit-spark==0.4.0
torch==1.8.1
keras==2.4.3
scipy==1.6.2
seaborn==0.11.1
EOF

pip3 install -r ~/py_requirements.txt > ~/py_requirements.logs

