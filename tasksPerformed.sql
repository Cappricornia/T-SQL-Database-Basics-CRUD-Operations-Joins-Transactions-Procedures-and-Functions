
-- WMS Database

-- 1 Insert

INSERT INTO Clients (FirstName, LastName, Phone)
VALUES
    ('Teri', 'Ennaco', '570-889-5187'),
    ('Merlyn', 'Lawler', '201-588-7810'),
    ('Georgene', 'Montezuma', '925-615-5185'),
    ('Jettie', 'Mconnell', '908-802-3564'),
    ('Lemuel', 'Latzke', '631-748-6479'),
    ('Melodie', 'Knipp', '805-690-1682'),
    ('Candida', 'Corbley', '908-275-8357');


INSERT INTO Parts (SerialNumber, Description, Price, VendorId)
VALUES
    ('WP8182119', 'Door Boot Seal', 117.86, 2),
    ('W10780048', 'Suspension Rod', 42.81, 1),
    ('W10841140', 'Silicone Adhesive', 6.77, 4),
    ('WPY055980', 'High Temperature Adhesive', 13.94, 3);

GO
-- 2 Update

SELECT *
FROM Mechanics
WHERE FirstName = 'Ryan' AND LastName = 'Harnos'

UPDATE Jobs
SET [Status] = 'In Progress', MechanicId = 3
WHERE [Status] = 'Pending';

GO
-- 3 Delete

DELETE FROM OrderParts
WHERE OrderId = 19;

DELETE FROM Orders
WHERE OrderId = 19;

GO
-- Drop Database WMS and created the scripts again 
DROP DATABASE WMS

-- Run the scripts again and created tables and records again

GO
-- 4	Mechanic Assignments
-- Select, JOIN
SELECT CONCAT(m.FirstName , ' ', m.LastName) AS Mechanic,
       j.[Status],
	   j.IssueDate
FROM Mechanics AS m
JOIN Jobs AS j
ON m.MechanicId = j.MechanicId
ORDER BY m.MechanicId, j.IssueDate, j.JobId;

GO

-- 5 Current Clients

SELECT CONCAT(c.FirstName, ' ', c.LastName) AS Client,
       DATEDIFF(DAY, j.IssueDate, '2017-04-24') AS [Days going],
       j.[Status]
FROM Clients AS c
JOIN Jobs AS j
ON c.ClientId = j.ClientId
WHERE j.[Status] <> 'Finished'
ORDER BY [Days going] DESC, c.ClientId;

GO
-- 6 Mechanic Performance

SELECT Mechanic, 
       AVG([DaysWorked]) AS [Average Days]
FROM (
    SELECT m.MechanicId,
           CONCAT(m.FirstName , ' ', m.LastName) AS Mechanic,
           j.JobId,
           DATEDIFF(DAY, j.IssueDate, j.FinishDate) AS [DaysWorked]
    FROM Mechanics AS m
    JOIN Jobs AS j
    ON m.MechanicId = j.MechanicId
    WHERE j.[Status] = 'Finished'
) AS SubQDaysWorked
GROUP BY Mechanic, MechanicId
ORDER BY MechanicId;

GO
-- 7 Available Mechanics

SELECT CONCAT(FirstName, ' ', LastName) AS Available FROM Mechanics
    WHERE MechanicId NOT IN
        (SELECT MechanicId 
         FROM Jobs
         WHERE [Status] = 'In Progress'
         GROUP BY MechanicId);


GO
-- 8 Past Expenses

SELECT JobId, COALESCE(Total, 0.00) AS TotalPartsCost
FROM
(
    SELECT j.JobId, SUM(op.Quantity * p.Price) AS Total
    FROM Jobs AS j
    LEFT JOIN Orders AS o ON j.JobId = o.JobId
    LEFT JOIN OrderParts AS op ON o.OrderId = op.OrderId
    LEFT JOIN Parts AS p ON op.PartId = p.PartId
    WHERE j.[Status] = 'Finished' 
    GROUP BY j.JobId
) AS TotalCostPartsSubq
ORDER BY COALESCE(Total, 0.00) DESC, JobId ASC;

GO
-- 9 Missing parts

SELECT 
    p.PartId AS [Part ID],
    p.Description AS [Description],
    pn.RequiredQuantity AS [Required],
    p.StockQty AS [In Stock],
    COALESCE(op.OrderedQuantity, 0) AS [Ordered]
FROM
    Parts AS p
JOIN
    (
        SELECT 
            PartId,
            JobId,
            SUM(Quantity) AS RequiredQuantity
        FROM
            PartsNeeded AS pn
        GROUP BY
            PartId, JobId
    ) pn ON p.PartId = pn.PartId
JOIN
    Jobs j ON pn.JobId = j.JobId
LEFT JOIN
    (
        SELECT 
            PartId,
            SUM(Quantity) AS OrderedQuantity
        FROM
            OrderParts AS op
        JOIN
            Orders o ON op.OrderId = o.OrderId AND o.Delivered = 0
        GROUP BY
            PartId 
    ) op ON p.PartId = op.PartId
WHERE
    j.Status = 'In Progress' -- Filter for active jobs (not finished)
    AND (p.StockQty + COALESCE(op.OrderedQuantity, 0)) < pn.RequiredQuantity
ORDER BY
    p.PartId ASC;

GO

-- 10 Cost Of Order

CREATE FUNCTION udf_GetCost (@jobId INT)
RETURNS DECIMAL(8,2)
AS
BEGIN
    DECLARE @totalCost DECIMAL(8,2);
    DECLARE @countJobOrder INT = (SELECT COUNT(OrderId) FROM Jobs AS j
                                  LEFT JOIN Orders AS o
                                  ON j.JobId = o.JobId
                                  WHERE j.JobId = @jobId
                                 );

    IF @countJobOrder = 0
    BEGIN
        RETURN 0;
    END

    SET @totalCost = (SELECT SUM(p.Price * op.Quantity) FROM Jobs AS j
                      LEFT JOIN Orders AS o
                      ON j.JobId = o.JobId
                      LEFT JOIN OrderParts AS op
                      ON o.OrderId = op.OrderId
                      LEFT JOIN Parts AS p
                      ON op.PartId = p.PartId
                      WHERE j.JobId = @jobId
                     );

    RETURN @totalCost;
END;

    

SELECT dbo.udf_GetCost(3)



