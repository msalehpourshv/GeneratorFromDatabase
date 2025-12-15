USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid	
-- Create date   : 1394/09/10
-- Viewed By	 : Hadi Sadeghi
-- Last Modified : 
-- Last Modifier : 
-- Description   : گزارش وضعیت یک درخواست
-- =============================================
Create PROCEDURE [cmr].[RptRequest_Situation]
	@ProcessID				Int = 150, 
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
	@SelectedORAcnt1		Int = 0, 
	@SelectedORAcnt2		Int = 0, 
	@SelectedORAcnt3		Int = 0, 
	@SelectedORAcnt4		Int = 0,
	@SelectedSellerAcnt1	Int = 0, 
	@SelectedSellerAcnt2	Int = 0, 
	@SelectedSellerAcnt3	Int = 0, 
	@SelectedSellerAcnt4	Int = 0, 		
	@RepInfo				NVarChar(100) = '1@1@1',
	@ExtraParams			NVarChar(500) = ''

WITH ENCRYPTION
AS
Declare @StrSelect		NVarChar(Max);
Declare @StrSelect1		NVarChar(Max);
Declare @StrSelect2		NVarChar(Max);
Declare @StrSelect3		NVarChar(Max);
Declare @StrSelect4		NVarChar(Max);
Declare @StrSelect5		NVarChar(Max);
Declare @StrWhere		NVarChar(Max);
Declare @StrWhere2		NVarChar(Max);
Declare @StrWhereAll	NVarChar(Max);

Declare @StrWhereOrd	NVarChar(200);
Declare @StrWhereBuy	NVarChar(200);
Declare @StrWhereTmp	NVarChar(200);
Declare @StrWhereOrdTmp	NVarChar(200);

Declare @StrGoodsID		VarChar(100);
Declare @StrGoodsName	VarChar(100);
Declare @StrQuantity	VarChar(100);
Declare @StrGoodsUnit	VarChar(100);
Declare @StrOrderDuration VarChar(100);
Declare @SenderDepartmentID VarChar(20);
Declare @PriorityCode VarChar(5);
DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

DECLARE @DocStep		Int;

DECLARE @ReqConfirmed		Bit;
DECLARE @ReqNotConfirmed	Bit;
DECLARE @OrdConfirmed		Bit;
DECLARE @OrdNotConfirmed	Bit;
DECLARE @TmpConfirmed		Bit;
DECLARE @TmpNotConfirmed	Bit;
DECLARE @NumericBuy			Bit;
DECLARE @CurrencyBuy		Bit;
DECLARE @OrderDateFr		Char(10);
DECLARE @OrderDateTo		Char(10);
Begin --============ S T A R T  C O D E ===================================================

