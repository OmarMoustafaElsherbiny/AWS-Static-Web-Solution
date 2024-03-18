
resource "aws_dynamodb_table" "site_vistors" {
  name           = "site-vistors"
  hash_key       = "Id"
  read_capacity  = 5
  write_capacity = 5

  attribute {
    name = "Id"
    type = "N"
  }

  tags = {
    Name        = "${local.name} - Site Vistors"
    Environment = local.environment
  }

}


resource "aws_dynamodb_table_item" "viewers" {
  table_name = aws_dynamodb_table.site_vistors.name
  hash_key   = aws_dynamodb_table.site_vistors.hash_key
  item       = <<ITEM
{
  "Id": {"N": "1"},
  "Views": {"N": "0"}
}
ITEM

}
