#!/bin/sh
#
# As root do:
# recommended for Supernode:
#./pot_install.sh
# recommended for occasional use:
#./pot_install.sh -no_cron_tasks
#
# all the optional params:
#./pot_install.sh -dev -no_adduser -no_folders -no_rvm -no_ruby -no_gems -no_mongo -no_cron_tasks -no_start_now
#
# contribute here — https://github.com/the-power-of-trust/installer-script
# feedback — yura.des@gmail.com

W='\033[1;37m'
G='\033[1;32m'
Y='\033[1;33m'
NC='\033[0m'
# echo $NC;exit

# needed to detect param by trailing space
params="[$@ ]"
# for tests:
#echo $params | grep -oe'-de '
# other way to detect params:
#echo ${params%-no_start *}
#if [ ! "$params" != "${params%-no_start *}" ]; then
#	echo "param not detected"
#fi 


if [ `echo $params | grep -oe'-dev '` ]; then
	echo "\033[0;36mDEV mode"
	user=pot_test
	userdel $user
else
	user=pot
fi

if [ `whoami` != "root" ]; then
	echo
	echo "$W    Installer should be launched from the root user$NC"
	echo
	exit
fi

echo "${Y}The Power of Trust installer"
echo
echo -n ${W}Creating isolated user \'$user\' to do not touch anything in the system and to limit process permissions$NC...
	if [ ! `echo $params | grep -oe'-no_adduser '` ]; then
		adduser $user --disabled-password --gecos PoT --quiet
		echo ${G}done
		echo
	else
		echo skipped
	fi

echo -n ${W}Creating folder structure for $user
	if [ ! `echo $params | grep -oe'-no_folders '` ]; then
		echo " -------$NC"
		sudo -H -u $user bash -c '
			cd ~
			wget inve.org/files/PoT/pack.tgz
			tar -zxf pack.tgz --strip-components=1
			rm pack.tgz
		'
		echo ${W}------- ${G}done
		echo
	else
		echo $NC...skipped
	fi

f_installed=`dpkg -l | grep 'ii *curl'`
if [ ! "$f_installed" ]; then
	echo ${W}Installing curl -------$NC
	apt-get install curl -y
	echo ${W}------- ${G}done
	echo
fi
f_installed=`dpkg -l | grep 'ii *p7zip-full'`
if [ ! "$f_installed" ]; then
	echo ${W}Installing p7zip-full -------$NC
	apt-get install p7zip-full -y
	echo ${W}------- ${G}done
	echo
fi
f_installed=`dpkg -l | grep 'ii *screen'`
if [ ! "$f_installed" ]; then
	echo ${W}Installing screen -------$NC
	apt-get install screen -y
	echo ${W}------- ${G}done
	echo
fi

echo -n ${W}Installing RVM for $user
	if [ ! `echo $params | grep -oe'-no_rvm '` ]; then
		echo " -------$NC"
		sudo -H -u $user bash -c '
			gpg --keyserver hkp://keys.gnupg.net --recv-keys 409B6B1796C275462A1703113804BB82D39DC0E3
			\curl -sSL https://get.rvm.io | bash -s stable
		'
		ver=`sudo -H -u $user bash -c ". ~/.rvm/scripts/rvm;rvm -v | cut -d' ' -f-3"`
		echo ${W}------- ${G}installed: $ver
		echo
	else
		echo $NC...skipped
	fi

echo -n ${W}Installing Ruby v2.0.x for $user
	if [ ! `echo $params | grep -oe'-no_ruby '` ]; then
		echo " -------$NC"
		cd /home/$user
		bash -c ". .rvm/scripts/rvm;rvm list remote"
		file_name=`bash -c ". .rvm/scripts/rvm;rvm list remote" | grep -o ruby-2\.0\..* | tail -1`
		echo Using binaries for ${W}$file_name$NC
		bash -c ". .rvm/scripts/rvm;rvm install $file_name --binary"
		chown -R $user .rvm
		sudo -H -u $user bash -c ". ~/.rvm/scripts/rvm; rvm use $file_name --default"
		ver=`sudo -H -u $user bash -c ". ~/.rvm/scripts/rvm; ruby -v"`
		echo ${W}------- ${G}installed: $ver
		echo
	else
		echo $NC...skipped
	fi

echo -n ${W}Installing 25+ gems for $user
	if [ ! `echo $params | grep -oe'-no_gems '` ]; then
		echo " -------$NC"
		sudo -H -u $user bash -c '
			cd ~
			. .rvm/scripts/rvm
			gem install bundler --no-ri --no-rdoc
			bundle
		'
		echo ${W}------- ${G}done
		echo
	else
		echo $NC...skipped
	fi

echo -n ${W}Installing MondoDB v2.2.7 for $user
	if [ ! `echo $params | grep -oe'-no_mongo '` ]; then
		echo " -------$NC"
		sudo -H -u $user bash -c '
			cd ~
			wget http://fastdl.mongodb.org/linux/mongodb-linux-x86_64-2.2.7.tgz -O mongodb.tgz
			tar -zxf mongodb.tgz -C platform/mongodb --strip-components=1
			rm mongodb.tgz
		'
		ver=`sudo -H -u $user bash -c "~/platform/mongodb/bin/mongod --version | grep 'db ver' | cut -d, -f-1"`
		echo ${W}------- ${G}installed: $ver
		echo
	else
		echo $NC...skipped
	fi

echo -n ${W}Adding crontab @reboot tasks for $user$NC...
	if [ ! `echo $params | grep -oe'-no_cron_tasks '` ]; then
		sudo -H -u $user bash -c "
			cd ~
			echo '@reboot ./start.sh' >> tempcron
			crontab tempcron
			rm tempcron
		"
		echo ${G}done
		echo
	else
		echo skipped
	fi

echo -n ${W}Starting now$NC...
	common_first_line="\n${Y}Now at anytime under the user '$user' you can do:$NC\n*switch from root with: su $user -c'script /dev/null'\n"
	if [ ! `echo $params | grep -oe'-no_start_now '` ]; then
		sudo -H -u $user bash -c "
			cd ~
			./start.sh
		"
		sleep 1
		echo
		echo "$common_first_line"
		echo "$W  ~/start.sh$NC  — start node (now already started)"
	else
		echo skipped
		echo
		echo "$common_first_line"
		echo "$W  ~/start.sh$NC  — start node"
	fi
	
echo "$W\
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
echo $NC
