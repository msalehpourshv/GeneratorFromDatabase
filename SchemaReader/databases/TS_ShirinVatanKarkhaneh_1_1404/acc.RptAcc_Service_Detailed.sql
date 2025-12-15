USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/04/31
-- Viewed By	 : 
-- Last Modified : 1388/05/08
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : گزارش تفصیلی خدمات برای یک سرویس یا مشتری
-- ==============================================
CREATE PROCEDURE [acc].[RptAcc_Service_Detailed]
	@ProcessNo			Int = 1,
	@SerialNoFr			Int = Null,
	@SerialNoTo			Int = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@SelectedService	Int = Null, -- انتخاب سرویس
	@SelectedAcnt1		Int = Null, -- انتخاب طرف حساب
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@SelectedExpert1	Int = Null, -- انتخاب ویزیتور
	@SelectedExpert2	Int = Null, 
	@SelectedExpert3	Int = Null, 
	@SelectedExpert4	Int = Null, 
	@RepOptions			VarChar(10) = '11',  -- bit array options
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect		NVarChar(4000);
DECLARE	@StrFrom		NVarChar(4000);
DECLARE	@StrWhere		NVarChar(4000);
DECLARE	@StrQty			VarChar(2000);
DECLARE	@StrPrc			VarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 

DECLARE	@ShowQuantity	Bit;  -- شامل ستون موجودی
DECLARE	@ShowPrice		Bit;  -- شامل ستون قیمت

DECLARE	@SelectedService2	Int; 
DECLARE	@SelectedService3	Int; 
DECLARE	@SelectedService4	Int; 

DECLARE	@SelectedVisitor1	Int; 
DECLARE	@SelectedVisitor2	Int; 
DECLARE	@SelectedVisitor3	Int; 
DECLARE	@SelectedVisitor4	Int; 

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init -------------------------------------------------------------------
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@RepOptions Is Null)	SET @RepOptions = '110'
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1'
	IF (@SortFields Is Null)	SET @SortFields = 'SerialNo'

	IF (@SelectedService Is Null)	SET @SelectedService = 0
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0
	IF (@SelectedExpert1 Is Null)	SET @SelectedExpert1 = 0
	IF (@SelectedExpert2 Is Null)	SET @SelectedExpert2 = 0
	IF (@SelectedExpert3 Is Null)	SET @SelectedExpert3 = 0
	IF (@SelectedExpert4 Is Null)	SET @SelectedExpert4 = 0

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @ShowQuantity	= Substring(@RepOptions, 1, 1)
	SET @ShowPrice		= Substring(@RepOptions, 2, 1)
	
	SET	@SelectedService2 = 0
	SET	@SelectedService3 = 0
	SET	@SelectedService4 = 0
	
	IF (@SelectedService2 Is Null)	SET @SelectedService2 = 0
	IF (@SelectedService3 Is Null)	SET @SelectedService3 = 0
	IF (@SelectedService4 Is Null)	SET @SelectedService4 = 0
	
	SET	@SelectedVisitor1 = 0
	SET	@SelectedVisitor2 = 0
	SET	@SelectedVisitor3 = 0
	SET	@SelectedVisitor4 = 0
		
	SET @SelectedService2  = pub.funSplitString(@RepInfo, '@', 4);	
	SET @SelectedService3  = pub.funSplitString(@RepInfo, '@', 5);
	SET @SelectedService4  = pub.funSplitString(@RepInfo, '@', 6);	
	SET @SelectedVisitor1  = pub.funSplitString(@RepInfo, '@', 7);
	SET @SelectedVisitor2  = pub.funSplitString(@RepInfo, '@', 8);
	SET @SelectedVisitor3  = pub.funSplitString(@RepInfo, '@', 9);
	SET @SelectedVisitor4  = pub.funSplitString(@RepInfo, '@', 10);	
	
	---------------------------------------------------------------------------

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
		
	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode')
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode')
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode')
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode')		
		
	------------------------------------------------------------

	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT *
	FROM
	(	
		SELECT	H.*, D.ServiceID, D.DescDtl, D.DocRowNo,
				D.ServiceQuantity Quantity, (D.ServiceQuantity * D.ServiceAmount) PriceDtl,
				[acc].[funGetServiceName] (D.ServiceID,' + @LangID + ') ServiceName, pub.GetCodeName(H.AcntCode, ' + @LangID + ') AcntName
		FROM	acc.tblServicesDtl D
		INNER JOIN acc.tblServicesHdr H ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
		WHERE	' + @StrWhere + '
	) T 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
