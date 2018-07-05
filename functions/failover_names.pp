function iscdhcp::failover_names(Hash $subnets) >> Array {
  #
  # If the subnet hash passed in has more than one failover peer, we return that, otherwise - false.
  #
  # we need to get all the pools out of the subnets so we can check for
  # failover peers.
  $all_pools = $subnets.reduce([]) | $pools, $subnets | {
    if has_key($subnets[1], 'parameters') {
      if has_key($subnets[1]['parameters'], 'pools') {
        $output = $pools + $subnets[1]['parameters']['pools']
      }
      else {
        $output = $pools
      }
    }
    else {
      $output = $pools
    }
  }
  #failover peers
  $fp = $all_pools.reduce([]) | $peers, $pools | {
    if has_key($pools, 'failover_peer') {
      $output = $peers + $pools['failover_peer']
    }
    else {
      $output = $peers
    }
  }
  $subnet_failover_peers = unique($fp)
}
