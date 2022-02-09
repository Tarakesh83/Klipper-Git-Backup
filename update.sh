#!/bin/bash

## Opening manual
if [[ "$1" = "-h" || "$1" = "--help" ]]
then
        less /home/pi/scripts/klipper_backup_script/manual
        exit 1
elif [[ -n "$1" ]]
then
        echo "Try -h, or --help for the manual"
        exit 2
fi

git -C /home/pi/scripts/klipper_backup_script pull origin main

sudo ln -s /home/pi/scripts/klipper_backup_script/klipper_config_git_backup.sh /usr/local/bin/backup
sudo ln -s /home/pi/scripts/klipper_backup_script/restore_config.sh /usr/local/bin/restore
sudo ln -s /home/pi/scripts/klipper_backup_script/uninstall.sh /usr/local/bin/uninstall_bak_util
sudo ln -s /home/pi/scripts/klipper_backup_script/update.sh /usr/local/bin/update_bak_util
sudo ln -s /home/pi/scripts/klipper_backup_script/git_repo.sh /usr/local/bin/reconfigure_git
sudo ln -s /home/pi/scripts/klipper_backup_script/google_drive.sh /usr/local/bin/reconfigure_drive

echo "Checking your config"

if [[ ! -f /home/pi/.config/klipper_backup_script/backup.cfg ]]
then
	echo "Config not found!"
	echo "Please run the setup script again!"
	echo "Setting up command for this..."
	echo "To set the script up just type: setup_klipper_bak_util"
	sudo ln -s /home/pi/scripts/klipper_backup_script/setup.sh /usr/local/bin/setup_klipper_bak_util
	exit 1
fi

configfile='/home/pi/.config/klipper_backup_script/backup.cfg'
configfile_secured='/home/pi/.config/klipper_backup_script/sec_backup.cfg'

## Check if the file contains malicious code
if egrep -q -v '^#|^[^ ]*=[^;]*' "$configfile"
then
        echo "Config file is unclean, cleaning it..." >&2
        ## Filter the original to a new file
        egrep '^#|^[^ ]*=[^;&]*'  "$configfile" > "$configfile_secured"
        configfile="$configfile_secured"
fi

## Importing the config
source "$configfile"

if [[ -z $GIT ]]
then
	GIT=0
fi

if [ $GIT = 0 ]
	echo "You don't have GitHub enabled as a backup location"
	while [[ "$GHUB" != "y" &&  "$GHUB" != "n" ]]
	do
		read -p 'Do you want to enable it? [y|n] ' GHUB
		case $GHUB in
			y)
				echo "Configuring GitHub"
				/home/pi/.config/klipper_backup_script/git_repo.sh
				;;
			n)
				echo "Skipping GitHub config"
				;;
			*)
				echo "Please provide a valid answer"
				;;
		esac
	done
fi

if [[ -z $CLOUD ]]
then
        CLOUD=0
fi

if [ $CLOUD = 0 ]
        echo "You don't have GitHub enabled as a backup location"
        while [[ "$CLD" != "y" &&  "$CLD" != "n" ]]
        do
                read -p 'Do you want to enable it? [y|n] ' CLD
                case $CLD in
                        y)
                                echo "Configuring Google Drive"
                                /home/pi/.config/klipper_backup_script/google_drive.sh
                                ;;
                        n)
                                echo "Skipping Google Drive config"
                                ;;
                        *)
                                echo "Please provide a valid answer"
                                ;;
                esac
        done
fi

if [[ -z $INTERVAL ]]
then
        INTERVAL=0
fi

if [ $INTERVAL = 0 ]
        echo "You don't have scheduled backups enabled"
        while [[ "$SCH" != "y" &&  "$SCH" != "n" ]]
        do
                read -p 'Do you want to enable it? [y|n] ' SCH
                case $SCH in
                        y)
                                echo "Configuring scheduled backups"
                                /home/pi/.config/klipper_backup_script/scheduled_backups.sh
                                ;;
                        n)
                                echo "Skipping scheduled backups"
                                ;;
                        *)
                                echo "Please provide a valid answer"
                                ;;
                esac
        done
fi

if [[ -z $ROTATION ]]
then
        ROTATION=0
fi

if [ $ROTATION = 0 ]
        echo "You don't have Log rotation enabled"
        while [[ "$ROT" != "y" &&  "$ROT" != "n" ]]
        do
                read -p 'Do you want to enable it? [y|n] ' ROT
                case $ROT in
                        y)
                                echo "Configuring scheduled backups"
                                /home/pi/.config/klipper_backup_script/log_rotation.sh
                                ;;
                        n)
                                echo "Skipping log rotation"
                                ;;
                        *)
                                echo "Please provide a valid answer"
                                ;;
                esac
        done
fi

echo "Update completed"
