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
Create PROCEDURE [inv].[sp_api_TakroSystem_AutoStoreRequestsDtl]
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
@StoreID as NVARCHAR(50)


WITH ENCRYPTION
 AS
BEGIN

Declare @StrErrorMessage As Nvarchar(1024)
Declare @StoreId2  As Nvarchar(50)
BEGIN TRY


	IF (SELECT Count(*) FROM inv.tblGoods
		where GoodsID=@GoodsID )<>1
	BEGIN
		Set @StrErrorMessage = N'کد کالا صحیح نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END	

	SELECT @StoreId2=StoreID2 from inv.tblStoresRequestsHdr
	where ProcessID=127 and ProcessNo=@ProcessNo and  FiscalYear=@FiscalYear and SerialNo=@SerialNo 


	INSERT INTO inv.tblStoresRequestsDtl
	(StoreID2,StoreID,ProcessID, ProcessNo, FiscalYear, SerialNo, RowNo, DocRowNo,
	DocStep, DocDate, AcntCode,
	GoodsID, SubUnitID, SubUnitQuantity,GoodsQuantity,
	DescDtl)
	
	select @StoreId2,@StoreID,127, @ProcessNo, @FiscalYear, @SerialNo, @RowNo , @RowNo ,
		   @DocStep, @DocDate,  @AcntCode, 
		   @GoodsID,UnitID ,@Quantity ,@Quantity  ,
		   @DescDtl
	FROM inv.tblGoods 
	where GoodsID=@GoodsID
    
END TRY
BEGIN CATCH

	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
