#!/bin/bash 

#By: Tyler Northrip
#This script configures ubuntu for optimal security
#while running TOR and tests the connection. Run using sudo
#DO NOT RUN AS ROOT!! USE SUDO

# Check for root priviliges
if [[ $EUID -ne 0 ]]; then
   printf "Please run as root:\nsudo %s\n" "${0}"
   exit 1
fi
 
#Remove packages to improve security and shrink attack surface
#Firefox is not needed. TOR should be the only browser
#gcc g++ are removed to prevent code being compiled locally
#Cheese is removed to prevent easy access to webcam
#Yelp, Thunderbird, cups, yelp removed to reduce attack surface
#Vino removed since it is remote access software
#ftp, rsync, ssh removed to prevent easy downloading of files
apt -qq remove firefox vino yelp gcc g++ cheese thunderbird cups ftp rsync ssh -y
apt -qq autoremove -y
 
#Reset the ufw config
ufw --force reset
         
#Deny all incoming traffic and outgoing traffic
ufw default deny incoming
ufw default deny outgoing
 
#Allow out HTTP traffic (unencrypted web pages)
ufw allow out 80/tcp
ufw allow out 80/udp
 
#Allow out HTTPS traffic (encrypted web pages)
ufw allow out 443/tcp
ufw allow out 443/udp

#Allow out dns, neccesary for the connection test to succeed. TOR does NOT need dns to function
ufw allow out 53/tcp
ufw allow out 53/udp

#If you need to download a file using ftp, copy the
#following lines into a terminal
#sudo ufw allow out 20,21/tcp
#Sudo ufw allow out 20,21/udp

#The below code backs up the old before.rules and copies the modified one over
{ 
	cp /etc/ufw/before.rules /etc/ufw/before.rules.old && cp ./before.rules /etc/ufw/before.rules
} ||
{ 
	printf "Please make sure that before.rules is in the same folder as this script\n"
}

#Reload the firewall
ufw disable
ufw enable


#The below code attempts to connect to a webpage via ports 80,81
#if the attempt fails, the print statement is executed. If the firewall
#is functioning as configure, only the second print statement should execute
{ 
	wget -qO- --tries=1 --timeout=5 portquiz.net:80 
} || 
{ 
	printf "Please check your connection, port 80 failed\n"
}

{ 
	wget -qO- --tries=1 --timeout=5 portquiz.net:81
} || 
{ 
	printf "Port 81 is blocked, firewall is functioning\n"
}

printf "Script exiting\n"
