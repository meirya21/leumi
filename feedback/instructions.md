# Build and Deploy Flask app with full CI/CD # 
In this project we will use:
1.  Google cloud K8s cluster (some with helm)
2.  Github
3.  Docker & docker-compose
4.  Flask app
5.  Terraform
6.  Mongodb
7.  Nginx ingress controller (with TLS)
8.  EFK
9.  Grafana & Prometheus
10. Jenkins
11. ArgoCD

### Working Tree:
```
├── app
│   ├── app.py
│   ├── deploy
│   │   └── deployment.yaml
│   ├── Dockerfile
│   ├── e2e.py
│   ├── Jenkinsfile
│   ├── __pycache__
│   │   └── app.cpython-38.pyc
│   ├── requirements.txt
│   ├── static
│   │   ├── demo.css
│   │   ├── index.css
│   │   ├── style.css
│   │   └── thank.jpg
│   ├── templates
│   │   ├── feedback.html
│   │   ├── health.html
│   │   ├── index.html
│   │   └── retind.html
│   └── test.py
├── argo scerrnshot.png
├── docker-compose.yaml
├── Dockerfile
├── EFK
│   ├── elastic.yaml
│   ├── fluentd-daemonset-elasticsearch.yaml
│   └── kibana-values.yaml
├── feedback Diagram.png
├── ingress
│   ├── ingress.yaml
│   └── letsencrypt-prod.yaml
├── instructions.md
├── jenkins
│   ├── config.yml
│   ├── docker-compose.yml
│   ├── Dockerfile
│   ├── plugins.txt
│   └── users.env
├── mongo.yaml
├── prom
│   ├── promtail-values.yaml
│   └── values.yaml
├── README.md
├── run.sh
├── secret.yaml
└── terraform
    ├── main.tf
    ├── output.tf
    ├── provider.tf
    └── variable.tf
```

## To build the app localy:
Install docker and docker-compose first

    docker-compose up --build

That command will create 3 containers locally

### === DNS URI === 
Enter the website to create your own dns uri for use in this project:

https://www.noip.com/

### === Github repo === #
Upload your app code to github for future use

## 1. building the cluster in GCP: ##
Before you start using the gcloud CLI and Terraform, you have to install the Google Cloud SDK bundle.

You can find the official documentation on installing Google Cloud SDK here:
https://cloud.google.com/sdk/docs/install

Next, you need to link your account to the gcloud CLI, and you can do this with:

    gcloud init
    gcloud auth application-default login

Please pay attantion that when you are creating a project you need to copy the project id to the files listed bellow:
A. deployment.yaml (app/deploy folder)
B. Jenkinsfile (app folder)
C. Variable (terraform folder)

### Creating buckt (for tfstat file)
    gsutil mb -p {project-id} gs://{uniqe name}
    gcloud services enable storage.googleapis.com

When you are building a bucket you need uniqe name so give it a uniqe name then change the variable and provider name with the name you gave for the bucket.

First step is to provision a cluster using Terraform files located in terraform folder:

variables.tf - to define the parameters for the cluster.  (make sure that the names of the project id and the bucket are correct)

main.tf - to store the actual code for the cluster.

outputs.tf - to define the outputs.

provider.tf - define the cloud provider

Next use these commands to apply the files:

    terraform init
    terraform plane
    terraform apply

Note - it will take a few minutes to deploy

what happend?
Terraform created cluster in Gcloud and saved the state-file that was created to the bucket that created before

## 2. Connecting to the cluster:
    gcloud container clusters get-credentials feedback-prod --region europe-west1 --project {project-id}

Enable the Cloud Storage API:

    gcloud services enable storage.googleapis.com

## 3. creating Namespace:
    kubectl create namespace feedback
    kubectl create namespace argocd

You might get an error with the project premissions so just Run the following command in the gcloud CLI to add back the service account:

    PROJECT_NUMBER=$(gcloud projects describe "{project-id}" --format 'get(projectNumber)')
    gcloud projects add-iam-policy-binding {project-id} \
    --member "serviceAccount:service-{project-number}@container-engine-robot.iam.gserviceaccount.com" \
    --role roles/container.serviceAgent

## 4. create feedback secret:
in the feedback main folder run the command:

    kubectl apply -f secret.yaml

This wont deploy the the app but its importent for the connection between mongo and the app
Argocd will build the app inside the cluster
We will let jenkins do the build and push and argo to deploy

