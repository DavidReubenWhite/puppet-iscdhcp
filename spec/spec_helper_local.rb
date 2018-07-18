RSpec.configure do |c|
  c.mock_with :rspec
end

require 'puppetlabs_spec_helper/module_spec_helper'
require 'rspec-puppet-facts'
include RspecPuppetFacts

default_facts = {
  puppetversion: Puppet.version,
  facterversion: Facter.version,
}

default_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_facts.yml'))
default_module_facts_path = File.expand_path(File.join(File.dirname(__FILE__), 'default_module_facts.yml'))

if File.exist?(default_facts_path) && File.readable?(default_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_facts_path)))
end

if File.exist?(default_module_facts_path) && File.readable?(default_module_facts_path)
  default_facts.merge!(YAML.safe_load(File.read(default_module_facts_path)))
end

RSpec.configure do |c|
  c.before(:each) do
    # Fake assert_private function from stdlib to not fail within test
    Puppet::Parser::Functions
      .newfunction(:assert_private, type: :rvalue) do |args|
    end
  end
  c.default_facts = default_facts
  c.hiera_config = File.expand_path(File.join(File.dirname(__FILE__), '../hiera.yaml'))
end

shared_context 'base_params' do
  let(:node_params) do
    {
      'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp',
      'iscdhcp::server::v4::subnets' => {
        '192.168.0.0/24' => {
          'parameters' => {
            'authoritative'  => false,
            'shared_network' => 'shared_network_1_v4',
            'min_lease_time' => '900',
          },
          'options' => {
            'routers' => ['192.168.0.1'],
          },
        },
        '192.168.1.0/24' => {
          'declarations' => {
            'pools' => [
              {
                'parameters' => {
                  'failover_peer' => 'blah.com',
                },
                'declarations' => {
                  'range' => {
                    'start' => '192.168.1.20',
                    'end' => '192.168.1.30',
                  },
                },
              },
            ],
          },
          'parameters' => {
            'shared_network' => 'shared_network_1_v4',
            'min-lease-time' => '900',
          },
          'options' => {
            'routers' => ['192.168.1.1'],
          },
        },
        '172.16.0.0/24' => {
          'parameters' => {
            'min_lease_time' => '900',
            'max_lease_time' => '86400',
          },
          'options' => {
            'routers' => ['172.16.0.1'],
            'domain_name_servers' => ['172.16.0.250', '172.16.0.251'],
          },
          'declarations' => {
            'pools' => [
              {
                'parameters' => {
                  'failover_peer' => 'blah.com',
                },
                'declarations' => {
                  'range' => {
                    'start'   => '172.16.0.10',
                    'end'     => '172.16.0.50',
                  },
                },
              },
              {
                'parameters' => {
                  'failover_peer' => 'blah.com',
                },
                'declarations' => {
                  'range' => {
                    'start' => '172.16.0.100',
                    'end' => '172.16.0.150',
                  },
                },
              },
            ],
            'hosts' => {
              '172.16.0.50' => {
                'parameters' => {
                  'host_identifier' => {
                    'option_name' => 'agent.remote-id',
                    'option_data' => 'REMOTEID12345679',
                  },
                  'fixed_address' => ['172.16.0.50'],
                },
              },
              'grego' => {
                'parameters' => {
                  'host_identifier' => {
                    'option_name' => 'agent.remote-id',
                    'option_data' => 'REMOTEID234567890',
                  },
                  'hardware' => {
                    'option_name' => 'ethernet',
                    'option_data' => '44:44:44:44:44:44',
                  },
                  'fixed_address' => ['172.15.0.51'],
                  'ddns_updates' => 'off',
                },
              },
            },
          },
        },
        '192.168.2.7/32' => {
          # host subnet for dhcp proxy / relay
          'parameters' => {
            'authoritative' => false,
          },
        },
      },
    }
  end
end

RSpec.configure do |c|
  c.after(:suite) do
    RSpec::Puppet::Coverage.report!
  end
end
