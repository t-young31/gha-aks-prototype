resource "azurerm_kubernetes_cluster" "sample" {
  name                = "cluster-${var.azure_suffix}"
  location            = azurerm_resource_group.aks.location
  resource_group_name = azurerm_resource_group.aks.name
  dns_prefix          = "dns-${var.azure_suffix}"

  identity {
    type = "SystemAssigned"
  }

  default_node_pool {
    name                = "agentpool"
    vm_size             = "Standard_B2s"
    enable_auto_scaling = true
    min_count           = 1
    max_count           = 2
  }

  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }

  api_server_access_profile {
    authorized_ip_ranges = ["${data.http.deployer_ip.response_body}/32"]
  }

  auto_scaler_profile {
    max_unready_nodes          = 1
    scale_down_delay_after_add = "1m"
  }
}

resource "local_sensitive_file" "kubeconfig" {
  filename = "${path.module}/../kubeconfig.yaml"
  content  = azurerm_kubernetes_cluster.sample.kube_config_raw
}
