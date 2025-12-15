USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1393/07/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : چاپ قرارداد  
-- =============================================
create PROCEDURE [sal].[RptSal_Restaurant_Talar_Info_sub3] --2 
		
	@SerialNo  INT =81,
	@ProcessID INT =182,
	@ProcessNo INT =0,
	@FiscalYear INT =93
	 
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);
 

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
-- ================ WHERE ===========================

	set @StrWhere = '(h.ProcessID=1) '
	
	IF (@SerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND  h.BaseSerialNo =' + LTRIM(STR(@SerialNo))
	
	IF (@ProcessID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.BaseProcessID=' + LTRIM(STR(@ProcessID))
	
	IF (@ProcessNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.BaseProcessNo=' + LTRIM(STR(@ProcessNo))
		
	IF (@FiscalYear IS NOT null)
		SET @StrWhere = @StrWhere + ' AND  h.BaseFiscalYear =' + LTRIM(STR(@FiscalYear))
	
	
-- ================ SELECT ===========================

	SET @StrSelect ='SELECT d.SerialNo,d.FiscalYear, d.DocDate,ChequeDate,d.BankTypeID,VolumeFiscalYear,VolumeRowNo,
		PayTypeID,Amount,isnull(b.BankTypeName,'''')bankTypeName,ChequeNo
		 from trs.tblPayDtl d
		 inner join trs.tblPayHdr h
		 on d.ProcessID=h.ProcessID and d.ProcessNo=h.ProcessNo
		 and d.FiscalYear=h.FiscalYear and d.SerialNo=h.SerialNo
		 left join trs.tblBankTypesDtl b
		 on d.BankTypeID=b.BankTypeID			 				
	   WHERE '  + @StrWhere
				 

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
