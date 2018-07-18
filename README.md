# Kubernetesfederation
this steps is to install and configure Kubernetes Federation with multi clusters.






Cluster Creation: it
will auto create instance in multi zone by below command with create
cluster. 









Asia
: 3 instance


asia-southeast1-a  -
1 instance 



Asia-southeast1-b  -
1 instance 



asia-southeast1-c  -
1 instance 















Europe
: 3 instance


europe-north1-a  - 1
instance 



europe-north1-b  - 1
instance 



europe-north1-c  - 1
instance 





















===Create global DNS Zone ======








gcloud dns
managed-zones create gfed --description "Kubernetes Federation
Zone" --dns-name devops.vishalvyas.com








gcloud dns
managed-zones describe gfed








=====================================================================




















Create Cluster in Asia,points kubectl to it, user to the cluster-admin role















gcloud container
clusters create asia --zone asia-southeast1-a --additional-zones
asia-southeast1-b,asia-southeast1-c --num-nodes
1 --scopes cloud-platform














gcloud container
clusters get-credentials asia --zone asia-southeast1-a














kubectl create
clusterrolebinding cluster-admin-binding --clusterrole cluster-admin
--user $(gcloud config get-value account)








=====================================================================






































CreateCluster in America,points kubectl to it, user to the cluster-admin role








gcloud container
clusters create europe --zone europe-north1-a --additional-zones
europe-north1-b,europe-north1-c --num-nodes 1 --scopes cloud-platform














gcloud container
clusters get-credentials europe --zone europe-north1-a














kubectl create
clusterrolebinding cluster-admin-binding --clusterrole cluster-admin
--user $(gcloud config get-value account)








=====================================================================


























Asia: rename default GKE cluster context to more representative names








kubectl config
set-context asia-context --cluster
gke_vishal-209706_asia-southeast1-a_asia --user
gke_vishal-209706_asia-southeast1-a_asia














kubectl config
delete-context gke_vishal-209706_asia-southeast1-a_asia








=====================================================================














Don’t forget to replace vishal-209706_us with your own GCP project id.














America: rename default GKE cluster context to more representative names














kubectl config
set-context europe-context --cluster gke_vishal-209706_europe-north1-a_europe --user gke_vishal-209706_europe-north1-a_europe








kubectl config delete-context gke_vishal-209706_europe-north1-a_europe








=====================================================================
































======================
To view and delete context
=========================














kubectl config get-contexts


kubectl config delete-context  global-context








=====================================================================


















































We now have everything in place to create a federated cluster








kubefed init global-context --host-cluster-context=europe-context --dns-zone-name="devops.vishalvyas.com." --dns-provider="google-clouddns"








...


…….


This step is the most crucial since it creates the federated control plane. After a few minutes, you should see the below output.








Creating a namespace federation-system for federation system components... done


Creating federation
control plane service.............. done


Creating federation
control plane objects (credentials, persistent volume claim)... done


Creating federation
component deployments... done


Updating
kubeconfig... done


Waiting for
federation control plane to come up..................... done


Federation API
server is running at: 35.202.187.107








=====================================================================




















Join all the clusters to the federated control plane.








kubefed --context=global-context join asia --cluster-context=asia-context --host-cluster-context=europe-context








kubefed --context=global-context join europe --cluster-context=europe-context --host-cluster-context=europe-context








Check Cluster :


kubectl --context=global-context get clusters








=====================================================================




















========Create Default name space ==========








kubectl --context=global-context create ns default








=====================================================================


























==================Time to download KUBEMCI===================








https://storage.googleapis.com/kubemci-release/release/latest/bin/linux/amd64/kubemci


chmod +x ./kubemci


sudo mv kubemci
/usr/local/bin








=====================================================================














=============Pass each cluster configuration to kubemci.==========








KUBECONFIG=$HOME/mcikubeconfig gcloud container clusters get-credentials asia --zone asia-southeast1-a --project vishal-209706








KUBECONFIG=$HOME/mcikubeconfig gcloud container clusters get-credentials europe --zone europe-north1-a --project vishal-209706








=====================================================================




















==========Create a static IP address for our global ingress======








gcloud compute addresses create g-ingress --global














=====================================================================














================To check global-context clusters================








kubectl --context=global-context get clusters








=====================================================================






































===Deploy Zone Printer to prints the details of the zone where it is being served==








Deploy:


kubectl --context=global-context create deployment zoneprinter --image=gcr.io/google-samples/zone-printer:0.1








Create Service :


kubectl --context=global-context create service nodeport zoneprinter --tcp=80:80 --node-port=30061








Scale Container :


kubectl --context=global-context scale deployment zoneprinter --replicas=4






















































































Create and run Ingress file to deploy zoneprinter








Vim ingress.yaml



apiVersion:
extensions/v1beta1


kind: Ingress


metadata:


  name: zoneprinter 
  



  annotations:


	kubernetes.io/ingress.global-static-ip-name:"k-ingress"


spec:


  backend:


	serviceName:
zoneprinter


	servicePort: 80








=================================








Run Ingress in global context :








kubectl --context=global-context create -f ingress.yaml








This single step
results in a series of configuration tasks involving the creation of
load balancers, firewall rules, health checks, and proxies.














Keep checking the
GCP Console for the health status. Once all the clusters are
registered with the ingress, it should show all the clusters as
healthy. Wait till you see 3/3 in the Healthy column of Backend
services section. It typically takes a few minutes for the health
check to pass.








Open ingress ip on
your browser : http://35.241.12.227/

























