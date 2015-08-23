#!/usr/bin/env bash
#
# As root do:
# recommended for Supernode:
# bash pot_install.sh
# recommended for occasional use:
# bash pot_install.sh -no_cron_tasks
#
# all the optional params:
# bash pot_install.sh -dev -no_adduser -no_folders -no_rvm -no_ruby -no_gems -no_mongo -no_cron_tasks -no_start_now
#
# contribute here — https://github.com/the-power-of-trust/installer-script
# feedback — yura.des@gmail.com

W='\e[1;37m'
G='\e[1;32m'
Y='\e[1;33m'
NC='\e[0m'
# echo -e $NC;exit

# needed to detect param by trailing space
params="[$@ ]"

if [[ "$OSTYPE" == "darwin"* ]]; then
	f_osx=true
fi

if [[ $params == *'-dev '* ]]; then
	echo -e "\e[0;36mDEV mode"
	user=pot_test
	if [ $f_osx ]; then
		dscl . -delete /Users/$user
		rm -rf /Users/$user
	else
		userdel $user
	fi
else
	user=pot
fi
user_homedir=/home/$user

if [ `whoami` != "root" ]; then
	echo
	echo -e "$W    Installer should be launched from the root user$NC"
	echo
	exit
fi
if [[ $f_osx && ! -x `which brew` ]]; then
	echo
	echo -e "$W    Installe Homebrew first - visit http://brew.sh$NC"
	echo
	exit
fi


echo -e "${Y}The Power of Trust installer"
echo
printf "${W}Creating isolated user \'$user\' to do not touch anything in the system and to limit process permissions$NC..."
	if [[ $params != *'-no_adduser '* ]]; then
		if [ $f_osx ]; then
			dscl . create /Users/$user
			dscl . create /Users/$user UserShell /bin/bash
			dscl . create /Users/$user RealName "$user"
			maxid=$(dscl . -list /Users UniqueID | awk '{print $2}' | sort -ug | tail -1)
			newid=$((maxid+1))
			dscl . create /Users/$user UniqueID $newid
			dscl . create /Users/$user PrimaryGroupID 20
			dscl . create /Users/$user NFSHomeDirectory /Users/$user
			dscl . passwd /Users/$user $user
			dscl . create /Users/$user IsHidden 1

			user_homedir=/Users/$user
			mkdir $user_homedir
			chown -R $user $user_homedir
		else
			adduser $user --disabled-password --gecos PoT --quiet
		fi
		echo -e ${G}done
		echo
	else
		echo skipped
	fi

printf "${W}Creating folder structure for $user"
	if [[ $params != *'-no_folders '* ]]; then
		echo -e " -------$NC"
		sudo -H -u $user bash -c "
			cd ~
			if [ $f_osx ]; then
				curl -O inve.org/files/PoT/pack.tgz
			else
				wget inve.org/files/PoT/pack.tgz
			fi
			tar -zxf pack.tgz --strip-components=1
			rm pack.tgz
		"
		echo -e ${W}------- ${G}done
		echo
	else
		echo -e $NC...skipped
	fi

if [ ! $f_osx ]; then
	f_installed=`dpkg -l | grep 'ii *curl'`
	if [ ! "$f_installed" ]; then
		echo -e ${W}Installing curl -------$NC
		apt-get install curl -y
		echo -e ${W}------- ${G}done
		echo
	fi

	f_installed=`dpkg -l | grep 'ii *screen'`
	if [ ! "$f_installed" ]; then
		echo -e ${W}Installing screen -------$NC
		apt-get install screen -y
		echo -e ${W}------- ${G}done
		echo
	fi
fi

if [ $f_osx ]; then
	if [ ! -x /usr/local/bin/7z2 ]; then
		echo -e ${W}Installing p7zip -------$NC
		brew install p7zip
		echo -e ${W}------- ${G}done
		echo
	fi
else
	f_installed=`dpkg -l | grep 'ii *p7zip-full'`
	if [ ! "$f_installed" ]; then
		echo -e ${W}Installing p7zip-full -------$NC
		apt-get install p7zip-full -y
		echo -e ${W}------- ${G}done
		echo
	fi
fi

printf "${W}Installing RVM for $user"
	if [[ $params != *'-no_rvm '* ]]; then
		echo -e " -------$NC"
		sudo -H -u $user bash -c 'curl -sSL https://get.rvm.io | bash -s stable'
		ver=`sudo -H -u $user bash -c ". ~/.rvm/scripts/rvm;rvm -v | cut -d' ' -f-3"`
		echo -e ${W}------- ${G}installed: $ver
		echo
	else
		echo -e $NC...skipped
	fi

