#!/bin/bash

Database_Dir="./DBMS"

# Create the databases directory if it doesn't exist
mkdir -p "$Database_Dir"

main_menu() {
    echo -e "\n---------------------------------------------"
    echo -e "Main Menu:                                  |"
    echo  "---------------------------------------------"
    echo "1. Create Database                          |"
    echo "2. List Databases                           |"
    echo "3. Connect To Database                      |"
    echo "4. Drop Database                            |"
    echo "5. Exit                                     |"
    echo  "---------------------------------------------"
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

    if [[ "$db_name" =~ [^a-zA-Z_] ]]; then
        echo -e "\nDatabase name can only contain letters and underscores. Please enter a valid name."
        create_database
        return
    fi

    if [[ "$db_name" =~ ^[_-] || "$db_name" =~ [_-]$ ]]; then
        echo -e "\nDatabase name cannot start or end with an underscore or hyphen. Please enter a valid name."
        create_database
        return
    fi

    if [[ "$db_name" =~ __ ]]; then
        echo -e "\nDatabase name cannot contain consecutive underscores. Please enter a valid name."
        create_database
        return
    fi

    if [[ ${#db_name} -gt 30 ]]; then
        echo -e "\nDatabase name cannot be longer than 30 characters. Please enter a valid name."
        create_database
        return
    fi

    RESERVED_WORDS="admin|database|root|system|table"
    if [[ "$db_name" =~ ^($RESERVED_WORDS)$ ]]; then
        echo -e "\nDatabase name cannot be a reserved word. Please enter a valid name."
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

    #simple is it just list all the databases that exist in the directory 



connect_database() {
    echo -e "\nConnect to Database"
    read -p "Enter database name: " dbname
    if [ -d "$Database_Dir/$dbname" ]; then
        chmod 755 "$Database_Dir/$dbname"  # Set read, write, and execute permissions
        cd "$Database_Dir/$dbname" || exit
        clear
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

    RESERVED_WORDS="admin|database|root|system|table"

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

    if [[ "$table_name" =~ [^a-zA-Z_] ]]; then
        echo -e "\nTable name can only contain letters and underscores. Please enter a valid name."
        createTable "$dbname"
        return
    fi

    if [[ "$table_name" =~ ^[_-] || "$table_name" =~ [_-]$ ]]; then
        echo -e "\nTable name cannot start or end with an underscore or hyphen. Please enter a valid name."
        createTable "$dbname"
        return
    fi

    if [[ "$table_name" =~ __ ]]; then
        echo -e "\nTable name cannot contain consecutive underscores. Please enter a valid name."
        createTable "$dbname"
        return
    fi

    if [[ ${#table_name} -gt 30 ]]; then
        echo -e "\nTable name cannot be longer than 30 characters. Please enter a valid name."
        createTable "$dbname"
        return
    fi

    if [[ "$table_name" =~ ^($RESERVED_WORDS)$ ]]; then
        echo -e "\nTable name cannot be a reserved word. Please enter a valid name."
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

        colname=$(echo "$colname" | xargs)

        if [ -z "$colname" ]; then
            echo -e "\nColumn name cannot be empty."
            ((index--))
            continue
        fi

        if [[ "$colname" == *" "* ]]; then
            echo -e "\nColumn name cannot contain spaces."
            ((index--))
            continue
        fi

        if [[ "$colname" =~ [0-9] ]]; then
            echo -e "\nColumn name cannot contain numbers."
            ((index--))
            continue
        fi

        if [[ "$colname" =~ [^a-zA-Z_] ]]; then
            echo -e "\nColumn name can only contain letters and underscores."
            ((index--))
            continue
        fi

        if [[ "$colname" =~ ^[_-] || "$colname" =~ [_-]$ ]]; then
            echo -e "\nColumn name cannot start or end with an underscore or hyphen."
            ((index--))
            continue
        fi

        if [[ "$colname" =~ __ ]]; then
            echo -e "\nColumn name cannot contain consecutive underscores."
            ((index--))
            continue
        fi

        if [[ ${#colname} -gt 30 ]]; then
            echo -e "\nColumn name cannot be longer than 30 characters."
            ((index--))
            continue
        fi

        if [[ "$colname" =~ ^($RESERVED_WORDS)$ ]]; then
            echo -e "\nColumn name cannot be a reserved word."
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
}
#so this create the table with all the possible conditions and it brings up with two files one with the table and the other is metafile


listTables() {
    echo -e "\nYour Tables:"
    tables=$(ls | grep -v '\.meta$')
    if [ -n "$tables" ]; then
        echo "---------------------------------------------"
        echo "$tables"
        echo "---------------------------------------------"
    else
        echo "There are no existing tables."
        echo "Choose option 1 from the database menu to create a Table."
    fi
} #this shows the table of columns only (that's before inserting) , it doesn't show the meta one 

dropTable() {
    read -p "Enter table name: " table_name
    if [ -f "$table_name" ]; then
        echo "--------------------------------------------------------------"
        echo "Are you sure you want to delete the table '$table_name'?"
        echo "--------------------------------------------------------------"
        echo "For yes press 1"
        echo "For no press 2"
        echo "--------------------------------------------------------------"
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
    echo -e "\nInsert into Table\n"
    read -p "Please enter the name of the table: " tableName

    if ! [[ -f "$tableName" ]]; then
        echo "Table '$tableName' does not exist. Please choose another table."
        return
    fi

    colsNum=$(awk 'END{print NR}' "$tableName.meta")
    sep="|"
    rSep="\n"
    row=""

    declare -a values

    for (( i = 2; i <= $colsNum; i++ )); do
        colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' "$tableName.meta")
        colType=$(awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' "$tableName.meta")
        colKey=$(awk 'BEGIN{FS="|"}{if(NR=='$i') print $3}' "$tableName.meta")

        echo -e "$colName ($colType) = \c"
        read data

        # Validate Input
        if [[ $colType == "int" ]]; then
            while ! [[ $data =~ ^[0-9]+$ ]]; do
                echo -e "Invalid datatype! Please enter an integer."
                echo -e "$colName ($colType) = \c"
                read data
            done
        fi

        if [[ $colKey == "PK" ]]; then
            while true; do
                if [[ $(awk -v data="$data" 'BEGIN{FS="|"}{if(NR > 1 && $'$i' == data) print $'$i'}' "$tableName") ]]; then
                    echo -e "Invalid input for Primary Key! It must be unique."
                else
                    break
                fi
                echo -e "$colName ($colType) = \c"
                read data
            done
        fi

        values+=("$data")
    done

    {
        printf "| %-20s " ""
        for ((i = 0; i < ${#values[@]}; i++)); do
            printf "| %-20s " "${values[$i]}"
        done
        printf "|\n"
    } >> "$tableName"

    if [[ $? == 0 ]]; then
        echo "Data inserted successfully."
    else
        echo "Error inserting data into table '$tableName'."
    fi
}




selectFromTable() {
    local dbname="$1"
    echo -e "\nSelect From Table\n"
    read -p "Please enter the name of the table: " table_name

    table_name=$(echo "$table_name" | xargs)

    if [ -z "$table_name" ]; then
        echo -e "\nPlease enter a correct name\n"
        selectFromTable "$dbname"
        return
    fi

    if [[ "$table_name" == *" "* ]]; then
        echo -e "\nTable name cannot contain spaces\n"
        selectFromTable "$dbname"
        return
    fi

    if [[ "$table_name" =~ [0-9] ]]; then
        echo -e "\nTable name cannot contain numbers. Please enter a valid name.\n"
        selectFromTable "$dbname"
        return
    fi

    if [ ! -f "$table_name" ]; then
        echo -e "\nTable '$table_name' does not exist\n"
        selectFromTable "$dbname"
        return
    fi
    clear
    echo -e "\n---------------------------------------------"
    echo "Select Options:                             |"
    echo "---------------------------------------------"
    echo "1. Select All                               |"
    echo "2. Select Specific Column                   |"
    echo -e "---------------------------------------------\n"
    read -p "Enter your choice (1 or 2): " choice

    case $choice in
        1)

            echo -e "\n\nTable: $table_name"
            echo "----------------------------------------------------------------------------------------------------------------"
            awk 'NR > 3' "$table_name"
            echo "----------------------------------------------------------------------------------------------------------------"
            ;;
        2)
            read -p "Please enter the column name: " column_name

            column_name=$(echo "$column_name" | xargs)

            if [ -z "$column_name" ]; then
                echo -e "\nPlease enter a correct column name\n"
                selectFromTable "$dbname"
                return
            fi

            column_index=$(awk -F '|' -v col="$column_name" '
                NR==1 {
                    for (i=1; i<=NF; i++) {
                        if ($i ~ col) {
                            print i
                        }
                    }
                }' "$table_name")

            if [ -z "$column_index" ]; then
                echo -e "\nColumn '$column_name' does not exist\n"
                selectFromTable "$dbname"
                return
            fi
            echo "---------------------------------------------"
            echo -e "\nTable: $table_name - Column: $column_name"
            awk -F '|' -v col_index="$column_index" 'NR > 3 {print $col_index}' "$table_name"
            echo "---------------------------------------------"
            ;;
        *)
            echo "Invalid choice"
            selectFromTable "$dbname"
            ;;
    esac
}

deleteFromTable() {
    echo -e "\nDelete From Table\n"
    read -p "Enter the table name: " table_name

    if ! [[ -f "$table_name" ]]; then
        echo "Table '$table_name' does not exist. Please choose another table."
        return
    fi

    echo "--------------------------------------------------------------"
    echo "Choose what you want to delete:"
    echo "--------------------------------------------------------------"
    echo "1. Delete Row"
    echo "2. Delete Column"
    echo "--------------------------------------------------------------"
    read -p "Enter your choice: " delete_choice

    case $delete_choice in
        1)
            read -p "Enter the primary key value of the row you want to delete: " pk_value
            pk_col=$(awk 'BEGIN{FS="|"}{if($3 == "PK") print $1}' "$table_name.meta")
            pk_index=$(awk -F '|' -v pk="$pk_col" 'NR==1 {for (i=1; i<=NF; i++) if ($i ~ pk) print i}' "$table_name")

            echo "--------------------------------------------------------------"
            echo "Are you sure you want to delete the row?"
            echo "--------------------------------------------------------------"
            echo "For yes press 1"
            echo "For no press 2"
            echo "--------------------------------------------------------------"
            read -p "Enter your choice: " confirm

            if [[ "$confirm" -eq 1 ]]; then
                awk -F '|' -v pk_col="$pk_index" -v pk_val="$pk_value" '
                BEGIN { OFS="|"; found=0 }
                NR == 1 { print; next }
                NR == 2 { print; next }
                NR == 3 { print; next }
                $pk_col == pk_val { found=1; next }
                { print }
                END { if (found == 0) print "Error: Primary key not found." }
                ' "$table_name" > tmpfile && mv tmpfile "$table_name"

                if [ $? -eq 0 ]; then
                    echo "Row deleted successfully."
                else
                    echo "Error deleting row."
                fi
            else
                echo "Deletion cancelled."
            fi
            ;;
        2)
            read -p "Enter the column name you want to delete: " col_name

            col_index=$(awk -F '|' -v col="$col_name" '
            NR==1 {
                for (i=1; i<=NF; i++) {
                    if ($i ~ col) {
                        print i
                    }
                }
            }' "$table_name")

            if [ -z "$col_index" ]; then
                echo "Column '$col_name' does not exist."
                return
            fi

            echo "--------------------------------------------------------------"
            echo "Are you sure you want to delete the column '$col_name'?"
            echo "--------------------------------------------------------------"
            echo "For yes press 1"
            echo "For no press 2"
            echo "--------------------------------------------------------------"
            read -p "Enter your choice: " confirm

            if [[ "$confirm" -eq 1 ]]; then
                awk -v col_index="$col_index" -F '|' '
                BEGIN { OFS="|"; }
                {
                    $col_index = ""
                    gsub(/\|+/, "|")
                    gsub(/^\|/, "")
                    gsub(/\|$/, "")
                    print
                }
                ' "$table_name" > tmpfile && mv tmpfile "$table_name"

                awk -v col_name="$col_name" -F '|' '
                BEGIN { OFS="|"; }
                NR==1 { for(i=1; i<=NF; i++) if ($i == col_name) col_index = i }
                {
                    $col_index = ""
                    gsub(/\|+/, "|")
                    gsub(/^\|/, "")
                    gsub(/\|$/, "")
                    print
                }
                ' "$table_name.meta" > tmpfile && mv tmpfile "$table_name.meta"

                if [ $? -eq 0 ]; then
                    echo "Column deleted successfully."
                else
                    echo "Error deleting column."
                fi
            else
                echo "Deletion cancelled."
            fi
            ;;
        *)
            echo "Invalid choice"
            ;;
    esac
}

updateTable() {
    echo -e "\nUpdate Table\n"
    read -p "Please enter the name of the table: " table_name

    if ! [[ -f "$table_name" ]]; then
        echo "Table '$table_name' does not exist."
        return
    fi

    # Display current table data without showing the table structure
    awk 'NR > 3' "$table_name"

    read -p "Enter the primary key value of the row you want to update: " pk_value
    pk_col=$(awk 'BEGIN{FS="|"}{if($3 == "PK") print $1}' "$table_name.meta")
    pk_index=$(awk -F '|' -v pk="$pk_col" 'NR==1 {for (i=1; i<=NF; i++) if ($i ~ pk) print i}' "$table_name")

    if [ -z "$pk_index" ]; then
        echo "Primary key column not found."
        return
    fi

    if ! awk -F '|' -v pk_col="$pk_index" -v pk_val="$pk_value" 'NR > 3 && $pk_col == pk_val {found=1} END {if (found == 0) exit 1}' "$table_name"; then
        echo "Row with primary key '$pk_value' not found."
        return
    fi

    echo -e "\nAre you sure you want to update the row with primary key '$pk_value'?"
    echo "For yes press 1"
    echo "For no press 2"
    read -p "Enter your choice: " confirm

    if [ "$confirm" -eq 1 ]; then
        declare -a values
        colsNum=$(awk 'END{print NR}' "$table_name.meta")

        for ((i = 2; i <= $colsNum; i++)); do
            colName=$(awk 'BEGIN{FS="|"}{ if(NR=='$i') print $1}' "$table_name.meta")
            colType=$(awk 'BEGIN{FS="|"}{if(NR=='$i') print $2}' "$table_name.meta")

            if [ "$colName" == "$pk_col" ]; then
                values+=("$pk_value")
                continue
            fi

            echo -e "$colName ($colType) = \c"
            read new_value

            if [[ $colType == "int" ]]; then
                while ! [[ $new_value =~ ^[0-9]+$ ]]; do
                    echo -e "Invalid datatype! Please enter an integer."
                    echo -e "$colName ($colType) = \c"
                    read new_value
                done
            fi

            values+=("$new_value")
        done

        awk -F '|' -v pk_col="$pk_index" -v pk_val="$pk_value" -v values="${values[*]}" '
        BEGIN { OFS="|"; split(values, v, " "); found=0 }
        NR == 1 { print; next }
        NR == 2 { print; next }
        NR == 3 { print; next }
        {
            if ($pk_col == pk_val) {
                found=1
                $0 = sprintf("| %-20s | %-20s | %-20s | %-20s |", "", v[1], v[2], v[3])
            }
            print
        }
        END { if (found == 0) print "Error: Primary key not found." }
        ' "$table_name" > tmpfile && mv tmpfile "$table_name"

        if [ $? -eq 0 ]; then
            echo "Row updated successfully."
        else
            echo "Error updating row."
        fi
    else
        echo "Update cancelled."
    fi
}


# Function to display the database menu
function database_menu() {
    clear
    while true; do
        echo -e "\n---------------------------------------------"
        echo -e "Database Menu:                              |"
         echo "---------------------------------------------"
        echo "1. Create Table                             |"
        echo "2. List Tables                              |"
        echo "3. Drop Table                               |"
        echo "4. Insert into Table                        |"
        echo "5. Select From Table                        |"
        echo "6. Delete From Table                        |"
        echo "7. Update Table                             |"
        echo "8. Back to Main Menu                        |"
        echo -e "---------------------------------------------\n"
        read -p "Choose an option: " option
        case $option in
            1) createTable ;;
            2) listTables ;;
            3) dropTable ;;
            4) insertIntoTable ;;
            5) selectFromTable ;;
            6) deleteFromTable ;;
            7) updateTable ;;
            8) clear 
               break ;;
            *) echo "Invalid option!" ;;
        esac
    done
}


main_menu  # Call the main menu function to start the script
