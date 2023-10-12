#cloud-config
chpasswd:
  list: |
    root:${admin_pass}
  expire: false
write_files:
- path: /opt/ovfconfig.sh
  content: |
    #!/bin/bash

    # Check if VM is alredy configured
    if [[ -e /opt/ovf/.configured ]]; then
        exit
    fi

    . ~/.profile

    # Setting Management Network
    cat > /etc/network/interfaces << EOF
    # The loopback network interface
    auto lo
    iface lo inet loopback
    
    # The primary network interface
    iface eth0 inet manual
    auto pnet0
    iface pnet0 inet static
        address $(ifconfig ens3 | awk '/netmask/ {print $2; exit}')
        netmask $(ifconfig ens3 | awk '/netmask/ {print $4; exit}')
        gateway $(ip route | awk '/default/ {print $3; exit}')
        bridge_ports eth0
        bridge_stp off
        dns-nameservers 8.8.8.8
    EOF

    # Setting the NTP server
    sed -i 's/NTPDATE_USE_NTP_CONF=.*/NTPDATE_USE_NTP_CONF=yes/g' /etc/default/ntpdate
    sed -i 's/NTPSERVERS=.*/NTPSERVERS=/g' /etc/default/ntpdate

    # Cleaning
    rm -rf /root/.bash_history /opt/unetlab/tmp/* /tmp/netio* /tmp/vmware* /opt/ovf/ovf_vars /opt/ovf/ovf.xml /root/.bash_history /root/.cache
    find /var/log -type f -exec rm -f {} \;
    find /var/lib/apt/lists -type f -exec rm -f {} \;
    find /opt/unetlab/data/Logs -type f -exec rm -f {} \;
    touch /var/log/wtmp
    chown root:utmp /var/log/wtmp
    chmod 664 /var/log/wtmp

    touch /opt/ovf/.configured
  owner: root:root
  permissions: '0644'
- path: /opt/get-images.sh
  content: |
    #!/bin/bash
    
    mkdir -p /opt/unetlab/addons/qemu/winserver-2019-tty-ci-rev290422-2
    mkdir -p /opt/unetlab/addons/qemu/win-10-tty-ci-rev290422-2
    mkdir -p /opt/unetlab/addons/qemu/linux-debian-11-de-rev210622-1
    mkdir -p /opt/unetlab/addons/qemu/csr1000v-170304a
    mkdir -p /opt/unetlab/labs/
    
    apt-get -y update
    DEBIAN_FRONTEND=noninteractive apt-get -y install awscli
    aws configure set aws_access_key_id bsk2XpHdYcLY1UNJiZysb5 --profile default
    aws configure set aws_secret_access_key gfquNLPZeE3CX1j5hZN4bSLRfvXc2YnBJzRSA5LQ8zPT --profile default
    aws configure set region RegionOne --profile default
    aws configure set output json --profile default

    aws s3 cp s3://kvmstore/csr1000v170304avirtioa.qcow2 /opt/unetlab/addons/qemu/csr1000v-170304a/virtioa.qcow2  --endpoint-url https://hb.bizmrg.com/
    aws s3 cp s3://kvmstore/linuxdebian11derev2106221virtioa.qcow2 /opt/unetlab/addons/qemu/linux-debian-11-de-rev210622-1/virtioa.qcow2    --endpoint-url  https://hb.bizmrg.com/
    aws s3 cp s3://kvmstore/winserver2019ttycirev2904222sataa.qcow2 /opt/unetlab/addons/qemu/winserver-2019-tty-ci-rev290422-2/sataa.qcow2    --endpoint-url  https://hb.bizmrg.com/
    aws s3 cp s3://kvmstore/win10ttycirev2904222virtioa.qcow2 /opt/unetlab/addons/qemu/win-10-tty-ci-rev290422-2/virtioa.qcow2   --endpoint-url  https://hb.bizmrg.com/


    #wget -O - https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/d/Iq6hzvLw1Zn75g/cml2/csr1000v-170304a/virtioa.qcow2 > /opt/unetlab/addons/qemu/csr1000v-170304a/virtioa.qcow2
    #wget -O - https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/d/Iq6hzvLw1Zn75g/winserver-2019-tty-ci-rev290422-2/virtioa.qcow2 > /opt/unetlab/addons/qemu/winserver-2019-tty-ci-rev290422-2/virtioa.qcow2
    #wget -O - https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/d/Iq6hzvLw1Zn75g/win-10-tty-ci-rev290422-2/virtioa.qcow2 > /opt/unetlab/addons/qemu/win-10-tty-ci-rev290422-2/virtioa.qcow2
    #wget -O - https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/d/Iq6hzvLw1Zn75g/linux-debian-11-de-rev300522-1/virtioa.qcow2 > /opt/unetlab/addons/qemu/linux-debian-11-de-rev210622-1/virtioa.qcow2

    wget -O - https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/d/9910L_hhp8HHKw/learnlab39decode11-type1.unl > /opt/unetlab/labs/learnlab39decode11-type1.unl
    
  owner: root:root
  permissions: '0644'
- path: /opt/deploy.sh
  content: |
    #!/bin/bash

    bash /opt/get-images.sh > /opt/get-images.out 2>&1    
    bash /opt/install-eve.sh > /opt/install-eve.out 2>&1
    mv /opt/ovf/ovfconfig.sh /opt/ovf/ovfconfig.sh.bak
    bash /opt/ovfconfig.sh > /opt/ovfconfig.out 2>&1
    wget -O - https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/d/tjBKyPmQMA-lyw/eve-bootstrap.sh > /opt/eve-bootstrap.sh && chmod 0644 /opt/eve-bootstrap.sh
    bash /opt/eve-bootstrap.sh > /opt/eve-bootstrap.out 2>&1 
    echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-custom-networking.cfg
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
    wget -O - https://getfile.dokpub.com/yandex/get/https://disk.yandex.ru/d/tjBKyPmQMA-lyw/get-files.sh > /opt/get-files.sh && chmod 0644 /opt/get-files.sh
    bash /opt/get-files.sh > /opt/get-files.out 2>&1 
    mv /opt/supercert.crt /etc/ssl/certs/apache-selfsigned.crt
    mv /opt/supercert.key /etc/ssl/private/apache-selfsigned.key
  owner: root:root
  permissions: '0644'
- path: /opt/install-eve.sh
  content: |
    #!/bin/bash
    echo "deb [trusted=yes] http://repo.pnetlab.com ./" >> /etc/apt/sources.list
    DEBIAN_FRONTEND=noninteractive apt-get update
    DEBIAN_FRONTEND=noninteractive apt-get purge netplan.io -y
    rm /etc/resolv.conf
    echo 'nameserver 8.8.8.8' > /opt/resolv.conf
    ln -s /opt/resolv.conf /etc/resolv.conf    
    DEBIAN_FRONTEND=noninteractive apt-get install cloud-image-utils pnetlab -y  
  owner: root:root
  permissions: '0644'
runcmd:
- sed -i -e "s/.*PermitRootLogin .*/PermitRootLogin yes/" /etc/ssh/sshd_config
- sed -i -e "s/.*PasswordAuthentication .*/PasswordAuthentication yes/" /etc/ssh/sshd_config
- service sshd restart
- echo 'DNS=8.8.8.8' >> /etc/systemd/resolved.conf
- systemctl restart systemd-resolved.service
- bash /opt/deploy.sh
- echo "${hostname}" > /etc/hostname
- reboot