USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Nogrepasand
-- Create date   : 92/09/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE  PROCEDURE [inv].[spAutoRestaurantBuyDtl]

@DocDate as CHAR(10),
@StoreID AS VARCHAR(20),
@FiscalYear as SMALLINT,
@GoodsID AS VARCHAR(20),
@GoodsQuantity	AS FLOAT,
@GoodsPrice AS FLOAT,
@UnitID AS VARCHAR(20)


WITH ENCRYPTION
 AS
BEGIN

BEGIN TRY


	DECLARE @maxSerialNo INT
	DECLARE @AcntCode AS VARCHAR(20)
	SET @AcntCode=''
	DECLARE @RowNo AS INT
	DECLARE @DocRowNo AS INT

	DECLARE @SubUnitID AS VARCHAR(20)
	DECLARE @UnitValue AS FLOAT
	
		
	IF @UnitID=''
	BEGIN
		SELECT @UnitID=UnitID FROM inv.tblGoods  WHERE
			GoodsID=@GoodsID
	END
	
	--IF (SELECT count(*)
	--FROM inv.tblSubUnitsDtl WHERE GoodsID=@GoodsID)>0
	--	BEGIN
	--		SELECT @SubUnitID=isnull(SubUnitID,''),@UnitValue=isnull(UnitValue/MainUnitValue,1)
	--		FROM inv.tblSubUnitsDtl WHERE GoodsID=@GoodsID
	--	END
	--ELSE
	--	BEGIN
			set @SubUnitID=@UnitID
			SET @UnitValue=1
		--END


	declare @buy_SetBuyLasPriceAsGoodsPrice		bit

	IF @GoodsPrice = 0 
	BEGIN

		SELECT @buy_SetBuyLasPriceAsGoodsPrice = SettingValue from pub.tblSettings where SettingKey = 'buy_SetBuyLasPriceAsGoodsPrice'
	
		IF @buy_SetBuyLasPriceAsGoodsPrice='1'
		BEGIN
			SELECT @GoodsPrice = [inv].[funGetLastBuyGoodsPrice](@GoodsID,@StoreID,@DocDate,0,1)
		END
	END

	SET @maxSerialNo = 0


	SELECT @maxSerialNo = isnull(MAX(SerialNo),0)
	FROM inv.tblStorageDocsHdr 
	WHERE ProcessID=55 
	  AND ProcessNo=1
	  AND FiscalYear=@FiscalYear

	  
	  
	 SELECT @RowNo = isnull(MAX(RowNo),0)
		FROM inv.tblStorageDocsDtl 
		WHERE ProcessID=55 
		 AND ProcessNo=1
		 AND FiscalYear=@FiscalYear
		 AND SerialNo=@maxSerialNo

	  
	  
	   SELECT @DocRowNo = isnull(MAX(DocRowNo),0)
			FROM inv.tblStorageDocsDtl 
			WHERE ProcessID=55 
			  AND ProcessNo=1
			  AND FiscalYear=@FiscalYear
			  AND SerialNo=@maxSerialNo
	  

		INSERT INTO inv.tblStorageDocsDtl
		(ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
		VolumeRowNo, DocStep, DocDate, StoreID, PhysicallyEffected, EnterKind,
		StoreID2, AcntCode, VisitorAcntCode, OrderAcntCode, GoodsID, SubUnitID,
		SubUnitQuantity, GoodsQuantity, QtyRemain, GoodsAmount, AmntRemain,
		AtomAmount, GoodsPrice, DescDtl, BaseProcessID, BaseProcessNo,
		BaseFiscalYear, BaseSerialNo, BaseDocRowNo, BaseDocType, AgreeNo, BatchNo,
		DiscountPercentDtl, DiscountDtl, BaseDocDate, VirtualQuantity, IsReward,
		FormulaNo, GoodsID2, Wage, WageRate, FormulaProductCount, CurrencyAmount,
		CalculatingAmount, VchDate2, SubUnitPrice, UserGoodsAmount, [ExpireDate],
		SourceSerialNo, SourceProcessNo, DailyUsesBranchID, GoodsAmount1,
		GoodsAmount2, GoodsAmount3, GoodsAmount4, GoodsAmount5, GoodsAmount6,
		GoodsAmount7, GoodsAmount8, GoodsAmount9, GoodsAmount10, GoodsAmount11,
		GoodsAmount12, StoreVariable1, StoreVariable2, SalePrice, PhrBatchNo,
		GregorianExpireDate)
		
		SELECT 55, 1, @FiscalYear, @maxSerialNo SerialNo, @RowNo+1 RowNo,@DocRowNo+1 DocRowNo, 
			   0, 1, @DocDate, @StoreID, 'True', 1, '', @AcntCode, '', '', @GoodsID,@SubUnitID SubUnitID,
			   @GoodsQuantity*@UnitValue  SubUnitQuantity,
			   @GoodsQuantity GoodsQuantity,0 QtyRemain,@GoodsPrice GoodsAmount,0 AmntRemain,0 AtomAmount,@GoodsPrice GoodsPrice,'' DescDtl,
			   0 BaseProcessID,0 BaseProcessNo,0 BaseFiscalYear,0 BaseSerialNo,0 BaseDocRowNo,'' BaseDocType,0 AgreeNo,
			   '' BatchNo,0 DiscountPercentDtl,0 DiscountDtl,'' BaseDocDate,0 VirtualQuantity,'False' IsReward,
			   0 FormulaNo,'' GoodsID2,0 Wage,0 WageRate,0 FormulaProductCount,0 CurrencyAmount,0 CalculatingAmount,
			   '' VchDate2,@GoodsPrice SubUnitPrice,0 UserGoodsAmount,'' [ExpireDate],0 SourceSerialNo,0 SourceProcessNo,
			   '' DailyUsesBranchID,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,'',''
		
		
		--############################################################################


END TRY
BEGIN CATCH

	Declare @StrErrorMessage As Nvarchar(1024)
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END
GO
