#!/usr/bin/python3
# -*- coding: utf-8 -*-

import click
import os
import random
import shutil
import string
import subprocess


@click.command()
@click.option("--delete", is_flag=True, help="Remove the file after upload")
@click.option("--directory", default="", help="Target Directory")
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

    user_agent = "Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/74.0.3729.157 Safari/537.36"
    if not scramble:
        base_command = [
            "rclone", "--user-agent", user_agent, "copy", "--progress"
        ]
    else:
        base_command = [
            "rclone", "--user-agent", user_agent, "copyto", "--progress"
        ]

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
            if os.path.isdir(arg):
                shutil.rmtree(arg)
            else:
                os.unlink(arg)


if __name__ == "__main__":
    upload()
