# Copyright (c) HashiCorp, Inc.
# SPDX-License-Identifier: MPL-2.0

job "payments-api" {
  datacenters = ["aws-us-east-1"]
  group "payments-api" {
    count = 2
    network {
      mode = "bridge"
      port "healthcheck" {
        to = -1
      }
    }
    service {
      name = "payments-api"
      tags = ["app"]
      port = "8080"
      check {
        name     = "payments-api-health"
        type     = "http"
        port     = "healthcheck"
        path     = "/actuator/health"
        interval = "10s"
        timeout  = "3s"
        expose   = true
      }
      connect {
        sidecar_service {
          proxy {
            upstreams {
              destination_name = "redis"
              local_bind_port  = 6379
            }
            upstreams {
              destination_name = "vault"
              local_bind_port  = 8200
            }
            upstreams {
              destination_name = "jaeger-http-collector"
              local_bind_port  = 14268
            }
            upstreams {
              destination_name = "zipkin-http-collector"
              local_bind_port  = 9411
            }
          }
        }
      }
    }
    task "payments-api" {
      driver = "docker"
      env {
        JAEGER_TAGS = "hostname=nomad"
      }
      config {
        image = "hashicorpdemoapp/payments:v0.0.14"
        mounts = [
          {
            type   = "bind"
            source = "local/bootstrap.yml"
            target = "/bootstrap.yml"
          },
          {
            type   = "bind"
            source = "local/application.properties"
            target = "/application.properties"
          }
        ]
      }
      vault {
        policies = ["payments"]
      }
      template {
        data = <<EOH
---
spring:
  cloud:
    vault:
      enabled: true
      fail-fast: true
      authentication: TOKEN
      token: ${VAULT_TOKEN}
      host: 127.0.0.1
      port: 8200
      scheme: http
        EOH
        destination = "local/bootstrap.yml"
      }
      template {
        data = <<EOH
app.storage=redis
app.encryption.enabled=true
app.encryption.path=transit
app.encryption.key=payments
spring.redis.host=127.0.0.1
spring.redis.port=6379
opentracing.jaeger.enable-b3-propagation=true
opentracing.jaeger.http-sender.url=http://127.0.0.1:14268/api/traces
opentracing.jaeger.include-jaeger-env-tags=true
        EOH
        destination = "local/application.properties"
      }
    }
  }
}
