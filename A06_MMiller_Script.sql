--*************************************************************************--
-- Title: Assignment06
-- User: MMiller
-- Desc: This file demonstrates how to use Views
-- Change Log: 
-- 2023-02-15, MMiller, Altering file for assignment 06
-- 2017-01-01,RRoot,Created File
--**************************************************************************--


--********************************************************************--
--[ Create the Database ]--
--********************************************************************--

USE  MASTER
; 
GO

IF EXISTS (
           SELECT *
		   FROM SYS.databases 
		   WHERE NAME='Assignment06DB_MMiller'
		   )
   BEGIN 
  	 USE [MASTER]
	 ;
	 ALTER DATABASE Assignment06DB_MMiller 
	   SET SINGLE_USER 
	   WITH ROLLBACK IMMEDIATE -- Kicks everyone out of the DB
	 ;
	 DROP DATABASE Assignment06DB_MMiller
	 ;
    END
GO

CREATE DATABASE Assignment06DB_MMiller
; 
GO

USE Assignment06DB_MMiller
;
GO


--********************************************************************--
--[ Create the Tables ]--
--********************************************************************--

CREATE TABLE t_CATEGORIES
    (CATEGORY_ID int IDENTITY (1,1) NOT NULL 
                 CONSTRAINT pkc_CATEGORY_ID 
				 PRIMARY KEY CLUSTERED (CATEGORY_ID) -- IDENTITY (starts using,interval)
   , CATEGORY_NAME nvarchar(100) NOT NULL
    );
GO

CREATE TABLE t_PRODUCTS
    (PRODUCT_ID int IDENTITY (1,1) NOT NULL 
                 CONSTRAINT pkc_PRODUCT_ID 
				 PRIMARY KEY CLUSTERED (PRODUCT_ID)
   , PRODUCT_NAME nvarchar(100) NOT NULL
   , CATEGORY_ID int NULL 
                 CONSTRAINT fk_PRODUCT_CATEGORY_ID 
				 FOREIGN KEY (CATEGORY_ID) REFERENCES t_CATEGORIES(CATEGORY_ID) --ON DELETE CASCADE
   , PRODUCT_UNIT_PRICE money NOT NULL
    );
GO
 
 CREATE TABLE t_EMPLOYEES
    (EMPLOYEE_ID int IDENTITY(1,1) NOT NULL 
                 CONSTRAINT pkc_EMPLOYEE_ID 
				 PRIMARY KEY CLUSTERED (EMPLOYEE_ID) 
   , EMPLOYEE_FIRST_NAME NVARCHAR(100) NOT NULL 
   , EMPLOYEE_LAST_NAME NVARCHAR(100) NOT NULL
   , MANAGER_ID int NULL 
                 CONSTRAINT fk_MANAGER_ID 
				 FOREIGN KEY (MANAGER_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID)
    );
GO
  
 CREATE TABLE t_INVENTORY
    (INVENTORY_ID int IDENTITY(1,1) NOT NULL 
               CONSTRAINT pk_INVENTORY_ID 
			   PRIMARY KEY CLUSTERED (INVENTORY_ID)
   , INVENTORY_DATE date NOT NULL
   , EMPLOYEE_ID int NOT NULL 
               CONSTRAINT fk_INVENTORY_TO_EMPLOYEES 
			   FOREIGN KEY (EMPLOYEE_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID) 
   , PRODUCT_ID int NOT NULL 
               CONSTRAINT fk_INVENTORY_PRODUCT_ID 
			   FOREIGN KEY (PRODUCT_ID) REFERENCES t_PRODUCTS(PRODUCT_ID) --ON DELETE CASCADE
   , INVENTORY_COUNT int NOT NULL
    );
GO

 --********************************************************************--
--[ Add Addtional Constaints ]--
--********************************************************************--

-- Table Constraints: Categories (Table 1 of 4)
BEGIN
/*   ALTER TABLE dbo.t_CATEGORIES -- moved action to table creation avoid script run error
	   ADD CONSTRAINT pkc_CATEGORY_ID 
	   PRIMARY KEY CLUSTERED (CATEGORY_ID)
	 ;
*/
	 ALTER TABLE dbo.t_CATEGORIES
	   ADD CONSTRAINT uq_CATEGORY_NAME
	   UNIQUE NONCLUSTERED (CATEGORY_NAME) -- Non-clustered is not ordered, is slower, requires a lookup, and is not stored with table.
     ;
END
GO

