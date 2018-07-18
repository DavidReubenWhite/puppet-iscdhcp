# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::v4::pool { 'namevar': }
define iscdhcp::server::v4::pool(
  String                   $target,
  String                   $replace,
  Variant[String, Integer] $order,
  Optional[Hash]           $permissions = undef,
  Optional[Hash]           $declarations = undef,
  Optional[Hash]           $parameters = undef,
  Optional[Hash]           $options = undef,
) {

  $pool_permissions = lookup('iscdhcp::server::pool_permissions')
  $global_declarations = lookup('iscdhcp::server::declarations')
  $global_parameters = lookup('iscdhcp::server::parameters')
  $global_options = lookup('iscdhcp::server::options')

  if $permissions {
    $filtered_permissions = iscdhcp::setup_data_structure($permissions, $pool_permissions)
  }
  if $parameters {
    $filtered_parameters = iscdhcp::setup_data_structure($parameters, $global_parameters)
  }
  if $options {
    $filtered_options = iscdhcp::setup_data_structure($options, $global_options)
  }
  if $declarations {
    $filtered_declarations = iscdhcp::setup_data_structure($declarations, $global_declarations)
  }


  # $content = inline_template("
  # <%- require 'json' -%>
  # <%= JSON.pretty_generate(@filtered_declarations) %>
  # ")
  # notify{ $content :
  #   loglevel => notice,
  # }



  concat::fragment { $title:
    target  => $target,
    content => template_regex('^', $replace, 'iscdhcp/server/v4/pool.erb'),
    order   => $order,
  }
}
