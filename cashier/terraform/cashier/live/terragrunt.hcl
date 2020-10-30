remote_state {
  backend = "s3"

  config = {
    bucket         = "${get_env("TF_VAR_aws_state_bucket", "tf-state_bucket")}"

    key            = "cashier/ecr/terraform.tfstate"
    region         = "${get_env("TF_VAR_aws_region","eu-west-3")}"
    encrypt        = true
    dynamodb_table = "${get_env("TF_VAR_aws_state_lock_name","tf-state-lock")}"
  }
}
