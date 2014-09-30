# == Class: osticket
#
# Full description of class osticket here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { osticket:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2014 Your name here, unless otherwise noted.
#
class osticket {
  class{'apache':
    default_vhost => true,
    mpm_module => prefork,
    service_enable => true,
    service_ensure => running,
  }
  class {'apache::mod::php':}

  apache::vhost {'osticket':
    priority => '10',
    vhost_name => $::ipaddress,
    port => 80,
    docroot => '/var/www/html/osticket',
    logroot => '/var/log/osticket',
    require => Vcsrepo['/var/www/html/osticket'],
  }
  class {'mysql::server':
    root_password => 'ubuntu',
  }

  mysql::db { 'osticket':
    user      => 'ubuntu',
    password  => 'ubuntu',
    host      => 'localhost',
    grant     => ['CREATE','INSERT','SELECT','DELETE','UPDATE'],
    require   => Class['mysql::server],
  }
  vcsrepo { '/var/www/html/osticket/':
    ensure    => present,
    provider  => git,
    source    => 'https://github.com/osTicket/osTicket-1.8/'
  }

  file {'/var/www/html/osticket/include/ost-config':
    ensure   => file,
    source   => '/var/www/html/osticket/include/ost-config.sample.php',
    mode     => '0644',
    require  => Vcsrepo['/var/www/html/osticket'],
  }
}
