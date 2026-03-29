include "root" {
    path = find_in_parent_folders("__shared__.hcl")
}

## input
dependency "input-vpc" {
    config_path = "${get_parent_terragrunt_dir()}/service-A/vpc"
}

## output
dependency "output-vpc" {
    config_path = "${get_parent_terragrunt_dir()}/service-B/vpc"
}

inputs = {
    inputVPC = dependency.input-vpc.outputs
    outputVPC = dependency.output-vpc.outputs
}