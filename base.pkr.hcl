variable "project_id" {
    type    = string
    default = "instruqt"
}

source "googlecompute" "rhel8-vmx" {
    project_id          = var.project_id
    source_image_family = "rhel-8"
    ssh_username        = "packer"
    zone                = "europe-west1-b"
    machine_type        = "n1-standard-4"
    image_family        = "rhel-8-vmx"
    image_licenses      = ["projects/vm-options/global/licenses/enable-vmx"]
}

build {
    sources = ["sources.googlecompute.rhel8-vmx"]

    provisioner "shell" {
        inline = [            
            "sudo yum update -y", 
            "sudo adduser crc -G wheel",
            "sudo dnf remove dnf-automatic -y",
            "echo '%wheel	ALL=(ALL)	NOPASSWD: ALL' | sudo tee -a /etc/sudoers"
        ]
    }
}