-- Table Constraints: Products (Table 2 of 4)
BEGIN
/*   ALTER TABLE dbo.t_PRODUCTS -- moved action to table creation avoid script run error
       ADD CONSTRAINT pkc_PRODUCT_ID
	   PRIMARY KEY CLUSTERED (PRODUCT_ID)
	 ;
*/
     ALTER TABLE dbo.t_PRODUCTS
       ADD CONSTRAINT uq_PRODUCT_NAME
	   UNIQUE (PRODUCT_NAME)
	 ;

/*   ALTER TABLE dbo.t_PRODUCTS -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_PRODUCT_CATEGORY_ID
	   FOREIGN KEY (CATEGORY_ID) REFERENCES t_CATEGORIES(CATEGORY_ID)
	 ;
*/
     ALTER TABLE dbo.t_PRODUCTS
       ADD CONSTRAINT ck_PRODUCT_UNIT_PRICE_EqGt0
	   CHECK (Product_Unit_Price >= 0)
	 ;
END
GO

-- Table Constraints: Employees (Table 3 of 4)
/*
BEGIN
     ALTER TABLE dbo.t_Employees -- moved action to table creation avoid script run error
       ADD CONSTRAINT pkc_EMPLOYEE_ID
       PRIMARY KEY CLUSTERED (EMPLOYEE_ID)
     ;
     ALTER TABLE dbo.t_Employees -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_MANAGER_ID
       FOREIGN KEY (MANAGER_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID)
     ;
END
GO
*/

-- Table Constraints: Inventory (Table 4 of 4)
BEGIN
/*
     ALTER TABLE dbo.t_INVENTORY -- moved action to table creation avoid script run error
       ADD CONSTRAINT pk_INVENTORY_ID
       PRIMARY KEY (INVENTORY_ID)
     ;
*/
     ALTER TABLE dbo.t_INVENTORY
       ADD CONSTRAINT df_INVENTORY_DATE
       DEFAULT GETDATE() FOR INVENTORY_DATE
     ;
/*
     ALTER TABLE dbo.t_INVENTORY -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_INVENTORY_PRODUCT_ID
       FOREIGN KEY (PRODUCT_ID) REFERENCES t_PRODUCTS(PRODUCT_ID)
     ;
*/
     ALTER TABLE dbo.t_INVENTORY
       ADD CONSTRAINT ck_INVENTORY_COUNT_EqGt0
       CHECK ([INVENTORY_COUNT] >= 0)
     ; 
/*
     ALTER TABLE dbo.t_INVENTORY -- moved action to table creation avoid script run error
       ADD CONSTRAINT fk_INVENTORY_TO_EMPLOYEES
       FOREIGN KEY (EMPLOYEE_ID) REFERENCES t_EMPLOYEES(EMPLOYEE_ID)
     ;
*/
END
GO


--********************************************************************--
--[ Adding Data ]--
--********************************************************************--

