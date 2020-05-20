# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ccs_software class' do
  context 'trivial case without installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> class{ 'ccs_software':
        base_path => '#{basedir}',
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    [
      basedir,
      "#{basedir}/ccs",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
      end
    end
  end

  context 'with installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'comcam-fp01',
        env           => 'ComCam',
        installations => {
          master  => {},
          e4a8224 => {},
        },
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    [
      basedir,
      "#{basedir}/ccs",
      "#{basedir}/ccs/master",
      "#{basedir}/ccs/master/bin",
      "#{basedir}/ccs/e4a8224",
      "#{basedir}/ccs/e4a8224/bin",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/package-lists/master",
      "#{basedir}/ccsadm/package-lists/master/.git",
      "#{basedir}/ccsadm/package-lists/e4a8224",
      "#{basedir}/ccsadm/package-lists/e4a8224/.git",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
      end
    end
  end

  context 'with complex installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        installations => {
          test1 => {
            repo_path => "#{basedir}/ccsadm/package-lists/test1.foo",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'e4a8224',
            env       => 'ComCam',
            hostname  => 'comcam-fp01',
          },
          test42 => {
            repo_path => "#{basedir}/ccsadm/package-lists/test42.bar",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'e4a8224',
            env       => 'ComCam',
            hostname  => 'comcam-fp01',
          },
        },
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    [
      basedir,
      "#{basedir}/ccs",
      "#{basedir}/ccs/test1",
      "#{basedir}/ccs/test1/bin",
      "#{basedir}/ccs/test42",
      "#{basedir}/ccs/test42/bin",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/package-lists/test1.foo",
      "#{basedir}/ccsadm/package-lists/test1.foo/.git",
      "#{basedir}/ccsadm/package-lists/test42.bar",
      "#{basedir}/ccsadm/package-lists/test42.bar/.git",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
      end
    end
  end

  context 'with aliases' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        env           => 'ComCam',
        hostname      => 'comcam-fp01',
        installations => {
          master  => {
            aliases => ['foo', 'bar', 'baz'],
          },
          e4a8224 => {
            aliases => ['a', 'b', 'c'],
          },
        },
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    [
      "#{basedir}/ccs/foo",
      "#{basedir}/ccs/bar",
      "#{basedir}/ccs/baz",
      "#{basedir}/ccs/a",
      "#{basedir}/ccs/b",
      "#{basedir}/ccs/c",
    ].each do |f|
      describe file(f) do
        it { should be_symlink }
      end
    end
  end
end
