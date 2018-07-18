$declarations = {
      range => {
        start => '192.168.20.5',
        end => '192.168.20.15',
      }
}

$global_declarations = {
  range => {
    data_type => 'hash',
    hash_keys => {
      start => {
        data_type => 'string',
        order => 1,
      },
      end => {
        data_type => 'string',
        order => 2,
      },
      delimiter => ', ',
      length => 2,
    },
    formatted => 'range'
  }
}
# use a temp var here for readability
$_decs = $declarations.reduce({}) | $declarations, $declaration | {
    $output = $declarations + {
      $declaration[0] => { 'action' => $declaration[1] }
    }
}
$merged_declarations = deep_merge($global_declarations, $_decs)
# the merge above merges every key from our global declarations and we only
# want the initial ones that were passed in so we do the below. Probably an
# easier way but meh.
$filtered_declarations = $merged_declarations.filter |$k, $v| {
  if has_key($declarations, $k) {
    $k == $k
  }
}



      $content = inline_template("
      <%- require 'json' -%>
      <%= JSON.pretty_generate(@filtered_declarations) %>
      ")
      notify{ $content :
        loglevel => notice,
      }
