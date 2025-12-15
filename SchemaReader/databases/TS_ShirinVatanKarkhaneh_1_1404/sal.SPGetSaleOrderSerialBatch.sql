USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hamid
-- Create date   : 93/09/17
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [sal].[SPGetSaleOrderSerialBatch] 
(
	@ProcessID		Int,
	@BaseProcessID	Int,
	@ProcessNo		Int = Null,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,	
	@DocRowNo		Int = Null,
	@GoodsID		Varchar(20)
)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @HasSerial As Bit;
	Set @HasSerial = 0
	
	Select @HasSerial = HasSerial From inv.tblGoods G
	Where GoodsID = @GoodsID
	
	IF @HasSerial = 1
	BEGIN 
			IF @BaseProcessID = 90 
				Select SS.*
				From sal.tblSaleOrderDtl SO
				INNER Join inv.tblStorageDocsSerials SS 
				ON SS.ProcessID = SO.ProcessID And SS.SerialNo = SO.SerialNo And SS.ProcessNo = SO.ProcessNo And 
				   SS.FiscalYear = SO.FiscalYear And SS.DocRowNo = SO.DocRowNo
				Where SO.ProcessID = @ProcessID And (@ProcessNo IS NULL OR (@ProcessNo IS NOT NULL AND SO.ProcessNo = @ProcessNo)) And SO.FiscalYear = @FiscalYear And 
					  SO.SerialNo = @SerialNo And SO.DocRowNo = @DocRowNo And 
					  SS.ProductSerialID Not In (Select SS.ProductSerialID
												 From inv.tblStorageDocsDtl SD
												 INNER Join inv.tblStorageDocsSerials SS 
												 ON SS.ProcessID = SD.ProcessID 
												 Where SD.ProcessID = @BaseProcessID And SD.BaseProcessID = SO.ProcessID And (@ProcessNo IS NULL OR (@ProcessNo IS NOT NULL AND SD.BaseProcessNo = SO.ProcessNo)) And
													   SD.BaseFiscalYear = SO.FiscalYear And SD.BaseSerialNo = SO.SerialNo)
			Else IF @ProcessID = 171
				Select SS.*
				From inv.tblInvTempReceiptDtl SO
				INNER Join inv.tblStorageDocsSerials SS 
				ON SS.ProcessID = SO.ProcessID And SS.SerialNo = SO.SerialNo And SS.ProcessNo = SO.ProcessNo And 
				   SS.FiscalYear = SO.FiscalYear And SS.DocRowNo = SO.DocRowNo
				Where SS.Confirmed='True' AND SO.ProcessID = @ProcessID And (@ProcessNo IS NULL OR (@ProcessNo IS NOT NULL AND SO.ProcessNo = @ProcessNo)) And SO.FiscalYear = @FiscalYear And 
					  SO.SerialNo = @SerialNo And SO.DocRowNo = @DocRowNo And 
					  SS.ProductSerialID Not In (Select  SS.ProductSerialID
												 From inv.tblStorageDocsDtl SD
												 INNER Join inv.tblStorageDocsSerials SS 
												 ON SS.ProcessID = SD.ProcessID   And SS.ProcessNo = SS.ProcessNo And 
													SS.FiscalYear = SS.FiscalYear And SS.SerialNo = SD.SerialNo And SS.DocRowNo = SS.DocRowNo
												 Where SD.ProcessID=100 AND SD.SourceProcessID = 171 And SD.SourceSerialNo = @SerialNo)
			Else IF @BaseProcessID = 100
				Select SS.*
				From inv.tblStorageDocsDtl SO
				INNER Join inv.tblStorageDocsSerials SS 
				ON SS.ProcessID = SO.ProcessID And SS.SerialNo = SO.SerialNo And SS.ProcessNo = SO.ProcessNo And 
				   SS.FiscalYear = SO.FiscalYear And SS.DocRowNo = SO.DocRowNo
				Where SO.ProcessID = @ProcessID And (@ProcessNo IS NULL OR (@ProcessNo IS NOT NULL AND SO.ProcessNo = @ProcessNo)) And SO.FiscalYear = @FiscalYear And 
					  SO.SerialNo = @SerialNo And SO.DocRowNo = @DocRowNo And 
					  SS.ProductSerialID Not In (Select SS.ProductSerialID
												 From inv.tblStorageDocsDtl SD
												 INNER Join inv.tblStorageDocsSerials SS 
												 ON SS.ProcessID = SD.ProcessID 
												 Where SD.ProcessID = @BaseProcessID And SD.BaseProcessID = SO.ProcessID And (@ProcessNo IS NULL OR (@ProcessNo IS NOT NULL AND SD.BaseProcessNo = SO.ProcessNo)) And
													   SD.BaseFiscalYear = SO.FiscalYear And SD.BaseSerialNo = SO.SerialNo)
	END					
									
	Else
		Select * From inv.tblStorageDocsSerials 
		Where ProcessID = @ProcessID AND ProcessNo = @ProcessNo And FiscalYear = @FiscalYear And SerialNo = @SerialNo And DocRowNo = @DocRowNo
	
END
GO
