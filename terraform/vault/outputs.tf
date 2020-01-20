resource "local_file" "outputs" {
  content  = "ip: \"${azurerm_public_ip.azlb[0].ip_address}\""
  filename = "${path.module}/public_ip.yml"
}
