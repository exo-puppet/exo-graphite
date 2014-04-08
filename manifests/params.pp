# Class: graphite::params
#
# This class manage the graphite parameters for different OS
class graphite::params {
  case $::operatingsystem {
    /(Ubuntu)/ : {
      $services_scripts_dir        = '/etc/init.d'
      $service_carbon_name         = 'carbon-cache'
      $run_dir                     = "/var/run/${service_carbon_name}"

      $carbon_local_data_dir       = "${graphite::carbon_data_dir}/whisper"
      $carbon_lists_dir            = "${graphite::carbon_conf_dir}/lists"
      $carbon_data_user            = 'www-data'
      $carbon_data_group           = 'www-data'

      $install_dir                 = '/opt/graphite'
      $tempdir4install             = '/tmp/graphite'

      #        $apache_conf_dir          = "${install_dir}/apache"
      $apache_docroot              = "${install_dir}/webapp"
      $apache_include_conf_file    = "${graphite::graphite_conf_dir}/apache.conf"
      $apache_include_confssl_file = "${graphite::graphite_conf_dir}/apache-ssl.conf"
      $apache_graphite_wsgi_file   = "${graphite::graphite_conf_dir}/graphite.wsgi"

      $packages                    = [
        'python-pip',
        'python-dev',
        'python-django',
        'python-django-tagging',
        'python-memcache',
        'python-cairo',
        'python-amqplib',
        'python-twisted',
        'python-twisted-core',
        'python-twisted-web',
        'python-twisted-names',
        'python-simplejson',
        'python-ldap']

      $graphite_data_dir           = "${install_dir}/storage/whisper"
      # python version
      case $::lsbdistrelease {
        /(10.04)/             : {
          fail("The ${module_name} puppet module is NOT SUPPORTED on ${::operatingsystem} ${::operatingsystemrelease} (and will never be)"
          )
        }
        /(10.10)/             : {
          $python_version = '2.6'
        }
        /(11.04|11.10|12.04)/ : {
          $python_version = '2.7'
        }
        default               : {
          fail("The ${module_name} puppet module is not (yet) supported on ${::operatingsystem} ${::operatingsystemrelease}")
        }
      }
      $python_binary = "python${python_version}"
    }
    default    : {
      fail("The ${module_name} module is not supported on ${::operatingsystem}")
    }
  }
}