printf "${W}Installing Ruby v2.0.x for $user"
	if [[ $params != *'-no_ruby '* ]]; then
		echo -e " -------$NC"
		cd $user_homedir
		bash -c ". .rvm/scripts/rvm;rvm list remote"
		file_name=`bash -c ". .rvm/scripts/rvm;rvm list remote" | grep -o ruby-2\.0\..* | tail -1`
		echo -e Using binaries for ${W}$file_name$NC
		bash -c ". .rvm/scripts/rvm;rvm install $file_name --binary"
		chown -R $user .rvm
		sudo -H -u $user bash -c ". ~/.rvm/scripts/rvm; rvm use $file_name --default"
		ver=`sudo -H -u $user bash -c ". ~/.rvm/scripts/rvm; ruby -v"`
		echo -e ${W}------- ${G}installed: $ver
		echo
	else
		echo -e $NC...skipped
	fi

printf "${W}Installing 25+ gems for $user"
	if [[ $params != *'-no_gems '* ]]; then
		echo -e " -------$NC"
		sudo -H -u $user bash -c '
			cd ~
			. .rvm/scripts/rvm
			gem install bundler --no-ri --no-rdoc
			bundle
		'
		echo -e ${W}------- ${G}done
		echo
	else
		echo -e $NC...skipped
	fi

printf "${W}Installing MondoDB v2.2.7 for $user"
	if [[ $params != *'-no_mongo '* ]]; then
		echo -e " -------$NC"
		sudo -H -u $user bash -c "
			cd ~
			if [ $f_osx ]; then
				curl http://downloads.mongodb.org/osx/mongodb-osx-x86_64-2.2.7.tgz -o mongodb.tgz
			else
				wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.2.7.tgz -O mongodb.tgz
			fi
			tar -zxf mongodb.tgz -C platform/mongodb --strip-components=1
			rm mongodb.tgz
		"
		ver=`sudo -H -u $user bash -c "~/platform/mongodb/bin/mongod --version | grep 'db ver' | cut -d, -f-1"`
		echo -e ${W}------- ${G}installed: $ver
		echo
	else
		echo -e $NC...skipped
	fi

printf "${W}Adding crontab @reboot tasks for $user$NC..."
	if [[ $params != *'-no_cron_tasks '* ]]; then
		sudo -H -u $user bash -c "
			cd ~
			echo '@reboot sleep 5;./start.sh' >> tempcron
			crontab tempcron
			rm tempcron
		"
		echo -e ${G}done
		echo
	else
		echo skipped
	fi

printf "${W}Starting now$NC..."
	common_first_line="\n${Y}Now at anytime under the user '$user' you can do:$NC\n"
	if [ $f_osx ]; then
		common_first_line+="*script /dev/null — resolves annoying problem with the terminal
*some commands work only if you are logged in as $user from the login screen, not with su\n"
	else
		common_first_line+="*switch from root with: su $user -c'script /dev/null'\n"
	fi
	if [[ $params != *'-no_start_now '* ]]; then
		sudo -H -u $user bash -c "
			cd ~
			./start.sh
		"
		sleep 1
		echo
		echo -e "$common_first_line"
		echo -e "$W  ~/start.sh$NC  — start node (now already started)"
	else
		echo skipped
		echo
		echo -e "$common_first_line"
		echo -e "$W  ~/start.sh$NC  — start node"
	fi

echo -e "$W\
$W  screen -r$NC   — check windows
$W  screen -dm$NC  — start node-screen if it was terminated

  Inside screen hotkeys:
$W    ^a,space/backspace$NC  — navigate windows (Node, Web-client, top)
$W    ^a,w$NC                — list windows
$W    ^a,[123]$NC            — switch to wnd by N
$W    ^a,Esc$NC              — enter the scrolling mode to read an output history
$W    r$NC                   — restart failed task
$W    ^a,d$NC                — detach (return to the main terminal)

  Finally:
$W    localhost:3070$NC   — check Web-Client UI in any local browser (WebKit-based or Firefox)
$W    app/conf_base.rb$NC — configure your node if needed

  For supernode:
  - If incoming connections are firewalled by default,
    you will need to add and exception for the node port 7733 (TCP).
  - You can also open external access to your Web-Client on port 3070
    (useful for supernode, but danger for personal node).
"

echo
echo -e $NC
