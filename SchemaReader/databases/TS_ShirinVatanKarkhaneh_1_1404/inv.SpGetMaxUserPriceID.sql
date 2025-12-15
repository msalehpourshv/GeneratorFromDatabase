USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE  PROCEDURE [inv].[SpGetMaxUserPriceID]
WITH ENCRYPTION
AS
BEGIN
	DECLARE @TempFiscalYear1 SMALLINT
	DECLARE @StrSelect1	NVarChar(4000)

	SET @TempFiscalYear1 = RIGHT(DB_NAME(),4)

	DECLARE @BMaxResault as int
	DECLARE @AMaxResault as int
	DECLARE @ID as int
	SET @BMaxResault = 0		
	SET @AMaxResault = 0		
	Declare @ParmDefinition NVarChar(200)
	SET @ParmDefinition = N'@MaxOUT as int OUTPUT';
	IF (SELECT COUNT(NAME) from master.sys.databases WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1-1)))=1 
	BEGIN
		SET @StrSelect1 = 'SELECT @MaxOUT=IsNull(Max(ID),0)+1 FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1-1)) + '.inv.tblGoodsUserPrice  WITH (NOLOCK)'
			
	print 	@StrSelect1	
		Exec sp_executesql @StrSelect1,@ParmDefinition, @MaxOUT = @BMaxResault OUTPUT;
	END

	IF (SELECT COUNT(NAME) from master.sys.databases WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1+1)))=1 
	BEGIN
		SET @StrSelect1 = 'SELECT @MaxOUT=IsNull(Max(ID),0)+1 FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1+1)) + '.inv.tblGoodsUserPrice  WITH (NOLOCK)'
	print 	@StrSelect1	
		Exec sp_executesql @StrSelect1,@ParmDefinition, @MaxOUT = @AMaxResault OUTPUT;
	END
	IF @BMaxResault>@AMaxResault
		SET @AMaxResault = @BMaxResault
	SELECT @ID = ISNULL(MAX(ID),0)+1 from inv.tblGoodsUserPrice WITH (NOLOCK)
	IF @AMaxResault>@ID
		SET @ID = @AMaxResault
		
	SELECT @ID	 ID

END

GO
