resource "google_container_cluster" "drone" {
 name = "drone"
 zone = "us-west1-b"
 initial_node_count = 3

 additional_zones = [
 "us-west1-b"
 ]

 network = "vishal network"
 subnetwork = "vishal-space-west1"


 node_config {
 oauth_scopes = [
 "https://www.googleapis.com/auth/compute",
 "https://www.googleapis.com/auth/devstorage.read_only",
 "https://www.googleapis.com/auth/logging.write",
 "https://www.googleapis.com/auth/monitoring"
 ]

 machine_type = "g1-small"
 }
 }
