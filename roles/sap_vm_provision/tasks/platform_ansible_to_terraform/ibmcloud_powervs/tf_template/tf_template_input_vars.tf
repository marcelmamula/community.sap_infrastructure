
# This file defines all Terraform Input Variables, with values to be provided interactively or using a vars file

locals {

  resource_group_create_boolean = var.ibmcloud_resource_group == "new" ? true : false

  ibmcloud_vpc_subnet_create_boolean = var.ibmcloud_vpc_subnet_name == "new" ? true : false

  ibmcloud_vpc_subnet_name_entry_is_ip = (
    can(
      regex("^(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\\.(25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)([/][0-3][0-2]?|[/][1-2][0-9]|[/][0-9])$",
        var.ibmcloud_vpc_subnet_name
      )
  ) ? true : false)

  #  ibmcloud_region = replace(var.ibmcloud_vpc_availability_zone, "/-[0-9]/", "")
  ibmcloud_region = replace(var.map_ibm_powervs_to_vpc_az[lower(var.ibmcloud_powervs_location)], "/-[0-9]/", "")

  # Ensure lowercase to avoid API case-sensitive errors such as "pcloudNetworksPostForbidden Code 403 Error crn regionZone WDC06 is not supported under the current region"
  ibmcloud_powervs_region = lower(var.map_ibm_powervs_location_to_powervs_region[lower(var.ibmcloud_powervs_location)])

}


variable "map_ibm_powervs_to_vpc_az" {

  description = "Map of IBM Power VS location to the colocated IBM Cloud VPC Infrastructure Availability Zone"

  type = map(any)

  default = {
    dal10    = "us-south-1"
    dal12    = "us-south-2"
    us-south = "us-south-3" // naming of IBM Power VS location 'us-south' was previous naming convention, would otherwise be 'dal13'
    us-east  = "us-east-1" // naming of IBM Power VS location 'us-east' was previous naming convention, would otherwise be 'wdc04'
    wdc06    = "us-east-2"
    wdc07    = "us-east-3"
    sao01    = "br-sao-1"
    sao02    = "br-sao-2"
    tor01    = "ca-tor-1"
    eu-de-1  = "eu-de-2" // naming of IBM Power VS location 'eu-de-1' was previous naming convention, would otherwise be 'fra04'
    eu-de-2  = "eu-de-3" // naming of IBM Power VS location 'eu-de-2' was previous naming convention, would otherwise be 'fra05'
    lon04    = "eu-gb-1"
    lon06    = "eu-gb-3"
    mad02    = "eu-es-1"
    mad04    = "eu-es-2"
    syd04    = "au-syd-2"
    syd05    = "au-syd-3"
    tok04    = "jp-tok-2"
    osa21    = "jp-osa-1"
  }

}


# IBM Cloud Regional API Endpoint = https://<<ibmcloud_region>>.cloud.ibm.com/
# IBM Power VS (on IBM Cloud) Regional API Endpoint = https://<<ibmpowervs_region>>.power-iaas.cloud.ibm.com/
variable "map_ibm_powervs_location_to_powervs_region" {

  description = "Map of IBM Power VS location to the secured IBM Power VS Region API Endpoints"

  type = map(any)

  default = {
    dal10    = "us-south"
    dal12    = "us-south"
    us-south = "us-south"
    us-east  = "us-east"
    wdc06    = "us-east"
    wdc07    = "us-east"
    sao01    = "sao"
    sao02    = "sao"
    tor01    = "tor"
    eu-de-1  = "eu-de"
    eu-de-2  = "eu-de"
    lon04    = "lon"
    lon06    = "lon"
    mad02    = "mad"
    mad04    = "mad"
    syd04    = "syd"
    syd05    = "syd"
    tok04    = "tok"
    osa21    = "osa"
  }

}


variable "ibmcloud_api_key" {
  description = "Enter your IBM Cloud API Key"
}

variable "resource_tags" {
  type        = list(string)
  description = "Tags applied to each resource created"
  default = [ "sap" ]
}

variable "sap_vm_provision_resource_prefix" {
  description = "Prefix to resource names"
}

