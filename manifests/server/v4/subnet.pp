# iscdhcp::server::v4::subnet
#
# A description of what this defined type does
#
# @summary A short summary of the purpose of this defined type.
#
# @example
#   iscdhcp::server::v4::subnet { 'namevar': }
define iscdhcp::server::v4::subnet (
  Optional[Hash] $parameters = undef,
  Optional[Hash] $options = undef,
  Optional[Hash] $permissions = undef,
  Optional[Hash] $declarations = undef,
  String         $dhcp_dir = $iscdhcp::server::v4::dhcp_dir,
) {

  assert_private()

  $global_parameters = lookup('iscdhcp::server::parameters')
  $global_options = lookup('iscdhcp::server::options')
  $global_permissions = lookup('iscdhcp::server::global_permissions')

  # figure out how to enable this without breaking rspec-puppet without including base class

  # if !(defined(Class['iscdhcp::server::v4'])) {
  #   fail('You must include a v4 server before using any defined resources')
  # }

  # In case shared_network key is explicitly set to an emtpy string
  if ($declarations and has_key($declarations, 'shared_network')
    and !empty($declarations['shared_network'])) {
      $shared_network = $declarations['shared_network']
  }
  else {
    $shared_network = undef
  }
  $target = $shared_network ? {
    default => "${dhcp_dir}/networks/v4/${shared_network}.conf",
    undef => "${dhcp_dir}/networks/v4/_private.conf"
  }
  $replace = $shared_network ? {
    default => '  ',
    undef => '',
  }
  $subnet_closing_brace = $shared_network ? {
    default => "  }\n",
    undef => "}\n"
  }

  # validate inputs and merge into globals here
  if $parameters {
#     $parameters.each |$param, $value| {
#       if !has_key($global_parameters, $param) {
#         fail("specified parameter: `${param}` is not in data schema, you will \
# need to add this to `iscdhcp::server::parameters` hash")
#       }
#     }
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
  if $declarations {
    if has_key($declarations, 'pools') {
      $declarations['pools'].each |$index, $data| {
        iscdhcp::server::v4::pool { "${title}_pool_${index}":
          target  => $target,
          replace => $replace,
          order   => 3,
          *       => $data,
        }
      }
    }
    if has_key($declarations, 'hosts') {
      $declarations['hosts'].each |$host, $data| {
        iscdhcp::server::host { $host:
          target  => $target,
          replace => $replace,
          order   => 4,
          *       => $data,
        }
      }
    }
  }

  $content = template('iscdhcp/server/v4/subnet.erb').regsubst('^', $replace, 'GM')

  concat::fragment { "${title}_template":
    target  => $target,
    content => $content,
    order   => 2,
  }
  concat::fragment { "${title}_footer":
    target  => $target,
    content => $subnet_closing_brace,
    order   => 5,
  }
}
