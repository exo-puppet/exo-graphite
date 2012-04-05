# Class: graphite::params
#
# This class manage the graphite configuration
class graphite::config {
    
    file { "carbon.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::install_dir}/conf/carbon.conf",
        content => template ("graphite/opt/graphite/conf/carbon.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params" ],
    } ->

    file { "storage-schemas.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::install_dir}/conf/storage-schemas.conf",
        content => template ("graphite/opt/graphite/conf/storage-schemas.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params" ],
        notify  => Class [ "graphite::service" ],
    } ->

    file { "aggregation-rules.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::install_dir}/conf/aggregation-rules.conf",
        content => template ("graphite/opt/graphite/conf/aggregation-rules.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params" ],
    } ->
    
    #########################################
    # Apache configuration files    
    #########################################    
    file { "graphite_local_settings.py":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::install_dir}/webapp/graphite/local_settings.py",
        content => template ("graphite/opt/graphite/webapp/graphite/local_settings.py.erb"),
        mode    => 644,
        require => Class [ "graphite::params" ],
    } ->
    file { "${graphite::params::apache_conf_dir}":
        ensure  => directory,
        owner   => root,
        group   => root,
        mode    => 644,
    } ->
    file { "apache-graphite.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::apache_include_conf_file}",
        content => template ("graphite/opt/graphite/apache/graphite.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params" ],
        notify  => Class [ "apache2::service" ]
    } ->
    file { "apache-graphite.wsgi":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::apache_conf_dir}/graphite.wsgi",
        content => template ("graphite/opt/graphite/apache/graphite.wsgi.erb"),
        mode    => 644,
        require => Class [ "graphite::params" ],
        notify  => Class [ "apache2::service" ]
    }
    
}
