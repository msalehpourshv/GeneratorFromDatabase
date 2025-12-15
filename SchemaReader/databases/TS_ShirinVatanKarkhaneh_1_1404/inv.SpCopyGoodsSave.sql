USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/02/07
-- Viewed By	 : 
-- Last Modified : 92/12/06 - Hamid
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[SpCopyGoodsSave]
	@FromGoodsID		NVarchar(50),
	@ToGoodsID			NVarchar(50),
	@ToGoodsName		NVarchar(100),
	@bolSubUnit			Bit,
	@bolGoodsPrice		Bit,
	@bolOtherSettings	Bit,
	@LanguageID			TinyInt

WITH ENCRYPTION
AS

BEGIN

	Declare @strMsgText	Nvarchar(2000)
	
	SET @strMsgText=''

	BEGIN TRAN

	BEGIN TRY

		IF 	(SELECT COUNT(*)
			FROM 	inv.tblGoods
			WHERE GoodsID = @FromGoodsID AND PartNumber = 1 ) = 0
			BEGIN
				---- این کد کالا توسط کاربر دیگری حذف شده است
				SET @strMsgText=TS.pub.funGetMessages(15001,@LanguageID)
				--Raiserror (@strMsgText,16,1)
				SELECT	@strMsgText AS ReturnValue
			END				

		IF 	(SELECT COUNT(*)
			 FROM 	inv.tblGoods
			 WHERE  PartNumber = 1  AND GoodsID LIKE @ToGoodsID  + '%' ) > 0
			BEGIN 
				-- این کد کالا توسط کاربر دیگری ایجاد شده است
				SET @strMsgText=TS.pub.funGetMessages(15002,@LanguageID)
				--Raiserror (@strMsgText,16,1)
				SELECT	@strMsgText AS ReturnValue 
			END

