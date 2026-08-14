# Data sources for AWS account and region information
data "aws_caller_identity" "current" {}
data "aws_region" "current" {}


###############################################################################################

                          #      sf-pw-delta-audit

###############################################################################################


# Create the Step Function state machine
resource "aws_sfn_state_machine" "amcs_delta_audit" {
  name     = "pw-${var.env}-data-ingestion-sf"
  role_arn = var.step_function_role_arn

  definition = jsonencode({
    Comment = "AMCS to S3 Data Lake Ingestion Workflow with Auditing"
    StartAt = "audit-start"
    States = {
      "audit-start" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            workflowName = "sf-pw-delta-audit"
            "workflow_start_time.$" = "$$.State.EnteredTime"
            source_system = "AMCS"
            target_system = "S3"
            layer = "Raw"
            "ExecutionName.$" = "$$.Execution.Name"
          }
        }
        ResultPath = "$.auditStart"
        Next = "lambda-identify-unique-amcs-schemas"
      }
      "lambda-identify-unique-amcs-schemas" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.all_datasources_lambda_name
          "Payload.$" = "$"
        }
        ResultPath = "$"
        Next = "update-lambda-details"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath = "$.error"
            Next = "notify-failure"
          }
        ]
      }
      "update-lambda-details" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            lambda_function_name = var.all_datasources_lambda_name
            "ExecutionName.$" = "$$.Execution.Name"
            "schema_list.$" = "$.Payload.body.schemas"
          }
        }
        ResultPath = "$.lambdaInfo"
        Next = "map-process-amcs-schemas"
      }
      "map-process-amcs-schemas" = {
        Type = "Map"
        ItemsPath = "$.Payload.body.schemas"
        MaxConcurrency = 15
        Iterator = {
          StartAt = "ingest-amcs-s3-glue-job"
          States = {
            "ingest-amcs-s3-glue-job" = {
              Type = "Task"
              Resource = "arn:aws:states:::glue:startJobRun.sync"
              Parameters = {
                # JobName = var.amcs_incremental_job${success-notification-topic-arn}
                JobName = var.amcs-data-ingestion-glue_name
                Arguments = {
                  "--enable-glue-datacatalog" = "true"
                  "--job-language" = "python"
                  "--SCHEMA_NAME.$" = "$"
                  "--SNS_SUCCESS_TOPIC_ARN" = var.success-notification-topic-arn
                  "--SNS_FAILURE_TOPIC_ARN" = var.failure-notification-topic-arn
                }
              }
              End = true
            }
          }
        }
        Next = "GetSchemaCounts"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath = "$.error"
            Next = "notify-failure"
          }
        ]
      }
      "GetSchemaCounts" = {
        Type = "Task"
        Resource = var.audit_lambda_arn
        Parameters = {
          "Payload.$" = "$"
        }
        ResultPath = "$"
        Next = "update-gluejob-details"
      }
      "update-gluejob-details" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            gluejob_name = "pw-amcs-incremental-job"
            "ExecutionName.$" = "$$.Execution.Name"
            "schema_counts.$" = "$.body.counts"
            "time_taken_for_workflow_execution.$" = "$.body.time"
          }
        }
        Next = "audit-end"
      }
      "audit-end" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            "ExecutionName.$" = "$$.Execution.Name"
            "workflow_end_time.$" = "$$.State.EnteredTime"
            workflow_status = "SUCCESS"
          }
        }
        Next = "success-notification"
      }
      "success-notification" = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.success-notification-topic-arn
          Subject = "AMCS to S3 Data Lake Ingestion: Success"
          Message = "All AMCS schemas successfully ingested to S3 Data Lake"
        }
        End = true
      }
      "notify-failure" = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.failure-notification-topic-arn
          "Subject.$" = "States.Format('AMCS to S3 Data Lake Ingestion: Failure in {}', $.error.Error)"
          "Message.$" = "States.Format('An error occurred during the {} step: {}', $.error.Error, $.error.Cause)"
        }
        End = true
      }
    }
  })

  tags = var.tags
}



###############################################################################################

                          #      sf-pw-dossier-workflow

###############################################################################################


