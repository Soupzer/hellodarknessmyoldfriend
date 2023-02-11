# Service
resource "kubernetes_service" "mariadb-svc" {
  metadata {
    name      = "mariadb-internal-service"
    namespace = "default"
  }
  spec {
    selector = {
      app = "mariadb"
    }
    port {
      name        = "http"
      port        = 3306
      protocol    = "TCP"
      target_port = 3306
    }
    cluster_ip = "None"
  }
}

resource "kubernetes_config_map" "mariadb-cm" {
  metadata {
    name      = "mariadb-configmap"
    namespace = "default"
  }

  data = {
    database_url = "mariadb-internal-service"
  }
}

# Secret
resource "kubernetes_secret" "mariadb-secret" {
  metadata {
    name      = "laddition-secret"
    namespace = "default"
  }
  data = {
    mariadb-root-password = "bGFkZGl0aW9u"
  }
  type = "Opaque"
}


resource "kubernetes_stateful_set" "mariadb-sts" {
  metadata {
    name      = "mariadb-sts"
    namespace = "default"
  }
  spec {
    replicas = 2
    selector {
      match_labels = {
        app = "mariadb"
      }
    }
    service_name = "mariadb"
    template {
      metadata {
        labels = {
          app = "mariadb"
        }
      }
      spec {
        container {
          image = "mariadb"
          name  = "mariadb"
          port {
            container_port = 3306
            name           = "dbport"
          }
          resources {
            requests = {
              cpu    = "250m"
              memory = "500Mi"
            }
            limits = {
              cpu    = "250m"
              memory = "500Mi"
            }
          }
          env {
            name = "MARIADB_ROOT_PASSWORD"
            value_from {
              secret_key_ref {
                key  = "mariadb-root-password"
                name = "laddition-secret"
              }
            }
          }
          env {
            name  = "MARIADB_DATABASE"
            value = "wordpress"
          }

          volume_mount {
            mount_path = "/var/lib/mysql"
            name       = "mariadb-data"
          }
        }
      }
    }
    volume_claim_template {
      metadata {
        name = "mariadb-data"
      }

      spec {
        access_modes       = ["ReadWriteOnce"]
        storage_class_name = "standard"

        resources {
          requests = {
            storage = "1Gi"
          }
        }
      }
    }

    # volume {
    #   name = "mariadb-vol"
    #   persistent_volume_claim {
    #     claim_name = "mariadb-pvc"
    #   }
    # }
  }
}