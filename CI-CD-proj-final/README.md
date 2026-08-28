# CI/CD Final - Terraform vers Ansible

## Contexte

Ce projet automatise le deploiement de la VM AWS geree par Terraform et configuree par Ansible. Il repond a la consigne : `make build` recupere les informations Terraform, un programme genere l'inventaire Ansible, puis Ansible deploye automatiquement Nginx, le site Web et le durcissement.

L'architecture reutilise :

- l'infrastructure Terraform de `02-terraform/infra/envs/dev` ;
- le playbook et les roles Ansible de `03-ansible` ;
- l'output Terraform `vm_public_ip` pour cibler la VM sans recopier son adresse a la main.

## Pipeline

```text
Terraform output -json
        |
        v
scripts/generate_inventory.py
        |
        v
build/inventory.ini
        |
        v
Ansible ping puis site.yml
        |
        v
VM AWS: Nginx + HTML/CSS/JavaScript + UFW + Fail2ban
```

## Ce qui est automatise

La cible `make build` execute successivement :

1. `terraform output -json` pour recuperer les outputs de l'etat Terraform ;
2. `generate_inventory.py` pour extraire `vm_public_ip` et creer l'inventaire ;
3. `ansible-playbook` avec le playbook de `03-ansible`.

La cible `make ci` ne contacte pas AWS : elle verifie le format Terraform, initialise Terraform sans backend, compile le generateur Python et controle la syntaxe Ansible. Le deploiement distant est reserve a `make build`.

Aucune adresse IP de VM n'est donc codee dans le pipeline. Le fichier genere reste dans `build/` et n'est pas versionne. Si l'etat Terraform a ete cree avant l'ajout de `ansible_target`, le script utilise temporairement `vm_public_ip`; un prochain `terraform apply` enregistrera l'output compose.

## Types et fonctions Terraform utilises

Le projet existant utilise deja plusieurs types et fonctions Terraform :

- `list(string)` pour `allowed_ssh_cidrs` ;
- `bool` pour `has_public_ip` ;
- `for_each` et `toset(...)` pour creer les regles SSH ;
- `contains(...)` et `regex(...)` pour valider l'environnement ;
- `can(...)` et `cidrhost(...)` pour valider les CIDR ;
- `file(...)` et `pathexpand(...)` pour charger la cle publique ;
- les outputs structures en JSON, consommes par le script Python.

Ces types de composition permettent de modeler des collections et de generer plusieurs ressources a partir d'une seule variable, au lieu de limiter Terraform a des valeurs simples.

## Utilisation locale

Depuis PowerShell, ouvrir Debian WSL :

```powershell
wsl -d Debian
```

Dans WSL, installer les outils :

```sh
sudo apt update
sudo apt install -y make python3 ansible openssh-client
cd /mnt/c/Users/ilyas/Documents/GitHub/TP-terraform/CI-CD-proj-final
```

Commandes disponibles (le Makefile utilise automatiquement `terraform.exe` depuis WSL) :

```sh
make init       # initialise Terraform
make validate   # valide Terraform et la syntaxe Ansible
make plan       # affiche le plan Terraform
make apply      # applique Terraform sur AWS
make inventory  # genere l'inventaire depuis Terraform
make ping       # teste SSH avec Ansible
make build      # pipeline complet apply Terraform -> inventaire -> Ansible
make ci         # controles CI sans deploiement distant
make clean      # supprime les fichiers generes
```

`make build` suppose que Terraform est deja applique et qu'un output `vm_public_ip` existe. Les identifiants AWS sont lus par le provider Terraform deja configure dans `02-terraform`.

## Docker

Docker fournit un environnement reproductible pour les controles CI :

```sh
make docker-build
docker run --rm -v "$PWD:/workspace" -w /workspace iac-ci-tools:local make ci
```

Pour un pipeline complet avec acces AWS et SSH, utiliser Docker Compose avec les credentials montes en lecture seule :

```sh
docker compose run --rm ci make build
```

Compose definit `ANSIBLE_SSH_KEY` vers la cle montee dans le conteneur. En execution WSL hors Docker, le generateur utilise automatiquement le chemin Windows monte sous `/mnt/c`.

Ne jamais placer de secrets dans le Dockerfile, le depot ou les fichiers generes.

## Resultat attendu

Apres `make build`, la VM AWS sert la page Engine-X sur le port 80. La page contient un compteur JavaScript et le serveur est protege par UFW et Fail2ban. Une seconde execution doit etre idempotente et ne modifier que ce qui a change.
