#!/bin/bash
clear

print_banner() {
    echo '
 __          __     _   _ _____  
 \ \        / /\   | \ | |  __ \ 
  \ \  /\  / /  \  |  \| | |  | |
   \ \/  \/ / /\ \ | . ` | |  | |
    \  /\  / ____ \| |\  | |__| |
     \/  \/_/    \_\_| \_|_____/ 
                                    
      Wand Installation Script
    '
}
print_banner

echo "Please answer these questions to set up the game:"
echo "Enter password for the database (leave empty for a random password):"
dbpass=""
while IFS= read -r -s -n1 char; do
    if [[ -z $char ]]; then
        break
    elif [[ $char == $'\177' ]]; then # handle backspace
        if [ ${#dbpass} -gt 0 ]; then
            dbpass="${dbpass%?}" # remove last character
            echo -ne '\b \b' # erase last character on the screen
        fi
    else
        echo -n '*'
        dbpass+="$char"
    fi
done

if [ -z "$dbpass" ]; then
    dbpass=$(openssl rand -base64 12)
fi

echo "Enter the hostname for the game (example: example.com) (leave empty for localhost):"
read hostname
if [ -z "$hostname" ]; then
    hostname=localhost
fi

echo "Enter your external IP address (leave empty for localhost):"
read ipadd
if [ -z "$ipadd" ]; then
    ipadd=127.0.0.1
fi

read -p "Do you want to run the game when the installation ends? (y/N): " run_game


install_docker_official() {
    echo "Installing Docker using the official installation script..."
    curl -fsSL https://get.docker.com -o get-docker.sh
    sudo sh get-docker.sh
    sudo systemctl start docker
    sudo systemctl enable docker
}

if [[ $(uname) == "Linux" ]]; then
    echo "Setting up the environment for Linux."
    
    # Detect the package manager
    if command -v apt &> /dev/null || command -v dnf &> /dev/null || command -v yum &> /dev/null; then
        if command -v apt &> /dev/null; then
            PKG_MANAGER="apt"
            INSTALL_CMD="sudo apt update && sudo apt install -y"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
            INSTALL_CMD="sudo dnf install -y"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
            INSTALL_CMD="sudo yum install -y"
        fi

        echo "Detected package manager: $PKG_MANAGER"

        # Install git and curl
        $INSTALL_CMD git curl

        # Install Docker using the official script supports Debian, Ubuntu, and CentOS
        install_docker_official

    # Installer for Arch because they do it a little differently over there
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        
        echo "Detected package manager: $PKG_MANAGER"

        # Update the system
        sudo pacman -Syu --noconfirm
        
        # Install Docker, git, and curl
        $INSTALL_CMD docker docker-compose git curl
        sudo systemctl start docker
        sudo systemctl enable docker
    else
        echo "This operating system isn't supported yet. Feel free to join the Discord and ask questions."
        exit 1
    fi

    # Install Docker Compose for non-Arch systems
    if [[ $PKG_MANAGER != "pacman" ]]; then
        echo "Installing Docker Compose..."
        sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
        sudo chmod +x /usr/local/bin/docker-compose
    fi

elif [[ $(uname) == "Darwin" ]]; then
    echo "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    echo "Installing Docker, git, and Docker Compose..."
    brew install docker
    brew install git
    brew install docker-compose@2.20.3
else
    echo "This operating system isn't supported yet. Feel free to join the Discord and ask questions."
    exit 1
fi

echo "Done setting up the environment."
echo "Downloading Game Files"
git clone --recurse-submodules https://github.com/solero/wand && cd wand
echo "Done Downloading the game files."
sudo rm -r .env

echo "# Database
POSTGRES_USER=postgres
POSTGRES_PASSWORD=$dbpass

# Web
WEB_PORT=80
WEB_HOSTNAME=$hostname

WEB_LEGACY_PLAY=http://old.$hostname
WEB_LEGACY_MEDIA=http://legacy.$hostname

WEB_VANILLA_PLAY=http://play.$hostname
WEB_VANILLA_MEDIA=http://media.$hostname

WEB_RECAPTCHA_SITE=
WEB_RECAPTCHA_SECRET=

WEB_SENDGRID_KEY=

# Game
GAME_ADDRESS=$ipadd
GAME_LOGIN_PORT=6112

# Snowflake
SNOWFLAKE_HOST=$ipadd
SNOWFLAKE_PORT=7002

APPLY_WINDOWMANAGER_OFFSET=False

ALLOW_FORCESTART_SNOW=False
ALLOW_FORCESTART_TUSK=True

MATCHMAKING_TIMEOUT=30" > .env

echo "Done!"


if [ "$run_game" == "y" ] || [ "$run_game" == "Y" ]; then
    sudo docker-compose up
else
    echo "You chose not to run the game. To run the game later, execute the command: cd wand && sudo docker-compose up"
fi
