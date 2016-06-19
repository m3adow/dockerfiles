Seafile Docker container based on Ubuntu

### Features

* Tailored to use the newest seafile version at rebuild (so it should always be up-to-date)
* Running under dumb-init to prevent the "child reaping problem"
* Configurable to run with MySQL/MariaDB or SQLite
* Auto-setup at initial run

### Quickstart

If you want to run with sqlite:
```bash
docker run -d -e SEAFILE_NAME=Seaflail \
	-e SEAFILE_ADDRESS=seafile.adminswerk.de \
	-e SEAFILE_ADMIN=seafile@adminswerk.de \
	-e SEAFILE_ADMIN_PW=LoremIpsum \
	-v /home/data/seafile:/seafile \
  m3adow/seafile
```
If you want to use MySQL:
```bash
docker run -d -e SEAFILE_NAME=Seaflail \
	-e SEAFILE_ADDRESS=seafile.adminswerk.de \
	-e SEAFILE_ADMIN=seafile@adminswerk.de \
	-e SEAFILE_ADMIN_PW=LoremIpsum \
  -e MYSQL_SERVER=172.17.0.2 \
  -e MYSQL_USER=seafile \
  -e MYSQL_USER_PASSWORD=Seafail \
  -e MYSQL_ROOT_PASSWORD=hunter2 \
	-v /home/data/seafile:/seafile \
  m3adow/seafile
```

### Overview

Filetree:

/seafile/
|-- ccnet
|-- conf
|-- seafile-data
`-- seahub-data
/opt/
`-- haiwen
    |-- ccnet -> /seafile/ccnet
    |-- conf -> /seafile/conf
    |-- logs
    |-- pids
    |-- seafile-data -> /seafile/seafile-data
    |-- seafile-server-5.1.3
    |-- seafile-server-latest -> seafile-server-5.1.3
    `-- seahub-data -> /seafile/seahub-data

All important data is stored under /seafile, so you should be mounting a volume there (recommended) or at the respective subdirectories. This will not happen automatically!
There are a plethora of environment variables which might be needed for your setup. I recommend using Dockers `--env-file` option.

**Mandatory ENV variables for auto setup**

* **SEAFILE_NAME**: Name of your Seafile installation
* **SEAFILE_ADDRESS**: URL to your Seafile installation
* **SEAFILE_ADMIN**: E-mail address of the Seafile admin
* **SEAFILE_ADMIN_PW**: Password of the Seafile admin

If you want to use MySQL/MariaDB, the following variables are needed:

**Mandatory ENV variables for MySQL/MariaDB**

* **MYSQL_SERVER**: Address of your MySQL server
* **MYSQL_USER**: MySQL user Seafile should use
* **MYSQL_USER_PASSWORD**: Password for said MySQL User
*Optionali:*
* **MYSQL_PORT**: Port MySQL runs on

**Optional ENV variables for auto setup with MySQL/MariaDB**
* **MYSQL_USER_HOST**: Host the MySQL User is allowed from (default: '%')
* **MYSQL_ROOT_PASSWORD**: If you haven't set up the MySQL tables by yourself, Seafile will do it for you when being provided with the MySQL root password

If you plan on omitting /seafile as a volume and mount the subdirectories instead, you'll need to additionally specify `SEAHUB_DB_DIR` which containes the subdirectory of /seafile the *seahub.db* file shall be put in.

There are some more variables which could be changed but have not been tested and are probably not fully functional as well. Therefore those not mentioned here. Inspect the `seafile-entrypoint.sh` script if you have additional needs for customization.

### Web server
This container does not include a web server. It's intended to be run behind a reverse proxy. You can read more about that in the Seafile manual: http://manual.seafile.com/deploy/
