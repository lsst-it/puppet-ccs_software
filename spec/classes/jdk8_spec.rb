# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:facts) do
    {
      hostname: 'foo',
    }
  end

  describe 'without any parameters' do
    it { is_expected.to compile.with_all_deps }

    [
      'java',
      'javac',
      'javaws',
      'jar',
      'jconsole',
      'jstack',
    ].each do |cmd|
      it do
        dest = "/usr/java/jdk1.8.0_202-amd64/bin/#{cmd}"
        is_expected.to contain_alternative_entry(dest).with(
          ensure: 'present',
          priority: 1000,
        )
      end
    end
  end
end
