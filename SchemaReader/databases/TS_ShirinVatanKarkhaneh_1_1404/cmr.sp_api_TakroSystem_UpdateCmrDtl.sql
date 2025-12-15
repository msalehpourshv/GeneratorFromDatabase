USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/09/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [cmr].[sp_api_TakroSystem_UpdateCmrDtl]
@ProcessNo as tinyint,
@FiscalYear as SMALLINT,
@SerialNo as Int,
@RowNo as Int,
@DocStep as tinyint,
@GoodsID AS VARCHAR(20),
@Quantity as FLOAT,
@SubUnitID as varchar(30),
@AcntCode AS VARCHAR(20),
@DescDtl as NVARCHAR(500),
@DocDate as CHAR(10),
@StoreID AS VARCHAR(20)


WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)

BEGIN TRY


	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا صحیح نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	
	
	

	update cmr.tblCMRDtl
	set DocDate=@DocDate, StoreID=@StoreID, AcntCode=@AcntCode,
	GoodsID=@GoodsID, SubUnitID=@SubUnitID, SubUnitQuantity=@Quantity,GoodsQuantity=@Quantity,DescDtl=@DescDtl
	where
	 ProcessID=150 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo and RowNo=@RowNo
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