# Create the Step Function state machine for Dossier workflow
resource "aws_sfn_state_machine" "dossier_workflow" {
  # name     = "sf-pw-dossier-workflow"
  name     = "pw-${var.env}-dossier-workflow-sf"
  role_arn = var.step_function_role_arn

#    # Load the JSON definition from file and replace variables
#   definition = templatefile("${path.module}/JSONdefinition/dossier_workflow_definition.json", {
#     audit_lambda_name             = var.audit_lambda_name
#     all_datasources_lambda_name   = var.all_datasources_lambda_name
#     all_datasources_lambda_arn    = var.all_datasources_lambda_arn
#     glue_dossier_delta_load_job_name = var.glue_dossier_delta_load_job_name
#     dossier_success_topic_arn     = var.dossier_success_topic_arn
#     dossier_failure_topic_arn     = var.dossier_failure_topic_arn
#     amcs_data_ingestion_glue_name = var.amcs-data-ingestion-glue_name  # Note: You might need to fix the variable name syntax here
#   })

#   tags = var.tags

# }

  definition = jsonencode({
    Comment = "Dossier to S3 Data Lake Ingestion Workflow with Auditing"
    StartAt = "audit-start"
    States = {
      "audit-start" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            workflowName = "sf-pw-dossier-workflow"
            "workflow_start_time.$" = "$$.State.EnteredTime"
            source_system = "Dossier"
            target_system = "S3"
            layer = "Raw"
            "ExecutionName.$" = "$$.Execution.Name"
          }
        }
        ResultPath = "$.auditStart"
        Next = "lambda-identify-unique-dossier-schemas"
      }
      "lambda-identify-unique-dossier-schemas" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.all_datasources_lambda_name
          "Payload.$" = "$"
        }
        ResultPath = "$"
        Next = "update-lambda-details"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath = "$.error"
            Next = "notify-failure"
          }
        ]
      }
      "update-lambda-details" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            lambda_function_name = var.all_datasources_lambda_name
            "ExecutionName.$" = "$$.Execution.Name"
            "schema_list.$" = "$.Payload.body.schemas"
          }
        }
        ResultPath = "$.lambdaInfo"
        Next = "map-process-dossier-schemas"
      }
      "map-process-dossier-schemas" = {
        Type = "Map"
        ItemsPath = "$.Payload.body.schemas"
        MaxConcurrency = 30
        Iterator = {
          StartAt = "ingest-dossier-s3-glue-job"
          States = {
            "ingest-dossier-s3-glue-job" = {
              Type = "Task"
              Resource = "arn:aws:states:::glue:startJobRun.sync"
              Parameters = {
                JobName = var.glue_dossier_delta_load_job_name
                Arguments = {
                  "--enable-glue-datacatalog" = "true"
                  "--job-language" = "python"
                  "--SCHEMA_NAME.$" = "$"
                  "--SNS_SUCCESS_TOPIC_ARN" = var.dossier_success_topic_arn
                  "--SNS_FAILURE_TOPIC_ARN" = var.dossier_failure_topic_arn
                }
              }
              End = true
            }
          }
        }
        Next = "GetSchemaCounts"
        Catch = [
          {
            ErrorEquals = ["States.ALL"]
            ResultPath = "$.error"
            Next = "notify-failure"
          }
        ]
      }
      "GetSchemaCounts" = {
        Type = "Task"
        Resource = var.all_datasources_lambda_arn
        Parameters = {
          "Payload.$" = "$"
        }
        ResultPath = "$"
        Next = "update-gluejob-details"
      }
      "update-gluejob-details" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            gluejob_name = var.amcs-data-ingestion-glue_name
            "ExecutionName.$" = "$$.Execution.Name"
            "schema_counts.$" = "$.body.counts"
            "time_taken_for_workflow_execution.$" = "$.body.time"
          }
        }
        Next = "audit-end"
      }
      "audit-end" = {
        Type = "Task"
        Resource = "arn:aws:states:::lambda:invoke"
        Parameters = {
          FunctionName = var.audit_lambda_name
          Payload = {
            "ExecutionName.$" = "$$.Execution.Name"
            "workflow_end_time.$" = "$$.State.EnteredTime"
            workflow_status = "SUCCESS"
          }
        }
        Next = "success-notification"
      }
      "success-notification" = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.dossier_success_topic_arn
          Subject = "Dossier to S3 Data Lake Ingestion: Success"
          Message = "All Dossier schemas successfully ingested to S3 Data Lake"
        }
        End = true
      }
      "notify-failure" = {
        Type = "Task"
        Resource = "arn:aws:states:::sns:publish"
        Parameters = {
          TopicArn = var.dossier_failure_topic_arn
          "Subject.$" = "States.Format('Dossier to S3 Data Lake Ingestion: Failure in {}', $.error.Error)"
          "Message.$" = "States.Format('An error occurred during the {} step: {}', $.error.Error, $.error.Cause)"
        }
        End = true
      }
    }
  })

  tags = var.tags
}




