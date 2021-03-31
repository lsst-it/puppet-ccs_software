#
# @summary
#   Install /etc/ccs files.
#
# @api private
class ccs_software::config {
  assert_private()

  $etc_path = $ccs_software::etc_path

  ## Hash of templates and any arguments they take.
  $etc_files = {
    'logging.properties' => {},
    'ccsGlobal.properties' => {
      'global_properties' => lookup('ccs_software::global_properties', Array[String], 'unique', []),
    },
    'udp_ccs.properties' => {
      'hostname' => $trusted['certname'],
      'udp_properties' => lookup('ccs_software::udp_properties', Array[String], 'unique', []),
    },
  }

  $etc_files.each |$file, $epp_vars| {
    file { "${etc_path}/${file}":
      ensure  => file,
      owner   => $ccs_software::adm_user,
      group   => $ccs_software::adm_group,
      mode    => '0664',
      content => epp("${module_name}/config/${file}", $epp_vars),
    }
  }
}
