# frozen_string_literal: true

require 'spec_helper'

desktop_files = %w[
  /etc/xdg/menus/applications-merged/lsst.menu
  /usr/share/desktop-directories/lsst.directory
  /usr/share/icons/lsst_appicon.png
  /usr/share/applications/lsst.ccs.console.prod.desktop
  /usr/share/applications/lsst.ccs.console.dev.desktop
  /usr/share/applications/lsst.ccs.shell.prod.desktop
  /usr/share/applications/lsst.ccs.shell.dev.desktop
]

describe 'ccs_software' do
  let(:facts) do
    {
      hostname: 'foo',
    }
  end

  describe 'with desktop parameter' do
    let(:params) do
      {
        desktop: true,
      }
    end

    it { is_expected.to compile.with_all_deps }

    desktop_files.each do |f|
      it do
        is_expected.to contain_file(f).with(
          ensure: 'file',
        )
      end
    end
  end

  describe 'without desktop parameter' do
    it { is_expected.to compile.with_all_deps }

    desktop_files.each do |f|
      it { is_expected.not_to contain_file(f) }
    end
  end
end
