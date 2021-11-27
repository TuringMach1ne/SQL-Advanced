
###########################################################
#
#		 SQL ADVANCED QUERIES
#
#               @Author: TuringMach1ne
#
###########################################################

CREATE TABLE Item (
    ItemName VARCHAR (30) NOT NULL,
    ItemType CHAR(1) NOT NULL,
    ItemColour VARCHAR(10),
    PRIMARY KEY (ItemName));

CREATE TABLE Employee (
    EmployeeNumber SMALLINT UNSIGNED NOT NULL,
    EmployeeName VARCHAR(10) NOT NULL,
    EmployeeSalary INTEGER UNSIGNED NOT NULL,
    DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
    BossNumber SMALLINT UNSIGNED NOT NULL REFERENCES Employee,
    PRIMARY KEY (EmployeeNumber));

CREATE TABLE Department (
    DepartmentName VARCHAR(10) NOT NULL,
    DepartmentFloor SMALLINT UNSIGNED NOT NULL,
    DepartmentPhone SMALLINT UNSIGNED NOT NULL,
    EmployeeNumber SMALLINT UNSIGNED NOT NULL REFERENCES Employee,
    PRIMARY KEY (DepartmentName));

CREATE TABLE Sale (
    SaleNumber INTEGER UNSIGNED NOT NULL,
    SaleQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    ItemName VARCHAR(30) NOT NULL REFERENCES Item,
    DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
    PRIMARY KEY (SaleNumber));

CREATE TABLE Supplier (
    SupplierNumber INTEGER UNSIGNED NOT NULL,
    SupplierName VARCHAR(30) NOT NULL,
    PRIMARY KEY (SupplierNumber));

CREATE TABLE Delivery (
    DeliveryNumber INTEGER UNSIGNED NOT NULL,
    DeliveryQuantity SMALLINT UNSIGNED NOT NULL DEFAULT 1,
    ItemName VARCHAR(30) NOT NULL REFERENCES Item,
    DepartmentName VARCHAR(10) NOT NULL REFERENCES Department,
    SupplierNumber INTEGER UNSIGNED NOT NULL REFERENCES Supplier,
    PRIMARY KEY (DeliveryNumber));

.header yes
.mode column

/*First, I print out the table names*/
.print 'The Table Names Are: '
.table
/*Importing the datasets for tables*/
.separator "\t"
.import delivery.txt Delivery
.import department.txt Department
.import employee.txt Employee
.import item.txt Item
.import sale.txt Sale
.import supplier.txt Supplier

.print '====FIRST SECTION===='

.print
.print 'Q1-1 List the Green items of Type "C"'
.print

SELECT ItemName
FROM Item
WHERE ItemType = 'C' AND ItemColour = 'Green';

.print
.print 'Q1-2 What are the names of brown items sold by the Recreation Department?'
.print

SELECT ItemName
FROM Sale
NATURAL JOIN Item
WHERE DepartmentName = 'Recreation' AND ItemColour = 'Brown';

.print
.print 'Q1-3 Which suppliers deliver compasses?'
.print

SELECT SupplierName
FROM Delivery
NATURAL JOIN Supplier
WHERE ItemName = 'Compass'
GROUP BY SupplierName;

.print
.print 'Q1-4 What items are delivered to the Books department?'
.print

SELECT ItemName
FROM Sale
WHERE DepartmentName = 'Books';

.print
.print 'Q1-5 What are the numbers and names of those employees who earn more than their managers?'
.print
/*For the SELF-JOIN, I created the same table twice, and used rows from both*/
SELECT ee.employeenumber, ee.EmployeeName FROM Employee ee, Employee mm WHERE ee.BossNumber = mm.EmployeeNumber AND ee.EmployeeSalary > mm.EmployeeSalary;

.print
.print 'Q1-6. What are the names of employees who are in the same department as their manager (as an employee), reporting the name of the employee, the department and the manager?'
.print
/*Again, for the SEL-JOIN purpose, the same table was created twice and rows from both are used*/
SELECT ee.EmployeeName, ee.DepartmentName, mm.EmployeeName AS 'BossName' FROM Employee ee, Employee mm WHERE ee.BossNumber = mm.EmployeeNumber AND ee.DepartmentName = mm.DepartmentName;

.print
.print 'Q1-7.List the departments having an average salary of over £25000.'
.print

SELECT DepartmentName, AVG(EmployeeSalary) AS 'AvgSalary' FROM Employee GROUP BY DepartmentName HAVING AVG(EmployeeSalary) > 25000 ORDER BY AVG(EmployeeSalary) DESC;

