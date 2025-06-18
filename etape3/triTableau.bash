#!/bin/bash

docker run --rm -v ~/docker_work:/work bigpapoo/sae103-excel2csv:latest ssconvert \
  /work/le_tablo.xlsx /work/le_tablo.csv # Conversion du fichier Excel en CSV
sudo chmod 777 tableau_csv/le_tablo.csv # Modification des permissions pour le fichier CSV

# Définir le fichier d'entrée et de sortie
fichierAConvertir="le_tablo.csv"
fichierConverti="le_tablo_trie.csv"

# Ajouter une colonne pour le total des médailles
# Trier le fichier par total décroissant puis par pays
# Ajouter une colonne pour le classement, qui se souvient du classement précédent en cas d'égalité
# Supprimer les 3 dernières lignes
awk -F',' '{ total = $2 + $3 + $4; print " " "," $1 "," $2 "," $3 "," $4 "," total }' "$fichierAConvertir" | \
sort -t',' -k6,6nr -k2,2 | awk -F',' ' 
BEGIN { OFS=","; rank = 1; prev_total = -1 }
{
  if ($6 != prev_total) {
    classement = rank;
    prev_total = $6;
  } else {
    classement = "-";
  }
  $1 = classement;
  rank++;
  print $1, $2, $3, $4, $5, $6;
}' | sed '$d' | sed '$d' | sed '$d'  > "$fichierConverti" 

rm le_tablo.csv # Suppression du fichier CSV d'origine converti

echo "Tableau de médaille trié généré : $fichierConverti"