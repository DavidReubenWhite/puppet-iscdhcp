function iscdhcp::setup_data_structure(Hash $data, Hash $static_defaults ) >> Hash {
  # use a temp var here for readability
  $_temp = $data.reduce({}) | $elements, $element | {
      $output = $elements + {
        $element[0] => { 'action' => $element[1] }
      }
  }
  # #_temp (our data) takes priority in the merge
  $merged_elements = deep_merge($static_defaults, $_temp)
  # the merge above merges every key from our global elements and we only
  # want the initial ones that were passed in so we do the below. Probably an
  # easier way but meh.
  $filtered_elements = $merged_elements.filter |$k, $v| {
    # elements is our original hash
    if has_key($data, $k) {
      $k == $k
    }
  }
}
