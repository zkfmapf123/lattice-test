variable "inputVPC" {}
variable "outputVPC" {}

locals {

  inputVPC = jsondecode(var.inputVPC)
  outputVPC = jsondecode(var.outputVPC)
}
