CREATE TABLE Departments (
    DeptID INTEGER PRIMARY KEY,
    DeptName TEXT
);

CREATE TABLE Employees (
    EmpID INTEGER PRIMARY KEY,
    Name TEXT,
    Salary INTEGER,
    DeptID INTEGER,
    FOREIGN KEY (DeptID) REFERENCES Departments(DeptID)
);

INSERT INTO Departments VALUES
    (1, 'HR'),
    (2, 'Engineering'),
    (3, 'Sales');

INSERT INTO Employees VALUES
    (1, 'Alice', 60000, 1),
    (2, 'Bob', 50000, 2),
    (3, 'Charlie', 70000, 1),
    (4, 'David', 65000, 3),
    (5, 'Eve', 55000, 2);

DELIMITER //
    
CREATE PROCEDURE GetEmployeesByDept(IN dept_name VARCHAR(50))
BEGIN
    SELECT e.Name, e.Salary, d.DeptName
    FROM Employees e
    JOIN Departments d ON e.DeptID = d.DeptID
    WHERE d.DeptName = dept_name;
END //
    
DELIMITER ;
CALL GetEmployeesByDept('HR');

DELIMITER //
    
CREATE FUNCTION DeptAvgSalary(dept_id INT)
RETURNS DECIMAL(10,2)
DETERMINISTIC
BEGIN
    DECLARE avgSal DECIMAL(10,2);
    SELECT AVG(Salary) INTO avgSal FROM Employees WHERE DeptID = dept_id;
    RETURN avgSal;
END //
    
DELIMITER ;
SELECT DeptAvgSalary(1);   -- Returns average salary for HR department (DeptID=1)

DELIMITER //
    
CREATE PROCEDURE GiveRaiseIfBelowAvg(
    IN emp_id INT,
    IN raise_amt INT
)
BEGIN
    DECLARE empSal INT;
    DECLARE deptAvg DECIMAL(10,2);
    DECLARE deptId INT;

    SELECT Salary, DeptID INTO empSal, deptId FROM Employees WHERE EmpID = emp_id;
    SET deptAvg = DeptAvgSalary(deptId);

    IF empSal < deptAvg THEN
        UPDATE Employees SET Salary = Salary + raise_amt WHERE EmpID = emp_id;
    END IF;
END //
    
DELIMITER ;
CALL GiveRaiseIfBelowAvg(2, 2000);   -- Gives a raise only if salary is below Engineering's average
