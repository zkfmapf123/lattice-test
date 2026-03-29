include "root" {
    path = find_in_parent_folders("__shared__.hcl")
}

dependency "vpc" {
    config_path = "${get_parent_terragrunt_dir()}/service-A/vpc"
}

inputs = {
    vpc = dependency.vpc.outputs
}