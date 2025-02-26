##############################################################################
# Outputs
##############################################################################

output "model_name" {
  description = "Name of the model based on value passed to bucket_name or repo"
  value       = local.l_model_name
}
