################################################################################
#
# This module manages the Graphite / Carbon service.
#
#   Tested working platforms:
#    - Ubuntu 12.04 Precise
#    - Ubuntu 11.10 Oneiric
#    - Ubuntu 11.04 Natty
#    - Ubuntu 10.10 Maverick
#
#   Tested NOT WORKING platforms:
#    - Ubuntu 10.04 Lucid
#
# == Parameters
#
# [+graphite_time_zone+]
#   (OPTIONAL) (default: Europe/Paris)
#
#   this variable allow to chose the graphite webapp time zone to use for Graphite UI.
#   If your graphs appear to be offset by a couple hours then this probably
#   needs to be explicitly set to your local timezone.
#
# [+carbon_receiver_port+]
#   (OPTIONAL) (default: 2003)
#
#   this variable allow to chose port for carbon tcp receiver.
#
# [+carbon_max_cache_size+]
#   (OPTIONAL) (default: inf)
#
#   this variable allow to chose maximum size of the carbon cache.
#   Limit the size of the cache to avoid swapping or becoming CPU bound.
#   Sorts and serving cache queries gets more expensive as the cache grows.
#   Use the value 'inf' (infinity) for an unlimited cache size.
#
# [+carbon_data_dir+]
#   (OPTIONAL) (default: /var/lib/carbon)
#
#   this variable allow to chose the place where to store all carbon collected data.
#
# [+carbon_conf_dir+]
#   (OPTIONAL) (default: /etc/carbon)
#
#   this variable allow to chose the place where to store carbon configuration.
#
# [+storage_rules+]
#   (OPTIONAL) (default: [  {  name => 'default', pattern => '.*', retentions => '1s:7d,10s:30d,1m:1y' } ])
#
#   An array to define the retention rules to apply on data recorded in carbon.
#   The rules MUST be ordered in the array.
#
# [+aggregation_rules+]
#   (OPTIONAL) (default: [])
#
#   An array to define the list of aggregation rules.
#   Entry format in the array : { description => 'the description of te aggregation rule (optional)', filter => 'the filter to
#   apply', operation => 'the aggregation operation to apply' }
#
# == Modules Dependencies
#
# [+repo+]
#   the +repo+ puppet module is needed to :
#
#   - refresh the repository before installing package (in puppet::install)
#
# == Examples
#
# === Graphite + Carbon install
#
#   class { 'graphite':
#       graphite_time_zone  => 'Europe/Paris',
#       carbon_data_dir     => '/srv/carbon',
#       storage_rules       => [ {  name => 'carbon_data',  pattern => '^carbon\.', retentions => '1m:7d,1h:30d' },
#                                {  name => 'default',      pattern => '.*',        retentions => '1s:7d,10s:30d,1m:1y' } ],
#       aggregation_rules   => [ { description => 'all application request sum', filter => '<env>.applications.<app>.all.requests
#       (60)', operation => 'sum <env>.applications.<app>.*.requests' },
#                                {                                               filter => '<env>.applications.<app>.all.latency
#                                (60)',  operation => 'avg <env>.applications.<app>.*.latency'} ]
#   }
#
# === Apache2 VHost install
#
#   class { 'apache2':
#       ...
#   } ->
#   apache2::vhost { 'graphite.example.com':
#       activated         => true,
#       ssl               => false,
#       server_aliases    => [ 'graphite.*.example.com', 'graphite-*.example.com' ],
#       admin_email       => 'admin@example.com',
#       document_root     => ${graphite::params::apache_docroot},
#       includes          => ${graphite::params::apache_include_conf_file},
#   }
#
################################################################################
class graphite (
  $graphite_conf_dir     = '/etc/graphite',
  $graphite_time_zone    = 'Europe/Paris',
  $carbon_receiver_port  = 2003,
  $carbon_max_cache_size = 'inf',
  $carbon_data_dir       = '/var/lib/carbon',
  $carbon_conf_dir       = '/etc/carbon',
  $carbon_log_dir        = '/var/log/carbon',
  $storage_rules         = [
    {
      name       => 'default',
      pattern    => '.*',
      retentions => '1s:7d,10s:30d,1m:1y'
    }
    ],
  $aggregation_rules     = [
    ]) {
  include graphite::params, graphite::install, graphite::config, graphite::service

}
