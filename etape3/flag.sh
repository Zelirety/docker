#!/bin/bash

maListe='drapeau.txt'
dossierSortie='flags'

mkdir ~/docker_work/$dossierSortie # Création du dossier de sortie

nbLigne=$(wc -l < "$maListe") # Affectation du nombre de lignes du le fichier dans une variable

for i in $(seq 1 $nbLigne); # Boucle pour télécharger les drapeaux
do
    iso=$(sed -n "${i}p" "$maListe" | tr -d '\r') # Récupération de la ligne i du fichier
    # Téléchargement du drapeau correspondant à l'ISO de la ligne i
    docker container run -v "$PWD"/flags:/work -w /work bigpapoo/sae103-wget -c "wget -q -o /work/${iso}.png https://flagcdn.com/80x60/${iso}.png"
done
