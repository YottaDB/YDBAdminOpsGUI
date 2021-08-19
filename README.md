# YDBAdminOpsGUI

The YottaDB Administration GUI is a browser based application that is intended to manage and explore YottaDB. Currently, it consists of different web modules that fall into different categories.

 - **System  Management**
    1. Running Processes
    2. Global Directory Editor
 - **System Explorer**
    1. Routines Explorer
    2. Globals Explorer
    3. Octo SQL Tables explorer

## Setup
The GUI is compromised of two parts. 
 1. **The backend**: written in M
 2. **The fontend**: written in VueJs

### Dependencies
1. **Node.js** and **npm** (to compile javascript files)
```bash
sudo apt update
sudo apt install nodejs npm
```
2. ***YottaDB***. 
```bash
mkdir /tmp/tmp 
wget -P /tmp/tmp https://gitlab.com/YottaDB/DB/YDB/raw/master/sr_unix/ydbinstall.sh
cd /tmp/tmp
chmod +x ydbinstall.sh
sudo ./ydbinstall.sh --utf8 default --octo --verbose
```

#### Running the application in production mode.
1. Git clone the project in any working directory. 
```bash
git clone https://gitlab.com/YottaDB/UI/YDBAdminOpsGUI.git
```
2. Change dirctory.
```bash
cd YDBAdminOpsGUI
```
3. Install the dependencies.
```bash
npm install
```
4. Build the application
 ```bash
 npm run build
 ```
5. Set the required environment variables
```bash
source $(pkg-config --variable=prefix yottadb)/ydb_env_set
```

6. Start the web server using default port (8089)
```bash
npm run start-server
# Or provide a specific port (7777 for example)
npm run start-server 7777
```

7. Point your browser to the running application ```http://localhost:8089```
##### Notes
- ***ydb_routines*** variable needs to be set correctly to point to the
  routines of the application. You can either move the routines manually to a
  location specified in ydb_routines, or you can modify ydb_routines before
  YottaDB process start up. Running ```npm run start-server``` sets this for
  you. 

```bash
export ydb_routines=`$ydb_dist/yottadb -run %XCMD 'W $P($P($ZRO,"(",1,2),")")_" "_"$PWD/routines"_")"_$P($ZRO,")",2,$L($ZRO,")"))'` 
```
- The instance of the web server has to be started from the project root folder, where the folder ./dist/spa/ contains the project's built files. 

#### Running the application in development mode
1. Git clone the project in any working directory. 
```bash
git clone https://gitlab.com/YottaDB/UI/YDBAdminOpsGUI.git
```

2. Change dirctory
```bash
cd YDBAdminOpsGUI
```
3. Download the nodejs dev dependencies.
```bash 
npm install
```
4. Run the front-end development server
```bash
npm run dev
```
5. Set the required environment variables
```bash
source $(pkg-config --variable=prefix yottadb)/ydb_env_set
```
6. Start the integrated M web server (YottaDB). 
```bash
npm run start-server
```
- By default the web server listens on port 8089. If you'd like to develop using a different port: 
  - 1) Pass a port to the start script ``` npm run start-server 7777```
  - 2) Modify the port in the proxy section of ```quasar.conf.js``` file

- Navigate to ```http://localhost:8080```. If port 8080 is unavailable, the closest available port will be selected.

#### Testing
 1. Testing the app requires the project files to be built first
 2. The testing framework assumes the server is running on port 8089. The port is specified in tests/bootstap.js
 3. The tests run by default in headless mode (no browser running in the foreground). The setting is also in tests/bootstap.js
 4. to run the tests:
 ```bash
 npm run start-server
 npm test
 ```

 #### Application Commands

|Command|Description|
|---|---|
|```npm run start-server```|Start the M Web Server (YottaDB)|
|```npm run start-server 7777```|Start the M Web Server (YottaDB) on port ```7777```|
|```npm run stop-server``` |Stop the M Web Server (YottaDB)|
|```npm run dev```|Run the application in development mode on port 8080 where the client files will be served from|
|```npm run build```|Build the application in ```dist``` folder|
|```npm test```|Run end-to-end tests|
|```npm run clean```|Clean all build artifacts|

