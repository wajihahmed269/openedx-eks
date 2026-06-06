region                  = "me-jeddah-1"
compartment_ocid        = "ocid1.compartment.oc1..aaaaaaaauzww5eknxu6fecvdm632udxfj5uug26yih3mb6uzsxfdchefoh7q"
oci_auth                = "SecurityToken"
oci_config_file_profile = "DEFAULT"

project_name = "openedx-oci"
environment  = "dev"

vcn_cidr                     = "10.20.0.0/16"
public_subnet_cidrs          = ["10.20.10.0/24"]
private_subnet_cidrs         = ["10.20.20.0/24"]
kubernetes_api_allowed_cidrs = ["202.47.51.242/32"]

kubernetes_version               = "v1.35.2"
oke_cluster_type                 = "BASIC_CLUSTER"
oke_api_endpoint_public          = true
oke_pods_cidr                    = "10.244.0.0/16"
oke_services_cidr                = "10.96.0.0/16"
oke_node_pool_size               = 1
oke_node_shape                   = "VM.Standard.E4.Flex"
oke_node_ocpus                   = 2
oke_node_memory_in_gbs           = 24
oke_node_boot_volume_size_in_gbs = 50
oke_node_image_id                = "ocid1.image.oc1.me-jeddah-1.aaaaaaaacl6fobnsv3n2nws5mshj6efri7typjlittpmnih45fm57ok7r7na"
