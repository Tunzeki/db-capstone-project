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

