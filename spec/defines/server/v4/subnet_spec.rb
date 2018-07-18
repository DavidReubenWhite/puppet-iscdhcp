require 'spec_helper_local'

describe 'iscdhcp::server::v4::subnet' do
  include_context 'base_params'
  let(:title) { '10.0.0.0/24' }

  on_supported_os.each do |os, os_facts|
    context "on #{os}" do
      let(:facts) { os_facts }
      let(:params) do
        {
          'declarations' => {
            'hosts' => {
              'hostblah' => {
                'parameters' => {
                  'host_identifier' => {
                    'option_name' => 'agent.remote-id',
                    'option_data' => 'REMOTEID12345679',
                  },
                },
              },
            },
          },
        }
      end

      it { is_expected.to compile }
      it { is_expected.to contain_concat__fragment('10.0.0.0/24_footer') }
      it { is_expected.to contain_concat__fragment('10.0.0.0/24_template') }
      it { is_expected.to contain_concat__fragment('host_hostblah') }
      it {
        is_expected
          .to contain_iscdhcp__server__host('hostblah')
      }
      # context 'with host_identifier option missing' do
      #   let(:params) do
      #     super().merge(
      #       'declarations' => {
      #         'hosts' => {
      #           'hostblah' => {
      #             'parameters' => {
      #               'host_identifier' => {
      #                 'option_value' => 'REMOTEID12345679',
      #               },
      #             },
      #           },
      #         },
      #       },
      #     )
      #   end

      #   it { is_expected.to compile.and_raise_error(%r{if host-identifier specified, must contain an option and value}) }
      # end
      # context 'with host_identifier value missing' do
      #   let(:params) do
      #     super().merge(
      #       'declarations' => {
      #         'hosts' => {
      #           'hostblah' => {
      #             'parameters' => {
      #               'host-identifier' => {
      #                 'option_name' => 'agent.remote-id',
      #               },
      #             },
      #           },
      #         },
      #       },
      #     )
      #   end

      #   it { is_expected.to compile.and_raise_error(%r{if host_identifier specified, must contain an option and value}) }
      # end
    end
  end
end
