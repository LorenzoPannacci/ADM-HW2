input='datasets/series.json'
grep -oP '"id": "\K\d+|"title": "\K[^"]+|books_count": "\K\d+' "$input" | paste - - - | sort -t$'\t' -k3,3nr | head -5 | awk -F'\t' '{print $1, $2, $3}'