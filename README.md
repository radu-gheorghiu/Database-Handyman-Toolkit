# Database Handyman Toolkit
A set of SQL Scripts I have built and use for various performance tuning and administration tasks.

* check_plan_cache.sql - compatible with SQL Server versions **2008 and later**

  ***Q***: *Why did you chose to build tvfn (table valued function) instead of a stored procedure?* <br></br>
  ***A***: *Although it might seem cumbersome to create a tvfn instead of a stored procedure to return this data, because with a stored procedure you don't need to declare the format and the datatypes of all the columns in the output, I believe by doing this you get more expandability and you could easily join the result of this procedure with any other tables or views etc. without the need to declare a temporary table or table variable before, which would be necessary in the case of a stored procedure.*
  
* compare_environment_indexes.sql - compatible with SQL Server versions **2008 and later**

   **Synopsis**:
   - The main purpose of this script is to be used as a check after deploys to PRODUCTION. It was built to find which indexes that were tested on a DEV environment and should have gone to PROD have not been applied automatically (*hopefully all of your database changes are scripted and under version control*), then this is an easier way to find those missing indexes instead of digging through Object Explorer in SSMS.
 
  **Prerequisites**:
   - The script assumes that the two environments / databases you are going to compare are either on linked servers (hopefully your production and development databases are not on the same instance) or on the same instance
   - In order to run the script you need to pass fully-qualified names of the databases you want to compare - ex: *[Instance_Name].[DB_Name]* if you're comparing across instances

* locking_queries.sql - compatible with SQL Server versions **2008 and later**
