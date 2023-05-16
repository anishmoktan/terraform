environment_map = {
  #---------  DEV  ---------#
  dev : {
    aws_account_id : 123456789123
    domains : {
      anishmoktan : "dev.anishmoktan.com"
    },
    environment : "dev",
    region : "us-east-1",
    vpc_cidr : "10.100.0.0/16",
  },
  #---------  STAGING  ---------#
  staging : {
    aws_account_id : 123456789123
    domains : {
      anishmoktan : "staging.anishmoktan.com"
    },
    environment : "staging",
    region : "us-east-1",
    vpc_cidr : "10.200.0.0/16",
  },

  #---------  Prod  ---------#
  prod : {
    aws_account_id : 123456789123
    domains : {
      anishmoktan : "prod.anishmoktan.com"
    },
    environment : "prod",
    region : "us-east-1",
    vpc_cidr : "10.300.0.0/16",
  }
}
