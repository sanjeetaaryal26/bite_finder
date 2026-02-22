#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
OUT_DIR="$ROOT_DIR/data/osm"
RAW_FILE="$OUT_DIR/kathmandu_restaurants_raw.json"
FINAL_FILE="$OUT_DIR/kathmandu_restaurants.json"

mkdir -p "$OUT_DIR"

curl -sS -X POST 'https://overpass-api.de/api/interpreter' \
  --data '[out:json][timeout:180];
(
  node["amenity"~"restaurant|cafe|fast_food"](27.58,85.20,27.82,85.52);
  way["amenity"~"restaurant|cafe|fast_food"](27.58,85.20,27.82,85.52);
  relation["amenity"~"restaurant|cafe|fast_food"](27.58,85.20,27.82,85.52);
);
out center tags;' \
  -o "$RAW_FILE"

jq '
  def norm_space: gsub("\\s+"; " ") | gsub("^\\s+|\\s+$"; "");
  def title_case_word: if . == "" then . else (.[0:1] | ascii_upcase) + (.[1:] | ascii_downcase) end;
  def to_cuisine_list:
    ((.tags.cuisine // .tags["cuisine"] // "")
      | split(";")
      | map(norm_space)
      | map(select(length > 0))
      | map(title_case_word));
  def service_list:
    (["Dine-in"]
      + (if (.tags.delivery // "") == "yes" then ["Delivery"] else [] end)
      + (if (.tags.takeaway // "") == "yes" then ["Takeaway"] else [] end)
      + (if (.tags.internet_access // "") != "" then ["WiFi"] else [] end)
      + (if (.tags.outdoor_seating // "") == "yes" then ["Outdoor Seating"] else [] end)
    ) | unique;
  def location_text:
    ([.tags["addr:street"], .tags["addr:suburb"], .tags["addr:city"], .tags["addr:district"], "Kathmandu"]
      | map(select(. != null and . != "")) | .[0]);
  def lat: (.lat // .center.lat);
  def lon: (.lon // .center.lon);
  [.elements[]
    | select((.tags.name // "") | norm_space | length > 0)
    | {
        id: ("osm-" + .type + "-" + (.id|tostring)),
        name: ((.tags.name | norm_space)),
        cuisines: (to_cuisine_list | if length == 0 then ["Local"] else . end),
        location: location_text,
        description: ("Imported from OpenStreetMap (" + (.tags.amenity // "food") + ")."),
        specialties: (to_cuisine_list | if length == 0 then ["Local dishes"] else [.[0] + " specials"] end),
        services: service_list,
        ratingAvg: 4.0,
        ratingCount: 0,
        priceRange: "Rs. 500-1500",
        photos: [
          ("https://picsum.photos/seed/" + (.id|tostring) + "a/600/350"),
          ("https://picsum.photos/seed/" + (.id|tostring) + "b/600/350"),
          ("https://picsum.photos/seed/" + (.id|tostring) + "c/600/350")
        ],
        bestSellers: ["Popular items"],
        latitude: lat,
        longitude: lon
      }
  ]
  | unique_by(.name + "|" + .location)
  | sort_by(.name)
' "$RAW_FILE" > "$FINAL_FILE"

echo "Generated dataset:"
echo "  Raw:   $RAW_FILE"
echo "  Final: $FINAL_FILE"
echo "  Count: $(jq 'length' "$FINAL_FILE")"
