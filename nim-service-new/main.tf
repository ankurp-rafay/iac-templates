resource "kubernetes_namespace" "namespace" {
  #depends_on = [time_sleep.wait_2m_seconds]
  metadata {
    name = "${var.name}-ns"
  }
}

resource "kubernetes_secret" "ngc-docker-secret" {
  metadata {
    name = "${var.name}-ngc-secret"
    namespace            = resource.kubernetes_namespace.namespace.metadata[0].name
  }

  type = "kubernetes.io/dockerconfigjson"

  data = {
    ".dockerconfigjson" = jsonencode({
      auths = {
        "${var.registry_server}" = {
          "username" = var.registry_username
          "password" = var.ngc_api_key
          "auth"     = base64encode("${var.registry_username}:${var.ngc_api_key}")
        }
      }
    })
  }
}

resource "kubernetes_secret" "ngc-api-secret" {
  metadata {
    name = "${var.name}-ngc-api-secret"
    namespace            = resource.kubernetes_namespace.namespace.metadata[0].name
  }

  data = {
    NGC_API_KEY= "${var.ngc_api_key}"
  }

  type = "generic"
}

resource "kubernetes_manifest" "nim-service" {
  #depends_on = [time_sleep.wait_2m_seconds]
  manifest = yamldecode(templatefile("${path.module}/templates/nim-service.tftpl", {
    name              = var.name
    image             = [for v in var.model_info : v.image if v.name == var.model_name][0]
    image_tag         = [for v in var.model_info : v.tag if v.name == var.model_name][0]
    storage_size         = var.storage_size
    ngc_secret           = resource.kubernetes_secret.ngc-docker-secret.metadata[0].name
    ngc_api_secret       = resource.kubernetes_secret.ngc-api-secret.metadata[0].name
    storage_class_name   = var.storage_class_name
    num_gpus             = var.num_gpus
    ingress_host         = "${var.name}.${var.ingress_domain}"
    namespace            = resource.kubernetes_namespace.namespace.metadata[0].name
    cluster_issuer       = var.cluster_issuer
  }))
  wait {
    condition {
      type   = "Ready"
      status = "True"
    }
  }
  timeouts {
    create = "30m"
    update = "30m"
    delete = "30s"
  }
}

resource "aws_route53_record" "jupyter" {
  zone_id = var.route53_zone_id
  name    = "${var.name}.${var.ingress_domain}"
  type    = "A"
  ttl     = 300
  records = var.ingress_controller_ips
}
