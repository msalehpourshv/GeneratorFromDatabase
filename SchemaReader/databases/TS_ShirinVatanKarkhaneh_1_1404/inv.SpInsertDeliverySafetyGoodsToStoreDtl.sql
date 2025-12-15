USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   :
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[SpInsertDeliverySafetyGoodsToStoreDtl]
	@FiscalYear		SmallInt,
	@SerialNo		Int,
	@RowNo			Int,
	@DocDate		char(10),
	@CostCenter		varchar(30),
	@AcntCode		varchar(30),
	@StoreID		varchar(30),
	@GoodsID		varchar(30)
	WITH ENCRYPTION
AS

BEGIN

	INSERT INTO inv.tblStorageDocsDtl
	        (ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,EnterKind,DocDate,StoreID,AcntCode,
	         GoodsID,SubUnitID,SubUnitQuantity,GoodsQuantity,DocStep )
	SELECT   110, 9,@FiscalYear,@SerialNo,@RowNo,@RowNo,0,-1,@DocDate,@StoreID,CASE WHEN LTRIM(@CostCenter) <>'' THEN @CostCenter ELSE  CASE WHEN CostCenterAcntCode<>'' THEN CostCenterAcntCode ELSE @AcntCode END END,
	         @GoodsID,[pub].[funGetGoodsUnitID](@GoodsID),1,1,2
	FROM inv.tblGoods
	where GoodsID = @GoodsID
	
END
GO
