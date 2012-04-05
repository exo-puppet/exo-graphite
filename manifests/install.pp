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
# sudo aptitude install python-django python-django-tagging python-memcache python-amqplib python-twisted python-twisted-core python-twisted-web python-twisted-names python-simplejson python-ldap
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
        path        => "/bin:/sbin:/usr/bin:/usr/sbin",
        logoutput   => true,
    }
    
    # Create compile working dir
    file {$graphite::params::tempdir4install:
        ensure  => directory,
        owner   => root,
        group   => root,
    } ->
    ##############################
    # Whisper download and Install
    ##############################
    wget::fetch { "download-whisper":
        source_url          => "${graphite::params::graphite_download_base_url}/${graphite::params::whisper_version}/+download/whisper-${graphite::params::whisper_version}.tar.gz",
        target_directory    => "${graphite::params::tempdir4install}",
        target_file         => "whisper-${graphite::params::whisper_version}.tar.gz",
    } ->
    exec { "install-whisper":
        command => "tar -zxf whisper-${graphite::params::whisper_version}.tar.gz && cd whisper-${graphite::params::whisper_version} && ${graphite::params::python_binary} setup.py install",
        unless  => "test -f /usr/local/lib/${graphite::params::python_binary}/dist-packages/whisper-${graphite::params::whisper_version}.egg-info",
        cwd     => "${graphite::params::tempdir4install}",
    } ->
    ##############################
    # Carbon download and Install
    ##############################
    wget::fetch { "download-carbon":
        source_url          => "${graphite::params::graphite_download_base_url}/${graphite::params::carbon_version}/+download/carbon-${graphite::params::carbon_version}.tar.gz",
        target_directory    => "${graphite::params::tempdir4install}",
        target_file         => "carbon-${graphite::params::carbon_version}.tar.gz",
    } ->
    exec { "install-carbon":
        command => "tar -zxf carbon-${graphite::params::carbon_version}.tar.gz && cd carbon-${graphite::params::carbon_version} && ${graphite::params::python_binary} setup.py install",
        unless  => "test -f ${graphite::params::install_dir}/lib/carbon-${graphite::params::carbon_version}-py${graphite::params::python_version}.egg-info",
        cwd     => "${graphite::params::tempdir4install}",
    } ->
    ##############################
    # Graphite webapp download and unzip
    ##############################
    wget::fetch { "download-graphite-webapp":
        source_url          => "${graphite::params::graphite_download_base_url}/${graphite::params::graphite_version}/+download/graphite-web-${graphite::params::graphite_version}.tar.gz",
        target_directory    => "${graphite::params::tempdir4install}",
        target_file         => "graphite-web-${graphite::params::graphite_version}.tar.gz",
    } ->
    exec { "unzip-graphite-web":
        command => "tar -zxf graphite-web-${graphite::params::graphite_version}.tar.gz",
        unless  => "test -d ${graphite::params::tempdir4install}/graphite-web-${graphite::params::graphite_version}",
        cwd     => "${graphite::params::tempdir4install}",
    } ->
    ##############################
    # Install all required packages
    ##############################
	package { $graphite::params::packages:
	    ensure  => present,
    } ->
    ##############################
    # python-txamqp download and Install
    ##############################
    wget::fetch { "download-python-txamqp":
        source_url          => "http://launchpad.net/txamqp/trunk/${graphite::params::python_txamqp_version}/+download/python-txamqp_${graphite::params::python_txamqp_version}.orig.tar.gz",
        target_directory    => "${graphite::params::tempdir4install}/graphite-web-${graphite::params::graphite_version}",
        target_file         => "python-txamqp_${graphite::params::python_txamqp_version}.orig.tar.gz",
    } ->
    exec { "install-python-txamqp":
        command => "tar -zxf python-txamqp_${graphite::params::python_txamqp_version}.orig.tar.gz && cd python-txamqp-${graphite::params::python_txamqp_version} && ${graphite::params::python_binary} setup.py install",
        unless  => "test -f /usr/local/lib/${graphite::params::python_binary}/dist-packages/txAMQP-${graphite::params::python_txamqp_version}.egg-info",
        cwd     => "${graphite::params::tempdir4install}/graphite-web-${graphite::params::graphite_version}",
    } ->
    ##############################
    # Graphite webapp install
    ##############################
    exec { "install-graphite-web":
        command => "${graphite::params::python_binary} setup.py install",
        unless  => "test -f ${graphite::params::install_dir}/webapp/graphite_web-${graphite::params::graphite_version}-py${graphite::params::python_version}.egg-info",
        cwd     => "${graphite::params::tempdir4install}/graphite-web-${graphite::params::graphite_version}",
    } ->
    ##############################
    # Graphite database initialization and ownership
    ##############################
    file { ["${graphite::params::install_dir}/storage", "${graphite::params::install_dir}/storage/log", "${graphite::params::install_dir}/storage/log/webapp"]:
        ensure  => directory,
        owner   => www-data,
        group   => www-data,
        mode    => 644,
        recurse => true,
    } ->
    exec { "create-graphite-db":
        command => "${graphite::params::python_binary} manage.py syncdb --noinput && chown -R www-data:www-data ${graphite::params::install_dir}/storage/",
        unless  => "test -f ${graphite::params::install_dir}/storage/graphite.db",
        cwd     => "${graphite::params::install_dir}/webapp/graphite",
	}
	
    ##############################
    # Carbon service script install
    ##############################
	
	file { "graphite-carbon-service-file":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::services_scripts_dir}/${graphite::params::service_carbon_name}",
        content => template ("graphite/etc/init.d/carbon-cache_init.d.sh.erb"),
        mode    => 754,
        require => Class [ "graphite::params" ],
	} ->
	exec { "graphite-carbon-service-install":
	    command    => "update-rc.d ${graphite::params::service_carbon_name} defaults",
#        unless     => "initctl list | grep \"${graphite::params::service_carbon_name}\" "
        unless     => "service --status-all | grep \"${graphite::params::service_carbon_name}\" "
	}
}
