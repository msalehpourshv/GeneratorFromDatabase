USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/04/30
-- Viewed By	 : 
-- Last Modified : 1388/05/08
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : گزارش سرجمع خدمات برای یک سرویس یا سرویسها
-- ==============================================
CREATE PROCEDURE [acc].[RptAcc_Service_Summary_Service]
	@ProcessNo			Int = 1,
	@SerialNoFr			Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedService	Int = 0, 
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@SelectedExpert1	Int = 0, 
	@SelectedExpert2	Int = 0, 
	@SelectedExpert3	Int = 0, 
	@SelectedExpert4	Int = 0, 
	@RepOptions			VarChar(10) = '110', -- bit array options
	@SortFields			NVarChar(100) = Null,   -- Order By Field List
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);

DECLARE @ShowQuantity	Bit;  -- شامل ستون مقدار
DECLARE @ShowPrice		Bit;  -- شامل ستون قیمت

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE	@SelectedService2	Int; 
DECLARE	@SelectedService3	Int; 
DECLARE	@SelectedService4	Int; 

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@RepOptions Is Null)	SET @RepOptions = '110'
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1'
	IF (@SortFields Is Null)	SET @SortFields = 'ServiceID'

	IF (@SelectedService Is Null)	SET @SelectedService = 0
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0
	IF (@SelectedExpert1 Is Null)	SET @SelectedExpert1 = 0
	IF (@SelectedExpert2 Is Null)	SET @SelectedExpert2 = 0
	IF (@SelectedExpert3 Is Null)	SET @SelectedExpert3 = 0
	IF (@SelectedExpert4 Is Null)	SET @SelectedExpert4 = 0

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1);
	SET @ShowPrice		= Substring(@RepOptions, 2, 1);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET	@SelectedService2 = 0
	SET	@SelectedService3 = 0
	SET	@SelectedService4 = 0
	
	IF (@SelectedService2 Is Null)	SET @SelectedService2 = 0
	IF (@SelectedService3 Is Null)	SET @SelectedService3 = 0
	IF (@SelectedService4 Is Null)	SET @SelectedService4 = 0
	
	SET @SelectedService2  = pub.funSplitString(@RepInfo, '@', 4);	
	SET @SelectedService3  = pub.funSplitString(@RepInfo, '@', 5);
	SET @SelectedService4  = pub.funSplitString(@RepInfo, '@', 6);	
	-- --------------------------------------------------
	
	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '(D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')' 

	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoFr)) + ')' 

	If (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		If (@DocDateFr = @DocDateTo)
			Set @StrWhere = @StrWhere + ' AND (H.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			If (@DocDateFr Is Not Null)
				Set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
			If @DocDateTo Is Not Null
				Set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
		End

	If (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		If (@VchNoFr = @VchNoTo)
			Set @StrWhere = @StrWhere + ' AND (H.VchNo  = ' + LTrim(Str(@VchNoFr)) + ')'
		Else
		Begin
			If (@VchNoFr Is Not Null)
				Set @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@VchNoFr)) + ')'
			If (@VchNoTo Is Not Null)
				Set @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@VchNoTo)) + ')'
		End

	If (@SelectedService > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService, 'D.ServiceID') 
	If (@SelectedService2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService2, 'D.ServiceID') 
	If (@SelectedService3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService3, 'D.ServiceID') 
	If (@SelectedService4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService4, 'D.ServiceID') 						

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	If (@SelectedExpert1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert1, 'H.ExpertCode') 
	If (@SelectedExpert2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert2, 'H.ExpertCode') 
	If (@SelectedExpert3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert3, 'H.ExpertCode') 
	If (@SelectedExpert4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert4, 'H.ExpertCode')
	---------------------------------------------------------

	-- Select Clause ----------------------------------------
	SET @StrSelect = '
	SELECT  D.ServiceID, [acc].[funGetServiceName] (D.ServiceID,' + @LangID + ') ServiceName,
		SUM(D.ServiceQuantity) AS Quantity,
		SUM(D.ServiceQuantity * D.ServiceAmount) AS Price
	FROM    acc.tblServicesHdr H 
			INNER JOIN acc.tblServicesDtl D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
	WHERE   ' + @StrWhere + '
	GROUP BY D.ServiceID, [acc].[funGetServiceName] (D.ServiceID,' + @LangID + ')
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
