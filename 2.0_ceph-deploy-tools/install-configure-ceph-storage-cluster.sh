#!/bin/sh
nodes_name=(${!nodes_map[@]});
monitor_name=(${!monitor_map[@]});
blk_name=(${!blks_map[@]});

base_location=$ftp_info
deploy_node=compute02

echo $deploy_node

##重置为裸盘
for ((i=0; i<${#nodes_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${nodes_map[$name]};
      echo "-------------$name------------";
        for ((j=0; j<${#blks_map[@]}; j+=1));
          do
              name2=${blk_name[$j]};
              blk=${blks_map[$name2]};
              echo "-------------$name2:$blk------------";
              ssh root@$ip ceph-disk zap /dev/$blk
          done
  done
echo $osds
ceph-deploy forgetkeys
ceph-deploy purge  ${nodes_name[@]}
ceph-deploy purgedata   ${nodes_name[@]}

mkdir -p /root/my-cluster
cd /root/my-cluster
rm -rf /root/my-cluster/*
ceph-deploy new $deploy_node

mon_hostname=""
mon_ip=""

### set mon nodes
for ((i=0; i<${#monitor_map[@]}; i+=1));
  do
      name=${monitor_name[$i]};
      ip=${monitor_map[$name]};
      echo "-------------$name------------"
        if [ $name =  $deploy_node ]; then
          echo $name" already is mon!"
        else
         mon_hostname=$mon_hostname","$name
	 mon_ip=$mon_ip","$(echo $store_network|cut -d "." -f1-3).$(echo $ip|awk -F "." '{print $4}')
        fi
  done;
echo $mon_hostname" >>${#monitor_map[@]}  "$mon_ip
sed -i -e 's#'"$(cat ceph.conf |grep mon_initial_members)"'#'"$(cat ceph.conf |grep mon_initial_members)$mon_hostname"'#g' ceph.conf  
sed -i -e 's#'"$(cat ceph.conf |grep mon_host )"'#'"$(cat ceph.conf |grep mon_host )$mon_ip"'#g' ceph.conf  

echo "public network ="$store_network>>ceph.conf
ceph-deploy install --nogpgcheck --repo-url $base_location/download.ceph.com/rpm-$ceph_release/el7/ ${nodes_name[@]} --gpg-url $base_location/download.ceph.com/release.asc
ceph-deploy mon create-initial

osds="";
echo $osds
for ((i=0; i<${#nodes_map[@]}; i+=1));
  do
      name=${nodes_name[$i]};
      ip=${nodes_map[$name]};
      echo "-------------$name------------";
        for ((j=0; j<${#blks_map[@]}; j+=1));
          do
              name2=${blk_name[$j]};
              blk=${blks_map[$name2]};
              echo "-------------$name2:$blk------------";
              osds=$osds" "$name":"$blk;
          done
  done
echo $osds

###[部署节点]激活OSD
ceph-deploy osd create $osds
ceph-deploy admin ${nodes_name[@]}

## set  mon nodes
for ((i=0; i<${#monitor_map[@]}; i+=1));
  do
      name=${monitor_name[$i]};
      ip=${monitor_map[$name]};
      echo "-------------$name------------"
        if [ $name =  $deploy_node ]; then
          echo $name" already is mon!"
        else
          ceph-deploy mon add $name
        fi
  done;

###查看集群状态
ceph -s
###[ceph管理节点]创建Pool
ceph osd pool create volumes 128
ceph osd pool create images 128
ceph osd pool create backups 128
ceph osd pool create vms 128