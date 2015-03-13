# Class: activemq::local_install
#
#   Modify bin/wrapper.conf
#
class activemq::wrapper_config (
  $wrapper_java_maxmemory,
) {

  if !is_integer($wrapper_java_maxmemory) {
    fail("wrapper.java.maxmemory set to: $wrapper_java_maxmemory Not an integer")
  }
  
  if ($activemq::local_install == true) {
    $wrapper_conf_file = "${activemq::local_install::wrapper_conf}"
    notify{"The value is: ${wrapper_conf_file}": }
  } else {
    $wrapper_conf_file = '/etc/activemq/activemq-wrapper.conf'
  }

  augeas { 'activemq-maxmemory':
    changes => [ "set wrapper.java.maxmemory ${wrapper_java_maxmemory}" ],
    incl    => $wrapper_conf_file,
    lens    => 'Properties.lns',
  }
}