USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid	
-- Create date   : 1394/09/10
-- Viewed By		 : Hadi Sadeghi
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش وضعیت یک رسید موقت
-- =============================================
Create PROCEDURE [inv].[RptTempReceipt_Situation]
	@ProcessID				Int = 170, 
	@ProcessNo				Int = 1,
	@FiscalYearFr			Int = Null,
	@SerialNoFr				Int = Null,
	@FiscalYearTo			Int = Null,
	@SerialNoTo				Int = Null,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@SelectedGoods			Int = 0, 
	@SelectedAcnt1			Int = 0, 
	@SelectedAcnt2			Int = 0, 
	@SelectedAcnt3			Int = 0, 
	@SelectedAcnt4			Int = 0,
	@SelectedSellerAcnt1	Int = 0, 
	@SelectedSellerAcnt2	Int = 0, 
	@SelectedSellerAcnt3	Int = 0, 
	@SelectedSellerAcnt4	Int = 0, 		
	@RepInfo				NVarChar(100) = '1@1@1',
	@ExtraParams			NVarChar(500) = ''

WITH ENCRYPTION
AS

DECLARE @StrSelect	    NVarChar(Max);
DECLARE @StrSelect1	    NVarChar(Max);
DECLARE @StrSelect2	    NVarChar(Max);
DECLARE @StrSelect3	    NVarChar(Max);
DECLARE @StrWhere	    NVarChar(Max);
DECLARE @StrWhereBuy	NVarChar(Max);

DECLARE @StrGoodsID		VarChar(100);
DECLARE @StrGoodsName	VarChar(100);
DECLARE @StrQuantity	VarChar(100);
DECLARE @StrGoodsUnit	VarChar(100);
DECLARE @StrOrderDuration VarChar(100);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @TmpConfirmed		Bit;
DECLARE @TmpNotConfirmed	Bit;
DECLARE @NumericBuy			Bit;
DECLARE @CurrencyBuy		Bit;

