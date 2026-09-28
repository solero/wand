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
    echo "Installing Docker..."
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
            INSTALL_CMD="sudo apt"
        elif command -v dnf &> /dev/null; then
            PKG_MANAGER="dnf"
            INSTALL_CMD="sudo dnf"
        elif command -v yum &> /dev/null; then
            PKG_MANAGER="yum"
            INSTALL_CMD="sudo yum"
        fi

        echo "Detected package manager: $PKG_MANAGER"

        # Update the system
        echo "Updating system repositories..."
        $INSTALL_CMD update 

        # Install git and curl
        echo "Installing Curl and Git..."
        $INSTALL_CMD install -y git curl

        # Install Docker using the official script supports Debian, Ubuntu, and CentOS
        install_docker_official

    # Installer for Arch because they do it a little differently over there
    elif command -v pacman &> /dev/null; then
        PKG_MANAGER="pacman"
        INSTALL_CMD="sudo pacman -S --noconfirm"
        
        echo "Detected package manager: $PKG_MANAGER"

        # Update the system
        echo "Updating system repositories..."
        sudo pacman -Syu --noconfirm
        
        # Install Docker, git, and curl
        echo "Installing Curl and Git, Docker and Docker Compose..."
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

echo "
##############################################
# Database
##############################################
# 
# POSTGRES_USER
# -------------
# The name for the root database account and 
# also the name for the database itself.
#
# POSTGRES_PASSWORD
# -----------------
# The password for the postgres database. It
# is reccomended that you change this to 
# something secure!
##############################################

POSTGRES_USER=postgres
POSTGRES_PASSWORD=$dbpass

##############################################
# Web
##############################################
#
# WEB_PORT
# --------
# The port that the nginx container will 
# listen on. It is fine to leave this so long
# as you do not have a web server running
# already.
#
# WEB_HOSTNAME
# ------------
# The hostname you intend to serve web traffic
# through. For example `clubpenguin.com`.
#
# WEB_LEGACY_PLAY
# ---------------
# The URL at which clients can access your 
# legacy play page from. Ideally this is 
# accessed via a subdomain like 
# `play.clubpenguin.com` but it can also be on 
# your root domain with a  path like 
# `http://clubpenguin.com/play`.
#
# WEB_LEGACY_MEDIA
# ----------------
# The URL at which clients can access your 
# media server from. Ideally this is accessed 
# via a subdomain like `media.clubpenguin.com` 
# but it can also be on your root domain with 
# a path like `http://clubpenguin.com/media`.
#
# WEB_VANILLA_PLAY
# ----------------
# The URL at which clients can access your 
# vanilla play page from.
#
# WEB_VANILLA_MEDIA
# -----------------
# The URL at which clients can access your
# vanilla media server from.
#
# WEB_RECAPTCHA_SITE
# ------------------
# Google reCAPTCHA v3 site key.
#
# Leave blank to disable reCAPTCHA.
#
# WEB_RECAPTCHA_SECRET
# --------------------
# Google reCAPTCHA v3 secret key.
##############################################

WEB_PORT=80
WEB_HOSTNAME=$hostname

WEB_LEGACY_PLAY=http://old.$hostname
WEB_LEGACY_MEDIA=http://legacy.$hostname

WEB_VANILLA_PLAY=http://play.$hostname
WEB_VANILLA_MEDIA=http://media.$hostname

WEB_RECAPTCHA_SITE=
WEB_RECAPTCHA_SECRET=

##############################################
# Email
##############################################
#
# EMAIL_METHOD
# ------------
# This is the method that will be used for
# email. It accepts the following options:
# - SENDGRID
# - SMTP
#
# Leave blank to disable activation and have
# players be activated immediately upon 
# registration.
#
# EMAIL_FROM_ADDRESS
# ---------------
# The mailbox you're sending the email from.
# This is typically the same as
# EMAIL_SMTP_PASS but may be another mailbox
# that user has access to.
#
# EMAIL_SENDGRID_KEY
# ---------------
# Sendgrid API key used for player activation.
#
# EMAIL_SMTP_HOST
# ---------------
# Email SMTP server hostname or address.
#
# EMAIL_SMTP_PORT
# ---------------
# Email SMTP server port.
#
# EMAIL_SMTP_USER
# ---------------
# Email SMTP server login username.
#
# EMAIL_SMTP_PASS
# ---------------
# Email SMTP server login password.
#
# EMAIL_SMTP_SSL
# ---------------
# Set to TRUE if your SMTP server uses SSL.
##############################################

EMAIL_METHOD=
EMAIL_FROM_ADDRESS=no-reply@$hostname

EMAIL_SENDGRID_KEY=

EMAIL_SMTP_HOST=
EMAIL_SMTP_PORT=0
EMAIL_SMTP_USER=
EMAIL_SMTP_PASS=
EMAIL_SMTP_SSL=TRUE


##############################################
# Game
##############################################
#
# GAME_ADDRESS
# ------------
# This is where clients can connect to your
# game server. If this is a localhost setup,
# it can stay default. Otherwise, it should be
# the external IP of the host machine this 
# instance is running on.
#
# GAME_LOGIN_PORT
# ---------------
# The login server port. Usually fine to leave
# this.
##############################################

GAME_ADDRESS=$ipadd
GAME_LOGIN_PORT=6112

##############################################
# Snowflake (Card-Jitsu Snow)
##############################################
#
# SNOWFLAKE_HOST
# --------------
# This is similar to the GAME_ADDRESS but for
# the Card-Jitsu Snow game server.
#
# SNOWFLAKE_PORT
# --------------
# The port where the Card-Jitsu Snow server
# is running. Usually fine to leave this as
# default.
#
# MEDIA_LOCATION
# -----------------
# The URL at which clients can access your
# Card-Jitsu Snow media server from. Should
# be the same as WEB_VANILLA_MEDIA.
#
# APPLY_WINDOWMANAGER_OFFSET
# --------------------------
# If you have issues with the game being in a
# weird position, try setting this to True.
#
# ENABLE_BETA
# --------------------------
# If you want to enable the beta features, set
# this to True.
#
# ALLOW_FORCESTART_SNOW
# ---------------------
# Allows players to force-start a regular
# match.
#
# ALLOW_FORCESTART_TUSK
# ---------------------
# Allows players to force-start a tusk
# battle.
#
# MATCHMAKING_TIMEOUT
# -------------------
# The amount of time in seconds for a
# force-start to happen.
#
# ENABLE_NINJA_AI
# -------------------
# If there aren't enough players in
# the queue when MATCHMAKING_TIMEOUT is
# reached, the remaining places will be
# filled with bots.
#
##############################################

SNOWFLAKE_HOST=$ipadd
SNOWFLAKE_PORT=7002

MEDIA_LOCATION=http://media.$hostname

APPLY_WINDOWMANAGER_OFFSET=False

ENABLE_BETA=False

ALLOW_FORCESTART_SNOW=False
ALLOW_FORCESTART_TUSK=True

MATCHMAKING_TIMEOUT=30

ENABLE_NINJA_AI=False" > .env

echo "Done!"


if [ "$run_game" == "y" ] || [ "$run_game" == "Y" ]; then
    sudo docker-compose up
else
    echo "You chose not to run the game. To run the game later, execute the command: cd wand && sudo docker-compose up"
fi
