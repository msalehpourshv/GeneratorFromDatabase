USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 90/04/10
-- Description:	
-- =============================================
CREATE PROCEDURE [sal].[spUpdateBaseDocRowNo] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @OldRowNo		int,
 @NewRowNo		int,
 @GoodsID		VARCHAR(20)
 WITH ENCRYPTION
 AS

BEGIN
SET NOCOUNT ON;
	
	DECLARE @DocRowNo int

	SET @DocRowNo = 0
	
	SELECT @DocRowNo = DocRowNo 
	FROM sal.tblSaleOrderDtl
	WHERE	ProcessID  = @ProcessID	 AND
			ProcessNo  = @ProcessNo	 AND
			FiscalYear = @FiscalYear AND
			SerialNo   = @SerialNo	 AND 
			RowNo      = @OldRowNo   AND 
			GoodsID    = @GoodsID  
			
			
	IF 	@DocRowNo >0
		BEGIN
		
			UPDATE sal.tblSaleOrderDtl
			SET BaseDocRowNo = @NewRowNo
			WHERE BaseProcessID  = 180	AND
				  BaseProcessNo  = @ProcessNo	AND
			      BaseFiscalYear = @FiscalYear	AND
			      BaseSerialNo   = @SerialNo	AND
				  BaseDocRowNo   = @DocRowNo	AND	
				  GoodsID        = @GoodsID  
				  
			UPDATE inv.tblStorageDocsDtl
			SET BaseDocRowNo = @NewRowNo
			WHERE BaseProcessID  = 180	AND
				  BaseProcessNo  = @ProcessNo	AND
			      BaseFiscalYear = @FiscalYear	AND
			      BaseSerialNo   = @SerialNo	AND
				  BaseDocRowNo   = @DocRowNo 	AND			   
				  GoodsID        = @GoodsID  

			UPDATE sal.tblDistributionsAtom
			SET BaseOrderDocRowNo = @NewRowNo
			WHERE BaseOrderProcessID  = 180	AND
				  BaseOrderProcessNo  = @ProcessNo	AND
			      BaseOrderFiscalYear = @FiscalYear	AND
			      BaseOrderSerialNo   = @SerialNo	AND
				  BaseOrderDocRowNo   = @DocRowNo 	AND			   
				  GoodsID        = @GoodsID 				  
		END

END
GO