variable "ibmcloud_resource_group" {
  description = "Enter existing/target Resource Group name, or enter 'new' to create a Resource Group using the defined prefix for all resources"
}

variable "ibmcloud_powervs_location" {
  description = "Target IBM Power VS location (e.g. lon06). Each location is colocated at a IBM Cloud VPC Infrastructure Availability Zone (e.g. eu-gb-3)"
}

#variable "ibmcloud_iam_yesno" {
#  description = "Please choose 'yes' or 'no' for setup of default IBM Cloud Identity and Access Management (IAM) controls, for use by technicians to view and edit resources of SAP Systems run on IBM Cloud (NOTE: Requires admin privileges on API Key)"
#}

variable "ibmcloud_vpc_subnet_name" {
  description = "Enter existing/target VPC Subnet name, or enter 'new' to create a VPC with a default VPC Address Prefix Range. If using an existing VPC Subnet, it must be attached to a Public Gateway (i.e. SNAT)"
}

variable "sap_vm_provision_dns_root_domain" {
  description = "Root Domain for Private DNS used with the Virtual Server"
}

variable "sap_vm_provision_bastion_os_image" {
  description = "Bastion OS Image. This variable uses the locals mapping with regex of OS Images, and will alter bastion provisioning."
}

variable "sap_vm_provision_bastion_user" {
  description = "OS User to create on Bastion host to avoid pass-through root user (e.g. bastionuser)"
}

variable "sap_vm_provision_bastion_ssh_port" {
  type        = number
  description = "Bastion host SSH Port from IANA Dynamic Ports range (49152 to 65535)"

  validation {
    condition     = var.sap_vm_provision_bastion_ssh_port > 49152 && var.sap_vm_provision_bastion_ssh_port < 65535
    error_message = "Bastion host SSH Port must fall within IANA Dynamic Ports range (49152 to 65535)."
  }
}


variable "sap_vm_provision_host_specification_plan" {
  description = "Host specification plans are xsmall_256gb. This variable uses the locals mapping with a nested list of host specifications, and will alter host provisioning."
}

variable "sap_vm_provision_ibmcloud_powervs_host_os_image" {
  description = "Host OS Image. This variable uses the locals mapping with regex of OS Images, and will alter host provisioning."
}

variable "sap_install_media_detect_source_directory" {
  description = "Mount point for downloads of SAP Software"

  validation {
    error_message = "Directory must start with forward slash."
    condition = can(regex("^/", var.sap_install_media_detect_source_directory))
  }

}



variable "sap_hana_install_instance_nr" {
  description = "Ansible - SAP HANA - Instance Number (e.g. 90)"

  validation {
    error_message = "Cannot use Instance Number 43 (HA port number) or 89 (Windows Remote Desktop Services)."
    condition = !can(regex("(43|89)", var.sap_hana_install_instance_nr))
  }

}

variable "sap_nwas_abap_ascs_instance_no" {
  description = "Ansible - SAP NetWeaver AS (ABAP) - ABAP Central Services (ASCS) instance number"

  validation {
    error_message = "Cannot use Instance Number 43 (HA port number) or 89 (Windows Remote Desktop Services)."
    condition = !can(regex("(43|89)", var.sap_nwas_abap_ascs_instance_no))
  }

}

variable "sap_nwas_abap_pas_instance_no" {
  description = "Ansible - SAP NetWeaver AS (ABAP) - Primary Application Server instance number"

  validation {
    error_message = "Cannot use Instance Number 43 (HA port number) or 89 (Windows Remote Desktop Services)."
    condition = !can(regex("(43|89)", var.sap_nwas_abap_pas_instance_no))
  }

}


variable "map_os_image_regex_bastion" {

  description = "Map of operating systems OS Image regex, to identify latest OS Image for the OS major.minor version"

  type = map(any)

  default = {

    rhel-8-8 = ".*redhat.*8-8.*minimal.*amd64.*"
    rhel-8-10 = ".*redhat.*8-10.*minimal.*amd64.*"
    rhel-9-2 = ".*redhat.*9-2.*minimal.*amd64.*"
    rhel-9-4 = ".*redhat.*9-4.*minimal.*amd64.*"

    sles-15-5 = ".*sles.*15-5.*amd64-[0-9]"
    sles-15-6 = ".*sles.*15-6.*amd64-[0-9]"

  }

}


