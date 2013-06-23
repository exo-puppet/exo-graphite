# Class: graphite::params
#
# This class manage the graphite configuration
class graphite::config {
    
    #########################################
    # Create all needed directories    
    #########################################    
    # Create carbon config directory
    file {$graphite::carbon_conf_dir:
        ensure  => directory,
        owner   => root,
        group   => root,
    } ->
    # Create carbon whitelists directory
    file {$graphite::params::carbon_lists_dir:
        ensure  => directory,
        owner   => root,
        group   => root,
    } ->
    # Create carbon data directory
    file {$graphite::carbon_data_dir:
        ensure  => directory,
        owner   => $graphite::params::carbon_data_user,
        group   => $graphite::params::carbon_data_group,
    } ->
    # Create carbon local data directory
    file {$graphite::params::carbon_local_data_dir:
        ensure  => directory,
        owner   => $graphite::params::carbon_data_user,
        group   => $graphite::params::carbon_data_group,
    } ->
    # Create a symlink between Carbon data directory and the place where Graphite Web think the data are stored 
    file {$graphite::params::graphite_data_dir:
        ensure  => link,
        target  => $graphite::params::carbon_local_data_dir,
        force   => true,
    } ->
    # Create carbon log directory
    file {$graphite::carbon_log_dir:
        ensure  => directory,
        owner   => $graphite::params::carbon_data_user,
        group   => $graphite::params::carbon_data_group,
    } ->
    # Create carbon run directory
    file {$graphite::params::run_dir:
        ensure  => directory,
        owner   => $graphite::params::carbon_data_user,
        group   => $graphite::params::carbon_data_group,
    } ->
    # Create graphit configuration directory
    file {$graphite::graphite_conf_dir:
        ensure  => directory,
        owner   => root,
        group   => root,
    } ->
    #########################################
    # Carbon configuration    
    #########################################    
    file { "carbon.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::carbon_conf_dir}/carbon.conf",
        content => template ("graphite/opt/graphite/conf/carbon.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params", "graphite::install" ],
    } ->

    file { "storage-schemas.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::carbon_conf_dir}/storage-schemas.conf",
        content => template ("graphite/opt/graphite/conf/storage-schemas.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params", "graphite::install" ],
        notify  => Class [ "graphite::service" ],
    } ->

    file { "aggregation-rules.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::carbon_conf_dir}/aggregation-rules.conf",
        content => template ("graphite/opt/graphite/conf/aggregation-rules.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params", "graphite::install" ],
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
        require => Class [ "graphite::params", "graphite::install" ],
    } ->
    file { "apache-graphite.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::apache_include_conf_file}",
        content => template ("graphite/opt/graphite/apache/graphite.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params", "graphite::install" ],
        notify  => Class [ "apache2::service" ]
    } ->
    file { "apache-graphite-ssl.conf":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::apache_include_confssl_file}",
        content => template ("graphite/opt/graphite/apache/graphite-ssl.conf.erb"),
        mode    => 644,
        require => Class [ "graphite::params", "graphite::install" ],
        notify  => Class [ "apache2::service" ]
    } ->
    file { "apache-graphite.wsgi":
        ensure  => file,
        owner   => root,
        group   => root,
        path    => "${graphite::params::apache_graphite_wsgi_file}",
        content => template ("graphite/opt/graphite/apache/graphite.wsgi.erb"),
        mode    => 644,
        require => Class [ "graphite::params", "graphite::install" ],
        notify  => Class [ "apache2::service" ]
    }
    
}
