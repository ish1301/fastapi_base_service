resource "aws_vpc" "amp_vpc" {
  cidr_block           = var.vpc_cidr
  instance_tenancy     = "default"
  enable_dns_hostnames = true
  tags = {
    Name       = "${var.app}-${var.env}-vpc"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_subnet" "amp_public_subnet" {
  vpc_id                  = aws_vpc.amp_vpc.id
  cidr_block              = var.public_subnet_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = var.main_availability_zone
  tags = {
    Name       = "${var.app}-${var.env}-public-subnet"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_subnet" "amp_private_subnet" {
  vpc_id                  = aws_vpc.amp_vpc.id
  cidr_block              = var.private_subnet_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.main_availability_zone
  tags = {
    Name       = "${var.app}-${var.env}-private-subnet"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_subnet" "amp_alternate_public_subnet" {
  vpc_id                  = aws_vpc.amp_vpc.id
  cidr_block              = var.alternate_public_subnet_cidr
  map_public_ip_on_launch = "true"
  availability_zone       = var.alternate_availability_zone
  tags = {
    Name       = "${var.app}-${var.env}-alternate-public-subnet"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_subnet" "amp_alternate_private_subnet" {
  vpc_id                  = aws_vpc.amp_vpc.id
  cidr_block              = var.alternate_private_subnet_cidr
  map_public_ip_on_launch = "false"
  availability_zone       = var.alternate_availability_zone
  tags = {
    Name       = "${var.app}-${var.env}-alternate-private-subnet"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_route_table" "amp_public_rt" {
  vpc_id = aws_vpc.amp_vpc.id
  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.amp_internet_gw.id
  }
  tags = {
    Name       = "${var.app}-${var.env}-public-rt"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_route_table_association" "amp_public_rta" {
  subnet_id      = aws_subnet.amp_public_subnet.id
  route_table_id = aws_route_table.amp_public_rt.id
}
resource "aws_route_table_association" "amp_alternate_public_rta" {
  subnet_id      = aws_subnet.amp_alternate_public_subnet.id
  route_table_id = aws_route_table.amp_public_rt.id
}

resource "aws_route_table" "amp_private_rt" {
  vpc_id = aws_vpc.amp_vpc.id
  route {
    cidr_block     = "0.0.0.0/0"
    nat_gateway_id = aws_nat_gateway.amp_ng.id
  }
  tags = {
    Name       = "${var.app}-${var.env}-private-rt"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_route_table_association" "amp_private_rta" {
  subnet_id      = aws_subnet.amp_private_subnet.id
  route_table_id = aws_route_table.amp_private_rt.id
}
resource "aws_route_table_association" "amp_alternate_private_rta" {
  subnet_id      = aws_subnet.amp_alternate_private_subnet.id
  route_table_id = aws_route_table.amp_private_rt.id
}


resource "aws_internet_gateway" "amp_internet_gw" {
  vpc_id = aws_vpc.amp_vpc.id
  tags = {
    Name       = "${var.app}-${var.env}-internet-gw"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}

resource "aws_eip" "amp_natIP" {
  vpc = true
  tags = {
    Name       = "${var.app}-${var.env}-nat-ip"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
resource "aws_nat_gateway" "amp_ng" {
  subnet_id     = aws_subnet.amp_public_subnet.id
  allocation_id = aws_eip.amp_natIP.id
  depends_on    = [aws_internet_gateway.amp_internet_gw]
  tags = {
    Name       = "${var.app}-${var.env}-ng"
    App        = var.app
    Env        = var.env
    automation = "terraform"
    repo_name  = "archerdxinc/assay-marketplace"
    repo_path  = "terraform"
    team       = "5AM_External"
  }
}
