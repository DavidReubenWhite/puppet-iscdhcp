require 'spec_helper'

describe 'iscdhcp::server::v4::pool' do
  let(:title) { 'pool_55' }
  let(:params) do
    {
      'target'  => '/etc/dhcp/networks/v4/shared_network_1.conf',
      'replace' => '  ',
      'order'   => 3,
    }
  end

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('pool_55') }
    end
  end
end
