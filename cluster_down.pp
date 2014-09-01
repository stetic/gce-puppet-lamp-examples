# /etc/puppet/manifests/cluster_down.pp
#
#
gce_disk { 'disk-mongodb1':
    ensure      => absent,
    zone        => 'europe-west1-b',
}
gce_disk { 'disk-mongodb2':
    ensure      => absent,
    zone        => 'europe-west1-a',
}
gce_disk { 'disk-mongodb3':
    ensure      => absent,
    zone        => 'europe-west1-a',
}

gce_disk { 'web1':
    ensure       => absent,
    zone         => 'europe-west1-b',
}
gce_disk { 'web2':
    ensure       => absent,
    zone         => 'europe-west1-a',
}
gce_disk { 'mongodb1':
    ensure       => absent,
    zone         => 'europe-west1-b',
}
gce_disk { 'mongodb2':
    ensure       => absent,
    zone         => 'europe-west1-a',
}
gce_disk { 'mongodb3':
    ensure       => absent,
    zone         => 'europe-west1-a',
}

gce_instance { 'web1':
    ensure       => absent,
    zone         => 'europe-west1-b',
}
gce_instance { 'web2':
    ensure       => absent,
    zone         => 'europe-west1-a',
}
gce_instance { 'mongodb1':
    ensure       => absent,
    zone         => 'europe-west1-b',
}
gce_instance { 'mongodb2':
    ensure       => absent,
    zone         => 'europe-west1-a',
}
gce_instance { 'mongodb3':
    ensure       => absent,
    zone         => 'europe-west1-a',
}
  
gce_firewall { 'allow-http':
    ensure      => absent,
}

gce_forwardingrule { 'web-rule':
    ensure       => absent,
    region       => 'europe-west1',
}
->
gce_targetpool { 'web-pool':
    ensure        => absent,
}
->
gce_httphealthcheck { 'basic-http':
    ensure       => absent,
}

Gce_instance["mongodb1"] -> Gce_disk["disk-mongodb1"] -> Gce_disk["mongodb1"]
Gce_instance["mongodb2"] -> Gce_disk["disk-mongodb2"] -> Gce_disk["mongodb2"]
Gce_instance["mongodb3"] -> Gce_disk["disk-mongodb3"] -> Gce_disk["mongodb3"]
Gce_instance["web1"] -> Gce_disk["web1"]
Gce_instance["web2"] -> Gce_disk["web2"]