variable "map_os_image_regex" {

  description = "Map of operating systems OS Image regex, to identify latest OS Image for the OS major.minor version"

  type = map(any)

  default = {

    # OS Image keys for IBM Power Virtual Server
    rhel-8-4-sap-ha = "RHEL8-SP4-SAP"
    rhel-8-4-sap-ha-byol = "RHEL8-SP4-SAP-BYOL"
    rhel-8-6-sap-ha = "RHEL8-SP6-SAP"
    rhel-8-6-sap-ha-byol = "RHEL8-SP6-SAP-BYOL"
    rhel-8-8-sap-ha = "RHEL8-SP8-SAP"
    rhel-8-8-sap-ha-byol = "RHEL8-SP8-SAP-BYOL"
    rhel-9-2-sap-ha = "RHEL9-SP2-SAP"
    rhel-9-2-sap-ha-byol = "RHEL9-SP2-SAP-BYOL"

    sles-15-2-sap-ha = "SLES15-SP2-SAP"
    sles-15-2-sap-ha-byol = "SLES15-SP2-SAP-BYOL"
    sles-15-3-sap-ha = "SLES15-SP3-SAP"
    sles-15-3-sap-ha-byol = "SLES15-SP3-SAP-BYOL"
    sles-15-4-sap-ha = "SLES15-SP4-SAP"
    sles-15-4-sap-ha-byol = "SLES15-SP4-SAP-BYOL"
    sles-15-5-sap-ha = "SLES15-SP5-SAP"
    sles-15-5-sap-ha-byol = "SLES15-SP5-SAP-BYOL"

  }

}

variable "map_host_specifications" {

  description = "Map of host specficiations for SAP HANA single node install"

  type = map(any)

  default = {

    small_256gb = {

      hana01 = { // Hostname
        ibmcloud_powervs_hardware_machine_type  = "e1080"
        virtual_server_profile = "ush1-4x256"
        // An IBM PowerVS host will be set to Tier 1 or Tier 3 storage type, and cannot use block storage volumes from both storage types
        // Therefore all block storage volumes are provisioned with Tier 1 (this cannot be changed once provisioned)
        // https://cloud.ibm.com/docs/power-iaas?topic=power-iaas-about-virtual-server#storage-tiers
        storage_definition = [
          {
            name = "hana_data"
            mountpoint = "/hana/data"
            disk_size = 384
            disk_type = "tier1"
            #disk_iops =
            filesystem_type = "xfs"
            #lvm_lv_name =
            #lvm_lv_stripes =
            #lvm_lv_stripe_size =
            #lvm_vg_name =
            #lvm_vg_options =
            #lvm_vg_physical_extent_size =
            #lvm_pv_device =
            #lvm_pv_options =
            #nfs_path =
            #nfs_server =
            #nfs_filesystem_type =
            #nfs_mount_options =
          },
          {
            name = "hana_log"
            mountpoint = "/hana/log"
            disk_size = 144
            disk_type = "tier1"
            filesystem_type = "xfs"
          },
          {
            name = "hana_shared"
            mountpoint = "/hana/shared"
            disk_size = 256
            disk_type = "tier1"
            filesystem_type = "xfs"
          },
          {
            name = "usr_sap"
            mountpoint = "/usr/sap"
            disk_size = 96
            disk_type = "tier1"
            filesystem_type = "xfs"
          },
          {
            name = "sapmnt"
            mountpoint = "/sapmnt"
            disk_size = 96
            disk_type = "tier1"
            filesystem_type = "xfs"
          },
          {
            name = "swap"
            mountpoint = "/swap"
            disk_size = 32
            disk_type = "tier1"
            filesystem_type = "swap"
          },
          {
            name = "software"
            mountpoint = "/software"
            disk_size = 100
            disk_type = "tier1"
            filesystem_type = "xfs"
          }
        ]
      }


    }
  }
}
