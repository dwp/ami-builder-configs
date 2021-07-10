#!/bin/sh
set -eEu

# Make changes to hardened-ami that are required for EMR to work

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

cat <<EOF > /tmp/py_requirements.txt
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

pip3 install -r /tmp/py_requirements.txt
