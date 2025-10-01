/*
 * Example SQL Script demonstrating the CaseKey query with sample data
 * This creates a sample table, inserts test data, and runs the query
 */

-- Create a sample table
CREATE TABLE #SampleCases (
    CaseKey VARCHAR(100) PRIMARY KEY,
    Description VARCHAR(200),
    CreatedDate DATETIME
);

-- Insert sample data
-- Some base cases with overlays, some without
INSERT INTO #SampleCases (CaseKey, Description, CreatedDate) VALUES
('12345', 'Base case 12345', '2024-01-01'),
('12345_OVERLAY', 'Overlay for 12345', '2024-01-02'),
('67890', 'Base case 67890 without overlay', '2024-01-03'),
('11111', 'Base case 11111', '2024-01-04'),
('11111_OVERLAY', 'Overlay for 11111', '2024-01-05'),
('22222', 'Base case 22222 without overlay', '2024-01-06'),
('33333', 'Base case 33333', '2024-01-07'),
('33333_OVERLAY', 'Overlay for 33333', '2024-01-08'),
('44444', 'Base case 44444 without overlay', '2024-01-09'),
('55555', 'Base case 55555', '2024-01-10'),
('55555_OVERLAY', 'Overlay for 55555', '2024-01-11');

-- Show all data
SELECT 'All Data:' AS Info, * FROM #SampleCases ORDER BY CaseKey;

-- Run the query (adapted for our sample table)
-- This will get the first 1000 base cases and their overlays
WITH BaseRows AS (
    SELECT TOP 1000
        CaseKey,
        CaseKey AS BaseKey
    FROM #SampleCases
    WHERE CaseKey NOT LIKE '%_OVERLAY'
    ORDER BY CaseKey
)
SELECT 
    '--- Query Results ---' AS Info,
    t.CaseKey,
    t.Description,
    t.CreatedDate
FROM #SampleCases t
WHERE 
    t.CaseKey IN (SELECT CaseKey FROM BaseRows)
    OR 
    t.CaseKey IN (
        SELECT br.BaseKey + '_OVERLAY' 
        FROM BaseRows br
    )
ORDER BY 
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
Expected Output:
The query will return 8 rows (5 base cases + 3 overlays):
- 11111
- 11111_OVERLAY
- 12345
- 12345_OVERLAY
- 22222 (no overlay)
- 33333
- 33333_OVERLAY
- 44444 (no overlay)
- 55555
- 55555_OVERLAY
- 67890 (no overlay)

Note: Each base case appears with its overlay (if it exists) grouped together
*/

-- Clean up
DROP TABLE #SampleCases;
