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
Create PROCEDURE [inv].[SpInsertTaskGoodsToStoreDtl]
	@ProcessID		SmallInt,
	@ProcessNo		TinyInt,
	@FiscalYear		SmallInt,
	@SerialNo		Int,
	@RowNo			Int,
	@DocDate		char(10),
	@AcntCode		varchar(30),
	@EnterKind		smallint,
	@StoreID		varchar(30),
	@GoodsID		varchar(30),
	@SubUnitID		varchar(30),
	@SubUnitQuantity	float,
	@GoodsQuantity	float
	WITH ENCRYPTION
AS

BEGIN

	INSERT INTO inv.tblStorageDocsDtl
	        (ProcessID,ProcessNo,FiscalYear,SerialNo,RowNo,DocRowNo,VolumeRowNo,EnterKind,DocDate,StoreID,AcntCode,
	         GoodsID,BatchNo,SubUnitID,SubUnitQuantity,GoodsQuantity )
	SELECT   @ProcessID, @ProcessNo,@FiscalYear,@SerialNo,@RowNo,@RowNo,0,@EnterKind,@DocDate,@StoreID,@AcntCode,
	         @GoodsID,'',@SubUnitID,@SubUnitQuantity,@GoodsQuantity
	
END
GO
