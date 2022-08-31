#!/bin/bash

apt update && apt install ipcalc -y

echo "THIS PROGRAM IS WRITTEN TO GENERATE tinc.conf"

read -p "Please enter the name of your VPN(i.e. the directory with configuration files of this server stored) [gameVpn]:" -i "gameVpn" -e vpnName

mkdir -p /etc/tinc/$vpnName/hosts

cd /etc/tinc/$vpnName

echo "##The VPN directory has been created##"

Address=$(curl ip.sb)

echo "######### tinc.conf  ##########"
read -p "Please enter the interface name you want [tun0]:" -i "tun0" -e Interface
read -p "Please input the name of server file(which would be stored in 'hosts' directory of 'gameVpn' directory) [myServerFile]:" -i "myServerFile" -e Name
read -p "[ IGNORABLE ] Please enter the address to bind to [* means 0.0.0.0/0]:" -i "*" -e BindToAddress
read -p "[ IGNORABLE ] Please enter the listening port [21111]:" -i "21111" -e port
read -p "Enter your the path of your server's network adapter [/dev/net/tun]:" -i "/dev/net/tun" -e Device
echo "PLEASE NOTE THAT the AddressFamily field would be set as ipv4 by default"

echo "######### $Name ##########"
read -p "Please enter the domain/IP of this server [$Address]:" -i "$Address" -e Address
read -p "Please enter the subnet range for nodes connecting to this server [192.0.0.1/24]:" -i "192.0.0.1/24" -e Subnet
#echo "###### Please DO REMEMBER the trailing bits should be 0 ######"

echo "
Name = $Name
Interface = $Interface
BindToAddress = $BindToAddress $port
Device = $Device
Mode = switch
" > /etc/tinc/$vpnName/tinc.conf

echo "
Address = $Address $port
Subnet = $Subnet
" > /etc/tinc/$vpnName/hosts/$Name

echo "####### tinc-up ######"
read -p "[ IGNORABLE ] Please enter the network device you want to forward the packets [eth0]:" -i "eth0" -e dev

####################### generating tinc-up #######################

echo $(cidr_to_netmask)
echo "
#!/bin/bash
/sbin/ifconfig \$INTERFACE $(echo $Subnet | grep -Eo "([0-9]+\.)+[0-9]+") netmask $(ipcalc 192.0.0.1/24 | grep -Eo "(255\.)+(0|255)");
iptables -A FORWARD -o \$INTERFACE -j ACCEPT; iptables -A FORWARD -i \$INTERFACE -j ACCEPT; iptables -t nat -A POSTROUTING -o $dev -j MASQUERADE;
" > /etc/tinc/$vpnName/tinc-up

####################### generating tinc-down #######################

echo "
#!/bin/bash
/sbin/ifconfig \$INTERFACE down;
iptables -D FORWARD -o \$INTERFACE -j ACCEPT; iptables -D FORWARD -i \$INTERFACE -j ACCEPT; iptables -t nat -D POSTROUTING -o $dev -j MASQUERADE;
" > /etc/tinc/$vpnName/tinc-down

chmod -v +x /etc/tinc/$vpnName/tinc-{up,down}
echo 1 > /proc/sys/net/ipv4/ip_forward

####################### generating certificate #######################

sudo tincd -n $vpnName -K 4096

echo "Bravo! You server is all set now! Please continue to configure your client"
