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

  if $parameters {
    $parameters.each |$param, $value| {
      if !has_key($global_parameters, $param) {
        fail("specified parameter: `${param}` is not in data schema, you will \
need to add this to `iscdhcp::server::parameters` hash")
      }
    }
    $filtered_parameters = iscdhcp::setup_data_structure($parameters, $global_parameters)
    # $filtered_parameters.each |$param, $value| {
    #   $filtered_parameters['hash_keys'].each |$hash_key, $value| {
    #     if ($hash_key != 'delimiter' and $hash_key != 'length' and !has_key($filtered_parameters['action'], $hash_key)) {
    #       fail("Missing key/value: `${hash_key}` for parameter: `${param}`")
    #     }
    #   }
    # }
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
      if !has_key($pool_permissions, $perm) {
        fail("specified permission: `${perm}` is not in data schema, you will \
need to add this to `iscdhcp::server::permissions` hash")
      }
    }
    $filtered_permissions = iscdhcp::setup_data_structure($permissions, $pool_permissions)
  }
  if $declarations {
    $declarations.each |$dec, $value| {
      if !has_key($global_declarations, $dec) {
        fail("specified option: `${dec}` is not in data schema, you will need \
to add this to `iscdhcp::server::declarations` hash")
      }
    }
    $filtered_declarations = iscdhcp::setup_data_structure($declarations, $global_declarations)
  }

  $content = template('iscdhcp/server/v4/pool.erb').regsubst('^', $replace, 'GM')

  concat::fragment { $title:
    target  => $target,
    content => $content,
    order   => $order,
  }
}