###############################################################################################

                          #      sf_platformdata_workflow

###############################################################################################


resource "aws_sfn_state_machine" "sf_platformdata_workflow" {
  # name     = "sf_platformdata_workflow"
  name     = "pw-${var.env}-platformdata-workflow-sf"
  role_arn = var.step_function_role_arn


  definition = jsonencode({
    Comment = "PW to S3 Data Lake Ingestion Workflow",
    StartAt = "audit-start",
    States = {
      "audit-start" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            workflowName = "sf_platformdata_workflow",
            "workflow_start_time.$" = "$$.State.EnteredTime",
            source_system = "PW",
            target_system = "S3",
            layer = "Raw",
            "ExecutionName.$" = "$$.Execution.Name"
          }
        },
        ResultPath = "$.auditStart",
        Next = "Get DynamoDB tables"
      },
      "Get DynamoDB tables" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.all_datasources_lambda_name,
          Payload = {
            source_system = "PW",
            "additionalData.$" = "$"
          }
        },
        ResultPath = "$",
        Next = "update-lambda-details",
        Catch = [
          {
            ErrorEquals = ["States.ALL"],
            ResultPath = "$.error",
            Next = "notify-failure"
          }
        ]
      },
      "update-lambda-details" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            lambda_function_name = "all-datasources-lambda",
            "ExecutionName.$" = "$$.Execution.Name",
            "schema_list.$" = "$.Payload"
          }
        },
        ResultPath = "$.lambdaInfo",
        Next = "map-process-dynamoDB-tables"
      },
      "map-process-dynamoDB-tables" = {
        Type = "Map",
        ItemsPath = "$.Payload",
        MaxConcurrency = 30,
        Iterator = {
          StartAt = "ingest-platform-s3-glue-job",
          States = {
            "ingest-platform-s3-glue-job" = {
              Type = "Task",
              Resource = "arn:aws:states:::glue:startJobRun.sync",
              Parameters = {
                JobName = var.glue_platform_data_incremental_load_job_name,
                Arguments = {
                  "--enable-glue-datacatalog" = "true",
                  "--job-language" = "python",
                  "--SCHEMA_NAME.$" = "$",
                  "--SNS_SUCCESS_TOPIC_ARN" = var.success-notification-topic-arn,
                  "--SNS_FAILURE_TOPIC_ARN" = var.failure-notification-topic-arn
                }
              },
              End = true
            }
          }
        },
        Next = "GetSchemaCounts",
        Catch = [
          {
            ErrorEquals = ["States.ALL"],
            ResultPath = "$.error",
            Next = "notify-failure"
          }
        ]
      },
      "GetSchemaCounts" = {
        Type = "Task",
        Resource = var.audit_lambda_arn,
        Parameters = {
          "Payload.$" = "$"
        },
        ResultPath = "$",
        Next = "update-gluejob-details"
      },
      "update-gluejob-details" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            gluejob_name = var.glue_platform_data_incremental_load_job_name,
            "ExecutionName.$" = "$$.Execution.Name",
            "schema_counts.$" = "$.body.counts",
            "time_taken_for_workflow_execution.$" = "$.body.time"
          }
        },
        Next = "audit-end"
      },
      "audit-end" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            "ExecutionName.$" = "$$.Execution.Name",
            "workflow_end_time.$" = "$$.State.EnteredTime",
            workflow_status = "SUCCESS"
          }
        },
        Next = "success-notification"
      },
      "success-notification" = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = var.success-notification-topic-arn,
          Subject = "PW-DynamoDB to S3 Data Lake Ingestion: Success",
          Message = "All DynamoDB tables successfully ingested to S3 Data Lake"
        },
        End = true
      },
      "notify-failure" = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = var.failure-notification-topic-arn,
          "Subject.$" = "States.Format('PW-DynamoDB to S3 Data Lake Ingestion: Failure in {}', $.error.Error)",
          "Message.$" = "States.Format('An error occurred during the {} step: {}', $.error.Error, $.error.Cause)"
        },
        End = true
      }
    }
  })
}


