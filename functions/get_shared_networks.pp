function iscdhcp::get_shared_networks(Hash $subnets) >> Hash {
  $networks = $subnets.reduce({}) | $shared_networks, $subnet | {
    if !(has_key($subnet[1], 'shared_network')) {
      if !('_private' in $shared_networks) {
        $output = $shared_networks + {
          '_private' => {
          $subnet[0] => $subnet[1]
          }
        }
      }
      else {
        $output = $shared_networks + {
          '_private' => $shared_networks["_private"] + {
            $subnet[0] => $subnet[1]
          }
        }
      }
    }
    else {
      if !($subnet[1]['shared_network'] in $shared_networks) {
        $output = $shared_networks + {
          $subnet[1]['shared_network'] => {
            $subnet[0] => $subnet[1]
          }
        }
      }
      else {
        $output = $shared_networks + {
          $subnet[1]['shared_network'] => $shared_networks[$subnet[1]['shared_network']] + {
            $subnet[0] => $subnet[1]
          }
        }
      }
    }
  }
}
