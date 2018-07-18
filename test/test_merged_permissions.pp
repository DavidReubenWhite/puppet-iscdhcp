$permissions = {
      client_updates => 'allow',
      # booting => 'deny',
      bootp => 'deny',
}
$flat_permissions = flatten($permissions)

$global_permissions = {
  client_updates => {
    formatted => 'client-updates',
    data_type => 'string',
  },
  booting => {
    formatted => 'booting',
    data_type => 'string',
  },
  bootp => {
    formatted => 'bootp',
    data_type => 'string',
  }
}
# use a temp var here for readability
$_perms = $permissions.reduce({}) | $permissions, $permission | {
    $output = $permissions + {
      $permission[0] => { 'action' => $permission[1] }
    }
}
$merged_permissions = deep_merge($global_permissions, $_perms)
# the merge above merges every key from our global permissions and we only
# want the initial ones that were passed in so we do the below. Probably an
# easier way but meh.
$filtered_permissions = $merged_permissions.filter |$k, $v| {
  if has_key($permissions, $k) {
    $k == $k
  }
}



      $content = inline_template("
      <%- require 'json' -%>
      <%= JSON.pretty_generate(@filtered_permissions) %>
      ")
      notify{ $content :
        loglevel => notice,
      }
