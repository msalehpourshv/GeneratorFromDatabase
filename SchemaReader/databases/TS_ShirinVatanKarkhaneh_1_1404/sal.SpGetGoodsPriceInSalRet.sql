USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create PROCEDURE  [sal].[SpGetGoodsPriceInSalRet]
	@GoodsID			Varchar(20),
	@GoodsPrice			Decimal(28,9),
	@SubUnitIDBase		Varchar(20),
	@SubUnitIDCurrent	Varchar(20)
WITH ENCRYPTION
AS
BEGIN

if @SubUnitIDCurrent=''
set @SubUnitIDCurrent=@SubUnitIDBase

if @SubUnitIDBase=''
set @SubUnitIDBase=@SubUnitIDCurrent

	IF @GoodsPrice > 0
		BEGIN
			DECLARE @GoodsPriceRet  FLOAT
			DECLARE @UnitValueBase FLOAT
			DECLARE @UnitValueCur FLOAT
			DECLARE @MainUnitValueBase FLOAT
			DECLARE @MainUnitValueCur FLOAT

			SELECT @UnitValueBase=UnitValue,@MainUnitValueBase=MainUnitValue 
			FROM inv.tblSubUnitsDtl 
			WHERE GoodsID = @GoodsID AND SubUnitID = @SubUnitIDBase

			IF @UnitValueBase IS NULL
				BEGIN
					SET @UnitValueBase = 1
					SET @MainUnitValueBase = 1
				END

			SELECT @UnitValueCur=UnitValue,@MainUnitValueCur=MainUnitValue 
			FROM inv.tblSubUnitsDtl 
			WHERE GoodsID = @GoodsID AND SubUnitID = @SubUnitIDCurrent
				
			IF @UnitValueCur IS NULL
				BEGIN
					SET @UnitValueCur = 1
					SET @MainUnitValueCur = 1
				END
			
			SET @GoodsPriceRet = ((@UnitValueCur/ @MainUnitValueCur  ) * @GoodsPrice ) / (@UnitValueBase / @MainUnitValueBase )
		END

	ELSE
		SET @GoodsPriceRet=0

	SELECT @GoodsPriceRet
	
END
GO
