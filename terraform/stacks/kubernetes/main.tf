# google_client_config si configurarile de kubernetes furnizate trebuie furnizate in in modul urmator
data "google_client_config" "default" {}

# data "google_service_account_key" "cloudsql-proxy-key2" {
#   service_account_id = "sql-proxy"
# }

provider "kubernetes" {
  host                   = "https://${module.gke.endpoint}"
  token                  = data.google_client_config.default.access_token
  cluster_ca_certificate = base64decode(module.gke.ca_certificate)
}

module "kubernetes-sa" {
  source = "../../modules/sa_kubernetes"

  org_id = var.org_id
}

module "gke" {
  depends_on = [
    module.kubernetes-sa
  ]

  source                     = "github.com/terraform-google-modules/terraform-google-kubernetes-engine.git"
  project_id                 = var.project_id
  name                       = "kubernetes-wordpress-licenta"
  region                     = "us-east1"
  zones                      = ["us-east1-b", "us-east1-c"]
  network                    = var.network_name
  subnetwork                 = "wp-live-kubernets-us-east1"
  ip_range_pods              = var.range_pods
  ip_range_services          = var.range_services
  http_load_balancing        = false
  network_policy             = false
  horizontal_pod_autoscaling = true
  filestore_csi_driver       = false

  node_pools = [
    {
      name                      = "wordpress-node-pool"
      machine_type              = "e2-medium"
      node_locations            = "us-east1-b,us-east1-c"
      min_count                 = 1
      max_count                 = 10
      local_ssd_count           = 0
      disk_size_gb              = 100
      disk_type                 = "pd-standard"
      image_type                = "COS_CONTAINERD"
      enable_gcfs               = false
      auto_repair               = true
      auto_upgrade              = true
      service_account           = var.serviceaccountgke
      preemptible               = false
      initial_node_count        = 2
    },
  ]

  node_pools_oauth_scopes = {
    all = []

    wordpress-node-pool = [
      "https://www.googleapis.com/auth/cloud-platform",
      "https://www.googleapis.com/auth/ndev.clouddns.readwrite",
    ]
  }

  # node_pools_labels = {
  #   all = {}

  #   default-node-pool = {
  #     default-node-pool = true
  #   }
  # }

  # node_pools_metadata = {
  #   all = {}

  #   default-node-pool = {
  #     node-pool-metadata-custom-value = "my-node-pool"
  #   }
  # }

  # node_pools_taints = {
  #   all = []

  #   default-node-pool = [
  #     {
  #       key    = "default-node-pool"
  #       value  = true
  #       effect = "PREFER_NO_SCHEDULE"
  #     },
  #   ]
  # }

  # node_pools_tags = {
  #   all = []

  #   default-node-pool = [
  #     "default-node-pool",
  #   ]
  # }
  


}

resource "null_resource" "nullremote1" {

  depends_on = [module.gke]
  provisioner "local-exec" {

    command = "gcloud container clusters get-credentials ${module.gke.name} --zone ${module.gke.region} --project wp-live-kubernets-6662"
    }
}

resource "kubernetes_persistent_volume_claim" "wordpressdisk" {
  depends_on = [module.gke]
  metadata {
    name = "wordpress-disk"
  }
  spec {
    access_modes = ["ReadWriteOnce"]
    resources {
      requests = {
        storage = "200Gi"
      }
    }
  }
}

# resource "null_resource" "generatesecretfromkey" {

#   depends_on = [null_resource.nullremote1]
#   provisioner "local-exec" {

#     command = "kubectl create secret generic cloudsql-db-credentials-terraform  --from-file ../secret/key.json"
#     }
# }

# resource "null_resource" "generatesecret-credentials" {

#   depends_on = [null_resource.nullremote1]
#   provisioner "local-exec" {

#     command = "kubectl create secret generic cloudsql-instance-credentials-terraform --from-literal username=wordpress --from-literal password=InfoIfrBacau"
#     }
# }

