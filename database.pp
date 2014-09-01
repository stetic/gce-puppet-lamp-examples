# /etc/puppet/manifests/database.pp
#
# MongoDB node
#
#
class database (
  $replicaset             = 'replica',
  $replicaset_type        = 'member',
) {
  
  include stdlib

  #
  # System settings
  # Adapted from http://docs.mongodb.org/ecosystem/platforms/google-compute-engine/
  #
  # /etc/security/limits.conf
  file_line { 'limits.conf-soft-nofile':
    ensure => present,
    line   => 'mongod soft nofile 64000',
    path   => '/etc/security/limits.conf',
  }
    
  file_line { 'limits.conf-hard-nofile':
    ensure => present,
    line   => 'mongod hard nofile 64000',
    path   => '/etc/security/limits.conf',
  }
  
  file_line { 'limits.conf-soft-nproc':
    ensure => present,
    line   => 'mongod soft nproc 32000',
    path   => '/etc/security/limits.conf',
  }
    
  file_line { 'limits.conf-hard-nproc':
    ensure => present,
    line   => 'mongod hard nproc 32000',
    path   => '/etc/security/limits.conf',
  }
  
  # /etc/security/limits.d/90-nproc.conf
  file { '/etc/security/limits.d/90-nproc.conf':
    ensure => present
  }
  ->
  file_line { '90-nproc.conf-soft-noproc':
    line => 'mongod soft nproc 32000',
    path => '/etc/security/limits.d/90-nproc.conf',
  }
  ->
  file_line { '90-nproc.conf-hard-noproc':
    line => 'mongod hard nproc 32000',
    path => '/etc/security/limits.d/90-nproc.conf',
  }
  
  # /etc/sysctl.conf
  file_line { 'sysctl.conf-tcp_keepalive_time':
    line => 'net.ipv4.tcp_keepalive_time = 300',
    path => '/etc/sysctl.conf',
  }
  
  # /etc/udev/rules.d/85-mongod.rules
  exec { 'blockdev-setra':
    onlyif  => "/usr/bin/test ! -f /etc/udev/rules.d/85-mongod.rules",
    command => '/sbin/blockdev --setra 32 /dev/disk/by-id/google-mongodb',
    require => Mount["/var/lib/mongodb"]
  }
  ->
  file { '/etc/udev/rules.d/85-mongod.rules':
    ensure => present
  }
  ->
  file_line { '85-mongod.rules':
    line => 'ACTION=="add", KERNEL=="disk/by-id/google-mongodb", ATTR{bdi/read_ahead_kb}="32"',
    path => '/etc/udev/rules.d/85-mongod.rules',
  }

  #
  # User, group and directories  
  #
  group { "mongodb":
    ensure  => present,
  }
  ->
  user { "mongodb":
    ensure  => present,
    gid     => "mongodb",
    require => Group["mongodb"]
  }
  ->
  # The mongodb module has a File resource /var/lib/mongodb - so we have to do a mkdir
  exec { "mkdir-var-lib-mongodb":
    command     => "/bin/mkdir -p /var/lib/mongodb >/dev/null 2>&1",
    user        => "root", 
    unless      => "/usr/bin/test -d /var/lib/mongodb",
  }
  -> 
  mount {'/var/lib/mongodb':
    ensure  => mounted,
    atboot  => true,
    device  => '/dev/disk/by-id/google-mongodb',
    fstype  => 'ext4',
    options => 'defaults,auto,noatime,noexec'
  }
  ->
  exec { "/bin/chown -R mongodb /var/lib/mongodb":
    unless => "/bin/bash -c '[ $(/usr/bin/stat -c %U /var/lib/mongodb) == \"mongodb\" ]'",
  }
  exec { "/bin/chgrp -R mongodb /var/lib/mongodb":
    unless => "/bin/bash -c '[ $(/usr/bin/stat -c %G /var/lib/mongodb) == \"mongodb\" ]'",
  }
  ->
  class {'::mongodb::globals':
    manage_package_repo => true,
    bind_ip             => '0.0.0.0'
  }
  ->
  class {'::mongodb::server':
    ensure           => present,
    bind_ip          => '0.0.0.0',
    directoryperdb   => true,
    replset          => $replicaset,
    require          => Mount["/var/lib/mongodb"]
  }
  ->
  class {'::mongodb::client': }
  
  if $replicaset_type == 'primary' {
  
    mongodb_replset { $replicaset:
      ensure  => present,
      members => ['mongodb1:27017', 'mongodb2:27017', 'mongodb3:27017'],
      require => [ Mount["/var/lib/mongodb"], Class['mongodb::server'] ]
    }
      
  }

}
