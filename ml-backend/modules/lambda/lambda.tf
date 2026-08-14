
resource "aws_iam_role" "pwmy_mlpipeline_lambda_role" {
 name = "mlpipeline_lambda_role"
 assume_role_policy = jsonencode({
   Version = "2012-10-17"
   Statement = [
     {
       Action = "sts:AssumeRole"
       Effect = "Allow"
       Sid    = ""
       Principal = {
         Service = "lambda.amazonaws.com"
       }
     },
   ]
 })
}

resource "aws_iam_policy" "pwmy_mlpipeline_lambda_policy" {
  name   = "mlpipeline_lambda_policy"
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "logs:CreateLogGroup",
          "logs:CreateLogStream",
          "logs:PutLogEvents"
        ]
        Resource = "arn:aws:logs:*:*:*"
      },
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:PutObject"
        ]
        Resource = "arn:aws:s3:::*"
      }
    ]
  })
}

resource "aws_iam_policy_attachment" "pwmy_mlpipeline_lambda_policy_attach" {
  name       = "mlpipeline_lambda_policy_attach"
  roles      = [aws_iam_role.pwmy_mlpipeline_lambda_role.name]
  policy_arn = aws_iam_policy.pwmy_mlpipeline_lambda_policy.arn
}

resource "aws_lambda_function" "pwmy_mlpipeline_lambda" {
  function_name = "mlpipeline_lambda_function" 
  role          = aws_iam_role.pwmy_mlpipeline_lambda_role.arn
  handler       = "lambda_function.lambda_handler"              # Change based on your runtime and entry point ;to be changed
  runtime       = "python3.12"                  # Example: Python 3.9 runtime
  filename      = "modules/python-files/genTelemetry.zip" # Path to your Lambda deployment package
  
  source_code_hash = filebase64sha256("modules/python-files/genTelemetry.zip")

  tags = var.tags
  
###   environment {
###     variables = {
###       LOG_LEVEL = "DEBUG"
###     }
###   }


}
  

  
