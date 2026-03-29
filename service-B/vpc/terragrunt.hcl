include "root" {
  path = find_in_parent_folders("__shared__.hcl")
}

terraform {
  source = "git::https://github.com/leedonggyu-terraform-factory/terraform-resource-vpc.git?ref=0.0.5"
}

inputs = {

  common_attr = {
    name   = "eks"
    env    = "service-b"
    region = "ap-northeast-2"
  }

  vpc_attr = {
    cidr_block = "10.0.0.0/16"
    azs        = 2
    subnet_cidrs = {
      "webserver" : ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"],
      "was" : ["10.0.4.0/24", "10.0.5.0/24", "10.0.6.0/24"],
      "db" : ["10.0.7.0/24", "10.0.8.0/24", "10.0.9.0/24"]
    }
    is_nat = true
  }

  subnet_tags_attr = {
    "webserver" : {
      "Name" : "eks-prd-was"
      "Properties" : "webserver",
      "kubernetes.io/role/elb" = "1"
    },
    "was" : {
      "Properties" : "was",
      "karpenter.sh/discovery" = "hub",
      "kubernetes.io/role/internal-elb" = "1"
    },
    "db" : {
      "Properties" : "db"
    }
  }

  tag_attr = {
    Name = "service-b"
  }

  webserver_nacl_attr = {
    "ingress" : {
      "100" : {
        "protocol" : "tcp",
        "action" : "allow",
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 80,
        "to_port" : 80
      },
      "101" : {
        "protocol" : "tcp",
        "action" : "allow",
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 443,
        "to_port" : 443
      },
      "102" : {
        "protocol" : "-1",
        "action" : "allow",
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "to_port" : 0
      }
    },
    "egress" : {
      "100" : {
        "protocol" : "-1",
        "action" : "allow",
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "to_port" : 0
      },
    }
  }

  was_nacl_attr = {
    "ingress" : {
      "100" : {
        "protocol" : "-1",
        "action" : "allow",
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "to_port" : 0
      },
    },
    "egress" : {
      "100" : {
        "protocol" : "-1",
        "action" : "allow",
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "to_port" : 0
      },
    }
  }

  db_nacl_attr = {
    "ingress" : {
      "100" : {
        "protocol" : "tcp",
        "action" : "allow",
        "cidr_block" : "10.0.0.0/16",
        "from_port" : 3306,
        "to_port" : 3306
      },
      "101" : {
        "protocol" : "tcp",
        "action" : "allow",
        "cidr_block" : "10.0.0.0/16",
        "from_port" : 5432,
        "to_port" : 5432
      }
    },
    "egress" : {
      "100" : {
        "protocol" : "-1",
        "action" : "allow",
        "cidr_block" : "0.0.0.0/0",
        "from_port" : 0,
        "to_port" : 0
      }
    }
  }
}