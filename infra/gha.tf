resource "kubernetes_namespace" "cert-manager" {
  metadata {
    name = "cert-manager"
  }
}

resource "null_resource" "install_certmanager_crds" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local_sensitive_file.kubeconfig.filename
    }
    command = "kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.12.0/cert-manager.crds.yaml"
  }
}

resource "helm_release" "cert-manager" {
  name       = "cert-manager"
  repository = "https://charts.jetstack.io/"
  chart      = "cert-manager"
  version    = "v1.12.0"
  namespace  = kubernetes_namespace.cert-manager.metadata[0].name
}

resource "kubernetes_namespace" "runner-ns" {
  metadata {
    name = "actions-runner-system"
  }
}

resource "kubernetes_secret" "runner-secret" {
  metadata {
    name      = "controller-manager"
    namespace = kubernetes_namespace.runner-ns.metadata[0].name
  }

  data = {
    github_token = var.gh_pat
  }

  type = "Opaque"
}

resource "helm_release" "arc" {
  name       = "arc"
  repository = "https://actions-runner-controller.github.io/actions-runner-controller"
  chart      = "actions-runner-controller"
  version    = "0.23.3"
  namespace  = kubernetes_namespace.runner-ns.metadata[0].name

  depends_on = [
    helm_release.cert-manager,
    kubernetes_secret.runner-secret
  ]
}

resource "kubernetes_namespace" "gha-ns" {
  metadata {
    name = "runners"
  }
}

resource "null_resource" "runner" {
  provisioner "local-exec" {
    environment = {
      KUBECONFIG = local_sensitive_file.kubeconfig.filename
    }
    command = "kubectl apply -f ${local_file.manifest.filename}"
  }

  depends_on = [helm_release.arc]
}

resource "local_file" "manifest" {
  filename = "manifest.yaml"
  content = templatefile("${path.module}/manifest.tmpl.yaml",
    {
      namespace  = kubernetes_namespace.gha-ns.metadata[0].name
      repository = var.gh_repository
    }
  )
}
