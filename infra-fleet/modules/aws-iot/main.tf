locals {
  greengrass_deployment_id = var.greengrass_deployment_id
}

resource "aws_iot_thing_group" "fleet" {
  name = "pw-fleet-group"

  tags = var.tags
}

resource "aws_iot_thing" "thing" {
  name = "pw-fleet-iot-thing-test"
}

resource "aws_iot_policy" "thing_policy" {
  name   = "thing_policy_test"
  policy = jsonencode({
    "Version" : "2012-10-17",
    "Statement": [
      {
        "Effect": "Allow",
        "Action": [
          "iot:Connect",
          "iot:Publish",
          "iot:Receive",
          "iot:Subscribe"
        ],
        "Resource": "*"
      }
    ]
  })
  tags = var.tags
}

resource "aws_iot_certificate" "thing_certificate" {
  active = true
}

resource "aws_iot_thing_principal_attachment" "certificate_thing_attachment" {
  thing     = aws_iot_thing.thing.name
  principal = aws_iot_certificate.thing_certificate.arn
}

resource "aws_iot_policy_attachment" "policy_certificate_attachment" {
  policy = aws_iot_policy.thing_policy.name
  target = aws_iot_certificate.thing_certificate.arn
}

resource "aws_iot_thing_group_membership" "group_thing_attachment" {
  thing_name       = aws_iot_thing.thing.name
  thing_group_name = aws_iot_thing_group.fleet.name

  override_dynamic_group = true
}