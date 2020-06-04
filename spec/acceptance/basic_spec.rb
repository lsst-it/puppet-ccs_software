# frozen_string_literal: true

require 'spec_helper_acceptance'

describe 'ccs_software class' do
  context 'trivial case without installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> accounts::user { 'ccsadm': }
      -> class{ 'ccs_software':
        base_path => '#{basedir}',
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe file('/lsst') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to basedir }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe file('/etc/ccs') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'ccsadm' }
      it { is_expected.to be_grouped_into 'ccsadm' }
      it { is_expected.to be_mode '2775' }
    end

    ['logging.properties', 'ccsGlobal.properties', 'udp_ccs.properties'].each do |f|
      describe file("/etc/ccs/#{f}") do
        it { is_expected.to be_file }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
        it { is_expected.to be_mode '664' } # serverspec does not like a leading 0
      end
    end

    describe file('/var/log/ccs') do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'ccs' }
      it { is_expected.to be_mode '2775' }
    end

    [
      "#{basedir}/ccs",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    # package deps
    ['unzip', 'git'].each do |p|
      describe package(p) do
        it { is_expected.to be_installed }
      end
    end

    # jdk
    describe file('/usr/bin/java') do
      it { is_expected.to be_symlink }
      it { is_expected.to be_linked_to '/etc/alternatives/java' }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    describe package('jdk1.8') do
      it { is_expected.to be_installed }
    end
  end

  context 'with installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> accounts::user { 'ccsadm': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'comcam-mcm',
        env           => 'ComCam',
        installations => {
          master  => {},
          e4a8224 => {},
        },
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
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
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with complex installations' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> accounts::user { 'ccsadm': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        installations => {
          test1 => {
            repo_path => "#{basedir}/ccsadm/package-lists/test1.foo",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'e4a8224',
            env       => 'ComCam',
            hostname  => 'comcam-mcm',
          },
          test42 => {
            repo_path => "#{basedir}/ccsadm/package-lists/test42.bar",
            repo_url  => 'https://github.com/lsst-camera-dh/dev-package-lists',
            repo_ref  => 'e4a8224',
            env       => 'ComCam',
            hostname  => 'comcam-mcm',
          },
        },
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
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
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with aliases' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> accounts::user { 'ccsadm': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        env           => 'ComCam',
        hostname      => 'comcam-mcm',
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
    ].each do |f|
      describe file(f) do
        it { is_expected.to be_symlink }
        it { is_expected.to be_linked_to "#{basedir}/ccs/master" }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    [
      "#{basedir}/ccs/a",
      "#{basedir}/ccs/b",
      "#{basedir}/ccs/c",
    ].each do |f|
      describe file(f) do
        it { is_expected.to be_symlink }
        it { is_expected.to be_linked_to "#{basedir}/ccs/e4a8224" }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end
  end

  context 'with etc symlink' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> accounts::user { 'ccsadm': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'lsst-dc01',
        env           => 'IR2',
        installations => {
          '0b5328e' => {},
        },
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe file(basedir) do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'root' }
      it { is_expected.to be_grouped_into 'root' }
    end

    [
      "#{basedir}/ccs",
      "#{basedir}/ccs/0b5328e",
      "#{basedir}/ccs/0b5328e/bin",
      "#{basedir}/ccsadm",
      "#{basedir}/ccsadm/package-lists",
      "#{basedir}/ccsadm/package-lists/0b5328e",
      "#{basedir}/ccsadm/package-lists/0b5328e/.git",
      "#{basedir}/ccsadm/release",
    ].each do |dir|
      describe file(dir) do
        it { is_expected.to be_directory }
        it { is_expected.to be_owned_by 'ccsadm' }
        it { is_expected.to be_grouped_into 'ccsadm' }
      end
    end

    # symlink created by install.py
    describe file("#{basedir}/ccs/0b5328e/etc") do
      it { is_expected.to be_symlink }
      # link is relative
      it { is_expected.to be_linked_to 'ccs-test-configurations-master/IR2/lsst-dc01' }
      it { is_expected.to be_owned_by 'ccsadm' }
      it { is_expected.to be_grouped_into 'ccsadm' }
    end

    # symlink target dir
    describe file("#{basedir}/ccs/0b5328e/ccs-test-configurations-master/IR2/lsst-dc01") do
      it { is_expected.to be_directory }
      it { is_expected.to be_owned_by 'ccs' }
      it { is_expected.to be_grouped_into 'ccs' }
    end

    # file in chown'd etc dir
    describe file("#{basedir}/ccs/0b5328e/ccs-test-configurations-master/IR2/lsst-dc01/focal-plane_9raft_HardwareId.properties") do
      it { is_expected.to be_file }
      it { is_expected.to be_owned_by 'ccs' }
      it { is_expected.to be_grouped_into 'ccs' }
    end
  end

  context 'with services' do
    basedir = default.tmpdir('ccs')

    let(:pp) do
      <<-EOS
      accounts::user { 'ccs': }
      -> accounts::user { 'ccsadm': }
      -> class{ 'ccs_software':
        base_path     => '#{basedir}',
        hostname      => 'comcam-mcm',
        env           => 'ComCam',
        installations => {
          e4a8224 => {
            aliases => ['dev'],
          },
        },
        services      => {
          dev => ['comcam-mcm'],
        },
      }
      EOS
    end

    it_behaves_like 'an idempotent resource'

    describe service('comcam-mcm') do
      # does not work on el7
      # it { is_expected.to be_installed }
      it { is_expected.to be_enabled }
      it { is_expected.not_to be_running }
    end
  end
end
