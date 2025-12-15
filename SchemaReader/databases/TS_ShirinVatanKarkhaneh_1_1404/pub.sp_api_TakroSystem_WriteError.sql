USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [pub].[sp_api_TakroSystem_WriteError]
@ProcessId as int,
@ProcessNo as int,
@SerialNo as int,
@FiscalYear as int,
@ErrorSide as INT,
@Error as nvarchar(max),
@DateTime as datetime,
@TaxID as nvarchar(max),
@TPCanceled as bit,
@TPEdited as bit

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @MaxRowNo INT
BEGIN TRY
	

	SELECT @MaxRowNo= ISNULL(DocRowNo,0)+1 FROM pub.tblTPErrors
	WHERE  ProcessID=@ProcessId AND ProcessNo=@ProcessNo AND
	  SerialNo=@SerialNo AND FiscalYear=@FiscalYear

	  
	 SET @MaxRowNo =ISNULL(@MaxRowNo ,1)

	INSERT INTO pub.tblTPErrors
	(SerialNo,ProcessID,ProcessNo,FiscalYear,DocRowNo,MSG,ErrState,SendDateTime,TaxID,TPEdited,TPCanceled)
	 VALUES( @SerialNo,@ProcessId,@ProcessNo,@FiscalYear,@MaxRowNo,@Error,@ErrorSide,@DateTime,@TaxID,@TPEdited,@TPCanceled)

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	
GO