## 5. mongodb build
In the main folder:

    helm repo add bitnami https://charts.bitnami.com/bitnami
    
    helm install mongo -n feedback -f mongo.yaml bitnami/mongodb --version 12.1.13

## 6. ingress install:
# === SSH tutorial === #
https://www.youtube.com/watch?v=8X4u9sca3Io 

# === TLS tutorial === #
https://docs.bitnami.com/tutorials/secure-kubernetes-services-with-ingress-tls-letsencrypt

Before you installing ingress and cert-manger change the values in the yaml file so there will be a match between your host name etc.

In the ingress folder use these commands:

    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v1.2.0/deploy/static/provider/cloud/deploy.yaml

    kubectl apply -f ingress.yaml

    helm repo add jetstack https://charts.jetstack.io
    kubectl apply --validate=false -f https://github.com/jetstack/cert-manager/releases/download/v0.14.1/cert-manager.crds.yaml
    helm install cert-manager -n feedback jetstack/cert-manager --version v0.14.1
        wait a few minutes. . .
    kubectl apply -f letsencrypt-prod.yaml

## 7. Jenkins install
At first you should change the connection string in stage 1 so jenkins will be able to connect to your cluster
Second - push it to github
third - change the group id of docker (inside the dockerfile in jenkins folder) so it will be the same as your own 
you can find the GID with the 'getent group GID docker' command

As for Jenkins we will install it locally
inside the jenkins folder run these commands:

    docker volume create --name=jenkins_home
    docker volume create --name=jenkins_casc
    docker-compose up --build

that will build the jenkins container locally 

Note:
you may recive an error massage:

    jenkins  | touch: cannot touch '/var/jenkins_home/copy_reference_file.log': Permission denied
    jenkins  | Can not write to /var/jenkins_home/copy_reference_file.log. Wrong volume permissions?

if so - Just run the command:
    
    sudo chown -R 1000:1000 /data/jenkins

and then again the 'docker-compose up --build' command.

enter jenkins with the addres:
    localhost:8880

As you installd jenkins CasC you allready 

Its recommaned to restart after installtionhave the plugins needed for this project.
Also you will enter jenkins as admin but its recommend to create a new user

Terraform created service acount and gave a role to jenkins
Also it generate key named 'jenkinskey.json' and saved it to /data/jenkins folder
You need to add the key to jenkins - simply follow the instructions in the link:

    https://itnext.io/setup-jenkins-with-google-container-registry-2f8d39aaa27

## 8. building ARGOCD
### ArgoCD tutorial
https://argo-cd.readthedocs.io/en/stable/getting_started/

    kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

    kubectl patch svc argocd-server -n argocd -p '{"spec": {"type": "LoadBalancer"}}'

### Get Password
    kubectl -n argocd get secret argocd-initial-admin-secret -o jsonpath="{.data.password}" | base64 -d; echo

    Username: admin

### ArgoCD UI
    kubectl port-forward svc/argocd-server -n argocd 8080:443

## 9. building EFK in Kubernetes
Get inside the EFK folder and use these commands to install EFK:

    helm repo add elastic https://helm.elastic.co
    helm install elasticsearch -n feedback --version 7.17.3 elastic/elasticsearch -f elastic.yaml
wait for few minutes..

    helm repo add fluent https://fluent.github.io/helm-charts
    helm upgrade -i fluent-bit -n feedback fluent/fluent-bit -f fluentd-daemonset-elasticsearch.yaml
    helm install kibana -n feedback elastic/kibana -f kibana-values.yaml

Open Kibana dashboard via loadbalncer ip

## 10. Building Prom + grafana

Get inside the prom folder and follow these commands:

    helm repo add prometheus-community https://prometheus-community.github.io/helm-charts

    helm install prometheus -n feedback prometheus-community/kube-prometheus-stack --values values.yaml

to enter prometheus:

    kubectl port-forward -n feedback service/prometheus-kube-prometheus-prometheus 9090:9090

then enter

    localhost:9090

install grafana:

    helm repo add grafana https://grafana.github.io/helm-charts
    helm repo update
    helm upgrade --install promtail -n feedback grafana/promtail -f promtail-values.yaml
    helm upgrade --install loki -n feedback grafana/loki-distributed

to enter grafana:

    kubectl port-forward -n feedback service/prometheus-grafana 3000:80

http://localhost:3000

username: admin 
Password: prom-operator