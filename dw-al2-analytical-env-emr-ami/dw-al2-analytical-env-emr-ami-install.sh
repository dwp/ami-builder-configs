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

# building pandas from source requires installing a C compiler so just get a binary.
sudo cat > $HOME/py_requirements.txt << EOF
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
scikit-learn==0.24.1
scikit-spark==0.4.0
scipy==1.6.2
seaborn==0.11.1
spark-nlp==3.0.1
statsmodels==0.12.2
torch==1.8.1
yake==0.4.7
# python-Levenshtein==0.12.2 - issue installing here
EOF

sudo -E pip3 install --upgrade pip setuptools
sudo -E pip3 --no-cache-dir install -r $HOME/py_requirements.txt

rm -f $HOME/py_requirements.txt