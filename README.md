# The Power of Trust — how to run a node
Just get and run the auto-installer script
> Installer should be run under the `root` user. A special `potrust` user will be created first and all the installation process will be done under that user and inside the `/home/potrust` (`/Users/potrust`) dir.  
For the sake of security all the working processes will be run only under the `potrust` user.

* On **Ubuntu / Debian**  
	`wget j.mp/aiscr -qO potrust_install.sh --no-check-certificate`  
	and then  
	`bash potrust_install.sh -no_cron_tasks` — for occasional use  
	`bash potrust_install.sh` — for running a supernode with opened external port  
	  
	Check the output for any errors and read the final notes.  
	If something went wrong and `localhost:3070` doesn't work for you — let's try [the detailed step-by-step instruction](detailed%20step-by-step%20instruction.md).
  
* On **Mac OS X** (10.9+)
	>Currently there is a problem if brew is not owned by root   
	
	`curl -sSL j.mp/aiscr -o potrust_install.sh`  
	and then  
	`bash potrust_install.sh -no_cron_tasks` — for occasional use  
	`bash potrust_install.sh` — for running a supernode with opened external port  
	  
	Check the output for any errors and read the final notes.  
	If something went wrong and `localhost:3070` doesn't work for you — let's try [the detailed step-by-step instruction](detailed%20step-by-step%20instruction%20(OSX).md).
  
* Other Linux distributives are waiting for king contributors (just send your pull requests).


## Resource usage
* 750MB of a disk space will be used from start. 
* Initial RAM usage: 120 MB (38 Node + 42 Web-Client + 40 MongoDB).
* Very low CPU and traffic usage after the initial sync.

## Feedback
Yura Babak — yura.des@gmail.com
