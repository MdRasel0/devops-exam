sudo hostnamectl set-hostname "k8smaster.example.net"
exec bash


sudo hostnamectl set-hostname "k8sworker1.example.net"   // 1st worker node

exec bash

 sudo swapoff -a
 sudo sed -i '/ swap / s/^\(.*\)$/#\1/g' /etc/fstab


sudo tee /etc/modules-load.d/containerd.conf <<EOF
overlay
br_netfilter
EOF
 sudo modprobe overlay
 sudo modprobe br_netfilter

sudo tee /etc/sysctl.d/kubernetes.conf <<EOT
net.bridge.bridge-nf-call-ip6tables = 1
net.bridge.bridge-nf-call-iptables = 1
net.ipv4.ip_forward = 1
EOT


sudo sysctl --system

sudo apt install -y curl gnupg2 software-properties-common apt-transport-https ca-certificates
sudo curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmour -o /etc/apt/trusted.gpg.d/docker.gpg
sudo add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable"

sudo apt update
sudo apt install -y containerd.io

 containerd config default | sudo tee /etc/containerd/config.toml >/dev/null 2>&1
 sudo sed -i 's/SystemdCgroup \= false/SystemdCgroup \= true/g' /etc/containerd/config.toml

 sudo systemctl restart containerd
 sudo systemctl enable containerd

 curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.28/deb/Release.key | sudo gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg

 echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.28/deb/ /' | sudo tee /etc/apt/sources.list.d/kubernetes.list

sudo apt update
sudo apt install -y kubelet kubeadm kubectl
sudo apt-mark hold kubelet kubeadm kubectl

sudo kubeadm init --control-plane-endpoint= IP

 mkdir -p $HOME/.kube
 sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
 sudo chown $(id -u):$(id -g) $HOME/.kube/config

 kubectl cluster-info
 kubectl get nodes


##Install Calico Network Plugin

kubectl apply -f https://raw.githubusercontent.com/projectcalico/calico/v3.26.0/manifests/calico.yaml


##Test Your Kubernetes Cluster Installation


kubectl create deployment nginx-app --image=nginx --replicas=2
kubectl expose deployment nginx-app --type=NodePort --port=80

kubectl get svc nginx-app
kubectl describe svc nginx-app