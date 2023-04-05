output vpc_id {
  value = aws_vpc.vpc.id
}


output public_subnet_ids {
  value = aws_subnet.public_subnet.*.id
}

output sg {
  value = aws_security_group.SG.id
}

output private_subnet_ids {
  value = aws_subnet.private_subnet.*.id
}




