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

runcmd:
  - /home/ismail/bin/update-dns.sh
  - apt-get update
  - apt-get dist-upgrade -y
  - apt-get install -y git-core golang-go zsh
  - 'mkdir /home/ismail/github; cd /home/ismail/github; git clone git@github.com:ismail/hacks.git; git clone git@github.com:ismail/config.git'
  - /home/ismail/github/config/setup.sh
  - /home/ismail/github/hacks/setup.sh
  - /home/ismail/bin/update-dns.sh
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
