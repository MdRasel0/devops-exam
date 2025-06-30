**Task 1: Provision a Kubernetes Cluster**
Cluster Setup
Master Node: k8smaster.example.com
Worker Nodes: k8sworker1.example.com, k8sworker2.example.com

<img width="531" alt="image" src="https://github.com/user-attachments/assets/7202f4d9-30f8-4071-abb0-b9d3c69accf2" />

Attched the kubeadm installation and join method on files.

**Persistent Storage**

PersistentVolume: demo-pv (2Gi)
PersistentVolumeClaim: demo-pvc
Both bound and functioning.

<img width="949" alt="image" src="https://github.com/user-attachments/assets/720c1da0-bdad-45fe-a6dc-96429f2ba90c" />


**Monitoring with Grafana & Prometheus
Deployed via Helm:**

helm repo add prometheus-community https://prometheus-community.github.io/helm-charts
helm install prometheus prometheus-community/kube-prometheus-stack

kubectl port-forward svc/monitoring-grafana 3000:80

<img width="1442" alt="image" src="https://github.com/user-attachments/assets/3f44d136-1ea3-4d7c-b20e-8dd469361d49" />


**Task 2: Optimize and Deploy a Docker Image**
Added docker files on git attachement

Docker Image Built & Pushed
Image Name: rasel009/devops-exam-app:v1
Docker Hub: rasel009/devops-exam-app


**Task 3: Deploy Application in Kubernetes**
Application Deployment
Deployment: 2 replicas across worker nodes
Node Affinity and Taints/Tolerations applied to ensure proper scheduling
Storage: 2Gi from demo-pvc


**Step 3.a: Setup Vault for Secrets**

vault auth enable kubernetes
vault write auth/kubernetes/config \
  token_reviewer_jwt="$(cat /var/run/secrets/kubernetes.io/serviceaccount/token)" \
  kubernetes_host="https://kubernetes.default.svc.cluster.local:443" \
  kubernetes_ca_cert=@/var/run/secrets/kubernetes.io/serviceaccount/ca.crt

# Create policy and role
vault policy write demo-app-policy - <<EOF
path "secret/data/demo-app" {
  capabilities = ["read"]
}
EOF

vault write auth/kubernetes/role/demo-app \
  bound_service_account_names=demo-app-sa \
  bound_service_account_namespaces=default \
  policies=demo-app-policy \
  ttl=24h

**Step 3.b: Create CloudNativePG Database**
kubectl apply -f https://raw.githubusercontent.com/cloudnative-pg/cloudnative-pg/release-1.21/releases/cnpg-1.21.0.yaml
<img width="572" alt="image" src="https://github.com/user-attachments/assets/acb97c74-0109-489d-878c-5ee88d75f4bf" />


**Step 3.c: Apply Taints and Tolerations**

kubectl taint nodes k8sworker1.convay.com app-tier=frontend:NoSchedule
kubectl taint nodes k8sworker2.convay.com app-tier=frontend:NoSchedule

<img width="517" alt="image" src="https://github.com/user-attachments/assets/4cf37cb6-77ba-466f-a1ea-21e2d195b8ed" />


**Step 3.d: Deploy Demo Application**

manifest is attached on git files

**Step 3.e: Setup Istio Ingress**

curl -L https://istio.io/downloadIstio | sh -
cd istio-*
sudo cp bin/istioctl /usr/local/bin/

# Verify istioctl can connect to cluster
istioctl version

# Install Istio with proper configuration
# Note: If you get Kubernetes version warning, it's safe to proceed
istioctl install --set values.defaultRevision=default -y

manifest is attched on git files

<img width="929" alt="image" src="https://github.com/user-attachments/assets/c8ca4567-dc93-47b4-a8b9-48385f22aa1b" />

**Step 3.f: Implement HPA (Horizontal Pod Autoscaler)**

kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml

**Task 4: Log & APM Management**

helm repo add grafana https://grafana.github.io/helm-charts
helm repo update

# Install Loki
helm install loki grafana/loki-stack \
  --namespace monitoring \
  --set grafana.enabled=false \
  --set prometheus.enabled=false \
  --set promtail.enabled=true

**Step 4.a: Install Grafana Tempo**

helm install tempo grafana/tempo \
  --namespace monitoring \
  --set tempo.retention=48h

**Step 4.b: Configure Application Logging**

<img width="715" alt="image" src="https://github.com/user-attachments/assets/94d5dccb-584c-4feb-9a16-c8e825b5488b" />



<img width="1177" alt="image" src="https://github.com/user-attachments/assets/773e3094-74c1-41ef-8725-863b44d59af9" />

