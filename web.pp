# /etc/puppet/manifests/web.pp
#
# Web node
#
class web {

  package { "apache2-mpm-prefork":  
      ensure  => latest
  }
  
  package { "libapache2-mod-php5":  
      ensure  => latest, 
      notify  => Service["apache2"] 
  }

  service { "apache2":
      ensure     => "running",
      enable     => true,
      hasrestart => true,
      require    => Package["apache2-mpm-prefork", "libapache2-mod-php5"]
  }

  package { "php5-mongo":  ensure  => latest }
      
  file { "/var/www/index.php":
    ensure  => file,
    path    => '/var/www/index.php',
    owner   => "www-data",
    group   => "www-data",
    mode    => "0644",
    require => Package["apache2-mpm-prefork"],
    content => "<?php
\$m = new MongoClient( 'mongodb1:27017,mongodb2:27017,mongodb3:27017/?replicaSet=replica' );
\$m->setReadPreference( MongoClient::RP_PRIMARY_PREFERRED );

\$c = \$m->foo->bar;
\$c->insert( array( 'msg' => sprintf( 'Hello from %s at %s.', '${hostname}', date('Y-m-d H:i:s') ) ) );

echo '</h1>Hi, this is ${hostname} on a load balanced apache and connected to a MongoDB replica set</h1>';
echo '<pre>';
        
\$cursor = \$c->find();
foreach (\$cursor as \$doc) {
    var_dump(\$doc);
}

echo '</pre>';

"
  }
  file { "/var/www/index.html":
    ensure  => absent,
    owner   => "root",
    group   => "root",
    require => [ Package["apache2-mpm-prefork"], Service["apache2"] ]
  }

}
