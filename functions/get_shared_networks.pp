function iscdhcp::get_shared_networks(Hash $subnets) >> Hash {
  # if we don't have a declarations key, add it.
  $with_decs = $subnets.reduce({}) | $subnets, $subnet | {
    if !(has_key($subnet[1], 'declarations')){
      $output = $subnets + {
        $subnet[0] => merge($subnet[1], 'declarations' => {})
      }
    }
    else {
      $output = $subnets + {
        $subnet[0] => $subnet[1]
      }
    }
  }
  $networks = $with_decs.reduce({}) | $shared_networks, $subnet | {
    if !(has_key($subnet[1]['declarations'], 'shared_network')) {
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
      if !($subnet[1]['declarations']['shared_network'] in $shared_networks) {
        $output = $shared_networks + {
          $subnet[1]['declarations']['shared_network'] => {
            $subnet[0] => $subnet[1]
          }
        }
      }
      else {
        $output = $shared_networks + {
          $subnet[1]['declarations']['shared_network'] => $shared_networks[$subnet[1]['declarations']['shared_network']] + {
            $subnet[0] => $subnet[1]
          }
        }
      }
    }
  }
}
