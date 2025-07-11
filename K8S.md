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
##### below need focus :)
* taint & tolerance may face a problem if pod tolerated and node not tainted -> tolerated pod goes to that node if available. -> node need taint (if you notice this the go to solution)
* label & node affinity may face a problem if pod not affinited and node is labeled -> not affinited pod goes to that node if not affinited. -> pod need affinite (if you notice this the go to solution)
So the solution is to combine both (taint & tolerance && label & node affinity).
first:  taint & tolerance
then: label & node affinity


* edit deployment -> changes applied automatically if not pods failed . if failed remove failed pods




#### Label a node 
```sh
kubectl label nodes <node-name> <label-key>=<label-value>
```
* used by `nodeSelector` in ease use (if this do this) not (do this and do this if this)
* used by ... has these cababilities 


#### Schedule resources on container A
- resource request: minimum requirement to run a containerA (resource is guaranteed)
- limit: containerA don't suffocate other containers to make them in pending status.
- default which is none: containerA may suffocate other containers which is not ideal.
- ram: may exceeded but not constantly
- vcpu: no exceeded at all, equals to a thread in aws but azure,gcp equal to a core


##### behavior
###### 2 problems of setting limit
2. Ram exceeding/needing(suffocated)
1. cpu cycle needing(suffocated/not reserved).
###### benefit of setting a resource request
- resource is guaranteed as (minimum/recommended) requirement.

---

- no req + no limit = default
- no req + limit -> request=limit -> excceding could happen (no guarantee of pod termination because of constantly ram excceding) 
- req + limit -> we may need more cpu cycles for some reason if these are not reserved + ram exceeding problem
- req + no limit -> resource is guaranteed + consume as many cpu cycles as available even when containerA uses 95% of cpu cycles containerB in the other hand still works in minimum requirments without problems. [ideal solution but ensure that setting request resource to all node containers]

---

- LimitRange and ResourceQuotas are namespace level objects to control resources(cpu,ram). -> general and not pod-specified.

---

### Good for copy description to a new file
Note: use this if errors happend if you edit a resource object file 
```sh
:w newfile.yaml
```

### Search for rs for ds in doc
just edit kind to DaemonSet and remove replicas if needed
then deploy it in namespace you want
```sh
kubectl create -f ds.yaml -n kube-system 
```

#### Static pods
- know static pods by name and make sure by ownerReference properity command below
- look at the yaml format for this
```sh
kubectl get pod <podName> -n <nsName> -o yaml
```
* if Node -> is Static.
- know the path of the directory that holding the static pod definitions files by this file
```sh
cat /var/lib/kubelet/config.yaml
```
- looking for `staticPodPath` which points to that directory.
- create a static pod with command
```sh
kubectl run <podName> --image <imgName> --dry-run=client -o yaml --command -- sleep  1000  > fileName.yaml
```
- Don't place kubectl options after -- command option
- Move it to the directory that holding the static pod definitions files.
- You don't need to run the yaml file using kubectl just place it there kubelet will run it automatically as a static pod -> if you do you will get 2 pods on is static and another is not.
- mirror object is sent to api server so you can read that static pod but you can't write in it if you want go to static pod definition files dir.


### priority classes
- after setting pods to classes you can compare them based on priority via this command
```sh
kubectl get pods -o custom-columns="NAME:.metadata.name,PRIORITY:.spec.priorityClassName"
```

### Admission Controller
- To check default enabled admission controllers you have to get into container and checkout
-  `--` after this is considered as a shell commands after getting container access
-  this command shows you enabled and disabled admission plugins by default
```sh
 kubectl exec -it -n kube-system kube-apiserver-controlplane -- kube-apiserver -h | grep admission-plugins
```


### Web hooking
- You need a namespace for web server
```sh
kubectl create -n <nsName>
```
- You need to create a tls secret for secure webhook communication in the namespace this secret requires (private key and certificate).

