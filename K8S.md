# k8S
This Main repo for k8s.
---
vagrant up, ->(book) init, (fromHere-CommandFile) install cni on master node then (book) join workers. (goodluck)


---
##### Initlize Kubernetes using kubeadm

```sh
sudo kubeadm init --apiserver-advertise-address 10.0.0.10 --pod-network-cidr 192.168.0.1/16
```

##### Allow user interact with kubernetes cluster
```sh
mkdir -p $HOME/.kube
sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
sudo chown $(id -u):$(id -g) $HOME/.kube/config
```
##### Install CNI on master node
```sh
kubectl apply -f https://github.com/weaveworks/weave/releases/download/v2.8.1/weave-daemonset-k8s.yaml
```

##### CRI
```sh
```sh


sudo apt-get update
sudo apt-get install -y containerd

sudo systemctl start containerd
sudo systemctl enable containerd


containerd --version




```
#####  Get Token
```


---

```sh
kubeadm token -h
kubeadm token list

```

##### Get the CA cert hash
```sh
openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //'
```

##### Get the combination to join worker nodes into cluster
```sh
echo -e "\nkubeadm join $(hostname -I | awk '{print $1}'):6443 --token $(kubeadm token create) --discovery-token-ca-cert-hash sha256:$(openssl x509 -pubkey -in /etc/kubernetes/pki/ca.crt | openssl rsa -pubin -outform der 2>/dev/null | openssl dgst -sha256 -hex | sed 's/^.* //')"
```

##### example (not working only for testing)
```sh
sudo kubeadm join 10.0.2.15:6443 --token wsq7c1.4gemi4h4hp4ao0yn --discovery-token-ca-cert-hash sha256:bb26c4093de064eecd322694979a3e0ca276f475c6dd156598cc02179ca34afb
```
##### example 2 (worked in that case)
```sh
sudo kubeadm join 10.0.0.10:6443 --token b0qfkj.q5um3b77qlebsvju \
	--discovery-token-ca-cert-hash sha256:66bcbd41bc075363f4833a3ab70785a4df814778c0e05d993033596a48f99e9f 
```

#### Master Node Components / Get things from a thing
```sh
kubectl get namespaces
kubectl get pods -n kube-system -l tier=control-plane -o wide
kubectl get svc -n <namespaceName>
kubectl get all -n <namespaceName>
```

### info about node like CRI
```sh
kubectl get nodes -o wide 
```
### infor about pod like IPs
```sh
kubectl get pods -o wide
```

#### Real Time Monitoring
```sh
kubectl get events --watch
```

#### Monitor Pods Status in real time
```sh
kubectl get pods -w                      
```
#### App Logs
```sh
kubectl logs <podname>
kubectl logs startup
```

#### For both
##### Pods
```sh
kubectl run hello-pod1 --image docker.io/brainupgrade/hello:1.0
```
##### Pods (Deployment Type)
```sh
kubectl create deploy hello-deploy-pod1 --image docker.io/brainupgrade/hello:1.0
kubectl scale --replicas 3 deploy hello-deploy-pod1
kubectl describe deploy hello-deploy-pod1
kubectl set image deploy hello-deploy-pod1 hello=docker.io/brainupgrade/hello:2.0 # Rollout (update container image) make new replica contains updated images but old replica stills because if we want Rollback (undo)
kubectl rollout undo deploy hello-deploy-pod1
kubectl rollout undo deploy app --to-revision 1
```
#### Get info about deployments
```sh
kubectl get deployments -o wide
```

#### Get info about replicasets
```sh
kubectl get replicasets -o wide
```

#### Get info about specific deployment pod by label
```sh
 kubectl get all -l app=app
```

#### Get into container
```sh
 kubectl exec -it deployment-pod-74b58fbbd5-skh2d  -- sh
 kubectl exec -it deployment-pod-74b58fbbd5-skh2d  -- bash (if  possible)

```

#### Get all information you need then filter by label (cluster, nodes, deployments, replicas, pods)

* Note: if you filter by deploy label you will get it and down (replicas, pods)
* so: filter by label `d -get-> d,r,p`, filter by label `r/p -get-> r,p`
```sh
kubectl get node,all -o wide --show-labels
kubectl get all -l app=<LabelValue>
```

---

`Pod labels is the key connection between the Service and its Endpoints (Pod
replicas).`

#### Get info about services
```sh
 kubectl get services --all-namespaces
```

#### Full DNS URL - Services
```sh
<service-name>.<namespace>.svc.cluster.local:<port>
logger-srv.default.svc.cluster.local:80
```
Hint: tshoot curl would help for testing/troubleshooting


