job "demo-storage" {
  region = "global"
  datacenters = [
    "dc1"
  ]
  type = "service"
  constraint {
    distinct_hosts = true
  }
  update {
    stagger = "5s"
    max_parallel = 1
  }
  group "group" {
    count = 3
    task "app" {
      driver = "docker"
      artifact {
        source = "http://192.168.99.1:8080/downloads/elasticsearch-2.3.5.tar"
      }
      config {
        image = "elasticsearch:2.3.5"
        load = [
          "elasticsearch-2.3.5.tar"
        ]
        command = "elasticsearch"
        args = [
          "-Des.discovery.zen.minimum_master_nodes=1",
          "-Des.network.publish_host=${NOMAD_IP_http}",
          "-Des.discovery.zen.ping.unicast.hosts=192.168.99.101,192.168.99.102,192.168.99.103"
        ]
        port_map {
          http = 9200
          tcp = 9300
        }
      }
      service {
        name = "demo-storage"
        port = "http"
        check {
          type = "http"
          path = "/"
          interval = "10s"
          timeout = "2s"
        }
      }
      resources {
        cpu = 50
        memory = 128
        disk = 150
        network {
          mbits = 10
          port "http" {
            static = 9200
          }
          port "tcp" {
            static = 9300
          }
        }
      }
    }
  }
}