USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : NOGREHPASAND
-- Create date   : 1393/02/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :  
-- =============================================
create PROCEDURE [phr].[RptPhr_InsuranceOrder]
		
	@CurrentSerialNo	INT =0,
	@FiscalYear			INT =0,
	@FooterText			NVARCHAR(200)='',
	@RepInfo			NVarChar(100) = '1@1@1' ,
	@pmFixOptions		NVarChar(100) = '1@1@1'

WITH ENCRYPTION

AS

DECLARE @StrSelect		NVarChar(4000);

DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID			Int; -- برای حالت کدهای انتخابی


BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

-- ================ WHERE ===========================

	set @StrWhere = '(1=1) '
	
	IF (@CurrentSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.SerialNo=' + LTRIM(STR(@CurrentSerialNo))
		
	IF (@FiscalYear IS NOT null)
		SET @StrWhere = @StrWhere + ' AND H.FiscalYear=' + LTRIM(STR(@FiscalYear))
		
	
-- ================ SELECT ===========================

	SET @StrSelect = 'select H.SerialNo,H.InsuranceOrder,D.InsurancePrice*D.Qty as InsurancePrice ,
		H.InsurancePortionSum,H.IllPortionSum,H.InsurancePriceSum from 
		phr.tblReciptionHdr H
		inner join phr.tblReciptionDtl D
		on H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	WHERE ' + @StrWhere 
	

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
