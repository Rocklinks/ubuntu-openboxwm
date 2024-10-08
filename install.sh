#!/bin/bash
########################
# Author: Rocklin K S
# Date: 07/09/2024
# This script makes my config to autinstall
# Version: v2
############################


set -exo  pipefail

mkdir -p "$HOME/.config"

cp -rf config/networkmanager-dmenu config/openbox config/xfce4 "$HOME/.config"

copy_normal_polybar() {
    cp -rf config/polybar "$HOME/.config/"
    echo "Normal Polybar configuration copied to ~/.config"
}

copy_transparent_polybar() {
    mv -f config/polybar-transparent "$HOME/.config/polybar"
    echo "Transparent Polybar configuration copied to ~/.config/polybar"
}

echo "Select Polybar version:"
echo "1. Normal"
echo "2. Transparent"
read -p "Enter your choice (1 or 2): " choice

# Handle user input
case $choice in
    1)
        copy_normal_polybar
        ;;
    2)
        copy_transparent_polybar
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2."
        exit 1 
        ;;
esac

# Make scripts executable if the directory exists
if [ -d "$HOME/.config/polybar/scripts/" ]; then
    chmod +x "$HOME/.config/polybar/scripts/"*
    echo "All scripts in ~/.config/polybar/scripts/ have been made executable."
else
    echo "Directory ~/.config/polybar/scripts/ does not exist, skipping chmod."
fi

#### Wifi Config ####
SYSTEM_CONFIG="$HOME/.config/polybar/system.ini"
POLYBAR_CONFIG="$HOME/.config/polybar/config.ini"

ETHERNET=$(ip link | awk '/state UP/ && !/wl/ {print $2}' | tr -d :)
WIFI=$(ip link | awk '/state UP/ && /wl/ {print $2}' | tr -d :)


if [ -n "$WIFI" ]; then
    echo "Using Wi-Fi interface: $WIFI"
    sed -i "s/sys_network_interface = wlan0/sys_network_interface = $WIFI/" "$SYSTEM_CONFIG"
    

elif [ -n "$ETHERNET" ]; then
    echo "Using Ethernet interface: $ETHERNET"
    sed -i "s/sys_network_interface = wlan0/sys_network_interface = $ETHERNET/" "$SYSTEM_CONFIG"
    sed -i "s/network/ethernet/g" "$POLYBAR_CONFIG"

else
    echo "No active network interfaces found."
fi

sudo -v

sudo apt update && sudo apt upgrade -y
sudo apt install vlc stacer zram-tools preload xarchiver xorg thunar gnome-disk-utility thunar-volman thunar-archive-plugin udiskie udisks2 tumbler gvfs git xfce4-panel policykit-1-gnome xfdesktop4 blueman seahorse gir1.2-appindicator3-0.1 xfce4-settings xfce4-power-manager libayatana-appindicator3-1 bc openbox obconf playerctl xcompmgr parcellite htop neofetch numlockx rofi polybar lxappearance dirmngr ca-certificates software-properties-common zsh tlp tlp-rdw viewnior obs-studio virtualbox apt-transport-https gir1.2-gtksource-4 libpeas-1.0-0 libpeas-common

#install firefox
sudo install -d -m 0755 /etc/apt/keyrings
wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null

echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null

echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000

Package: firefox*
Pin: release o=Ubuntu
Pin-Priority: -1' | sudo tee /etc/apt/preferences.d/mozilla
sudo apt update && sudo apt install firefox -y

## install docklike-plugin
if ! dpkg -l | grep -q xfce4-docklike-plugin; then
    echo "xfce4-docklike-plugin not found. Installing from GitHub..."
    URL="https://github.com/jakbin/xfce4-docklike-plugin/releases/download/0.4.2/xfce4-docklike-plugin.deb"
    wget $URL -O xfce4-docklike-plugin.deb
    sudo dpkg -i xfce4-docklike-plugin.deb
    sudo rm xfce4-docklike-plugin.deb

    echo "Installation complete."
else
    echo "xfce4-docklike-plugin is already installed."
fi

URL1="http://packages.linuxmint.com/pool/backport/x/xed/xed-common_3.6.6+wilma_all.deb"
URL2="http://packages.linuxmint.com/pool/backport/x/xed/xed_3.6.6+wilma_amd64.deb"

######## Xed
read -p "Do you want to install Xed? (y/n): " choice
if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
    echo "Downloading Xed packages..."
    wget $URL1
    wget $URL2

    echo "Installing Xed packages..."
    sudo dpkg -i xed-common_3.6.6+wilma_all.deb
    sudo dpkg -i xed_3.6.6+wilma_amd64.deb
    # Fix any dependency issues
    sudo apt-get install -f

    echo "Cleaning up..."
    sudo rm xed-common_3.6.6+faye_all.deb
    sudo rm xed_3.6.6+faye_amd64.deb

    echo "Xed installation completed."