IF @strMsgText = ''

	BEGIN
		INSERT INTO inv.tblGoods (GoodsID, CodeClosed, UnitID, TechnicalSpecifications, TechnicalNo, 
					MiscSpecifications, GoodsLength, GoodsWidth, GoodsHeight, GoodsWeight, GoodsPrice, 
					MapNo, MasterCode, CheckBuyRequest, CheckBuyOrder, CheckQualityControl, RecID, 
					SessionNo, BarCode, GlobalCodingID, IranCodeID, ExtraField1, ExtraField2, ExtraField3, 
					ExtraField4, ExtraField5, FitPoint, SetPoint, BatchSize, HasSerial, UseFactor, 
					CostCenterAcntCode, ProduceWithoutFormula, GoodsClassificationID, IsService,
					ContainTax,VisitorPercent,PartNumber)
		SELECT @ToGoodsID + SUBSTRING(GoodsID,LEN(@ToGoodsID)+1,30), CodeClosed, UnitID, 
			   TechnicalSpecifications, TechnicalNo, MiscSpecifications, GoodsLength, GoodsWidth, GoodsHeight, GoodsWeight, 
			   GoodsPrice, MapNo, MasterCode, Case When @bolOtherSettings = 1 Then CheckBuyRequest Else 0 End, 
			   Case When @bolOtherSettings = 1 Then CheckBuyOrder Else 0 End, Case When @bolOtherSettings = 1 Then CheckQualityControl Else 0 End, 
			   RecID, SessionNo, BarCode, GlobalCodingID,
			   IranCodeID, ExtraField1, ExtraField2, ExtraField3, ExtraField4, ExtraField5, 
			   FitPoint, SetPoint, Case When @bolOtherSettings = 1 Then [BatchSize] Else 0 End, 
			   Case When @bolOtherSettings = 1 Then HasSerial Else 0 End, UseFactor, 
			   Case When @bolOtherSettings = 1 Then CostCenterAcntCode Else '' End, 
			   Case When @bolOtherSettings = 1 Then ProduceWithoutFormula Else 0 End, 
			   GoodsClassificationID, Case When @bolOtherSettings = 1 Then IsService Else 0 End,
			   ContainTax,VisitorPercent,1
		FROM inv.tblGoods
		WHERE GoodsID LIKE  @FromGoodsID + '%'

		INSERT INTO inv.tblGoodsDtl 
		SELECT @ToGoodsID + ISNULL(SUBSTRING(GoodsID,LEN(@ToGoodsID)+1,30),''), LanguageID, @ToGoodsName,'','',Author,Translator,GoodsLocation,PartNumber,[Description]
		FROM inv.tblGoodsDtl
		WHERE GoodsID =  @FromGoodsID AND PartNumber = 1
		
		INSERT INTO inv.tblGoodsDtl 
		SELECT @ToGoodsID + ISNULL(SUBSTRING(GoodsID,LEN(@ToGoodsID)+1,30),''), LanguageID, GoodsName,'','',Author,Translator,GoodsLocation,PartNumber,[Description]
		FROM inv.tblGoodsDtl
		WHERE GoodsID LIKE  @FromGoodsID + '%' AND LEN(GoodsID)>LEN(@FromGoodsID) AND PartNumber = 1
		
		--واحد فرعی
		IF (@bolSubUnit = 1)
		Begin
			Print  @ToGoodsID 
			INSERT INTO inv.tblSubUnitsHdr
			SELECT @ToGoodsID + ISNULL(SUBSTRING(GoodsID,LEN(@ToGoodsID)+1,30),''), RecID, SessionNo
			FROM inv.tblSubUnitsHdr
			WHERE GoodsID LIKE  @FromGoodsID + '%'

			INSERT INTO inv.tblSubUnitsDtl 
			SELECT @ToGoodsID + SUBSTRING(GoodsID,LEN(@ToGoodsID)+1,30), RowNo, SubUnitID, UnitValue, TolerancePercent, ToleranceValue, DocRowNo, MainUnitValue, ShowInInvoice, UnitID
			FROM inv.tblSubUnitsDtl
			WHERE GoodsID LIKE  @FromGoodsID + '%'
		End

		--INSERT INTO sal.tblGoodsPricesHdr (GoodsID, SessionNo, RecID, IsGroupCode)
		--SELECT @ToGoodsID + SUBSTRING(GoodsID,LEN(@ToGoodsID)+1,30),0,0,IsGroupCode
		--FROM sal.tblGoodsPricesHdr
		--WHERE GoodsID LIKE  @FromGoodsID + '%'
		
		--قیمت کالا
		IF (@bolGoodsPrice = 1)
		Begin
			INSERT INTO sal.tblGoodsPricesDtl 
			(GoodsID, RowNo, DocRowNo, SalePriceTypeID, DefaultSalePriceTypeID, SaleTypeID, SalePrice, BasePriceTypeID, AddendAmountToPrice, AddendPercentToPrice, RoundableDigitsInPrice, CurrencyTypeID, CurrencyPrice, Coefficient, IsGroupCode)
			SELECT @ToGoodsID + SUBSTRING(GoodsID,LEN(@ToGoodsID)+1,30), RowNo, DocRowNo, SalePriceTypeID, DefaultSalePriceTypeID, SaleTypeID, SalePrice, BasePriceTypeID, AddendAmountToPrice, AddendPercentToPrice, RoundableDigitsInPrice, CurrencyTypeID, CurrencyPrice, Coefficient, IsGroupCode
			FROM sal.tblGoodsPricesDtl
			WHERE GoodsID LIKE  @FromGoodsID + '%'	
		End	
		
		SELECT '' AS ReturnValue
	END	
ELSE
	BEGIN
		declare @Err varchar(10)
		SELECT @Err
	END

		COMMIT TRAN
		
	END TRY
	
	BEGIN CATCH
		ROLLBACK TRAN
		
	END CATCH
	
END
GO
