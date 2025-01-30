resource "aws_internet_gateway" "example" {
  vpc_id = aws_vpc.main.id
}
