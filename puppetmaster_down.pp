gce_instance { 'puppet-master':
    ensure       => absent,
    zone         => 'europe-west1-b',
}