# DevOps-Experience
This repository has created to make experience in DevOps.


#### rediness probe
![image](https://github.com/user-attachments/assets/260e80ca-09ab-4633-b6e1-b6e6c2af23a8)

![image](https://github.com/user-attachments/assets/8b6a5fe4-ef92-45a5-b8e4-87400b00820f)

---

#### Logical Components Relationships (Tree)
![image](https://github.com/user-attachments/assets/78954156-3b38-4b14-8e2f-52e312f81c8c)

```sh
📦 Kubernetes Cluster
│
├── 📦 Deployments/
│   │
│   ├── 📦 deployment-pod/ (LABELS: app=app)
│   │   ├── 📄 Spec: replicas=1, image=hello:1.0
│   │   │
│   │   └── 📦 ReplicaSets/
│   │       └── 📦 deployment-pod-74b58fbbd5/ (HASH: 74b58fbbd5)
│   │           └── 📦 Pods/
│   │               └── 📦 deployment-pod-74b58fbbd5-skh2d/
│   │                   ├── 📄 Status: Running
│   │                   ├── 📄 IP: 10.244.0.25
│   │                   └── 📦 Containers/ (Act in port level, all containers shares the same pod Ip address but in different port) like cont1: 10.244.0.25:8080, cont2: 10.244.0.25:3000 and so on
│   │                       └── 📦 hello-container/
│   │                           └── 📄 Image: hello:1.0
│   │
│   └── 📦 hello-deploy-pod1/ (LABELS: app=hello-deploy-pod1)
│       ├── 📄 Spec: replicas=1, image=hello:1.0
│       │
│       └── 📦 ReplicaSets/
│           └── 📦 hello-deploy-pod1-6dd4d47c65/ (HASH: 6dd4d47c65)
│               └── 📦 Pods/
│                   └── 📦 hello-deploy-pod1-6dd4d47c65-x2fzw/
│                       ├── 📄 Status: Running
│                       ├── 📄 IP: 10.244.0.27
│                       └── 📦 Containers/
│                           └── 📦 hello/
│                               └── 📄 Image: hello:1.0
│
└── 📦 Standalone Pods/
    └── 📦 hello-pod/
        ├── 📄 Status: Running
        ├── 📄 IP: 10.244.0.26
        └── 📦 Containers/
            └── 📦 [unnamed]/
                └── 📄 Image: hello:1.0

```
