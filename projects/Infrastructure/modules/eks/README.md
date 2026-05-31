
ebs_csi_assume_role
Kubernetes Pod
      ↓
Service Account
      ↓
OIDC Token
      ↓
AWS IAM verifies token
      ↓
IAM Role granted
      ↓
Pod accesses AWS APIs


installs the AWS EBS CSI Driver addon into your EKS cluster and connects it with the IAM role created using IRSA.
addon acts as bridge between:
Kubernetes
AWS EBS service

flow
Kubernetes PVC
       ↓
EBS CSI Driver
       ↓
IAM Role (IRSA)
       ↓
AWS EC2/EBS APIs
       ↓
EBS Volume Created

terraform init 
terraform plan 
terraform apply --auto-approve

update the cluster and we can access it directly command connects your local machine to your Amazon Web Services EKS Kubernetes cluster.
aws eks update-kubeconfig --region us-east-1 --name eks-cluster 