--	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set NoCount On;

	--============== 
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- I N I T ----------------------------------------------------------------
	IF (@ProcessNo  Is Null) SET @ProcessNo  = 1;
	IF (@RepInfo	Is Null) SET @RepInfo	= '1@1@1';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;

	IF (@SelectedAcnt1	 	 Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	 	 Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	 	 Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	 	 Is Null)	SET @SelectedAcnt4 = 0;
	
	IF (@SelectedORAcnt1 	 Is Null)	SET @SelectedORAcnt1 = 0;
	IF (@SelectedORAcnt2 	 Is Null)	SET @SelectedORAcnt2 = 0;
	IF (@SelectedORAcnt3 	 Is Null)	SET @SelectedORAcnt3 = 0;
	IF (@SelectedORAcnt4 	 Is Null)	SET @SelectedORAcnt4 = 0;	
	
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
	
	SET @ReqConfirmed		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @ReqNotConfirmed	= pub.funSplitString(@ExtraParams, '@', 2);
	SET @OrdConfirmed		= pub.funSplitString(@ExtraParams, '@', 3);
	SET @OrdNotConfirmed	= pub.funSplitString(@ExtraParams, '@', 4);	
	SET @TmpConfirmed		= pub.funSplitString(@ExtraParams, '@', 5);	
	SET @TmpNotConfirmed	= pub.funSplitString(@ExtraParams, '@', 6);	
	SET @NumericBuy			= pub.funSplitString(@ExtraParams, '@', 7);	
	SET @CurrencyBuy		= pub.funSplitString(@ExtraParams, '@', 8);	
	SET @SenderDepartmentID	= pub.funSplitString(@ExtraParams, '@', 9);
	SET @PriorityCode       = pub.funSplitString(@ExtraParams, '@', 10);
	SET @OrderDateFr        = pub.funSplitString(@ExtraParams, '@', 16);
	SET @OrderDateTo        = pub.funSplitString(@ExtraParams, '@', 17);
	
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = 'Cmr.ProcessID = ' + LTrim(Str(@ProcessID)) + ' AND Cmr.ProcessNo = ' + LTrim(Str(@ProcessNo))
	
	Set @StrWhereOrd = '1 = 1'	
	Set @StrWhereTmp = '1 = 1'	
	Set @StrWhereOrdTmp = '1 = 1'	
	Set @StrWhereBuy = '1 = 1'	
	
	Set @StrWhereAll = '1 = 1'	
	
	Set @StrWhere2 = 'O1.ProcessID = 160'

	If (@SerialNoFr Is Not Null)
	Begin
		Set @StrWhere = @StrWhere + ' AND (Cmr.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(Cmr.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND Cmr.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	End
	
	If (@SerialNoTo Is Not Null)
	Begin
		Set @StrWhere = @StrWhere + ' AND (Cmr.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(Cmr.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND Cmr.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	End

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
		Begin
			SET @StrWhere = @StrWhere + ' AND (Cmr.DocDate = ''' + @DocDateFr + ''')'
		End
		
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
			Begin
				SET @StrWhere = @StrWhere + ' AND (Cmr.DocDate >= ''' + @DocDateFr + ''')'
			End
			IF @DocDateTo Is Not Null
			Begin
				SET @StrWhere = @StrWhere + ' AND (Cmr.DocDate <= ''' + @DocDateTo + ''')'
			End
		End
		
	If (@SelectedGoods > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'Cmr.GoodsID') 
	End
		
	If (@SelectedAcnt1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'Cmr.AcntCode')
	End
	If (@SelectedAcnt2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'Cmr.AcntCode')
	End
	If (@SelectedAcnt3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'Cmr.AcntCode')
	End
	If (@SelectedAcnt4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'Cmr.AcntCode')
	End
		
	If (@SelectedORAcnt1 > 0)
	Begin
		SET @StrWhereOrd = @StrWhereOrd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedORAcnt1, 'O.AcntCode')
	End
	If (@SelectedORAcnt2 > 0)
	Begin
		SET @StrWhereOrd = @StrWhereOrd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedORAcnt2, 'O.AcntCode')
	End
	If (@SelectedORAcnt3 > 0)
	Begin
		SET @StrWhereOrd = @StrWhereOrd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedORAcnt3, 'O.AcntCode')
	End
	If (@SelectedORAcnt4 > 0)
	Begin
		SET @StrWhereOrd = @StrWhereOrd + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedORAcnt4, 'O.AcntCode')		
	End
	
	If (@SelectedORAcnt1 > 0 OR @SelectedORAcnt2 > 0 OR @SelectedORAcnt3 > 0 OR @SelectedORAcnt4 > 0)
		SET @StrWhereAll = @StrWhereAll + ' AND (A.CmrOrdQuantity > 0)'	
				
	If (@SelectedSellerAcnt1 > 0)
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSellerAcnt1, 'S.AcntCode')
	End
	If (@SelectedSellerAcnt2 > 0)
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSellerAcnt2, 'S.AcntCode')
	End
	If (@SelectedSellerAcnt3 > 0)
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSellerAcnt3, 'S.AcntCode')
	End
	If (@SelectedSellerAcnt4 > 0)
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedSellerAcnt4, 'S.AcntCode')
	End
	
	If (@SelectedSellerAcnt1 > 0 OR @SelectedSellerAcnt2 > 0 OR @SelectedSellerAcnt3 > 0 OR @SelectedSellerAcnt4 > 0)
		SET @StrWhereAll = @StrWhereAll + ' AND (A.CmrBuyQuantity > 0)'    

	If (@SenderDepartmentID >0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SenderDepartmentID, 'CMRH.SenderDepartmentID')
		
    If (@PriorityCode>0)
	    SET @StrWhere = @StrWhere + ' AND  (Cmr.PriorityCode = ' + @PriorityCode  + ')'
	--============= Confirm Check
	If (@ReqConfirmed = 1 And @ReqNotConfirmed = 0)
		SET @StrWhere = @StrWhere + ' AND (IsNull(Cmr.DocStep,0) > 1)'
	If (@ReqConfirmed = 0 And @ReqNotConfirmed = 1)
		SET @StrWhere = @StrWhere + ' AND (IsNull(Cmr.DocStep,0) <= 1)'		

	If (@OrdConfirmed = 1 And @OrdNotConfirmed = 0)
	Begin
		SET @StrWhereOrd = @StrWhereOrd + ' AND (IsNull(O.DocStep,0) > 1)'
		SET @StrWhereAll = @StrWhereAll + ' AND (A.CmrOrdQuantity > 0 And A.CmrOrdConfirmQuantity > 0)'
	End
	If (@OrdConfirmed = 0 And @OrdNotConfirmed = 1)
	Begin
		SET @StrWhereOrd = @StrWhereOrd + ' AND (IsNull(O.DocStep,0) <= 1)'		
		SET @StrWhereAll = @StrWhereAll + ' AND A.CmrOrdQuantity > 0'
	End
		
	If (@TmpConfirmed = 1 And @TmpNotConfirmed = 0)
	Begin
		SET @StrWhereTmp = @StrWhereTmp + ' AND (IsNull(T.DocStep,0) > 1 AND IsNull(T.Recognition,0) IN (1,2,3))'		
		SET @StrWhereOrdTmp = @StrWhereOrdTmp + ' AND (IsNull(T.DocStep,0) > 1 AND IsNull(T.Recognition,0) IN (1,2,3))'		
		SET @StrWhereAll = @StrWhereAll + ' AND (A.CmrOrdTmpQuantity > 0 And A.CmrOrdTmpConfirmQuantity > 0)'
	End
	If (@TmpConfirmed = 0 And @TmpNotConfirmed = 1)
	Begin
		SET @StrWhereTmp = @StrWhereTmp + ' AND (IsNull(T.DocStep,0) <= 1 OR IsNull(T.Recognition,0) IN (0,4))'		
		SET @StrWhereOrdTmp = @StrWhereOrdTmp + ' AND (IsNull(T.DocStep,0) <= 1 OR IsNull(T.Recognition,0) IN (0,4))'		
		SET @StrWhereAll = @StrWhereAll + ' AND A.CmrOrdTmpQuantity > 0'
	End

	If (@NumericBuy = 1 And @CurrencyBuy = 0)
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND (IsNull(S.DocStep,0) <= 1)'		
		SET @StrWhereAll = @StrWhereAll + ' AND A.NumericBuyCount > 0'
		--SET @StrWhere = @StrWhere + ' AND [cmr].[funGetCmrBuyOprations] (Cmr.GoodsID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo, 1) > 0' + 
		--							' AND [cmr].[funGetCmrBuyOprations] (Cmr.GoodsID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo, 2) < [cmr].[funGetCmrBuyOprations] (Cmr.GoodsID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo, 1)'
	End
	If (@NumericBuy = 0 And @CurrencyBuy = 1)
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND (IsNull(S.DocStep,0) > 1)'		
		SET @StrWhereAll = @StrWhereAll + ' AND (A.NumericBuyCount > 0 And A.CurrencyBuyCount > 0)'
		--SET @StrWhere = @StrWhere + ' AND [cmr].[funGetCmrBuyOprations] (Cmr.GoodsID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo, 1) > 0' + 
		--							' AND [cmr].[funGetCmrBuyOprations] (Cmr.GoodsID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo, 2) = [cmr].[funGetCmrBuyOprations] (Cmr.GoodsID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo, 1)'
	End
	if @OrderDateFr Is Not Null  and @OrderDateFr <> ''
		Set @StrWhere = @StrWhere + ' AND (Cmr.OrderDate >= ''' + @OrderDateFr + ''')'
	
	if @OrderDateTo Is Not Null  and @OrderDateTo <> ''
		Set @StrWhere = @StrWhere + ' AND (Cmr.OrderDate <= ''' + @OrderDateTo + ''')'

select Cmr.ProcessID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo,DocRowNo ,GoodsID ,Cmr.DocStep
		,SubUnitQuantity CmrQty
		,SubUnitQuantity CmrQtyOK
		,SubUnitQuantity CmrQtyCancel	
		,SubUnitQuantity OrdQty
		,SubUnitQuantity OrdQtyOK
		,SubUnitQuantity OrdQtyCancel	
		,SubUnitQuantity TmpQty
		,SubUnitQuantity TmpQtyOK
		,SubUnitQuantity TmpQtyCancel	
		,SubUnitQuantity BuyQty
		,SubUnitQuantity BuyQtyCancel	
		,DescDtl
		,DescDtl2
		,DescDtl DocDesc
		,Cmr.DocDate
		,Cmr.OrderDate
		,UnitName
		,ISNULL(DEP.DepartmentName,'')  DepartmentName
	into #cmr
		 From cmr.tblCMRDtl Cmr
		 inner join inv.tblUnitsDtl U 
					ON U.UnitID=Cmr.SubUnitID	
	     inner join cmr.tblCMRHdr CMRH 
		           ON CMRH.ProcessID = Cmr.ProcessID   
			       And CMRH.ProcessNo =Cmr.ProcessNo   
			       And CMRH.FiscalYear = Cmr.FiscalYear 
			       And CMRH.SerialNo = Cmr.SerialNo
		LEFT JOIN  prs.tblDepartmentsDtl DEP
		            On CMRH.SenderDepartmentID=DEP.DepartmentID
		 
					where 1=0
		
--12===========   درخواست
		print ' درخواست'
Set @StrSelect = '
		insert into  #cmr
		select  Cmr.ProcessID, Cmr.ProcessNo, Cmr.FiscalYear, Cmr.SerialNo,DocRowNo ,GoodsID,Cmr.DocStep
		,SubUnitQuantity,ConfirmQuantity ,0
		,0,0,0
		,0,0,0
		,0,0,DescDtl,DescDtl2,'''',Cmr.DocDate,Cmr.OrderDate,UnitName,ISNULL(DEP.DepartmentName,'''') DepartmentName  From cmr.tblCMRDtl  Cmr
		inner join inv.tblUnitsDtl U 
					ON U.UnitID=Cmr.SubUnitID
	    inner join cmr.tblCMRHdr CMRH 
		           ON CMRH.ProcessID = Cmr.ProcessID   
			       And CMRH.ProcessNo =Cmr.ProcessNo   
			       And CMRH.FiscalYear = Cmr.FiscalYear 
			       And CMRH.SerialNo = Cmr.SerialNo	
		LEFT join  prs.tblDepartmentsDtl DEP
		            On CMRH.SenderDepartmentID=DEP.DepartmentID
		Where ' + @StrWhere 
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
		
	update #cmr
		set DocDesc= C2.DocDesc
		from  #cmr Cmr
		inner Join cmr.tblCMRHdr C2 
		ON C2.ProcessID = Cmr.ProcessID   
			And C2.ProcessNo = Cmr.ProcessNo   
			And C2.FiscalYear = Cmr.FiscalYear 
			And C2.SerialNo = Cmr.SerialNo     				
			
--3=========== انصراف از درخواست
print ' انصراف از درخواست'
Set @StrSelect = '
		update #cmr
		set CmrQtyCancel= isnull(ConfirmQuantity,0)
		from  #cmr Cmr
		Left Join cmr.tblCMRDtl C2 
		ON C2.BaseProcessID = Cmr.ProcessID   
			And C2.BaseProcessNo = Cmr.ProcessNo   
			And C2.BaseFiscalYear = Cmr.FiscalYear 
			And C2.BaseSerialNo = Cmr.SerialNo     
			And C2.BaseDocRowNo = Cmr.DocRowNo
			And	C2.GoodsID = Cmr.GoodsID  '
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

		print ' درخواست  --> '+'سفارش ' 

--45=========== سفارش طبق درخواست			
Set @StrSelect = '
		update #cmr
		set	 OrdQty=  IsNull(CmrOrd.SubUnitQuantity,0) 
			,OrdQtyOK= IsNull(CmrOrd.ConfirmQuantity,0)
		from  #cmr Cmr
		Left Join  
		(Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				   IsNull(Sum(O.SubUnitQuantity),0) SubUnitQuantity, IsNull(Sum(O.ConfirmQuantity),0) ConfirmQuantity
			 From cmr.tblOrderDtl O			
			 Where ' + @StrWhereOrd + '
			 Group By O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
				)CmrOrd
			
			ON CmrOrd.BaseProcessID = Cmr.ProcessID	
			And CmrOrd.BaseProcessNo = Cmr.ProcessNo	
			And CmrOrd.BaseFiscalYear = Cmr.FiscalYear  
			And CmrOrd.BaseSerialNo = Cmr.SerialNo		
			And CmrOrd.BaseDocRowNo = Cmr.DocRowNo
			And	CmrOrd.GoodsID = Cmr.GoodsID  
		'
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	print ' درخواست  --> '+'انصراف سفارش  ' 
--6=========== انصراف سفارش طبق درخواست			
Set @StrSelect = '
		update #cmr
		set	OrdQtyCancel= IsNull(CmrOrd.ConfirmQuantity,0)
		from  #cmr Cmr
		Left Join  
		(Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				   IsNull(Sum(O2.ConfirmQuantity),0) ConfirmQuantity
			 From cmr.tblOrderDtl O			
			 inner join cmr.tblOrderDtl O2
			 ON O2.BaseProcessID = O.ProcessID	
			And O2.BaseProcessNo = O.ProcessNo	
			And O2.BaseFiscalYear = O.FiscalYear  
			And O2.BaseSerialNo = O.SerialNo		
			And O2.BaseDocRowNo = O.DocRowNo  
			 Where ' + @StrWhereOrd + '
			 Group By O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
				)CmrOrd
			
			ON CmrOrd.BaseProcessID = Cmr.ProcessID	
			And CmrOrd.BaseProcessNo = Cmr.ProcessNo	
			And CmrOrd.BaseFiscalYear = Cmr.FiscalYear  
			And CmrOrd.BaseSerialNo = Cmr.SerialNo		
			And CmrOrd.BaseDocRowNo = Cmr.DocRowNo
			And	CmrOrd.GoodsID = Cmr.GoodsID  '
	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	print ' درخواست  --> '+'رسید موقت   ' 

	--78	--=========== رسید موقت طبق درخواست	
Set @StrSelect = '
		update #cmr
		set	 TmpQty=  IsNull(CmrTmp.SubUnitQuantity,0) 
			,TmpQtyOK= IsNull(CmrTmp.ConfirmQuantity,0)
		from  #cmr Cmr
		Left Join  
			(Select T.BaseProcessID, T.BaseProcessNo, T.BaseFiscalYear, T.BaseSerialNo, T.BaseDocRowNo, T.GoodsID,
				    IsNull(Sum(T.SubUnitQuantity),0) SubUnitQuantity,
					Sum(Case When T.Recognition In (1,2,3) Then IsNull(T.ConfirmQuantity,0) Else 0 End) ConfirmQuantity
			 From inv.tblInvTempReceiptDtl T
			 Where ' + @StrWhereTmp + '
			 Group By T.BaseProcessID, T.BaseProcessNo, T.BaseFiscalYear, T.BaseSerialNo, T.BaseDocRowNo, T.GoodsID
			 ) CmrTmp
			 ON CmrTmp.BaseProcessID = Cmr.ProcessID	And
				CmrTmp.BaseProcessNo = Cmr.ProcessNo	And
				CmrTmp.BaseFiscalYear = Cmr.FiscalYear  And
				CmrTmp.BaseSerialNo = Cmr.SerialNo		And
				CmrTmp.BaseDocRowNo = Cmr.DocRowNo		And	
				CmrTmp.GoodsID = Cmr.GoodsID 
				'
	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	print ' درخواست   --> '+' سفارش  ' +'---->'+'رسید موقت   ' 


	--78	--=========== رسید موقت طبق سفارش	
Set @StrSelect = '
		update #cmr
		set	 TmpQty= TmpQty+ IsNull(CmrOrdTmp.SubUnitQuantity,0) 
			,TmpQtyOK=TmpQtyOK+ IsNull(CmrOrdTmp.ConfirmQuantity,0)
		from  #cmr Cmr
		Left Join  
		(Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				 IsNull(Sum(O2.SubUnitQuantity),0) SubUnitQuantity,
				 Sum(Case When O2.Recognition In (1,2,3) Then IsNull(O2.ConfirmQuantity,0) Else 0 End) ConfirmQuantity
			 From  cmr.tblOrderDtl O			 			   
				inner join  inv.tblInvTempReceiptDtl O2
			 ON O2.BaseProcessID = O.ProcessID	
			And O2.BaseProcessNo = O.ProcessNo	
			And O2.BaseFiscalYear = O.FiscalYear  
			And O2.BaseSerialNo = O.SerialNo		
			And O2.BaseDocRowNo = O.DocRowNo  
			And O2.GoodsID = O.GoodsID  
			 Where ' + @StrWhereOrd + '
			 Group By O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
				)CmrOrdTmp
		
			 ON CmrOrdTmp.BaseProcessID = Cmr.ProcessID		And
				CmrOrdTmp.BaseProcessNo = Cmr.ProcessNo		And
				CmrOrdTmp.BaseFiscalYear = Cmr.FiscalYear	And
				CmrOrdTmp.BaseSerialNo = Cmr.SerialNo		And
				CmrOrdTmp.BaseDocRowNo = Cmr.DocRowNo		And	
				CmrOrdTmp.GoodsID = Cmr.GoodsID 				
				'
	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	print ' درخواست   --> '+'انصراف رسید موقت   ' 


--9=========== انصراف رسید موقت طبق درخواست	
Set @StrSelect = '
		update #cmr
		set	TmpQtyCancel=IsNull(CmrOrd.ConfirmQuantity,0)
		from  #cmr Cmr
		Left Join  
		(
		Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				   IsNull(Sum(O2.ConfirmQuantity),0) ConfirmQuantity
			 From inv.tblInvTempReceiptDtl O
			 inner join inv.tblInvTempReceiptDtl O2
			 ON O2.BaseProcessID = O.ProcessID	
			And O2.BaseProcessNo = O.ProcessNo	
			And O2.BaseFiscalYear = O.FiscalYear  
			And O2.BaseSerialNo = O.SerialNo		
			And O2.BaseDocRowNo = O.DocRowNo  
			And O2.GoodsID = O.GoodsID  
			 Where ' + @StrWhereOrd + '
			 Group By O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
				)CmrOrd
			
			ON CmrOrd.BaseProcessID = Cmr.ProcessID	
			And CmrOrd.BaseProcessNo = Cmr.ProcessNo	
			And CmrOrd.BaseFiscalYear = Cmr.FiscalYear  
			And CmrOrd.BaseSerialNo = Cmr.SerialNo		
			And CmrOrd.BaseDocRowNo = Cmr.DocRowNo 
			And	CmrOrd.GoodsID = Cmr.GoodsID '
	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	print ' درخواست   --> '+' سفارش  ' +'---->'+'انصراف رسید موقت   ' 

--9=========== انصراف رسید موقت طبق سفارش	

Set @StrSelect = '
		update #cmr
		set	TmpQtyCancel=  TmpQtyCancel+IsNull(CmrOrd.ConfirmQuantity,0)
		from  #cmr Cmr
		Left Join  
		(Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				   IsNull(Sum(O3.ConfirmQuantity),0) ConfirmQuantity
			 From  cmr.tblOrderDtl O						   
				inner join  inv.tblInvTempReceiptDtl O2
			 ON O2.BaseProcessID = O.ProcessID	
			And O2.BaseProcessNo = O.ProcessNo	
			And O2.BaseFiscalYear = O.FiscalYear  
			And O2.BaseSerialNo = O.SerialNo		
			And O2.BaseDocRowNo = O.DocRowNo  
			And O2.GoodsID = O.GoodsID  
			inner join inv.tblInvTempReceiptDtl O3
			 ON O3.BaseProcessID = O2.ProcessID	
			And O3.BaseProcessNo = O2.ProcessNo	
			And O3.BaseFiscalYear = O2.FiscalYear  
			And O3.BaseSerialNo = O2.SerialNo		
			And O3.BaseDocRowNo = O2.DocRowNo  
			And O3.GoodsID = O2.GoodsID  
			
			 Where ' + @StrWhereOrd + '
			 Group By O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
				)CmrOrd
			
			ON CmrOrd.BaseProcessID = Cmr.ProcessID	
			And CmrOrd.BaseProcessNo = Cmr.ProcessNo	
			And CmrOrd.BaseFiscalYear = Cmr.FiscalYear  
			And CmrOrd.BaseSerialNo = Cmr.SerialNo		
			And CmrOrd.BaseDocRowNo = Cmr.DocRowNo 
			And	CmrOrd.GoodsID = Cmr.GoodsID '
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	print ' درخواست   --> '+' خرید  ' 


--10-11=========== خرید طبق درخواست

Set @StrSelect = '
		update #cmr
		set	BuyQty=  IsNull(CmrBuy.SubUnitQuantity,0)
		from  #cmr Cmr
		Left Join 
			(
			 Select S.BaseProcessID, S.BaseProcessNo, S.BaseFiscalYear, S.BaseSerialNo, S.BaseDocRowNo, S.GoodsID,
					IsNull(Sum(S.SubUnitQuantity),0) SubUnitQuantity--, S.DocStep
			 From inv.tblStorageDocsDtl S
			 Where ' + @StrWhereBuy + '
			 Group By S.BaseProcessID, S.BaseProcessNo, S.BaseFiscalYear, S.BaseSerialNo, S.BaseDocRowNo, S.GoodsID
			 ) CmrBuy
			 ON CmrBuy.BaseProcessID = Cmr.ProcessID	And
				CmrBuy.BaseProcessNo = Cmr.ProcessNo	And
				CmrBuy.BaseFiscalYear = Cmr.FiscalYear  And
				CmrBuy.BaseSerialNo = Cmr.SerialNo		And
				CmrBuy.BaseDocRowNo = Cmr.DocRowNo 		And				
				CmrBuy.GoodsID = Cmr.GoodsID '
			

	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	print ' درخواست   --> '+' سفارش  ' +'---->'+' خرید  ' 


--10-11=========== خرید طبق سفارش

Set @StrSelect = '
		update #cmr
		set	BuyQty=BuyQty+  IsNull(CmrOrdBuy.SubUnitQuantity,0)
		from  #cmr Cmr
		Left Join 
		(Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				 IsNull(Sum(S.SubUnitQuantity),0) SubUnitQuantity			
			 From  cmr.tblOrderDtl O					   
				inner join  inv.tblStorageDocsDtl S
			 ON S.BaseProcessID = O.ProcessID	
			And S.BaseProcessNo = O.ProcessNo	
			And S.BaseFiscalYear = O.FiscalYear  
			And S.BaseSerialNo = O.SerialNo		
			And S.BaseDocRowNo = O.DocRowNo  
			And S.GoodsID = O.GoodsID  
			 Where ' + @StrWhereBuy + '
			 Group By  O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
			 ) CmrOrdBuy
			 ON CmrOrdBuy.BaseProcessID = Cmr.ProcessID		And
				CmrOrdBuy.BaseProcessNo = Cmr.ProcessNo		And
				CmrOrdBuy.BaseFiscalYear = Cmr.FiscalYear	And
				CmrOrdBuy.BaseSerialNo = Cmr.SerialNo		And
				CmrOrdBuy.BaseDocRowNo = Cmr.DocRowNo 		And	
				CmrOrdBuy.GoodsID = Cmr.GoodsID '
			

	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	print ' درخواست   --> '+' رسید موقت  ' +'---->'+' خرید  ' 


--10-11=========== خرید طبق رسید موقت

Set @StrSelect = '
		update #cmr
		set	BuyQty=BuyQty+  IsNull(CmrOrdBuy.SubUnitQuantity,0)
		from  #cmr Cmr
		Left Join 
		(Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				 IsNull(Sum(S.SubUnitQuantity),0) SubUnitQuantity				
			 From   inv.tblInvTempReceiptDtl  O				   
				inner join  inv.tblStorageDocsDtl S
			 ON S.BaseProcessID = O.ProcessID	
			And S.BaseProcessNo = O.ProcessNo	
			And S.BaseFiscalYear = O.FiscalYear  
			And S.BaseSerialNo = O.SerialNo		
			And S.BaseDocRowNo = O.DocRowNo  
			And S.GoodsID = O.GoodsID  
			 Where ' + @StrWhereBuy + '
			 Group By  O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
			 ) CmrOrdBuy
			 ON CmrOrdBuy.BaseProcessID = Cmr.ProcessID		And
				CmrOrdBuy.BaseProcessNo = Cmr.ProcessNo		And
				CmrOrdBuy.BaseFiscalYear = Cmr.FiscalYear	And
				CmrOrdBuy.BaseSerialNo = Cmr.SerialNo		And
				CmrOrdBuy.BaseDocRowNo = Cmr.DocRowNo		And	
				CmrOrdBuy.GoodsID = Cmr.GoodsID 
				 '
			

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	print ' درخواست   --> '+' سفارش ' +'---->'+' رسید موقت  ' +'---->'+' خرید  ' 

--10-11=========== خرید طبق سفارش تبدیل شده به رسید موقت

Set @StrSelect = '
		update #cmr
		set	BuyQty=BuyQty+  IsNull(CmrOrdBuy.SubUnitQuantity,0)
		from  #cmr Cmr
		Left Join 
		(Select O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID,
				 IsNull(Sum(S.SubUnitQuantity),0) SubUnitQuantity				
			 From   cmr.tblOrderDtl O				   		  
					inner join   inv.tblInvTempReceiptDtl T			
			 ON T.BaseProcessID = O.ProcessID	
			And T.BaseProcessNo = O.ProcessNo	
			And T.BaseFiscalYear = O.FiscalYear  
			And T.BaseSerialNo = O.SerialNo		
			And T.BaseDocRowNo = O.DocRowNo 
			And T.GoodsID = O.GoodsID 
			inner join  inv.tblStorageDocsDtl S
			 ON S.BaseProcessID = T.ProcessID	
			And S.BaseProcessNo = T.ProcessNo	
			And S.BaseFiscalYear = T.FiscalYear  
			And S.BaseSerialNo = T.SerialNo		
			And S.BaseDocRowNo = T.DocRowNo  
			And S.GoodsID = T.GoodsID  
			 Where ' + @StrWhereBuy + '
			 Group By  O.BaseProcessID, O.BaseProcessNo, O.BaseFiscalYear, O.BaseSerialNo, O.BaseDocRowNo, O.GoodsID
			 ) CmrOrdBuy
			 ON CmrOrdBuy.BaseProcessID = Cmr.ProcessID		And
				CmrOrdBuy.BaseProcessNo = Cmr.ProcessNo		And
				CmrOrdBuy.BaseFiscalYear = Cmr.FiscalYear	And
				CmrOrdBuy.BaseSerialNo = Cmr.SerialNo		And
				CmrOrdBuy.BaseDocRowNo = Cmr.DocRowNo		And	
				CmrOrdBuy.GoodsID = Cmr.GoodsID '
			

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
--------------------------------------------------------------------------


 select *,[pub].[funGetGoodsName](GoodsID,@LangID) GoodsName,
		IsNull([inv].[FunGetGoodsBarCode] (GoodsID), '''') BarCode, 
		--------------------------------------------------------------------------------
		IsNull(CmrQty,0) SubUnitQuantity, IsNull(CmrQtyOK,0) - IsNull(CmrQtyCancel,0) ConfirmQuantity, 
		IsNull(CmrQtyCancel,0) ConfirmQuantityCancel, 
		IsNull(OrdQty,0) CmrOrdQuantity, IsNull(OrdQtyOK,0) CmrOrdConfirmQuantity,
		IsNull(OrdQtyCancel,0) CmrOrdConfirmQuantityCancel	, 
		IsNull(TmpQty,0)  CmrOrdTmpQuantity, 
		IsNull(TmpQtyOK,0) CmrOrdTmpConfirmQuantity, 
		IsNull(TmpQtyCancel,0) CmrOrdTmpConfirmQuantityCancel, 
		IsNull(BuyQty,0)  CmrBuyQuantity,
		((Select Count(*) 
		From inv.tblStorageDocsDtl S
		Inner Join cmr.tblCMRDtl C ON S.BaseProcessID = C.ProcessID And S.BaseProcessNo = C.ProcessNo And 
										S.BaseFiscalYear = C.FiscalYear And S.BaseSerialNo = C.SerialNo And 
										S.BaseDocRowNo = C.DocRowNo And S.GoodsID = C.GoodsID
														 
		Where C.ProcessNo = cc.ProcessNo And C.FiscalYear = cc.FiscalYear And C.SerialNo = cc.SerialNo And C.GoodsID = cc.GoodsID And C.DocRowNo = cc.DocRowNo And 
				(S.DocStep = 0 OR S.DocStep >= 1)) +
		--===
		(Select Count(*) 
		From cmr.tblCMRDtl C
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And 
											T.BaseFiscalYear = C.FiscalYear And T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo And T.GoodsID = C.GoodsID
														 
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = T.ProcessID And S.BaseProcessNo = T.ProcessNo And 
											S.BaseFiscalYear = T.FiscalYear And S.BaseSerialNo = T.SerialNo And S.BaseDocRowNo = T.DocRowNo And S.GoodsID = T.GoodsID
													  									 
		Where T.BaseProcessNo = cc.ProcessNo And T.BaseFiscalYear = cc.FiscalYear And T.BaseSerialNo = cc.SerialNo And T.GoodsID = cc.GoodsID And T.BaseDocRowNo = cc.DocRowNo And
				(S.DocStep = 0 OR S.DocStep >= 1)) +
		--===
		(Select Count(*) 
		From cmr.tblOrderDtl O
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = O.ProcessID And T.BaseProcessNo = O.ProcessNo And 
												T.BaseFiscalYear = O.FiscalYear And T.BaseSerialNo = O.SerialNo And T.BaseDocRowNo = O.DocRowNo And T.GoodsID = O.GoodsID
														 
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = T.ProcessID And S.BaseProcessNo = T.ProcessNo And 
											S.BaseFiscalYear = T.FiscalYear And S.BaseSerialNo = T.SerialNo And S.BaseDocRowNo = T.DocRowNo And S.GoodsID = T.GoodsID
													  
		Where O.BaseProcessNo = cc.ProcessNo And O.BaseFiscalYear = cc.FiscalYear And O.BaseSerialNo = cc.SerialNo And O.GoodsID = cc.GoodsID And O.BaseDocRowNo = cc.DocRowNo And
				(S.DocStep = 0 OR S.DocStep >= 1)) +
		--===
		(Select Count(*) 
		From cmr.tblCMRDtl C
		Inner Join cmr.tblOrderDtl O ON O.BaseProcessID = C.ProcessID And O.BaseProcessNo = C.ProcessNo And 
										O.BaseFiscalYear = C.FiscalYear And O.BaseSerialNo = C.SerialNo And O.BaseDocRowNo = C.DocRowNo And O.GoodsID = C.GoodsID
												
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = O.ProcessID And S.BaseProcessNo = O.ProcessNo And 	
											S.BaseFiscalYear = O.FiscalYear And S.BaseSerialNo = O.SerialNo And S.BaseDocRowNo = O.DocRowNo And S.GoodsID = O.GoodsID
													  
		Where C.ProcessNo = cc.ProcessNo And C.FiscalYear = cc.FiscalYear And C.SerialNo = cc.SerialNo And C.GoodsID = cc.GoodsID And C.DocRowNo = cc.DocRowNo And 
				(S.DocStep = 0 OR S.DocStep >= 1))) NumericBuyCount,
		((Select Count(*) 
		From inv.tblStorageDocsDtl S
		Inner Join cmr.tblCMRDtl C ON S.BaseProcessID = C.ProcessID And S.BaseProcessNo = C.ProcessNo And 
										S.BaseFiscalYear = C.FiscalYear And S.BaseSerialNo = C.SerialNo And 
										S.BaseDocRowNo = C.DocRowNo And S.GoodsID = C.GoodsID
														 
		Where C.ProcessNo = cc.ProcessNo And C.FiscalYear = cc.FiscalYear And C.SerialNo = cc.SerialNo And C.GoodsID = cc.GoodsID And C.DocRowNo = cc.DocRowNo And 
				(S.DocStep = 0 OR S.DocStep >= 1)) +
		--===
		(Select Count(*) 
		From cmr.tblCMRDtl C
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And 
												T.BaseFiscalYear = C.FiscalYear And T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo And T.GoodsID = C.GoodsID
														 
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = T.ProcessID And S.BaseProcessNo = T.ProcessNo And 
												 S.BaseFiscalYear = T.FiscalYear And S.BaseSerialNo = T.SerialNo And S.BaseDocRowNo = T.DocRowNo And S.GoodsID = T.GoodsID
													  									 
		Where T.BaseProcessNo = cc.ProcessNo And T.BaseFiscalYear = cc.FiscalYear And T.BaseSerialNo = cc.SerialNo And T.GoodsID = cc.GoodsID And T.BaseDocRowNo = cc.DocRowNo And 
				(S.DocStep = 0 OR S.DocStep >= 1)) +
		--===
		(Select Count(*) 
		From cmr.tblOrderDtl O
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = O.ProcessID And T.BaseProcessNo = O.ProcessNo And 
													T.BaseFiscalYear = O.FiscalYear And T.BaseSerialNo = O.SerialNo And T.BaseDocRowNo = O.DocRowNo And T.GoodsID = O.GoodsID
														 
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = T.ProcessID And S.BaseProcessNo = T.ProcessNo And 
												S.BaseFiscalYear = T.FiscalYear And S.BaseSerialNo = T.SerialNo And S.BaseDocRowNo = T.DocRowNo	And S.GoodsID = T.GoodsID								 								 
													  
		Where O.BaseProcessNo = cc.ProcessNo And O.BaseFiscalYear = cc.FiscalYear And O.BaseSerialNo = cc.SerialNo And O.GoodsID = cc.GoodsID And O.BaseDocRowNo = cc.DocRowNo And 
				(S.DocStep = 0 OR S.DocStep >= 1)) +
		--===
		(Select Count(*) 
		From cmr.tblCMRDtl C
		Inner Join cmr.tblOrderDtl O ON O.BaseProcessID = C.ProcessID And O.BaseProcessNo = C.ProcessNo And 
										O.BaseFiscalYear = C.FiscalYear And O.BaseSerialNo = C.SerialNo And O.BaseDocRowNo = C.DocRowNo And O.GoodsID = C.GoodsID
												
		Inner Join inv.tblStorageDocsDtl S ON S.BaseProcessID = O.ProcessID And S.BaseProcessNo = O.ProcessNo And 
												S.BaseFiscalYear = O.FiscalYear And S.BaseSerialNo = O.SerialNo And S.BaseDocRowNo = O.DocRowNo And S.GoodsID = O.GoodsID 
													  
		Where C.ProcessNo = cc.ProcessNo And C.FiscalYear = cc.FiscalYear And C.SerialNo = cc.SerialNo And C.GoodsID = cc.GoodsID And C.DocRowNo = cc.DocRowNo And 
				(S.DocStep = 0 OR S.DocStep >= 1))) CurrencyBuyCount
		,(select isnull(max (DocDate),'') from inv.tblStorageDocsDtl S
			where S.BaseProcessID=cc.ProcessID and S.BaseProcessNo =cc.ProcessNo 
				and S.BaseFiscalYear=cc.FiscalYear and S.BaseSerialNo=cc.SerialNo ) MaxDocDateBuy
		, isNull( cast( (Select Sum(GoodsQuantity *EnterKind) from inv.tblStorageDocsDtl s where s.GoodsID=cc.GoodsID )as float ),0) GoodsRemain
			,isnull((Select top 1 DocDate
		From cmr.tblOrderDtl O where  O.BaseProcessID = cc.ProcessID And O.BaseProcessNo = cc.ProcessNo And 
										O.BaseFiscalYear = cc.FiscalYear And O.BaseSerialNo = cc.SerialNo And O.BaseDocRowNo = cc.DocRowNo And O.GoodsID = cc.GoodsID
		order by DocDate Desc), '') OrderDocDate
			,isnull((Select top 1 DocDate
		From inv.tblInvTempReceiptDtl O where  O.BaseProcessID = cc.ProcessID And O.BaseProcessNo = cc.ProcessNo And 
										O.BaseFiscalYear = cc.FiscalYear And O.BaseSerialNo = cc.SerialNo And O.BaseDocRowNo = cc.DocRowNo And O.GoodsID = cc.GoodsID
		order by DocDate Desc), '')TempReceiptDocDate
		,isnull((Select top 1 DocDate
		From inv.tblStorageDocsDtl O where  O.BaseProcessID = cc.ProcessID And O.BaseProcessNo = cc.ProcessNo And 
										O.BaseFiscalYear = cc.FiscalYear And O.BaseSerialNo = cc.SerialNo And O.BaseDocRowNo = cc.DocRowNo And O.GoodsID = cc.GoodsID
		order by DocDate Desc), '') BuyDocDate

  from #cmr cc
  order by FiscalYear, SerialNo,DocRowNo
	----------------------------------------
End
GO