else
    echo "Installation aborted."
fi

########################################### wps office & Localsend
URL="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb"
FILE="wps-office_11.1.0.11723.XA_amd64.deb"
L=LocalSend-1.15.4-linux-x86-64.deb
read -p "Do you want to download and install WPS Office & localsend ? (y/n): " choice

if [[ "$choice" == [Yy] ]]; then
    wget "$URL"
    wget https://github.com/localsend/localsend/releases/download/v1.15.4/LocalSend-1.15.4-linux-x86-64.deb
    
    # Install the downloaded package
    sudo apt install ./"$FILE" -y
    sudo apt install ./"$L" -y
    
    # Remove the downloaded file
    sudo rm "$FILE"
    sudo rm "$L"
    
    echo "WPS Office has been installed successfully."
else
    echo "Installation canceled."
fi

#############################################3 Wine

read -p "Do you want to install Wine? (y/n): " answer

if [[ "$answer" == "y" ]]; then
    sudo dpkg --add-architecture i386
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
    sudo apt update
    sudo apt install wine-staging winetricks zenity -y
else
    echo "Wine will not be installed."
fi


###################################################### 

enable_service() {
    local service_name=$1
    sudo systemctl enable "$service_name"
}

enable_service bluetooth
enable_service tlp
enable_service preload
enable_service zramswap

sudo cp -rf udev/rules.d/90-backlight.rules /etc/udev/rules.d/
# Rules for the brightness
USERNAME=$(whoami)
sudo sed -i "s/\$USER/$USERNAME/g" /etc/udev/rules.d/90-backlight.rules

# Copy the networkmanager_dmenu file, forcing the overwrite
sudo cp -Rf usr/bin/networkmanager_dmenu /usr/bin/
sudo chmod +x /usr/bin/networkmanager_dmenu

sudo mkdir -p Fonts
sudo tar -xzvf Fonts.tar.gz -C Fonts
sudo cp -Rf Fonts/ /usr/share/fonts/
sudo fc-cache -fv

# Create the zsh directory and extract the contents of zsh.tar.gz
home = $HOME
sudo mkdir -p zsh
sudo tar -xzvf zsh.tar.gz -C zsh
sudo cp -Rf zsh/.bashrc "$home/.bashrc"
sudo cp -Rf zsh/.zshrc "$home/.zshrc"

#############################################
THEMES_DIR="themes"

# Check if the themes directory exists
if [ ! -d "$THEMES_DIR" ]; then
    echo "Themes directory does not exist."
    exit 1
fi

# Loop through .xz and .gz files in the themes directory
for file in "$THEMES_DIR"/*.{xz,gz}; do
    # Check if the file exists (to avoid errors if no files match)
    if [ -e "$file" ]; then
        echo "Extracting $file..."

        # Determine the file type and extract accordingly
        case "$file" in
            *.xz)
                # Extract .xz files
                tar -xf "$file" -C "$THEMES_DIR"
                ;;
            *.gz)
                # Extract .gz files
                tar -xzf "$file" -C "$THEMES_DIR"
                ;;
        esac

        # Move the extracted folder to /usr/share/themes/
        extracted_folder="${file%.*}"  # Remove the file extension
        extracted_folder="${extracted_folder%.*}"  # Remove the second extension if any
        if [ -d "$extracted_folder" ]; then
            echo "Moving $extracted_folder to /usr/share/themes/"
            sudo mv "$extracted_folder" /usr/share/themes/
        else
            echo "No extracted folder found for $file."
        fi
    else
        echo "No .xz or .gz files found in $THEMES_DIR."
    fi
done

########################################################
#### XDM ###
wget https://github.com/subhra74/xdm/releases/download/8.0.29/xdman_gtk_8.0.29_amd64.deb
sudo dpkg -i xdman_gtk_8.0.29_amd64.deb
sudo rm xdman_gtk_8.0.29_amd64.deb

## Icons
SOURCE_DIR="./icons"

TARGET_DIR="/usr/share/icons"
for file in "$SOURCE_DIR"/*.tar.gz "$SOURCE_DIR"/*.tar.xz; do
    if [[ -e "$file" ]]; then
        if [[ "$file" == *.tar.gz ]]; then
            sudo tar -xzf "$file" -C /tmp/
        elif [[ "$file" == *.tar.xz ]]; then
            sudo tar -xf "$file" -C /tmp/
        fi
        sudo mv /tmp/* "$TARGET_DIR"/
        
        rm "$file"
    fi
done
echo "All operations completed successfully."






















