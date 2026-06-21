#!/bin/bash

REGION="us-east-1"

echo "========================================="
echo " AWS CLEANUP SCANNER - $REGION"
echo "========================================="

echo ""
echo "=== EC2 INSTANCES ==="
aws ec2 describe-instances --region $REGION --output table 2>/dev/null

echo ""
echo "=== EBS VOLUMES (CRITICAL) ==="
aws ec2 describe-volumes --region $REGION --output table 2>/dev/null

echo ""
echo "=== ELASTIC IPs ==="
aws ec2 describe-addresses --region $REGION --output table 2>/dev/null

echo ""
echo "=== NETWORK INTERFACES (EKS LEFTOVERS) ==="
aws ec2 describe-network-interfaces --region $REGION --output table 2>/dev/null

echo ""
echo "=== NAT GATEWAYS (HIGH COST) ==="
aws ec2 describe-nat-gateways --region $REGION --output table 2>/dev/null

echo ""
echo "=== LOAD BALANCERS ==="
aws elbv2 describe-load-balancers --region $REGION --output table 2>/dev/null

echo ""
echo "=== EKS CLUSTERS ==="
aws eks list-clusters --region $REGION --output table 2>/dev/null

echo ""
echo "=== ECR REPOSITORIES ==="
aws ecr describe-repositories --region $REGION --output table 2>/dev/null

echo ""
echo "=== SECRETS MANAGER ==="
aws secretsmanager list-secrets --region $REGION --output table 2>/dev/null

echo ""
echo "=== CLOUDWATCH LOG GROUPS ==="
aws logs describe-log-groups --region $REGION --output table 2>/dev/null

echo ""
echo "=== AUTO SCALING GROUPS ==="
aws autoscaling describe-auto-scaling-groups --region $REGION --output table 2>/dev/null

echo ""
echo "=== VPCs ==="
aws ec2 describe-vpcs --region $REGION --output table 2>/dev/null

echo ""
echo "========================================="
echo " SCAN COMPLETE - $REGION"
echo "========================================="