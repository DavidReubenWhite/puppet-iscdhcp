# iscdhcp::server::v4
#
# This class installs and configures an ISC DHCP v4 server. This class can also be instantiated as iscdhcp::server.
#
# @example
# see examples/v4.pp

class iscdhcp::server::v4 (
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
  #pxe server params
  #puppet 4 doesn't have Stdlib:Fqdn
  Optional[Variant[Stdlib::Fqdn, Stdlib::Ipv4]] $pxe_next_server = undef,
  #Optional[Stdlib::Compat::Ipv4] $pxe_next_server = undef,
  Optional[Enum['arch', 'vci']] $pxe_match_criteria = 'arch',
  Optional[Array[Tuple[String, String]]] $pxe_arch_to_bootfile_map = undef,
  Optional[Array[Tuple[String, String]]] $pxe_vci_to_bootfile_map = undef,
  Optional[String] $pxe_default_bootfile = undef,
  #omapi params
  Optional[Integer] $omapi_port = 7911,
  Optional[String] $omapi_algorithm = 'HMAC-MD5',
  Optional[String] $omapi_key_name = undef,
  Optional[String] $omapi_secret = undef,
  #dns updater params
  Optional[Hash] $dns_zone_keys = undef,
  Optional[Hash] $dns_zones = undef,
  Optional[String] $dns_default_algorithm = undef,
  Optional[Enum['none', 'interim']] $dns_update_style = 'none',
  Optional[Enum['allow', 'ignore', 'deny']] $dns_client_updates = 'deny',
  # failover params
  Optional[String] $failover_name = undef,
  Optional[Variant[Stdlib::Fqdn,
                    Stdlib::Ipv4]] $failover_listen_address = undef,
  #Optional[Stdlib::Compat::Ipv4] $failover_listen_address = undef,
  Optional[Variant[Stdlib::Fqdn, Stdlib::Ipv4]] $failover_peer_address = undef,
  #Optional[Stdlib::Compat::Ipv4] $failover_peer_address = undef,
  Optional[Enum['primary','secondary']] $failover_role = 'primary',
  Optional[Integer] $failover_listen_port = 519,
  Optional[Integer] $failover_peer_port = 520,
  Optional[Integer] $failover_max_response_delay = 60,
  Optional[Integer] $failover_max_unacked_updates = 10,
  Optional[Integer] $failover_mclt = 3600,
  Optional[Integer] $failover_split = 128,
  Optional[Integer] $failover_load_balance_max_s = 3,
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
    unless $subnet =~ Stdlib::IP::Address::V4::CIDR {
      fail("`subnet` is not a valid V4 CIDR: ${subnet}")
    }
    $data.each | $key, $value | {
      unless ($key in ['parameters',
                        'options',
                        'declarations',
                        'permissions',]){
        fail("unsupported subnet key used: ${key}")
      }
    }
  }

  contain iscdhcp::server::install
  contain iscdhcp::server::v4::config
  contain iscdhcp::server::v4::service

  Class['iscdhcp::server::install']
  -> Class['iscdhcp::server::v4::config']
  ~> Class['iscdhcp::server::v4::service']

}
