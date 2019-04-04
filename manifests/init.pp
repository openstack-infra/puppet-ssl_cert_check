# == Class: ssl_cert_check
#
class ssl_cert_check(
  $domainlist_file,
  $email = 'root',
  $days = '30',
) {
  # Hacky way of ensuring we have the dependencies for the script installed
  package { 'ssl-cert-check':
    ensure => present,
  }

  file {'/var/lib/certcheck':
    ensure  => directory,
    owner   => 'certcheck',
    group   => 'certcheck',
    mode    => '0755',
    require => User['certcheck'],
  }

  group { 'certcheck':
    ensure => present,
  }

  user { 'certcheck':
    ensure     => present,
    home       => '/var/lib/certcheck',
    shell      => '/bin/bash',
    gid        => 'certcheck',
    managehome => true,
    require    => Group['certcheck'],
  }

  # Pull the script straight from github so that we get support for things
  # like SNI.
  vcsrepo { '/opt/ssl-cert-check':
    ensure   => latest,
    provider => git,
    revision => 'master',
    source   => 'https://github.com/Matty9191/ssl-cert-check',
  }

  cron { 'check ssl certificates':
    user    => 'certcheck',
    command => "/opt/ssl-cert-check/ssl-cert-check -a -q -f ${domainlist_file} -x ${days} -e ${email}",
    hour    => '12',
    minute  => '04',
  }
}

# vim:sw=2:ts=2:expandtab:textwidth=79
