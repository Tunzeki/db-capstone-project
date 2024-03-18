-- In the first task, Little Lemon need you to create a virtual table called OrdersView 
-- that focuses on OrderID, Quantity and Cost columns within the Orders table for all orders 
-- with a quantity greater than 2. 
-- Here’s some guidance around completing this task: 
-- Use a CREATE VIEW statement.
-- Extract the order id, quantity and cost data from the Orders table.
-- Filter data from the orders table based on orders with a quantity greater than 2. 
CREATE VIEW OrdersView AS 
SELECT 
    OrderID, Quantity, TotalCost
FROM Orders
WHERE Quantity > 2;

-- Query the OrdersView table
SELECT * FROM OrdersView;


-- For your second task, Little Lemon need information from four tables on all customers with orders 
-- that cost more than $150. Extract the required information from each of the following tables by 
-- using the relevant JOIN clause: 
-- Customers table: The customer id and full name.
-- Orders table: The order id and cost.
-- Menus table: The menus name.
-- MenusItems table: course name and starter name.
-- The result set should be sorted by the lowest cost amount.
SELECT 
    Customers.CustomerID,
    CONCAT(Customers.FirstName, ' ', Customers.LastName) AS FullName,
    Orders.OrderID,
    Orders.TotalCost,
    Menus.MenuName,
    MenuTypes.MenuType 
FROM Customers 
INNER JOIN Bookings USING (CustomerID)
INNER JOIN Orders USING (BookingID)
INNER JOIN Menus ON Menus.MenuID = Orders.MenuID
INNER JOIN MenuTypes ON Menus.MenuTypeID = MenuTypes.MenuTypeID
ORDER BY Orders.TotalCost ASC;


-- Little Lemon need you to find all menu items for which more than 2 orders have been placed. 
-- You can carry out this task by creating a subquery that lists the menu names from the menus table 
-- for any order quantity with more than 2.
-- Here’s some guidance around completing this task: 
-- Use the ANY operator in a subquery
-- The outer query should be used to select the menu name from the menus table.
-- The inner query should check if any item quantity in the order table is more than 2. 
SELECT 
    MenuName 
FROM Menus 
WHERE MenuID = ANY (SELECT MenuID FROM Orders WHERE Quantity > 2);


-- Little Lemon need you to create a procedure that displays the maximum ordered quantity in the Orders table. 
-- Creating this procedure will allow Little Lemon to reuse the logic implemented in the procedure easily 
-- without retyping the same code over again and again to check the maximum quantity. 
CREATE PROCEDURE GetMaxQuantity()
SELECT MAX(Quantity) AS 'Max Quantity in Order' FROM Orders;

-- Call the procedure GetMaxQuantity
CALL GetMaxQuantity();


-- Little Lemon need you to help them to create a prepared statement called GetOrderDetail. 
-- This prepared statement will help to reduce the parsing time of queries. 
-- It will also help to secure the database from SQL injections.
-- The prepared statement should accept one input argument, the CustomerID value, from a variable. 
-- The statement should return the order id, the quantity and the order cost from the Orders table. 
-- Once you create the prepared statement, you can create a variable called id and assign it value of 1.
PREPARE GetOrderDetail FROM 
'SELECT OrderID, Quantity, TotalCost FROM Customers INNER JOIN Bookings USING (CustomerID) INNER JOIN Orders USING (BookingID) WHERE CustomerID = ?';

SET @id = 1;
EXECUTE GetOrderDetail USING @id;


-- Create a stored procedure called CancelOrder. 
-- Little Lemon want to use this stored procedure to delete an order record based on the user input of the order id.
-- Creating this procedure will allow Little Lemon to cancel any order by specifying the order id value 
-- in the procedure parameter without typing the entire SQL delete statement.
DELIMITER //

CREATE PROCEDURE CancelOrder(IN UserOrderID INT)
BEGIN
DELETE FROM Orders WHERE OrderID = UserOrderID;
SELECT CONCAT('Order ', UserOrderID, ' is cancelled') AS Confirmation;
END //

DELIMITER ;

CALL CancelOrder(5);


-- Little Lemon wants to populate the Bookings table of their database with some records of data. 
-- Your first task is to replicate the list of records in the following table by adding them 
-- to the Little Lemon booking table.
-- First, insert data into the Customers and Staff tables which will be referenced in the Bookings table
INSERT INTO Customers(CustomerID, FirstName, LastName, PhoneNumber)
VALUES
(1, 'John', 'Doe', '12345'),
(2, 'Mary', 'Jane', '13678'),
(3, 'Leslie', 'Cooper', '32560');

INSERT INTO Staff(StaffID, FirstName, LastName, `Role`, Salary)
VALUE (1, 'Titi', 'Tomomewo', 'Manager', '100000');

-- Then, insert data into the Bookings table

INSERT INTO Bookings (BookingID, BookingDate, ReservationDate, TableNumber, NumberOfGuests, CustomerID, StaffID)
VALUES
(1, '2022-10-10 12:00:00', '2022-10-10 18:00:00', 5, 2, 1, 1),
(2, '2022-11-12 15:00:00', '2022-11-12 19:00:00', 3, 2, 3, 1),
(3, '2022-10-11 10:00:00', '2022-10-11 20:00:00', 2, 2, 2, 1),
(4, '2022-10-13 00:00:00', '2022-10-13 18:00:00', 2, 2, 1, 1)

-- Confirm that the data was correctly inserted
SELECT 
    BookingID,
    DATE(BookingDate) AS BookingDate,
    TableNumber,
    CustomerID
FROM Bookings;


-- Little Lemon need you to create a stored procedure called CheckBooking to check whether a table 
-- in the restaurant is already booked. Creating this procedure helps to minimize the effort involved 
-- in repeatedly coding the same SQL statements.
-- The procedure should have two input parameters in the form of booking date and table number. 
-- You can also create a variable in the procedure to check the status of each table.
DELIMITER //

CREATE PROCEDURE CheckBooking (IN CustomerBookingDate VARCHAR(45), IN CustomerTableNumber INT)
BEGIN 
DECLARE TableNumberOfInterest INT;

SELECT TableNumber INTO TableNumberOfInterest FROM Bookings
WHERE DATE(BookingDate) = CustomerBookingDate AND TableNumber = CustomerTableNumber;

SELECT 
    IF TableNumberOfInterest = CustomerTableNumber
    THEN CONCAT('Table ', CustomerTableNumber, ' is already booked')
    ELSE CONCAT('Table ', CustomerTableNumber, ' is available for booking')
    END IF AS 'Booking status';
END //

DELIMITER ;

DELIMITER //

CREATE PROCEDURE CheckBooking (IN CustomerBookingDate VARCHAR(45), IN CustomerTableNumber INT)
BEGIN 
DECLARE TableNumberOfInterest INT;

SELECT TableNumber INTO TableNumberOfInterest FROM Bookings
WHERE DATE(BookingDate) = CustomerBookingDate AND TableNumber = CustomerTableNumber;

SELECT 
    IF(
        CustomerTableNumber = TableNumberOfInterest, 
        CONCAT('Table ', CustomerTableNumber, ' is already booked'), 
        CONCAT('Table ', CustomerTableNumber, ' is available for booking')
    ) AS 'Booking status';
END //

DELIMITER ;

CALL CheckBooking('2022-11-12', 3);



