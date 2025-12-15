USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/04/30
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش سرجمع خدمات برای یک طرف حساب یا طرف حسابها
-- ==============================================
CREATE PROCEDURE [acc].[RptAcc_Service_Summary_Acnt]
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

DECLARE	@SelectedVisitor1	Int; 
DECLARE	@SelectedVisitor2	Int; 
DECLARE	@SelectedVisitor3	Int; 
DECLARE	@SelectedVisitor4	Int; 

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '110';
	IF (@SortFields Is Null)	SET @SortFields = 'AcntCode';

	IF (@SelectedService Is Null)	SET @SelectedService = 0;
	IF (@SelectedAcnt1 Is Null)		SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2 Is Null)		SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3 Is Null)		SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4 Is Null)		SET @SelectedAcnt4 = 0;
	IF (@SelectedExpert1 Is Null)	SET @SelectedExpert1 = 0;
	IF (@SelectedExpert2 Is Null)	SET @SelectedExpert2 = 0;
	IF (@SelectedExpert3 Is Null)	SET @SelectedExpert3 = 0;
	IF (@SelectedExpert4 Is Null)	SET @SelectedExpert4 = 0;

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
		
	-- --------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	SET @StrWhere = '(D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')' 
	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.SerialNo <= ' + LTrim(Str(@SerialNoFr)) + ')' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (H.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			IF (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
		End

	IF (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		IF (@VchNoFr = @VchNoTo)
			SET @StrWhere = @StrWhere + ' AND (H.VchNo  = ' + LTrim(Str(@VchNoFr)) + ')'
		Else
		Begin
			IF (@VchNoFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (H.VchNo >= ' + LTrim(Str(@VchNoFr)) + ')'
			IF (@VchNoTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND (H.VchNo <= ' + LTrim(Str(@VchNoTo)) + ')'
		End

	IF (@SelectedService > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService, 'D.ServiceID') 
	If (@SelectedService2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService2, 'D.ServiceID') 
	If (@SelectedService3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService3, 'D.ServiceID') 
	If (@SelectedService4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedService4, 'D.ServiceID') 						

	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	IF (@SelectedExpert1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert1, 'H.ExpertCode') 
	IF (@SelectedExpert2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert2, 'H.ExpertCode') 
	IF (@SelectedExpert3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert3, 'H.ExpertCode') 
	IF (@SelectedExpert4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedExpert4, 'H.ExpertCode')
		
	If (@SelectedVisitor1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor1, 'H.VisitorAcntCode')
	If (@SelectedVisitor2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor2, 'H.VisitorAcntCode')
	If (@SelectedVisitor3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor3, 'H.VisitorAcntCode')
	If (@SelectedVisitor4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedVisitor4, 'H.VisitorAcntCode')		

	---------------------------------------------------------
	-- Select Clause ----------------------------------------
	SET @StrSelect = '
	SELECT  H.AcntCode, pub.GetCodeName(H.AcntCode, ' + @LangID + ') AS AcntName,
		SUM(D.ServiceQuantity) AS Quantity,
		SUM(D.ServiceQuantity * D.ServiceAmount) AS Price
	FROM    acc.tblServicesHdr H 
			INNER JOIN acc.tblServicesDtl D ON H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
	WHERE   ' + @StrWhere + '
	GROUP BY H.AcntCode
	ORDER BY ' + @SortFields
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
