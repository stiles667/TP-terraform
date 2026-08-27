# Deploiement Engine-X avec Ansible

## 1. Contexte

Ce dossier correspond a la partie Ansible du projet IaC. L'infrastructure AWS est creee avec Terraform dans `02-terraform`, puis configuree avec Ansible dans ce dossier.

La consigne du cours, inspiree du depot `borisrosedev/iac-boris-v1` sur la branche `j2-prep`, demandait de :

- mettre a jour le service Engine-X (Nginx) ;
- utiliser Jinja2 et le dossier `defaults` pour parametrer sa configuration ;
- faire servir une page Web contenant du HTML, du CSS et du JavaScript ;
- ajouter, en bonus, du durcissement et des handlers.

## 2. Chaine de deploiement

1. Terraform cree une instance Ubuntu dans AWS et lui associe une adresse IP publique.
2. Terraform injecte la cle publique `~/.ssh/tp-terraform-dev-ed25519` dans l'instance.
3. Le Security Group autorise HTTP sur le port 80 et SSH depuis l'adresse IP d'administration.
4. Ansible se connecte a cette instance avec la cle privee correspondante.
5. Le playbook installe Nginx, deploye le site Web et applique le durcissement.

L'adresse utilisee lors du dernier deploiement etait `54.162.216.95`. Elle peut changer si l'instance est recreee. Il faut donc verifier l'output Terraform avant chaque nouveau deploiement.

## 3. Organisation des fichiers

```text
03-ansible/
|-- ansible.cfg
|-- inventory.ini
|-- group_vars/web.yml
|-- site.yml
`-- roles/
    |-- install_nginx/
    |   |-- defaults/main.yml
    |   |-- files/index.html
    |   |-- files/styles.css
    |   |-- files/app.js
    |   |-- handlers/main.yml
    |   |-- tasks/main.yml
    |   `-- templates/nginx.conf.j2
    |-- hardening_ufw/
    |   |-- defaults/main.yml
    |   `-- tasks/main.yml
    `-- hardening_fail2ban/
        |-- defaults/main.yml
        |-- handlers/main.yml
        |-- tasks/main.yml
        `-- templates/jail.local.j2
```

## 4. Role `install_nginx`

Le role `install_nginx` :

- installe le paquet `nginx` ;
- active et demarre le service ;
- cree le dossier `/var/www/enginex` ;
- copie les fichiers `index.html`, `styles.css` et `app.js` ;
- desactive le site Nginx par defaut ;
- active le virtual host Engine-X ;
- valide la configuration complete avec `nginx -t`.

### Jinja2 et variables

Les variables sont definies dans `roles/install_nginx/defaults/main.yml`, notamment :

- `nginx_web_root` : emplacement des fichiers Web ;
- `nginx_listen_port` : port d'ecoute ;
- `nginx_server_name` : nom du serveur ;
- `nginx_index_title` : titre affiche sur la page.

Le template `templates/nginx.conf.j2` utilise ces variables pour generer la configuration Nginx. La configuration peut donc etre adaptee sans modifier les taches du role.

### Page Web

La page deployee contient :

- une structure HTML simple ;
- une feuille de style CSS responsive ;
- un bouton JavaScript qui incremente dynamiquement un compteur.

## 5. Bonus de securite

### UFW

Le role `hardening_ufw` applique les regles suivantes :

- refus des connexions entrantes par defaut ;
- autorisation des connexions sortantes ;
- autorisation de SSH uniquement depuis `176.191.65.163/32` ;
- autorisation de HTTP sur le port 80.

Cette adresse doit rester identique a `allowed_ssh_cidrs` dans `02-terraform/infra/envs/dev/dev.auto.tfvars`. Si l'adresse publique change, il faut mettre a jour Terraform et `group_vars/web.yml`.

### Fail2ban

Le role `hardening_fail2ban` installe Fail2ban et active la protection du service SSH. Apres 5 echecs dans une periode de 10 minutes, l'adresse est bannie pendant 1 heure.

## 6. Handlers

Le handler `Reload Engine-X` est appele lorsqu'un fichier de configuration ou un fichier Web change. Il recharge Nginx uniquement lorsque cela est necessaire.

Le handler `Restart Fail2ban` redemarre Fail2ban lorsque `jail.local` est modifie.

## 7. Installation et execution sous Windows

Ansible est execute dans Debian WSL, car Ansible n'est pas supporte nativement comme environnement serveur sous Windows.

Dans PowerShell :

```powershell
wsl -d Debian
```

Dans Debian WSL :

```sh
sudo apt update
sudo apt install -y ansible openssh-client
cd /mnt/c/Users/ilyas/Documents/GitHub/TP-terraform/03-ansible
```

Recuperer l'adresse de la VM Terraform depuis PowerShell :

```powershell
terraform -chdir=02-terraform/infra/envs/dev output -raw vm_public_ip
```

Mettre cette adresse dans `inventory.ini`, puis executer :

```sh
ansible -i inventory.ini web -m ping
ansible-playbook -i inventory.ini site.yml
```

## 8. Validation realisee

Le deploiement a ete valide sur la VM AWS avec :

- `ansible -m ping` : connexion SSH fonctionnelle ;
- playbook Ansible : `ok=21`, `failed=0` ;
- `nginx -t` : configuration validee ;
- requete HTTP : statut `200` ;
- seconde execution Ansible : `changed=0`, `failed=0`.

La page est accessible a l'adresse suivante lorsque l'IP Terraform est encore valide :

```text
http://54.162.216.95
```
