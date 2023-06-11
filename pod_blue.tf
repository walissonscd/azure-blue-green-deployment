resource "kubernetes_pod" "myapp_blue_pod_blue" {
  provider = kubernetes.blue
  metadata {
    name = "myapp-blue-pod"
    labels = {
      app = "myapp-blue"
    }
  }

  spec {
    container {
      name  = "nginx"
      image = "nginx"
      port {
        container_port = 80
      }
      command = ["bash", "-c", "echo 'Welcome to the Blue version of My App!' > /usr/share/nginx/html/index.html && nginx -g 'daemon off;'"]
    }
  }
}


resource "kubernetes_service" "myapp_blue_service" {
  provider = kubernetes.blue
  metadata {
    name = "myapp-blue-service"
  }

  spec {
    selector = {
      app = "myapp-blue"
    }

    port {
      protocol   = "TCP"
      port       = 80
    }
  }
}

resource "kubernetes_ingress_v1" "myapp_ingress_blue" {
  depends_on = [ kubernetes_ingress_v1.myapp_ingress_green ]
   
  provider = kubernetes.blue
   metadata {
    name = "myapp-ingress-blue"
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
               name = kubernetes_service.myapp_blue_service.metadata[0].name
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