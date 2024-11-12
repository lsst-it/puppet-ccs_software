# Changelog

All notable changes to this project will be documented in this file.
Each new release typically also includes the latest modulesync defaults.
These should not affect the functionality of the module.

## [v2.8.1](https://github.com/lsst-it/puppet-ccs_software/tree/v2.8.1) (2024-11-12)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.8.0...v2.8.1)

**Implemented enhancements:**

- Removed git status check from installCCS.sh [\#77](https://github.com/lsst-it/puppet-ccs_software/pull/77) ([mxturri](https://github.com/mxturri))

## [v2.8.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.8.0) (2024-10-24)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.7.0...v2.8.0)

**Implemented enhancements:**

- bump version constraint for saz/sudo to allow 9.0.0 [\#75](https://github.com/lsst-it/puppet-ccs_software/pull/75) ([badenerb](https://github.com/badenerb))

## [v2.7.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.7.0) (2024-09-04)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.6.0...v2.7.0)

**Implemented enhancements:**

- Add CCS desktops apps to default gnome favorites [\#69](https://github.com/lsst-it/puppet-ccs_software/pull/69) ([glennmorris](https://github.com/glennmorris))

## [v2.6.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.6.0) (2024-08-27)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.5.0...v2.6.0)

**Implemented enhancements:**

- Add option to install kafka-brokers properties files [\#67](https://github.com/lsst-it/puppet-ccs_software/pull/67) ([glennmorris](https://github.com/glennmorris))

## [v2.5.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.5.0) (2024-08-13)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.4.0...v2.5.0)

**Implemented enhancements:**

- Add new config file for influxDB [\#65](https://github.com/lsst-it/puppet-ccs_software/pull/65) ([glennmorris](https://github.com/glennmorris))

## [v2.4.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.4.0) (2024-08-07)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.3.0...v2.4.0)

**Implemented enhancements:**

- allow puppet/systemd 7.x [\#63](https://github.com/lsst-it/puppet-ccs_software/pull/63) ([jhoblitt](https://github.com/jhoblitt))

## [v2.3.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.3.0) (2024-07-05)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.2.2...v2.3.0)

**Implemented enhancements:**

- Allow control over the enable state of services [\#60](https://github.com/lsst-it/puppet-ccs_software/pull/60) ([glennmorris](https://github.com/glennmorris))
- Added code to cleanup dev-package-list clone after installation [\#59](https://github.com/lsst-it/puppet-ccs_software/pull/59) ([mxturri](https://github.com/mxturri))

## [v2.2.2](https://github.com/lsst-it/puppet-ccs_software/tree/v2.2.2) (2024-05-21)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.2.1...v2.2.2)

**Implemented enhancements:**

- \(files/install/installCCS.sh\) update CCS install script for use on summit [\#58](https://github.com/lsst-it/puppet-ccs_software/pull/58) ([glennmorris](https://github.com/glennmorris))
- \(puppet-ccs-software\) add license file [\#56](https://github.com/lsst-it/puppet-ccs_software/pull/56) ([dtapiacl](https://github.com/dtapiacl))

## [v2.2.1](https://github.com/lsst-it/puppet-ccs_software/tree/v2.2.1) (2024-03-19)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.2.0...v2.2.1)

**Breaking changes:**

- use stdlib::ensure\_packages\(\) and require stdlib \>= 9 [\#55](https://github.com/lsst-it/puppet-ccs_software/pull/55) ([jhoblitt](https://github.com/jhoblitt))

**Implemented enhancements:**

- Bump version to 2.2.1 [\#53](https://github.com/lsst-it/puppet-ccs_software/pull/53) ([glennmorris](https://github.com/glennmorris))
- Add wget as a required system package [\#52](https://github.com/lsst-it/puppet-ccs_software/pull/52) ([glennmorris](https://github.com/glennmorris))

## [v2.2.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.2.0) (2023-10-04)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.1.0...v2.2.0)

**Implemented enhancements:**

- allow puppet/systemd 6.x [\#50](https://github.com/lsst-it/puppet-ccs_software/pull/50) ([jhoblitt](https://github.com/jhoblitt))
- add almalinux 9 support [\#40](https://github.com/lsst-it/puppet-ccs_software/pull/40) ([jhoblitt](https://github.com/jhoblitt))

## [v2.1.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.1.0) (2023-08-22)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v2.0.0...v2.1.0)

**Implemented enhancements:**

- allow saz/sudo 8.x [\#48](https://github.com/lsst-it/puppet-ccs_software/pull/48) ([jhoblitt](https://github.com/jhoblitt))
- allow stdlib 9.x [\#46](https://github.com/lsst-it/puppet-ccs_software/pull/46) ([jhoblitt](https://github.com/jhoblitt))

## [v2.0.0](https://github.com/lsst-it/puppet-ccs_software/tree/v2.0.0) (2023-06-23)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.4.0...v2.0.0)

**Breaking changes:**

- \(plumbing\) drop support for puppet6 [\#37](https://github.com/lsst-it/puppet-ccs_software/pull/37) ([jhoblitt](https://github.com/jhoblitt))

**Implemented enhancements:**

- allow puppetlabs/vcsrepo 6.x [\#42](https://github.com/lsst-it/puppet-ccs_software/pull/42) ([jhoblitt](https://github.com/jhoblitt))
- add support for puppet8 [\#38](https://github.com/lsst-it/puppet-ccs_software/pull/38) ([jhoblitt](https://github.com/jhoblitt))
- \(sudo\) add 'reset-failed' to the commands ccs user can run [\#36](https://github.com/lsst-it/puppet-ccs_software/pull/36) ([glennmorris](https://github.com/glennmorris))

## [v1.4.0](https://github.com/lsst-it/puppet-ccs_software/tree/v1.4.0) (2023-04-17)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.3.0...v1.4.0)

**Implemented enhancements:**

- Extend the service hash to allow for more options [\#33](https://github.com/lsst-it/puppet-ccs_software/pull/33) ([glennmorris](https://github.com/glennmorris))

## [v1.3.0](https://github.com/lsst-it/puppet-ccs_software/tree/v1.3.0) (2023-03-06)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.2.1...v1.3.0)

**Implemented enhancements:**

- Switch to using python3 to run the install.py script [\#31](https://github.com/lsst-it/puppet-ccs_software/pull/31) ([glennmorris](https://github.com/glennmorris))

## [v1.2.1](https://github.com/lsst-it/puppet-ccs_software/tree/v1.2.1) (2023-01-31)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.2.0...v1.2.1)

**Fixed bugs:**

- fix .pmtignore rm'ing templates/log from release tarballs [\#30](https://github.com/lsst-it/puppet-ccs_software/pull/30) ([jhoblitt](https://github.com/jhoblitt))

## [v1.2.0](https://github.com/lsst-it/puppet-ccs_software/tree/v1.2.0) (2023-01-31)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.1.4...v1.2.0)

**Implemented enhancements:**

- normalize supported operating systems [\#28](https://github.com/lsst-it/puppet-ccs_software/pull/28) ([jhoblitt](https://github.com/jhoblitt))
- bump puppet/systemd to \< 5.0.0 [\#26](https://github.com/lsst-it/puppet-ccs_software/pull/26) ([jhoblitt](https://github.com/jhoblitt))

## [v1.1.4](https://github.com/lsst-it/puppet-ccs_software/tree/v1.1.4) (2022-11-01)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.1.3...v1.1.4)

**Merged pull requests:**

- Use remote persistency server, get rid of 6.0.4 full paths workaround [\#25](https://github.com/lsst-it/puppet-ccs_software/pull/25) ([tony-johnson](https://github.com/tony-johnson))

## [v1.1.3](https://github.com/lsst-it/puppet-ccs_software/tree/v1.1.3) (2022-08-17)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.1.2...v1.1.3)

**Merged pull requests:**

- release 1.1.3 [\#24](https://github.com/lsst-it/puppet-ccs_software/pull/24) ([jhoblitt](https://github.com/jhoblitt))

## [v1.1.2](https://github.com/lsst-it/puppet-ccs_software/tree/v1.1.2) (2022-08-17)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.1.1...v1.1.2)

**Merged pull requests:**

- release 1.1.2 [\#23](https://github.com/lsst-it/puppet-ccs_software/pull/23) ([jhoblitt](https://github.com/jhoblitt))

## [v1.1.1](https://github.com/lsst-it/puppet-ccs_software/tree/v1.1.1) (2022-08-17)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.1.0...v1.1.1)

**Merged pull requests:**

- release 1.1.1 [\#22](https://github.com/lsst-it/puppet-ccs_software/pull/22) ([jhoblitt](https://github.com/jhoblitt))
- modulesync 5.3.0 [\#21](https://github.com/lsst-it/puppet-ccs_software/pull/21) ([jhoblitt](https://github.com/jhoblitt))

## [v1.1.0](https://github.com/lsst-it/puppet-ccs_software/tree/v1.1.0) (2022-07-22)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.0.2...v1.1.0)

**Merged pull requests:**

- add EL8 support [\#20](https://github.com/lsst-it/puppet-ccs_software/pull/20) ([jhoblitt](https://github.com/jhoblitt))

## [v1.0.2](https://github.com/lsst-it/puppet-ccs_software/tree/v1.0.2) (2022-07-08)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.0.1...v1.0.2)

## [v1.0.1](https://github.com/lsst-it/puppet-ccs_software/tree/v1.0.1) (2022-02-21)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v1.0.0...v1.0.1)

**Merged pull requests:**

- Default to CCS remote configuration server [\#19](https://github.com/lsst-it/puppet-ccs_software/pull/19) ([glennmorris](https://github.com/glennmorris))

## [v1.0.0](https://github.com/lsst-it/puppet-ccs_software/tree/v1.0.0) (2022-02-01)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.8.0...v1.0.0)

**Merged pull requests:**

- update to ~ voxpupuli 5.1.0 plumbing [\#18](https://github.com/lsst-it/puppet-ccs_software/pull/18) ([jhoblitt](https://github.com/jhoblitt))

## [v0.8.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.8.0) (2021-11-30)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.7.0...v0.8.0)

**Merged pull requests:**

- Produce alert emails when a ccs systemd service fails [\#17](https://github.com/lsst-it/puppet-ccs_software/pull/17) ([glennmorris](https://github.com/glennmorris))
- Allow a service file to specify a custom ExecStart [\#16](https://github.com/lsst-it/puppet-ccs_software/pull/16) ([glennmorris](https://github.com/glennmorris))

## [v0.7.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.7.0) (2021-08-03)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.6.1...v0.7.0)

**Merged pull requests:**

- set org.hibernate.level=WARNING [\#15](https://github.com/lsst-it/puppet-ccs_software/pull/15) ([jhoblitt](https://github.com/jhoblitt))

## [v0.6.1](https://github.com/lsst-it/puppet-ccs_software/tree/v0.6.1) (2021-07-30)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.6.0...v0.6.1)

## [v0.6.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.6.0) (2021-07-29)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/sudo-0.1...v0.6.0)

**Merged pull requests:**

- Add a sudo file allowing the ccs user to control ccs services [\#14](https://github.com/lsst-it/puppet-ccs_software/pull/14) ([glennmorris](https://github.com/glennmorris))

## [sudo-0.1](https://github.com/lsst-it/puppet-ccs_software/tree/sudo-0.1) (2021-07-29)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.5.0...sudo-0.1)

## [v0.5.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.5.0) (2021-04-08)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/auxtel-0.3...v0.5.0)

**Merged pull requests:**

- It 2820 auxtel ccs [\#13](https://github.com/lsst-it/puppet-ccs_software/pull/13) ([glennmorris](https://github.com/glennmorris))

## [auxtel-0.3](https://github.com/lsst-it/puppet-ccs_software/tree/auxtel-0.3) (2021-04-06)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/auxtel-0.2...auxtel-0.3)

## [auxtel-0.2](https://github.com/lsst-it/puppet-ccs_software/tree/auxtel-0.2) (2021-03-31)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/auxtel-0.1...auxtel-0.2)

## [auxtel-0.1](https://github.com/lsst-it/puppet-ccs_software/tree/auxtel-0.1) (2021-03-30)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.4.2...auxtel-0.1)

## [v0.4.2](https://github.com/lsst-it/puppet-ccs_software/tree/v0.4.2) (2020-10-16)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.4.1...v0.4.2)

**Merged pull requests:**

- Add bash completion for the ccslog utility [\#12](https://github.com/lsst-it/puppet-ccs_software/pull/12) ([glennmorris](https://github.com/glennmorris))

## [v0.4.1](https://github.com/lsst-it/puppet-ccs_software/tree/v0.4.1) (2020-09-18)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.4.0...v0.4.1)

**Merged pull requests:**

- Install the /usr/local/bin/ccslog utility [\#11](https://github.com/lsst-it/puppet-ccs_software/pull/11) ([glennmorris](https://github.com/glennmorris))

## [v0.4.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.4.0) (2020-09-02)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.3.0...v0.4.0)

**Merged pull requests:**

- \[blacksmith\] Bump version to 0.4.0 [\#10](https://github.com/lsst-it/puppet-ccs_software/pull/10) ([jhoblitt](https://github.com/jhoblitt))
- add `WorkingDirectory` to all systemd service units [\#9](https://github.com/lsst-it/puppet-ccs_software/pull/9) ([jhoblitt](https://github.com/jhoblitt))
- sync puppet-lint plugins from lsst-it/lsst-itconf [\#8](https://github.com/lsst-it/puppet-ccs_software/pull/8) ([jhoblitt](https://github.com/jhoblitt))
- README fixes [\#7](https://github.com/lsst-it/puppet-ccs_software/pull/7) ([jhoblitt](https://github.com/jhoblitt))

## [v0.3.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.3.0) (2020-06-25)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.2.0...v0.3.0)

**Merged pull requests:**

- \[blacksmith\] Bump version to 0.3.0 [\#6](https://github.com/lsst-it/puppet-ccs_software/pull/6) ([jhoblitt](https://github.com/jhoblitt))
- add jgroups bufs + allow manual installs + git\_force param [\#5](https://github.com/lsst-it/puppet-ccs_software/pull/5) ([jhoblitt](https://github.com/jhoblitt))

## [v0.2.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.2.0) (2020-06-12)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.1.1...v0.2.0)

**Merged pull requests:**

- release v0.2.0 [\#4](https://github.com/lsst-it/puppet-ccs_software/pull/4) ([jhoblitt](https://github.com/jhoblitt))

## [v0.1.1](https://github.com/lsst-it/puppet-ccs_software/tree/v0.1.1) (2020-06-12)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/v0.1.0...v0.1.1)

**Merged pull requests:**

- release v0.1.1 [\#3](https://github.com/lsst-it/puppet-ccs_software/pull/3) ([jhoblitt](https://github.com/jhoblitt))
- change /var/log/ccs to 2777 [\#2](https://github.com/lsst-it/puppet-ccs_software/pull/2) ([jhoblitt](https://github.com/jhoblitt))

## [v0.1.0](https://github.com/lsst-it/puppet-ccs_software/tree/v0.1.0) (2020-06-10)

[Full Changelog](https://github.com/lsst-it/puppet-ccs_software/compare/fcbb3907a244b1d02f13fd8d9688983151b59f36...v0.1.0)

**Merged pull requests:**

- fwv [\#1](https://github.com/lsst-it/puppet-ccs_software/pull/1) ([jhoblitt](https://github.com/jhoblitt))



\* *This Changelog was automatically generated by [github_changelog_generator](https://github.com/github-changelog-generator/github-changelog-generator)*
