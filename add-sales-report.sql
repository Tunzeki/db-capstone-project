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

--------------------------------------------------------------------------------------------------------
-- NB: The exercise in week 2 asked to create CheckBooking() and AddValidBooking() stored procedures,
-- but not a ManageBooking() stored procedure. 
-- When it was time to submit the project in week 4, they asked for a ManageBooking() stored procedure,
-- I cannot tell for sure if they meant CheckBooking() or AddValidBooking().
-- I'm going to assume they meant CheckBooking() and so, the stored procedure originally named
-- CheckingBooking() has been renamed ManageBooking()
--------------------------------------------------------------------------------------------------------


-- Little Lemon need you to create a stored procedure called CheckBooking to check whether a table 
-- in the restaurant is already booked. Creating this procedure helps to minimize the effort involved 
-- in repeatedly coding the same SQL statements.
-- The procedure should have two input parameters in the form of booking date and table number. 
-- You can also create a variable in the procedure to check the status of each table.
DELIMITER //

CREATE PROCEDURE ManageBooking (IN CustomerBookingDate VARCHAR(45), IN CustomerTableNumber INT)
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

CALL ManageBooking('2022-11-12', 3);


-- Task 3
-- Little Lemon need to verify a booking, and decline any reservations for tables that are already booked 
-- under another name. 
-- Since integrity is not optional, Little Lemon need to ensure that every booking attempt 
-- includes these verification and decline steps. However, implementing these steps requires a stored procedure 
-- and a transaction. 
-- To implement these steps, you need to create a new procedure called AddValidBooking. 
-- This procedure must use a transaction statement to perform a rollback if a customer reserves a table 
-- that’s already booked under another name.  
-- Use the following guidelines to complete this task:
-- The procedure should include two input parameters in the form of booking date and table number.
-- It also requires at least one variable and should begin with a START TRANSACTION statement.
-- Your INSERT statement must add a new booking record using the input parameter's values.
-- Use an IF ELSE statement to check if a table is already booked on the given date. 
-- If the table is already booked, then rollback the transaction. 
-- If the table is available, then commit the transaction. 
DELIMITER //

CREATE PROCEDURE AddValidBooking(IN CustomerBookingDate VARCHAR(45), IN CustomerTableNumber INT)

BEGIN
START TRANSACTION;

SET @TableNumberOfInterest = NULL;

SELECT TableNumber INTO @TableNumberOfInterest FROM Bookings
WHERE DATE(BookingDate) = CustomerBookingDate AND TableNumber = CustomerTableNumber;

IF @TableNumberOfInterest = CustomerTableNumber 
    THEN SELECT CONCAT('Table ', CustomerTableNumber, ' is already booked - booking cancelled') AS 'Booking status';
    ROLLBACK;
ELSE 
    INSERT INTO Bookings 
        (BookingDate, ReservationDate, TableNumber, NumberOfGuests, CustomerID, StaffID)
        VALUES (CustomerBookingDate, CustomerBookingDate, CustomerTableNumber, 2, 1, 1);
        SELECT CONCAT('Table ', CustomerTableNumber, ' successfully booked.') AS 'Booking status';
        COMMIT;
END IF;
END //
DELIMITER ;

-- This table is already booked
CALL AddValidBooking('2022-11-12', 3);

-- This table is available
CALL AddValidBooking('2023-01-12', 3);
 

-- You need to create a new procedure called AddBooking to add a new table booking record.
-- The procedure should include four input parameters in the form of the following bookings parameters:
-- booking id, 
-- customer id, 
-- booking date,
-- and table number
DELIMITER // 

CREATE PROCEDURE AddBooking(IN CustomerBookingID INT, IN CustomerID INT, IN CustomerBookingDate DATE, IN CustomerTableNumber INT)
BEGIN
INSERT INTO Bookings (BookingID, BookingDate, ReservationDate, TableNumber, NumberOfGuests, CustomerID, StaffID)
        VALUES (CustomerBookingID, CustomerBookingDate, CustomerBookingDate, CustomerTableNumber, 2, CustomerID, 1);

SELECT 'New Booking Added' AS Confirmation;
END //

DELIMITER ;

-- Add a booking
CALL AddBooking(9, 3, '2022-12-30', 4);


-- Little Lemon need you to create a new procedure called UpdateBooking 
-- that they can use to update existing bookings in the booking table.
-- The procedure should have two input parameters in the form of booking id and booking date. 
-- You must also include an UPDATE statement inside the procedure.
DELIMITER //

CREATE PROCEDURE UpdateBooking (IN CustomerBookingID INT, IN CustomerBookingDate DATE)
BEGIN
UPDATE Bookings SET ReservationDate = CustomerBookingDate WHERE BookingID = CustomerBookingID;
SELECT CONCAT('Booking ', CustomerBookingID, ' updated') AS 'Confirmation';
END //

DELIMITER ;

-- Update a booking
CALL UpdateBooking(9, '2022-12-17');


-- Little Lemon need you to create a new procedure called CancelBooking that they can use 
-- to cancel or remove a booking.
-- The procedure should have one input parameter in the form of booking id. 
-- You must also write a DELETE statement inside the procedure. 
DELIMITER //

CREATE PROCEDURE CancelBooking (IN CustomerBookingID INT)
BEGIN
DELETE FROM Bookings WHERE BookingID = CustomerBookingID;
SELECT CONCAT('Booking ', CustomerBookingID, ' cancelled') AS 'Confirmation';
END //

DELIMITER ;

-- Cancel a booking
CALL CancelBooking(9);