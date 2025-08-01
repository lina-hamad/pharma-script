
#!/bin/bash
#######################################
# Pharmacy Management System (PMS)
# ENCS3130 Linux Lab Project
# Authors: Lina hamad
# Date: 01/05/2025
#######################################
# ** Note: there are some sleep commands in the code to make it easier to read and understand the output **
# the below 2 if statements are for checking if the required packages are installed
if ! command -v dialog &> /dev/null; then
    echo "Error: 'dialog' package required. Install with: sudo apt install dialog" >&2
    exit 1
fi

if ! command -v bc &> /dev/null; then
    echo "Error: 'bc' package required. Install with: sudo apt install bc" >&2
    exit 1
fi
# create the required files if they don't exist
touch inventory.txt sales.txt customer.txt
# validation functions:
is_valid_number() {
    if [[ $1 =~ ^[0-9]+(\.[0-9]+)?$ ]]
    then
        return 0
    else
        return 1
    fi  
}
is_valid_date() {
    if [[ $1 =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]
    then
        year=${1:0:4}
        month=${1:5:2}
        day=${1:8:2}
        if [[ $month -ge 1 && $month -le 12 && $day -ge 1 && $day -le 31 ]]
        then
            return 0
        else
            return 1
        fi
    else
        return 1
    fi
}
is_valid_phone() {
    if [[ $1 =~ ^[0-9]{10}$ ]]; then
          return 0
    else
          return 1
    fi
}
is_There(){
    if [ ! -f "inventory.txt" ]; then
        echo "Inventory file not found." >> logs.txt
        echo "Inventory file not found."
        return 1
    fi
    lines=` wc -l inventory.txt | cut -d' ' -f1`
    for (( i=1; i<= "$lines"; i++ ))
    do
      line=`sed -n "${i}p" inventory.txt`
      name=`echo $line | cut -d"|" -f1`
      if [[ "$name" == "$1" ]]
      then
          return 0
      fi
    done
    return 1
}
#inventory managment:
# add_medicine function : adds a new medicine to the inventory , it checks if the medicine already exists and if the inputs are valid and then adds the medicine
add_medicine() {
    echo "Enter medicine name:"
    read name
    while ( is_There "$name")
    do
        echo "Medicine already exists. Please enter a different name or type 'exit' to cancel." >> logs.txt
        echo "Medicine already exists. Please enter a different name or type 'exit' to cancel."
        read name
        if [ "$name" == "exit" ]
        then
            echo "Exiting add process."
            sleep 2
            return
        fi
    done
    echo "Enter quantity:"
    read quantity
    while (! is_valid_number "$quantity")
    do
        echo "Invalid quantity. Please enter a valid number." >> logs.txt
        echo "Invalid quantity. Please enter a valid number."
        read quantity
    done
    echo "Enter price:"
    read price
    while (! is_valid_number "$price")
    do
        echo "Invalid price. Please enter a valid number." >> logs.txt
        echo "Invalid price. Please enter a valid number."
        read price
    done
    echo "Enter expiry date (YYYY-MM-DD):"
    read expiry_date
    while (! is_valid_date "$expiry_date")
    do
        echo "Invalid date format. Please enter a valid date (YYYY-MM-DD)." >> logs.txt
        echo "Invalid date format. Please enter a valid date (YYYY-MM-DD)."
        read expiry_date
    done
    echo "Enter category:"
    read category
    echo "$name|$quantity|$price|$expiry_date|$category" >> inventory.txt
    echo "Medicine added successfully."
    sleep 2
}
# update_medicine function : updates the medicine in the inventory , it checks if the medicine exists and if the inputs are valid and then updates the medicine
update_medicine(){
   echo "Enter the name of the medicine you want to update:"
    read newName
    while (! is_There "$newName")
    do
        echo "Medicine not found. Please enter a valid name , or type 'exit' to cancel." >> logs.txt
        echo "Medicine not found. Please enter a valid name , or type 'exit' to cancel."
        read newName
        if [ "$newName" == "exit" ]
        then
            echo "Exiting update process."
            sleep 2
            return
        fi
    done
    echo "Enter quantity:"
    read newQuantity
    while (! is_valid_number "$newQuantity")  
    do
        echo "Invalid quantity. Please enter a valid number." >> logs.txt
        echo "Invalid quantity. Please enter a valid number."
        read newQuantity
    done
    echo "Enter price:"
    read newPrice
    while (! is_valid_number "$newPrice") 
    do
        echo "Invalid price. Please enter a valid number." >> logs.txt
        echo "Invalid price. Please enter a valid number."
        read newPrice
    done
    sed -i "/^$newName|/s/\([^|]*|\)\([^|]*|\)\([^|]*|\)/\1$newQuantity|$newPrice|/" inventory.txt
    echo "Medicine updated successfully."
    sleep 5
}
# remove_expired_medicines function : removes the expired medicines from the inventory and adds them to a removed_medicines.txt file
# it checks if the inventory file exists and if the medicines are expired
remove_expired_medicines(){
    lines=` wc -l inventory.txt | cut -d' ' -f1` # number of lines in the file
    current_date=$(date +%Y-%m-%d)
    for (( i=1; i<= "$lines"; i++ )) # loop through the lines and check if the medicine is expired
    do
      line=`sed -n "${i}p" inventory.txt`
      expiry_date=`echo $line | cut -d'|' -f4`
      if [[ "$expiry_date" < "$current_date" ]]
      then
          sed -i "${i}d"  inventory.txt
          echo "$line" >> removed_medicines.txt
      fi
    done
    echo "Medicine removed successfully."
        sleep 5
}
# display_inventory function : displays the inventory file
# it checks if the inventory file exists and if it is empty
display_inventory() {
    echo "Current Inventory:"
    if [ -f "inventory.txt" ]; then
        cat inventory.txt
    else
        echo "No inventory file found." >> logs.txt
        echo "No inventory file found."
        return 1
    fi
    sleep 5
}
# Sales Management
# sell_medicine function : sells the medicine to the customer , it checks if the medicine exists and if the inputs are valid and then sells the medicine
sell_medicine() {
    echo "Enter customer name to sell:"
    read cname
    echo "Enter customer phone number to sell:"
    read cphone
    while (! is_valid_phone "$cphone")
    do
        echo "Invalid phone number. Please enter a valid 10-digit phone number." >> logs.txt
        echo "Invalid phone number. Please enter a valid 10-digit phone number."
        read cphone
    done
    echo "Enter medicine name to sell:"
    read mname
    while (! is_There "$mname")
    do
        echo "Medicine not found. Please enter a valid name , or type 'exit' to cancel." >> logs.txt
        echo "Medicine not found. Please enter a valid name , or type 'exit' to cancel."
        read mname
        if [ "$mname" == "exit" ]
        then
          echo "Exiting sale process."
          sleep 2
          return
        fi
    done
    echo "Enter quantity to sell:"
    read quantity
    while (! is_valid_number "$quantity")
    do
        echo "Invalid quantity. Please enter a valid number." >> logs.txt
        echo "Invalid quantity. Please enter a valid number."
        read quantity
    done
    line=`grep "$mname" inventory.txt`
    test=`echo $?`
    if [ "$test" -ne 0 ]
    then
        echo "medicine is not found" >> logs.txt
        echo "medicine is not found"
        sleep 2
     return 
    fi
    # Extracting the medicine details from the line:
    name=`echo "$line" | cut -d'|' -f1`
    q=`echo "$line" | cut -d'|' -f2`
    price=`echo "$line" | cut -d'|' -f3`
    expiry=`echo "$line" | cut -d'|' -f4`
    if [[ "$quantity" > "$q" ]]
    then
        echo "there is no enough quantity from this medicine there is just $q" 
        sleep 2
        echo -n "do you want from the available the quntity  ? (yes/no)" # ask the user if he wants to buy the available quantity
    read answer
    if [[ $answer == "no" ]]
    then
      echo "sorry"
      sleep 2
      return
    elif [[ $answer == "yes" ]]
      then
      quantity="$q"
    fi
    fi
    total_price=$(echo "$price * $quantity" | bc) # calculate the total price (bc is used for floating point calculation)
    new_quantity=$(echo "$q - $quantity" | bc) # calculate the new quantity
    sale_date=$(date +%Y-%m-%d)

    echo "$sale_date|$mname|$quantity|$total_price " >> sales.txt
    costumerhist=`grep "$cname" customer.txt`
    test=`echo $?`
    if [[ "$test" != 0 ]]
      then
        echo "$cname|$cphone|$sale_date:$total_price" >> customer.txt
        elif [[ "$test" == 0 ]]
        then # updated
        existing_history=`echo "$costumerhist" | cut -d'|' -f3`
        updated_history="$existing_history,$sale_date:$total_price"
        sed -i "/^$cname|/c\\$cname|$cphone|$updated_history" customer.txt
        #echo "$costumerhist,$sale_date:$total_price" >> customer.txt
    fi
    echo "Medicine sold successfully."
    new_quantity=$(echo "$new_quantity" | bc)
    if [ "$new_quantity" -eq 0 ] # if the quantity is 0 then remove the medicine from the inventory
    then
        sed -i "/^$mname|/d" inventory.txt
        echo "Medicine $mname is out of stock and removed from inventory."
    else
      sed -i "/^$mname|/s/\([^|]*|\)\([^|]*|\)\([^|]*|\)/\1$new_quantity|$price|/" inventory.txt
    fi
    sleep 3
}
#reporting:
# Display_low-stock_medicines function : displays the low-stock medicines in the inventory , it checks if the inventory file exists and if it is empty
# it checks if the input is valid and then displays the low-stock medicines (less than the input)
Display_low-stock_medicines(){
  echo "enter the low-stock amount:"
  read low_stock
  while (! is_valid_number "$low_stock")
  do
      echo "Invalid quantity. Please enter a valid number." >> logs.txt
      echo "Invalid quantity. Please enter a valid number."
      read low_stock
  done
    echo "Low-stock medicines:"
  lines=` wc -l inventory.txt | cut -d' ' -f1`
    for (( i=1; i<= "$lines"; i++ ))
    do
      line=`sed -n "${i}p" inventory.txt`
      amount=`echo $line | cut -d'|' -f2`
      if [ "$amount" -lt "$low_stock" ]
      then
        echo "$line"
      fi
    done
    sleep 5
}
# Show_expired_medicines function : shows the expired medicines in the inventory , it checks if the inventory file exists and if it is empty
Show_expired_medicines(){
  if (! [ -f "removed_medicines.txt" ] )
  then 
    lines=` wc -l inventory.txt | cut -d' ' -f1`
      current_date=$(date +%Y-%m-%d)
      for (( i=1; i<= "$lines"; i++ ))
      do
        line=`sed -n "${i}p" inventory.txt`
        expiry_date=`echo $line | cut -d'|' -f4`
        if [[ "$expiry_date" < "$current_date" ]]
        then
          sed -i "${i}p"  inventory.txt
      fi
    done
    sleep 5
  else
  echo "Expired medicines:"
  cat removed_medicines.txt
    sleep 5
  fi
}
# sales_Period_Report function : generates a sales report for a specific period , it checks if the input is valid and then generates the report
# by checking the sales.txt file and filtering the lines based on the input dates
sales_Period_Report(){
    echo "Enter from date (YYYY-MM-DD):"
    read from_date
    while (! is_valid_date "$from_date")
      do
          echo "Invalid date format. Please enter a valid date (YYYY-MM-DD)." >> logs.txt
          echo "Invalid date format. Please enter a valid date (YYYY-MM-DD)."
          read from_date
      done
    echo "Enter to date (YYYY-MM-DD):"
    read to_date
    while (! is_valid_date "$to_date")
      do
          echo "Invalid date format. Please enter a valid date (YYYY-MM-DD)." >> logs.txt
          echo "Invalid date format. Please enter a valid date (YYYY-MM-DD)."
          read to_date
      done
    lines=` wc -l sales.txt | cut -d" " -f1`
    for (( i=1; i<= "$lines"; i++ ))
    do
      line=`sed -n "${i}p" sales.txt`
      sale_date=`echo $line | cut -d"|" -f1`
      if [[ "$sale_date" > "$from_date" && "$sale_date" < "$to_date" ]]
      then
        echo "$line" >> sales_period.txt
      fi
    done
    echo "Sales report from $from_date to $to_date:"
    cat sales_period.txt
    rm -f sales_period.txt # remove the file after displaying it so if the user wants to generate it again it will be generated again properly
    sleep 7
}
# topKPurchaseMedicines function : displays the top K purchased medicines , it checks if the input is valid and then displays the top K purchased medicines
# by sorting the sales.txt file based on the quantity and displaying the top K lines
topKPurchaseMedicines(){
    echo "Enter the number of top medicines to display:"
    read k
    while (! is_valid_number "$k")
    do
        echo "Invalid number. Please enter a valid number." >> logs.txt
        echo "Invalid number. Please enter a valid number."
        read k
    done
    echo "Top $k purchased medicines:"
    sort -t '|' -k3,3n sales.txt | tail -n $k  # sort the sales.txt file based on the quantity and display the top K lines
    # the -t option is used to specify the delimiter and the -k option is used to specify the key to sort by
    sleep 5 
}
#Search Functionality:
# search_medicine function : searches for a medicine in the inventory , it checks if the input is valid and then searches for the medicine
# by checking the inventory.txt file and filtering the lines based on the input
# it checks if the medicine name or category matches the input
# and displays the matching lines
# if no match is found it displays a message
search_medicine() {
    echo "Enter medicine name or category to search:"
    read input
    lines=`wc -l inventory.txt | cut -d' ' -f1`
    found=0  # Flag to track if a match is found
    for (( i=1; i<=lines; i++ ))
    do
      line=`sed -n "${i}p" inventory.txt`
      name=`echo $line | cut -d"|" -f1`
      category=`echo $line | cut -d"|" -f5`
      if [ "$name" == "$input" -o "$category" == "$input" ]; then
        echo "$line"
        found=1  # Set flag to indicate a match
        sleep 2
      fi
    done
    if [ $found -eq 0 ]; then
        echo "Medicine not found." >> logs.txt
        echo "Medicine not found."
        sleep 2
    fi
}
# customer_purchase_history function : displays the purchase history of a customer , it checks if the input is valid and then displays the purchase history
# by checking the customer.txt file and filtering the lines based on the input
# it checks if the customer name matches the input
# and displays the matching lines
customer_purchase_history(){
    echo "Enter customer name to view purchase history:"
    read customer_name
    lines=` wc -l customer.txt | cut -d' ' -f1`
    for (( i=1; i<= "$lines"; i++ ))
    do
      line=`sed -n "${i}p" customer.txt`
      name=`echo $line | cut -d"|" -f1`
      flag=0
      if [[ "$name" == "$customer_name" ]]
      then
          flag=1
          echo "Purchase history:"
          echo "$line" | cut -d"|" -f3
          sleep 2
      fi
    done
    if [ "$flag" -eq 0 ]
    then
        echo "Customer not found." >> logs.txt
        echo "Customer not found."
        sleep 2
    fi
}
# Main Menu
# main_menu function : displays the main menu and handles the user input
# dialog is used to make the menu more user friendly 
# the number beside the dialog menu is the height and width of the menu
# the 16 is the number of options in the menu
# the 2>&1 >/dev/tty is used to redirect the output to the terminal
main_menu() {
  while true; do
    choice=$(dialog --menu "Pharmacy Management System" 20 70 16 \
                    "1" "Inventory Management" \
                    "2" "Sales Management" \
                    "3" "Reporting" \
                    "4" "Search" \
                    "5" "Exit" 2>&1 >/dev/tty)

    case $choice in
      1) inventory_menu ;;
      2) sales_menu ;;
      3) reporting_menu ;;
      4) searching_menu ;;
      5) exit 0 ;;
      "") echo "Cancelled." ;; 
      *) echo "Invalid choice." ;; 
    esac
  done
}

