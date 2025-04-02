#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

if [ -z "$1" ]; then
  echo "Please provide an element as an argument."
  exit 0
fi

ELEMENT=$($PSQL "
  SELECT atomic_number, name, symbol, type, atomic_mass, melting_point_celsius, boiling_point_celsius 
  FROM properties 
  JOIN elements USING(atomic_number) 
  JOIN types USING(type_id) 
  WHERE atomic_number::TEXT = '$1' OR symbol ILIKE '$1' OR name ILIKE '$1';")

if [ -z "$ELEMENT" ]; then
  echo "I could not find that element in the database."
else
  echo "$ELEMENT" | awk -F '|' '{printf "The element with atomic number %s is %s (%s). It'\''s a %s, with a mass of %s amu. %s has a melting point of %s celsius and a boiling point of %s celsius.\n", $1, $2, $3, $4, $5, $2, $6, $7}'
fi
