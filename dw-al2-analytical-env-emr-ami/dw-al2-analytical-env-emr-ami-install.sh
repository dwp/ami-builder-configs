#!/bin/sh
#set -eEu

# Make changes to hardened-ami that are required for EMR to work

# Set Proxy
echo "http_proxy=$http_proxy"
echo "https_proxy=$https_proxy"
echo "no_proxy=$no_proxy"

export https_proxy=$https_proxy
export http_proxy=$http_proxy
export no_proxy=$no_proxy

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

# building pandas from source requires installing a C compiler so just get a binary.
cat <<EOF > /tmp/py_requirements.txt
--only-binary=:pandas:
nltk==3.6.1
yake==0.4.7
spark-nlp==3.0.1
scikit-learn==0.24.1
scikit-spark==0.4.0
torch==1.8.1
keras==2.4.3
scipy==1.6.2
pandas==1.3.0
numpy==1.17.3
seaborn==0.11.1
statsmodels==0.12.2
kaleido==0.2.1
fuzzywuzzy==0.18.0  
openpyxl==3.0.8
python-docx==0.8.11
EOF

sudo -E pip3 install --upgrade pip setuptools || true
sudo -E python3 -m pip install -r /tmp/py_requirements.txt || true
