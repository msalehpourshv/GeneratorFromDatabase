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
Create PROCEDURE [cmr].[RptOrder_Situation]
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
Declare @StrSort		NVarChar(Max) = '';


Declare @StrWhereOrd	NVarChar(Max);
Declare @StrWhereBuy	NVarChar(Max);
Declare @StrWhereTmp	NVarChar(Max);
Declare @StrWhereOrdTmp	NVarChar(Max);

Declare @StrGoodsID				VarChar(100);
Declare @StrGoodsName			VarChar(100);
Declare @StrQuantity			VarChar(100);
Declare @StrGoodsUnit			VarChar(100);
Declare @StrOrderDuration		VarChar(100);
Declare @SenderDepartmentID		VarChar(20);
Declare @ExpectedDeliveryDateFrom	Char(10);
Declare @ExpectedDeliveryDateTo		Char(10);
Declare @SettlementDateFrom			Char(10);
Declare @SettlementDateTo			Char(10);	
DECLARE	@LangID						Char(1);
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
DECLARE @SortByFilter		TinyInt;


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
	
	SET @ReqConfirmed				= pub.funSplitString(@ExtraParams, '@', 1);
	SET @ReqNotConfirmed			= pub.funSplitString(@ExtraParams, '@', 2);
	SET @OrdConfirmed				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @OrdNotConfirmed			= pub.funSplitString(@ExtraParams, '@', 4);	
	SET @TmpConfirmed				= pub.funSplitString(@ExtraParams, '@', 5);	
	SET @TmpNotConfirmed			= pub.funSplitString(@ExtraParams, '@', 6);	
	SET @NumericBuy					= pub.funSplitString(@ExtraParams, '@', 7);	
	SET @CurrencyBuy				= pub.funSplitString(@ExtraParams, '@', 8);
	SET @SenderDepartmentID			= pub.funSplitString(@ExtraParams, '@', 9);
	SET @ExpectedDeliveryDateFrom	= pub.funSplitString(@ExtraParams, '@', 11);
	SET @ExpectedDeliveryDateTo		= pub.funSplitString(@ExtraParams, '@', 12);		
	SET @SettlementDateFrom			= pub.funSplitString(@ExtraParams, '@', 13);
	SET @SettlementDateTo			= pub.funSplitString(@ExtraParams, '@', 14);
	SET @SortByFilter				= pub.funSplitString(@ExtraParams, '@', 15);	
	
	
	IF @SortByFilter = 1
		Set @StrSort = 'Order BY SerialNo'
	else IF @SortByFilter = 2
		Set @StrSort = 'Order BY DocDate'
	else IF @SortByFilter = 3
		Set @StrSort = 'Order BY ExpectedDeliveryDate'
	else IF @SortByFilter = 4
		Set @StrSort = 'Order BY SettlementDate'
	else
		Set @StrSort = ' '

	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhere = 'O.ProcessID = ' + LTrim(Str(@ProcessID)) + ' AND O.ProcessNo = ' + LTrim(Str(@ProcessNo))
	
	Set @StrWhereOrd	= '1 = 1'	
	Set @StrWhereTmp	= '1 = 1'	
	Set @StrWhereOrdTmp = '1 = 1'	
	Set @StrWhereBuy	= '1 = 1'	
	Set @StrWhereAll	= '1 = 1'	
	Set @StrWhere2		= 'O1.ProcessID = 160'
	


	If (@SerialNoFr Is Not Null)
	Begin
		Set @StrWhere = @StrWhere + ' AND (O.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(O.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND O.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	End
	
	If (@SerialNoTo Is Not Null)
	Begin
		Set @StrWhere = @StrWhere + ' AND (O.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(O.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND O.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	End

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
		Begin
			SET @StrWhere = @StrWhere + ' AND (O.DocDate = ''' + @DocDateFr + ''')'
		End
		
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
			Begin
				SET @StrWhere = @StrWhere + ' AND (O.DocDate >= ''' + @DocDateFr + ''')'
			End
			IF @DocDateTo Is Not Null
			Begin
				SET @StrWhere = @StrWhere + ' AND (O.DocDate <= ''' + @DocDateTo + ''')'
			End
		End
		
	If (@SelectedGoods > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'O.GoodsID') 
	End
		
	If (@SelectedAcnt1 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'O.AcntCode')
	End
	If (@SelectedAcnt2 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'O.AcntCode')
	End
	If (@SelectedAcnt3 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'O.AcntCode')
	End
	If (@SelectedAcnt4 > 0)
	Begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'O.AcntCode')
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
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SenderDepartmentID, 'ORDERH.SenderDepartmentID')	

	IF @ExpectedDeliveryDateFrom Is Not Null and @ExpectedDeliveryDateFrom<>''
		SET @StrWhere = @StrWhere + ' AND (O.ExpectedDeliveryDate >= ''' + @ExpectedDeliveryDateFrom + ''')'
    IF @ExpectedDeliveryDateTo Is Not Null  and @ExpectedDeliveryDateTo<>''
		SET @StrWhere = @StrWhere + ' AND (O.ExpectedDeliveryDate <= ''' + @ExpectedDeliveryDateTo + ''')'


	IF @SettlementDateFrom Is Not Null  and @SettlementDateFrom<>''
		SET @StrWhere = @StrWhere + ' AND (ORDERH.SettlementDate >= ''' + @SettlementDateFrom + ''')'
    IF @SettlementDateTo Is Not Null  and @SettlementDateTo<>''
		SET @StrWhere = @StrWhere + ' AND (ORDERH.SettlementDate <= ''' + @SettlementDateTo + ''')'

	--============= Confirm Check
	If (@ReqConfirmed = 1 And @ReqNotConfirmed = 0)
		SET @StrWhere = @StrWhere + ' AND (IsNull(O.DocStep,0) > 1)'
	If (@ReqConfirmed = 0 And @ReqNotConfirmed = 1)
		SET @StrWhere = @StrWhere + ' AND (IsNull(O.DocStep,0) <= 1)'		

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
	End
	If (@NumericBuy = 0 And @CurrencyBuy = 1)
	Begin
		SET @StrWhereBuy = @StrWhereBuy + ' AND (IsNull(S.DocStep,0) > 1)'		
		SET @StrWhereAll = @StrWhereAll + ' AND (A.NumericBuyCount > 0 And A.CurrencyBuyCount > 0)'
	End

--select @StrWhere
--select @StrWhereTmp
--select @StrWhereOrdTmp
--select @StrWhereAll
--select @StrWhereOrd
--select @StrWhereBuy
	---------------------------------------------------------------------------
	---- S E L E C T ----------------------------------------------------------
	Set @StrSelect1 = '	SELECT * 
FROM (
	select distinct O.ProcessID, O.ProcessNo, O.FiscalYear, O.SerialNo,O.DocRowNo, O.GoodsID,O.ExpectedDeliveryDate
		, [pub].[funGetGoodsName](O.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName,O.GoodsPrice
		, IsNull([inv].[FunGetGoodsBarCode] (O.GoodsID), '''') BarCode, O.DocStep 
		, IsNull(O.SubUnitQuantity,0) CmrOrdQuantity  
		, IsNull(O.ConfirmQuantity,0) - IsNull(O2.ConfirmQuantity,0) CmrOrdConfirmQuantity
		, IsNull(O2.ConfirmQuantity,0) CmrOrdQuantityCancel
		, IsNull(T.ConfirmQuantity,0) CmrOrdTmpQuantity
		, IsNull(T2.ConfirmQuantity,0) CmrOrdTmpConfirmQuantity
		, IsNull(T3.ConfirmQuantity,0) CmrOrdTmpQuantityCancel
		, IsNull(B.ConfirmQuantity,0) + IsNull(B2.ConfirmQuantity,0) CmrBuyQuantity
		, [cmr].[funGetOrdrBuyOprations] (O.GoodsID, O.ProcessNo, O.FiscalYear, O.SerialNo, O.DocRowNo, 1) As NumericBuyCount
		, [cmr].[funGetOrdrBuyOprations] (O.GoodsID, O.ProcessNo, O.FiscalYear, O.SerialNo, O.DocRowNo, 2) As CurrencyBuyCount
		, ISNULL(DEP.DepartmentName,'''') DepartmentName,O.DocDate,O.OrderDate,ISNULL(U.UnitName,'''') UnitName
		, ORDERH.AcntCode,pub.GetCodeName(ORDERH.AcntCode,' + LTrim(RTrim(@LangID)) + ' )AcntCodeName, ORDERH.DocDesc,ORDERH.BuyTypeID, BTD.BuyTypeName
		, inv.funGetLastBuyGoodsPrice(O.GoodsID ,O.StoreID ,O.DocDate ,	0 ,' + LTrim(RTrim(@LangID)) + ') LastBuyGoodsPrice,ORDERH.SettlementDate
			 ----سفارش
	from  cmr.tblOrderDtl O
	inner join cmr.tblOrderHdr ORDERH 
		ON ORDERH.ProcessID = O.ProcessID   
		And ORDERH.ProcessNo =O.ProcessNo   
		And ORDERH.FiscalYear = O.FiscalYear 
		And ORDERH.SerialNo = O.SerialNo
	LEFT JOIN  inv.tblBuyTypeDtl BTD on BTD.BuyTypeID=ORDERH.BuyTypeID  AND BTD.LanguageID=' + LTrim(RTrim(@LangID)) + '
	LEFT JOIN  prs.tblDepartmentsDtl DEP On ORDERH.SenderDepartmentID=DEP.DepartmentID AND DEP.LanguageID=' + LTrim(RTrim(@LangID)) + '
	LEFT Join  inv.tblUnitsDtl U On U.UnitID=O.SubUnitID AND U.LanguageID=' + LTrim(RTrim(@LangID)) + '
		 -------برگشت سفارش
	Left Join  ( select Sum(ConfirmQuantity) ConfirmQuantity ,BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo 
		 			From  cmr.tblOrderDtl 
		 			Where ProcessID=165 and BaseProcessID>0 	 	
		 			Group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo )O2 
		ON O2.BaseProcessID = O.ProcessID
		And O2.BaseProcessNo = O.ProcessNo
		And O2.BaseFiscalYear = O.FiscalYear 
		And O2.BaseSerialNo = O.SerialNo
		And O2.BaseDocRowNo = O.DocRowNo
					   '
--Print @StrSelect1;
Set @StrSelect2 = '---- رسید موقت
			Left Join  ( select Sum(SubUnitQuantity) ConfirmQuantity, BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo 
			From  inv.tblInvTempReceiptDtl T
		 	Where ProcessID=170 and BaseProcessID>0 
		 	and  ' + @StrWhereOrdTmp + '
		 	Group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo )T
			ON T.BaseProcessID = O.ProcessID   And 
			   T.BaseProcessNo = O.ProcessNo   And 
			   T.BaseFiscalYear = O.FiscalYear And 
			   T.BaseSerialNo = O.SerialNo     And 
			   T.BaseDocRowNo = O.DocRowNo 
			   ----  رسید موقت تایید شده		 
			Left Join  ( select Sum(ConfirmQuantity) ConfirmQuantity, BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo 
			From  inv.tblInvTempReceiptDtl T
		 	Where ProcessID=170 and BaseProcessID>0 and Recognition in(1,2,3)
		 	 and ' + @StrWhereOrdTmp + '
		 	Group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo)T2
			ON T2.BaseProcessID = O.ProcessID   And 
			   T2.BaseProcessNo = O.ProcessNo   And 
			   T2.BaseFiscalYear = O.FiscalYear And 
			   T2.BaseSerialNo = O.SerialNo     And 
			   T2.BaseDocRowNo = O.DocRowNo 			   
			  ----  رسید موقت برگشت شده			   
		Left Join  ( 	   select Sum(T3.ConfirmQuantity) ConfirmQuantity, T.BaseProcessID,T.BaseProcessNo,T.BaseFiscalYear,T.BaseSerialNo,T.BaseDocRowNo 
						From  inv.tblInvTempReceiptDtl T3
						inner join  inv.tblInvTempReceiptDtl T
						on  T3.ProcessID=175 and T.ProcessID=170 
						and T3.BaseProcessID = T.ProcessID   
						And T3.BaseProcessNo = T.ProcessNo   
						And T3.BaseFiscalYear = T.FiscalYear 
						And T3.BaseSerialNo = T.SerialNo     
						And T3.BaseDocRowNo = T.DocRowNo 
						where  ' + @StrWhereOrdTmp + '
		 	Group by T.BaseProcessID,T.BaseProcessNo,T.BaseFiscalYear,T.BaseSerialNo,T.BaseDocRowNo
						)T3
						ON T3.BaseProcessID = O.ProcessID   And 
			   T3.BaseProcessNo = O.ProcessNo   And 
			   T3.BaseFiscalYear = O.FiscalYear And 
			   T3.BaseSerialNo = O.SerialNo     And 
			   T3.BaseDocRowNo = O.DocRowNo 
						   '
--Print @StrSelect2;
Set @StrSelect3 = '
			   -----خرید از سفارش 
			Left Join  ( select cast(Sum(SubUnitQuantity) as float )ConfirmQuantity, BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo 
			From  inv.tblStorageDocsDtl S
		 	Where  BaseProcessID>0 
		 	and  ' + @StrWhereBuy + '
		 	Group by BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo )B
			ON B.BaseProcessID = O.ProcessID   And 
			   B.BaseProcessNo = O.ProcessNo   And 
			   B.BaseFiscalYear = O.FiscalYear And 
			   B.BaseSerialNo = O.SerialNo     And 
			   B.BaseDocRowNo = O.DocRowNo 
			   ---- خرید از طریق رسید موقت 			   
		Left Join  (select Sum(S.SubUnitQuantity) ConfirmQuantity, T2.BaseProcessID,T2.BaseProcessNo,T2.BaseFiscalYear,T2.BaseSerialNo,T2.BaseDocRowNo 
						From inv.tblStorageDocsDtl  S
						inner join  inv.tblInvTempReceiptDtl T2
						on T2.ProcessID=170 and  S.ProcessID=55 
						and S.BaseProcessID = T2.ProcessID   
						And S.BaseProcessNo = T2.ProcessNo   
						And S.BaseFiscalYear = T2.FiscalYear 
						And S.BaseSerialNo = T2.SerialNo     
						And S.BaseDocRowNo = T2.DocRowNo 
						where  ' + @StrWhereBuy + ' 
		 	Group by T2.BaseProcessID,T2.BaseProcessNo,T2.BaseFiscalYear,T2.BaseSerialNo,T2.BaseDocRowNo
						)B2
						ON B2.BaseProcessID = O.ProcessID   And 
			   B2.BaseProcessNo = O.ProcessNo   And 
			   B2.BaseFiscalYear = O.FiscalYear And 
			   B2.BaseSerialNo = O.SerialNo     And 
			   B2.BaseDocRowNo = O.DocRowNo 
					   '
Set @StrSelect4 = '
INNER JOIN inv.tblGoodsDtl GD ON GD.GoodsID = SUBSTRING(O.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	Where ' + @StrWhere + ' and  ' + @StrWhereOrd + '
	) A Where ' + @StrWhereAll	+'  '+ @StrSort
	
	
	Print @StrSelect1;
	Print @StrSelect2;
	Print @StrSelect3;
	Print @StrSelect4;
	Set @StrSelect = @StrSelect1 + @StrSelect2 + @StrSelect3 + @StrSelect4
	---------------------------------------------------------------------------

	---- R U N ----------------------------------------------------------------
	--Print @StrSelect;
	Exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
