USE ROLE "AZ-SF-ADVANCED-ANALYTICS-GROUP-DEPLOYER";

CREATE OR REPLACE STAGE DB_ODS_BILLING.SH_STAGING.aws_stage_s3_bucket_billing_source_datasets
    URL = "s3://replica-s3-verisure-billing-gil-stg/"
    STORAGE_INTEGRATION = aws_sti_s3_bucket_billing_source_datasets;