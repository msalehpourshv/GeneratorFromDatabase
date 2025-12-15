USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1402/08/15
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- ================================================
Create PROCEDURE [pub].[SpChangeFarsiChar]
	@tblName as varchar(1000)

WITH ENCRYPTION
AS

BEGIN 

	DECLARE @Table NVARCHAR(MAX),
		   @Col NVARCHAR(MAX),
		   @Sch NVARCHAR(MAX)

	DECLARE Table_Cursor CURSOR
	FOR
	   --پیدا کردن تمام فیلدهای متنی تمام جداول دیتابیس جاری
	   SELECT a.name, --table
			  b.name, --col,
			  s.name --schema,

	   FROM   sys.tables a,
			  syscolumns b,
			  sys.schemas s
	   WHERE  a.object_id = b.id and s.schema_id=a.schema_id
			  AND a.type = 'U' --User table
			  AND (
					  b.xtype = 99 --ntext
					  OR b.xtype = 35 -- text
					  OR b.xtype = 231 --nvarchar
					  OR b.xtype = 167 --varchar
					  OR b.xtype = 175 --char
					  OR b.xtype = 239 --nchar
				  )
				  and a.name=@tblName

	OPEN Table_Cursor FETCH NEXT FROM  Table_Cursor INTO @Table,@Col,@Sch
	WHILE (@@FETCH_STATUS = 0)
	BEGIN
	   EXEC (
				'update  [' + @Sch + '].[' + @Table + '] set [' + @Col +
				']= REPLACE(REPLACE(CAST([' + @Col +
				'] as nvarchar(max)) , NCHAR(1610), NCHAR(1740)),NCHAR(1603),NCHAR(1705)) '
			)


	   FETCH NEXT FROM Table_Cursor INTO @Table,@Col,@Sch
	END 
	CLOSE Table_Cursor 
	DEALLOCATE Table_Cursor

END



GO
