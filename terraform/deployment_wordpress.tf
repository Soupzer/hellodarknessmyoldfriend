# Service
resource "kubernetes_service" "wordpress-svc" {
  metadata {
    name      = "wordpress-internal-service"
    namespace = "default"
  }
  spec {
    selector = {
      app   = "wordpress"
      scope = "frontend"
    }
    port {
      name      = "http"
      port      = 80
      protocol  = "TCP"
      node_port = 31000
    }
    type = "NodePort"
  }
}

# Peristent volume Claim
resource "kubernetes_persistent_volume_claim" "wordpress-pv-claim" {
  metadata {
    name      = "wp-pv-claim"
    namespace = "default"
    labels = {
      app = "wordpress"
    }
  }

  spec {
    resources {
      requests = {
        storage = "5Gi"
      }
    }
    access_modes = ["ReadWriteOnce"]
  }
}

#Deployment
resource "kubernetes_deployment" "wordpress-deploy" {
  metadata {
    name      = "wordpress"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app   = "wordpress"
        scope = "frontend"
      }
    }
    strategy {
      type = "Recreate"
    }
    template {
      metadata {
        labels = {
          app   = "wordpress"
          scope = "frontend"
        }
      }
      spec {
        container {
          image = "wordpress:latest"
          name  = "wordpress"
          port {
            container_port = 80
            name           = "wordpress"
          }
          resources {
            requests = {
              cpu    = "100m"
              memory = "200Mi"
            }
            limits = {
              cpu    = "100m"
              memory = "200Mi"
            }
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "mariadb-root-password"
                name = "laddition-secret"
              }
            }
          }
          env {
            name  = "WORDPRESS_DB_HOST"
            value = "mariadb-internal-service"
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value = "root"
          }
          volume_mount {
            mount_path = "/var/www/html"
            name       = "wordpress-vol"
          }
        }
        volume {
          name = "wordpress-vol"
          persistent_volume_claim {
            claim_name = "wp-pv-claim"
          }
        }
      }
    }
  }
}