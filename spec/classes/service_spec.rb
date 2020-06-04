# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:facts) do
    {
      hostname: 'comcam-mcm',
      path: '/bin',
    }
  end

  describe 'with services parameters' do
    let(:params) do
      {
        env: 'ComCam',
        installations: {
          'e4a8224': {
            aliases: ['dev'],
          },
        },
        services: {
          dev: ['comcam-mcm'],
        },
      }
    end

    it { is_expected.to compile.with_all_deps }

    ['comcam-mcm'].each do |svc|
      it do
        is_expected.to contain_service(svc).with(
          enable: true,
        )
      end
    end
  end
end
