#!/bin/bash
apt update
apt upgrade -y
apt install sudo

# Verification que le script est execute en tant que root
if [ "$(id -u)" -ne 0 ]; then
  echo "Ce script doit etre execute en tant que root."
  exit 1
fi

# Demander le nom de l'utilisateur a creer
read -p "Entrez le nom de l'utilisateur a ajouter : " username

# Verification si l'utilisateur existe deja
if id "$username" &>/dev/null; then
  echo "L'utilisateur $username existe deja"
  exit 1
fi

# Creation de l'utilisateur
useradd -m -s /bin/bash "$username"
if [ $? -ne 0 ]; then
  echo "Erreur lors de la creation de l'utilisateur."
  exit 1
fi

# Definition d'un mot de passe pour l'utilisateur
passwd "$username"
if [ $? -ne 0 ]; then
  echo "Erreur lors de la definition du mot de passe pour l'utilisateur."
  exit 1
fi

# Ajouter l'utilisateur au fichier sudoers via visudo
echo "Ajout de $username aux sudoers."
echo "$username ALL=(ALL:ALL) NOPASSWD:ALL" | EDITOR='tee -a' visudo

# Verification si l'utilisateur a ete corectement ajoute aux sudoers
if sudo -lU "$username" | grep -q "(ALL:ALL) NOPASSD:ALL"; then
  echo "L'utilisateur $username a ete ajoute avec succes dans  sudoers."
else
  echo "Erreur lors de l'ajout de $username aux sudoers."
  exit 1
fi

echo "Configuration termine."
