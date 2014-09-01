# /etc/puppet/manifests/site.pp
#
# Site.pp
#
import "web.pp"
import "database.pp"
  
node /^web(1|2)$/ {
  include web
}
node 'mongodb1' {
  class { 'database':
    replicaset_type  => 'primary',
  }
}
node /^mongodb(2|3)$/ {
  include database
}
