## 여러 서비스를 묶는 그룹
resource "aws_vpclattice_service_network" "common" {
  name      = "common"
  auth_type = "NONE"
}

############################################################################################################ Input
## endpoint 1개로 진행 - 만약 통신구간 많다면 여러개 만들어야 함 (input -> output)
resource "aws_vpclattice_service" "service-input" {
    name = "input-svc"
    auth_type = "NONE"
}

resource "aws_vpclattice_target_group" "service-input-tg" {
  name = "input-svc-tg"
  type = "INSTANCE"

  config {
    vpc_identifier = local.inputVPC.vpc_id
    
    port = 80
    protocol = "HTTP"
  }

}

resource "aws_vpclattice_target_group_attachment" "input-svc-attch" {
  target_group_identifier = aws_vpclattice_target_group.service-input-tg.id

  target {
    id = "i-01fd337dbc587431c"
  }
}

resource "aws_vpclattice_listener" "input-svc-listener" {
  name               = "input-svc-listener"
  protocol           = "HTTP"
  service_identifier = aws_vpclattice_service.service-input.id
  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.service-input-tg.id
        weight = 100
      }
    }
  }
}

resource "aws_vpclattice_service_network_service_association" "input-svc-assoc" {
  service_network_identifier = aws_vpclattice_service_network.common.id
  service_identifier         = aws_vpclattice_service.service-input.id
}

resource "aws_vpclattice_service_network_vpc_association" "input-svc-vpc-assoc" {
  service_network_identifier = aws_vpclattice_service_network.common.id
  vpc_identifier                     = local.inputVPC.vpc_id
}

############################################################################################################ Output
## endpoint 1개로 진행 - 만약 통신구가 많다면 여러개 만들어야 함 (output -> input)
resource "aws_vpclattice_service" "service-output" {
    name = "output-svc"
    auth_type = "NONE"
}

resource "aws_vpclattice_target_group" "service-output-tg" {
  name = "output-svc-tg"
  type = "INSTANCE"

  config {
    vpc_identifier = local.outputVPC.vpc_id
    
    port = 80
    protocol = "HTTP"
  }
}

resource "aws_vpclattice_target_group_attachment" "output-svc-attch" {
  target_group_identifier = aws_vpclattice_target_group.service-output-tg.id

  target {
    id = "i-0ab6379a1cc4392bb"
  }
}

resource "aws_vpclattice_listener" "outpu-svc-listener" {
  name               = "output-svc-listener"
  protocol           = "HTTP"
  service_identifier = aws_vpclattice_service.service-output.id
  default_action {
    forward {
      target_groups {
        target_group_identifier = aws_vpclattice_target_group.service-output-tg.id
        weight = 100
      }
    }
  }
}

resource "aws_vpclattice_service_network_service_association" "output-svc-assoc" {
  service_network_identifier = aws_vpclattice_service_network.common.id
  service_identifier         = aws_vpclattice_service.service-output.id
}

resource "aws_vpclattice_service_network_vpc_association" "output-svc-vpc-assoc" {
  service_network_identifier = aws_vpclattice_service_network.common.id
  vpc_identifier                     = local.outputVPC.vpc_id
}
  

output "input_svc_dns" {
  value = aws_vpclattice_service.service-input.dns_entry
}

output "output_svc_dns" {
  value = aws_vpclattice_service.service-output.dns_entry
}