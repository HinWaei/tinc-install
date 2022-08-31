#!/bin/bash

echo "##### NOTE: This file is for generating Windows-based client files #####"

read -p "Please enter your client directory name[nickClientVpn]:" -i "nickClientVpn" -e clientDir
clientpath="/etc/tinc/$clientDir"
echo "Your client config files would be stored in $clientpath"
mkdir -p $clientpath/hosts

read -p "Please enter the client file name(i.e. the file in 'hosts' of 'xxClientVpn')[nickClientFile]:" -i "nickClientFile" -e Name
read -p "Please enter the network adapter name you like[myVpn]:" -i "myVpn" -e Interface
ls /etc/tinc
read -p "What's the server vpn directory name?(I guess it would be gameVpn by default) [gameVpn]:" -i "gameVpn" -e vpnName
echo "##### There're totally $(ls /etc/tinc/$vpnName/hosts | wc -l) nodes in the hosts directory of $vpnName #####"
read -p "Please enter the static internal IP address/subnet[e.g. 192.0.0.2]:" -e Subnet
ls /etc/tinc/$vpnName/hosts
read -p "Please enter your server file name(which should be in the server vpn directory, gameVpn if by default, and stand for the server) [myServerFile]:" -i "myServerFile" -e ConnectTo
read -p "What's your server's public IP/domain and port[example.com 655]?:" -i "txcloud.hinwai.top 21111" -e Address

echo "##### If you want to add extra subnets, please edit $clientpath/hosts/$Name #####"
echo "##### By default, the netmask of your subnet is set as 255.255.255.255 #####"

echo "
Name = $Name
ConnectTo = $ConnectTo
Interface = $Interface
" > $clientpath/tinc.conf

echo "
Subnet = $Subnet/32

" > $clientpath/hosts/$Name

echo "##### The netmask of your client file is set as 255.255.255.0 by default #####"

echo "
netsh interface ip set address \"$Interface\" static $Subnet 255.255.255.0
" > $clientpath/tinc-up.bat

#netsh interface ip set address \"$Interface\" source=dhcp
echo "
" > $clientpath/tinc-down.bat


################# TO GENERATE FILES FOR RUN AND DETACHMENT BELOW ################
echo "
@echo off
%~dp0tincd.exe -n $clientDir
pause
" > $clientepath/run.bat

echo "
@echo off
%~dp0tincd.exe -n $clientDir -k
pause
" > $clientepath/detach.bat

################# certificate generation ################

tincd -n $clientDir -K 4096

cp /etc/tinc/$vpnName/hosts/$ConnectTo $clientpath/hosts/
cp $clientpath/hosts/$Name /etc/tinc/$vpnName/hosts


echo "Bravo! You're all set now! Just test it"
