# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:node_params) { { 'site' => 'ls' } }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'logs' do
        it { is_expected.to compile.with_all_deps }

        it do
          is_expected.to contain_file('/etc/cron.daily/ccs-log-compress').with(
            ensure: 'file',
            mode: '0755',
            owner: 'root',
            group: 'root',
            content: %r{archive_flag=n}
          )
        end
      end
    end
  end
end
