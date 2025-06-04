CREATE TRIGGER dbo.trigger_prevent_assignment_teaches
ON dbo.teaches
AFTER INSERT, UPDATE AS
IF (ROWCOUNT_BIG() = 0)
RETURN;
IF EXISTS (
    SELECT 1
    FROM inserted AS i
    JOIN (
        SELECT teaches.ID, teaches.[year], COUNT(*) AS assignment_count
        FROM dbo.teaches teaches
        JOIN inserted i2 ON teaches.ID = i2.ID AND teaches.[year] = i2.[year]
        GROUP BY teaches.ID, teaches.[year]
        HAVING COUNT(*) >= 2
    ) AS existing_assignments
    ON i.ID = existing_assignments.ID AND i.[year] = existing_assignments.[year]
)
BEGIN  
    RAISERROR ('Um instrutor que já possui 2 ou mais', 16, 1);  
    ROLLBACK TRANSACTION;  
    RETURN;
END;