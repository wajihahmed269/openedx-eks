data "oci_identity_availability_domains" "this" {
  compartment_id = var.compartment_ocid
}

resource "oci_containerengine_cluster" "this" {
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = var.name
  type               = var.cluster_type
  vcn_id             = var.vcn_id
  freeform_tags      = var.freeform_tags

  cluster_pod_network_options {
    cni_type = "FLANNEL_OVERLAY"
  }

  endpoint_config {
    is_public_ip_enabled = var.is_public_ip_enabled
    subnet_id            = var.public_subnet_ids[0]
  }

  options {
    service_lb_subnet_ids = var.public_subnet_ids

    add_ons {
      is_kubernetes_dashboard_enabled = false
    }

    kubernetes_network_config {
      pods_cidr     = var.pods_cidr
      services_cidr = var.services_cidr
    }
  }
}

resource "oci_containerengine_node_pool" "this" {
  cluster_id         = oci_containerengine_cluster.this.id
  compartment_id     = var.compartment_ocid
  kubernetes_version = var.kubernetes_version
  name               = "${var.name}-workers"
  node_shape         = var.node_shape
  freeform_tags      = var.freeform_tags

  node_config_details {
    size = var.node_pool_size

    placement_configs {
      availability_domain = data.oci_identity_availability_domains.this.availability_domains[0].name
      subnet_id           = var.private_subnet_ids[0]
    }
  }

  node_shape_config {
    memory_in_gbs = var.node_memory_in_gbs
    ocpus         = var.node_ocpus
  }

  dynamic "node_source_details" {
    for_each = var.node_image_id == null ? [] : [var.node_image_id]

    content {
      boot_volume_size_in_gbs = var.node_boot_volume_size_in_gbs
      image_id                = node_source_details.value
      source_type             = "IMAGE"
    }
  }

  initial_node_labels {
    key   = "workload"
    value = "openedx"
  }
}
