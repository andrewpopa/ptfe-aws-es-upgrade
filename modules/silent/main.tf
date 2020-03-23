data "template_file" "user_data_script" {
  template = "${file("${path.module}/templates/user_data.sh.tpl")}"

  vars = {
    fqdn                       = var.fqdn
    dashboard_default_password = var.dashboard_default_password
    pg_dbname                  = var.pg_dbname
    pg_netloc                  = var.pg_netloc
    pg_port                    = var.pg_port
    pg_password                = var.pg_password
    pg_user                    = var.pg_user
    s3_bucket_svc              = var.s3_bucket_svc
    s3_region                  = var.s3_region
    s3_bucket_svc_snapshots    = var.s3_bucket_svc_snapshots
    tls_cert                   = var.tls_cert
    tls_key                    = var.tls_key
    settings_file              = var.settings_file
    license_file               = var.license_file
    s3_installation_bucket     = var.s3_installation_bucket
    docker_cli                 = var.docker_cli
    docker_ce                  = var.docker_ce
    containerd                 = var.containerd
    lib_dep                    = var.lib_dep
    airgap_installer           = var.airgap_installer
    airgap_binary              = var.airgap_binary
  }
}

resource "random_id" "silent" {
  keepers = {
    silent_template = data.template_file.user_data_script.rendered
  }
  byte_length = 8
}