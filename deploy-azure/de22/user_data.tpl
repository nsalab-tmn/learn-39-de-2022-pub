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
    iface pnet0 inet dhcp
        bridge_ports eth0
        bridge_stp off
        dns-nameservers 8.8.8.8
        up route add 168.63.129.16 netmask 255.255.255.255 gw $(ip route | awk '/default/ {print $3; exit}')
        up route add 169.254.169.254 netmask 255.255.255.255 gw $(ip route | awk '/default/ {print $3; exit}')
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
    mkdir -p /opt/unetlab/addons/qemu/linux-debian-11-de-rev300522-1
    mkdir -p /opt/unetlab/addons/qemu/csr1000v-170304a
    mkdir -p /opt/unetlab/labs/
    
    wget -O - https://kvmstore.blob.core.windows.net/images/csr1000v170304avirtioa.qcow2 > /opt/unetlab/addons/qemu/csr1000v-170304a/virtioa.qcow2
    wget -O - https://kvmstore.blob.core.windows.net/images/winserver2019ttycirev2904222virtioa.qcow2 > /opt/unetlab/addons/qemu/winserver-2019-tty-ci-rev290422-2/sataa.qcow2
    wget -O - https://kvmstore.blob.core.windows.net/images/win10ttycirev2904222virtioa.qcow2 > /opt/unetlab/addons/qemu/win-10-tty-ci-rev290422-2/virtioa.qcow2
    wget -O - https://kvmstore.blob.core.windows.net/images/linuxdebian11derev3005221virtioa.qcow2 > /opt/unetlab/addons/qemu/linux-debian-11-de-rev300522-1/virtioa.qcow2

    wget -O - https://kvmstore.blob.core.windows.net/images/learnlab39decode11-type1.unl > /opt/unetlab/labs/learnlab39decode11-type1.unl
    
  owner: root:root
  permissions: '0644'
- path: /opt/unetlab/html/devices/qemu/device_linux1.php
  content: |
    <?php
    
    /**
     * 
     * @author Aleksandr Gorbachev
     * @copyright NSALAB
     * @link https://nsalab.org
     * file path is /opt/unetlab/html/devices/qemu/device_linux.php
     */
    
    class device_linux extends device_qemu
    {
    
        function __construct($node)
        {
            parent::__construct($node);
        }
    
        public function createEthernets($quantity)
        {
            $ethernets = [];
    
            for ($i = 0; $i < $quantity; $i++) {
    
                if (!isset($this->ethernets[$i])) {
                    $n = 'e' . $i;                // Interface name
                    
                    if($i == 0 && $this->first_nic != ''){
                        $flags = ' -device '.$this->first_nic.',netdev=net' . $i . ',mac=' . incMac($this->createFirstMac(), $i);
                    }else{
                        $flags = ' -device %NICDRIVER%,netdev=net' . $i . ',mac=' . incMac($this->createFirstMac(), $i);
                    }
    
                    $flags .= ' -netdev tap,id=net' . $i . ',ifname=vunl' . $this->getSession() . '_' . $i . ',script=no';
    
                    try {
                        $ethernets[$i] = new Interfc( $this, array('name' => $n, 'type' => 'ethernet', 'flag' => $flags), $i);
                    } catch (Exception $e) {
                        error_log(date('M d H:i:s ') . 'ERROR: ' . $GLOBALS['messages'][40020]);
                        error_log(date('M d H:i:s ') . (string) $e);
                        return false;
                    }
                }
            }
    
            $this->ethernets = $ethernets;
            return $this->ethernets;
        }
    
        public function customFlag($flag)
        {
            if(is_file($this->getRunningPath() . '/minidisk') && !is_file($this->getRunningPath() . '/.configured') && $this->config != 0) {
                $flag .= ' -drive file=minidisk,if=virtio,bus=0,unit=15,cache=none'; 
            }
            return $flag;
        }
    
        public function prepare()
        {
            $result = parent::prepare();
            if ($result != 0) return $result;
    
            if (is_file($this->getRunningPath() . '/startup-config') && !is_file($this->getRunningPath() . '/.configured')) {
                copy($this->getRunningPath() . '/startup-config',  $this->getRunningPath() . '/cloud-config');
                $diskcmd = '/opt/unetlab/scripts/createclouddrive.sh ' . $this->getRunningPath();
                exec($diskcmd, $o, $rc);
            }
    
            return 0;
        }
    
    }
  owner: www-data:www-data
  permissions: '0755'
- path: /opt/unetlab/html/devices/qemu/device_win.php
  content: |
    <?php
    
    /**
     * 
     * @author Aleksandr Gorbachev
     * @copyright NSALAB
     * @link https://nsalab.org
     * file path is /opt/unetlab/html/devices/qemu/device_win.php
     */
    
    class device_win extends device_qemu
    {
    
        function __construct($node)
        {
            parent::__construct($node);
        }
    
        public function customFlag($flag)
        {
            if(is_file($this->getRunningPath() . '/minidisk') && !is_file($this->getRunningPath() . '/.configured') && $this->config != 0) {
                #$flag .= ' -drive file=minidisk,if=virtio,bus=0,unit=1,cache=none'; 
                $flag .= ' -drive file=minidisk,index=0,if=floppy';
            }
            return $flag;
        }
    
        public function prepare()
        {
            $result = parent::prepare();
            if ($result != 0) return $result;
    
            if (is_file($this->getRunningPath() . '/startup-config') && !is_file($this->getRunningPath() . '/.configured')) {
                copy($this->getRunningPath() . '/startup-config',  $this->getRunningPath() . '/cloud-config');
                $diskcmd = '/opt/unetlab/scripts/createwindisk.sh ' . $this->getRunningPath();
                exec($diskcmd, $o, $rc);
            }
    
            return 0;
        }
    
    }
  owner: www-data:www-data
  permissions: '0755'
