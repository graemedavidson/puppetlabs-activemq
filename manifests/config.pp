# Class: activemq::config
#
#   class description goes here.
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::config (
  $server_config,
  $instance,
  $package,
  $path = '/etc/activemq/activemq.xml'
) {

  # Resource defaults
  if $activemq::local_install == false {
    File {
      owner   => 'activemq',
      group   => 'activemq',
      mode    => '0644',
      notify  => Service['activemq'],
      require => Package[$package],
    }
  } else {
    File {
      owner   => 'activemq',
      group   => 'activemq',
      mode    => '0644',
      notify  => Service['activemq'],
      require => Exec['mv-activemq'],
    }
  }

  $server_config_real = $server_config

  if ($::osfamily == 'Debian') and  
    ($activemq::local_install == false) {
    
    $available = "/etc/activemq/instances-available/${instance}"
    $path_real = "${available}/activemq.xml"

    file { $available:
      ensure => directory,
    }

    file { "/etc/activemq/instances-enabled/${instance}":
      ensure => link,
      target => $available,
    }
  }
  else {
    validate_re($path, '^/')
    $path_real = $path
  }

  # The configuration file itself.
  if $server_config_real =~ /^puppet:\/\// {
    file { 'activemq.xml':
      ensure  => file,
      path    => $path_real,
      owner   => '0',
      group   => '0',
      source  => $server_config_real,
    }
  } else {
    file { 'activemq.xml':
      ensure  => file,
      path    => $path_real,
      owner   => '0',
      group   => '0',
      content => $server_config_real,
    }
  }
}
