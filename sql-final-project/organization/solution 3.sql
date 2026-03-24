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