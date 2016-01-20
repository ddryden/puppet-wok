# == Class: wok
# Puppet class to install and manage a Ralph CMDB server.
#
# == Author: Dennis Dryden
#
# === Parameters:
#
# [*service_user*] user running the service.
#   Optional. Defaults to wok
#
# [*url*] The URL that you want ralph to be avalible on.
#   Optional. Defaults to 'ralphcmdb.*'.
#
# [*service_home*] The service_home directory of the wok user
#   Optional. Defaults to '/opt/wok'
#
class wok (
  $service_user = 'wok',
  $url = 'wok.*',
  $service_home = '/opt/wok/'
) {
  include '::nginx'
  class { 'python': }

  $virtualenv_path = "${service_home}/virtualenv"

  ensure_packages([
    'openssl',
    'fonts-font-awesome',
    'texlive-fonts-extra'
  ])

  group { $service_user: ensure => present }
  user { $service_user:
    ensure       => present,
    groups       => $service_user,
    service_home => $service_home,
    require      => Group[$service_user]
  }

  File{ $service_home:
    ensure  => directory,
    mode    => '0644',
    require => User[$service_user]
  }

  File{ $virtualenv_path:
    ensure => directory,
    owner  => $service_user,
    group  => $service_user,

  }

  File{ "${virtualenv_path}/requirements.txt":
    owner      => $service_user,
    group      => $service_user,
    source     => 'puppet://modules/wok/pip-requirements.txt'
    require    => File["${virtualenv_path}/requirements"];
  }

  python::virtualenv { $virtualenv_path:
    ensure       => present,
    requirements => "${virtualenv_path}/requirements.txt"
    owner        => $service_user,
    group        => $service_user,
    cwd          => $virtualenv_path,
    require      => File[$virtualenv_path];
  }

}
