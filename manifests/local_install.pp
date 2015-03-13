# Class: activemq::local_install
#
#   ActiveMQ Local install from the pre-build binary release from the ActiveMQ site
#
# Parameters:
#
# Actions:
#
# Requires:
#
# Sample Usage:
#
class activemq::local_install (
  $version,
  $download_url_root,
  $install_dir        = '/opt',
  $wrapper_dir        = '/opt/activemq/bin/',
  $pid_dir            = '/opt/activemq/data'
) {
  $architecture_flag = split($architecture, '_')
  $wrapper_cmd = "/opt/activemq/bin/linux-x86-${architecture_flag[1]}/wrapper"
  $wrapper_conf = "/opt/activemq/bin/linux-x86-${architecture_flag[1]}/wrapper.conf"

  $download_url = "${download_url_root}/${version}/apache-activemq-${version}-bin.tar.gz"
  notify{"URL: ${download_url}": }

  user { 'activemq':
    ensure => present,
    shell => '/bin/bash',
    password => '!',
    home => '/var/lib/activemq',
    managehome => true,
  } -> 
  exec { 'download-activemq':
    command => "wget ${download_url} -O apache-activemq-bin.tar.gz",
    cwd => '/tmp',
    unless => 'ls /opt/*activemq*',
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/bin'
  } ->
  exec { 'untar-activemq':
    command => 'tar -C /opt -xf apache-activemq-bin.tar.gz',
    cwd => '/tmp',
    unless => 'ls /opt/*activemq*',
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/bin'
  } ->
  exec { 'mv-activemq':
    command => 'mv /opt/apache-* /opt/activemq',
    cwd => '/tmp',
    unless => 'ls /opt/activemq',
    path => '/usr/local/sbin:/usr/local/bin:/usr/sbin:/usr/bin:/root/bin:/bin'
  } ->
  file { 'activemq-dir-root':
    ensure => directory,
    path => '/opt/activemq',
    recurse => true,
    owner => 'root',
    group => 'root'
  } ->
   file { 'activemq-dir-bin':
    ensure => directory,
    path => '/opt/activemq/bin',
    recurse => true,
    owner => 'root',
    group => 'root',
    mode => 0755
  } ->
  file { 'activemq-dir-lib':
    ensure => directory,
    path => '/opt/activemq/lib',
    recurse => true,
    owner => 'root',
    group => 'root',
    mode => 0755
  } ->  
  file { 'activemq-webapps-dir':
    ensure => directory,
    path => '/opt/activemq/webapps',
    recurse => true,
    owner => 'activemq',
    group => 'activemq',
  } ->
  file { 'activemq-data-dir':
    ensure => directory,
    path => '/opt/activemq/data',
    recurse => true,
    owner => 'activemq',
    group => 'activemq',
    before => Service['activemq']
  }

  # Manually adding the init script as this won't get added automatically
  file { '/etc/init.d/activemq':
    ensure  => file,
    path    => '/etc/init.d/activemq',
    content => template("${module_name}/init/activemq.local.erb"),
    owner   => 'root',
    group   => 'root',
    mode    => '0755',
  }
}
