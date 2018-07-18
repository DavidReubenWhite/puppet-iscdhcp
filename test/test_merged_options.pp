$options = {
      domain_name => 'example.com',
      domain_name_servers => ['192.168.1.5', '192.168.1.6'],
}

$global_options = {
  domain_name => {
    data_type => 'quoted_string',
    formatted => 'domain-name',
  },
  domain_name_servers => {
    data_type => 'array',
    formatted => 'domain-name-servers',
    array_data_type => 'string'
  }
}
# use a temp var here for readability
$_opts = $options.reduce({}) | $options, $option | {
    $output = $options + {
      $option[0] => { 'action' => $option[1] }
    }
}
$merged_options = deep_merge($global_options, $_opts)
# the merge above merges every key from our global options and we only
# want the initial ones that were passed in so we do the below. Probably an
# easier way but meh.
$filtered_options = $merged_options.filter |$k, $v| {
  if has_key($options, $k) {
    $k == $k
  }
}



      $content = inline_template("
      <%- require 'json' -%>
      <%= JSON.pretty_generate(@filtered_options) %>
      ")
      notify{ $content :
        loglevel => notice,
      }