---
#### KIND
```sh
# 1. نزّل الملف أولاً
curl -o kind-config.yaml https://raw.githubusercontent.com/HussamQreie/Test-Files/main/yaml-files/KIND-MN-Cluster.yaml

# 2. تحقق من محتواه
cat kind-config.yaml

# 3. أنشئ الكلستر باستخدام الملف المحلي
kind create cluster --name mn-cluster --config kind-config.yaml
```


##### Load Balancer issue

###### Install MetalLB (Metal LoadBalancer -> LoadBalancer Controller
```sh
kubectl apply -f https://raw.githubusercontent.com/metallb/metallb/v0.13.7/config/manifests/metallb-native.yaml
```

###### Create a config file named `metallb-config.yaml` and add the MetalLB IP address pool 
```sh
apiVersion: metallb.io/v1beta1
kind: IPAddressPool
metadata:
  name: my-ip-pool
  namespace: metallb-system
spec:
  addresses:
  - 172.18.255.1-172.18.255.250  # Change to match your Docker network range

---
apiVersion: metallb.io/v1beta1
kind: L2Advertisement
metadata:
  name: my-l2-advert
  namespace: metallb-system

```
Note: do `docker network inspect kind | grep Subnet` to include ip range of this subnet

###### create the service to trigger LoadBalancer IP assignment
```sh
kubectl create svc loadbalancer hello --tcp=80:8080
kubectl get svc hello -o wide
```

##### service accessability (what i applied)
- ClusterIP: pods within cluster can access this service ClusterIP:32xxx(port)
- NodePort: pods within cluster can access this service via NodeIP:32xxx(port)
- LoadBalancer: Accessable via docker network (Out of cluster) ExternalIP:serviceport> like 80:8080 in this case 80.
- ExternalName: I haven't done it yet.

---

#### Rollout & Rollback

```sh
kubectl rollout status deployment/<deploymentName>
kubectl rollout history deployment/<deploymentName>
kubectl rollout undo deployment/<deploymentName>
```
Note: one pod is affected at a time in rollout (rollingupdate) strategy (v2,v3) jumping, but Recreate strategy the application went down (failure) for a specific time to wait app 
till getting up again. all deployment pods are affected at a time in Recreate strategy 




##### Get serviceurl
```sh
minikube service servicename --url
```

#### Namespaces
Goal: Isolate group of resources(pods, deploys, replicasets) from other resourses logically

###### create a namespace
```sh
kubectl create namespace <name>
kubectl create namespace dev
```

###### create a resource in another namespace use 
```sh
kubectl run pod1 --image nginx -n dev
same commands addtion to namespace option
```

##### access a resource from same namespace
use: resourcename
```sh
resourcename
mysql.connect("db-service)
```
##### access a resource from diff namespace 
use: full dns url

```sh
resourcename.namespace.resourcetype.cluster.local
mysql.connect("db-service.dev.svc.cluster.local")
```

###### Change your workenvironment without namespace option
```sh
kubectl config set-context $(kubectl config current-context) --namespace=dev
```
now you moved from default to dev namespace so you can  apply commands without namespace like
```sh
kubectl get pods
not
kubectl get pods -n dev
```
##### show everything in namespaces
```sh
kubectl get pods --all-namespaces
```


##### Update image in deployment
```sh
kubectl set image deployment deploymentname currentimage=updatedimage
kubectl set image deployment nginx nginx=nginx:1.18
```

#### Imperative commands
Create objects
```sh
kubectl create deploy nginx --image nginx
kubectl expose deploy nginx --port 80
```



Update objects
```sh
kubectl edit deploy nginx
kubectl scale deploy nginx --replicas 5
kubectl set image deployment nginx nginx=nginx:1.18
kubectl replace -f nginx.yaml # replace local yaml file with object file in kubernetes ensure `kubectl create -f file.yaml` to avoid getting error because how would you replace something is not exist :)
kubectl replace --force -f nginx.yaml # delete and recreate object file (diff a bit of above)
kubectl create -f nginx.yaml # fail! object file is already exist/created in kubernetes


Declarative (more smarter)
kubectl apply -f nginx.yaml # nginx image
kubectl apply -f nginx.yaml # this as update  will workds -> nginx 1.18 (updated)

```

#### Don't start from zero 
```sh
kubectl run bee --image nginx --dry-run=client -o yaml > bee.yaml
```
then and tolerations section in this case for ex.

* node(taint) - pod(toleration)
* node(label) - pod(affinity)

* edit deployment -> changes applied automatically if not pods failed . if failed remove failed pods




#### Label a node 
```sh
kubectl label nodes <node-name> <label-key>=<label-value>
```
* used by `nodeSelector` in ease use (if this do this) not (do this and do this if this)
* used by ... has these cababilities 
