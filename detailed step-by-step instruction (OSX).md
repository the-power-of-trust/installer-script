## The Power of Trust — detailed step-by-step instruction
Try this if [the fast auto-installer script](README.md) doesn't work for you.

> ## ! This file is not up to date

On **Mac OS X** as `root` do:

1. Create isolated user 'potrust' to do not touch anything in the system and to limit process permissions  
	```
	name=potrust
	dscl . create /Users/$name
	dscl . create /Users/$name UserShell /bin/bash
	dscl . create /Users/$name RealName "$name"
	maxid=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
	newid=$((maxid+1))
	dscl . create /Users/$name UniqueID $newid
	dscl . create /Users/$name PrimaryGroupID 20
	dscl . create /Users/$name NFSHomeDirectory /Users/$name
	dscl . passwd /Users/$name $name
	dscl . create /Users/$name IsHidden 1
	
	mkdir /Users/$name
	chown -R $name /Users/$name
	
	cd /Users/$name
	```

1. Install Homebrew if needed  
	<http://brew.sh> — get installation command there  
	`brew update`  
	>`brew doctor` — should show no problems

1. Install some required packages
	```
	brew install p7zip
	```

1. Install RVM for user potrust (but still as root)
	```
	sudo -H -u potrust bash -c 'curl -sSL https://get.rvm.io | bash -s stable'
	alias rvm=.rvm/bin/rvm
	```
	>`rvm -v` — should show RVM version  

1. Install Ruby (still as root)  
	```
	file_name=ruby-2.0.0-p643
	rvm install $file_name --binary
	``` 
	``` 
	chown -R potrust .rvm
	su potrust
	source .rvm/scripts/rvm
	rvm use $file_name --default
	```
	
	>`rvm list` — should show installed Ruby  
	`ruby -v` — should be similar to `ruby 2.0.0p598 ...`  

1. Create base folder structure
	```
	mkdir the-power-of-trust
	cd the-power-of-trust
	curl -O inve.org/files/PoT/pack.tgz
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
	curl http://downloads.mongodb.org/osx/mongodb-osx-x86_64-2.2.7.tgz -o mongodb.tgz
	mkdir platform
	mkdir platform/mongodb
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
	>some commands work only if you are logged in as `potrust` from the login screen, not with `su`
	
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
