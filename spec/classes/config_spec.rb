# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:node_params) { { 'site' => 'ls' } }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'without any parameters' do
        it { is_expected.to compile.with_all_deps }

        %w[
          logging.properties
          ccsGlobal.properties
          udp_ccs.properties
        ].each do |f|
          it do
            is_expected.to contain_file("/etc/ccs/#{f}").with(
              ensure: 'file',
              owner: 'ccsadm',
              group: 'ccsadm',
              mode: '0664'
            )
          end
        end
      end
    end
  end
end
