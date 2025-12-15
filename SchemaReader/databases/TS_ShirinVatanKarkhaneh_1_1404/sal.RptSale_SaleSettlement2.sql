USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/22
-- Viewed By	 : 
-- Last Modified : 1393/08/04 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[RptSale_SaleSettlement2]
	@FiscalFr		Int 	 	  = Null,
	@SerialFr		Int 	 	  = Null,
	@FiscalTo		Int 	 	  = Null,
	@SerialTo		Int 	 	  = Null,
	@DocDateFr		Char(10) 	  = Null,
	@DocDateTo		Char(10) 	  = Null,
	@SelectedAcnt1	Int = 0,
	@SelectedAcnt2	Int = 0,
	@SelectedAcnt3	Int = 0,
	@SelectedAcnt4	Int = 0,
	@StoreID		Varchar(20)	  = Null,
	@RepOptions		VarChar(20)	  = '111', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(200) = ''
	
WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @StrSelect1			NVarChar(Max);
	DECLARE @StrSelect2  		NVarChar(Max);
	DECLARE @StrWhere   		NVarChar(Max);
	DECLARE @StrWhere2   		NVarChar(Max);
	DECLARE @StartLayerIndex	TINYINT;

	DECLARE @LangID		Char(1);
	DECLARE @SessionNo	VarChar(10);
	DECLARE @ReportID	VarChar(10);

	DECLARE @SaleFiscalFr		Int; 	 	  
	DECLARE @SaleSerialFr		Int; 	 	  
	DECLARE @SaleFiscalTo		Int; 	 	  
	DECLARE @SaleSerialTo		Int; 	 	  

	DECLARE @chkIsOfficial		int;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1';

	IF (@FiscalFr	Is Null)	SET @SerialFr = 0;
	IF (@FiscalTo	Is Null)	SET @SerialTo = 0;
	IF (@SerialFr	Is Null)	SET @FiscalFr = 0;
	IF (@SerialTo	Is Null)	SET @FiscalTo = 0;

	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	--SET @IsDetailed	= Substring(@RepOptions, 1, 1);
	SET @SaleFiscalFr	= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @SaleSerialFr	= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @SaleFiscalTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @SaleSerialTo	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	set @chkIsOfficial  = LTrim(pub.funSplitString(@ExtraParams, '@', 5));
	
	IF (@SaleFiscalFr	Is Null)	SET @SaleFiscalFr = 0;
	IF (@SaleSerialFr	Is Null)	SET @SaleSerialFr = 0;
	IF (@SaleFiscalTo	Is Null)	SET @SaleFiscalTo = 0;
	IF (@SaleSerialTo	Is Null)	SET @SaleSerialTo = 0;
	If (@chkIsOfficial  Is Null)	SET @chkIsOfficial = 0;

	-- ==========
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

	-- ==========
	SELECT @StartLayerIndex = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'StartLayerIndex'	

	-- ========== Where
	SET @StrWhere = '1 = 1'
	
	If (@FiscalFr Is Not Null) And (@FiscalFr <> 0)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear=' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo>=' + LTrim(Str(@SerialFr)) + ')'
	If (@FiscalTo Is Not Null) And (@FiscalTo <> 0)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear=' + LTrim(Str(@FiscalTo)) + '  AND H.SerialNo<=' + LTrim(Str(@SerialTo)) + ')'

	If (@SaleFiscalFr <> 0)
		SET @StrWhere = @StrWhere + ' AND D.BaseSaleFiscalYear=' + LTrim(Str(@SaleFiscalFr))
	If  (@SaleFiscalTo <> 0)
		SET @StrWhere = @StrWhere + ' AND D.BaseSaleFiscalYear=' + LTrim(Str(@SaleFiscalTo))

