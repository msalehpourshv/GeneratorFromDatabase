USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

Create PROCEDURE  [sal].[SpGetGoodsPriceCustomerKind] 
	@GoodsID	Varchar(20),
	@SubUnitID	Varchar(20),
	@AcntCode	Varchar(20),
	@DocDate	Char(10),
	@Time		Char(7),
	@CurrencyTypeID	varChar(20),
	@UserPriceID Int=0

WITH ENCRYPTION
AS
BEGIN

	DECLARE @GoodsPrice  FLOAT

	Declare @StrSelect AS NVarChar(4000);
	Declare @SubUnitIDTemp	AS Varchar(20);
	Declare @CustomerKindID AS Varchar(20);
	Declare @MainUnitID AS Varchar(20);
	Declare @AppraisalWithSaleType AS bit;
	
	Declare @LayerLen AS tinyint;
	Declare @StartLayerIndex AS tinyint;
	Declare @AcntPartNumberForRemainCalculation AS tinyint;
	DECLARE @ParmDefinition nvarchar(500);
	DECLARE @UnitValue FLOAT
	DECLARE @MainUnitValue FLOAT
	
	SET @ParmDefinition = N' @GoodsPrice1 FLOAT OUTPUT';

	SET @CustomerKindID = ''
	SET @SubUnitIDTemp = ''
	SET @GoodsPrice = 0
	SET @LayerLen = 0
	SET @StartLayerIndex = 0
	SET @AcntPartNumberForRemainCalculation = 0
	SET @AppraisalWithSaleType = 'False'

	SELECT @LayerLen = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'LayerLen'
	
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'

	
	SELECT @AcntPartNumberForRemainCalculation = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

		
	SELECT @AppraisalWithSaleType = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AppraisalWithSaleType'

	if (SELECT  SettingValue FROM pub.tblSettings	WHERE SettingKey = 'sal_AcntSaleTypeIDCustomerKindIDFromTopLayer') ='True'   
		select @CustomerKindID=acc.funGetAcntCustomerKindIDReverse(@AcntCode,0)
	else 
		SELECT @CustomerKindID = CustomerKindID 
		FROM acc.tblAcnt 
		WHERE PartNumber = @AcntPartNumberForRemainCalculation AND 
			  AcntCode = SUBSTRING(@AcntCode,@StartLayerIndex ,@LayerLen)

	--SET @StrSelect = N'SELECT TOP 1 @GoodsPrice1=Amount' + LTRIM(@CustomerKindID) + ' 
	--	FROM sal.tblGoodsPriceForCustomerKindDtl D 
	--	INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H 
	--	ON D.SerialNo = H.SerialNo  
	--	WHERE GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''' AND SubUnitID = ''' + LTrim(RTrim(@SubUnitID)) + ''' AND
	--		 ((FromDate = ''' + LTrim(RTrim(@DocDate)) + ''' AND FromTime <= ''' + LTrim(RTrim(@Time)) + ''') OR 
	--		  FromDate < ''' + LTrim(RTrim(@DocDate)) + ''') AND 
	--		 (ToDate='''' OR ToDate >= ''' + LTrim(RTrim(@DocDate)) + ''')
	--	ORDER BY FromDate DESC'

	--print @StrSelect
	--Exec sp_executesql @StrSelect,@ParmDefinition,@GoodsPrice1=@GoodsPrice OUTPUT;;
	
	IF @GoodsPrice = 0
		BEGIN
		IF @AppraisalWithSaleType = 'False'
		BEGIN
			SET @ParmDefinition = N' @GoodsPrice1 FLOAT OUTPUT,@SubUnitIDTemp1 VARCHAR(20) OUTPUT';
			SET @StrSelect = N'SELECT TOP 1 @GoodsPrice1=Amount' + LTRIM(@CustomerKindID) + ' ,@SubUnitIDTemp1=SubUnitID
				FROM sal.tblGoodsPriceForCustomerKindDtl D 
				INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H 
				ON D.SerialNo = H.SerialNo  
				WHERE (H.CustomerKind='''+ @CustomerKindID + ''' OR H.CustomerKind='''') AND 
				       CurrencyTypeID = ''' + @CurrencyTypeID + ''' AND GoodsID = SUBSTRING(''' + LTrim(RTrim(@GoodsID)) + ''',1,LEN(GoodsID)) AND 
					 ((FromDate = ''' + LTrim(RTrim(@DocDate)) + ''' AND FromTime <= ''' + LTrim(RTrim(@Time)) + ''') OR 
					  FromDate < ''' + LTrim(RTrim(@DocDate)) + ''') AND 
					 (ToDate='''' OR ToDate >= ''' + LTrim(RTrim(@DocDate)) + ''') 
					 and ('+str(@UserPriceID)+' =0 or UserPriceID='+ str(@UserPriceID)+')
				ORDER BY FromDate DESC,FromTime DESC,H.SerialNo DESC'
print @StrSelect
			Exec sp_executesql @StrSelect,@ParmDefinition,@GoodsPrice1=@GoodsPrice OUTPUT,@SubUnitIDTemp1=@SubUnitIDTemp OUTPUT;
		END
		ELSE
		BEGIN
			SELECT @GoodsPrice = sal.funGetGoodsAmountSaleType(@GoodsID,'',@DocDate,@AcntCode,1,@UserPriceID,0)
			SELECT @SubUnitIDTemp = UnitID from inv.tblGoods WHERE GoodsID = @GoodsID
		END

			IF @SubUnitIDTemp <>'' 
				BEGIN
					SELECT @UnitValue=UnitValue,@MainUnitValue=MainUnitValue 
					FROM inv.tblSubUnitsDtl 
					WHERE GoodsID = @GoodsID AND SubUnitID = @SubUnitIDTemp
					
					IF @MainUnitValue<>0
						SET @GoodsPrice = @GoodsPrice *  @UnitValue / @MainUnitValue
					
					SET @UnitValue = 1
					SET @MainUnitValue = 1
					
					IF @GoodsPrice<>0
						SELECT @UnitValue=UnitValue,@MainUnitValue=MainUnitValue 
						FROM inv.tblSubUnitsDtl 
						WHERE GoodsID = @GoodsID AND SubUnitID = @SubUnitID

					IF @MainUnitValue<>0
						SET @GoodsPrice = @GoodsPrice *  @MainUnitValue/ @UnitValue
			
				END
		END
		
	IF @GoodsPrice = 0
		BEGIN
			SELECT TOP 1 @GoodsPrice = Amount 
			FROM sal.tblGoodsPriceForCustomerKindDtl D 
			INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H 
			ON D.SerialNo = H.SerialNo  
			WHERE  CurrencyTypeID = @CurrencyTypeID  AND GoodsID LIKE SUBSTRING( @GoodsID,1,LEN(GoodsID)) AND SubUnitID = @SubUnitID AND
				 (FromDate = @DocDate AND FromTime <= @Time) AND 
				  FromDate < @DocDate AND 
				 (ToDate='' OR ToDate >= @DocDate) 
			order by FromDate desc,LEN(GoodsID) desc	  
				 
			IF @GoodsPrice = 0
				BEGIN
					SELECT TOP 1 @GoodsPrice = Amount ,@SubUnitIDTemp=SubUnitID
					FROM sal.tblGoodsPriceForCustomerKindDtl D 
					INNER JOIN sal.tblGoodsPriceForCustomerKindHdr H 
					ON D.SerialNo = H.SerialNo  
					WHERE CurrencyTypeID = @CurrencyTypeID  AND GoodsID LIKE SUBSTRING( @GoodsID,1,LEN(GoodsID)) AND
						 (FromDate = @DocDate AND FromTime <= @Time) AND 
						  FromDate < @DocDate AND (ToDate='' OR ToDate >= @DocDate) 
					order by FromDate desc	  
						 
					IF @SubUnitIDTemp <>'' 
						BEGIN
							SELECT @UnitValue=UnitValue,@MainUnitValue=MainUnitValue 
							FROM inv.tblSubUnitsDtl 
							WHERE GoodsID = @GoodsID AND SubUnitID = @SubUnitIDTemp
							
							IF @MainUnitValue<>0
								SET @GoodsPrice = @GoodsPrice *  @UnitValue/ @MainUnitValue
							
							SET @UnitValue = 1
							SET @MainUnitValue = 1
							
							IF @GoodsPrice<>0
								SELECT @UnitValue=UnitValue,@MainUnitValue=MainUnitValue 
								FROM inv.tblSubUnitsDtl 
								WHERE GoodsID = @GoodsID AND SubUnitID = @SubUnitID

							IF @MainUnitValue<>0
								SET @GoodsPrice = @GoodsPrice * @MainUnitValue / @UnitValue

						END
					 
				END
				 
		END
		
	SELECT @GoodsPrice
	
END
GO
