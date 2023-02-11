# Mariadb and Wordpress on K8S

Here is the terraform setup you will need to deploy a MariadBD and Wordpress in Kubernetes cluster 


## Terraform folder

In the terraform folder, there is 3 terraform files :
- One for the MariaDB statefulset deployment with service, secret, statefulset and configmap needed for the good deployment
- One for the Wordpress deployment with service, deployment and persistentVolumesClaim
- One with all the providers needed to load the infra in Minikube 

## How to make it works ? 

First we will assume that you have a minikube running in your compute, feel free to follow this doc, if not : [Click here](https://kubernetes.io/fr/docs/tasks/tools/install-minikube/)
Second,  you will need a good working terraform environment, if not : [Click here](https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli)
Third, you will have to change the provider.tf to make it fit with your environment

    kubectl config view
    #check for this line :     server: https://X.X.X.X:YYYY

If you have selft signed certificate you will have to give the path in the provider "kubernetes" and change the host by the line you got previously
## Deployment

    git clone git@github.com:Soupzer/hellodarknessmyoldfriend.git
    cd hellodarknessmyoldfriend/terraform
    
    terraform init -reconfigure
    terraform plan
    #check plan if there is no errors
    
    terraform apply
    #check apply if there is no errors
    
    #Kubernetes
    alias k=kubectl
    k get all --namespace=default #check if everything is up and ready
    minikube service wordpress-internal-service

    

## Kubernetes answers

**Requests and Limits :** 
- Limits and request has been according to the Minikube node configuration, by default Minikube will allow only 2Cpu and 1000Mi of memory. We can obviously increase this with some flags at the start of minikube. (We will assume that we only have this working space in our minikube cluster to let them free working, if not we will have to decrease the amount of cpu and memory allocated but mariaDb and BDD in general needs a minimum amount to work)

      Resource           Requests      Limits
      --------           --------      ------
      cpu                1450m (72%)   700m (35%)
      memory             1570Mi (74%)  1570Mi (74%)

**Pods amount :**
- To have a high disponibility of our MariaDB we have here 2 pods which are replicated in a Statefulset. Why Statefulset over Deployment, it's because it's more suitable for instances that have workloads and require persistent storage on each cluster node, such as databases. 
- To have also a high disponibility of our Wordpress frontend we have 2 pods. But, in minikube the Loadbalancer type in Service is not allowed so we could have had a single pod for this. In a perfect environment the 2 pods with Loadbalancing service is more suitable to split the requests not only on a single pod but on multiple to let them breath.

**Secret :** 
- A secret has been deployed in the Mariadb deployment because we don't want to have a not sensitive password in our configurations

