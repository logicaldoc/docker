# LogicalDOC
Official Docker image for LogicalDOC.
Nore: This image requires to be connected to an external database

## What is LogicalDOC ?
The LogicalDOC is a flexible and highly performant Document Management System platform

![LogicalDOC](https://www.logicaldoc.com/images/assets/LogicalDocWhiteH02-167.png)

* **Website**: https://www.logicaldoc.com
* **Manuals**: https://docs.logicaldoc.com
* **Twitter**: https://twitter.com/logicaldoc
* **Blog**: https://blog.logicaldoc.com

## Your UserNo
You have to pass your activation code(the UserNo) when you launch this image.
If you need an activation code, you can get one delivered to your email by filling-out the form at https://www.logicaldoc.com/try

## Start a LogicalDOC instance linked to a MySQL container**
1. Run the MySQL container
```Shell
docker run -d --name=mysql-ld --env="MYSQL_ROOT_PASSWORD=mypassword" --env="MYSQL_DATABASE=logicaldoc" --env="MYSQL_USER=ldoc" --env="MYSQL_PASSWORD=changeme" mysql:5.7
```

2. Run the LogicalDOC container
```Shell
docker run -d -p 8080:8080 --env LDOC_USERNO=<your userno>  --link mysql-ld logicaldoc/logicaldoc
```

This image includes EXPOSE 8080 (the logicaldoc port). The default LogicalDOC configuration is applied.

Then, access it via `http://localhost:8080` or `http://host-ip:8080` in a browser. Default User and Password are **admin** / **admin**.

## Start a LogicalDOC with some settings
```Shell
docker run -d -p 8080:8080 --env LDOC_USERNO=<your userno> --env LDOC_MEMORY=4000 --link mysql-ld logicaldoc/logicaldoc
```
This will run the same image as above but with 4000 MB memory allocated to LogicalDOC.

Then, access it via `http://localhost:8080` or `http://host-ip:8080` in a browser.

If you'd like to use an external database instead of a linked `mysql-ld` container, specify the hostname with `DB_HOST` and port with `DB_PORT` along with the password in `DB_PASSWORD` and the username in `DB_USER` (if it is something other than `ldoc`):

```console
$ docker run -d -p 8080:8080 -e DB_HOST=10.1.2.3 -e DB_PORT=3306 -e DB_USER=... -e DB_PASSWORD=... logicaldoc/logicaldoc
```

## Environment Variables
The LogicalDOC image uses environment variables that allow to obtain a more specific setup.

* **LDOC_USERNO**: your own license activation code ([`click here to get a fee trial code`](https://www.logicaldoc.com/try)) 
* **LDOC_MEMORY**: memory allocated for LogicalDOC expressed in MB (default is 2000)
* **DB_ENGINE**: the database type, possible vaues are: mysql(default), postgres
* **DB_HOST**: the database server host (default is 'mysql-ld')
* **DB_PORT**: the database communication port (default is 3306)
* **DB_NAME**: the database name (default is 'logicaldoc')
* **DB_INSTANCE**: some databases require the instance specification
* **DB_USER**: the username (default is 'ldoc')
* **DB_PASSWORD**: the password (default is 'changeme')

## Docker-Compose
Some docker-compose examples are available in the repository of this container on GitHub https://github.com/logicaldoc/docker

## ... via [`docker stack deploy`](https://docs.docker.com/engine/reference/commandline/stack_deploy/) or [`docker-compose`](https://github.com/docker/compose)

Example `stack.yml` for `logicaldoc`:

```yaml
version: "3.1"

services:

  logicaldoc:
    depends_on:
      - mysql-ld
    command: ["./wait-for-it.sh", "mysql-ld:3306", "-t", "30", "--", "/LogicalDOC/logicaldoc.sh", "run"]
    image: logicaldoc/logicaldoc
    ports:
      - 8080:8080
    environment:
      - LDOC_MEMORY=2000

  mysql-ld: 
    image: mysql:5.7
    environment:
      - MYSQL_ROOT_PASSWORD=example
      - MYSQL_DATABASE=logicaldoc
      - MYSQL_USER=ldoc
      - MYSQL_PASSWORD=changeme
      
```

[![Try in PWD](https://github.com/play-with-docker/stacks/raw/cff22438cb4195ace27f9b15784bbb497047afa7/assets/images/button.png)](http://play-with-docker.com?stack=https://raw.githubusercontent.com/logicaldoc/docker/master/stack.yml)

Run `docker stack deploy -c stack.yml logicaldoc` , wait for it to initialize completely, and visit `http://swarm-ip:8080`, `http://localhost:8080`, or `http://host-ip:8080` (as appropriate).
