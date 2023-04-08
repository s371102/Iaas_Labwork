node ’slave.openstacklocal’ {
package { ’hping3’:
ensure => ’installed’
}
package { ’jed’:
ensure => ’installed’
}
}
