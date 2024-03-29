----------------------------------------------------
-- Use littlelemon database
----------------------------------------------------
USE littlelemon;

----------------------------------------------------
-- Table base_table
----------------------------------------------------

-- Create a base_table which the existing data
-- collected by Little Lemon will be imported into
CREATE TABLE IF NOT EXISTS base_table (
    RowNumber INT NOT NULL PRIMARY KEY AUTO_INCREMENT,
    OrderID VARCHAR(45) NOT NULL,
    OrderDate DATE NOT NULL,
    DeliveryDate DATE NOT NULL,
    CustomerID VARCHAR(45) NOT NULL,
    CustomerName VARCHAR(45) NOT NULL,
    City VARCHAR(45) NOT NULL,
    Country VARCHAR(45) NOT NULL,
    PostalCode VARCHAR(45) NOT NULL,
    CountryCode VARCHAR(10) NOT NULL,
    Cost DECIMAL(6,2) NOT NULL,
    Sales DECIMAL(6,3) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(6,2) NOT NULL,
    DeliveryCost DECIMAL(6,2) NOT NULL,
    CourseName VARCHAR(45) NOT NULL,
    CuisineName VARCHAR(45) NOT NULL,
    StarterName VARCHAR(45) NOT NULL,
    DessertName VARCHAR(45) NOT NULL,
    Drink VARCHAR(45) NOT NULL,
    Sides VARCHAR(45) NOT NULL
) ENGINE=InnoDB,CHARSET=utf8mb4;


-- Find out the location to keep the CSV file to be imported
SELECT @@secure_file_priv;


-- Import the CSV file containing Little Lemon data into base_table
LOAD DATA INFILE 'C:/ProgramData/MySQL/MySQL Server 8.0/Uploads/LittleLemon_data.csv'
INTO TABLE base_table
FIELDS TERMINATED BY ','
ENCLOSED BY '"'
LINES TERMINATED BY '\n'
IGNORE 1 ROWS
(
    RowNumber, OrderID, @OrderDate, @DeliveryDate, CustomerID, CustomerName, City, Country, 
    PostalCode, CountryCode, Cost, Sales, Quantity, Discount, DeliveryCost, CourseName, 
    CuisineName, StarterName, DessertName, Drink, Sides
)
SET OrderDate = STR_TO_DATE(@OrderDate, '%m/%d/%Y'), 
DeliveryDate = STR_TO_DATE(@DeliveryDate, '%m/%d/%Y');


------------------------------------------------------------------------------
-- INSERT INTO SELECT
------------------------------------------------------------------------------

-- INSERT INTO Customers ...
INSERT INTO Customers (CustomerID, FirstName, LastName)
SELECT DISTINCT CustomerID, SUBSTRING_INDEX(CustomerName, ' ', 1), SUBSTRING_INDEX(CustomerName, ' ', -1)
FROM base_table;

-- Inspect a few rows from the `Customers` table
SELECT CustomerID, FirstName, LastName FROM Customers LIMIT 10;


-- INSERT INTO Countries ...
INSERT INTO Countries (Country, CountryCode)
SELECT DISTINCT Country, CountryCode
FROM base_table;


-- INSERT INTO Cities ...
INSERT INTO Cities (City)
SELECT DISTINCT City
FROM base_table;


-- INSERT INTO Courses ...
INSERT INTO Courses (CourseName)
SELECT DISTINCT CourseName
FROM base_table;


-- INSERT INTO Cuisines ...
INSERT INTO Cuisines (CuisineName)
SELECT DISTINCT CuisineName
FROM base_table;


-- INSERT INTO Starters ...
INSERT INTO Starters (StarterName)
SELECT DISTINCT StarterName
FROM base_table;


-- INSERT INTO Desserts ...
INSERT INTO Desserts (DessertName)
SELECT DISTINCT DessertName
FROM base_table;


-- INSERT INTO Drinks ...
INSERT INTO Drinks (DrinkName)
SELECT DISTINCT Drink
FROM base_table;


-- INSERT INTO Sides ...
INSERT INTO Sides (SideName)
SELECT DISTINCT Sides
FROM base_table;


-- INSERT INTO Addresses ...
INSERT INTO Addresses (PostalCode, CityID, CountryID, CustomerID)
SELECT DISTINCT
    ba.PostalCode, 
    ci.CityID, 
    co.CountryID, 
    cu.CustomerID
