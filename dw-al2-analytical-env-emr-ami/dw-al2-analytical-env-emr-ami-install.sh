#!/bin/sh
#set -eEu
set -x
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
dfply==0.3.3
dplython==0.0.7
fuzzywuzzy==0.18.0
kaleido==0.2.1
keras==2.4.3
nltk==3.6.1
numpy==1.17.3
openpyxl==3.0.7
pandas==1.3.0
PyDriller==2.0
python-docx==0.8.11
python-Levenshtein==0.12.2
scikit-learn==0.24.1
scikit-spark==0.4.0
scipy==1.6.2
seaborn==0.11.1
spark-nlp==3.0.1
statsmodels==0.12.2
torch==1.8.1
yake==0.4.7
EOF

sudo -E pip3 install --upgrade pip setuptools
sudo -E python3 -m pip --no-cache-dir install -r /tmp/py_requirements.txt
