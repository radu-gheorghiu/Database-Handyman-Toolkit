# Database Handyman Toolkit
A set of SQL Scripts I have built and use for various performance tuning and administration tasks.

* check_plan_cache.sql - compatible with SQL Server versions **2008 and later**

  ***Q***: *Why did you chose to build tvfn (table valued function) instead of a stored procedure?* <br></br>
  ***A***: *Although it might seem cumbersome to create a tvfn instead of a stored procedure to return this data, because with a stored procedure you don't need to declare the format and the datatypes of all the columns in the output, I believe by doing this you get more expandability and you could easily join the result of this procedure with any other tables or views etc. without the need to declare a temporary table or table variable before, which would be necessary in the case of a stored procedure.*
  
* compare_environment_indexes.sql - compatible with SQL Server versions **2008 and later**
 Prerequisites:
  - The script assumes that the two environments you are going to compare are linked servers (hopefully your production and development databases are not on the same instance)
  - In order to run the script you need to pass fully-qualified names of the databases you want to compare - ex: *[Instance_Name].[DB_Name]*

* locking_queries.sql - compatible with SQL Server versions **2008 and later**
