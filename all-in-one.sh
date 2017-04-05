
#!/bin/sh
cd bin
./set-ssh-nodes.sh
./set-network-config.sh
./set-hostname.sh
./set-chrony.sh
./disable_firewall_selinux.sh
./set-local-yum-repos.sh
./install-configure-pacemaker.sh
./install-configure-haproxy.sh
./install-configure-galera.sh
./install-configure-rabbitmq.sh
./install-configure-mongodb.sh
./install-configure-memcached.sh
./install-configure-prerequisites.sh
./install-configure-keystone.sh
./install-configure-glance.sh
./install-configure-nova.sh
./install-configure-neutron.sh
./install-configure-dashboard.sh
./install-configure-cinder.sh
./install-configure-ceilometer.sh
./install-configure-aodh.sh
./install-configure-ceph-deploy.sh
./install-configure-ceph-storage-cluster.sh
./install-configure-ceph-auth-client-key.sh
./install-configure-compute-nodes-services.sh
