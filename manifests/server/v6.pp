# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include iscdhcp::server::v6
class iscdhcp::server::v6 (
  Hash[String, Data, 1] $subnets,
  Optional[String] $freeform_input = undef,
  Optional[Array[Enum['pxe_server',
                        'omapi_listener',
                        'failover',
                        'dns_updater',
                        'freeform_input']]] $enabled_services = [],
  Optional[Hash] $global_defaults = undef,
  #Optional[Hash] $shared_defaults = undef,
  Optional[Hash] $subnet_defaults = undef,
) {

  $dhcp_dir = lookup('iscdhcp::server::dhcp_dir')
  $root_group = lookup('iscdhcp::server::root_group')
  $package_name = lookup('iscdhcp::server::package_name')
  $service_name = lookup('iscdhcp::server::service_name')

  if (!($dhcp_dir) or (empty($dhcp_dir))) {
    fail("unsupported os: ${::osfamily}")
  }
  if (empty($subnets)){
    fail('`subnets` must not be empty')
  }
  unless assert_type(Hash, $subnets){
    fail('`subnets` must be a hash')
  }
  $subnets.each | $subnet, $data | {
    # there is no CIDR matcher for v6
    unless $subnet =~ Stdlib::IP::Address::V6 {
      fail("`subnet` is not a valid V6 address: ${subnet}")
    }
    $data.each | $key, $value | {
      unless ($key in ['parameters',
                        'options',
                        'permissions',
                        'declarations',
                      ]){
        fail("unsupported subnet key used: ${key}")
      }
    }
  }

  contain iscdhcp::server::install
  contain iscdhcp::server::v6::config
  contain iscdhcp::server::v6::service

  Class['iscdhcp::server::install']
  -> Class['iscdhcp::server::v6::config']
  ~> Class['iscdhcp::server::v6::service']
}
