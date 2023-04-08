node 'puppetmaster.openstacklocal' {
  package{ 'hping3':
    ensure => "installed",
  }
  exec { 'sign_all':
    path => '/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin',
    command => 'sudo /opt/puppetlabs/bin/puppetserver ca sign --all',
  }
}

node 'webserver.openstacklocal' {
  package{ 'apache2':
    ensure => "installed",
  }
  exec { 'join':
    path => '/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin',
    command => 'sudo /opt/puppetlabs/puppet/bin/puppet agent --test',
    unless => 'sudo /opt/puppetlabs/puppet/bin/puppet agent -t --noop',
}

node 'devserver.openstacklocal' {
  package { 'gcc':
    ensure => "installed",
  }
  package { 'jed':
    ensure => "installed",
  }
  exec { 'join':
    path => '/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin',
    command => 'sudo /opt/puppetlabs/puppet/bin/puppet agent --test',
    unless => 'sudo /opt/puppetlabs/puppet/bin/puppet agent -t --noop',
  }
}

