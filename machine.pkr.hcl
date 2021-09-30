variable "project_id" {
    type    = string
    default = "instruqt"
}

source "googlecompute" "crc" {
    project_id              = var.project_id
    source_image_family     = "rhel-8-vmx"
    source_image_project_id = [var.project_id]
    ssh_username            = "crc"

    zone                = "europe-west1-b"
    machine_type        = "n1-standard-16"
    image_family        = "rhel-crc"
    disk_size           = 40
    image_licenses      = ["projects/vm-options/global/licenses/enable-vmx"]
}


build {
    sources = ["sources.googlecompute.crc"]

    # The image pull secret (download from https://cloud.redhat.com/openshift/create/local)
    provisioner "file" {
        source = "assets/pull-secret.txt"
        destination = "/tmp/pull-secret.txt"
    }

    provisioner "shell" {
        inline = [
            "sudo yum install -yC NetworkManager",
            "curl https://developers.redhat.com/content-gateway/rest/mirror/pub/openshift-v4/clients/crc/latest/crc-linux-amd64.tar.xz -Lo crc-linux-amd64.tar.xz",
            "tar -xf crc-linux-amd64.tar.xz",
            "sudo mv crc-linux*/crc /usr/local/bin",
            "crc config set consent-telemetry no",
            "crc setup",
            "crc start -p /tmp/pull-secret.txt",
            "rm /tmp/pull-secret.txt",
            "crc stop"
        ]
    }
}
