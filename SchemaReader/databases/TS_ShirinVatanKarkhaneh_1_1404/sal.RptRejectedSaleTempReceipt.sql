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
-- Description   : گزارش وضعیت رسید موقت برگشت از فروش
-- =============================================

Create PROCEDURE [sal].[RptRejectedSaleTempReceipt]
	@ProcessID				Int = 150, 
	@ProcessNo				Int = 1,
	@FiscalYearFr			Int = Null,
	@SerialNoFr				Int = Null,
	@FiscalYearTo			Int = Null,
	@SerialNoTo				Int = Null,
	@DocDateFr				Char(10) = Null,
	@DocDateTo				Char(10) = Null,
	@SelectedGoods			Int = 0, 	
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
Declare @StrWhereTempReceipt		NVarChar(Max);


Declare @StrWhereRejectedSale	NVarChar(200);


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

	
	
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	SET @ReqConfirmed     = pub.funSplitString(@ExtraParams, '@', 1);
	SET @ReqNotConfirmed  = pub.funSplitString(@ExtraParams, '@', 2);
	
	
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	Set @StrWhereTempReceipt = 'InvTemp.ProcessID = ' + LTrim(Str(@ProcessID)) + ' AND InvTemp.ProcessNo = ' + LTrim(Str(@ProcessNo))
	

	Set @StrWhereRejectedSale = '1 = 1'	
	


	If (@SerialNoFr Is Not Null)
	Begin
		Set @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND (InvTemp.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR 
		(InvTemp.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND InvTemp.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	End
	
	If (@SerialNoTo Is Not Null)
	Begin
		Set @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND (InvTemp.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR 
		(InvTemp.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND InvTemp.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	End

	IF (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		IF (@DocDateFr = @DocDateTo)
		Begin
			SET @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND (InvTemp.DocDate = ''' + @DocDateFr + ''')'
		End
		
		Else
		Begin
			IF (@DocDateFr Is Not Null) 
			Begin
				SET @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND (InvTemp.DocDate >= ''' + @DocDateFr + ''')'
			End
			IF @DocDateTo Is Not Null
			Begin
				SET @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND (InvTemp.DocDate <= ''' + @DocDateTo + ''')'
			End
		End
		
	If (@SelectedGoods > 0)
	Begin
		SET @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'InvTemp.GoodsID') 
	End
		

			
    If (@PriorityCode>0)
	    SET @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND  (InvTemp.PriorityCode = ' + @PriorityCode  + ')'
	--============= Confirm Check
	
	If (@ReqConfirmed = 1 And @ReqNotConfirmed = 0)
		SET @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND (IsNull(InvTemp.DocStep,0) > 1)'
	If (@ReqConfirmed = 0 And @ReqNotConfirmed = 1)
		SET @StrWhereTempReceipt = @StrWhereTempReceipt + ' AND (IsNull(InvTemp.DocStep,0) <= 1)'		

	

select InvTemp.ProcessID, InvTemp.ProcessNo, InvTemp.FiscalYear, InvTemp.SerialNo,DocRowNo ,GoodsID ,InvTemp.DocStep		

		,SubUnitQuantity TmpReceiptQty
		,SubUnitQuantity TmpConfirmedReceiptQty	
		,SubUnitQuantity TmpConfirmedReceiptQty1
		,SubUnitQuantity TmpConfirmedReceiptQty2	
		,SubUnitQuantity RejectedSaleQty
		,DescDtl DocDesc		
		,InvTemp.DocDate	
		,UnitName		
	into #invTemp
		 From inv.tblInvTempReceiptDtl  InvTemp
		 inner join inv.tblUnitsDtl U 
					ON U.UnitID=InvTemp.SubUnitID	
	 --    inner join inv.tblStorageDocsHdr StoH 
		--           ON StoH.ProcessID = InvTemp.ProcessID   
		--	       And StoH.ProcessNo =InvTemp.ProcessNo   
		--	       And StoH.FiscalYear = InvTemp.FiscalYear 
		--	       And StoH.SerialNo = InvTemp.SerialNo
		--LEFT JOIN  prs.tblDepartmentsDtl DEP
		--            On StoH.SenderDepartmentID=DEP.DepartmentID
		 
					where 1=0
		
--171===========   رسید موقت برگشت از فروش 
		print ' رسید موقت برگشت از فروش'
Set @StrSelect = '
		insert into  #invTemp
		select  InvTemp.ProcessID, InvTemp.ProcessNo, InvTemp.FiscalYear, InvTemp.SerialNo,DocRowNo ,GoodsID,InvTemp.DocStep
		,SubUnitQuantity,ConfirmQuantity,ConfirmQuantity1,ConfirmQuantity2 ,0		
		,DescDtl,InvTemp.DocDate,UnitName 
		From inv.tblInvTempReceiptDtl  InvTemp
		inner join inv.tblUnitsDtl U 
		ON U.UnitID=InvTemp.SubUnitID	   
		Where ' + @StrWhereTempReceipt 
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
		


	--100	--===========برگشت از فروش	
Set @StrSelect = '
		update #invTemp
		set	 RejectedSaleQty=  IsNull(StoTmp.SubUnitQuantity,0)			   		
		from  #invTemp InvTemp
		Left Join  
			(Select S.SourceProcessID, S.SourceProcessNo, S.SourceFiscalYear, S.SourceSerialNo, S.SourceDocRowNo, S.GoodsID,
				    IsNull(Sum(S.SubUnitQuantity),0) SubUnitQuantity					
			 From inv.tblStorageDocsDtl S
			 Group By S.SourceProcessID, S.SourceProcessNo, S.SourceFiscalYear, S.SourceSerialNo, S.SourceDocRowNo, S.GoodsID
			 ) StoTmp
			 ON StoTmp.SourceProcessID = InvTemp.ProcessID	And
				StoTmp.SourceProcessNo = InvTemp.ProcessNo	And
				StoTmp.SourceFiscalYear = InvTemp.FiscalYear  And
				StoTmp.SourceSerialNo = InvTemp.SerialNo	And
				StoTmp.SourceDocRowNo = InvTemp.DocRowNo	And	
				StoTmp.GoodsID = InvTemp.GoodsID 
				'
	Print @StrSelect;
	Exec sp_executesql @StrSelect;


	print ' برگشت از فروش   ' 


--------------------------------------------------------------------------


 select *,[pub].[funGetGoodsName](GoodsID,@LangID) GoodsName,
		IsNull([inv].[FunGetGoodsBarCode] (GoodsID), '''') BarCode
		
	
  from #invTemp cc
  order by FiscalYear, SerialNo,DocRowNo
	----------------------------------------
End
GO