- certifcation example below (.crt)
```sh
-----BEGIN CERTIFICATE-----
MIIDjjCCAnagAwIBAgIUWDW3Z5yroE2+GJSW5YDm7xnPjoAwDQYJKoZIhvcNAQEL
BQAwLzEtMCsGA1UEAwwkQWRtaXNzaW9uIENvbnRyb2xsZXIgV2ViaG9vayBEZW1v
IENBMB4XDTI1MDcxMTE1NTk1NFoXDTI1MDgxMDE1NTk1NFowKjEoMCYGA1UEAwwf
d2ViaG9vay1zZXJ2ZXIud2ViaG9vay1kZW1vLnN2YzCCASIwDQYJKoZIhvcNAQEB
BQADggEPADCCAQoCggEBAKHV9RvYg07ZV/2rhjDSjro8SnAK/6VNl1/ZAUadgRp+
SyR2m7Eb947VTPOBMrfVAePt4PJi2CqxSewVRYjNAC9mOuxueBDFnh3dCO77FvOE
+vqCr1Ia3Z2+Mq7QJapv0y8nn9yE4djTVzwnWBE/C2iEyNn+GEVEamJIJHZHnCFg
ZKD5cQ1RN+AtIcslxwmtLDwazCKhLn/jXbaS8pus9O3it42InV+jRM2NL8y6imNS
CY77h3xftIo/TxJp2aFL3+6dugPVzLOWVaYzHJ1DQf91mG0oENDTQI5iLG3AsSkE
/Dt6/fOg6E/uVv2JVGi8iAJ6BUeSeVuaTdYHwyQgsIUCAwEAAaOBpjCBozAJBgNV
HRMEAjAAMAsGA1UdDwQEAwIF4DAdBgNVHSUEFjAUBggrBgEFBQcDAgYIKwYBBQUH
AwEwKgYDVR0RBCMwIYIfd2ViaG9vay1zZXJ2ZXIud2ViaG9vay1kZW1vLnN2YzAd
BgNVHQ4EFgQU9qlHuukWIU8UQkzs5hHvBOKDTrwwHwYDVR0jBBgwFoAUf79MQ+zA
J8M3y9J8CygCpP0+XIUwDQYJKoZIhvcNAQELBQADggEBAIusmnwOuA9Lb80CDxLs
MK91CNhB5285gjDjKIcR4GhCMyphQr+UFFoD6Ecl4foF2CaxmHjwtb5B1GX0NYQI
vXG/rbIV6CLgBk4rTb1y+82Tm/3u3Hb3ObXVX5z9OPamhkelCLzNfa6HhXpCs9cw
r/3rfpiv1uoqw0SpBBwWkNVCWWefKDAoVdeN7IddAgud2jw75EPv/LAwv92IAx0y
hMI+U49WyBmd0zsQ0ufuurnFdJoaYe1FI7YDsHZ5gF5CVi3QrIVqwfXMlUcjZiDt
8ZgmbkAzR/EoJwQ1A6lEDVCugrM8RdouXVOzniYYuw7Xv9ndMNZlT4d/HzP1X4+0
6Qs=
-----END CERTIFICATE-----
```
- private key example below (.key)
```sh
-----BEGIN PRIVATE KEY-----
MIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQCh1fUb2INO2Vf9
q4Yw0o66PEpwCv+lTZdf2QFGnYEafkskdpuxG/eO1UzzgTK31QHj7eDyYtgqsUns
FUWIzQAvZjrsbngQxZ4d3Qju+xbzhPr6gq9SGt2dvjKu0CWqb9MvJ5/chOHY01c8
J1gRPwtohMjZ/hhFRGpiSCR2R5whYGSg+XENUTfgLSHLJccJrSw8GswioS5/4122
kvKbrPTt4reNiJ1fo0TNjS/MuopjUgmO+4d8X7SKP08SadmhS9/unboD1cyzllWm
MxydQ0H/dZhtKBDQ00COYixtwLEpBPw7ev3zoOhP7lb9iVRovIgCegVHknlbmk3W
B8MkILCFAgMBAAECggEAH7KUuNDCPTwgOiDxnlfrWSpMaSAaXOHy63TJRW+9lPcW
GCz8BydDaHA6S3preOqpXV+e/tKh5NDHOgybizUd22rSUTM85IoUU2SS5p3665UJ
BG560OHOtOIHMsq1iemvqy1/Z/WF985DKJbLLsuSnDTf0ySr08tX6+qV663QdI/I
vbIB3Wy+ZT/OsjwKjhepjEPCAuVVjf1S4Zd9Y/OyKciMacYLFYoE+meIEwKNiFKK
GFig1CKOdV12sRoCD/mO2G7W2oZmatuCmQLYO+WaH0rxbvnVvJu6487DMitP7AMg
jZqswa4FhkX/5SELSOUHgGh2o1SxNdUVGi3CCMrf8QKBgQC1qEo3rMnkclLh9Agd
++lCV58E3SV6Oh2mElCCSUiMydlqJgtszCSwB7PpWm8s4qjhnZ7BZ+NTFbFDiJ6M
nC7rSWgV1xgCa0nAYhyZY/zDrW+lE4CZ89QZRLvNzN5/Xa2pPsVUbyeGVdB8/B1S
98mVN4N4yHF1z5DIS0iuJxc6lQKBgQDkEQP+K8z/Rw7vrnTNg0nBvNmB56CKdaEV
bDiG9XqG38fIstn5jimYssCrmBwZJ1USIHwG2Kme5dm+mtY92SkBT0Yy3QbsmFgK
oM++PJ07fytJC0z58C2TuEiUhvTzFyP1VS87DaALTTSwRCTnWfAagbD4Ti5Uj+U5
ypGG2FASMQKBgGEofWmBtQnGS6YmSyEeVwfwrVCAp0bURn9IVF8aqv8CBpLLfljW
Ztjvhb5NbCDpqcHh98MhuWf6tjCUpZg3ALE/NbhYrrK8h1mqH/m6jLprzMbRw3qT
+uD47imIZYhhpjxbIleii9VBmJ0Aiv6RIPP6GQtEycplFd7KxTjAF6BxAoGAEy57
L31vmGjZkL8Tg9Vu9qRzhsF8dyi9i5e2iWNMEtvvaanhO2QBi549JjF864CrXwLs
a4b9fSfH0IglTL5e/IU2WkDMvElz3jD4R//BGafwdAxHRR42Nx5gvF09bNSdaZzo
hAb5Vvn/XHPexraBwzj1MW0h6GrR1LJ82uKGmYECgYEAn/PJWmMw6R6IybXvtx5V
W2/oFMMCY/P8NyDd8sZenpqvJ0MyftD5ULhRgChZ4qahBw1kddtozWwibBIxFN4j
5OOUfbM+124oVQVy7oBT/UvbC6Sx/CmxibuAsn2bcJxJwCKzDwQb1Zwaca970A9f
SzLbD3KJht5vNgG/8hLE8xA=
-----END PRIVATE KEY-----
```
  
