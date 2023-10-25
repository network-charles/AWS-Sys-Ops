#!/bin/bash 

# Download Oracle Instant Client files 
wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-basic-linux.x64-21.11.0.0.0dbru.zip

wget https://download.oracle.com/otn_software/linux/instantclient/2111000/instantclient-sqlplus-linux.x64-21.11.0.0.0dbru.zip

# Create the /opt/oracle directory if it doesn't exist 
sudo mkdir -p /opt/oracle 

# Install unzip if you don’t have it
sudo apt install unzip

# Unzip the Instant Client files to /opt/oracle 
sudo unzip -d /opt/oracle instantclient-basic-linux.x64-21.11.0.0.0dbru.zip

sudo unzip -d /opt/oracle instantclient-sqlplus-linux.x64-21.11.0.0.0dbru.zip

# update LD_LIBRARY_PATH to include the directory where Oracle Instant Client is installed
sudo echo 'export LD_LIBRARY_PATH=/opt/oracle/instantclient_21_11:$LD_LIBRARY_PATH' >> ~/.bashrc

# adjusts the PATH variable to give preference to the directories listed in LD_LIBRARY_PATH
sudo echo 'export PATH=$LD_LIBRARY_PATH:$PATH' >> ~/.bashrc

# Execute the contents in the .bashrc file 
source ~/.bashrc

sqlplus -V

