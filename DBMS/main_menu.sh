#!/bin/bash

Database_Dir="./DBMS"

# Create the databases directory if it doesn't exist
mkdir -p "$Database_Dir"

main_menu() {
    echo "////Main Menu:////"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo "5. Exit"
    read -p "Choose From The Menu Above: " choice

    case $choice in
        1) create_database ;;
        2) list_databases ;;
        3) connect_database ;;
        4) drop_database ;;
        5) exit 0 ;;
        *) echo "Invalid choice, please try choosing From the menu Above." ;;
    esac
    main_menu  # Call main_menu again to show the menu after an option is executed
}

create_database() {
    read -p "Enter database name: " db_name
    if [ -d "$Database_Dir/$db_name" ]; then
        echo "Database '$db_name' already exists."
    else
        mkdir -p "$Database_Dir/$db_name"
        echo "Database '$db_name' created successfully."
    fi
} #here this function is for creating the db , it asks the user to enter the db name then it goes for checking if it exist if the db exist it shows a msg with already existed if not then it creates it 

list_databases() {
    echo "Databases:"
    ls "$Database_Dir"
} #simple is it just list all the databases that exist in the directory 

main_menu  # Call the main menu function to start the script
