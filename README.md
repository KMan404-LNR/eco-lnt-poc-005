# CaseKey Query Solution

## Problem Statement

This repository contains a SQL query solution for finding rows in a MS SQL Server table where the `CaseKey` column has two patterns:
- **NUMBER** (base case)
- **NUMBER_OVERLAY** (overlay case)

Not all NUMBER rows have a matching OVERLAY row.

## Solution

The query finds the first 1000 NUMBER rows and their matching NUMBER_OVERLAY rows (if they exist).

## Usage

1. Open `query_casekey_with_overlays.sql`
2. Replace `YourTableName` with your actual table name
3. Execute the query in your MS SQL Server environment

### Example

If your table is named `Cases`:

```sql
WITH BaseRows AS (
    SELECT TOP 1000
        CaseKey,
        CaseKey AS BaseKey
    FROM Cases  -- Replace YourTableName with Cases
    WHERE CaseKey NOT LIKE '%_OVERLAY'
    ORDER BY CaseKey
)
SELECT 
    t.CaseKey,
    t.*
FROM Cases t  -- Replace YourTableName with Cases
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
```

## Query Logic

1. **CTE (BaseRows)**: Selects the first 1000 rows where `CaseKey` does NOT contain '_OVERLAY' suffix
2. **Main SELECT**: Returns all columns for:
   - The 1000 base rows (NUMBER pattern)
   - Their matching overlay rows (NUMBER_OVERLAY pattern), if they exist
3. **ORDER BY**: Results are ordered by the base number, with each base row followed by its overlay (if present)

## Alternative Solution

The file also includes a commented-out alternative using UNION ALL, which may perform better depending on:
- Table size
- Available indexes
- SQL Server version and configuration

To use the alternative solution, uncomment it and comment out the first query.

## Sample Data Example

If your table has these CaseKey values:
```
12345
12345_OVERLAY
67890
11111
11111_OVERLAY
```

And you request TOP 2, the query would return:
```
11111
11111_OVERLAY
12345
12345_OVERLAY
```

Note: `67890` would be included if it's among the first 1000, but its overlay wouldn't appear (because it doesn't exist).
