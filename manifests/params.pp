# Class: graphite::params
#
# This class manage the graphite parameters for different OS
class graphite::params {

	case $::operatingsystem {
		/(Ubuntu)/: {

		    $services_scripts_dir = "/etc/init.d"
		    $service_carbon_name  = "carbon-cache"

		    $install_dir        = "/opt/graphite"
            $tempdir4install    = "/tmp/graphite"

            $apache_conf_dir    = "${install_dir}/apache"
            $apache_docroot     = "${install_dir}/webapp"
            $apache_include_conf_file = "${$apache_conf_dir}/graphite.conf"

            $packages           = [ "python-django", "python-django-tagging", "python-memcache", "python-amqplib", "python-twisted", "python-twisted-core", "python-twisted-web", "python-twisted-names", "python-simplejson", "python-ldap" ]

            $graphite_download_base_url = "http://launchpad.net/graphite/0.9"
            $whisper_version            = "0.9.9"
            $carbon_version             = "0.9.9"
            $graphite_version           = "0.9.9"
            $python_txamqp_version      = "0.3"

            # python version
            case $::lsbdistrelease {
                /(10.04)/: {
                    fail ("The ${module_name} puppet module is NOT SUPPORTED on $::operatingsystem $::operatingsystemrelease (and will never be)")
                }
                /(10.10)/: {
                    $python_version = "2.6"
                }
                /(11.04|11.10)/: {
                    $python_version = "2.7"
                }
                default: {
                    fail ("The ${module_name} puppet module is not (yet) supported on $::operatingsystem $::operatingsystemrelease")
                }
            }
            $python_binary  = "python${python_version}"
		}
		default: {
			fail ("The ${module_name} module is not supported on $::operatingsystem")
		}
	}
}
