# YDBAdminOpsGUI

The YottaDB Administration GUI is a browser based application that is intended to manage and explore YottaDB. Currently, it consists of different web modules that fall into different categories.

 - **System  Management**
    1. Running Processes
    2. Global Directory Editor
 - **System Explorer**
    1. Routines Explorer
    2. Globals Explorer
    3. Octo SQL Tables explorer

## Manual Setup for Development
The GUI is compromised of two parts. 
 1. **The backend**: written in M
 2. **The fontend**: written in VueJs on top of the UI framework [Quasar](https://quasar.dev/)

### Development dependencies (Nodejs and npm are only used in development)
**Node.js** and **npm** (to compile javascript files)
```bash
sudo apt update
sudo apt install nodejs npm
```


#### Running the app in development mode
- Git clone the project in any working directory. 
```bash
git clone https://gitlab.com/YottaDB/UI/YDBAdminOpsGUI.git
```

- Change dirctory
```bash
cd YDBAdminOpsGUI
```

##### Server
- Point your ydb_routines environment  to the routines folder
```bash
export ydb_routines="$PWD/routines"
```
- Start the integrated web server. 
By default the web server listens on port 8089. This can be changed by passing the ```Start``` label a port number, and modifying the proxy section of ```quasar.conf.js``` file 
```bash
$ydb_dist/yottadb -run Start^%YDBWEB
```

##### Client
- Download the nodejs dev dependencies.
```bash 
npm install
```
- Run the front-end development server
```bash
quasar dev
# if the command fails, you might need to point to the executable directly
./node_modules/@quasar/app/bin/quasar dev

```
- Navigate to http://localhost:8080. If port 8080 is unavailable, ```quasar``` will use the closest available port.  Quasar will also report on the port being used whether it's 8080 or any other chosen available port 
