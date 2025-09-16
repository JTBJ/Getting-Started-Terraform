##################################################################################
# DATA
##################################################################################

data "aws_ssm_parameter" "amzn2_linux" {
  name = "/aws/service/ami-amazon-linux-latest/amzn2-ami-hvm-x86_64-gp2"
}

# INSTANCES #
resource "aws_instance" "nginx1" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_size["small"]
  subnet_id                   = aws_subnet.public_subnet1.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  user_data_replace_on_change = true

  tags = local.common_tags

  user_data = <<EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      
      systemctl start httpd
      systemctl enable httpd
      
      cat << 'HTML' > /var/www/html/index.html
        <html>
        <head>
            <title>Taco Team Server</title>
        </head>
        <body style="background-color:#1F778D">
            <p style="text-align: center;">
                <span style="color:#FFFFFF;">
		    <span style="font-size:100px;">Welcome to Server 1's website! Have a 🌮 </span>
                </span>
            </p>
        </body>
        </html>
    EOF
}

resource "aws_instance" "nginx2" {
  ami                         = nonsensitive(data.aws_ssm_parameter.amzn2_linux.value)
  instance_type               = var.instance_size["small"]
  subnet_id                   = aws_subnet.public_subnet2.id
  vpc_security_group_ids      = [aws_security_group.nginx_sg.id]
  user_data_replace_on_change = true

  tags = local.common_tags

  user_data = <<EOF
      #!/bin/bash
      yum update -y
      yum install -y httpd
      
      systemctl start httpd
      systemctl enable httpd
      
      cat << 'HTML' > /var/www/html/index.html
        <html>
        <head>
            <title>Taco Team Server</title>
        </head>
        <body style="background-color:#1F778D">
            <p style="text-align: center;">
                <span style="color:#FFFFFF;">
                  <span style="color:#FFFFFF;">
        <span style="font-size:100px;">Welcome Server 2's website! Have a 🌮  </span>
                </span>
            </p>
        </body>
        </html>
    EOF
}

# aws_iam_role
resource "aws_iam_role" "allow_nginx_s3" {
  name = "allow_nginx_s3"

  assume_role_policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": "sts:AssumeRole",
          "Principal": {
          "Service": "ec2.amazonaws.com"
        },
        "Effect": "Allow",
        "Sid": ""
        }
      ]
    }
  EOF

  tags = local.common_tags
}

# aws_iam_role_policy
resource "aws_iam_role_policy" "allow_s3_all" {
  name = "allow_s3_all"
  role = aws_iam_role.allow_nginx_s3.name

  policy = <<EOF
    {
      "Version": "2012-10-17",
      "Statement": [
        {
          "Action": [
            "s3:*"
          ],
          
          "Effect": "Allow",
          "Resource": ["arn:aws:s3:::${local.s3_bucket_name}", "arn:aws:s3:::${local.s3_bucket_name}/*"]
        }
      ]
    }
  EOF
}

# aws_iam_instance_profile
resource "aws_iam_instance_profile" "nginx_profile" {
  name = "nginx_profile"
  role = aws_iam_role.allow_nginx_s3.name

  tags = local.common_tags
}
