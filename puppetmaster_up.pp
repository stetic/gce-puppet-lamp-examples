# The Puppet master
gce_instance { 'puppet-master':
  ensure                => present,
  description           => 'Puppet Master Open Source',
  machine_type          => 'f1-micro',
  zone                  => 'europe-west1-b',
  network               => 'default',
  auto_delete_boot_disk => false,
  tags                  => ['puppet', 'master'],
  image                 => 'projects/debian-cloud/global/images/backports-debian-7-wheezy-v20140814',
  manifest              => "include gce_compute_master",
  startupscript         => 'puppet-community.sh',
  puppet_service        => present,
  puppet_master         => "puppet-master",
  modules               => ['puppetlabs-inifile', 'puppetlabs-stdlib', 'puppetlabs-apt', 'puppetlabs-concat', 'saz-locales'],
  module_repos          => { 
    'gce_compute'        => 'git://github.com/stetic/puppetlabs-gce_compute', 
    'gce_compute_master' => 'git://github.com/stetic/puppet-gce_compute_master',
    'mongodb'            => 'git://github.com/puppetlabs/puppetlabs-mongodb'
  }
}