if (@SaleSerialFr <> 0)
		SET @StrWhere = @StrWhere + ' AND D.BaseSaleSerialNo>=' + LTrim(Str(@SaleSerialFr)) 
	If  (@SaleSerialTo <> 0)
		SET @StrWhere = @StrWhere + ' AND  D.BaseSaleSerialNo<=' + LTrim(Str(@SaleSerialTo)) 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.CustomerAcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.CustomerAcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.CustomerAcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.CustomerAcntCode')

	IF (@DocDateFr Is Not Null) And (Len(Ltrim(@DocDateFr)) <> 0)
		Set @StrWhere = @StrWhere + ' AND LEFT(H.DocDate,' + LTRIM(STR(LEN(@DocDateFr))) + ')>=''' + LTrim(RTrim(@DocDateFr)) + '''  '

	IF (@DocDateTo Is Not Null) AND (Len(LTrim(@DocDateTo)) <> 0)
		Set @StrWhere =  @StrWhere + ' AND LEFT(H.DocDate,' + LTRIM(STR(LEN(@DocDateTo))) + ')<=''' + LTrim(RTrim(@DocDateTo)) + '''  '
		
	IF @StoreID Is Not Null And @StoreID <> ''
		Set @StrWhere =  @StrWhere + ' AND H.StoreID = ''' + LTRIM(STR(LEN(@StoreID))) + ''''

	If @chkIsOfficial = 2
		Set @StrWhere = @StrWhere + ' AND (H1.IsOfficial = 0)'	
	If @chkIsOfficial = 1
		Set @StrWhere = @StrWhere + ' AND (H1.IsOfficial = 1)'		
	If @chkIsOfficial = 0
		Set @StrWhere = @StrWhere + ''
		
		
	Update trs.tblSettlementDtl
Set CashPrice= isnull(Amount,0) From trs.tblSettlementDtl D 
	left Join  (Select SUM(Amount)Amount,ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID From trs.tblPayDtl 
	Where PayTypeID =1
	Group by ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID) P On D.BasePayProcessID=P.ProcessID And 	
	D.BasePayProcessNo=P.ProcessNo And 	
	D.BasePayFiscalYear=P.FiscalYear And 	
	D.BasePaySerialNo=P.SerialNo	

	   
	Update trs.tblSettlementDtl
Set ChequePrice= isnull(Amount,0) From trs.tblSettlementDtl D 
	left Join  (Select SUM(Amount)Amount,ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID From trs.tblPayDtl 
	Where PayTypeID =6
	Group by ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID) P On D.BasePayProcessID=P.ProcessID And 	
	D.BasePayProcessNo=P.ProcessNo And 	
	D.BasePayFiscalYear=P.FiscalYear And 	
	D.BasePaySerialNo=P.SerialNo	
	
	
	Update trs.tblSettlementDtl
Set DraftPrice= isnull(Amount,0) From trs.tblSettlementDtl D 
	left Join  (Select SUM(Amount)Amount,ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID From trs.tblPayDtl 
	Where PayTypeID =35
	Group by ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID) P On D.BasePayProcessID=P.ProcessID And 	
	D.BasePayProcessNo=P.ProcessNo And 	
	D.BasePayFiscalYear=P.FiscalYear And 	
	D.BasePaySerialNo=P.SerialNo	

	
	Update trs.tblSettlementDtl
Set DepositPrice= isnull(Amount,0) From trs.tblSettlementDtl D 
	left Join  (Select SUM(Amount)Amount,ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID From trs.tblPayDtl 
	Where PayTypeID =3
	Group by ProcessID ,ProcessNo,FiscalYear ,SerialNo ,PayTypeID) P On D.BasePayProcessID=P.ProcessID And 	
	D.BasePayProcessNo=P.ProcessNo And 	
	D.BasePayFiscalYear=P.FiscalYear And 	
	D.BasePaySerialNo=P.SerialNo	

	
	
				
	--=======================================
	SET @StrSelect1 = '
	Select H.DocDate, H.CollectorID, H.CashID, H.BankID, H.RecID, H.SessionNo, H.CashID2, H.Confirmed, D.*,
		   LTRIM(RTrim(Str(H1.BaseDistributionFiscalYear))) + ''/'' + LTRIM(RTrim(Str(H1.BaseDistributionSerialNo))) DistributionNo,
		   pub.GetCodeName(D.CustomerAcntCode,' + LTrim(RTrim(@LangID)) + ') AS CustomerAcntName,
		   [acc].[funAccountRemain](D.CustomerAcntCode,H.DocDate) as CustomerAcntRemain,
		   (select AfterSaleDiscount 
		    from inv.tblStorageDocsHdr H 
		    where H.ProcessID=D.BaseSaleProcessID and H.ProcessNo=D.BaseSaleProcessNo and 
				  H.FiscalYear=D.BaseSaleFiscalYear and H.SerialNo=D.BaseSaleSerialNo) Discount,
		   H1.SaleAmount, H1.RetAmount
	From trs.tblSettlementHdr H
	Inner Join trs.tblSettlementDtl D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
										 H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
	Inner Join 
	(
		Select H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.Amount SaleAmount, 
			   H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo, IsNull(Sum(R.Price),0) RetAmount,H.IsOfficial
		From inv.tblStorageDocsHdr H
		Left Join inv.tblStorageDocsHdr R ON H.ProcessID = R.BaseProcessID And H.ProcessNo = R.BaseProcessNo And
											 H.FiscalYear = R.BaseFiscalYear And H.SerialNo = R.BaseSerialNo
		Where H.ProcessID = 90 And H.ProcessNo = 10	
		Group By H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.Amount,
				 H.BaseDistributionFiscalYear, H.BaseDistributionSerialNo,H.IsOfficial
	) H1 ON H1.ProcessID = D.BaseSaleProcessID And H1.ProcessNo = D.BaseSaleProcessNo And
			H1.FiscalYear = D.BaseSaleFiscalYear And H1.SerialNo = D.BaseSaleSerialNo									 
	Where ' + @StrWhere
	
	-- ===========================				
	Print @StrSelect1
	Exec sp_executesql @StrSelect1;	

END
GO
