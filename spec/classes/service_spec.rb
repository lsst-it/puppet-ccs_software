# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:facts) do
    {
      hostname: 'comcam-mcm',
      path: '/bin',
    }
  end
  let(:node_params) { { 'site' => 'ls' } }

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
        is_expected.to contain_systemd__unit_file("#{svc}.service").with(
          content: %r{WorkingDirectory=/home/ccs},
        ).that_comes_before("Service[#{svc}]")
      end
      it do
        is_expected.to contain_service(svc).with(
          enable: true,
        )
      end
    end

    context 'with workdir parameter' do
      let(:params) do
        super().merge(service_workdir: '/foo/bar')
      end

      ['comcam-mcm'].each do |svc|
        it do
          is_expected.to contain_systemd__unit_file("#{svc}.service").with(
            content: %r{WorkingDirectory=/foo/bar},
          )
        end
      end
    end # with workdir parameter
  end # with services parameters
end
