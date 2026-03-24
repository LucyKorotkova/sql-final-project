-- solution 1
WITH RECURSIVE subordinates AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    JOIN subordinates s ON e.ManagerID = s.EmployeeID
)
SELECT
    s.EmployeeID,
    s.Name AS EmployeeName,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (
        SELECT GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ')
        FROM Projects p
        WHERE p.DepartmentID = s.DepartmentID
    ) AS ProjectNames,
    (
        SELECT GROUP_CONCAT(t.TaskName ORDER BY t.TaskName SEPARATOR ', ')
        FROM Tasks t
        WHERE t.AssignedTo = s.EmployeeID
    ) AS TaskNames
FROM subordinates s
LEFT JOIN Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON s.RoleID = r.RoleID
ORDER BY s.Name;

-- solution 2
WITH RECURSIVE subordinates AS (
    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    WHERE e.EmployeeID = 1

    UNION ALL

    SELECT
        e.EmployeeID,
        e.Name,
        e.ManagerID,
        e.DepartmentID,
        e.RoleID
    FROM Employees e
    JOIN subordinates s ON e.ManagerID = s.EmployeeID
)
SELECT
    s.EmployeeID,
    s.Name AS EmployeeName,
    s.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (
        SELECT GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ')
        FROM Projects p
        WHERE p.DepartmentID = s.DepartmentID
    ) AS ProjectNames,
    (
        SELECT GROUP_CONCAT(t.TaskName ORDER BY t.TaskName SEPARATOR ', ')
        FROM Tasks t
        WHERE t.AssignedTo = s.EmployeeID
    ) AS TaskNames,
    (
        SELECT COUNT(*)
        FROM Tasks t
        WHERE t.AssignedTo = s.EmployeeID
    ) AS TotalTasks,
    (
        SELECT COUNT(*)
        FROM Employees e2
        WHERE e2.ManagerID = s.EmployeeID
    ) AS TotalSubordinates
FROM subordinates s
LEFT JOIN Departments d ON s.DepartmentID = d.DepartmentID
LEFT JOIN Roles r ON s.RoleID = r.RoleID
ORDER BY s.Name;

-- solution 3
WITH RECURSIVE hierarchy AS (
    SELECT
        e.EmployeeID AS ManagerEmployeeID,
        e.EmployeeID AS SubordinateID
    FROM Employees e

    UNION ALL

    SELECT
        h.ManagerEmployeeID,
        e.EmployeeID
    FROM hierarchy h
    JOIN Employees e ON e.ManagerID = h.SubordinateID
),
subordinate_counts AS (
    SELECT
        ManagerEmployeeID,
        COUNT(*) - 1 AS TotalSubordinates
    FROM hierarchy
    GROUP BY ManagerEmployeeID
)
SELECT
    e.EmployeeID,
    e.Name AS EmployeeName,
    e.ManagerID,
    d.DepartmentName,
    r.RoleName,
    (
        SELECT GROUP_CONCAT(DISTINCT p.ProjectName ORDER BY p.ProjectName SEPARATOR ', ')
        FROM Projects p
        WHERE p.DepartmentID = e.DepartmentID
    ) AS ProjectNames,
    (
        SELECT GROUP_CONCAT(t.TaskName ORDER BY t.TaskName SEPARATOR ', ')
        FROM Tasks t
        WHERE t.AssignedTo = e.EmployeeID
    ) AS TaskNames,
    sc.TotalSubordinates
FROM Employees e
JOIN Roles r ON e.RoleID = r.RoleID
JOIN Departments d ON e.DepartmentID = d.DepartmentID
JOIN subordinate_counts sc ON e.EmployeeID = sc.ManagerEmployeeID
WHERE r.RoleName = 'Менеджер'
  AND sc.TotalSubordinates > 0
ORDER BY e.Name;