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



connect_database() {
    read -p "Enter database name: " dbname
    if [ -d "$Database_Dir/$dbname" ]; then
        cd "$Database_Dir/$dbname" || exit
        database_menu
        cd "$OLDPWD" || exit
    else
        echo "Database does not exist!"
    fi
} #this function connects to the database and show the db menu 


drop_database() {
    read -p "Enter database name: " dbname
    if [ -d "$Database_Dir/$dbname" ]; then
        echo "Are you sure you want to delete the database '$dbname'?"
        echo "For yes press 1"
        echo "For no press 2"
        read -p "Enter your choice: " confirm
        case $confirm in
            1) 
                rm -r "$Database_Dir/$dbname"
                echo "Database '$dbname' dropped successfully!"
                ;;
            2)
                echo "Database deletion cancelled."
                ;;
            *)
                echo "Invalid choice, deletion cancelled."
                ;;
        esac
    else
        echo "Database '$dbname' does not exist!"  
    fi
} #this function drops the choosen db by the user 


# Function to display the database menu
function database_menu() {
    while true; do
        echo "Database Menu:"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo "8. Back to Main Menu"
        read -p "Choose an option: " option
        case $option in
            1) create_table ;;
            2) list_tables ;;
            3) drop_table ;;
            4) insert_into_table ;;
            5) select_from_table ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) break ;;
            *) echo "Invalid option!" ;;
        esac
    done
}


main_menu  # Call the main menu function to start the script