-- Categories Data (Table 1 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment06DB_MMiller.dbo.t_CATEGORIES
                  (CATEGORY_NAME)
            SELECT CATEGORYNAME
		      FROM NORTHWIND.dbo.CATEGORIES
		  ORDER BY CategoryID
	 COMMIT TRANSACTION
	 ;
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Categories not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

-- Products Data (Table 2 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment06DB_MMiller.dbo.t_PRODUCTS 
                  (PRODUCT_NAME
				 , CATEGORY_ID
				 , PRODUCT_UNIT_PRICE)
            SELECT PRODUCTNAME AS PRODUCT_NAME
			     , CATEGORYID AS CATEGORY_ID
				 , UNITPRICE AS PRODUCT_UNIT_PRICE
		      FROM NORTHWIND.dbo.PRODUCTS
		  ORDER BY ProductID
	 COMMIT TRANSACTION
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Products not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

-- Employees Data (Table 3 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment06DB_MMiller.dbo.t_EMPLOYEES
                  (EMPLOYEE_FIRST_NAME
				 , EMPLOYEE_LAST_NAME
				 , MANAGER_ID)
            SELECT e.FIRSTNAME as EMPLOYEE_FIRST_NAME
		         , e.LASTNAME as EMPLOYEE_LAST_NAME
			     , IsNULL (e.ReportsTo, e.EmployeeID)
		      FROM NORTHWIND.dbo.EMPLOYEES e
		  ORDER BY e.EmployeeID
	 COMMIT TRANSACTION
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Employees not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

-- Inventory Data (Table 4 of 4)
BEGIN TRY
     BEGIN TRANSACTION
       INSERT INTO Assignment06DB_MMiller.dbo.t_INVENTORY
                  (INVENTORY_DATE
				 , EMPLOYEE_ID
				 , PRODUCT_ID
				 , INVENTORY_COUNT)
         SELECT '20170101' AS INVENTORY_DATE
		       , 5 AS EMPLOYEE_ID
			   , ProductID AS PRODUCT_ID
			   , UnitsInStock AS INVENTORY_COUNT
           FROM NORTHWIND.dbo.PRODUCTS
          UNION
         SELECT '20170201' AS INVENTORYDATE
		       , 7 AS EMPLOYEE_ID
			   , ProductID AS PRODUCT_ID
			   , UnitsInStock + 10 AS INVENTORY_COUNT -- Using this is to create a made up value
           FROM NORTHWIND.dbo.PRODUCTS
          UNION
         SELECT '20170301' AS INVENTORYDATE
		       , 9 AS EMPLOYEE_ID
			   , ProductID AS PRODUCT_ID
			   , UnitsInStock + 20 AS INVENTORY_COUNT -- Using this is to create a made up value
		   FROM NORTHWIND.dbo.PRODUCTS 
		  ORDER BY 1, 2
	  COMMIT TRANSACTION
END TRY
BEGIN CATCH
     ROLLBACK TRANSACTION
	 ;
	 PRINT N'ERROR - Inventory not entered. Please check data being entered!'
	 ;
	 PRINT Error_Message() -- original RDMS
	 ;
END CATCH
GO

--********************************************************************--
--[ Show Data Tables ]--
--********************************************************************--
--SELECT * FROM ASSIGNMENT06DB_MMiller.dbo.t_CATEGORIES;
--SELECT * FROM ASSIGNMENT06DB_MMiller.dbo.t_PRODUCTS;
--SELECT * FROM ASSIGNMENT06DB_MMiller.dbo.t_EMPLOYEES;
--SELECT * FROM ASSIGNMENT06DB_MMiller.dbo.t_INVENTORY;



--********************************************************************--
--[ Questions and Answers ]--
--********************************************************************--
PRINT 
 'NOTES------------------------------------------------------------------------------------ 
  1) You can use any name you like for you views, but be descriptive and consistent
  2) You can use your working code from assignment 5 for much of this assignment
  3) You must use the BASIC views for each table after they are created in Question 1
  ------------------------------------------------------------------------------------------'
;
GO

-- Question 1 (5% pts): How can you create BACIC views to show data from each table in the database.
-- NOTES: 1) Do not use a *, list out each column!
--        2) Create one view per table!
--		  3) Use SchemaBinding to protect the views from being orphaned!


CREATE VIEW dbo.v_CATEGORIES WITH SCHEMABINDING
       AS
       SELECT 
         c.CATEGORY_ID
	   , c.CATEGORY_NAME
	   FROM dbo.t_CATEGORIES c
;
GO
				-- Testing Order By DESC vs ASC 
				-- SELECT * FROM Assignment06DB_MMiller.dbo.CATEGORIES ORDER BY Category_name ASC
				-- SELECT * FROM Assignment06DB_MMiller.dbo.CATEGORIES ORDER BY Category_name DESC

CREATE VIEW dbo.v_PRODUCTS WITH SCHEMABINDING
       AS
       SELECT
         p.PRODUCT_ID
	   , p.PRODUCT_NAME 
	   , p.CATEGORY_ID
	   , p.PRODUCT_UNIT_PRICE 
	     FROM dbo.t_PRODUCTS p
; 
GO
CREATE VIEW dbo.v_EMPLOYEES WITH SCHEMABINDING
       AS
       SELECT
         e.EMPLOYEE_ID
	   , e.EMPLOYEE_FIRST_NAME 
	   , e.EMPLOYEE_LAST_NAME
	   , e.MANAGER_ID 
	     FROM dbo.t_EMPLOYEES e
; 
GO

CREATE VIEW dbo.v_INVENTORY WITH SCHEMABINDING
       AS
       SELECT
         i.INVENTORY_ID
	   , i.INVENTORY_DATE 
	   , i.EMPLOYEE_ID
	   , i.PRODUCT_ID
	   , i.INVENTORY_COUNT
	     FROM dbo.t_INVENTORY i
