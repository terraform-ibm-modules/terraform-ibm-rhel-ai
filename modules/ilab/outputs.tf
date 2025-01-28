##############################################################################
# Outputs
##############################################################################

output "model_url" {
    description = "URL to Open API docs to chat with model"
    value       = "https://${var.public_ip_address}:8443/docs"
}