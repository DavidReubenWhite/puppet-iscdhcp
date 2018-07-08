require 'spec_helper_local'

describe 'iscdhcp::server::v4::failover' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:node_params) do
        {

          'iscdhcp::server::v4::dhcp_dir' => '/etc/dhcp',
          'iscdhcp::server::v4::failover_role' => 'primary',
          'iscdhcp::server::v4::failover_name' => 'testpeer.com',
          'iscdhcp::server::v4::failover_listen_port' => 530,
          'iscdhcp::server::v4::failover_peer_port' => 529,
          'iscdhcp::server::v4::failover_listen_address' => 'server1.bighostname.com',
          'iscdhcp::server::v4::failover_peer_address' => 'server2.bighostname.com',
          'iscdhcp::server::v4::failover_max_response_delay' => 60,
          'iscdhcp::server::v4::failover_max_unacked_updates' => 10,
          'iscdhcp::server::v4::failover_mclt' => 3600,
          'iscdhcp::server::v4::failover_split' => 128,
          'iscdhcp::server::v4::failover_load_balance_max_s' => 3,
          'iscdhcp::server::v4::config::failover_names' => ['testpeer.com'],
        }
      end

      it { is_expected.to compile }
      it {
        is_expected
          .to contain_file('/etc/dhcp/enabled_services/failover.conf')
      }
      context 'with different failover peer in pool and defined' do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::failover_name' => 'blah.com',
          )
        end

        it {
          is_expected.to compile
            .and_raise_error(%r{if failover enabled, failover_name must match name specified on subnet pool})
        }
      end
      context 'with missing failover peer' do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::failover_name' => :undef,
          )
        end

        it {
          is_expected.to compile
            .and_raise_error(%r{if failover enabled, failover_name must be set})
        }
      end
      context 'with empty failover_peers' do
        let(:node_params) do
          super().merge(
            'iscdhcp::server::v4::config::failover_names' => [],
          )
        end

        it { is_expected.to compile }
      end
    end
  end
end
