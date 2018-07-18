function iscdhcp::failover_names(Hash $subnets) >> Array {
  # we need to get all the pools out of the subnets so we can check
  # for failover peers.
  $all_pools = $subnets.reduce([]) | $pools, $subnets | {
    if has_key($subnets[1], 'declarations') {
      if has_key($subnets[1]['declarations'], 'pools') {
        $output = $pools + $subnets[1]['declarations']['pools']
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
    if has_key($pools, 'parameters') {
      if has_key($pools['parameters'], 'failover_peer') {
      $output = $peers + $pools['parameters']['failover_peer']
      }
      else {
        $output = $peers
      }
    }
    else {
      $output = $peers
    }
  }
  $subnet_failover_peers = unique($fp)
}
