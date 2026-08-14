


####################################################################################################


########################################################################################################

                                          # raw bucket

########################################################################################################

# Raw bucket
resource "aws_s3_bucket" "raw" {
  bucket = "pw-${var.env}-datalake-raw-s3"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "raw" {
  bucket = aws_s3_bucket.raw.id
  versioning_configuration {
    status = "Enabled"
  }
}


resource "aws_s3_bucket_public_access_block" "raw" {
  bucket = aws_s3_bucket.raw.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_server_side_encryption_configuration" "raw" {
  bucket = aws_s3_bucket.raw.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.datalake_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}



resource "aws_s3_bucket_notification" "raw" {
  bucket = aws_s3_bucket.raw.id
  topic {
    topic_arn = var.s3_topic_arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_policy" "raw" {
  bucket = aws_s3_bucket.raw.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-${var.env}-datalake-raw-s3",
          "arn:aws:s3:::pw-${var.env}-datalake-raw-s3/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

########################################################################################################

                                          # Cleansed bucket

########################################################################################################

resource "aws_s3_bucket" "cleansed" {
  # bucket = "pw-s3-${var.env}-datalake-cleansed"
  bucket = "pw-${var.env}-datalake-cleansed-s3"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "cleansed" {
  bucket = aws_s3_bucket.cleansed.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "cleansed" {
  bucket = aws_s3_bucket.cleansed.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "cleansed" {
  bucket = aws_s3_bucket.cleansed.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.datalake_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_notification" "cleansed" {
  bucket = aws_s3_bucket.cleansed.id
  topic {
    topic_arn = var.s3_topic_arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_policy" "cleansed" {
  bucket = aws_s3_bucket.cleansed.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-${var.env}-datalake-cleansed-s3",
          "arn:aws:s3:::pw-${var.env}-datalake-cleansed-s3/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}


########################################################################################################

                                         # Curated bucket

########################################################################################################


resource "aws_s3_bucket" "curated" {
  # bucket = "pw-s3-${var.env}-datalake-curated"
  bucket = "pw-${var.env}-datalake-curated-s3"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "curated" {
  bucket = aws_s3_bucket.curated.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "curated" {
  bucket = aws_s3_bucket.curated.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "curated" {
  bucket = aws_s3_bucket.curated.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.datalake_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_notification" "curated" {
  bucket = aws_s3_bucket.curated.id
  topic {
    topic_arn = var.s3_topic_arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_policy" "curated" {
  bucket = aws_s3_bucket.curated.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-${var.env}-datalake-curated-s3",
          "arn:aws:s3:::pw-${var.env}-datalake-curated-s3/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}

###############################################################################################

########################################################################################################

                                          # operational bucket

########################################################################################################

resource "aws_s3_bucket" "operational" {
  # bucket = "pw-s3-${var.env}-datalake-operational"
  bucket = "pw-${var.env}-datalake-operational-s3"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "operational" {
  bucket = aws_s3_bucket.operational.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "operational" {
  bucket = aws_s3_bucket.operational.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "operational" {
  bucket = aws_s3_bucket.operational.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.datalake_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_notification" "operational" {
  bucket = aws_s3_bucket.operational.id
  topic {
    topic_arn = var.s3_topic_arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_policy" "operational" {
  bucket = aws_s3_bucket.operational.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-${var.env}-datalake-operational-s3",
          "arn:aws:s3:::pw-${var.env}-datalake-operational-s3/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}



# ########################################################################################################

#                                           # pw-platform-data  >  raw
# ########################################################################################################

# resource "aws_s3_bucket" "platform-data" {
#   # bucket = "pw-platform-data"
#   bucket = "pw-${var.env}-datalake-operational-s3"
#   tags   = var.tags
# }

# resource "aws_s3_bucket_versioning" "platform-data" {
#   bucket = aws_s3_bucket.platform-data.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "platform-data" {
#   bucket = aws_s3_bucket.platform-data.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "platform-data" {
#   bucket = aws_s3_bucket.platform-data.id
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = var.datalake_kms_key_arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket_notification" "platform-data" {
#   bucket = aws_s3_bucket.platform-data.id
#   topic {
#     topic_arn = var.s3_topic_arn
#     events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#   }
# }

# resource "aws_s3_bucket_policy" "platform-data" {
#   bucket = aws_s3_bucket.platform-data.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           "arn:aws:s3:::pw-platform-data",
#           "arn:aws:s3:::pw-platform-data/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       }
#     ]
#   })
# }


########################################################################################################

                                          # temp bucket

########################################################################################################

resource "aws_s3_bucket" "temp" {
  # bucket = "pw-s3-${var.env}-datalake-temp"
  bucket = "pw-${var.env}-datalake-temp-s3"
  tags   = var.tags
}

resource "aws_s3_bucket_versioning" "temp" {
  bucket = aws_s3_bucket.temp.id
  versioning_configuration {
    status = "Enabled"
  }
}

resource "aws_s3_bucket_public_access_block" "temp" {
  bucket = aws_s3_bucket.temp.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "temp" {
  bucket = aws_s3_bucket.temp.id
  rule {
    apply_server_side_encryption_by_default {
      kms_master_key_id = var.datalake_kms_key_arn
      sse_algorithm     = "aws:kms"
    }
  }
}

resource "aws_s3_bucket_notification" "temp" {
  bucket = aws_s3_bucket.temp.id
  topic {
    topic_arn = var.s3_topic_arn
    events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
  }
}

resource "aws_s3_bucket_policy" "temp" {
  bucket = aws_s3_bucket.temp.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Deny"
        Principal = "*"
        Action = "s3:*"
        Resource = [
          "arn:aws:s3:::pw-${var.env}-datalake-temp-s3",
          "arn:aws:s3:::pw-${var.env}-datalake-temp-s3/*"
        ]
        Condition = {
          Bool = {
            "aws:SecureTransport" = "false"
          }
        }
      }
    ]
  })
}


########################################################################################################

                                         # aws-glue-assets-767397709508-us-east-1 > operational

########################################################################################################


# resource "aws_s3_bucket" "aws-glue" {
#   # bucket = "pw-s3-${var.env}-datalake-curated"
#     bucket = "aws-glue-assets-767397709508"
#     bucket = "pw-${var.env}-datalake-temp-s3"
#   tags   = var.tags
# }

# resource "aws_s3_bucket_versioning" "aws-glue" {
#   bucket = aws_s3_bucket.aws-glue.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "aws-glue" {
#   bucket = aws_s3_bucket.aws-glue.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "aws-glue" {
#   bucket = aws_s3_bucket.aws-glue.id
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = var.datalake_kms_key_arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket_notification" "aws-glue" {
#   bucket = aws_s3_bucket.aws-glue.id
#   topic {
#     topic_arn = var.s3_topic_arn
#     events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#   }
# }

# resource "aws_s3_bucket_policy" "aws-glue" {
#   bucket = aws_s3_bucket.aws-glue.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           "arn:aws:s3:::aws-glue-assets-767397709508",
#           "arn:aws:s3:::aws-glue-assets-767397709508/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       }
#     ]
#   })
# }

###############################################################################################




########################################################################################################

                                         # dossier-layer  > raw

########################################################################################################


# resource "aws_s3_bucket" "dossier-layer" {
#   # bucket = "pw-s3-${var.env}-datalake-curated"
#     bucket = "dossier-layer"
#     bucket = "pw-${var.env}-datalake-temp-s3"
#   tags   = var.tags
# }

# resource "aws_s3_bucket_versioning" "dossier-layer" {
#   bucket = aws_s3_bucket.dossier-layer.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "dossier-layer" {
#   bucket = aws_s3_bucket.dossier-layer.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "dossier-layer" {
#   bucket = aws_s3_bucket.dossier-layer.id
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = var.datalake_kms_key_arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket_notification" "dossier-layer" {
#   bucket = aws_s3_bucket.dossier-layer.id
#   topic {
#     topic_arn = var.s3_topic_arn
#     events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#   }
# }

# resource "aws_s3_bucket_policy" "dossier-layer" {
#   bucket = aws_s3_bucket.dossier-layer.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           "arn:aws:s3:::dossier-layer",
#           "arn:aws:s3:::dossier-layer/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       }
#     ]
#   })
# }

###############################################################################################






########################################################################################################

                                         # pw_reporting > curated

########################################################################################################


# resource "aws_s3_bucket" "pw_reporting" {
#   # bucket = "pw-s3-${var.env}-datalake-curated"
#     bucket = "pw-reportings"
#   tags   = var.tags
# }

# resource "aws_s3_bucket_versioning" "pw_reporting" {
#   bucket = aws_s3_bucket.pw_reporting.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "pw_reporting" {
#   bucket = aws_s3_bucket.pw_reporting.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "pw_reporting" {
#   bucket = aws_s3_bucket.pw_reporting.id
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = var.datalake_kms_key_arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket_notification" "pw_reporting" {
#   bucket = aws_s3_bucket.pw_reporting.id
#   topic {
#     topic_arn = var.s3_topic_arn
#     events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#   }
# }

# resource "aws_s3_bucket_policy" "pw_reporting" {
#   bucket = aws_s3_bucket.pw_reporting.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           "arn:aws:s3:::pw-reportings",
#           "arn:aws:s3:::pw-reportings/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       }
#     ]
#   })
# }





########################################################################################################

                                         # pw-amcs-historical  > raw

########################################################################################################


# resource "aws_s3_bucket" "amcs_historical" {
#   # bucket = "pw-s3-${var.env}-datalake-curated"
#     bucket = "pw-amcs-historicals"
#   tags   = var.tags
# }

# resource "aws_s3_bucket_versioning" "amcs_historical" {
#   bucket = aws_s3_bucket.amcs_historical.id
#   versioning_configuration {
#     status = "Enabled"
#   }
# }

# resource "aws_s3_bucket_public_access_block" "amcs_historical" {
#   bucket = aws_s3_bucket.amcs_historical.id

#   block_public_acls       = true
#   block_public_policy     = true
#   ignore_public_acls      = true
#   restrict_public_buckets = true
# }

# resource "aws_s3_bucket_server_side_encryption_configuration" "amcs_historical" {
#   bucket = aws_s3_bucket.amcs_historical.id
#   rule {
#     apply_server_side_encryption_by_default {
#       kms_master_key_id = var.datalake_kms_key_arn
#       sse_algorithm     = "aws:kms"
#     }
#   }
# }

# resource "aws_s3_bucket_notification" "amcs_historical" {
#   bucket = aws_s3_bucket.amcs_historical.id
#   topic {
#     topic_arn = var.s3_topic_arn
#     events    = ["s3:ObjectCreated:*", "s3:ObjectRemoved:*"]
#   }
# }

# resource "aws_s3_bucket_policy" "amcs_historical" {
#   bucket = aws_s3_bucket.amcs_historical.id

#   policy = jsonencode({
#     Version = "2012-10-17"
#     Statement = [
#       {
#         Effect = "Deny"
#         Principal = "*"
#         Action = "s3:*"
#         Resource = [
#           "arn:aws:s3:::pw-amcs-historicals",
#           "arn:aws:s3:::pw-amcs-historicals/*"
#         ]
#         Condition = {
#           Bool = {
#             "aws:SecureTransport" = "false"
#           }
#         }
#       }
#     ]
#   })
# }

