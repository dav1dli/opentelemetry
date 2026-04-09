module "vnet" {
    source              = "../modules/vnet"
    resource_group_name = local.rg_name
    location            = var.location
    vnet_name           = local.vnet_name
    address_space       = var.vnet_address_space

    subnets = [
        {
          name : local.pep_subnet_name
          address_prefixes : var.pep_subnet_address_prefix
        },
  ]
}