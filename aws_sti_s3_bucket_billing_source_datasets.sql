CREATE OR REPLACE STORAGE INTEGRATION aws_sti_s3_bucket_billing_source_datasets
  type = external_stage
  enabled = true
  storage_provider = 'S3'
  storage_aws_role_arn = 'arn:aws:iam::446384052121:role/sd-ml-snowflake-access-role-stg'
  storage_allowed_locations = ('s3://replica-s3-verisure-billing-gil-stg/')
  comment = 'Storage Integration from AWS central account PRE (446384052121) on s3 bucket replica-s3-verisure-billing-gil-stg';

GRANT USAGE ON integration aws_sti_s3_bucket_billing_source_datasets TO ROLE "AZ-SF-ADVANCED-ANALYTICS-GROUP-DEPLOYER";