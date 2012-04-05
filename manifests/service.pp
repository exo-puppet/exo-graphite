# Class: graphite::params
#
# This class manage the graphite service
class graphite::service {
    service { "graphite-carbon" :
        ensure     => running,
        name       => $graphite::params::service_carbon_name,
        hasstatus  => true,
        hasrestart => false,
        require => [ Class[ "graphite::install", "graphite::config" ], Exec [ "graphite-carbon-service-install" ] ],
    }
}
