#!/bin/bash

log_file="wand/logs/installLog.txt"
firstrun_log="wand/logs/firstrun.txt"

# Function to log output to file
log() {
    echo "$(date +"%Y-%m-%d %T") $1" >> "$log_file"
}

# Function to log first run output to file
log_firstrun() {
    echo "$(date +"%Y-%m-%d %T") $1" >> "$firstrun_log"
}

# Clear screen and log
clear
log "Please answer these questions to set up the game:"

# Function to read password silently
read_password() {
    local password=""
    while IFS= read -r -s -n1 char; do
        if [[ -z $char ]]; then
            break
        elif [[ $char == $'\177' ]]; then # handle backspace
            if [ ${#password} -gt 0 ]; then
                password="${password%?}" # remove last character
                echo -ne '\b \b'          # erase last character on the screen
            fi
        else
            echo -n '*'
            password+="$char"
        fi
    done
    echo "$password"
}

# Read password and log
log "Enter password for the database (leave empty for a random password):"
dbpass=$(read_password)
log "Database password entered."

# Generate random password if needed
if [ -z "$dbpass" ]; then
    dbpass=$(openssl rand -base64 12)
    log "Generated random database password."
fi

# Read hostname and log
log "Enter the hostname for the game (example: example.com) (leave empty for localhost):"
read hostname
if [ -z "$hostname" ]; then
    hostname=localhost
fi
log "Hostname entered: $hostname"

# Read IP address and log
log "Enter your external IP address (leave empty for localhost):"
read ipadd
if [ -z "$ipadd" ]; then
    ipadd=127.0.0.1
fi
log "IP address entered: $ipadd"

# Read whether to run the game and log
read -p "Do you want to run the game when the installation ends? (y/N): " run_game
log "Choice to run the game: $run_game"

# Setting up environment
log "Setting up the environment."
sudo apt update >> "$log_file" 2>&1
sudo apt install docker.io git curl -y >> "$log_file" 2>&1
sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose >> "$log_file" 2>&1
sudo chmod +x /usr/local/bin/docker-compose >> "$log_file" 2>&1
log "Environment setup completed."

# Downloading game files
log "Downloading Game Files"
git clone --recurse-submodules https://github.com/solero/wand && cd wand >> "$log_file" 2>&1
log "Game files downloaded."

# Remove existing .env file if exists
sudo rm -r .env >> "$log_file" 2>&1

# Write environment variables to .env file
echo "# database
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
GAME_LOGIN_PORT=6112" > .env

log "Environment variables written to .env file."

# Final message
echo "Done!"
log "Setup completed."

# Run the game if chosen
if [ "$run_game" == "y" ] || [ "$run_game" == "Y" ]; then
    log_firstrun "Running the game..."
    sudo docker-compose up >> "$firstrun_log" 2>&1
else
    echo "You chose not to run the game. To run the game later, execute the command: cd wand && sudo docker-compose up"
    log "Game not started."
fi