BEGIN --============== S T A R T  C O D E ===================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	IF (@ProcessNo  Is Null) SET @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;

	IF (@SelectedAcnt1	 	 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	 	 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	 	 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	 	 Is Null)	SET @SelectedAcnt4 = 0;
	
	IF (@SelectedSellerAcnt1 Is Null)	SET @SelectedSellerAcnt1 = 0;
	IF (@SelectedSellerAcnt2 Is Null)	SET @SelectedSellerAcnt2 = 0;
	IF (@SelectedSellerAcnt3 Is Null)	SET @SelectedSellerAcnt3 = 0;
	IF (@SelectedSellerAcnt4 Is Null)	SET @SelectedSellerAcnt4 = 0;		
	
	
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @TmpConfirmed	  = pub.funSplitString(@ExtraParams, '@', 1);	
	SET @TmpNotConfirmed  = pub.funSplitString(@ExtraParams, '@', 2);	
	SET @NumericBuy		  = pub.funSplitString(@ExtraParams, '@', 3);	
	SET @CurrencyBuy	  = pub.funSplitString(@ExtraParams, '@', 4);
		
	UPDATE inv.tblStorageDocsDtl 
    SET BaseDocRowNo = A.DocRowNo 
    FROM inv.tblStorageDocsDtl B INNER JOIN 
    inv.tblInvTempReceiptDtl A 
    ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo  AND 
    A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND 
    A.GoodsID=B.GoodsID AND A.DocRowNo<>B.BaseDocRowNo 
    AND A.GoodsID NOT IN (SELECT GoodsID 
                FROM inv.tblInvTempReceiptDtl AA 
                WHERE AA.ProcessID = 170 AND AA.ProcessID=A.ProcessID AND 
                AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo 
                GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID 
                HAVING COUNT(GoodsID)>1)

	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = 'C.ProcessID = 170 AND C.ProcessNo = ' + LTrim(Str(@ProcessNo))
	if @ProcessID=175
	Set @StrWhere = @StrWhere + ' and IsNull(C.CancelQty,0) >0'
	
	Set @StrWhereBuy = 'where 1=1 '

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (C.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND C.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (C.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND C.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND (C.DocDate = ''' + @DocDateFr + ''')'
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
				SET @StrWhere = @StrWhere + ' AND (C.DocDate >= ''' + @DocDateFr + ''')'
			IF @DocDateTo Is Not Null
				SET @StrWhere = @StrWhere + ' AND (C.DocDate <= ''' + @DocDateTo + ''')'
		End
		
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'C.GoodsID') 
		
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'C.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'C.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'C.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'C.AcntCode')
		
	If (@SelectedSellerAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'S.AcntCode')
	If (@SelectedSellerAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'S.AcntCode')
	If (@SelectedSellerAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'S.AcntCode')
	If (@SelectedSellerAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'S.AcntCode')
				
	--=============== Confirm Check
	If (@TmpConfirmed = 1 And @TmpNotConfirmed = 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (IsNull(C.Recognition,0) IN (1,2,3))'		
	End
	If (@TmpConfirmed = 0 And @TmpNotConfirmed = 1)
	Begin
		SET @StrWhere = @StrWhere + ' And (IsNull(C.Recognition,0) IN (0,4))'		
	End

	If (@NumericBuy = 1 And @CurrencyBuy = 0)  -- تعدادی
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND (IsNull(DocStep,0) > 0 And IsNull(DocStep,0) <= 1)'		
	End
	If (@NumericBuy = 0 And @CurrencyBuy = 1) -- ریالی
	Begin
	
		SET @StrWhereBuy = @StrWhereBuy + ' AND (IsNull(DocStep,0) > 1)'	
		
		
		
			
	End	
	---------------------------------------------------------------------------

	---- S E L E C T ----------------------------------------------------------
	Set @StrSelect1 = '
	Select C.ProcessID,' + LTrim(Str(@ProcessID))+' ProcessID2, C.ProcessNo, C.FiscalYear, C.SerialNo, C.GoodsID, GD.GoodsName, C.TempReceiptDate,C.DocDate, --C.DocRowNo, C.DocDate, C.AcntCode, C.SubUnitID
		   IsNull(Sum(C.Qty),0) As TmpBuyQuantity,
		   IsNull(Sum(C.CancelQty),0) As TmpBuyCancelQuantity, 
		   IsNull(Sum(S.SubUnitQuantity),0) As SubUnitQuantity, 
		   IsNull(Sum(S.SubUnitQuantityQ),0) As SubUnitQuantityQ, 
		   --IsNull(Sum(C.SubUnitQuantity),0) As ResideMovgat,-- Case When S.DocStep >= 1 Then ''True'' Else ''False'' End As CountBuy,
		  -- Case When S.DocStep >= 2 Then ''True'' Else ''False'' End As PriceBuy, --O.VchNo As OrderVchNo, T.VchNo TempRecVchNo,  
		   (Select Count(VchNo) From inv.tblStorageDocsHdr Where BaseProcessID = C.ProcessID And BaseProcessNo = C.ProcessNo And 
														  BaseFiscalYear = C.FiscalYear And BaseSerialNo = C.SerialNo And
														  VchNo > 0) AS HasVchNo 			
	From   cmr.FunCmrGoodsQtyRemain( 170 ,0,0,0,0,0,0,0,0,0)  C

	--================ خريد رسید موقت
	Left Join 
	(
		Select BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, SubUnitQuantity,SubUnitQuantityQ--, DocStep
		from ( 
				SELECT  BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo,SUM(SubUnitQuantityQ) SubUnitQuantityQ,SUM(SubUnitQuantity) SubUnitQuantity
				FROM (
					Select BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocStep, 
						   IsNull(Sum(CASE WHEN DocStep = 1 THEN SubUnitQuantity ELSE 0 END),0) As SubUnitQuantityQ,
						   IsNull(Sum(CASE WHEN DocStep >= 2 THEN SubUnitQuantity ELSE 0 END),0) As SubUnitQuantity
						   --,IsNull(Sum(SubUnitQuantity),0) As ResideMovagat
					From inv.tblStorageDocsDtl
					' + @StrWhereBuy + '
					Group By BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo, DocStep 
					) B
					GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo
	          ) A
	) S ON S.BaseProcessID = C.ProcessID And S.BaseProcessNo = C.ProcessNo And S.BaseFiscalYear = C.FiscalYear And 
									     S.BaseSerialNo = C.SerialNo And S.BaseDocRowNo = C.DocRowNo
	Left Join inv.tblGoodsDtl GD ON GD.GoodsID = C.GoodsID
	Where ' + @StrWhere + '
	Group By C.ProcessID, C.ProcessNo, C.FiscalYear, C.SerialNo, C.GoodsID, GD.GoodsName,C.TempReceiptDate ,C.DocDate--, S.DocStep '

	---- R U N ----------------------------------------------------------------
	--Print '--================================================'
	Print @StrSelect1;
	Exec sp_executesql @StrSelect1;
	---------------------------------------------------------------------------
END
GO
