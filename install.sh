#!/bin/bash
########################
# Author: Rocklin K S
# Date: 07/09/2024
# This script makes my config to autinstall
# Version: v1
############################


set -exo  pipefail

sudo apt update && sudo apt upgrade -y
packages=(
    vlc stacer zram-tools preload xarchiver xorg thunar gnome-disk-utility
    thunar-volman thunar-archive-plugin udiskie udisks2 tumbler gvfs git
    xfce4-panel policykit-1-gnome xfdesktop4 blueman seahorse gir1.2-appindicator3-0.1
    xfce4-settings xfce4-power-manager imagemagick libayatana-appindicator3-1
    bc openbox obconf playerctl xcompmgr parcellite htop neofetch
    numlockx rofi polybar lxappearance dirmngr ca-certificates software-properties-common
    zsh tlp tlp-rdw viewnior obs-studio virtualbox apt-transport-https gir1.2-gtksource-4 libpeas-1.0-0 libpeas-common
)


for package in "${packages[@]}"; do
    if ! dpkg -l | grep -q "^ii  $package "; then
        echo "$package is not installed. Installing..."
        sudo apt install -y "$package"
    else
        echo "$package is already installed."
    fi
done


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

# Define the list of packages to install
URL="https://github.com/jakbin/xfce4-docklike-plugin/releases/download/0.4.2/xfce4-docklike-plugin.deb"

# Download the .deb file
wget $URL -O xfce4-docklike-plugin.deb

# Install the .deb package
sudo dpkg -i xfce4-docklike-plugin.deb

# Remove the downloaded .deb file
sudo rm xfce4-docklike-plugin.deb

URL1="http://packages.linuxmint.com/pool/backport/x/xed/xed-common_3.6.6%2Bwilma_all.deb"
URL2="http://packages.linuxmint.com/pool/backport/x/xed/xed_3.6.6%2Bwilma_amd64.deb"

# Download the .deb files
wget $URL1
wget $URL2

# Install the .deb packages
sudo dpkg -i xed-common_3.6.6+wilma_all.deb
sudo dpkg -i xed_3.6.6+wilma_amd64.deb

# Remove the downloaded .deb files
sudo rm xed-common_3.6.6+wilma_all.deb
sudo rm xed_3.6.6+wilma_amd64.deb

###################################### Qbittorrent 
sudo add-apt-repository ppa:qbittorrent-team/qbittorrent-stable -y
sudo apt update && sudo apt install qbittorrent -y


########################################### wps office
wget https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/11723/wps-office_11.1.0.11723.XA_amd64.deb
sudo apt install ./wps-office_11.1.0.11723.XA_amd64.deb
sudo rm wps-office_11.1.0.11723.XA_amd64.deb
######################################## Localsend
wget https://github.com/localsend/localsend/releases/download/v1.15.4/LocalSend-1.15.4-linux-x86-64.deb
sudo apt install ./LocalSend-1.15.4-linux-x86-64.deb

sudo rm LocalSend-1.15.4-linux-x86-64.deb

#############################################3 Wine

read -p "Do you want to install Wine? (y/n): " answer

if [[ "$answer" == "y" ]]; then
    sudo dpkg --add-architecture i386
    sudo mkdir -pm755 /etc/apt/keyrings
    sudo wget -O /etc/apt/keyrings/winehq-archive.key https://dl.winehq.org/wine-builds/winehq.key
    sudo wget -NP /etc/apt/sources.list.d/ https://dl.winehq.org/wine-builds/ubuntu/dists/noble/winehq-noble.sources
    sudo apt update
    sudo apt install wine-staging winetricks zenity lutris
else
    echo "Wine will not be installed."
fi


###################################################### SDDM optional

install_sddm() {
    sudo apt install sddm --noconfirm -y
    sudo systemctl enable sddm
    sudo systemctl start sddm
    echo "SDDM has been installed and enabled successfully."
}

# Ask the user if they want to install and configure SDDM
read -p "Do you want to install and configure SDDM? (y/n): " response

# Convert response to lowercase
response=${response,,}

if [[ "$response" == "y" ]]; then
    install_sddm
else
    echo "SDDM installation skipped."
fi


##Services to Enbale
sudo systemctl enable --now bluetooth
sudo systemctl enable --now preload
sudo systemctl enable --now zramswap

# brightness on polybar
sudo cp -Rf udev/rules.d/90-backlight.rules /etc/udev/rules.d/

# Rules for the brightness
RULES_FILE="/etc/udev/rules.d/90-backlight.rules"
sudo sed -i "s/\$USER/$(logname)/g" "$RULES_FILE"

# Copy the networkmanager_dmenu file, forcing the overwrite
sudo cp -Rf usr/bin/networkmanager_dmenu /usr/bin/
sudo chmod +x /usr/bin/networkmanager_dmenu

mkdir -p Fonts
tar -xzvf Fonts.tar.gz -C Fonts
sudo cp -Rf Fonts/ /usr/share/fonts/
sudo fc-cache -fv

