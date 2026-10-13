output "cluster_name" { value = module.eks.cluster_name }
output "cluster_autoscaler_role_arn" { value = module.cluster_autoscaler_irsa.iam_role_arn }
output "kubeconfig_command" {
  value = "aws eks update-kubeconfig --name ${module.eks.cluster_name} --region ${var.region}"
}
