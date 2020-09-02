#
# @summary
#   Install /etc/ccs files.
#
# @api private
class ccs_software::config {
  assert_private()

  $etc_path = $ccs_software::etc_path

  $etc_files = [
    'logging.properties',
    'ccsGlobal.properties',
    'udp_ccs.properties',
  ]

  $epp_vars = {
    'hostname' => $trusted['certname'],
  }

  $etc_files.each |$file| {
    file { "${etc_path}/${file}":
      ensure  => file,
      owner   => $ccs_software::adm_user,
      group   => $ccs_software::adm_group,
      mode    => '0664',
      content => epp("${module_name}/config/${file}", $epp_vars),
    }
  }
}
