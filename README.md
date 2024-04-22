# wand

Wand makes it easy to configure dash, houdini and a media server.

## Install script
**Step 1** run the script
```bash
$ bash <(https://raw.githubusercontent.com/solero/wand/master/install.sh)
```
**Step 2** Answer Questions
the questions are:
* Database password (Leave blank for random password)
* Hostname (example: `clubpenguin.com`) (Leave empty for localhost)
* External IP Address (Leave empty for localhost)
**Step 3** Run and enjoy.
Run this command:
```bash
$ cd wand && sudo docker-compose up
```
## Basic setup

**Step 1** Install git, docker & docker-compose

```bash
$ sudo apt update
$ sudo apt install docker.io git curl
$ sudo curl -L "https://github.com/docker/compose/releases/download/v2.20.3/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
$ sudo chmod +x /usr/local/bin/docker-compose
```

**Step 2** Clone the repository & submodules
```bash
$ git clone --recurse-submodules https://github.com/solero/wand && cd wand
```

**Step 3** Edit the config file
```bash
$ nano .env
```

**Step 4** Start the services
```bash
$ sudo docker-compose up
```

**Step 5** You're done!