.print
.print 'Q1-8. List the name, salary and manager of the employees of the Marketing department who have a salary of over £25000.'
.print
/*Same table was created twice for SELF-JOIN*/
SELECT ee.EmployeeName, ee.EmployeeSalary, mm.EmployeeName AS 'BossName' FROM Employee ee, Employee mm WHERE ee.DepartmentName = 'Marketing' AND mm.EmployeeNumber = ee.BossNumber GROUP BY ee.EmployeeName HAVING ee.EmployeeSalary > 25000 ORDER BY ee.EmployeeSalary DESC;

.print
.print 'Q1-9.For each item, give its type, the departments that sell the item and the floor location of these departments.'
.print

SELECT DISTINCT Item.ItemName, Item.ItemType, Department.DepartmentName, Department.DepartmentFloor
FROM Item, Sale, Department WHERE Sale.ItemName = Item.ItemName AND Sale.DepartmentName = Department.DepartmentName ORDER BY Item.ItemName;

.print
.print 'Q1-10.What suppliers deliver a total quantity of items of types "C" and "N" that is altogether greater than 100?'
.print
/*Query first finds suppliers that delivers item types C and N , and refines the search to include only the ones who exceed 100*/
SELECT Supplier.SupplierName, Supplier.SupplierNumber FROM Delivery, Supplier, Item WHERE Delivery.SupplierNumber = Supplier.SupplierNumber AND Item.ItemName = Delivery.ItemName AND (ItemType = 'C' OR ItemType = 'N') GROUP BY Supplier.SupplierName HAVING SUM(DeliveryQuantity) > 100;

.print
.print
.print '====SECOND SECTION===='

.print
.print 'Q2-1. Find the suppliers that do not deliver compasses.'
.print
/*Nested query finds suppliers that deliver compasses, the first query just excludes them to project every other supplier*/
SELECT SupplierNumber, SupplierName
FROM Supplier
WHERE SupplierNumber NOT IN
  (SELECT SupplierNumber
  FROM Delivery
  WHERE ItemName = 'Compass');


.print
.print 'Q2-2. Find the name of the highest-paid employee in the Marketing Department'
.print
/*Nested query finds max salary form marketing and the first query matches it to corresponding employee*/
SELECT EmployeeName
FROM Employee
WHERE EmployeeSalary IN
  (SELECT MAX(EmployeeSalary)
  FROM Employee
  WHERE DepartmentName = 'Marketing');

.print
.print 'Alternative Solution to Q2.2 Find the name of the highest-paid employee in the Marketing Department'
.print
/* ALTERNATIVE TO Q2.2 This query lists the most earning employees in marketing department, and only shows the top row of output*/
SELECT EmployeeName
FROM Employee
WHERE Employee.DepartmentName = 'Marketing'
ORDER BY EmployeeSalary DESC
LIMIT 1;

.print
.print 'Q2-3. Find the names of the suppliers that do not supply compasses or geo-positioning systems'
.print
/*Nested query finds suppliers that deliver GPS or compass, the first query excludes what nested query finds.*/
SELECT SupplierNumber, SupplierName
FROM Supplier
WHERE SupplierNumber NOT IN
  (SELECT Delivery.SupplierNumber
  FROM Delivery
  WHERE ItemName = 'Geo positioning system' OR ItemName = 'Compass');
.print
.print


.print
.print 'Q2-4. Find the number of employees with a salary under £10000'
.print
/*Nested query finds employees with salary <1000 and the first query counts them*/
SELECT COUNT (*) AS 'NoOfEmployees'
FROM Employee
WHERE EmployeeName IN
  (SELECT EmployeeName
  FROM Employee
  WHERE EmployeeSalary < 10000);

.print
.print 'Alternative Solution to Q2.4 Find the number of employees with a salary under £10000'
.print
/*Alternative to Q2.4*/
SELECT COUNT(*) AS 'NoOfEmployees'
FROM Employee
WHERE EmployeeSalary < 10000;

.print
.print 'Q2-5. List the departments on the second floor that contain more than one employee'
.print
/*Nested query finds the departments with more than one employee, the first query narrows it down to only departments on the second floor.*/
SELECT DepartmentName
FROM Department
WHERE DepartmentFloor = 2 AND DepartmentName IN
  (SELECT DepartmentName
  FROM Employee
  GROUP BY DepartmentName
  HAVING COUNT(*) > 1);

.print
.print 'Alternative Solution to Q2.5 List the departments on the second floor that contain more than one employee'
.print
/*Alternative solution to Q2.5*/
SELECT DISTINCT Employee.DepartmentName
FROM Department, Employee
WHERE Department.DepartmentName = Employee.DepartmentName AND DepartmentFloor = 2
GROUP BY Employee.DepartmentName
HAVING COUNT (*) > 1;

.print
