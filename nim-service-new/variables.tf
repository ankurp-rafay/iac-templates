variable "name" {}
variable "model_name" {}
variable "storage_size" {}
variable "storage_class_name" {}
variable "num_gpus" {
  default = 1
}
variable "ingress_domain" {}
variable "route53_zone_id" {}
variable "ingress_controller_ips" {}
variable "registry_server" {
  default = "nvcr.io"
}
variable "registry_username" {
  default = "$oauthtoken"
}
variable "ngc_api_key" {}

variable "cluster_issuer" {
  default = "demo-issuer"
}

variable "model_info" {
  type        = list(any)
  default = [
    {
      "name" : "Llama-3.1-8b-instruct",
      "image" : "nvcr.io/nim/meta/llama-3.1-8b-instruct",
      "tag": "1.3.3"
    },
    {
      "name" : "Llama-3.1-70b-instruct",
      "image" : "nvcr.io/nim/meta/llama-3.1-70b-instruct",
      "tag": "1.3.3"
    },
    {
      "name" : "Mistral-7B-Instruct-v0.3",
      "image" : "nvcr.io/nim/mistralai/mistral-7b-instruct-v0.3",
      "tag": "1.3.0"
    }
  ]
}
