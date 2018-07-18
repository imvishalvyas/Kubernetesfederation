resource "google_container_cluster" "development" {
name = "development-systems"
zone = "europe-north1-a"
initial_node_count = 3

 additional_zones = [
    "europe-north1-b",
    "europe-north1-c",
  ]



node_config {
oauth_scopes = [
"https://www.googleapis.com/auth/compute",
"https://www.googleapis.com/auth/devstorage.read_only",
"https://www.googleapis.com/auth/logging.write",
"https://www.googleapis.com/auth/monitoring"
]
}