; 
GO

			     --[ Show Views Created ]--
			     --SELECT * FROM dbo.v_CATEGORIES;
			     --SELECT * FROM dbo.v_PRODUCTS;
			     --SELECT * FROM dbo.v_EMPLOYEES;
			     --SELECT * FROM dbo.v_INVENTORY; 

-- Question 2 (5% pts): How can you set permissions, so that the public group CANNOT select data 
-- from each table, but can select data from each view?

--PERMISSIONS DENY
   DENY SELECT ON Assignment06DB_MMiller.dbo.t_CATEGORIES to
               PUBLIC;
   DENY SELECT ON Assignment06DB_MMiller.dbo.t_PRODUCTS to 
               PUBLIC;
   DENY SELECT ON Assignment06DB_MMiller.dbo.t_EMPLOYEES to
               PUBLIC;
   DENY SELECT ON Assignment06DB_MMiller.dbo.t_INVENTORY to 
               PUBLIC;
GO
--PERMISSIONS GRANT
   GRANT SELECT ON Assignment06DB_MMiller.dbo.t_CATEGORIES to
               PUBLIC;
   GRANT SELECT ON Assignment06DB_MMiller.dbo.t_PRODUCTS to 
               PUBLIC;
   GRANT SELECT ON Assignment06DB_MMiller.dbo.t_EMPLOYEES to
               PUBLIC;
   GRANT SELECT ON Assignment06DB_MMiller.dbo.t_INVENTORY to 
               PUBLIC;
GO   
				-- TEST DENY:
				-- SELECT * FROM Assignment06DB_MMiller.dbo.t_CATEGORIES

				-- TEST GRANT:
				-- SELECT * FROM Assignment06DB_MMiller.dbo.t_CATEGORIES

				-- TO DO:
			    -- a) Ask how do you test DENY to PUBLIC, when as author you alway have GRANT?


-- Question 3 (10% pts): How can you create a view to show a list of Category and Product names, 
-- and the price of each product?
-- Order the result by the Category and Product!

			    -- Views (not tables) being referenced:
			    -- SELECT * FROM dbo.v_CATEGORIES vc
			    -- SELECT * FROM dbo.v_PRODUCTS vp

CREATE VIEW v_PRODUCTS_byCATEGORY WITH SCHEMABINDING
       AS
	   SELECT TOP 1000
              vc.CATEGORY_NAME AS CATEGORY
            , vp.PRODUCT_NAME AS PRODUCT
            , vp.PRODUCT_UNIT_PRICE AS PRICE
         FROM dbo.v_PRODUCTS vp
        RIGHT JOIN dbo.v_CATEGORIES vc ON vp.CATEGORY_ID = vc.CATEGORY_ID
        ORDER BY 
              vc.CATEGORY_NAME
            , vp.PRODUCT_NAME
;
GO 
			    -- Check new view
			    -- SELECT * FROM dbo.v_PRODUCTS_byCATEGORY


-- Question 4 (10% pts): How can you create a view to show a list of Product names 
-- and Inventory Counts on each Inventory Date?
-- Order the results by the Product, Date, and Count!

CREATE VIEW v_INVENTORY_PRODUCTS_byDATE WITH SCHEMABINDING
       AS
	   SELECT TOP 1000 
	          vp.PRODUCT_NAME AS [PRODUCT]
		    , vi.INVENTORY_COUNT AS [COUNT]
		    , vi.INVENTORY_DATE AS [INVENTORY_DATE]         
         FROM dbo.v_INVENTORY vi
         JOIN dbo.v_PRODUCTS vp ON vi.PRODUCT_ID = vp.PRODUCT_ID
        ORDER BY
		      vp.PRODUCT_NAME
			, vi.INVENTORY_DATE ASC
			, vi.INVENTORY_COUNT
;
GO
                -- Check new view
	            -- SELECT * FROM dbo.v_INVENTORY_PRODUCTS_byDATE


-- Question 5 (10% pts): How can you create a view to show a list of Inventory Dates 
-- and the Employee that took the count?
-- Order the results by the Date and return only one row per date!

CREATE VIEW v_INVENTORY_byEMPLOYEE_byDATE WITH SCHEMABINDING
       AS
	   SELECT TOP 1000
	          vi.INVENTORY_DATE AS [INVENTORY_DATE]
		    , ve.EMPLOYEE_FIRST_NAME + ' ' + ve.EMPLOYEE_LAST_NAME AS [EMPLOYEE_NAME]
         FROM dbo.v_INVENTORY vi
		 JOIN dbo.v_EMPLOYEES ve ON vi.EMPLOYEE_ID = ve.EMPLOYEE_ID
		GROUP BY
		      vi.INVENTORY_DATE
			, ve.EMPLOYEE_FIRST_NAME + ' ' + ve.EMPLOYEE_LAST_NAME
        ORDER BY
		      vi.INVENTORY_DATE ASC
