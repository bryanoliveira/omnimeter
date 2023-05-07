#!/bin/bash

DIRNAME=$(dirname $(realpath "$0"))

# create .desktop and .service files for current installation
cp omnimeter.service.example omnimeter.service
sed -i "s+<OMNIMETERFOLDER>+$DIRNAME+" omnimeter.service
sed -i "s+<OMNIMETERUSER>+$(whoami)+" omnimeter.service
cp omnimeter.desktop.example omnimeter.desktop
sed -i "s+<OMNIMETERFOLDER>+$DIRNAME+" omnimeter.desktop
cp run.sh.example run.sh
sed -i "s+<PYTHONEXECUTABLE>+$(which python)+" run.sh
sed -i "s+<OMNIMETERFOLDER>+$DIRNAME+" run.sh

# get necessary environment variables
printenv > sysenv

# install icon
icons_folder=~/.icons
mkdir -p $icons_folder
rm -rf $icons_folder/omnimeter.svg
cp ./omnimeter/icon.svg $icons_folder/omnimeter.svg
echo "Installed Icon in" $icons_folder

# install desktop shortcut
shortcuts_folder=~/.local/share/applications/
mkdir -p $shortcuts_folder
rm -rf $shortcuts_folder/omnimeter.desktop
cp ./omnimeter.desktop $shortcuts_folder/omnimeter.desktop
echo "Installed Desktop shortcut in" $shortcuts_folder

services_folder=/etc/systemd/system
sudo cp ./omnimeter.service $services_folder/omnimeter.service
sudo systemctl daemon-reload
sudo systemctl enable omnimeter
sudo systemctl start omnimeter
echo "Installed Service in" $services_folder
