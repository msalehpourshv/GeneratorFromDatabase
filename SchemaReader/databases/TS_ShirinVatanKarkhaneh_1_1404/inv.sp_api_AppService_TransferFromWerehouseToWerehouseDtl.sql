USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/11/06
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
create PROCEDURE inv.sp_api_AppService_TransferFromWerehouseToWerehouseDtl

@FiscalYear as int,
@Quantity   as float,
@GoodsID    as NVARCHAR(50),
@SerialNo   as int,
@StoreID2   as NVARCHAR(50),          
@StoreID    as NVARCHAR(50),  
@UnitID     as NVARCHAR(50),  
@ProcessNo  as int,    
@DocDate    as NVARCHAR(50),           
@RowNo      as int,       
@DocStep    as int   
                        
WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @maxSerialNo AS INT
BEGIN TRY
	

	INSERT INTO inv.tblStorageDocsDtl
		(ProcessID, ProcessNo, FiscalYear, SerialNo, DocStep, DocDate,	StoreID, StoreID2,EnterKind,GoodsID,GoodsQuantity,SubUnitID,RowNo)
	
		SELECT 120, @ProcessNo, @FiscalYear, @SerialNo, @DocStep, @DocDate, @StoreID, @StoreID2, -1,@GoodsID,@Quantity,@UnitID,@RowNo
		
		SELECT  CAST(1 AS INT )AS Success

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
