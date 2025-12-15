USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 1400/04/22
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[sp_api_saymandigital_AutoBuySerials]
@ProcessID as tinyint,
@ProcessNo as tinyint,
@FiscalYear as Int,
@SerialNo as Int,
@RowNo as Int,
@AtomRowNo as Int,
@GoodsID AS VARCHAR(20),
@PSerialNo varchar(100),
@EnterKind smallint,
@StoreID AS VARCHAR(20),
@Desc AS NVARCHAR(300),
@ProductSerialNo varchar(100)


WITH ENCRYPTION
 AS
BEGIN
DECLARE @CountSerialInStore as int
Declare @StrErrorMessage As Nvarchar(1024)
DECLARE @StoreLayer  AS INT

BEGIN TRY


	insert into [inv].[tblStorageDocsSerials]
	([ProcessID], [ProcessNo], [FiscalYear], [SerialNo], [DocRowNo], [AtomRowNo], [DocAtomRowNo], [ProductSerialID], [PSerialNo], [StoreID], [EnterKind], 
	[NumberPerSerial], [SerialDesc])
	
	SELECT @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @RowNo, @AtomRowNo, @AtomRowNo, @ProductSerialNo, @PSerialNo, @StoreID, @EnterKind,1,@Desc

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
