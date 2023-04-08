node 'puppetmaster.openstacklocal' {
  class { 'docker':
    version => 'latest',
    package_name => 'docker-ce',
    package_ensure => 'installed',
    }  

  exec { "sign_all":
    path => "/usr/bin/:/usr/sbin/:/usr/local/bin:/bin/:/sbin",
    command => "sudo puppet module install garethr-docker",
  }
}

