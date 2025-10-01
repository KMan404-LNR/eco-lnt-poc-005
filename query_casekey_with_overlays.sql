/*
 * Query to find the first 1000 NUMBER rows and their matching NUMBER_OVERLAY rows
 * from a table with CaseKey column
 * 
 * CaseKey patterns:
 * - NUMBER (base case)
 * - NUMBER_OVERLAY (overlay case)
 * 
 * Not all NUMBER rows have a matching NUMBER_OVERLAY row
 */

-- Solution using CTE and LEFT JOIN
WITH BaseRows AS (
    -- Get the first 1000 NUMBER rows (rows without _OVERLAY suffix)
    SELECT TOP 1000
        CaseKey,
        -- Extract the base number for matching with overlay rows
        CaseKey AS BaseKey
    FROM YourTableName
    WHERE CaseKey NOT LIKE '%_OVERLAY'
    ORDER BY CaseKey
)
SELECT 
    t.CaseKey,
    t.* -- Include all columns from your table
FROM YourTableName t
WHERE 
    -- Include the base rows from our CTE
    t.CaseKey IN (SELECT CaseKey FROM BaseRows)
    OR 
    -- Include matching overlay rows (if they exist)
    t.CaseKey IN (
        SELECT br.BaseKey + '_OVERLAY' 
        FROM BaseRows br
    )
ORDER BY 
    -- Order by base number first, then overlay after base
    CASE 
        WHEN t.CaseKey LIKE '%_OVERLAY' 
        THEN REPLACE(t.CaseKey, '_OVERLAY', '')
        ELSE t.CaseKey 
    END,
    CASE 
        WHEN t.CaseKey LIKE '%_OVERLAY' THEN 1 
        ELSE 0 
    END;

/*
 * Alternative solution using UNION for potentially better performance
 * depending on table size and indexes
 */
-- WITH BaseRows AS (
--     SELECT TOP 1000
--         CaseKey
--     FROM YourTableName
--     WHERE CaseKey NOT LIKE '%_OVERLAY'
--     ORDER BY CaseKey
-- )
-- -- Get base rows
-- SELECT t.*
-- FROM YourTableName t
-- INNER JOIN BaseRows br ON t.CaseKey = br.CaseKey
-- UNION ALL
-- -- Get matching overlay rows
-- SELECT t.*
-- FROM YourTableName t
-- INNER JOIN BaseRows br ON t.CaseKey = br.CaseKey + '_OVERLAY'
-- ORDER BY 
--     CASE 
--         WHEN CaseKey LIKE '%_OVERLAY' 
--         THEN REPLACE(CaseKey, '_OVERLAY', '')
--         ELSE CaseKey 
--     END,
--     CASE 
--         WHEN CaseKey LIKE '%_OVERLAY' THEN 1 
--         ELSE 0 
--     END;
