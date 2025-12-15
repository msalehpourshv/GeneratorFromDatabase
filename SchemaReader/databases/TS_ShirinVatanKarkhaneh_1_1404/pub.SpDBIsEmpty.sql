USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : Sadeghi
-- Create date   : 87/03/06
-- Viewed By	 : 
-- Last Modified : 
-- Description	 :
-- ==============================================
CREATE PROCEDURE [pub].[SpDBIsEmpty] 
WITH ENCRYPTION
AS

BEGIN
	SET NOCOUNT ON;
	DECLARE @StrSelect NVARCHAR(4000)

	Declare @strSchemaName VarChar(200);
	Declare @strTableName VarChar(200);
	Declare @Count Int
	DECLARE @ParmDefinition nvarchar(500);
	
	SET @ParmDefinition = N' @max_OUT INT OUTPUT';

	DECLARE curTables CURSOR FOR 
	Select S.name,T.name From sys.tables T 
	INNER JOIN sys.schemas S ON T.schema_id = S.schema_id AND S.schema_id > 4
	WHERE T.name<>'sysdiagrams'
	Order By S.name,T.name ;

	OPEN curTables;

	FETCH NEXT FROM curTables INTO @strSchemaName ,@strTableName ;
	WHILE @@FETCH_STATUS = 0 
		BEGIN
	
			SET @StrSelect = 'Select  @max_OUT=COUNT(*) From ' + @strSchemaName + '.' + @strTableName 
			
			EXECUTE sp_executesql @StrSelect, @ParmDefinition, @max_OUT=@Count OUTPUT;

			 IF @Count > 0
				BEGIN
					Close curTables;
					Deallocate curTables;						
					SELECT 1 AS IsEmpty
					RETURN 
				END

			FETCH NEXT FROM curTables INTO @strSchemaName ,@strTableName;
		END
	Close curTables;
	Deallocate curTables;
		
	SELECT 0 AS IsEmpty


END

--[pub].[SpDBIsEmpty]
GO
