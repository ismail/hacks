#!/usr/bin/python3
# -*- coding: utf-8 -*-

import click
import os
import random
import string
import subprocess


@click.command()
@click.option("--delete", is_flag=True, help="Remove the file after upload")
@click.option("--directory", default="Temp", help="Target Directory")
@click.option("--dry-run", is_flag=True, help="Simulate but not execute")
@click.option("--list-remotes", is_flag=True, help="List configured remotes")
@click.option("--remote", default="google", help="The remote service")
@click.option("--scramble", is_flag=True, help="Scramble file names")
@click.argument('args', nargs=-1)
def upload(delete, directory, dry_run, list_remotes, remote, scramble, args):

    if list_remotes:
        subprocess.Popen(["rclone", "listremotes"]).communicate()
        return

    if not args:
        ctx = click.get_current_context()
        click.echo(ctx.get_help())
        ctx.exit()

    if not scramble:
        base_command = ["rclone", "copy", "--progress"]
    else:
        base_command = ["rclone", "copyto", "--progress"]

    if dry_run:
        base_command.insert(0, "echo")

    for arg in args:
        if not scramble:
            command = base_command + [arg, f'{remote}:/{directory}']
        else:
            scrambled_name = ''.join(
                random.choices(string.ascii_lowercase + string.digits, k=32))
            extension = arg.split(".")[-1]
            command = base_command + [
                arg, f'{remote}:/{directory}/{scrambled_name}.{extension}'
            ]

        child = subprocess.Popen(command)
        child.communicate()

        if (child.returncode == 0) and delete:
            os.unlink(arg)


if __name__ == "__main__":
    upload()