FROM base_table ba
INNER JOIN Cities ci ON ba.City = ci.City
INNER JOIN Countries co ON ba.Country = co.Country
INNER JOIN Customers cu ON ba.CustomerName = CONCAT(cu.FirstName, ' ', cu.LastName); 

-- INSERT INTO Orders ...
-- Inspect the base table for `OrderID` '65-311-3002'
SELECT * FROM base_table
WHERE OrderID = '65-311-3002';

-- Drop foreign key constraints on tables referencing Orders.OrderID
ALTER TABLE Deliveries DROP FOREIGN KEY deliveries_order_id_fk;

ALTER TABLE Payments DROP FOREIGN KEY payments_order_id_fk;

-- See the arrangement of columns in the Orders table
SHOW COLUMNS FROM Orders;

-- Add a new column after OrderID column
ALTER TABLE Orders ADD COLUMN PostalCode VARCHAR(45) NOT NULL AFTER OrderID;

-- Confirm that the new column was placed after the OrderID column
SHOW COLUMNS FROM Orders;

-- Drop existing primary key
ALTER TABLE Orders DROP PRIMARY KEY; 

-- Add a composite primary key
ALTER TABLE Orders ADD PRIMARY KEY (OrderID, PostalCode);

-- Recreate the foreign key constraints on relevant tables
ALTER TABLE Deliveries ADD CONSTRAINT deliveries_order_id_fk FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE;

ALTER TABLE Payments ADD CONSTRAINT payments_order_id_fk FOREIGN KEY (OrderID) REFERENCES Orders(OrderID) ON DELETE CASCADE ON UPDATE CASCADE;

-- Rerun the modified query to insert data into the Orders table
INSERT INTO Orders 
(OrderID, PostalCode, OrderDate, CostPrice, SellingPrice, Quantity, Discount, CustomerID, CourseID, CuisineID, StarterID, DessertID, DrinkID, SideID)
SELECT DISTINCT
    ba.OrderID,
    ba.PostalCode,
    ba.OrderDate,
    ba.Cost,
    ROUND(ba.Sales, 2),
    ba.Quantity,
    ba.Discount,
    cu.CustomerID,
    co.CourseID,
    cui.CuisineID,
    st.StarterID,
    de.DessertID,
    dr.DrinkID,
    si.SideID
FROM base_table ba
INNER JOIN Customers cu ON ba.CustomerName = CONCAT(cu.FirstName, ' ', cu.LastName)
INNER JOIN Courses co ON ba.CourseName = co.CourseName
INNER JOIN Cuisines cui ON ba.CuisineName = cui.CuisineName
INNER JOIN Starters st ON ba.StarterName = st.StarterName
INNER JOIN Desserts de ON ba.DessertName = de.DessertName
INNER JOIN Drinks dr ON ba.Drink = dr.DrinkName
INNER JOIN Sides si ON ba.Sides = si.SideName;


-- INSERT INTO Deliveries ...
INSERT INTO Deliveries (DeliveryDate, DeliveryFee, AddressID, OrderID)
SELECT
    ba.DeliveryDate,
    ba.DeliveryCost,
    ad.AddressID,
    `or`.OrderID
FROM base_table ba
INNER JOIN Addresses ad ON ba.PostalCode = ad.PostalCode AND ba.CustomerID = ad.CustomerID
INNER JOIN Orders `or` ON ba.PostalCode = `or`.PostalCode AND ba.OrderID = `or`.OrderID;


-- INSERT INTO Payments ...
INSERT INTO Payments (SellingPriceAfterDiscount, DeliveryFee, AmountPaid, OrderID, DeliveryID)
SELECT
    (ROUND(ba.Sales, 2) - ba.Discount),
    ba.DeliveryCost,
    (ROUND(ba.Sales, 2) - ba.Discount + ba.DeliveryCost),
    `or`.OrderID,
    de.DeliveryID
FROM base_table ba
INNER JOIN Orders `or` ON ba.PostalCode = `or`.PostalCode AND ba.OrderID = `or`.OrderID
INNER JOIN Addresses ad ON ba.PostalCode = ad.PostalCode AND ba.CustomerID = ad.CustomerID
INNER JOIN Deliveries de ON `or`.OrderID = de.OrderID AND ad.AddressID = de.AddressID;