###############################################################################################

                          #      pw-cleansing-workflow

###############################################################################################



# Step Function State Machine
resource "aws_sfn_state_machine" "cleansing_workflow" {
  # name     = "pw-cleansing-workflow"
  name     = "pw-${var.env}-cleansing-workflow-sf"
  role_arn = var.step_function_role_arn
  
  definition = jsonencode({
    Comment = "PW data lake cleansing workflow",
    StartAt = "audit-start",
    States = {
      "audit-start" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            workflowName = "sf-pw-delta-audit",
            "workflow_start_time.$" = "$$.State.EnteredTime",
            source_system = "AMCS",
            target_system = "S3",
            layer = "Cleansed",
            "ExecutionName.$" = "$$.Execution.Name"
          }
        },
        ResultPath = "$.auditStart",
        Next = "Create-s3paths"
      },
      "Create-s3paths" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.data_curator_lambda_name,
          Payload = {
            source_system = "AMCS",
            "event.$" = "$"
          }
        },
        ResultPath = "$",
        Next = "update-lambda-details",
        Catch = [
          {
            ErrorEquals = [
              "States.ALL"
            ],
            ResultPath = "$.error",
            Next = "notify-failure"
          }
        ]
      },
      "update-lambda-details" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            lambda_function_name = var.data_curator_lambda_name,
            "ExecutionName.$" = "$$.Execution.Name",
            layer = "Cleansed",
            "schema_list.$" = "$.Payload.body.schemas"
          }
        },
        ResultPath = "$.lambdaInfo",
        Next = "map-process-schemas"
      },
      "map-process-schemas" = {
        Type = "Map",
        ItemsPath = "$.Payload.body.schemas",
        MaxConcurrency = 15,
        Iterator = {
          StartAt = "Clean-S3-data-lake",
          States = {
            "Clean-S3-data-lake" = {
              Type = "Task",
              Resource = "arn:aws:states:::glue:startJobRun.sync",
              Parameters = {
                JobName = var.glue_data_cleansing_job_name,
                Arguments = {
                  "--enable-glue-datacatalog" = "true",
                  "--job-language" = "python",
                  "--SCHEMA_NAME.$" = "$",
                  "--DATA_SOURCE" = "AMCS",
                  "--SNS_SUCCESS_TOPIC_ARN" = var.success-notification-topic-arn,
                  "--SNS_FAILURE_TOPIC_ARN" = var.failure-notification-topic-arn
                }
              },
              End = true
            }
          }
        },
        Next = "GetSchemaCounts",
        Catch = [
          {
            ErrorEquals = [
              "States.ALL"
            ],
            ResultPath = "$.error",
            Next = "notify-failure"
          }
        ]
      },
      "GetSchemaCounts" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          "Payload" = {
            "Payload.$" = "$",
            source_system = "AMCS"
          }
        },
        ResultPath = "$",
        Next = "update-gluejob-details"
      },
      "update-gluejob-details" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            gluejob_name = "pw-data-cleansing-job",
            "ExecutionName.$" = "$$.Execution.Name",
            "schema_counts.$" = "$.body.counts",
            "time_taken_for_workflow_execution.$" = "$.body.time"
          }
        },
        Next = "audit-end"
      },
      "audit-end" = {
        Type = "Task",
        Resource = "arn:aws:states:::lambda:invoke",
        Parameters = {
          FunctionName = var.audit_lambda_name,
          Payload = {
            "ExecutionName.$" = "$$.Execution.Name",
            "workflow_end_time.$" = "$$.State.EnteredTime",
            workflow_status = "SUCCESS"
          }
        },
        Next = "success-notification"
      },
      "success-notification" = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = var.success-notification-topic-arn,
          Subject = "PW S3 data cleansing: Success",
          Message = "PW cleansing S3 Data Lake SUCCESSFUL"
        },
        End = true
      },
      "notify-failure" = {
        Type = "Task",
        Resource = "arn:aws:states:::sns:publish",
        Parameters = {
          TopicArn = var.failure-notification-topic-arn,
          "Subject.$" = "States.Format('PW S3 data cleansing: Failure in {}', $.error.Error)",
          "Message.$" = "States.Format('An error occurred during the {} step: {}', $.error.Error, $.error.Cause)"
        },
        End = true
      }
    }
  })

  tags = {
    Name = "pw-cleansing-workflow"
    Environment = "production"
  }
}













######################################################################################


