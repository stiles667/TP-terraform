#!/usr/bin/env python3
"""Generate an Ansible inventory from Terraform JSON outputs."""

import argparse
import json
import os
from pathlib import Path


def output_value(outputs: dict, name: str) -> dict:
    try:
        return outputs[name]["value"]
    except (KeyError, TypeError) as error:
        raise SystemExit(f"Missing Terraform output: {name}") from error


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--terraform-output", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()

    terraform_outputs = json.loads(args.terraform_output.read_text(encoding="utf-8"))
    if "ansible_target" in terraform_outputs:
        target = output_value(terraform_outputs, "ansible_target")
    else:
        public_ip = output_value(terraform_outputs, "vm_public_ip")
        target = {"host": public_ip, "user": "ubuntu", "ports": {"ssh": 22}}
        print("Warning: ansible_target is absent; using vm_public_ip compatibility mode")

    public_ip = target["host"]
    ssh_port = target["ports"]["ssh"]
    user = target["user"]
    ssh_key = os.environ.get(
        "ANSIBLE_SSH_KEY", "/mnt/c/Users/ilyas/.ssh/tp-terraform-dev-ed25519"
    )

    inventory = f"""[web]\nwebserver ansible_host={public_ip} ansible_port={ssh_port} ansible_user={user} ansible_ssh_private_key_file={ssh_key} ansible_ssh_common_args='-o StrictHostKeyChecking=accept-new'\n\n[all:vars]\nansible_python_interpreter=/usr/bin/python3\n"""
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(inventory, encoding="utf-8")
    print(f"Generated Ansible inventory for {public_ip}: {args.output}")


if __name__ == "__main__":
    main()
