node 'puppetmaster.openstacklocal' {
  package{ 'hping3':
    ensure => "installed",
  }
  exec { "sign_all":
    path => "/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin",
    command => "sudo /opt/puppetlabs/bin/puppetserver ca sign --all",
  }
}

group { 'developers':
  ensure => present,
}


node 'puppet_agent_dev-0.openstacklocal','puppet_agent_dev-1.openstacklocal'{
  package { 'emacs':
    ensure => "installed",
  }
  package { 'jed':
    ensure => "installed",
  }
  package { 'git':
    ensure => "installed",
  }
  user { "bob" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "janet" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }
  user { "alice" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "tim" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }

  exec { "join":
    path => "/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin",
    command => "sudo /opt/puppetlabs/puppet/bin/puppet agent --test",
    unless => "sudo /opt/puppetlabs/puppet/bin/puppet agent -t --noop",
  }
}

node 'puppet_agent_storage-0.openstacklocal','puppet_agent_storage-1.openstacklocal'{
  package { 'hping3':
    ensure => "installed",
  }
  package { 'jed':
    ensure => "installed",
  }
  user { "bob" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "janet" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }
  user { "alice" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "tim" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }
  exec { "join":
    path => "/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin",
    command => "sudo /opt/puppetlabs/puppet/bin/puppet agent --test",
    unless => "sudo /opt/puppetlabs/puppet/bin/puppet agent -t --noop",
  }
}
node 'compile-0.openstacklocal','compile-1.openstacklocal'{
  package { 'binutils':
    ensure => "installed",
  }
  package { 'make':
    ensure => "installed",
  }
   package { 'gcc':
    ensure => "installed",
  }
  user { "bob" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "janet" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }
  user { "alice" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "tim" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }
  exec { "join":
    path => "/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin",
    command => "sudo /opt/puppetlabs/puppet/bin/puppet agent --test",
    unless => "sudo /opt/puppetlabs/puppet/bin/puppet agent -t --noop",
  }
}
node 'puppet-agent-docker.openstacklocal'{
  include 'docker'  
  user { "bob" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "janet" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }
  user { "alice" :
   ensure => present,
   managehome => true,
   groups => ['sudo'],
  }
  user { "tim" :
   ensure => present,
   managehome => true,
   groups => ['developers','sudo'],
  }
  exec { "join":
    path => "/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin",
    command => "sudo /opt/puppetlabs/puppet/bin/puppet agent --test",
    unless => "sudo /opt/puppetlabs/puppet/bin/puppet agent -t --noop",
  }
}