;
GO
                -- Check new view
	            -- SELECT * FROM dbo.v_INVENTORY_byEMPLOYEE_byDATE

				-- Here is are the rows selected from the view:
				-- InventoryDate	EmployeeName
				-- 2017-01-01	    Steven Buchanan
				-- 2017-02-01	    Robert King
				-- 2017-03-01	    Anne Dodsworth


-- Question 6 (10% pts): How can you create a view show a list of Categories, Products, 
-- and the Inventory Date and Count of each product?
-- Order the results by the Category, Product, Date, and Count!

CREATE VIEW v_INVENTORY_PRODUCTS_withCATEGORY WITH SCHEMABINDING
       AS
	   SELECT TOP 1000 
	          vc.CATEGORY_NAME
			, vp.PRODUCT_NAME
			, vi.INVENTORY_DATE
			, vi.INVENTORY_COUNT
         FROM dbo.v_CATEGORIES vc
		 JOIN dbo.v_PRODUCTS vp  ON vc.CATEGORY_ID = vp.CATEGORY_ID
		 JOIN dbo.v_INVENTORY vi ON vp.PRODUCT_ID = vi.PRODUCT_ID 
        ORDER BY
	          vc.CATEGORY_NAME
			, vp.PRODUCT_NAME
			, vi.INVENTORY_DATE ASC
			, vi.INVENTORY_COUNT
;
GO
                -- Check new view
	            -- SELECT * FROM dbo.v_INVENTORY_PRODUCTS_withCATEGORY


-- Question 7 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the EMPLOYEE who took the count?
-- Order the results by the Inventory Date, Category, Product and Employee!

CREATE VIEW v_INVENTORY_PRODUCTS_byEMPLOYEE WITH SCHEMABINDING
       AS
	   SELECT TOP 1000
	          vc.CATEGORY_NAME AS [CATEGORY]
			, vp.PRODUCT_NAME AS [PRODUCT]
			, vi.INVENTORY_DATE AS [INVENTORY_DATE]
			, vi.INVENTORY_COUNT AS [COUNT]
			, ve.EMPLOYEE_FIRST_NAME +' '+ ve.EMPLOYEE_LAST_NAME AS [EMPLOYEE]
         FROM dbo.v_CATEGORIES vc
		 JOIN dbo.v_PRODUCTS vp  ON vc.CATEGORY_ID = vp.CATEGORY_ID
		 JOIN dbo.v_INVENTORY vi ON vp.PRODUCT_ID = vi.PRODUCT_ID 
		 JOIN dbo.v_EMPLOYEES ve ON vi.EMPLOYEE_ID = ve.EMPLOYEE_ID
        ORDER BY
	          vi.INVENTORY_DATE ASC
			, vc.CATEGORY_NAME
			, vp.PRODUCT_NAME
			, ve.EMPLOYEE_FIRST_NAME
;
GO
                -- Check new view
	            -- SELECT * FROM dbo.v_INVENTORY_PRODUCTS_byEMPLOYEE
				
-- Question 8 (10% pts): How can you create a view to show a list of Categories, Products, 
-- the Inventory Date and Count of each product, and the Employee who took the count
-- for the Products 'Chai' and 'Chang'? 

CREATE VIEW v_INVENTORY_for_CHAI_and_CHANG_byEMPLOYEE WITH SCHEMABINDING
       AS
	   SELECT TOP 1000
	          vc.CATEGORY_NAME AS [CATEGORY]
			, vp.PRODUCT_NAME AS [PRODUCT]
			, vi.INVENTORY_DATE AS [INVENTORY_DATE]
			, vi.INVENTORY_COUNT AS [COUNT]
			, ve.EMPLOYEE_FIRST_NAME +' '+ ve.EMPLOYEE_LAST_NAME AS [EMPLOYEE]
         FROM dbo.v_CATEGORIES vc
		 JOIN dbo.v_PRODUCTS vp  ON vc.CATEGORY_ID = vp.CATEGORY_ID
		 JOIN dbo.v_INVENTORY vi ON vp.PRODUCT_ID = vi.PRODUCT_ID 
		 JOIN dbo.v_EMPLOYEES ve ON vi.EMPLOYEE_ID = ve.EMPLOYEE_ID
		WHERE vp.PRODUCT_NAME IN ('CHAI', 'CHANG')
        ORDER BY
	          vi.INVENTORY_DATE ASC
			, vc.CATEGORY_NAME
			, vp.PRODUCT_NAME
			, ve.EMPLOYEE_FIRST_NAME
