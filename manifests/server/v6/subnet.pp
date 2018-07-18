# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::v6::subnet { 'namevar': }
define iscdhcp::server::v6::subnet (
  Optional[Hash] $parameters = undef,
  Optional[Hash] $options = undef,
  Optional[Hash] $permissions = undef,
  Optional[Hash] $declarations = undef,
) {

  assert_private()

  $dhcp_dir = lookup('iscdhcp::server::dhcp_dir')

  # figure out how to enable this without breaking rspec-puppet without including base class

  # if !(defined(Class['iscdhcp::server::v4'])) {
  #   fail('You must include a v4 server before using any defined resources')
  # }

  # should really have merged the subnet defaults in here...

  # if $hosts {
  #   $hosts.each | $host, $values | {
  #     if has_key($values, 'parameters') {
  #       if has_key($values['parameters'], 'host-identifier') {
  #         unless (has_key($values['parameters']['host-identifier'],'option')
  #           and has_key($values['parameters']['host-identifier'], 'value')) {
  #           fail('if host-identifier specified, must contain an option and value')
  #         }
  #       }
  #     }
  #   }
  # }
  # if $shared_network {
  #   concat::fragment { "${title}_subnet":
  #     target  => "${dhcp_dir}/networks/v6/${shared_network}.conf",
  #     content => template('iscdhcp/server/v6/subnet_shared.erb'),
  #     order   => 2,
  #   }
  # }
  # else {
  #   concat::fragment { "${title}_subnet":
  #     target  => "${dhcp_dir}/networks/v6/_private.conf",
  #     content => template('iscdhcp/server/v6/subnet_private.erb'),
  #     order   => 2,
  #   }
  # }
}
