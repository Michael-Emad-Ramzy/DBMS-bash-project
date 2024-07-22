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
    db_name=$(echo "$db_name" | xargs) 

        if [ -z "$db_name" ]; then
        echo "Database name cannot be empty. Please enter a valid name."
        create_database
        return
    fi


        if [[ "$db_name" == *" "* ]]; then
        echo "Database name cannot contain spaces. Please enter a valid name."
        create_database
        return
    fi

    if [ -d "$Database_Dir/$db_name" ]; then
        echo "Database '$db_name' already exists."
    else
        mkdir -p "$Database_Dir/$db_name"
        echo "Database '$db_name' created successfully."
    fi
} #create DBs with Conditions like if i created with empty name , contain spaces and so on 


list_databases() {
    echo "Databases:"
    if [ "$(ls -A $Database_Dir)" ]; then
        ls "$Database_Dir"
    else
        echo "There are no existing databases."
        echo "Click 1 from the main menu to create a Database."
    fi
    } 
    #simple is it just list all the databases that exist in the directory 



connect_database() {
    read -p "Enter database name: " dbname
    if [ -d "$Database_Dir/$dbname" ]; then
        cd "$Database_Dir/$dbname" || exit
        database_menu "$dbname"
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


createTable() {
    local dbname="$1"
    echo -e "Create Table"
    read -p "Please enter the Table Name: " table_name

    table_name=$(echo "$table_name" | xargs)

    if [ -z "$table_name" ]; then
        echo -e "Table name can't be empty"
        createTable "$dbname" 
        return
    fi

    if [[ "$table_name" == *" "* ]]; then
        echo -e "Table name cannot contain spaces"
        createTable "$dbname" 
        return
    fi

    if [ -f "$table_name" ]; then
        echo -e "Table '$table_name' already exists"
        createTable "$dbname" 
        return
    fi

    read -p "Enter number of columns: " colnumber

    if ! [[ "$colnumber" =~ ^[1-9][0-9]*$ ]]; then
        echo "Invalid number of columns."
        return
    fi

    declare -a col_names
    declare -a col_types
    declare primary_key=""

    echo "Enter column details:"
    for ((index = 1; index <= colnumber; index++)); do
        read -p "Column $index name: " colname

        colname=$(echo "$colname" | tr ' ' '_')

        if [[ "$colname" == *" "* ]]; then
            echo "Column name cannot contain spaces."
            ((index--))
            continue
        fi

        read -p "Column $colname datatype (string/int): " coltype

        if [[ "$coltype" != "string" && "$coltype" != "int" ]]; then
            echo "Invalid datatype. Please enter 'string' or 'int'."
            ((index--))
            continue
        fi

        if [ -z "$primary_key" ]; then
            read -p "Is $colname the primary key? (yes/no): " is_primary_key
            if [ "$is_primary_key" == "yes" ]; then
                primary_key=$colname
            fi
        fi

        col_names+=("$colname")
        col_types+=("$coltype")
    done

    touch "$table_name"
    {
        printf "| %-20s " "Column Name"
        for ((i = 0; i < ${#col_names[@]}; i++)); do
            printf "| %-20s " "${col_names[$i]}"
        done
        printf "|\n"
        
        printf "| %-20s " "Type"
        for ((i = 0; i < ${#col_types[@]}; i++)); do
            printf "| %-20s " "${col_types[$i]}"
        done
        printf "|\n"

        printf "| %-20s " "Primary Key"
        for ((i = 0; i < ${#col_names[@]}; i++)); do
            if [ "${col_names[$i]}" == "$primary_key" ]; then
                printf "| %-20s " "Yes"
            else
                printf "| %-20s " "No"
            fi
        done
        printf "|\n"
    } > "$table_name"
    
    meta_file="$table_name.meta"
    echo "Field|Type|Key" > "$meta_file"
    
    for ((i = 0; i < ${#col_names[@]}; i++)); do
        col_name=${col_names[$i]}
        col_type=${col_types[$i]}
        key=""
        if [ "$col_name" == "$primary_key" ]; then
            key="PK"
        fi
        echo "$col_name|$col_type|$key" >> "$meta_file"
    done

    echo -e "\nTable '$table_name' created successfully with $colnumber columns."

} #so this create the table with all the possible conditions and it brings up with two files one with the table and the other is metafile


listTables() {
    echo "Tables:"
    if [ "$(ls -A)" ]; then
        ls
    else
        echo "There are no existing tables."
        echo "Choose option 1 from the database menu to create a Table."
    fi
} #this is for listing tables same as Dbs

dropTable() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name" ]; then
        echo "Are you sure you want to delete the table '$table_name'?"
        echo "For yes press 1"
        echo "For no press 2"
        read -p "Enter your choice: " confirm
        case $confirm in
            1)
                rm "$table_name"
                echo "Table '$table_name' dropped successfully!"
                ;;
            2)
                echo "Table deletion cancelled."
                ;;
            *)
                echo "Invalid choice, deletion cancelled."
                ;;
        esac
    else
        echo "Table '$table_name' does not exist!"
    fi
} #this is for dropping tables




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
            1) createTable ;;
            2) listTables ;;
            3) dropTable ;;
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
