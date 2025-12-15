USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : E.Alian
-- Create date   : 1401/06/20
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_saymandigital_CreateGoods

@GoodsId AS NVARCHAR(100),
@TechnicalNo AS NVARCHAR(100),
@GoodsName AS NVARCHAR(100),
--@LastUpdate AS DateTime,
@Description AS NVARCHAR(100),
@UnitID AS NVARCHAR(100),
@HasSerialNo as bit
WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)

BEGIN TRY

	IF(SELECT COUNT(*) FROM inv.tblGoods WHERE GoodsID=@GoodsId)>0
	BEGIN
		Set @StrErrorMessage = N'این کد قبلا ثبت شده است'
		raiserror (@StrErrorMessage, 16, 1)
	END

	INSERT INTO inv.tblGoods(GoodsID, CodeClosed, UnitID, TechnicalSpecifications, TechnicalNo, MiscSpecifications, GoodsLength, GoodsWidth, GoodsHeight, GoodsWeight,
							  MapNo, MasterCode, CheckBuyRequest, CheckBuyOrder, CheckQualityControl, RecID, SessionNo, BarCode, GlobalCodingID, IranCodeID, FitPoint, SetPoint, 
							  [BatchSize], HasSerial, UseFactor, CostCenterAcntCode, ProduceWithoutFormula, GoodsClassificationID, PrinterID, ShowInSaleMenu, GoodsPrice, SpecialCode,
							  NationalCode, DrugKindID, CompanyID, MinSaleCeiling, MaxBuyCeiling, QtyInPerPacket, SalePrice, BuyPrice, IsRation, RationQty, IsCombination, CombinationAmount,
							  IsMammyDrug, IsSalePermit, IsComplementDrug, IsDecorDrug, IsNotInventoryCountDrug, IsNotTariffDrug, IsComrade, VisitorPercent, DoseID, SpecialAlarm, GenericCode, IsOTC,
							  DrugSetID, UseExpireDate, GenericID, IsService, IsCombined, IsSendInfo, ContainTax, HasExpireDate, HasBatchNo, HasLentgh, SaleTypeID, DfStoreID, GoodsGroup, SubGroup, 
							  PublisherAcntCode, GoodsCount, GoodsType, PrintTurn, PrintYear, [PageCount], BuyPricePercent, NotShowInTablet, PartNumber, UserPrice, ActiveUserPrice, WeightGoods,
							  TTMSCode, CanEditWidth, PureWeight, ExpirDate,  ActiveGoodsWeight, ActiveGoodsHeight,
							  ActiveGoodsWidth, ActiveGoodsLength,
							  OurTrustInSale, Tolerance, WeightBarcode, HasContainer, BuyWhitBaskul,  SkillID, GoodsAcntGroupID, NotReturnToCustomer, DayForExpire,
							  HasWeight, GoodsCID, InquiryTime, FallOfMaterialPercent, IncreasOfProductPercent, PlnProduce, Tax, Toll)

	    VALUES (@GoodsId, '', '01', '', @TechnicalNo, '', 0, 0, 0, 0,
		       '', '', '', '', '', '', '', '', '', '', '', '', 
		       0, @HasSerialNo, 0, '', 0, '', '', 0, 0,'',
		       '', '', '', 0, 0, 0, 0, 0, 0, 0, 0, 0,
		       0, 0, 0, 0, 0, 0, 0, 0, '', '', '', 0,
		       '', 0, '', 0, 0, 0, 0, 0, 0, 0, '', '', '', '', 
		       '', 0, '', '', 0, 0, 0, 0, 1, 0, 0, 0,
		       0, 0,0, '',  0, 0,
		       0, 0,
		       0, 0, 0, 0, 0,  '', 0, 0, 0,
		       0, '', 0, 0, 0, 0, 0, 0)



	INSERT INTO inv.tblGoodsDtl (GoodsID, LanguageID, GoodsName, GoodsName2, GenericName, Author, Translator, GoodsLocation, PartNumber, [Description])
	VALUES(@GoodsId,1,@GoodsName,'', '', '', '', '', 1, @Description)


END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