resource "kubernetes_secret" "cloudsql-db-credentials-terraform" {
  depends_on = [module.gke]

  metadata {
    name = "cloudsql-db-credentials-terraform"
  }
  data = {
    "username" = "wordpress"
    "password" = "InfoIfrBacau"
  }
}

resource "google_service_account_key" "cloudsql-proxy-key-test" {
  depends_on = [module.gke]
  service_account_id = "projects/wp-live-db-f946/serviceAccounts/wp-live-db-f946@wp-live-db-f946.iam.gserviceaccount.com"
}

resource "kubernetes_secret" "cloudsql-instance-credentials-terraform" {
  depends_on = [module.gke]
  metadata {
    name = "cloudsql-instance-credentials-terraform"
  }
  data = {
    "key.json" = base64decode(google_service_account_key.cloudsql-proxy-key-test.private_key)
  }
}


resource "kubernetes_deployment" "wordpress" {
  depends_on = [google_service_account_key.cloudsql-proxy-key-test]
  metadata {
    name = "wordpress-pod"
    labels = {
      App = "Wordpress-Gke"
    }
  }

  spec {
    replicas = 1
    selector {
      match_labels = {
        App = "Wordpress-Gke"
      }
    }
    template {
      metadata {
        labels = {
          App = "Wordpress-Gke"
        }
      }
      spec {
        container {
          image = "wordpress"
          name  = "wordpress-container"

          env {
            name  = "WORDPRESS_DB_HOST"
            value = "127.0.0.1:3306"
          }
          env {
            name  = "WORDPRESS_DB_USER"
            value_from {
                      secret_key_ref {
                          name = kubernetes_secret.cloudsql-db-credentials-terraform.metadata.0.name
                          key = "username"
                      }  
                  }
          }
          env {
            name = "WORDPRESS_DB_PASSWORD"
            value_from  {
                      secret_key_ref  {
                          name = kubernetes_secret.cloudsql-db-credentials-terraform.metadata.0.name
                          key = "password"
                      }  
                  }
          }
          env{
            name  = "WORDPRESS_DB_NAME"
            value = var.database
          }

          port {
            container_port = 80
          }

          volume_mount {
              mount_path = "/var/www/html"
              name       = "wordpress-disk"
            }

          resources {
            limits = {
              cpu    = "0.5"
              memory = "512Mi"
            }
            requests = {
              cpu    = "250m"
              memory = "50Mi"
            }
          }
        }

        container { 
            image = "gcr.io/cloudsql-docker/gce-proxy:1.11"
            name  = "cloudsql-proxy"
            #Aici adaugam key-ul care contine cheia de autentificare cu service account de sql-proxy
            command = ["/cloud_sql_proxy", 
            "-instances=wp-live-db-f946:us-east1:mysql-db=tcp:3306",
            "-credential_file=/secrets/cloudsql/key.json"]
            
            security_context {
                run_as_user = 2 
                allow_privilege_escalation = "false"
            }

            volume_mount {
                mount_path = "/secrets/cloudsql"
                name       = "cloudsql-instance-credentials-terraform"
                read_only  = "true"
            }

        }

            volume {
            name = "wordpress-disk"
            persistent_volume_claim {
              claim_name = "wordpress-disk"
            } 
        }
            volume {
            name = "cloudsql-instance-credentials-terraform"
            secret {
                secret_name = "cloudsql-instance-credentials-terraform"
            }
        }
      } 
    }
  }
}

resource "kubernetes_service" "wordpress-lb" {
  metadata {
    name = "wordpress-lb"
  }
  spec {
    selector = {
      App = kubernetes_deployment.wordpress.spec.0.template.0.metadata[0].labels.App
    }
    port {
      port        = 80
      target_port = 80
    }

    type = "LoadBalancer"
    load_balancer_ip = "34.148.46.204"
  }

  depends_on = [
    kubernetes_deployment.wordpress
  ]
}
