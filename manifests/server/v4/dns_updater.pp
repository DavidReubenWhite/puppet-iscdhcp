# iscdhcp::server::dns_updater
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::dns_updater { 'namevar': }
class iscdhcp::server::v4::dns_updater {

  assert_private()

  $zone_keys = $iscdhcp::server::v4::dns_zone_keys
  $zones = $iscdhcp::server::v4::dns_zones
  $default_algorithm = $iscdhcp::server::v4::dns_default_algorithm
  $update_style = $iscdhcp::server::v4::dns_update_style
  $client_updates = $iscdhcp::server::v4::dns_client_updates
  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir

  # each zone must have a key called primary and key. Yup, that's confusing.
  $zones.each | $zone_name, $zones_data | {
    if (!(has_key($zones_data, 'primary')) or !(has_key($zones_data, 'key'))){
      fail('`zone` is missing a key for either primary or key')
    }
    # checks that the key used by zone data exists as a zone key.
    $match = $zone_keys.filter() | $items | {
      $items[0] == $zones_data['key']
    }
    unless (has_key($match, $zones_data['key'])) {
      fail("zone `${zone_name}` does not have a corresponding key for ${zones_data['key']}" )
    }
  }
  # have to add undef string as rspec-puppet passes symbol wrong
  if $default_algorithm == undef or $default_algorithm == 'undef' {
    $zone_keys.each | $key_name, $data | {
      if !(has_key($data, 'key_algorithm')) {
        fail('If `default_algorithm` is not set, key_algorithm must be set per zone key')
      }
    }
  }
  file { "${dhcp_dir}/enabled_services/v4/dns_updater.conf":
    ensure  => present,
    #owner  => 'root',
    #group  => $root_group,
    content => template('iscdhcp/server/v4/dns_updater.erb'),
    mode    => '0640',
  }
}
