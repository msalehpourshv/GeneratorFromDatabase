USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		Hadi Sadeghi
-- Create date: 90/04/10
-- Description:	
-- =============================================
CREATE PROCEDURE [sal].[spDeleteBaseDocRowNo] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @OldRowNo		int,
 @GoodsID		VARCHAR(20)
 WITH ENCRYPTION
 AS

BEGIN
SET NOCOUNT ON;
	
	DECLARE @DocRowNo		int
	DECLARE @BaseSerialNo	varchar(20)

	SET @DocRowNo = 0
	SET @BaseSerialNo = 0
	
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
		
			SELECT top 1 @BaseSerialNo = SerialNo 
			FROM sal.tblSaleOrderDtl
			WHERE BaseProcessID  = 180	AND
				  BaseProcessNo  = @ProcessNo	AND
			      BaseFiscalYear = @FiscalYear	AND
			      BaseSerialNo   = @SerialNo	AND
				  BaseDocRowNo   = @DocRowNo	AND	
				  GoodsID        = @GoodsID  
				  
			IF @BaseSerialNo > 0
				BEGIN
	  				DECLARE @StrErr1 NVARCHAR(4000)
					SET @StrErr1 = '#$ کالای ' + @GoodsID + ' در برگشت از سفارش به شماره برگه ' + @BaseSerialNo + ' استفاده شده است #$'
					raiserror (@StrErr1, 16, 1)
				END	  
			
			SELECT  top 1 @BaseSerialNo = SerialNo 
			FROM inv.tblStorageDocsDtl
			WHERE BaseProcessID  = 180	AND
				  BaseProcessNo  = @ProcessNo	AND
			      BaseFiscalYear = @FiscalYear	AND
			      BaseSerialNo   = @SerialNo	AND
				  BaseDocRowNo   = @DocRowNo 	AND			   
				  GoodsID        = @GoodsID  
				  
				  
			IF @BaseSerialNo > 0
				BEGIN
	  				DECLARE @StrErr2 NVARCHAR(4000)
					SET @StrErr2 = '#$ کالای ' + @GoodsID + ' در فروش به شماره برگه ' + @BaseSerialNo + ' استفاده شده است #$'
					raiserror (@StrErr2, 16, 1)
				END	 	
				
				
			SELECT  top 1 @BaseSerialNo = SerialNo 
			FROM sal.tblDistributionsAtom
			WHERE BaseOrderProcessID  = 180	AND
				  BaseOrderProcessNo  = @ProcessNo	AND
			      BaseOrderFiscalYear = @FiscalYear	AND
			      BaseOrderSerialNo   = @SerialNo	AND
				  BaseOrderDocRowNo   = @DocRowNo 	AND			   
				  GoodsID        = @GoodsID  
				  
				  
			IF @BaseSerialNo > 0
				BEGIN
	  				DECLARE @StrErr3 NVARCHAR(4000)
					SET @StrErr3 = '#$ کالای ' + @GoodsID + ' در پخش به شماره برگه ' + @BaseSerialNo + ' استفاده شده است #$'
					raiserror (@StrErr3, 16, 1)
				END	 								  
		END

END
GO
