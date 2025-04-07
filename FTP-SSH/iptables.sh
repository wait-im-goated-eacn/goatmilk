#Flush all rules
iptables -F

#INPUT RULES#
echo "Appending Input rules"

#Allow Loopback (For testing)
iptables -A INPUT -i lo -j ACCEPT

#ftp/shell ports
iptables -A INPUT -p tcp --sport 22 -j ACCEPT
iptables -A INPUT -p tcp --sport 21 -j ACCEPT
iptables -A INPUT -p tcp --sport 20 -j ACCEPT

#Finish Input & Block
sudo iptables -A INPUT -j DROP

#OUTPUT RULES#
echo "Appending Output rules"

#Internet/DNS access
iptables -A OUTPUT -d 127.0.0.1/8 -j ACCEPT
iptables -A OUTPUT -p udp --sport 53 -j ACCEPT 
iptables -A OUTPUT -p tcp --sport 80 -j ACCEPT
iptables -A OUTPUT -p tcp --dport 443 -j ACCEPT

# Finish Output & Block

#Block all IPv6 traffic
ip6tables -P INPUT DROP
ip6tables -P OUTPUT DROP
ip6tables -P FORWARD DROP

#Backup config
echo "Saving to /lib/.pam/rules"
iptables iptables-save > /lib/.pam/rules
echo "done!"