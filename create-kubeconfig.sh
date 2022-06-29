SERVICEACCOUNT=posydon-ops
NAMESPACE=posydon-web

cat <<EOF | envsubst | kubectl create -f -
---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: $SERVICEACCOUNT
  namespace: $NAMESPACE
---
kind: Role
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: developer-access
  namespace: $NAMESPACE
rules:
- apiGroups: ["", "extensions", "apps"]
  resources: ["*"]
  verbs: ["*"]
- apiGroups: ["batch"]
  resources:
  - jobs
  - cronjobs
  verbs: ["*"]
---
kind: RoleBinding
apiVersion: rbac.authorization.k8s.io/v1
metadata:
  name: $SERVICEACCOUNT
  namespace: $NAMESPACE
subjects:
- kind: ServiceAccount
  name: $SERVICEACCOUNT
  namespace: $NAMESPACE
roleRef:
  apiGroup: rbac.authorization.k8s.io
  kind: Role
  name: developer-access
EOF

git clone https://github.com/devopstales/k8s_sec_lab.git

(
    cd k8s_sec_lab/kubernetes-scripts
    chmod +x create-kubeconfig.sh
    ./create-kubeconfig.sh $SERVICEACCOUNT -n $NAMESPACE > ../../kubeconfig-$NAMESPACE
)

kubectl --kubeconfig=kubeconfig-$NAMESPACE get po

