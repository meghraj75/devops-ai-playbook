output "secret_arn" {
  value = aws_secretsmanager_secret.this.arn
}
output "secret_name" {
  value = aws_secretsmanager_secret.this.name
}
output "irsa_role_arn" {
  value = aws_iam_role.irsa_role.arn
}
output "irsa_role_name" {
  value = aws_iam_role.irsa_role.name
}
