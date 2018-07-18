# A description of what this class does
#
# @summary A short summary of the purpose of this class
#
# @example
#   include iscdhcp::server::v4::global_defaults
class iscdhcp::server::v4::global_defaults (
  String                   $target,
  String                   $replace,
  Variant[String, Integer] $order,
  Optional[Hash]           $permissions = undef,
  Optional[Hash]           $parameters = undef,
  Optional[Hash]           $options = undef,
  ) {

  assert_private()

  $dhcp_dir = $iscdhcp::server::v4::dhcp_dir
  $global_defaults = $iscdhcp::server::v4::global_defaults

  $global_permissions = lookup('iscdhcp::server::global_permissions')
  $global_parameters = lookup('iscdhcp::server::parameters')
  $global_options = lookup('iscdhcp::server::options')

  # the below is to merge in our static definitions in common.yaml into the
  # user provided hash

  if $permissions {
    $filtered_permissions = iscdhcp::setup_data_structure($permissions, $global_permissions)
  }
  if $parameters {
    $filtered_parameters = iscdhcp::setup_data_structure($parameters, $global_parameters)
  }
  if $options {
    $filtered_options = iscdhcp::setup_data_structure($options, $global_options)
  }

  # $content = inline_template("
  # <%- require 'json' -%>
  # <%= JSON.pretty_generate(@filtered_parameters) %>
  # ")
  # notify{ $content :
  #   loglevel => notice,
  # }

  concat::fragment { "${dhcp_dir}/dhcpd.conf_global_defaults":
    target  => $target,
    content => template_regex('^', '', 'iscdhcp/server/v4/global_defaults.erb'),
    order   => $order,
  }

}
