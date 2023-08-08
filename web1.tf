provider "aws" {
  region = "eu-north-1"  # Вкажіть ваш регіон AWS тут
}

resource "aws_instance" "web_server" {
  ami           = "ami-0989fb15ce71ba39e"
  instance_type = "t3.micro"
  key_name      = "Teraform-key"
  vpc_security_group_ids = [aws_security_group.web_server.id] # add new SG
  user_data = <<-EOF
              #!/bin/bash
              apt update -y
              apt install -y apache2

              # Allow access to files outside of default directories
              echo '
              <Directory /var/www/html>
                  Options Indexes FollowSymLinks
                  AllowOverride None
                  Require all granted
              </Directory>
              ' > /etc/apache2/conf-available/custom.conf

              # Enable the custom configuration
              a2enconf custom

              # Create a virtual host for your content
              echo '
              <VirtualHost *:80>
                  DocumentRoot /var/www/html
                  <Directory /var/www/html>
                      Options Indexes FollowSymLinks MultiViews
                      AllowOverride All
                      Require all granted
                  </Directory>
              </VirtualHost>
              ' > /etc/apache2/sites-available/terraform.conf

              # Enable the virtual host
              a2ensite terraform

              # Set up the index.html file with updated text and image
              echo "<html><head><style>
                    body {
                        display: flex;
                        flex-direction: column;
                        align-items: center;
                        justify-content: center;
                        height: 100vh;
                        margin: 0;
                        font-size: 30px;
                    }
                    img {
                        max-width: 100%;
                        height: auto;
                    }
                    </style></head><body>
                    <p>Welcome to Terraform, young Padavan. Don't forget to say thanks to your teacher.</p>
                    <a href="https://imgbb.com/"><img src="https://i.ibb.co/pxX0C18/it-specialist-small.png" alt="it-specialist-small" border="0"></a>
                    </body></html>" > /var/www/html/index.html

              # Restart Apache
              systemctl restart apache2
              EOF


  tags = {
    Name = "Web Server"
	Environment = "Production"
  }
}

resource "aws_security_group" "web_server" {
  name_prefix = "web_server_sg"
  
  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }
  
  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
