$parameters = {
      authoritative => true,
      # booting => 'deny',
      default_lease => 900,
      host_identifier => {
        option_name => 'agent.remote-id',
        option_data => 'REMOTEID123456789',
      },
      fixed_address => ['172.26.12.1', '172.26.12.2'],
}


$global_parameters = {
  authoritative => {
    data_type => 'boolean',
    formatted => 'authoritative'
  },
  default_lease => {
    data_type => 'integer',
    formatted => 'default-lease-time',
  },
  ddns_updates => {
    data_type => 'string',
    formatted => 'ddns-updates',
  },
  host_identifier => {
    data_type => 'hash',
    hash_keys => {
      option_name => 'string',
      option_data => 'quoted_string',
      delimeter => ' ',
      length => 2
    },
  },
  fixed_address => {
    data_type => 'array',
    formatted => 'fixed-address',
    array_data_type => 'string',
  },
}
# use a temp var here for readability
$_params = $parameters.reduce({}) | $parameters, $permission | {
    $output = $parameters + {
      $permission[0] => { 'action' => $permission[1] }
    }
}
$merged_parameters = deep_merge($global_parameters, $_params)
# the merge above merges every key from our global parameters and we only
# want the initial ones that were passed in so we do the below. Probably an
# easier way but meh.
$filtered_parameters = $merged_parameters.filter |$k, $v| {
  if has_key($parameters, $k) {
    $k == $k
  }
}



      $content = inline_template("
      <%- require 'json' -%>
      <%= JSON.pretty_generate(@filtered_parameters) %>
      ")
      notify{ $content :
        loglevel => notice,
      }
