#
# @summary
#   Manages ccs systemd service units
#
# @api private
class ccs_software::service {
  assert_private()

  $::ccs_software::services.each |String $alias, Array[String] $services| {
    $services.each |$svc| {
      $epp_vars = {
        desc  => "CCS ${svc} service",
        user  => $::ccs_software::user,
        group => $::ccs_software::group,
        cmd   => "/lsst/ccs/${alias}/bin/${svc}",
      }

      systemd::unit_file { "${svc}.service":
        content => epp("${module_name}/service/ccs.service.epp", $epp_vars),
      }
      ~> service { $svc:
        enable => true,
      }
    }
  }
}