config_dir="/home/$(logname)/.config"
home_dir="/home/$(logname)"

# Create the destination directory if it doesn't exist
sudo mkdir -p "$config_dir"

# Copy the directories
sudo cp -Rf config/dunst config/networkmanager-dmenu config/openbox config/xfce4 "$config_dir/"

copy_normal_polybar() {
    sudo cp -rf config/polybar $home_dir/.config/
    echo "Normal Polybar configuration copied to ~/.config"
}

# Function to copy transparent Polybar configuration
copy_transparent_polybar() {
    sudo cp -rf config/polybar-transparent $home_dir/.config/polybar
    echo "Transparent Polybar configuration copied to ~/.config/polybar"
}

# Prompt user for choice
echo "Select Polybar version:"
echo "1. Normal"
echo "2. Transparent"
read -p "Enter your choice (1 or 2): " choice

# Handle user choice
case $choice in
    1)
        copy_normal_polybar
        ;;
    2)
        copy_transparent_polybar
        ;;
    *)
        echo "Invalid choice. Please select 1 or 2."
        ;;
esac
# Change permissions for polybar scripts
sudo chmod +x "$config_dir/polybar/scripts/"*

# Create the zsh directory and extract the contents of zsh.tar.gz
sudo mkdir -p zsh
tar -xzvf zsh.tar.gz -C zsh
sudo cp -Rf zsh/.bashrc "$home_dir/.bashrc"
sudo cp -Rf zsh/.zshrc "$home_dir/.zshrc"
sudo cp -Rf zsh/* /usr/share
sudo mkdir -p $home_dir/.local/share
sudo mkdir -p $home/dir/.local/share/cache
DIR="$home_dir/.local/share/cache"
sudo cp -rf cache/* "$DIR/"


SYSTEM_CONFIG="$home_dir/.config/polybar/system.ini"
POLYBAR_CONFIG="$home_dir/.config/polybar/config.ini"

# Get the active Ethernet and Wi-Fi interfaces
ETHERNET=$(ip link | awk '/state UP/ && !/wl/ {print $2}' | tr -d :)
WIFI=$(ip link | awk '/state UP/ && /wl/ {print $2}' | tr -d :)

# Check if Wi-Fi is active
if [ -n "$WIFI" ]; then
    echo "Using Wi-Fi interface: $WIFI"
    # Replace wlan0 with the actual Wi-Fi interface name in system.ini
    sed -i "s/sys_network_interface = wlan0/sys_network_interface = $WIFI/" "$SYSTEM_CONFIG"
    
# Check if Ethernet is active
elif [ -n "$ETHERNET" ]; then
    echo "Using Ethernet interface: $ETHERNET"
    # Replace wlan0 with the Ethernet interface name in system.ini
    sed -i "s/sys_network_interface = wlan0/sys_network_interface = $ETHERNET/" "$SYSTEM_CONFIG"
    
    # Replace 'network' with 'ethernet' in config.ini
    sed -i "s/network/ethernet/g" "$POLYBAR_CONFIG"

else
    echo "No active network interfaces found."
fi
#sudo chmod 777 /sys/class/backlight/intel_backlight/brightness


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

ICONS_DIR="icons"

# Check if the icons directory exists
if [ ! -d "$ICONS_DIR" ]; then
    echo "Icons directory does not exist."
    exit 1
fi

# Loop through .xz files in the icons directory
for file in "$ICONS_DIR"/*.xz; do
    # Check if the file exists (to avoid errors if no files match)
    if [ -e "$file" ]; then
        echo "Extracting $file..."

        # Create the kora folder
        KORA_DIR="$ICONS_DIR/kora"
        mkdir -p "$KORA_DIR"

        # Extract the .xz file to the kora folder
        tar -xf "$file" -C "$KORA_DIR"

        # Copy the extracted contents to /usr/share/icons/
        echo "Copying extracted contents to /usr/share/icons/..."
        sudo cp -r "$KORA_DIR"/* /usr/share/icons/

        # Remove the kora folder
        rm -rf "$KORA_DIR"
    else
        echo "No .xz files found in $ICONS_DIR."
    fi
done



sudo apt install autoconf gcc make pkg-config libpam0g-dev libcairo2-dev libfontconfig1-dev libxcb-composite0-dev libev-dev libx11-xcb-dev libxcb-xkb-dev libxcb-xinerama0-dev libxcb-randr0-dev libxcb-image0-dev libxcb-util-dev libxcb-xrm-dev libxkbcommon-dev libxkbcommon-x11-dev libjpeg-dev -y
git clone https://github.com/Raymo111/i3lock-color.git
cd i3lock-color
./install-i3lock-color.sh
cd ..

wget https://raw.githubusercontent.com/betterlockscreen/betterlockscreen/main/install.sh -O - -q | sudo bash -s system
sudo rm -rf betterlockscreen























