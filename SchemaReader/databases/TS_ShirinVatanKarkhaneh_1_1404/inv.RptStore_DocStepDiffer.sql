USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/10/12
-- Viewed By	 : 
-- Last Modified : 1390/07/06
-- Last Modifier : TakroSystem\Zia
-- Description	 : برگه هائی که تعدادی دارد و ریالی ندارد
-- ==============================================
Create PROCEDURE [inv].[RptStore_DocStepDiffer]
	@ProcessID		Int = 55,
	@ProcessNo		Int = 1,
	@SelectedAcnt1	Int = 0, 
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@DocStep1		Int = 1,
	@DocStep2		Int = 2,
	@ProcessName	NVarChar(100) = '',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect		NVarChar(4000);
DECLARE	@StrFrom		NVarChar(4000);
DECLARE	@StrWhere1		NVarChar(4000);
DECLARE	@StrWhere2		NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE	@AcntPart	Int;
DECLARE	@AcntLayerStart	Int;
DECLARE	@AcntLayerLen	Int;
BEGIN -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables ---------------------------------------
	If (@DocStep1		IS Null)	SET @DocStep1 = 1;
	If (@DocStep2		Is Null)	SET @DocStep2 = 2;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- ------------------------------------------------------

	SELECT @AcntPart=[acc].[FunGetAcntInfoForRemain](1)
	SELECT @AcntLayerStart=[acc].[FunGetAcntInfoForRemain](2)
	SELECT @AcntLayerLen=[acc].[FunGetAcntInfoForRemain](3)

	-- Where Clause -----------------------------------------
	Set @StrWhere1 = ' (ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ') AND (ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ') '

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere1 = @StrWhere1 + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'AcntCode')

	SET @StrWhere2 = @StrWhere1

	IF @ProcessID = 70
		Set @StrWhere1 = @StrWhere1 + ' AND (StoreID2 = '''')' 
		
	SET @StrWhere1 = @StrWhere1 + ' AND (DocStep = ' + Ltrim(RTrim(Str(@DocStep1))) + ')' 
	SET @StrWhere2 = @StrWhere2 + ' AND ((DocStep = ' + LTrim(RTrim(Str(@DocStep2))) + ') 
									AND (VchNo>0 OR VchNo2>0 ))' 
	-- ------------------------------------------------------

	-- Select Clause ----------------------------------------
	SET @StrSelect = '
	SELECT a.*,
		   AcntName
	FROM inv.tblStorageDocsHdr a
	INNER JOIN (
		SELECT ProcessID, 
			   ProcessNo, 
			   FiscalYear, 
			   SerialNo
		FROM inv.tblStorageDocsHdr
		WHERE ' + @StrWhere1 + '

		EXCEPT

		SELECT ProcessID, 
			   ProcessNo, 
			   FiscalYear, 
			   SerialNo
		FROM inv.tblStorageDocsHdr
		WHERE  ' + @StrWhere2 + '
	) b ON a.ProcessID = b.ProcessID 
	   AND a.ProcessNo = b.ProcessNo 
	   AND a.FiscalYear = b.FiscalYear 
	   AND a.SerialNo = b.SerialNo
	LEFT JOIN acc.tblAcntDtl c ON c.AcntCode = substring (a.AcntCode,'+  LTrim(RTrim(str(@AcntLayerStart)))+','+  LTrim(RTrim(str(@AcntLayerLen)))+') 
							  AND c.PartNumber = '+  LTrim(RTrim(str(@AcntPart)))+'	
							  AND c.LanguageID = '+  LTrim(RTrim(str(@LangID)))+'
	ORDER BY a.ProcessID, a.ProcessNo, a.FiscalYear, a.SerialNo	'
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	-- ------------------------------------------------------

End
GO
