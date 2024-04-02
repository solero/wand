# wand

Wand makes it easy to configure dash, houdini and a media server.

## Basic setup

**Step 1** Install git, docker & docker-compose

```bash
$ sudo apt update
$ sudo apt install docker.io git curl
$ sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
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

**Step 5** 
Grab the required browser/tools

- **Web Browser (Client)**
***Required since Mid Jan 2021***
https://www.slimjet.com/en/dlpage.php <- This has flash built-in

- **DB Browser**
pgAdmin
https://www.pgadmin.org/download/

- **.swf Decomplier/Editor**
JPEXS Free Flash Decompiler
https://github.com/jindrapetrik/jpexs-decompiler/releases
