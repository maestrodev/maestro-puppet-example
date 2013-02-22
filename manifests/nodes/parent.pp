# Common configuration for Maestro Master and Agent nodes

node 'parent' {

  filebucket { main: server => 'puppet' }

  File { backup => main }
  Exec { path => "/usr/bin:/usr/sbin:/bin:/sbin:/usr/local/bin" }

  group { "puppet":
    ensure => "present",
  }
  File { owner => 0, group => 0, mode => 0644 }

  # Java
  file { "/etc/profile.d/set_java_home.sh":
    ensure  => present,
    content => 'export JAVA_HOME=/usr/lib/jvm/jre-openjdk',
    mode    => '0755',
  } ->
  exec { "/bin/sh /etc/profile": } 
  class { 'java': distribution => 'java-1.6.0-openjdk' }
  package { "java-1.6.0-openjdk-devel": ensure => present}

  case $::kernel {
   'Linux': {
     file { '/etc/motd':
         content => "Maestro 4\n"
     }     
     
     # NTP client
     class { 'ntp': }
    }
    default: {

    }
  }

  # Always persist firewall rules
  exec { 'persist-firewall':
    command     => $operatingsystem ? {
      'debian'          => '/sbin/iptables-save > /etc/iptables/rules.v4',
      /(RedHat|CentOS)/ => '/sbin/iptables-save > /etc/sysconfig/iptables',
    },
    refreshonly => true,
  }

  # These defaults ensure that the persistence command is executed after 
  # every change to the firewall.
  Firewall {
    notify  => Exec['persist-firewall'],
  }
  Firewallchain {
    notify  => Exec['persist-firewall'],
  }
}
