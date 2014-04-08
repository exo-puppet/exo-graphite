# Class: graphite::params
#
# This class manage the graphite installation
#
# # sudo aptitude install python-whisper
# mkdir -p /tmp/graphite
# cd /tmp/graphite
# # First we install whisper, as both Carbon and Graphite require it
# wget http://launchpad.net/graphite/0.9/0.9.9/+download/whisper-0.9.9.tar.gz
# tar -zxf whisper-0.9.9.tar.gz
# cd whisper-0.9.9/
# sudo python2.7 setup.py install
# cd ..
#
# # Now we install carbon
# wget http://launchpad.net/graphite/0.9/0.9.9/+download/carbon-0.9.9.tar.gz
# tar -zxf carbon-0.9.9.tar.gz
# cd carbon-0.9.9/
# sudo python2.7 setup.py install
# cd ..
# # Finally, the graphite webapp
# wget http://launchpad.net/graphite/0.9/0.9.9/+download/graphite-web-0.9.9.tar.gz
# tar zxf graphite-web-0.9.9.tar.gz
# cd graphite-web-0.9.9/
#
# # install the dependencies
# # optional : python-ldap
# sudo aptitude install python-django python-django-tagging python-memcache python-amqplib python-twisted python-twisted-core
# python-twisted-web python-twisted-names python-simplejson python-ldap
# sudo aptitude install libapache2-mod-python libapache2-mod-wsgi
#
# # Install Python TXAMQP
# wget http://launchpad.net/txamqp/trunk/0.3/+download/python-txamqp_0.3.orig.tar.gz
# tar xzvf python-txamqp_0.3.orig.tar.gz
# pushd python-txamqp-0.3
# python setup.py install
#
# popd
#
# # check all dependencies
# ./check-dependencies.py
#
# # once all dependencies are met...
# sudo python2.7 setup.py install
class graphite::install {
  Exec {
    path      => '/bin:/sbin:/usr/bin:/usr/sbin',
    logoutput => true,
  }

  ##############################
  # Install all required packages
  ##############################
  package { $graphite::params::packages:
    ensure  => present,
    require => [
      Exec['repo-update'],],
  } ->
  ##############################
  # Graphite database initialization and ownership
  ##############################
  file {$graphite::params::install_dir:
    ensure  => directory,
    owner   => root,
    group   => www-data,
    mode    => 644,
  } ->
  file {[
    "${graphite::params::install_dir}/storage",
    "${graphite::params::install_dir}/storage/log",
    "${graphite::params::install_dir}/storage/log/webapp"]:
    ensure  => directory,
    owner   => www-data,
    group   => www-data,
    mode    => 644,
    recurse => true,
  } ->
  ##############################
  # Whisper Install
  ##############################
  package {'whisper':
    ensure    => $graphite::version,
    provider  =>pip,
  } ->
  ##############################
  # Carbon Install
  ##############################
  package {'carbon':
    ensure    => $graphite::version,
    provider  =>pip,
  } ->
  ##############################
  # Graphite Web Install
  ##############################
  package {'graphite-web':
    ensure    => $graphite::version,
    provider  =>pip,
  } ->
  ##############################
  # Graphite database initialization and ownership
  ##############################
  exec { 'create-graphite-db':
    command => "${graphite::params::python_binary} manage.py syncdb --noinput && chown -R www-data:www-data ${graphite::params::install_dir}/storage/",
    # don't do anything if the graphite.db file exists and is non empty
    unless  => "test -s ${graphite::params::install_dir}/storage/graphite.db",
    cwd     => "${graphite::params::install_dir}/webapp/graphite",
  } ->
  ##############################
  # Carbon service script install
  ##############################
  file { 'graphite-carbon-service-file':
    ensure  => file,
    owner   => root,
    group   => root,
    path    => "${graphite::params::services_scripts_dir}/${graphite::params::service_carbon_name}",
    content => template('graphite/etc/init.d/carbon-cache_init.d.sh.erb'),
    mode    => 754,
    require => Class['graphite::params'],
  } ->
  exec { 'graphite-carbon-service-install':
    command => "/usr/sbin/update-rc.d ${graphite::params::service_carbon_name} defaults",
    unless  => "/usr/sbin/service --status-all &> /dev/stdout | grep \"${graphite::params::service_carbon_name}\" "
  }
}
