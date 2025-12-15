USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [pln].[SpGetMaxProductSerialID]
@BRN	Varchar(10)

WITH ENCRYPTION
AS
BEGIN
	DECLARE @TempFiscalYear1 SMALLINT
	DECLARE @StrSelect1	NVarChar(4000)
	DECLARE @BRNWhere	NVarChar(4000)

	SET @TempFiscalYear1 = RIGHT(DB_NAME(),4)
	set @BRNWhere=''
	IF @BRN = '0' 
		SET @BRN = '' 

	IF @BRN <> '' 
		SET @BRNWhere = ' WHERE ProductSerialID LIKE ''' + @BRN +'''+''%'''

	DECLARE @BMaxResault as int
	DECLARE @AMaxResault as int
	DECLARE @ProductSerialID as int
	SET @BMaxResault = 0		
	SET @AMaxResault = 0		
	Declare @ParmDefinition NVarChar(200)
	SET @ParmDefinition = N'@MaxOUT as int OUTPUT';
	IF (SELECT COUNT(NAME) from master.sys.databases WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1-1)))=1 
	BEGIN
		SET @StrSelect1 = 'SELECT @MaxOUT=IsNull(Max(ProductSerialID),0) FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1-1)) + '.pln.tblProductSerials  WITH (NOLOCK)' + @BRNWhere
			
	print 	@StrSelect1	
		Exec sp_executesql @StrSelect1,@ParmDefinition, @MaxOUT = @BMaxResault OUTPUT;

		IF @BRN <> '' 
			SET @BMaxResault = @BRN + CAST((CAST(SUBSTRING(CAST(@BMaxResault as varchar(20)),LEN(@BRN)+1,20) AS INT)+1 ) as varchar(20))
		ELSE
			SET @BMaxResault = @BMaxResault + 1

	END

	IF (SELECT COUNT(NAME) from master.sys.databases WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1+1)))=1 
	BEGIN
		SET @StrSelect1 = 'SELECT @MaxOUT=IsNull(Max(ProductSerialID),0) FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1+1)) + '.pln.tblProductSerials  WITH (NOLOCK)' + @BRNWhere
	print 	@StrSelect1	
		Exec sp_executesql @StrSelect1,@ParmDefinition, @MaxOUT = @AMaxResault OUTPUT;
	
		IF @BRN <> '' 
			SET @AMaxResault = @BRN + CAST((CAST(SUBSTRING(CAST(@AMaxResault as varchar(20)),LEN(@BRN)+1,20) AS INT)) as varchar(20))
		ELSE
			SET @AMaxResault = @AMaxResault + 1
	END

	IF @BMaxResault>@AMaxResault
		SET @AMaxResault = @BMaxResault
	SELECT @ProductSerialID = IsNull(Max(ProductSerialID),0) from pln.tblProductSerials WITH (NOLOCK)
	WHERE @BRN='' OR  ProductSerialID LIKE @BRN +'%'

	IF @BRN <> '' 
		SET @ProductSerialID = @BRN +  CAST((CAST(SUBSTRING(CAST(@ProductSerialID as varchar(20)),LEN(@BRN)+1,20) AS INT)+1 ) as varchar(20))
	ELSE
		SET @ProductSerialID = @ProductSerialID + 1

	IF @AMaxResault>@ProductSerialID
		SET @ProductSerialID = @AMaxResault
		
	SELECT @ProductSerialID	 ProductSerialID

END
GO
