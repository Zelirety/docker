#!/bin/bash

# Variables
tableauMedailles="le_tablo_trie.csv" # Fichier des médailles
fichierDrapeau="drapeau_complet.txt" # Fichier contenant les codes ISO et les noms des pays
dossierSortie="output_html" # Dossier pour le HTML et le PDF
fichierHTML="$dossierSortie/tableau_medaille.html"
dossierDrapeaux="flags" # Chemin relatif vers les drapeaux
logo="logo.png" # Logo des JO

# Préparation des dossiers
mkdir -p "$dossierSortie"

# Générer un dictionnaire (nom du pays -> code ISO) à partir de drapeau_complet.txt afin d'assigner chaque pays à son code ISO
declare -A country_to_iso

while IFS=',' read -r iso_code country_name; do
    # Supprimer les espaces et les retours à la ligne superflus pour éviter les erreurs
    country_to_iso["$country_name"]="$iso_code"
done < "$fichierDrapeau"

# Vérifier si le dictionnaire est correctement chargé
if [[ ${#country_to_iso[@]} -eq 0 ]]; then
    echo "Erreur : aucun code ISO chargé depuis $fichierDrapeau"
    exit 1
fi

# Créer le fichier HTML avec le titre, le logo et le tableau
cat <<EOF > "$fichierHTML"
<!DOCTYPE html>
<html lang="fr">
<head>
    <meta charset="UTF-8">
    <title>Tableau des Médailles - JO Paris 2024</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 20px; }
        h1 { text-align: center; }
        table { width: 100%; border-collapse: collapse; }
        th, td { border: 1px solid #ddd; text-align: center; padding: 8px; }
        tr:nth-child(even) { background-color: #f9f9f9; }
        img { height: 20px; vertical-align: middle; margin-right: 5px; }
    </style>
</head>
<body>
    <h1>Tableau des Médailles - JO Paris 2024</h1>
    <img src="$logo" alt="Logo JO Paris 2024" style="display: block; margin: 0 auto; height: 50px;">
    <table>
        <tr>
            <th>Rang</th>
            <th>Pays</th>
            <th>Or</th>
            <th>Argent</th>
            <th>Bronze</th>
            <th>Total</th>
            <th>% Total</th>
        </tr>
EOF

# Calculer le total des médailles pour le calcul du pourcentage
total_medals=$(awk -F, '{sum+=$4+$5+$6} END {print sum}' "$tableauMedailles")

# Remplit les lignes du tableau en utilisant awk pour traiter les données du dictionnaire et afficher les drapeaux (mais ils ne s'affichent pas ): )
awk -F, -v total="$total_medals" -v dossierDrapeaux="$dossierDrapeaux" -v fichierDrapeau="$fichierDrapeau" '
BEGIN {
    # Charger le dictionnaire (nom du pays -> code ISO)
    while (getline < fichierDrapeau > 0) {
        iso_code = $1
        country_name = $2
        country_to_iso[country_name] = iso_code
    }
    close(fichierDrapeau)
}
NR > 0 {
    iso_code = country_to_iso[$2]   # Remplacer le nom du pays par le code ISO correspondant
    if (iso_code == "") {
        iso_code = "fr" # Utiliser le drapeau par défaut si le code ISO est introuvable
    }
    printf "<tr><td>%s</td><td><img src= \"%s/%s.png\"> %s</td><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%.2f%%</td></tr>\n",
    $1, dossierDrapeaux, iso_code, $2, $3, $4, $5, $6, ($4+$5+$6)/total*100   # Afficher les données du tableau + drapeaux
}' "$tableauMedailles" >> "$fichierHTML"

# Clore le fichier html
cat <<EOF >> "$fichierHTML"
    </table>
</body>
</html>
EOF

# Générer le PDF avec Docker
docker container run --rm -v "$PWD/$dossierSortie:/work" bigpapoo/sae103-html2pdf \
    weasyprint /work/tableau_medaille.html /work/tableau_medaille.pdf