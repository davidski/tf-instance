#cloud-config
package_upgrade: true
runcmd:
- echo "$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone).${fs_id}.efs.$(curl -s http://169.254.169.254/latest/meta-data/placement/availability-zone | sed 's/.$//').amazonaws.com:/ /home nfs4 defaults" >> /etc/fstab
- mount -a
