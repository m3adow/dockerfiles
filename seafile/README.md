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
	-v /home/data/seafile:/seafile

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

All important data is stored under /seafile, so you should be mounting a volume there or at the respective subdirectories (this will not happen automatically!).  
If you already got a working configuration, you're good to go. If not, there are some environment variables you need to configure for the Auto-setup.

**Mandatory ENV variables**

* **SEAFILE_NAME**: Name of your Seafile installation
* **SEAFILE_ADDRESS**: URL to your Seafile installation
* **SEAFILE_ADMIN**: E-mail address of the Seafile admin
* **SEAFILE_ADMIN_PW**: Password of the Seafile admin

**Mandatory ENV variables for MySQL/MariaDB**

* **MYSQL_SERVER**: Address of your MySQL server
* **MYSQL_USER**: MySQL user Seafile should use
* **MYSQL_USER_PASSWORD**: Password for said MySQL User

**Optional ENV variables**
* **MYSQL_USER_HOST**: Host the MySQL User is allowed from (default: '%')
* **MYSQL_ROOT_PASSWORD**: If you haven't set up the MySQL tables by yourself, Seafile will do it for you when being provided with the MySQL root password
* **MYSQL_PORT**: Port MySQL runs on

There are some more variables which could be changed but have not been tested and are therefore not mentioned here. Inspect the `seafile-entrypoint.sh` script if you have additional needs for customization.