- path: /opt/unetlab/html/devices/qemu/device_winserver.php
  content: |
    <?php
    
    /**
     * 
     * @author Aleksandr Gorbachev
     * @copyright NSALAB
     * @link https://nsalab.org
     * file path is /opt/unetlab/html/devices/qemu/device_winserver.php
     */
    
    class device_winserver extends device_qemu
    {
    
        function __construct($node)
        {
            parent::__construct($node);
        }
    
        public function customFlag($flag)
        {
            if(is_file($this->getRunningPath() . '/minidisk') && !is_file($this->getRunningPath() . '/.configured') && $this->config != 0) {
                #$flag .= ' -drive file=minidisk,if=virtio,bus=0,unit=1,cache=none'; 
                $flag .= ' -drive file=minidisk,index=0,if=floppy';
            }
            return $flag;
        }
    
        public function prepare()
        {
            $result = parent::prepare();
            if ($result != 0) return $result;
    
            if (is_file($this->getRunningPath() . '/startup-config') && !is_file($this->getRunningPath() . '/.configured')) {
                copy($this->getRunningPath() . '/startup-config',  $this->getRunningPath() . '/cloud-config');
                $diskcmd = '/opt/unetlab/scripts/createwindisk.sh ' . $this->getRunningPath();
                exec($diskcmd, $o, $rc);
            }
    
            return 0;
        }
    }
  owner: www-data:www-data
  permissions: '0755'
- path: /opt/unetlab/scripts/createclouddrive.sh
  content: |
    #!/bin/bash
    # file path is /opt/unetlab/scripts/createclouddrive.sh
    cd $1
    pwd
    cloud-localds minidisk cloud-config
  owner: root:root
  permissions: '0755'
- path: /opt/unetlab/scripts/createwindisk.sh
  content: |
    #!/bin/bash
    # file path is /opt/unetlab/scripts/createwindisk.sh
    cd $1
    pwd
    dd if=/dev/zero of=minidisk count=1440 bs=1k 
    mkfs.msdos minidisk
    mcopy -i minidisk cloud-config ::/init.ps1
    echo -e 'n\np\n1\n\n\nt\ne\nw\n\n' | fdisk  minidisk
  owner: root:root
  permissions: '0755'
- path: /opt/deploy.sh
  content: |
    #!/bin/bash

    bash /opt/get-images.sh > /opt/get-images.out 2>&1    
    bash /opt/install-eve.sh > /opt/install-eve.out 2>&1
    mv /opt/ovf/ovfconfig.sh /opt/ovf/ovfconfig.sh.bak
    bash /opt/ovfconfig.sh > /opt/ovfconfig.out 2>&1
    bash /opt/eve-bootstrap.sh > /opt/eve-bootstrap.out 2>&1 
    echo "network: {config: disabled}" > /etc/cloud/cloud.cfg.d/99-custom-networking.cfg
    /opt/unetlab/wrappers/unl_wrapper -a fixpermissions
  owner: root:root
  permissions: '0644'
- path: /opt/eve-bootstrap.sh
  content: |
    #!/bin/bash
    
    mysql --user=root --password=pnetlab pnetlab_db << EOF
    INSERT INTO user_roles (\`user_role_id\`, \`user_role_name\`, \`user_role_workspace\`) VALUES ("1", "student", "/")
    EOF

    mysql --user=root --password=pnetlab pnetlab_db << EOF
    INSERT INTO users (\`pod\`, \`username\`, \`expiration\`, \`password\`, \`role\`, \`folder\`, \`html5\`, \`offline\`, \`user_status\`) VALUES (2, "student", -1, "$(echo -n '${student_pass}' | sha256sum | awk '{print $1}')", 1, "/", 1, 1, 1)
    EOF

    mysql --user=root --password=pnetlab pnetlab_db << EOF
    INSERT INTO users (\`pod\`, \`username\`, \`expiration\`, \`password\`, \`role\`, \`folder\`, \`html5\`, \`offline\`, \`user_status\`) VALUES (1, "admin", -1, "$(echo -n '${admin_pass}' | sha256sum | awk '{print $1}')", 0, "/", 1, 1, 1)
    EOF

    qemu-img create -f qcow2 /opt/unetlab/addons/qemu/winserver-2019-tty-ci-rev290422-2/satab.qcow2 2G
    qemu-img create -f qcow2 /opt/unetlab/addons/qemu/winserver-2019-tty-ci-rev290422-2/satac.qcow2 2G
    qemu-img create -f qcow2 /opt/unetlab/addons/qemu/linux-debian-11-de-rev300522-1/virtiob.qcow2 2G
    qemu-img create -f qcow2 /opt/unetlab/addons/qemu/linux-debian-11-de-rev300522-1/virtioc.qcow2 2G

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
- bash /opt/deploy.sh
- mv /opt/unetlab/html/devices/qemu/device_linux1.php /opt/unetlab/html/devices/qemu/device_linux.php
- echo 'nameserver 8.8.8.8' > /etc/resolvconf/resolv.conf.d/tail
- wget -O - https://learncertstore.blob.core.windows.net/supercert/supercert.pem > /etc/ssl/certs/apache-selfsigned.crt
- wget -O - https://learncertstore.blob.core.windows.net/supercert/supercert.key > /etc/ssl/private/apache-selfsigned.key
- echo "${hostname}" > /etc/hostname
- reboot

