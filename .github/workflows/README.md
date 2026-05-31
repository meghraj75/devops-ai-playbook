Docker build
✅ Parallel builds using matrix
✅ Push to ECR
✅ Auto update Kubernetes manifests
✅ GitOps workflow with ArgoCD


GitHub Push / Manual Trigger
        ↓
GitHub Actions CI
        ↓
Build Docker Images
        ↓
Push Images to ECR
        ↓
Update Kubernetes YAML
        ↓
Push manifest changes to Git
        ↓
ArgoCD detects changes
        ↓
Deploys automatically to EKS