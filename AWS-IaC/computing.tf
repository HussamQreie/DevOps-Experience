variable "instance-image" {default = "ami-02003f9f0fde924ea"} // ubuntu24.04 image
variable "instance-type" { default = "t2.micro"} // instance type
  


resource "aws_instance" "jenkins" { // jenkins virtual server

    ami = var.instance-image
    instance_type = var.instance-type
    subnet_id= aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sec_grp.id]
//  user_data = file("scripts/jenkins.sh")
    tags = {Name="Jenkins-Server"}
}


resource "aws_instance" "sonarqube" { // sonarqube virtual server

    ami = var.instance-image
    instance_type = var.instance-type
    subnet_id= aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sec_grp.id]
//  user_data = file("scripts/sonarqube.sh")
    tags = {Name="SonarQube-Server"}
}


resource "aws_instance" "k8s_master" { // sonarqube virtual server

    ami = var.instance-image
    instance_type = var.instance-type
    subnet_id= aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sec_grp.id]
    //user_data = file("scripts/k8s-master.sh")
    tags = {Name="K8S-Master-Server"}
}

resource "aws_instance" "k8s_worker" { // sonarqube virtual server

    count = 2
    ami = var.instance-image
    instance_type = var.instance-type
    subnet_id= aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sec_grp.id]
    //user_data = file("scripts/k8s-worker.sh")
    tags = {Name="K8S-Worker-${count.index}"}
}

 
 resource "aws_instance" "nexus" { // sonarqube virtual server

    ami = var.instance-image
    instance_type = var.instance-type
    subnet_id= aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sec_grp.id]
    //user_data = file("scripts/k8s-worker.sh")
    tags = {Name="Nexus"}
}


 resource "aws_instance" "monitor" { // sonarqube virtual server

    ami = var.instance-image
    instance_type = var.instance-type
    subnet_id= aws_subnet.public_subnet.id
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.sec_grp.id]
    //user_data = file("scripts/k8s-worker.sh")
    tags = {Name="Monitor"}
}
