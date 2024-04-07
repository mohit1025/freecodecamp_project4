#!/bin/bash

PSQL="psql -X --username=freecodecamp --dbname=periodic_table --tuples-only --no-align -c"

# Function to check if input is an integer
is_integer() {
    [[ $1 =~ ^[0-9]+$ ]]
}

if [[ $1 ]]; then
    # Check if the input is an integer
    if is_integer "$1"; then
        # Retrieve information based on atomic number
        PROPERTY_INFO=$( $PSQL "SELECT type_id, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number = $1" )
        ELEMENT_INFO=$( $PSQL "SELECT atomic_number,symbol, name FROM elements WHERE atomic_number = $1" )
    else
        # Retrieve information based on element name or symbol
        PROPERTY_INFO=$( $PSQL "SELECT type_id, atomic_mass, melting_point_celsius, boiling_point_celsius FROM properties WHERE atomic_number = (SELECT atomic_number FROM elements WHERE name = '$1' OR symbol = '$1')" )
        ELEMENT_INFO=$( $PSQL "SELECT atomic_number, symbol, name FROM elements WHERE name = '$1' OR symbol = '$1'" )
    fi

    # Check if property information is retrieved
    if [[ -n $PROPERTY_INFO && -n $ELEMENT_INFO ]]; then
        # Parse property information
        IFS='|' read -r TYPE_ID ATOMIC_MASS MELTING_POINT BOILING_POINT <<< "$PROPERTY_INFO"
        # Parse element information
        IFS='|' read -r ATOMIC_NUMBER SYMBOL NAME <<< "$ELEMENT_INFO"
        # Get the type info from types table
        TYPE=$( $PSQL "SELECT type FROM types WHERE type_id = $TYPE_ID" )
        # Print the output
        echo "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT celsius and a boiling point of $BOILING_POINT celsius."
    else
        echo "I could not find that element in the database."
    fi
else
    echo "Please provide an element as an argument."
fi
