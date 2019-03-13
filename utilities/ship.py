#!/usr/bin/python3
# -*- coding: utf-8 -*-

import click
import subprocess


@click.command()
@click.option("--directory", default="Temp", help="Target Directory")
@click.option("--dry-run", is_flag=True, help="Simulate but not execute")
@click.option("--remote", default="google", help="The remote service")
@click.argument('args', nargs=-1)
def upload(directory, dry_run, remote, args):
    if not args:
        ctx = click.get_current_context()
        click.echo(ctx.get_help())
        ctx.exit()

    base_command = ["rclone", "copy", "--progress"]

    if dry_run:
        base_command.insert(0, "echo")

    for arg in args:
        command = base_command + [arg, f'{remote}:/{directory}']
        subprocess.Popen(command).communicate()


if __name__ == "__main__":
    upload()
