#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse
import digitalocean
import ipaddress
import time
import os
import sys

api_token = os.getenv("DIGITALOCEAN_API_KEY")
user_data = '''
#cloud-config

package_update:  true
package_upgrade: true
package_reboot_if_required: true

apt_sources:
  - source: deb http://apt.llvm.org/cosmic/ llvm-toolchain-cosmic main
    filename: llvm-dev.list
    keyid: 15CF4D18AF4F7421

packages:
  - bmon
  - clang-8
  - git-core
  - golang-go
  - lld-8
  - ncdu
  - php-cli
  - php-curl
  - tmux
  - tree
  - zsh

write_files:
  - content: |
        options rotate timeout:1

        nameserver 1.1.1.1
        nameserver 1.0.0.1
        nameserver 2606:4700:4700::1111
        nameserver 2606:4700:4700::1001
    owner: root:root
    path: /etc/resolv.conf.cf
    permissions: '0644'

  - content: |
        #!/bin/bash

        cd ~
        echo "export PATH=~/.local/bin:~/go/bin:\$PATH" > ~/.zshrc-local
        mkdir github; mkdir ship
        (cd github; git clone https://github.com/ismail/hacks.git; git clone https://github.com/ismail/config.git)
        (cd github/config; ./setup.sh; cd ../hacks; ./setup.sh)

        go get -u github.com/ncw/rclone; strip go/bin/rclone
        curl -sL https://yt-dl.org/downloads/latest/youtube-dl -o bin/youtube-dl; chmod +x bin/youtube-dl
        curl -sO https://rarlab.com/rar/rarlinux-x64-5.6.1.tar.gz; tar xf rarlinux-x64-5.6.1.tar.gz; mv rar/rar rar/unrar bin; rm -rf rar*
        curl -sO https://johnvansickle.com/ffmpeg/builds/ffmpeg-git-amd64-static.tar.xz; tar xf ffmpeg-git-amd64-static.tar.xz; mv ffmpeg-git*/ffmpeg bin; rm -rf ffmpeg*
    owner: ismail:ismail
    path: /etc/autosetup.sh
    permissions: '0755'

users:
  - name: ismail
    groups: sudo
    shell: /bin/zsh
    sudo: ['ALL=(ALL) NOPASSWD:ALL']
    ssh-authorized-keys:
      - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/lONWgiw1sqUDUTP6IeQwxR0k0oUFEGEQIIn1SdFr3 ismail@xps13

runcmd:
  - rm /etc/resolv.conf; mv /etc/resolv.conf.cf /etc/resolv.conf; chattr +i /etc/resolv.conf
  - su - ismail -c '/etc/autosetup.sh'
'''


def create(manager):
    # Make sure we have only 1 droplet
    if len(manager.get_all_droplets()) >= 1:
        print("There is already an active droplet!")
        return

    keys = manager.get_all_sshkeys()
    region = "fra1"
    droplet_name = f"auto-{region}-{int(time.mktime(time.gmtime()))}"
    droplet_size = "s-1vcpu-1gb"
    image_name = "ubuntu-18-10-x64"
    domain_name = "i10z.com"
    subdomain = "autobahn"

    droplet = digitalocean.Droplet(
        token=api_token,
        name=droplet_name,
        region=region,
        image=image_name,
        size_slug=droplet_size,
        ssh_keys=keys,
        ipv6=True,
        private_networking=False,
        user_data=user_data,
        backups=False)

    print(f"Creating the droplet {droplet_name}")
    droplet.create()

    for action in droplet.get_actions():
        print(f"Droplet status: {action.status}")

    while droplet.get_actions()[0].status != "completed":
        time.sleep(60)

    droplet.load()

    print("Updating DNS records.")
    records = [
        record for record in manager.get_domain(domain_name).get_records()
        if record.type in ["A", "AAAA"] if record.name == subdomain
    ]
    for r in records:
        if r.type == "A":
            r.data = droplet.ip_address
        elif r.type == "AAAA":
            r.data = droplet.ip_v6_address
        r.save()

    print(
        f"Droplet is active, IPv4: {droplet.ip_address}, IPv6: [{str(ipaddress.ip_address(droplet.ip_v6_address))}]"
    )


def destroy(manager):
    droplets = manager.get_all_droplets()

    if len(droplets) == 0:
        print("No droplets found.")
    else:
        for droplet in droplets:
            print(f"Destroying droplet {droplet.name}")
            droplet.destroy()


def status(manager):
    droplets = manager.get_all_droplets()
    if not len(droplets):
        print("No droplets found.")
        return

    for droplet in droplets:
        creation_time = time.mktime(
            time.strptime(droplet.created_at, '%Y-%m-%dT%H:%M:%SZ'))
        time_now = time.mktime(time.gmtime())
        minutes = int((time_now - creation_time) / 60)

        print(f"Droplet:      {droplet.name}")
        print(f"Status:       {droplet.status}")
        print(f"Created at:   {droplet.created_at}")
        print(f"Running time: {minutes} minutes.")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description='Create/Destroy droplets.')
    parser.add_argument('-c', '--create', action='store_true')
    parser.add_argument('-d', '--destroy', action='store_true')
    parser.add_argument('-s', '--status', action='store_true')
    args = parser.parse_args()

    if (args.create and args.destroy) or (not args.create and not args.destroy
                                          and not args.status):
        parser.print_help()
        sys.exit(0)

    manager = digitalocean.Manager(token=api_token)

    if args.create:
        create(manager)
    elif args.destroy:
        destroy(manager)
    elif args.status:
        status(manager)
