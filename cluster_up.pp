# /etc/puppet/manifests/cluster_up.pp
#
# LAMP cluster on GCE with Apache and MongoDB replica set
#
# Disks

gce_disk { 'disk-mongodb1':
  ensure               => present,
  description          => 'mongodb1:/var/lib/mongodb',
  size_gb              => '100',
  zone                 => 'europe-west1-b',
  disk_type            => 'pd-ssd',
  wait_until_complete  => true
}

gce_disk { 'disk-mongodb2':
  ensure               => present,
  description          => 'mongodb2:/var/lib/mongodb',
  size_gb              => '100',
  zone                 => 'europe-west1-a',
  disk_type            => 'pd-ssd',
  wait_until_complete  => true
}

gce_disk { 'disk-mongodb3':
  ensure               => present,
  description          => 'mongodb3:/var/lib/mongodb',
  size_gb              => '100',
  zone                 => 'europe-west1-a',
  disk_type            => 'pd-ssd',
  wait_until_complete  => true
}

# Instances
gce_instance { 'web1':
  ensure                => present,
  machine_type          => 'g1-small',
  zone                  => 'europe-west1-b',
  network               => 'default',
  boot_disk_type        => 'pd-ssd',
  auto_delete_boot_disk => false,
  tags                  => ['apache', 'web'],
  image                 => 'projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140814',
  manifest              => '',
  startupscript         => 'puppet-community.sh',
  puppet_service        => present,
  puppet_master         => $fqdn
}

gce_instance { 'web2':
    ensure                => present,
    machine_type          => 'g1-small',
    zone                  => 'europe-west1-a',
    network               => 'default',
    boot_disk_type        => 'pd-ssd',
    auto_delete_boot_disk => false,
    tags                  => ['apache', 'web'],
    image                 => 'projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140814',
    manifest              => '',
    startupscript         => 'puppet-community.sh',
    puppet_service        => present,
    puppet_master         => $fqdn
}

gce_instance { 'mongodb1':
  ensure                    => present,
  machine_type              => 'n1-highmem-2',
  zone                      => 'europe-west1-b',
  network                   => 'default',
  require                   => Gce_disk['disk-mongodb1'],
  disk                      => 'disk-mongodb1,deviceName=mongodb',
  boot_disk_type            => 'pd-ssd',
  auto_delete_boot_disk     => false,
  tags                      => ['mongodb', 'database', 'primary'],
  image                     => 'projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140814',
  manifest                  => 'exec { "mkdir-var-lib-mongodb":
    command => "/usr/bin/sudo /bin/mkdir -p /var/lib/mongodb"
  }
  exec { "safe_format_and_mount":
    command => "/usr/bin/sudo /usr/share/google/safe_format_and_mount -m \"mkfs.ext4 -F\" /dev/disk/by-id/google-mongodb /var/lib/mongodb",
    require => Exec["mkdir-var-lib-mongodb"]
  }',
  startupscript             => 'puppet-community.sh',
  puppet_service            => present,
  puppet_master             => $fqdn
}

gce_instance { 'mongodb2':
  ensure                    => present,
  machine_type              => 'n1-highmem-2',
  zone                      => 'europe-west1-a',
  network                   => 'default',
  require                   => Gce_disk['disk-mongodb2'],
  disk                      => 'disk-mongodb2,deviceName=mongodb',
  boot_disk_type            => 'pd-ssd',
  auto_delete_boot_disk     => false,
  tags                      => ['mongodb', 'database', 'member'],
  image                     => 'projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140814',
  manifest                  => 'exec { "mkdir-var-lib-mongodb":
    command => "/usr/bin/sudo /bin/mkdir -p /var/lib/mongodb"
  }
  exec { "safe_format_and_mount":
    command => "/usr/bin/sudo /usr/share/google/safe_format_and_mount -m \"mkfs.ext4 -F\" /dev/disk/by-id/google-mongodb /var/lib/mongodb",
    require => Exec["mkdir-var-lib-mongodb"]
  }',
  startupscript             => 'puppet-community.sh',
  puppet_service            => present,
  puppet_master             => $fqdn
}

gce_instance { 'mongodb3':
  ensure                    => present,
  machine_type              => 'n1-highmem-2',
  zone                      => 'europe-west1-a',
  network                   => 'default',
  require                   => Gce_disk['disk-mongodb3'],
  disk                      => 'disk-mongodb3,deviceName=mongodb',
  boot_disk_type            => 'pd-ssd',
  auto_delete_boot_disk     => false,
  tags                      => ['mongodb', 'database', 'member'],
  image                     => 'projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140814',
  manifest                  => 'exec { "mkdir-var-lib-mongodb":
    command => "/usr/bin/sudo /bin/mkdir -p /var/lib/mongodb"
  }
  exec { "safe_format_and_mount":
    command => "/usr/bin/sudo /usr/share/google/safe_format_and_mount -m \"mkfs.ext4 -F\" /dev/disk/by-id/google-mongodb /var/lib/mongodb",
    require => Exec["mkdir-var-lib-mongodb"]
  }',
  startupscript             => 'puppet-community.sh',
  puppet_service            => present,
  puppet_master             => $fqdn
}

#
# Firewall
#
gce_firewall { 'allow-http':
    ensure      => present,
    network     => 'default',
    description => 'allows incoming HTTP connections',
    allowed     => 'tcp:80',
}

#
# Load balancer
#
gce_httphealthcheck { 'basic-http':
    ensure       => present,
    require      => Gce_instance['web1', 'web2'],
    description  => 'basic http health check',
}
gce_targetpool { 'web-pool':
    ensure        => present,
    require       => Gce_httphealthcheck['basic-http'],
    health_checks => 'basic-http',
    instances     => 'europe-west1-b/web1,europe-west1-a/web2',
    region        => 'europe-west1',
}
gce_forwardingrule { 'web-rule':
    ensure       => present,
    require      => Gce_targetpool['web-pool'],
    description  => 'Forward HTTP to web instances',
    port_range   => '80',
    region       => 'europe-west1',
    target       => 'web-pool',
}
