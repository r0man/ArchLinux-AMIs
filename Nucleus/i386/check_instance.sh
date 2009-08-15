rm -rf /Users/elliottcable/.ssh/known_hosts

MANIFEST=
AMI_ID=$(ec2-register arch-linux/$MANIFEST | awk '/IMAGE/ { print $2 }')

INSTANCE_ID=$(ec2-run-instances --group Void --key Void \
  --instance-type m1.small $AMI_ID | awk '/INSTANCE/ { print $2 }')
INSTANCE_ADDRESS="pending"
while [[ $INSTANCE_ADDRESS == "pending" ]]; do
  INSTANCE_ADDRESS=$(ec2-describe-instances $INSTANCE_ID \
    | awk '/INSTANCE/ { print $4 }')
done
sleep 60
ssh -o "StrictHostKeyChecking no" root@$INSTANCE_ADDRESS \
  -i ~/.ec2/id_rsa-Void

# Install the packages we’ve removed
pacman --noconfirm -S sudo wget which vi tar nano lzo2 procinfo libgcrypt \
  less groff file diffutils dialog dbus-core dash cpio binutils

sleep 1 ; shutdown -h now && exit

ec2-deregister $AMI_ID