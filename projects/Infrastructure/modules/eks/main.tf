//eks cluster role It is an IAM role assumed by the EKS control plane to interact with AWS services like EC2, VPC, and Load Balancers.

resource "aws_iam_role" "eks_cluster_role" {

  name = "eks-cluster-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"

    Statement = [
      {
        Effect = "Allow"

        Principal = {
          Service = "eks.amazonaws.com"
        }

        Action = "sts:AssumeRole"
      }
    ]
  })
}

//Attach an IAM policy to an IAM role.
# Now the role gets permissions to:
# manage EKS
# interact with EC2
# manage networking
# create load balancers
resource "aws_iam_role_policy_attachment" "eks_cluster_policy_attachment" {
role = aws_iam_role.eks_cluster_role.name
policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}


//create a Kubernetes cluster in Amazon Web Services
# AWS creates:
# ✅ Kubernetes API server
# ✅ etcd management
# ✅ scheduler
# ✅ controller manager
# AWS manages all these internally

//EKS cluster ≠ EC2 worker nodes.
//aws manage cluster you manage worker nodes and eks node group
resource "aws_eks_cluster" "eks" {
  name = var.cluster_name
  role_arn = aws_iam_role.eks_cluster_role.arn
  version = "1.34"

  vpc_config {
    subnet_ids = var.subnet_ids
    endpoint_private_access = false
    endpoint_public_access = true
  }
  depends_on = [ aws_iam_role_policy_attachment.eks_cluster_policy_attachment ]
}

# Fetches the TLS certificate from the EKS OIDC issuer URL for secure IAM OIDC provider configuration
#why it needed 
#Is this OIDC provider genuine
data "tls_certificate" "eks" {
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  
}

#creates an OIDC trust relationship between Amazon Web Services IAM and your EKS cluster.
resource "aws_iam_openid_connect_provider" "eks" {
  client_id_list =  ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks.certificates[0].sha1_fingerprint]
  url = aws_eks_cluster.eks.identity[0].oidc[0].issuer
  
}

#node group role
#Worker nodes need AWS permissions to:
#join EKS cluster
#pull Docker images from ECR
#communicate with EKS API
#manage pod networking
resource "aws_iam_role" "eks_node_role" {

  name="${var.cluster_name}-node-role"
  assume_role_policy = jsonencode({
   Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"  //Temporary permissions
    }]
  })
}


resource "aws_iam_role_policy_attachment" "worker_node_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
}

resource "aws_iam_role_policy_attachment" "cni_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
}

resource "aws_iam_role_policy_attachment" "ecr_policy" {
  role       = aws_iam_role.eks_node_role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
}

#node group 
## Node group provides EC2 worker nodes where Kubernetes pods and applications run

resource "aws_eks_node_group" "node_group" {
  cluster_name    = aws_eks_cluster.eks.name 
  node_group_name = var.node_group_name
  node_role_arn   = aws_iam_role.eks_node_role.arn
  subnet_ids      = var.subnet_ids

  instance_types = var.instance_types
  capacity_type  = var.capacity_type
  disk_size      = var.disk_size

  
  scaling_config {
    desired_size = var.desired_size
    min_size     = var.min_size
    max_size     = var.max_size
  }

//During node updates:
//only 1 node can be unavailable at a time
  update_config {
    max_unavailable = 1
  }

  tags = {
    Terraform   = "true"
  }
   depends_on = [
    aws_iam_role_policy_attachment.worker_node_policy,
    aws_iam_role_policy_attachment.cni_policy,
    aws_iam_role_policy_attachment.ecr_policy
  ]
}

# EBS Volume and policies for EKS Node Group
// This Terraform block creates an IAM trust policy document for the EBS CSI Kubernetes service account using IRSA.
data "aws_iam_policy_document" "ebs_csi_assume_role" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]

    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.eks.arn]
    }

    condition {
      test     = "StringEquals"
      variable = "${replace(aws_eks_cluster.eks.identity[0].oidc[0].issuer, "https://", "")}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
}

//creates an IAM role for the EBS CSI driver 
resource "aws_iam_role" "ebs_csi_irsa" {
  name               = "${var.cluster_name}-ebs-csi-irsa"
  assume_role_policy = data.aws_iam_policy_document.ebs_csi_assume_role.json
}

//and attaches the required AWS permissions policy.
resource "aws_iam_role_policy_attachment" "ebs_csi_irsa_policy" {
  role       = aws_iam_role.ebs_csi_irsa.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonEBSCSIDriverPolicy"
}
//installs the AWS EBS CSI Driver addon into your EKS cluster and connects it with the IAM role created using IRSA.
resource "aws_eks_addon" "ebs_csi" {
  cluster_name             = aws_eks_cluster.eks.name
  addon_name               = "aws-ebs-csi-driver"
  service_account_role_arn = aws_iam_role.ebs_csi_irsa.arn

  depends_on = [
  aws_iam_role_policy_attachment.ebs_csi_irsa_policy,
  aws_eks_node_group.node_group
]
}