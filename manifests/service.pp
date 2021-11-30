#
# @summary
#   Manages ccs systemd service units
#
# @api private
class ccs_software::service {
  assert_private()

  $ccs_software::services.each |String $alias, Array[Variant[String, Hash]] $services| {

    $services.each |$svc| {
      if $svc =~ Hash {
        $service_name = $svc['name']
        $service_cmd = $svc['cmd']
      } else {
        $service_name = $svc
        $service_cmd = "${ccs_software::ccs_path}/${alias}/bin/${svc}"
      }
      $epp_vars = {
        desc    => "CCS ${service_name} service",
        user    => $ccs_software::user,
        group   => $ccs_software::group,
        cmd     => $service_cmd,
        workdir => $ccs_software::_real_service_workdir,
      }

      systemd::unit_file { "${service_name}.service":
        content => epp("${module_name}/service/ccs.service.epp", $epp_vars),
      }
      -> service { $service_name:
        enable => true,
      }

      $epp_sudo_vars = {
        service => $service_name,
        user    => $ccs_software::user,
      }

      sudo::conf { "ccs-service-${service_name}":
        content => epp("${module_name}/sudo/ccs.sudo.epp", $epp_sudo_vars),
      }
    }
  }

  $email_helper = 'systemd-email'

  file { "/usr/local/libexec/${email_helper}":
    ensure => file,
    owner  => 'root',
    group  => 'root',
    mode   => '0755',
    source => "puppet:///modules/${module_name}/service/${email_helper}",
  }

  $email_config = 'systemd-email'
  $email_service = 'status-email-user@.service'
  $envfile = "${ccs_software::etc_path}/${email_config}"

  systemd::unit_file { $email_service:
    content => epp("${module_name}/service/${email_service}.epp", {'envfile' => $envfile})
  }

  file { $envfile:
    ensure  => file,
    owner   => $ccs_sofware::adm_user,
    group   => $ccs_sofware::adm_group,
    mode    => '0644',
    content => epp("${module_name}/service/${email_config}", {'email' => $ccs_software::service_email}),
  }

}
