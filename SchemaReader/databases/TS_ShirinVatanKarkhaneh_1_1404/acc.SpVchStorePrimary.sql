USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 87/07/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpVchStorePrimary]
	@intVchNo				Int,
	@intDocStep				TinyInt,
    @strVchDate				Char(10),
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@intMaxRowNo			Int,
	@intMaxDocRowNo			Int,
	@SessionNo				Int,
	@LanguageID				TinyInt
	WITH ENCRYPTION
AS

BEGIN
	-----
	
	Declare @strMsgText				NVarChar(2044)
	Declare @StockAcntCode			Varchar(20)
	Declare @StoreID				Varchar(20)
	Declare @AcntCode				Varchar(20)
	Declare @Amount					Float
	Declare @GoodsPrice					Float
	Declare @strRecDesc				NVarChar(1000)
	Declare @strFiscalSerial		VarChar(20)
	Declare @DescDtl				NVarChar(1000)
	Declare @CurrencyRate			Float
	Declare @CurrencyAmount			Float
	Declare @CurrencyTypeID			VarChar(20)
	Declare @inv_GoodsAcntGroupWithStoreID bit
	Declare @CurrencyRateTmp			Float
	Declare @CurrencyAmountTmp			Float
	Declare @CurrencyTypeIDTmp			VarChar(20)

	SET @CurrencyRate = 0 	
	SET @CurrencyAmount = 0 
	SET @CurrencyTypeID = ''

	SET @CurrencyRateTmp = 0
	SET @CurrencyAmountTmp = 0
	SET @CurrencyTypeIDTmp = ''

	SET @inv_GoodsAcntGroupWithStoreID   = 'False'

	SELECT @inv_GoodsAcntGroupWithStoreID=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey='inv_GoodsAcntGroupWithStoreID'


	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1
	DECLARE @str_Goods  tinyint,
		@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	--------------------------------------------------------------------------------------------------------
	SELECT	@Amount=SUM(CASE WHEN d.UnitID<>s.SubUnitID and SubUnitQuantity2<>0 AND SubUnitPrice2 <>0 THEN SubUnitQuantity2*SubUnitPrice2 ELSE s.GoodsPrice * GoodsQuantity END)
	FROM inv.tblStorageDocsDtl s
	INNER JOIN inv.tblGoods d
	ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID AND d.PartNumber=@UnitPart
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 
	
	SELECT	@StoreID=StoreID,@AcntCode=AcntCode,@CurrencyRate=CurrencyRate,@CurrencyTypeID=CurrencyTypeID--,@Amount=Amount
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@intSourceProcessID AND
		  ProcessNo=@intSourceProcessNo AND
		  FiscalYear=@intSourceFiscalYear AND
		  SerialNo=@intSourceSerialNo 

    SELECT @StockAcntCode=StockAcntCode
    FROM inv.tblStores 
    WHERE StoreID = @StoreID

	IF @StockAcntCode=''
		BEGIN
			--کد موجودی کالا خالی است
			SET @strMsgText=TS.pub.funGetMessages(11001,@LanguageID)
			Raiserror (@strMsgText,16,1)
			Return
		END

	-----
	SET @strFiscalSerial = LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	SET @strRecDesc=' موجودي اول دوره شماره' + LTRIM(RTRIM(STR(@intSourceFiscalYear))) + '/' + LTRIM(RTRIM(STR(@intSourceSerialNo))) 
	
	IF @inv_GoodsAcntGroupWithStoreID='True'
	BEGIN
		Declare	curStore CURSOR For
		SELECT	s.StoreID,[acc].[funMerg_AcntCode](g.StockAcntCode,P2AcntCode,P3AcntCode,P4AcntCode) StockAcntCode, 
				sum(CASE WHEN d.UnitID<>s.SubUnitID and s.SubUnitQuantity2<>0 AND s.SubUnitPrice2 <>0 THEN s.SubUnitQuantity2*s.SubUnitPrice2 ELSE s.GoodsPrice * s.GoodsQuantity END) GoodsPrice
		FROM inv.tblStorageDocsDtl s
		INNER JOIN inv.tblStores g
		ON s.StoreID=g.StoreID
		INNER JOIN inv.tblGoods d
		ON SUBSTRING(s.GoodsID,@str_Goods+1,@str_GoodsSum)=d.GoodsID AND d.PartNumber=@UnitPart
		LEFT JOIN inv.tblGoodsAcntGroup a
		on a.GoodsAcntGroupID=d.GoodsAcntGroupID
		WHERE ProcessID=@intSourceProcessID AND 
			  ProcessNo=@intSourceProcessNo AND
			  FiscalYear=@intSourceFiscalYear AND
			  SerialNo=@intSourceSerialNo 
		group by s.StoreID,[acc].[funMerg_AcntCode](g.StockAcntCode,P2AcntCode,P3AcntCode,P4AcntCode)
		
		Open curStore;

		Fetch NEXT From curStore Into @StoreID,@StockAcntCode,@GoodsPrice

		While (@@Fetch_Status = 0)
		BEGIN


			SET @intMaxDocRowNo = @intMaxDocRowNo + 1
			SET @intMaxRowNo = @intMaxRowNo + 1
			
			IF @CurrencyRate <> 0 
				SET @CurrencyAmount = ROUND(@GoodsPrice ,0) / @CurrencyRate

			IF [acc].[funIsCurrencyAcntCode] (@StockAcntCode) = 'True'
			Begin
				Set @CurrencyRateTmp	= @CurrencyRate
				Set @CurrencyAmountTmp  = @CurrencyAmount
				Set @CurrencyTypeIDTmp  = @CurrencyTypeID
			End
			Else
			Begin
				Set @CurrencyRateTmp	= 0
				Set @CurrencyAmountTmp  = 0
				Set @CurrencyTypeIDTmp  = ''
			End


			INSERT INTO acc.tblVoucherDtl
					(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
						AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
			VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
					@StockAcntCode,ROUND(@GoodsPrice,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmountTmp ,@CurrencyTypeIDTmp)	

		FETCH NEXT From curStore Into @StoreID,@StockAcntCode,@GoodsPrice
		END -- curStore
		Close curStore;
		Deallocate curStore;

	END
	ELSE
	BEGIN
		-----
		SET @intMaxDocRowNo = @intMaxDocRowNo + 1
		SET @intMaxRowNo = @intMaxRowNo + 1
	
		IF @CurrencyRate <> 0 	
			SET @CurrencyAmount = ROUND(@Amount,0) / @CurrencyRate
						
		INSERT INTO acc.tblVoucherDtl
				(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
					AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
		VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
					@StockAcntCode,ROUND(@Amount,0),0,TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount ,@CurrencyTypeID)	
	END
	-----
	SET @intMaxDocRowNo = @intMaxDocRowNo + 1
	SET @intMaxRowNo = @intMaxRowNo + 1
							
	INSERT INTO acc.tblVoucherDtl
			(SerialNo,SourceProcessID,SourceProcessNo,SourceFiscalYear,SourceSerialNo,DocDate,IsAutoDoc,SessionNo,VchKind,RowNo,DocRowNo,
				AcntCode,Debit,Credit,RecDesc,RecDesc2,SourceDocType,CurrencyAmount,CurrencyTypeID) 
	VALUES	(@intVchNo,@intSourceProcessID,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo,@strVchDate ,1,@SessionNo ,2,@intMaxRowNo ,@intMaxDocRowNo,
				@AcntCode,0,ROUND(@Amount,0),TS.pub.funChangeFarsiStrings(pub.funReverseForCrystal(@strRecDesc)),'',0,@CurrencyAmount ,@CurrencyTypeID)	

END
GO
