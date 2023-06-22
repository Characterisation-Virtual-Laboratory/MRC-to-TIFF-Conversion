### TransferScript ###
A wrapper script for RClone to allow for automated, parallel file transfers.
Designed for easy configuration and reuse via the associated 'config.json' file.

Logs transfers and sends an alert email on errors.

Can be configured with a list of transfers so multiple source and destination pairs can be managed with a single instance if desired.




### Requirements ###
Python 3.8+			($ sudo dnf install python38)
RClone v1.61.1+			($ curl -O https://downloads.rclone.org/rclone-current-linux.amd.zip)




### Download Commands ###
$ cd ~/Downloads
$ git clone https://github.com/Characterisation-Virtual-Labratory/Data-Movement-Automation




### Install Commands ###
$ cd ~/Downloads/Data-Movement-Automation
$ sudo ./INSTALL.sh




### Configuration ###
Edit the following files:
	/usr/local/scripts/TransferScript/config.json
		This is where most of your transfer settings are defined.
	/usr/local/scripts/TransferScript/excludes.txt
		Any files / folders you want to exclude from the transfers.
	/etc/systemd/system/TransferScript.service
		Set "User=<user_to_run_as>" for the script and RClone transfer.
	/etc/systemd/system/TransferScript.timer
		Set when you want this to run.

Fix ownership:
	$ sudo chown -R <user_to_run_as> /usr/local/scripts/TransferScript

Add any required endpoints into rclone (not required for local src / dest):
	$ su <user_to_run_as>
	$ export RCLONE_CONFIG=/usr/local/scripts/TransferScript/rclone.conf
	$ rclone config
		See: https://rclone.org/commands/rclone_config/




### Enable ###
$ sudo systemctl enable TransferScript.timer