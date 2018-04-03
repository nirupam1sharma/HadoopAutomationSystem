#!/bin/bash
dialog --msgbox "This is namenode creation platform " 10 30
my_name=`ifconfig eth0 |grep 192|awk '{print $2}'| cut -f2 -d ":"`
ch=1
while [ $ch -eq 1 ]
do
echo "list of available node ips are "
dialog --textbox  /root/Desktop/my_project/files/avai_nodes 20 30
dialog --inputbox "Enter the IP of Namenode ip " 10 35 2> nameip.txt
ip_name=`cat nameip.txt`
rm -rvf nameip.txt
nmap -sT   $ip_name -p  22  | grep ssh | cut -f2 -d" " >status_node
st=`cat status_node`
if [ $st == "open" ]
then
dialog --inputbox "Enter the port number of Namenode" 10 35 2> nameport.txt
port_name=`cat nameport.txt`
rm -rf nameport.txt
echo "$ip_name:$port_name" > name_ip_port.txt
a=`cat name_ip_port.txt`
rm -rf name_ip_port.txt
cd /root/Desktop/my_project/config
touch core-site.xml
echo '<?xml version="1.0"?>
<?xml-stylesheet type="text/xsl" href="configuration.xsl"?>

<!-- Put site-specific property overrides in this file. -->

<configuration>
<property>
<name>fs.default.name</name>
<value>hdfs://'"$a"'</value>
</property>
</configuration>' &> core-site.xml
ssh-copy-id $ip_name
ssh $ip_name -t yum install hadoop -y
ssh $ip_name -t yum install jdk -y
scp /root/Desktop/my_project/config/core-site.xml  $ip_name:/etc/hadoop/core-site.xml
scp /root/Desktop/my_project/config/name-hdfs-site.xml  $ip_name:/etc/hadoop/hdfs-site.xml
scp /root/Desktop/my_project/config/hadoop-env.sh  $ip_name:/etc/hadoop/hadoop-env.sh.xml
scp /root/Desktop/my_project/config/bash_profile  $ip_name:/root/.bash_profile
scp /root/Desktop/my_project/config/bashrc  $ip_name:/root/.bashrc
ssh $ip_name -t hadoop namenode -format
ssh $ip_name -t hadoop-daemon.sh start namenode
rm -rf core-site.xml
dialog --msgbox "Your Name node has been configured " 10 40 
ch=0
else
dialog --msgbox "try again " 10 40
ch=1
done

