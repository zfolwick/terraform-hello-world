# Getting the repo
Clone in the usual way, acquire the access and secret keys in the usual way, then run `terraform init`. The rest of this readme assumes you are using linux-based utilities (this was run on a mac).

This will bring in the aws provider resources into the local directory, creating a `.terraform` directory. Run `terraform plan` to see what changes will be made.

To spin up an ec2 instance, run `terraform apply`. The public ip address will be printed at the end. To automatically enter "yes", run `yes "yes" | terraform appyly`.

Creators may ssh into the machine using the public ip address displayed. If the ip address isn't displayed, just run `terraform apply` again. It should display.

When completed, run `terraform destroy` and validate in AWS console that the ec2 instance is actually destroyed.
