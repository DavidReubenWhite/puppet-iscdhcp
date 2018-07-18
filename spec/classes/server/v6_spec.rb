require 'spec_helper'

describe 'iscdhcp::server::v6' do
  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'subnets' => {
            '2406:5a00:0:11::/64' => {
              'declarations' => {
                'authoritative'  => true,
                'shared_network' => 'shared_network_2',
              },
              'parameters' => {
                'pools' => [
                  {
                    'declarations' => {
                      'range' => {
                        'start' => '2406:5a00:2:93::10',
                        'end' => '2406:5a00:2:93::ffff:ffff',
                      },
                    },
                  },
                ],
                'pd' => {
                  'start' => '2406:5a00:f400::',
                  'end' => '2406:5a00:f4ff:ff00::',
                  'mask' => 56,
                },
              },
              'options' => {
                'domain-name' => 'larry.com',
              },
            },
          },
        }
      end

      it { is_expected.to compile }
    end
  end
end
