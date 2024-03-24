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
    Cost DECIMAL(6,2) NOT NULL,
    Sales DECIMAL(6,2) NOT NULL,
    Quantity INT NOT NULL,
    Discount DECIMAL(6,2) NOT NULL,
    DeliveryCost DECIMAL(6,2) NOT NULL,
    CourseName VARCHAR(45) NOT NULL,
    CuisineName VARCHAR(45) NOT NULL,
    StarterName VARCHAR(45) NOT NULL,
    DessertName VARCHAR(45) NOT NULL,
    Drink VARCHAR(45) NOT NULL,
    Sides VARCHAR(45) NOT NULL
) ENGINE=InnoDB;


-- Find out the location to keep the CSV file to be imported
SELECT @@secure_file_priv;