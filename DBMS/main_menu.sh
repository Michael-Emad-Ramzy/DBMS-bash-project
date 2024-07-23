#!/bin/bash

Database_Dir="./DBMS"

# Create the databases directory if it doesn't exist
mkdir -p "$Database_Dir"

main_menu() {
    echo -e "\n#############################################"
    echo -e "////Main Menu:////\n"
    echo "1. Create Database"
    echo "2. List Databases"
    echo "3. Connect To Database"
    echo "4. Drop Database"
    echo -e "5. Exit\n"
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
    echo -e "\nCreate Database"
    read -p "Enter database name: " db_name
    db_name=$(echo "$db_name" | xargs) 

    if [ -z "$db_name" ]; then
        echo -e "\nDatabase name cannot be empty. Please enter a valid name."
        create_database
        return
    fi

    if [[ "$db_name" == *" "* ]]; then
        echo -e "\nDatabase name cannot contain spaces. Please enter a valid name."
        create_database
        return
    fi

    if [[ "$db_name" =~ [0-9] ]]; then
        echo -e "\nDatabase name cannot contain numbers. Please enter a valid name."
        create_database
        return
    fi

    if [ -d "$Database_Dir/$db_name" ]; then
        echo -e "\nDatabase '$db_name' already exists."
    else
        mkdir -p "$Database_Dir/$db_name"
        echo -e "\nDatabase '$db_name' created successfully."
    fi
}
 #create DBs with Conditions like if i created with empty name , contain spaces and so on 


list_databases() {
    echo -e "\nDatabases:"
    if [ "$(ls -A "$Database_Dir")" ]; then
        ls -l "$Database_Dir" | grep "^d" | awk '{print $9}'
    else
        echo -e "\nThere are no existing databases.\n"
        echo "Click 1 from the main menu to create a Database."
    fi
}

    #simple is it just list all the databases that exist in the directory 



connect_database() {
    echo -e "\nConnect to Database"
    read -p "Enter database name: " dbname
    if [ -d "$Database_Dir/$dbname" ]; then
        chmod 755 "$Database_Dir/$dbname"  # Set read, write, and execute permissions
        cd "$Database_Dir/$dbname" || exit
        database_menu "$dbname"
        cd "$OLDPWD" || exit
    else
        echo -e "\nDatabase does not exist!"
    fi
} #this function connects to the database and show the db menu 




drop_database() {
    echo -e "\nDrop Database"
    read -p "Enter database name: " dbname

    if [ -z "$dbname" ]; then
        echo -e "\nDatabase name cannot be empty. Please enter a valid name."
        drop_database
        return
    fi

    if [ -d "$Database_Dir/$dbname" ]; then
        echo -e "\n Are you sure you want to delete the database '$dbname'?\n"
        echo -e "\nFor yes press 1"
        echo -e "For no press 2\n"
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
        echo -e "\nDatabase '$dbname' does not exist!"  
    fi
} #this function drops the choosen db by the user 


######################### second menu functions ###############################

createTable() {
    local dbname="$1"
    echo -e "\nCreate Table\n"
    read -p "Please enter the name of the table: " table_name


    table_name=$(echo "$table_name" | xargs)


    if [ -z "$table_name" ]; then
        echo -e "\nPlease enter a correct name\n"
        createTable "$dbname" 
        
        return
    fi


    if [[ "$table_name" == *" "* ]]; then
        echo -e "\nTable name cannot contain spaces\n"
        createTable "$dbname" 
        
        return
    fi

    if [[ "$table_name" =~ [0-9] ]]; then
        echo -e "\nTable name cannot contain numbers. Please enter a valid name.\n"
        createTable "$dbname"
        return
    fi


    # Check if the table already exists
    if [ -f "$table_name" ]; then
        echo -e "\nTable '$table_name' already exists\n"
        createTable "$dbname" 
        return
    fi


    read -p "Enter number of columns: " colnumber


    if ! [[ "$colnumber" =~ ^[1-9][0-9]*$ ]]; then
        echo -e "\nInvalid number of columns. Please enter a positive number.\n"
        return
    fi

    declare -a col_names
    declare -a col_types
    declare primary_key=""

    echo -e "\nEnter column details:\n"
    for ((index = 1; index <= colnumber; index++)); do
        read -p "Column $index name: " colname

        colname=$(echo "$colname" | tr ' ' '_')


        if [[ "$colname" == *" "* ]]; then
            echo -e "\nColumn name cannot contain spaces."
            ((index--))
            continue
        fi

        # Check if the column name contains numbers
        if [[ "$colname" =~ [0-9] ]]; then
            echo -e "\nColumn name cannot contain numbers."
            ((index--))
            continue
        fi


        read -p "Column $colname datatype (string/int): " coltype


        if [[ "$coltype" != "string" && "$coltype" != "int" ]]; then
            echo -e "\nInvalid datatype. Please enter 'string' or 'int'."
            ((index--))
            continue
        fi


        while true; do
        if [ -z "$primary_key" ]; then
            read -p "Is $colname the primary key? (yes/no): " is_primary_key
            # Ensure the input is either "yes" or "no"
            if [[ "$is_primary_key" == "yes" || "$is_primary_key" == "no" ]]; then
                if [ "$is_primary_key" == "yes" ]; then
                    primary_key=$colname
                fi
                break
                else
                echo "Invalid input. Please enter 'yes' or 'no'"
            fi
            else
            break
        fi
        done



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
    echo "Field |Type |Key" > "$meta_file"
    
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

}
#so this create the table with all the possible conditions and it brings up with two files one with the table and the other is metafile


