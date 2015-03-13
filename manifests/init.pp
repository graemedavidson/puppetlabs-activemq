# Class: activemq
#
# This module manages the ActiveMQ messaging middleware.
#
# Parameters:
#
# Actions:
#
# Requires:
#
#   Class['java']
#
# Sample Usage:
#
# node default {
#   class { 'activemq': }
# }
#
# To supply your own configuration file:
#
# node default {
#   class { 'activemq':
#     server_config => template('site/activemq.xml.erb'),
#   }
# }
#
class activemq(
  $version                  = 'present',
  $package                  = 'activemq',
  $ensure                   = 'running',
  $instance                 = 'activemq',
  $webconsole               = true,
  $server_config            = 'UNSET',
  $local_install            = false,
  $overwrite_initd          = true,
  $download_url_root        = '',
  $wrapper_java_maxmemory   = 512
) {

  validate_re($ensure, '^running$|^stopped$')
  validate_re($version, '^present$|^latest$|^[~+._0-9a-zA-Z:-]+$')
  validate_bool($webconsole)
  validate_bool($local_install)

  $package_real = $package
  $version_real = $version
  $ensure_real  = $ensure
  $webconsole_real = $webconsole

  # Since this is a template, it should come _after_ all variables are set for
  # this class.
  $server_config_real = $server_config ? {
    'UNSET' => template("${module_name}/activemq.xml.erb"),
    default => $server_config,
  }

  # Anchors for containing the implementation class
  anchor { 'activemq::begin':
    before => Class['activemq::packages'],
    notify => Class['activemq::service'],
  }

  class { 'activemq::packages':
    version           => $version_real,
    download_url_root => $download_url_root,
    package           => $package_real,
    overwrite_initd   => $overwrite_initd,
    notify            => Class['activemq::service'],
  }

  class { 'activemq::wrapper_config':
    wrapper_java_maxmemory  => $wrapper_java_maxmemory,
    notify                  => Class['activemq::service']
  }

  class { 'activemq::config':
    instance      => $instance,
    package       => $package_real,
    server_config => $server_config_real,
    require       => Class['activemq::packages'],
    notify        => Class['activemq::service'],
  }

  class { 'activemq::service':
    ensure => $ensure_real,
  }

  anchor { 'activemq::end':
    require => Class['activemq::service'],
  }
}