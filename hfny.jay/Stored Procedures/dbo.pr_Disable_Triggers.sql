SET QUOTED_IDENTIFIER ON
GO
SET ANSI_NULLS ON
GO

-- pr_Disable_Triggers_v2 0

CREATE PROCEDURE [dbo].[pr_Disable_Triggers] @disable BIT = 1
AS 
    DECLARE
        @sql VARCHAR(500),
        @tableName VARCHAR(128),
        @tableSchema VARCHAR(128)

	-- List of all tables
    DECLARE triggerCursor CURSOR
        FOR
	SELECT
        t.TABLE_NAME AS TableName,
        t.TABLE_SCHEMA AS TableSchema
      FROM
        INFORMATION_SCHEMA.TABLES t
      ORDER BY
        t.TABLE_NAME,
        t.TABLE_SCHEMA 

    OPEN triggerCursor

    FETCH NEXT FROM triggerCursor INTO @tableName, @tableSchema
    WHILE ( @@FETCH_STATUS = 0 )
        BEGIN
            IF @disable = 1 
                SET @sql = 'ALTER TABLE ' + @tableSchema + '.[' + @tableName + '] DISABLE TRIGGER ALL' 
            ELSE 
                SET @sql = 'ALTER TABLE ' + @tableSchema + '.[' + @tableName + '] ENABLE TRIGGER ALL' 
            PRINT 'Executing Statement - ' + @sql
            EXECUTE ( @sql )
            FETCH NEXT FROM triggerCursor INTO @tableName, @tableSchema
        END

    CLOSE triggerCursor
    DEALLOCATE triggerCursor
GO
