
module "sms-scheduler" {
  source = "./modules/lambda"
  enable = true
  name   = format("%s-sms-scheduler", module.labels.id)

  aws_parameter_arns = [
    aws_ssm_parameter.sms_url.arn,
    aws_ssm_parameter.sms_region.arn,
    aws_ssm_parameter.sms_quiet_time.arn,
    aws_ssm_parameter.sms_scheduling.arn,
    aws_ssm_parameter.db_database.arn,
    aws_ssm_parameter.db_host.arn,
    aws_ssm_parameter.db_port.arn,
    aws_ssm_parameter.db_reader_host.arn,
    aws_ssm_parameter.db_ssl.arn,
    aws_ssm_parameter.time_zone.arn
  ]    
  aws_secret_arns    = [data.aws_secretsmanager_secret_version.rds_read_write.arn]
  config_var_prefix  = local.config_var_prefix
  handler            = "sms-scheduler.handler"
  kms_reader_arns    = [aws_kms_key.sqs.arn]
  layers             = lookup(var.lambda_custom_runtimes, "sms", "NOT-FOUND") == "NOT-FOUND" ? null : var.lambda_custom_runtimes["sms"].layers
  log_retention_days = var.logs_retention_days
  memory_size        = var.lambda_sms_memory_size
  runtime            = lookup(var.lambda_custom_runtimes, "sms", "NOT-FOUND") == "NOT-FOUND" ? var.lambda_default_runtime : var.lambda_custom_runtimes["sms"].runtime
  security_group_ids = [module.lambda_sg.id]
  subnet_ids         = module.vpc.private_subnets
  tags               = module.labels.tags
  timeout            = 180
}
