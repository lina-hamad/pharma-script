#  🏥 Pharmacy Management System (shell project)
This project mimic a pharmacy vault management system, CRUD operations.


## ✨Core Features

- 📦Inventory Management:
    - Adds & delets medicines from the unventory
    - updats medecine's details
    - display what in the inventory
- 💰 Sales Managment:
    - Process medicine sales
- 📊 Reporting:
    - Low stock alerts
    - Expired medicine tracking
    - Sales period reports
    - Top selling medicines 
- 🔍Search:
    - serches for a medecine
    - customer purchase history

## 🛠️Additional Features
1. Data validations
   - Checks if numbers (prices/quantities) are valid
   - Validates date format (must be YYYY-MM-DD)
   - Prevents duplicate medicine entries

2. User-Friendly Menu
   - Easy-to-use interface with clear options
   - Navigate using keyboard arrows/numbers
   - Built with dialog for better visuals

3. Error Handling
   - Catches common errors like:
   - Invalid inputs
   - Missing files
   - Out-of-stock items

- Logs all errors to logs.txt with timestamps


## 🖥️ Main Menu
- Inventory Menu
- sales Menu
- reporting Menu
- searching Menu


## 🚀 to make the bash file excutable

```
chmod +x proj.sh
```

## 🚀to try project use these commands

To open the file:
```bash
./shell.sh
```
## Prerequisites
- `dialog`: For interactive menus  
  Install: `sudo apt install dialog`
- `bc`: For calculations  
  Install: `sudo apt install bc`

## 💊 Example: Adding a Medicine

1. Run the program:
   ```bash
   ./pharmacy.sh
2. Main Menu → Inventory Management → Add Medicine
3. Enter the medicine details when prompted:
- Medicine name: Ibuprofen
- Quantity: 50
- Price: 8.99
- Expiry date (YYYY-MM-DD): 2025-06-30
- Category: Painkiller
4. ✅ Success message:
- "Medicine added successfully"
5. The medicine will appear in inventory.txt as:
- Ibuprofen|50|8.99|2025-06-30|Painkiller
6.  ⚠️ If you enter invalid data:
- Expiry date (YYYY-MM-DD): 30-06-2025
7. ❌ Error message:
- "Invalid date format. Use YYYY-MM-DD"