;
GO
                -- Check new view
	            -- SELECT * FROM dbo.v_INVENTORY_for_CHAI_and_CHANG_byEMPLOYEE


-- Question 9 (10% pts): How can you create a view to show a list of Employees and the Manager who manages them?
-- Order the results by the Manager's name!

CREATE VIEW v_EMPLOYEES_byMANAGER WITH SCHEMABINDING
       AS
	   SELECT TOP 1000
			  vm.EMPLOYEE_FIRST_NAME +' '+ vm.EMPLOYEE_LAST_NAME AS [MANAGER]
            , ve.EMPLOYEE_FIRST_NAME +' '+ ve.EMPLOYEE_LAST_NAME AS [EMPLOYEE]
        FROM dbo.v_EMPLOYEES vm 
		JOIN dbo.v_EMPLOYEES ve ON vm.EMPLOYEE_ID = ve.MANAGER_ID
        ORDER BY
	          vm.EMPLOYEE_FIRST_NAME ASC
		    , ve.EMPLOYEE_FIRST_NAME
;
GO
                -- Check new view
	            -- SELECT * FROM dbo.v_EMPLOYEES_byMANAGER


-- Question 10 (20% pts): How can you create one view to show all the data from all four 
-- BASIC Views? Also show the Employee's Manager Name and order the data by 
-- Category, Product, InventoryID, and Employee.

CREATE VIEW v_INVENTORY_PRODUCTS_byCATEGORY_byEMPLOYEE WITH SCHEMABINDING
       AS
	   SELECT TOP 1000 
              vc.CATEGORY_ID
            , vc.CATEGORY_NAME
			, vp.PRODUCT_ID
			, vp.PRODUCT_NAME
			, vp.PRODUCT_UNIT_PRICE AS [PRICE]
			, vi.INVENTORY_ID
			, vi.INVENTORY_DATE
			, vi.INVENTORY_COUNT AS [COUNT]
			, ve.EMPLOYEE_ID 
			, ve.EMPLOYEE_FIRST_NAME + ' ' + ve.EMPLOYEE_LAST_NAME AS [EMPLOYEE]
			, vm.EMPLOYEE_FIRST_NAME + ' ' + vm.EMPLOYEE_LAST_NAME AS [MANAGER]
        FROM dbo.v_CATEGORIES vc
		JOIN dbo.v_PRODUCTS vp ON vp.CATEGORY_ID = vc.CATEGORY_ID
		JOIN dbo.v_INVENTORY vi ON vi.PRODUCT_ID = vp.PRODUCT_ID
		JOIN dbo.v_EMPLOYEES ve ON ve.EMPLOYEE_ID = vi.EMPLOYEE_ID
		JOIN dbo.v_EMPLOYEES vm ON vm.EMPLOYEE_ID = ve.MANAGER_ID
        ORDER BY
	          vc.CATEGORY_NAME
			, vp.PRODUCT_NAME
			, vi.INVENTORY_ID	
;
GO
                -- Check new view
	            -- v_INVENTORY_PRODUCTS_byCATEGORY_byEMPLOYEE


-- Test your Views (NOTE: You must change the your view names to match what I have below!)

Print 'Note: You will get an error until the views are created!'; 
Select * From dbo.v_CATEGORIES;
Select * From dbo.v_PRODUCTS;
Select * From dbo.v_INVENTORY;
Select * From dbo.v_EMPLOYEES;

Select * From dbo.v_PRODUCTS_byCATEGORY;
Select * From dbo.v_INVENTORY_PRODUCTS_byDATE;
Select * From dbo.v_INVENTORY_byEMPLOYEE_byDATE;
Select * From dbo.v_INVENTORY_PRODUCTS_withCATEGORY;
Select * From dbo.v_INVENTORY_PRODUCTS_byEMPLOYEE;
Select * From dbo.v_INVENTORY_for_CHAI_and_CHANG_byEMPLOYEE;
Select * From dbo.v_EMPLOYEES_byMANAGER;
Select * From dbo.v_INVENTORY_PRODUCTS_byCATEGORY_byEMPLOYEE;

/***************************************************************************************/