inventory_menu() {
  while true; do
    choice=$(dialog --menu "Inventory Management" 15 60 6 \
                    "1" "Add Medicine" \
                    "2" "Update Medicine" \
                    "3" "Remove Expired Medicines" \
                    "4" "Display Inventory" \
                    "5" "Back to Main Menu" 2>&1 >/dev/tty)
    case $choice in
      1) add_medicine ;;
      2) update_medicine ;;
      3) remove_expired_medicines ;;
      4) display_inventory ;;
      5) break ;;
      "") echo "Cancelled." ;;
      *) echo "Invalid choice." ;;
    esac
  done
}

sales_menu() {
  while true; do
    choice=$(dialog --menu "Sales Management" 10 60 3 \
                    "1" "Process Sale" \
                    "2" "Back to Main Menu" 2>&1 >/dev/tty)
    case $choice in
      1) sell_medicine ;;
      2) break ;;
      "") echo "Cancelled." ;;
      *) echo "Invalid choice." ;;
    esac
  done
}

reporting_menu() {
  while true; do
    choice=$(dialog --menu "Reporting" 15 60 6 \
                    "1" "Display Low Stock" \
                    "2" "Show Expired Medicines" \
                    "3" "Generate Sales Report" \
                    "4" "Top K Purchased Medicines" \
                    "5" "Back to Main Menu" 2>&1 >/dev/tty)
    case $choice in
      1) Display_low-stock_medicines ;;
      2) Show_expired_medicines ;;
      3) sales_Period_Report ;;
      4) topKPurchaseMedicines ;;
      5) break ;;
      "") echo "Cancelled." ;;
      *) echo "Invalid choice." ;;
    esac
  done
}
searching_menu(){
  while true; do
    choice=$(dialog --menu "Search" 15 60 6 \
                    "1" "Search Medicine" \
                    "2" "Customer Purchase History" \
                    "3" "Back to Main Menu" 2>&1 >/dev/tty)
    case $choice in
      1) search_medicine ;;
      2) customer_purchase_history ;;
      3) break ;;
      "") echo "Cancelled." ;;
      *) echo "Invalid choice." ;;
    esac
  done

}
# Start the main menu
main_menu
# End of script
