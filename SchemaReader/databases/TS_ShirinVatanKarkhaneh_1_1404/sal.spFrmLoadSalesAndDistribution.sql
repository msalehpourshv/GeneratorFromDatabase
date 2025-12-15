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
Create PROCEDURE [sal].[spFrmLoadSalesAndDistribution]
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@DocDateFr		Char(10),
	@DocDateTo		Char(10),
	@AcntCodeFr		Varchar(20),
	@AcntCodeTo		Varchar(20),
	@StoreID		Varchar(20),
	@LanguageID		Tinyint,
	@FiscalYear		Smallint,
	@SerialNo		Int	,
	@ExtraParams	NVarChar(Max) = ''
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	Declare @StrSelect1			NVarChar(Max);
	Declare @StrSelect2  		NVarChar(Max);
	Declare @StrWhere   		NVarChar(Max);
	Declare @StrWhere2   		NVarChar(Max);
	Declare @StartLayerIndex	TINYINT;
	Declare @AcntPartNumber	TINYINT;
	Declare @LayerLen	TINYINT;

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
	SELECT @StartLayerIndex = SettingValue	FROM pub.tblSettings	WHERE SettingKey = 'StartLayerIndex'	
	select @AcntPartNumber = SettingValue From pub.tblSettings Where SettingKey='AcntPartNumberForRemainCalculation'
	select @LayerLen = SettingValue From pub.tblSettings Where SettingKey='LayerLen'
		
	IF (@StartLayerIndex Is Null)		SET @StartLayerIndex = Null;
	IF (@LayerLen Is Null)		SET @LayerLen = 1;
	IF (@AcntPartNumber Is Null)		SET @AcntPartNumber = 1;
	
	-- ==========
	IF (@FiscalYear Is Null)		SET @SerialNo = Null;
	IF (@SerialNo	Is Null)		SET @FiscalYear = Null;
	
	IF (@ProcessID = 90) OR (@ProcessID = 210)
		SET @ProcessNo = 10
						
	-- ========== Where
	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID)))
	SET @StrWhere2 = 'D.ProcessID = ' + LTrim(RTrim(Str(@ProcessID)))
	
	IF (@ProcessNo Is Not Null) And (@ProcessNo <> 0)
	Begin
		SET @StrWhere = @StrWhere + ' And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
		SET @StrWhere2 = @StrWhere2 + ' And H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	End
	
	IF (@FiscalYear Is Not Null) And (@FiscalYear <> 0)
	Begin
		Set @StrWhere = @StrWhere + ' AND (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ')' 
	End
		
	IF (@SerialNo Is Not Null) And (@SerialNo <> 0)
	Begin
		Set @StrWhere = @StrWhere + ' AND (H.SerialNo = ' + LTrim(Str(@SerialNo)) + ')' 
		Set @StrWhere2 = @StrWhere2 + ' AND (D.SerialNo = ' + LTrim(Str(@SerialNo)) + ')' 
	End
	
	--SET @StrWhere2 = @StrWhere2 + ' AND D.BaseSaleSerialNo Not In (Select BaseSaleSerialNo From trs.tblSettlementDtl) ' 

	IF (@AcntCodeFr Is Not Null) And (Len(Ltrim(@AcntCodeFr)) <> 0)
		Set @StrWhere = @StrWhere + ' AND SUBSTRING(H.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeFr))) + ')>=LEFT(''' + LTrim(RTrim(@AcntCodeFr)) + ''',' + LTRIM(STR(LEN(@AcntCodeFr))) + ')  '

	IF (@AcntCodeTo Is Not Null) AND (Len(LTrim(@AcntCodeTo)) <> 0)
		Set @StrWhere =  @StrWhere + ' AND SUBSTRING(H.AcntCode,' + LTRIM(STR(@StartLayerIndex)) + ',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')<=LEFT(''' + LTrim(RTrim(@AcntCodeTo)) + ''',' + LTRIM(STR(LEN(@AcntCodeTo))) + ')  '

	IF (@DocDateFr Is Not Null) And (Len(Ltrim(@DocDateFr)) <> 0)
		Set @StrWhere = @StrWhere + ' AND LEFT(H.DocDate,' + LTRIM(STR(LEN(@DocDateFr))) + ')>=''' + LTrim(RTrim(@DocDateFr)) + '''  '

	IF (@DocDateTo Is Not Null) AND (Len(LTrim(@DocDateTo)) <> 0)
		Set @StrWhere =  @StrWhere + ' AND LEFT(H.DocDate,' + LTRIM(STR(LEN(@DocDateTo))) + ')<=''' + LTrim(RTrim(@DocDateTo)) + '''  '
		
	IF @StoreID Is Not Null And @StoreID <> ''
		Set @StrWhere =  @StrWhere + ' AND H.StoreID = ''' + LTRIM(STR(LEN(@StoreID))) + ''''
	if not(@ExtraParams Is  Null) and @ExtraParams<>''
	  	begin
			SET @StrWhere = 	 @StrWhere  + ' ' + @ExtraParams +'' 
			SET @StrWhere2 = 	 @StrWhere2  + ' ' + @ExtraParams +'' 
		end 
			
	--=======================================
Declare @StrWharePey NVarChar(Max)
Set @StrWharePey = '  ,inv.funGetRemainInvoice(H.ProcessID ,H.ProcessNo ,H.FiscalYear,H.SerialNo )as TotalPriceRemain'
    
	IF @ProcessID = 90 -- ����
	BEGIN
		SET @StrSelect1 = '
			SELECT H.*, IsNull(H.Amount,0) SaleAmount, IsNull(H.TotalLineDiscount,0) + IsNull(H.Discount,0) + IsNull(H.Discount2,0)+ IsNull(H.Discount3,0) SaleDiscount
					, 0 RetAmount, pub.GetCodeName(H.AcntCode,' + LTrim(RTrim(@LanguageID)) + ') AS AcntName
					,[acc].[funAccountRemain](H.AcntCode,''' + LTrim(RTrim(@DocDateTo)) + ''') as AcntRemain
				    ,(SELECT  MaxDebitRemain FROM acc.tblAcnt WHERE PartNumber='+str(@AcntPartNumber)+' and AcntCode=SUBSTRING(H.AcntCode,'+str(@StartLayerIndex)+','+str(@LayerLen)+')) MaxDebitRemain
				     '+ @StrWharePey+'	
				    , case when H.AfterSaleVchNo<>0   then  Case   when H.AfterSaleDate=''' + LTrim(RTrim(@DocDateTo)) + ''' then H.AfterSaleDiscount else -1 end else 0 end AfterDiscount			   
				    ,isnull(( select top 1 SessionNo5 from sal.tblDistributionsDtl D 
								Inner Join sal.tblDistributionsHdr DH ON DH.ProcessID = D.ProcessID And DH.SerialNo = D.SerialNo and H.ProcessID = D.BaseSaleProcessID And H.SerialNo = D.BaseSaleSerialNo    ),0)DstSessionNo5
					,DH.DriverID ,isnull(d.FirstName+'' ''+d.LastName , '''') DriverName
					,DH.DistributerID1	,isnull(p1.FirstName +'' ''+p1.LastName , '''') DistributerName1
					,DH.DistributerID2,isnull(p2.FirstName +'' ''+p2.LastName , '''') DistributerName2
			FROM inv.tblStorageDocsHdr H
			left join  sal.tblDistributionsHdr DH on DH.ProcessID=H.BaseDistributionProcessID and DH.SerialNo =H.BaseDistributionSerialNo
			left join prs.tblPersonnelsDtl p1 on p1.PersonnelID=DH.DistributerID1
			left join prs.tblPersonnelsDtl p2 on p2.PersonnelID=DH.DistributerID2
			left join pub.tblDriversDtl d on d.DriverID=DH.DriverID
				Where ' + @StrWhere
	END
	ELSE IF @ProcessID = 210 -- ���
	BEGIN
		SET @StrSelect1 = '
			SELECT Distinct H.*, IsNull(H.Amount,0) SaleAmount, 
				   IsNull(H.TotalLineDiscount,0) + IsNull(H.Discount,0) + IsNull(H.Discount2,0) + IsNull(H.Discount3,0) SaleDiscount, 
				   0 RetAmount, pub.GetCodeName(H.AcntCode,' + LTrim(RTrim(@LanguageID)) + ') AS AcntName,
				   [acc].[funAccountRemain](H.AcntCode,''' + LTrim(RTrim(@DocDateTo)) + ''') as AcntRemain,
				   (SELECT  ISNULL(SUM(Amount), 0) AS SUMAmount FROM  trs.tblPayDtl b inner join    trs.tblPayHdr a on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and a.SerialNo=b.SerialNo and  a.FiscalYear=b.FiscalYear WHERE   (PayTypeID =1) and a.BaseProcessID=H.ProcessID and  a.BaseProcessNo=H.ProcessNo and a.BaseSerialNo=H.SerialNo and  a.BaseFiscalYear=H.FiscalYear ) CashPrice,
				   (SELECT  ISNULL(SUM(Amount), 0) AS SUMAmount FROM  trs.tblPayDtl b inner join    trs.tblPayHdr a on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and a.SerialNo=b.SerialNo and  a.FiscalYear=b.FiscalYear WHERE   (PayTypeID =35) and a.BaseProcessID=H.ProcessID and  a.BaseProcessNo=H.ProcessNo and a.BaseSerialNo=H.SerialNo and  a.BaseFiscalYear=H.FiscalYear ) DraftPrice,
				   (SELECT  ISNULL(SUM(Amount), 0) AS SUMAmount FROM  trs.tblPayDtl b inner join    trs.tblPayHdr a on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and a.SerialNo=b.SerialNo and  a.FiscalYear=b.FiscalYear WHERE   (PayTypeID =6) and a.BaseProcessID=H.ProcessID and  a.BaseProcessNo=H.ProcessNo and a.BaseSerialNo=H.SerialNo and  a.BaseFiscalYear=H.FiscalYear ) ChequePrice,
				   (SELECT  MaxDebitRemain FROM acc.tblAcnt WHERE PartNumber='+str(@AcntPartNumber)+' and AcntCode=SUBSTRING(H.AcntCode,'+str(@StartLayerIndex)+','+str(@LayerLen)+')) MaxDebitRemain
				' + @StrWharePey + '
				, case when H.AfterSaleVchNo<>0  then  Case   when H.AfterSaleDate=''' + LTrim(RTrim(@DocDateTo)) + ''' then H.AfterSaleDiscount else -1 end else 0 end AfterDiscount			   
				, DH.SessionNo5  DstSessionNo5
				,DH.DriverID ,isnull(d.FirstName+'' ''+d.LastName , '''') DriverName
				,DH.DistributerID1	,isnull(p1.FirstName +'' ''+p1.LastName , '''') DistributerName1
				, DH.DistributerID2,isnull(p2.FirstName +'' ''+p2.LastName , '''') DistributerName2
			FROM inv.tblStorageDocsHdr H		
			Inner Join sal.tblDistributionsDtl D ON H.ProcessID = D.BaseSaleProcessID And H.SerialNo = D.BaseSaleSerialNo    
			Inner Join sal.tblDistributionsHdr DH ON DH.ProcessID = D.ProcessID And DH.SerialNo = D.SerialNo   
			left join prs.tblPersonnelsDtl p1 on p1.PersonnelID=DH.DistributerID1
			left join prs.tblPersonnelsDtl p2 on p2.PersonnelID=DH.DistributerID2
			left join pub.tblDriversDtl d on d.DriverID=DH.DriverID 
 			Where ' + @StrWhere2
	END	
	
	-- ===========================				
	Print @StrSelect1
	Exec sp_executesql @StrSelect1;	

END
GO
