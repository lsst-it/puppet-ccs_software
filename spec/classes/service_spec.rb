# frozen_string_literal: true

require 'spec_helper'

describe 'ccs_software' do
  let(:node_params) { { 'site' => 'ls' } }

  on_supported_os.each do |os, facts|
    context "on #{os}" do
      let(:facts) do
        facts
      end

      describe 'with services parameters' do
        let(:params) do
          {
            env: 'ComCam',
            installations: {
              e4a8224: {
                aliases: ['dev'],
              },
            },
            services: {
              dev: ['comcam-mcm',
                    { name: 'comcam-ih',
                      user: 'ccs-ipa', }],
            },
          }
        end

        it { is_expected.to compile.with_all_deps }

        %w[comcam-mcm comcam-ih].each do |svc|
          it do
            is_expected.to contain_systemd__unit_file("#{svc}.service").with(
              content: %r{WorkingDirectory=/home/ccs}
            ).that_comes_before("Service[#{svc}]")
          end

          it do
            is_expected.to contain_service(svc).with(
              enable: true
            )
          end
        end

        ['comcam-ih'].each do |svc|
          it do
            is_expected.to contain_systemd__unit_file("#{svc}.service").with(
              content: %r{User=ccs-ipa}
            ).that_comes_before("Service[#{svc}]")
          end
        end

        context 'with workdir parameter' do
          let(:params) do
            super().merge(service_workdir: '/foo/bar')
          end

          ['comcam-mcm'].each do |svc|
            it do
              is_expected.to contain_systemd__unit_file("#{svc}.service").with(
                content: %r{WorkingDirectory=/foo/bar}
              )
            end
          end
        end
      end
    end
  end
end