listTables() {
    echo -e "\nYour Tables:"
    tables=$(ls | grep -v '\.meta$')
    if [ -n "$tables" ]; then
        echo "$tables"
    else
        echo "There are no existing tables."
        echo "Choose option 1 from the database menu to create a Table."
    fi
} #this shows the table of columns only (that's before inserting) , it doesn't show the meta one 

dropTable() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name" ]; then
        echo -e "Are you sure you want to delete the table '$table_name'?\n"
        echo "For yes press 1"
        echo -e "For no press 2\n"
        read -p "Enter your choice: " confirm
        case $confirm in
            1)
                rm "$table_name"
                rm "$table_name.meta"
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



insertIntoTable() {
    local dbname="$1"
    echo -e "\nInsert Into Table\n"
    read -p "Please enter the name of the table: " table_name

    table_name=$(echo "$table_name" | xargs)

    if [ -z "$table_name" ]; then
        echo -e "\nPlease enter a correct name\n"
        insertIntoTable "$dbname"
        return
    fi

    if [[ "$table_name" == *" "* ]]; then
        echo -e "\nTable name cannot contain spaces\n"
        insertIntoTable "$dbname"
        return
    fi

    if [[ "$table_name" =~ [0-9] ]]; then
        echo -e "\nTable name cannot contain numbers. Please enter a valid name.\n"
        insertIntoTable "$dbname"
        return
    fi

    # Check if the table exists
    if [ ! -f "$table_name" ]; then
        echo -e "\nTable '$table_name' does not exist\n"
        insertIntoTable "$dbname"
        return
    fi

    meta_file="$table_name.meta"
    if [ ! -f "$meta_file" ]; then
        echo -e "\nMeta file for table '$table_name' does not exist\n"
        return
    fi

    # Read column names and types from meta file
    declare -a col_names
    declare -a col_types
    declare primary_key=""
    
    while IFS="|" read -r col_name col_type key; do
        if [ "$col_name" != "Field" ]; then
            col_names+=("$col_name")
            col_types+=("$col_type")
            if [ "$key" == "PK" ]; then
                primary_key="$col_name"
            fi
        fi
    done < <(tail -n +2 "$meta_file")

    declare -A new_row
    for ((index = 0; index < ${#col_names[@]}; index++)); do
        colname="${col_names[$index]}"
        coltype="${col_types[$index]}"
        
        while true; do
            read -p "Enter value for $colname ($coltype): " value
            
            if [[ "$coltype" == "int" && ! "$value" =~ ^[0-9]+$ ]]; then
                echo -e "\nInvalid value for $colname. Expected an integer.\n"
                continue
            elif [[ "$coltype" == "string" && "$value" =~ [0-9] ]]; then
                echo -e "\nInvalid value for $colname. Strings cannot contain numbers.\n"
                continue
            fi
            
            if [ "$colname" == "$primary_key" ]; then
                # Check if primary key already exists
                if grep -q "| $value |" "$table_name"; then
                    echo -e "\nPrimary key value '$value' already exists. Please enter a unique value.\n"
                    continue
                fi
            fi
            
            new_row["$colname"]="$value"
            break
        done
    done

    # Insert new row into table file
    {
        printf "| "
        for ((i = 0; i < ${#col_names[@]}; i++)); do
            printf "%-20s | " "${new_row[${col_names[$i]}]}"
        done
        printf "\n"
    } >> "$table_name"

    echo -e "\nRecord inserted successfully into table '$table_name'."
}

selectFromTable() {
    local dbname="$1"
    echo -e "\nSelect From Table\n"
    read -p "Please enter the name of the table: " table_name

    table_name=$(echo "$table_name" | xargs)

    if [ -z "$table_name" ]; then
        echo -e "\nPlease enter a correct name\n"
        select_from_table "$dbname"
        return
    fi

    if [[ "$table_name" == *" "* ]]; then
        echo -e "\nTable name cannot contain spaces\n"
        select_from_table "$dbname"
        return
    fi

    if [[ "$table_name" =~ [0-9] ]]; then
        echo -e "\nTable name cannot contain numbers. Please enter a valid name.\n"
        select_from_table "$dbname"
        return
    fi

    if [ ! -f "$table_name" ]; then
        echo -e "\nTable '$table_name' does not exist\n"
        select_from_table "$dbname"
        return
    fi

    echo -e "\nTable: $table_name"
    awk '{print $0}' "$table_name"
}








# Function to display the database menu
function database_menu() {
    while true; do
        echo -e "\n #############################################"
        echo -e "Database Menu:\n"
        echo "1. Create Table"
        echo "2. List Tables"
        echo "3. Drop Table"
        echo "4. Insert into Table"
        echo "5. Select From Table"
        echo "6. Delete From Table"
        echo "7. Update Table"
        echo -e "8. Back to Main Menu\n"
        read -p "Choose an option: " option
        case $option in
            1) createTable ;;
            2) listTables ;;
            3) dropTable ;;
            4) insertIntoTable ;;
            5) selectFromTable ;;
            6) delete_from_table ;;
            7) update_table ;;
            8) break ;;
            *) echo "Invalid option!" ;;
        esac
    done
}


main_menu  # Call the main menu function to start the script
