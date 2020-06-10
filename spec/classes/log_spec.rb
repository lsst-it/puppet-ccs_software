# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:facts) { { hostname: 'foo' } }
  let(:node_params) { { 'site' => 'ls' } }

  describe 'logs' do
    it { is_expected.to compile.with_all_deps }

    it do
      is_expected.to contain_file('/etc/cron.daily/ccs-log-compress').with(
        ensure: 'file',
        mode: '0755',
        owner: 'root',
        group: 'root',
        content: %r{archive_flag=n},
      )
    end
  end
end
