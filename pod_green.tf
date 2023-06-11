resource "kubernetes_pod" "myapp_green_pod_green" {
  provider = kubernetes.green
  metadata {
    name = "myapp-green-pod"
    labels = {
      app = "myapp-green"
    }
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx"
      port {
        container_port = 80
      }
      command = ["bash", "-c", "echo 'Welcome to the green version of My App!' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
    }
  }
}


resource "kubernetes_service" "myapp_green_service" {
  provider = kubernetes.green
  metadata {
    name = "myapp-green-service"
  }

  spec {
    selector = {
      app = "myapp-green"
    }

    port {
      protocol   = "TCP"
      port       = 80
    }
  }
}

resource "kubernetes_ingress_v1" "myapp_ingress_green" {
  provider = kubernetes.green
   metadata {
    name = "myapp-ingress-green"
    annotations = {
      "kubernetes.io/ingress.class" = "azure/application-gateway"
    }
  }
   spec {
      rule {
        host = "myapp.example.com"
        http {
         path {
           path = "/"
           backend {
             service {
               name = kubernetes_service.myapp_green_service.metadata[0].name
               port {
                 number = 80
               }
             }
           }
        }
      }
    }
  }
}