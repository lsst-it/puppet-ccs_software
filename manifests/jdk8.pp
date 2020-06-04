#
# @summary Install jdk8
#
# @param source
#   URL to JDK rpm
# @param package
#   String naming the package installed by the rpm; eg jdk1.8.
#   In older rpms, this had a version suffix, eg: jdk1.8.0_112
# @param dir
#   String giving the install directory in /usr/java; eg jdk1.8.0_251-amd64.
#   The -amd64 suffix is a semi-recent addition, eg
#   https://bugs.openjdk.java.net/browse/JDK-8202320
#   The ever-changing world of java rpms:
#   https://bugs.openjdk.java.net/browse/JDK-8202528
#   TODO this seems like something we should derive.
#
class ccs_software::jdk8 (
  Stdlib::HTTPUrl $source = 'https://github.com/frekele/oracle-java/releases/download/8u202-b08/jdk-8u202-linux-x64.rpm',
  String          $package = 'jdk1.8',
  String          $dir     = 'jdk1.8.0_202-amd64',
) {
  yum::install { $package:
    ensure  => present,
    source  => $source,
    timeout => 600,
  }

  $cmds = [
    'java',
    'javac',
    'javaws',
    'jar',
    'jconsole',
    'jstack',
  ]

  $cmds.each |$cmd| {
    $src = "/usr/bin/${cmd}"
    $dest = "/usr/java/${dir}/bin/${cmd}"

    alternative_entry { $dest:
      ensure   => present,
      altlink  => $src,
      altname  => $cmd,
      priority => 1000,
      require  => Yum::Install[$package],
    }
  }
}
