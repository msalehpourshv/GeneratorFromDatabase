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
Create PROCEDURE [sal].[sp_api_saymandigital_AutoSerials]
@ProcessID as tinyint,
@ProcessNo as tinyint,
@FiscalYear as Int,
@SerialNo as Int,
@RowNo as Int,
@AtomRowNo as Int,
@GoodsID AS VARCHAR(20),
@PSerialNo varchar(30),
@EnterKind smallint,
@StoreID AS VARCHAR(20),
@Desc AS NVARCHAR(300)

WITH ENCRYPTION
 AS
BEGIN
DECLARE @CountSerialInStore as int
Declare @StrErrorMessage As Nvarchar(1024)
DECLARE @StoreLayer  AS INT

BEGIN TRY

	DECLARE @ProductSerialID as int=0
	

	SELECT @ProductSerialID=ProductSerialID 
	FROM  [pln].[tblProductSerials]
	WHERE ProductID=@GoodsID and SerialNo=@PSerialNo

	IF @ProductSerialID = 0
	BEGIN
		Set @StrErrorMessage = N'سریال   '+ @PSerialNo+ +' برای کالای '++@GoodsID+' تعریف نشده است '
		raiserror (@StrErrorMessage, 16, 1)
	END	

	SELECT @CountSerialInStore= isnull(sum (EnterKind )  ,0) 
	FROM inv.tblStorageDocsSerials s 
	INNER JOIN pln.tblProductSerials p 
	ON s.ProductSerialID=p.ProductSerialID 
	WHERE p.ProductSerialID=@ProductSerialID AND s.PSerialNo = @PSerialNo and StoreID=@StoreID
	AND Not  (s.ProcessID=90 and s.ProcessNo= @ProcessNo  and s.FiscalYear= @FiscalYear and s.SerialNo= @SerialNo ) 

	if @CountSerialInStore<=0
	Begin
		
		Set @StrErrorMessage = N' موجودی سریال    '+ @PSerialNo+ +' در انبار '++@StoreID+' منفی شده است '
		raiserror (@StrErrorMessage, 16, 1)
	End

	insert into [inv].[tblStorageDocsSerials]
	([ProcessID], [ProcessNo], [FiscalYear], [SerialNo], [DocRowNo], [AtomRowNo], [DocAtomRowNo], [ProductSerialID], [PSerialNo], [StoreID], [EnterKind], 
	[NumberPerSerial], [SerialDesc])
	SELECT @ProcessID, @ProcessNo, @FiscalYear, @SerialNo, @RowNo, @AtomRowNo, @AtomRowNo, @ProductSerialID, @PSerialNo, @StoreID, @EnterKind,1,@Desc

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
