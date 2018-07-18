# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::host { 'namevar': }
define iscdhcp::server::host(
  String                   $target,
  String                   $replace,
  Variant[String, Integer] $order,
  Optional[Hash]           $permissions = undef,
  Optional[Hash]           $parameters = undef,
  Optional[Hash]           $options = undef,
) {

  $global_permissions = lookup('iscdhcp::server::global_permissions')
  $global_parameters = lookup('iscdhcp::server::parameters')
  $global_options = lookup('iscdhcp::server::options')

  # the below is to merge in our static definitions in common.yaml into the
  # user provided hash


  if $parameters {
    $parameters.each |$param, $value| {
      if !has_key($global_parameters, $param) {
        fail("specified parameter: `${param}` is not in data schema, you will \
need to add this to `iscdhcp::server::parameters` hash")
      }
    }
    $filtered_parameters = iscdhcp::setup_data_structure($parameters, $global_parameters)
  }
  if $options {
    $options.each |$opt, $value| {
      if !has_key($global_options, $opt) {
        fail("specified option: `${opt}` is not in data schema, you will need \
to add this to `iscdhcp::server::options` hash")
      }
    }
    $filtered_options = iscdhcp::setup_data_structure($options, $global_options)
  }
  if $permissions {
    $permissions.each |$perm, $value| {
      if !has_key($global_permissions, $perm) {
        fail("specified permission: `${perm}` is not in data schema, you will \
need to add this to `iscdhcp::server::permissions` hash")
      }
    }
    $filtered_permissions = iscdhcp::setup_data_structure($permissions, $global_permissions)
  }

  # $content = inline_template("
  # <%- require 'json' -%>
  # <%= JSON.pretty_generate(@filtered_parameters) %>
  # ")
  # notify{ $content :
  #   loglevel => notice,
  # }

  $content = template('iscdhcp/server/v4/host.erb').regsubst('^', $replace, 'GM')

  concat::fragment { "host_${title}":
    target  => $target,
    content => $content,
    order   => $order,
  }
}
