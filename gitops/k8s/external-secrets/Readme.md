 install helm chart for the external secrets 

 helm repo add external-secrets https://charts.external-secrets.io

helm install external-secrets external-secrets/external-secrets -n external-secrets --create-namespace




Terraform
    |
    v
AWS Secrets Manager
(prod/database/credentials)
    |
    v
IRSA Role
    |
    v
External Secrets Operator
    |
    v
Kubernetes Secret
(db-secret)
    |
    v
Deployment
    |
    v
Container Environment Variables



flow to apply 

kubectl apply -f serviceaccount.yaml

kubectl apply -f secretstore.yaml

kubectl apply -f external-secret.yaml

k get secret 

