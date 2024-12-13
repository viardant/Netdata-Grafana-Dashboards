#!/bin/bash

# Read templates available in the templates directory (./templates) and prompt the user to select one
echo "Available templates:"
ls ./templates
read -p "Enter the name of the template you want to use: " TEMPLATE

# The template will be looked by fuzzy search
TEMPLATE_PATH=$(find ./templates -name "*$TEMPLATE*")
OUTPUT_PATH="./rendered/$(basename $TEMPLATE_PATH)"

# Check if the template exists
if [ -z "$TEMPLATE_PATH" ]; then
  echo "Template not found"
  exit 1
fi

# Check if rendered templates directory exists
if [ ! -d "./rendered" ]; then
  mkdir ./rendered
fi

# Clone the template to the rendered directory
cp "$TEMPLATE_PATH" "$OUTPUT_PATH"

# Extract variables from the template
VARIABLES=$(grep -o '\${[^}]*}' "$OUTPUT_PATH" | sort | uniq)

# Prompt the user for variable values
for VARIABLE in $VARIABLES; do
  # If variable starts with DS_ (datasource) or is GENERATED_UID, skip it
  if [[ $VARIABLE == \${DS_* ]] || [[ $VARIABLE == ${GENERATED_UID} ]]; then
    continue
  fi
  read -p "Enter value for $VARIABLE: " VALUE
  sed -i "s/$VARIABLE/$VALUE/g" "$OUTPUT_PATH"
done

# Generate a random UID for the dashboard
GENERATED_UID=$(uuidgen | cut -d '-' -f 1)
sed -i "s/\${GENERATED_UID}/$GENERATED_UID/g" "$OUTPUT_PATH"

echo "Generated dashboard with hardcoded values saved to $OUTPUT_PATH"
