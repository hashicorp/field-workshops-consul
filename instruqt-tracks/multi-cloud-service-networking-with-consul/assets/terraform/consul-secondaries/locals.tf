locals {
  named_ports = [{
    name = "api"
    port = 8500
  }]
  health_check = {
    type                = "tcp"
    check_interval_sec  = 1
    healthy_threshold   = 4
    timeout_sec         = 1
    unhealthy_threshold = 5
    response            = ""
    proxy_header        = "NONE"
    port                = 8500
    port_name           = "health-check-port"
    request             = ""
    request_path        = "/"
    host                = "1.2.3.4"
  }
}
