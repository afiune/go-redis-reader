pkg_name=go-redis-reader
pkg_origin=afiune
pkg_description="An application that reads messages from a redis channel"
pkg_maintainer="Salim Afiune <afiune@chef.io>"
pkg_version="0.1.0"
pkg_bin_dirs=(bin)
pkg_deps=(core/glibc)
pkg_scaffolding=core/scaffolding-go
scaffolding_go_module=on
pkg_svc_run="go-redis-reader -c=${pkg_svc_config_path}/config.toml"
pkg_binds=(
  [cache]="port"
)
