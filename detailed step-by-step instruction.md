## The Power of Trust — detailed step-by-step instruction
Try this if [the fast auto-installer script](README.md) doesn't work for you.


On **Ubuntu / Debian** as root do:

1. Create isolated user 'potrust' to do not touch anything in the system and to limit process permissions  
	```
	adduser potrust --disabled-password --gecos potrust --quiet
	cd /home/potrust
	```

1. Install some required packages
	```
	apt-get install curl p7zip-full screen -y
	```

1. Install RVM for user potrust (but still as root)
	```
	sudo -H -u potrust bash -c '
		gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
		\curl -sSL https://get.rvm.io | bash -s stable
	'
	```

1. Install Ruby (still as root)  
	```
	. .rvm/scripts/rvm
	rvm list remote
	``` 
	pick the latest ruby-2.0.x name and use in  
	`rvm install {name} --binary` — should be like `rvm install ruby-2.0.0-p598 --binary`  
	if there are no ruby-2.0.0 binaries — compile from sources  
	`rvm install 2.0.0` (it can take 5 mins)
	```
	chown -R potrust .rvm
	su potrust
	source .rvm/scripts/rvm
	```
	
	>`rvm -v` — should show RVM version  
	`type rvm | head -n 1` — should show `rvm is a function`  
	`rvm list` — should show installed Ruby  
	`ruby -v` — should be similar to `ruby 2.0.0p598 ...`  

1. Create base folder structure
	```
	wget inve.org/files/PoT/pack.tgz
	tar -zxf pack.tgz --strip-components=1
	rm pack.tgz
	```

1. Install 30+ required gems  
	```
	gem install bundler --no-ri --no-rdoc
	bundle
	```

1. Install MondoDB
	```
	wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.2.7.tgz -O mongodb.tgz
	tar -zxf mongodb.tgz -C platform/mongodb --strip-components=1
	rm mongodb.tgz
	```
	>`platform/mongodb/bin/mongod --version` — should show `db version v2.2.7, pdfile version 4.5`

1. Auto-start on boot (needed for supernode)
	```
	echo '@reboot sleep 5;./start.sh' >> tempcron
	crontab tempcron
	rm tempcron
	```
	>`crontab -l` — should show the added tasks

1. Start  
	`./start.sh`  
	`script /dev/null` — resolves annoying problem with the terminal

1. Now at anytime under the user `potrust` you can do:  
	>*switch from root with: `su potrust -c'script /dev/null'`  

	`~/start.sh`  — start node (it it was stopped)  
	`screen -r`   — check windows  
	`screen -dm`  — start node-screen if it was terminated  

	Inside screen hotkeys:  
	`Ctrl+a, space/backspace`  — navigate windows (Node, Web-client, top)  
	`Ctrl+a, w`                — list windows  
	`Ctrl+a, [123]`            — switch to wnd by N  
	`Ctrl+a, Esc`              — enter the scrolling mode to read an output history  
	`r`                        — restart process (if terminated)  
	`Ctrl+c, r`                — restart working process  
	`Ctrl+a, d`                — detach (return to the main terminal)  
	`Ctrl+a, \`                — terminate this screen with all the processes

1. **Finally**  
	`localhost:3070`   — check Web-Client UI in any browser (WebKit-based or Firefox)  
	`app/conf_base.rb` — configure your node if needed  
	
1. For supernode  
	* If incoming connections are firewalled by default, you will need to add and exception for the node port `7733` (TCP).  
	* You can also open external access to your Web-Client on port `3070` (useful for supernode, but danger for personal node).


## Feedback
Yura Babak — yura.des@gmail.com