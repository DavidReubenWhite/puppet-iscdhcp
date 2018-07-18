require 'spec_helper'

describe 'iscdhcp::server::v4::global_defaults' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'target' => '/etc/dhcp/dhcpd.conf',
          'replace' => '  ',
          'order' => 5,
        }
      end
      let(:node_params) do
        {
          'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp',
          'iscdhcp::server::v4::global_defaults' => {
            'parameters' => {
              'authoritative'      => false,
              'ping_check'         => false,
              'min_lease_time'     => 600,
              'max_lease_time'     => 600,
              'default_lease_time' => 600,
            },
            'permissions' => {
              'client_updates' => 'ignore',
            },
            'options' => {
              'domain_name' => 'example.com',
            },
          },
        }
      end

      it { is_expected.to compile }
    end
  end
end
