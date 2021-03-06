# How to ...

## Run a node

**Prepare**  
```
git clone https://github.com/lab10-coop/sigma1
cd sigma1
./download-openethereum.sh
```

**Run**    
`./openethereum -c node.toml`

## Run a trustnode

**Create a user**  
This step is optional.  
For the smoothest setup journey (least changes necessary), create a user named "artis".  
Execute as root:
```
adduser --disabled-password artis
su artis
cd
```
Now you are in directory `/home/artis` as user `artis`.  
In case you prefer to have an account which allows login with password, omit `--disabled-password` and make sure you're using a strong password!
  
**Prepare**
```
git clone https://github.com/lab10-coop/sigma1
cd sigma1
./download-openethereum.sh
```

**Create an account**  
```
./openethereum -c node.toml account new
```
This will ask you for a password. Hint: use [pwgen](https://linux.die.net/man/1/pwgen)  
After entering the password twice, there will be a new file (a JSON formatted _keystore_ file) in `data/keys/sigma1.artis/`. You should make a backup of that file!

Now, create a file `password.txt` and paste the password into it.

(If you prefer another method for creating the mining key, feel free to do so.)

**Adapt the config**  
* Copy `trustnode.toml.example` to `trustnode.toml`.
* Open `trustnode.toml` with your favourite editor and set the missing values for _identity_, _unlock_ and _engine_signer_ (see inline comments and examples)

**Initial run**  
`./openethereum -c trustnode.toml`  
On first run, OpenEthereum creates a _node key_ which is stored in `data/network/key`. This key, the IP address and P2P port are combined to an _enode_ (more details [here](https://github.com/ethereum/wiki/wiki/enode-url-format)) which uniquely identifies your node. Your node's enode is printed to the console after a few seconds.  
Example: `enode://1e795a8ecedf7e2509a3ecc86ef5fa08a35828abeb5edf02a8dd8139250bd5ec286d34e367461b64e01bced15fed4ca273e03b4cd1326c353bb99b47fb3a3b39@94.130.160.209:30303`
Make sure the contained IP address is Internet routable (if your host system has multiple network interfaces / IPs, OpenEthereum may not choose the correct one) and that the selected port (default: 30303) is accessible from the outside (not blocked by a firewall).  
Please copy the enode and communicate it in the trustnode operator chat channel.  

If OpenEthereum started syncing the chain, you can stop it with Ctrl-C and proceed with the next step.

Warning: When starting a trustnode which isn't yet allowed to create blocks, you may see entries like this in the openethereum log:
```
Dec 11 12:32:05 your.hostname parity[7400]: 2018-12-11 12:32:05 UTC Closing the block failed with error Error(Engine(FailedSystemCall("Cannot decode address[]")), State { next_error: None, backtrace: InternalBacktrace { backtrace: None } }). This is likely an error in chain specificiations or on-chain consensus smart contracts.
```
Don't worry, this is without consequences and usually goes away once your trustnode starts producing blocks (which is the case once your _mining key_ was added to the [validator set](https://wiki.parity.io/Validator-Set.html)).

**Keep running**  
A trustnode is supposed to be always on, thus running it in an interactive shell isn't the best option.  
This repository includes a systemd template config you can use to make openethereum a system service.  
The following steps require root privileges (sudo):  
* Copy `artis-sigma1-openethereum.service.example` to `/etc/systemd/system/artis-sigma1-openethereum.service` (if that directory doesn't exist, you're likely not using systemd and can't use this method).
* Open the copied file and set _User_, _Group_, _WorkingDirectory_ and _ExecStart_ to values matching your setup
* Start the service: `systemctl start artis-sigma1-openethereum`
* Enable start-on-boot: `systemctl enable artis-sigma1-openethereum`

Finally, make sure the service is running: `systemctl status artis-sigma1-openethereum`.  
In order to see a live log, do `journalctl -f -u artis-sigma1-openethereum` (Ctrl-C will get you back).

## Get listed in status dashboard

There's a nice network status dashboard at https://status.sigma1.artis.network/  
It only lists nodes which want to be listed.  
In order to be on the list, a dedicated status reporting application needs to run alongside parity.  

If you run a public node which is always on (be it a trustnode or not), please get it listed.  
In case you decide to get listed, please ask for the _secret key_ needed to connect to the service (since the dashboard service shows whatever data it gets from connected nodes, this kind of permissioning helps to protect it against anonymous trolls feeding it with manipulated data).

**Prepare**  
Check which version of nodejs you have installed (if any):
`node --version`  
Anything newer than v6 should do.

If you don't have it installed, your options depend on the operating system.

_Ubuntu 18.04_:  
`apt install nodejs npm`

_Ubuntu 16.04_:  
```
curl -sL https://deb.nodesource.com/setup_10.x -o nodesource_setup.sh
bash nodesource_setup.sh
apt install nodejs
```
(Of course you can take a look into `nodesource_setup.sh` before executing it with root permissions.)

**Install**  
Next, get the application.  
```
cd
git clone https://github.com/lab10-coop/node-status-reporter
cd node-status-reporter
npm install
```

**Test run**  
Now you _could_ run it with  
`NODE_ENV=production INSTANCE_NAME=<your instance name here> WS_SERVER=https://status.sigma1.artis.network WS_SECRET=<SECRET-KEY> npm start`  

**Keep running**

If you installed a service for openethereum, you should do the same for this application. With root privileges, do:
* Copy `artis-sigma1-statusreporter.service.example` to `/etc/systemd/system/artis-sigma1-statusreporter.service`.
* Open the copied file and adapt it to your needs. Important: set values for _INSTANCE_NAME_ and _CONTACT_DETAILS_ and then uncomment both. Please use `<nick>.sigma1.artis.network` as value for _INSTANCE_NAME_ - replace `<nick>` with a nickname of your choice (using ASCII characters and digits only). Example: randomguy.sigma1.artis.network
* Start the service: `systemctl start artis-sigma1-statusreporter`
* Flag service to be started on boot: `systemctl enable artis-sigma1-statusreporter`

You can check the status of the service with `systemctl status artis-sigma1-statusreporter`.

## Run a bridge validator

**Create a user**  
This step is optional.  
For the smoothest setup journey (least changes necessary), create a user named "bridge".  
Execute as root:
```
adduser --disabled-password bridge
su bridge
cd
```

**Create a private key**  
Next, you need a private key for the bridge validator account.  
You may use any tool you want (e.g. dices). One option is to get (build or download) Parity's `ethkey` binary ([Linux binary](https://releases.parity.io/ethereum/v2.2.10/x86_64-unknown-linux-gnu/ethkey)) and run `./ethkey generate random` - this will print a random public key and its address.  
Next, send at least 10 ATS to this address - needed for creating the signing transactions.  
Finally, communicate this address to the bridge admin in order to get your validator whitelisted in the bridge contracts.

**Setup**  
```
git clone https://github.com/lab10-coop/artis-bridge-oracle
cd artis-bridge-oracle
```

Now, create a file `.env`, copy the contents of [bridge-oracle-config.env.example](bridge-oracle-config.env.example) into it and add the private key as value for `VALIDATOR_ADDRESS_PRIVATE_KEY`.

Then, as root execute `./install-bridge.sh bridge` (`bridge` being the system user running the bridge processes. Change accordingly if needed!).  
This will install and start required dependencies (RabbitMQ, Redis, Node.js) and set up systemd unit files for the bridge.  
The first (and only) argument denotes the bridge user. Change accordingly if it's not _bridge_.  
Note that this script was made for and tested with Ubuntu 16.04 and 18.04. If using another OS, you need to do the setup manually - you can consult the shell script for the needed steps.

**Start / Watch / Stop**  
Run `./start-bridge.sh` in order to start all bridge related systemd services.  
With `./check-bridge.sh` you can check the status of the bridge.  
With `./monitor-bridge.sh` you can watch the log of the bridge services in realtime.  
With `./stop-bridge.sh` you can stop the bridge related systemd services.

Note that the start and stop script support an optional argument `--persist` which _enables_/_disables_ the services (for setting or removing the autostart flag for the service).

## use with Metamask

[Metamask](https://metamask.io/) is a browser extension which implements an Ethereum wallet. It can be used with any Ethereum compatible network.  
Once you have Metamask installed:
* Open and unlock Metamask
* Click the _Networks_ dropdown and choose _Custom RPC_
* For _Network Name_, enter "ARTIS Sigma1"
* For _RPC URL_, enter "https://rpc.sigma1.artis.network"
* For _Chain ID_, enter "0x3c301"
* For _symbol_, enter "ATS"
* For _Block Explorer URL", enter "https://explorer.sigma1.artis.network"
* Click _Save_

Note that Metamask is still beta software and sometimes behaves in weird ways.  
For use with ARTIS Sigma1, we recommend to set up a fresh instance of Metamask which is used for this chain only.

# About

Σ1 is an ARTIS mainnet.  
It makes use of several open source contributions of the fantastic Ethereum community, most importantly those of [poa.network](https://github.com/poanetwork/) and [OpenEthereum](https://github.com/openethereum/) (former _Parity_).

Instructions for building OpenEthereum from source can be found [here](https://github.com/openethereum/openethereum#chapter-003).  
Newer versions of OpenEthereum are expected to be compatible (able to sync with this chain). Older versions may be incompatible.
