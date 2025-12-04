resource "aws_secretsmanager_secret" "app_db_credentials" {
  name        = "app/db-credentials"
  description = "Database credentials for the app EC2 instance"

  recovery_window_in_days = 7
}

resource "aws_secretsmanager_secret_version" "app_db_credentials_value" {
  secret_id     = aws_secretsmanager_secret.app_db_credentials.id
  secret_string = jsonencode({
    username = "appuser"
    password = "ChangeMe123!"
  })
}
