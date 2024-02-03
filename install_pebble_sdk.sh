#!/bin/bash
set -e
clear

o=$(tput setaf 202)
r=$(tput sgr0)

function output() {
	tput setaf 202
	echo "$1"
	tput sgr0
}

echo "	   _____     "
echo "	  |     |    "
echo "	  |_____|    "
echo "	 /       \   "
echo "	|  $o  | $r   |  "
echo "	|  $o  o $r   |  "
echo "	|   $o  \ $r  |  "
echo "	|         |  "
echo "	 \_______/   "
echo "	  |     |    "
echo "	  |_____|    "
echo ""
echo " ${o}Rebble ${r}Installer Script "
echo "      for Pebble SDK"
echo "        Version 1.0 "

echo ""
echo ""
          
output "1] Install universe repository"
sudo add-apt-repository universe

output "2] Update package list"
sudo apt update 

output "3] Installing legacy python 2"
sudo apt install python2 curl git -y

output "4] Installing legacy python 2 pip"
curl https://bootstrap.pypa.io/pip/2.7/get-pip.py --output get-pip.py
sudo python2 get-pip.py

output "5] Install other dependencies"
sudo apt install wget python2-dev libsdl1.2debian libfdt1 libpixman-1-0 npm gcc -y

output "6] Configure SDK directory"
cd "$HOME"
mkdir pebble-dev

output "7] Download SDK tool"
cd "$HOME"/pebble-dev
wget https://rebble-sdk.s3-us-west-2.amazonaws.com/pebble-sdk-4.6-rc2-linux64.tar.bz2

output "8] Extract SDK tool"
tar -jxf pebble-sdk-4.6-rc2-linux64.tar.bz2

output "9] Configure venv"
cd "$HOME"/pebble-dev/pebble-sdk-4.6-rc2-linux64
python2 -m pip install virtualenv
python2 -m virtualenv .env
source .env/bin/activate

output "10] Install python requirements"
pip install -r requirements.txt
deactivate

output "11] Add SDK tool to PATH"
echo 'export PATH=${HOME}/pebble-dev/pebble-sdk-4.6-rc2-linux64/bin:$PATH' >> ~/.bashrc
source "${HOME}/.bashrc"

output "12] Patch Pebble tool to call python2"
cat ${HOME}/pebble-dev/pebble-sdk-4.6-rc2-linux64/bin/pebble | sed -e 's/python/python2/g' > /tmp/pebble_patched
cp /tmp/pebble_patched ${HOME}/pebble-dev/pebble-sdk-4.6-rc2-linux64/bin/pebble

cat ${HOME}/pebble-dev/pebble-sdk-4.6-rc2-linux64/pebble-tool/pebble_tool/commands/sdk/__init__.py | sed -e 's/subprocess\.check\_output(\[\"python\"/subprocess\.check\_output(\[\"python2\"/g' > /tmp/pebble_patched_2
cp /tmp/pebble_patched_2 ${HOME}/pebble-dev/pebble-sdk-4.6-rc2-linux64/pebble-tool/pebble_tool/commands/sdk/__init__.py

output "13] Install latest SDK"
set +e
pebble sdk install latest
set -e

output "14] Test SDK and Emulator"
cd /tmp
git clone https://github.com/pebble-examples/cards-example
cd cards-example
pebble build
pebble install --emulator basalt

output "15] Update emulator certificate store to fix HTTPS"
cd ${HOME}/pebble-dev/pebble-sdk-4.6-rc2-linux64/
source .env/bin/activate
pip install certifi
deactivate
pebble kill
pebble wipe

output "All done! You are ready to build for Pebble"
output "Use https://dev-portal.rebble.io to upload to the Rebble appstore"
output "See https://developer.rebble.io for a mirror of the Pebble dev docs"
output "Join us at https://rebble.io/discord for chat!"

