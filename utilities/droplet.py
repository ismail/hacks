#!/usr/bin/python3
# -*- coding: utf-8 -*-

import argparse
import calendar
import digitalocean
import ipaddress
import time
import os
import sys

api_token = os.getenv("DIGITALOCEAN_API_KEY")
user_data = '''
#cloud-config

manage-resolv-conf: true
package_update:  true
package_upgrade: true
package_reboot_if_required: true

packages:
  - git-core
  - golang-go
  - unrar
  - youtube-dl
  - zsh

users:
  - name: ismail
    groups: sudo
    shell: /bin/zsh
    sudo: ['ALL=(ALL) NOPASSWD:ALL']

resolv_conf:
  nameservers:
    - '1.1.1.1'
    - '1.0.0.1'
    - '2606:4700:4700::1111'
    - '2606:4700:4700::1001'

ssh_authorized_keys:
    - ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAII/lONWgiw1sqUDUTP6IeQwxR0k0oUFEGEQIIn1SdFr3 ismail@xps13

runcmd:
  - su - ismail -c 'mkdir /home/ismail/github; cd /home/ismail/github; git clone https://github.com/ismail/hacks.git; git clone https://github.com/ismail/config.git'
  - su - ismail -c 'cd /home/ismail/github/config; ./setup.sh'
  - su - ismail -c 'cd /home/ismail/github/hacks; ./setup.sh'
'''


def create(manager):
    # Make sure we have only 1 droplet
    if len(manager.get_all_droplets()) >= 1:
        print("There is already an active droplet!")
        return

    keys = manager.get_all_sshkeys()
    region = "fra1"
    droplet_name = f"auto-{region}-{calendar.timegm(time.gmtime())}"
    droplet_size = "s-1vcpu-1gb"
    image_name = "ubuntu-18-10-x64"

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
        print(
            f"Droplet: {droplet.name} Status: {droplet.status} Created at: {droplet.created_at}"
        )


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
