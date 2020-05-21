# go-redis-reader
An application that reads messages from a redis channel

## Deploy with Terraform
To deploy the `go-redis-reader` app in Amazon Web Services you
can use the terraform template stored at `terraform/`, to configure
it create a file named `terraform/terraform.tfvars` with the
following variables:
```
aws_profile        = "default"
aws_region         = "us-east-2"
aws_key_pair_file  = "~/.ssh/YOUR-KEY.pem"
aws_key_pair_name  = "YOUR-KEY-NAME"
tag_name           = "YOUR FULL NAME"
tag_contact        = "your@email.address"

# This is the Lacework Agent URL
lacework_agent_url = "https://YOUR_ACCOUNT.lacework.net/download/abc124/install.sh"
```

Then, run `terraform init` and `terraform apply`, if everything runs as
expected you should see an output similar to:
```
$ terraform apply

 <...>

aws_instance.ubuntu1804[0]: Creation complete after 1m19s [id=i-abcde5345f3a12345]

Apply complete! Resources: 12 added, 0 changed, 0 destroyed.

Outputs:

ubuntu_public_ip = [
  "18.123.123.123",
]
```

Finally, install the `redis-cli` on your computer and publish messages to
`mychannel` queue:
```
# For Mac users, use homebrew
$ brew install redis

$ redis-cli -h 18.123.123.123 PUBLISH mychannel 'hello from my computer!'
```

To verify that the `go-redis-reader` application is working properly, you can
log in to the VM and cat the supervisor logs located at `/var/log/sup.log`:
```
# Use your SSH key and login to the machine
ubuntu@ubuntu1804-lacework:~$ cat /var/log/sup.log

 <...>

go-redis-reader.default(O): Received message from channel 'mychannel'. message:'hello from my computer!'
```
