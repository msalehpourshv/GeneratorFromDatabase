USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 1402/01/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE sal.SPSaleSendTaxToll
@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
AS
begin

	DECLARE @StrSelect1				NVarChar(max)
	DECLARE @StrSelect2				NVarChar(max)
	DECLARE @StrWhere				NVarChar(max)
	DECLARE @ErrCountType			bit
	DECLARE @RetNoBase				bit
	DECLARE @RetWithBase			bit
	DECLARE @PayType				int
	DECLARE @VchNoNotImportent		char(1)

	SET @VchNoNotImportent	= '0'
	SET @ErrCountType		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @StrWhere			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @RetNoBase			= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @RetWithBase		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @PayType			= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @VchNoNotImportent	= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
	
	Set @StrWhere +=' and (D.ProcessID = 90   ' 
	if @RetNoBase ='True'
		Set @StrWhere +='  or (D.ProcessID = 100 and BaseProcessID=0 )   ' 
	if @RetWithBase ='True'
		Set @StrWhere +='  or (D.ProcessID = 100 and BaseProcessID<>0 )   ' 
	Set @StrWhere +='  )   ' 

	if @PayType=1
		Set @StrWhere +='  And PayType in (0,1)' 
	if @PayType=2
		Set @StrWhere +='  And PayType =2' 		

	DECLARE @StrFields2	NVarChar(Max);
	DECLARE @Eqal		NVarChar(2000);
	declare @CountPartRemain tinyint
	SET @CountPartRemain=0;
	DECLARE @Remain1	Bit;
	DECLARE @Remain2	Bit;
	DECLARE @Remain3	Bit;
	DECLARE @Remain4	Bit;
	DECLARE @Part1Start	Int;
	DECLARE @Part2Start	Int;
	DECLARE @Part3Start	Int;
	DECLARE @Part4Start	Int;
	DECLARE @Part1Len	Int;
	DECLARE @Part2Len	Int;
	DECLARE @Part3Len	Int;
	DECLARE @Part4Len	Int;
 
	select @Part1Start=acc.funGetAcntLayerStartandLen(1,1)
	select @Part1Len=acc.funGetAcntLayerStartandLen(1,2)
	select @Part2Start=acc.funGetAcntLayerStartandLen(2,1)
	select @Part2Len=acc.funGetAcntLayerStartandLen(2,2)
	select @Part3Start=acc.funGetAcntLayerStartandLen(3,1)
	select @Part3Len=acc.funGetAcntLayerStartandLen(3,2)
	select @Part4Start=acc.funGetAcntLayerStartandLen(4,1)
	select @Part4Len=acc.funGetAcntLayerStartandLen(4,2)

	select a.* into #T 
	from (
		select AcntCode,IsNull(Sum(Debit-Credit),0) DC from acc.tblVoucherDtl M
		INNER JOIN acc.tblVoucherHdr VH ON VH.SerialNo=M.SerialNo
		where  VH.DocRegisterState>0   AND M.VchKind<>0 
		group by AcntCode
		) a
	inner join acc.tblAcnt b
	on b.PartNumber=1 and SUBSTRING(a.AcntCode,1,@Part1Len)=b.AcntCode 
	where b.AcntType NOT IN (91,92)

	SELECT  @Remain1 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain1'
	SELECT  @Remain2 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain2'
	SELECT  @Remain3 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain3'
	SELECT  @Remain4 = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SalIvcRemain4'

	SET @Eqal = '1=1'

	IF (@Remain1 = 1)
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain2 = 1) AND @CountPartRemain = 1
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain3 = 1) AND @CountPartRemain = 2
		SET @CountPartRemain = @CountPartRemain + 1
	IF (@Remain4 = 1) AND @CountPartRemain = 3
		SET @CountPartRemain = @CountPartRemain + 1

	IF (select COUNT(*) from pub.tblCodeLayer where TableName='acc.tblAcnt' and Layer1>0) = @CountPartRemain
		BEGIN
				SET @Eqal = @Eqal + ' AND M.AcntCode=D.AcntCode'
		END
		ELSE
		BEGIN
			IF (@Remain1 = 1) AND (@Remain2 = 1)
			BEGIN
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(D.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part2Len)) + ')'

			END
			ELSE
			BEGIN
				IF (@Remain1 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')=Substring(D.AcntCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
				IF (@Remain2 = 1)
					SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')=Substring(D.AcntCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
			END
			IF (@Remain3 = 1)
				SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')=Substring(D.AcntCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
			IF (@Remain4 = 1)
				SET @Eqal = @Eqal + ' AND Substring(M.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')=Substring(D.AcntCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
		END	

	update inv.tblStorageDocsHdr set NoSentSale2TTMS=1	where SendTaxTollState=3  and ProcessID in (90,100) and  NoSentSale2TTMS=0	

	SET @StrFields2 = '
			(SELECT	IsNull(Sum(DC),0) Debit 
			 FROM	#T M
			 WHERE  (' + @Eqal + ') )   '

	set @StrSelect1 = ' SELECT  D.SerialNo,TaxID,BaseTaxID,BaseSerialNo,ReferenceID,VchDate DocDate
	,TPCanceled  ,TPEdited ,SendTaxTollState,
		case when SendTaxTollState=3 and TPCanceled=0  and TPEdited = 0 then  '' ویرایش'' 
		when SendTaxTollState <> 2 and SendTaxTollState <> 3 and TPCanceled=0 and TPEdited = 1 then  '' ویرایش'' else '''' end  BtnEditedDate,TPEditedDate, SendTaxToll,NoSentSale2TTMS ,EnterKind*Amount Amount ,EnterKind*Price Price , 
		EnterKind*(TotalLineDiscount+Discount+Discount2+Discount3 ) + case when DiscountTaxOverWorth =1 then EnterKind*TaxOverWorthCost +EnterKind*TollOverWorthCost  else 0 end   Discount,EnterKind*TaxOverWorthCost +EnterKind*TollOverWorthCost TaxOverWorthCost 
		, case when  PersonType=1 then ''حقیقی''
			when  PersonType=2 then ''حقوقی''
			when  PersonType=3 then ''مشارکت مدنی''
			when  PersonType=4 then ''اتباع غیر ایرانی''
			when  PersonType=5 then ''مصرف کننده نهایی''
			else  ''نامعلوم''
		end PersonTypeName
		, Case when PayType =0 then ''تعیین نشده'' when PayType =1 then ''نقد'' when PayType=2 then  ''نسیه''   when PayType=3 then  ''نقد/نسیه''end PayType 
		, Case when PayType=0 then 0 when PayType =1 then Amount when PayType=2 then 0 when PayType=3 then Amount-PayTypeCashAmount end PayTypeCashAmount1
		, Case when PayType in (0,1) then 0 when PayType=2 then Amount when PayType=3 then PayTypeCashAmount end PayTypeCashAmount2	
		,'+@StrFields2 +' DebitRemain , ''        '' DebitRemainType, 
		CASE WHEN D.EconomicalCode<>'''' THEN  D.EconomicalCode ELSE A.EconomicalCode END AS EconomicalCode, isNull(D.SourceSerialNo, 0) SourceSerialNo
		, Case when D.ProcessID=90 then 
			CASE 
			WHEN TPInp = 0 THEN ''بدون الگو''  
			WHEN TPInp = 1 THEN ''الگوی فروش''  
			WHEN TPInp = 2 THEN ''فروش ارزی''  
			WHEN TPInp = 4 THEN ''پیمان کاری''  
			WHEN TPInp = 7 THEN ''فروش صادراتی''  
			WHEN TPInp = 8 THEN ''بارنامه''  
			else  ''بدون الگو'' end 
		else 
			CASE 
			WHEN TPInp = 0 THEN ''بدون الگو''  
			WHEN TPInp = 1 THEN ''الگوی برگشت از فروش''  
			WHEN TPInp = 2 THEN ''برگشت از فروش ارزی''  
			WHEN TPInp = 4 THEN ''برگشت از پیمان کاری''  
			WHEN TPInp = 7 THEN ''برگشت از فروش صادراتی''
			WHEN TPInp = 8 THEN ''برگشت از فروش بارنامه''  
			else  ''بدون الگو'' end 
		end 
		InvoiceTemplate	
		,Case when SendTaxTollState=0 then Case when TPEdited=1 then ''اصلاحی و عدم ارسال'' else ''عدم ارسال ''  end
			when SendTaxTollState=1 then ''ارسال نشده '' 
			when SendTaxTollState=2 then ''در حال ارسال'' 
			when SendTaxTollState=3 then ''ارسال شده'' 
			when SendTaxTollState=4 then ''خطای شبکه'' 
			when SendTaxTollState=5 then ''خطای مقادیر فاکتور'' 
		else ''خطای نامعلوم'' 
		end SendTaxTollStateName ,D.AcntCode,pub.GetCodeName(D.AcntCode,1) AS AcntCodeName
		,D.ProcessID, 	D.ProcessNo,P.ProcessName,	D.FiscalYear,DocDesc,KotagNo,CurrencyTypeID ,PersonType ,A.LocationID , pub.funGetLocationName(A.LocationID,1) LocationName ,A.AcntName
		,A.CustomerFirstName +'+''' '''+'+ A.CustomerLastName CustomerName ,A.OrganzationName ,
		A.Tel ,A.Address1 ,A.Address2, isnull(TPCanceledDate,'''') TPCanceledDate
		,case when SendTaxTollState=3 then 0 else   ( select  Count(*) from pub.tblTPErrors E '
	if @ErrCountType='False'
		set @StrSelect1 += 'inner join  (select  max(SendDateTime) SendDateTime, ProcessID,	ProcessNo,	FiscalYear,	SerialNo
											from pub.tblTPErrors 
												group by ProcessID,	ProcessNo,	FiscalYear,	SerialNo
										) F on E.ProcessID=F.ProcessID  and E.ProcessNo=F.ProcessNo  and E.FiscalYear=F.FiscalYear  and E.SerialNo=F.SerialNo  and E.SendDateTime=F.SendDateTime 
											'
	set @StrSelect1 +=' 
			where E.ProcessID=D.ProcessID  and E.ProcessNo=D.ProcessNo  and E.FiscalYear=D.FiscalYear  and E.SerialNo=D.SerialNo ) End ErrorCount, CASE WHEN D.ZipCode<>'''' THEN  D.ZipCode ELSE A.ZipCode END AS ZipCode,
			CASE WHEN D.NationalIDNumber<>'''' THEN  D.NationalIDNumber ELSE A.NationalIDNumber END AS NationalIDNumber, A.NationalIdentity
			'
	set @StrSelect2 = '	from inv.tblStorageDocsHdr D 
		inner join (Select ProcessID,ProcessNo,FiscalYear,SerialNo,Case When ProcessID=90 then 1 else -1 end EnterKind from inv.tblStorageDocsHdr )DD
			on DD.ProcessID=D.ProcessID  and DD.ProcessNo=D.ProcessNo  and DD.FiscalYear=D.FiscalYear  and DD.SerialNo=D.SerialNo 
		LEFT JOIN pub.tblProcess P ON P.ProcessID=D.ProcessID AND P.ProcessNo=D.ProcessNo
		OUTER APPLY acc.funGetCodeInfo(D.AcntCode) AS A 
		where  (VchNo>0 or TPCanceled=1 OR D.ProcessNo=11 OR ' + @VchNoNotImportent + '=1 ) '+@StrWhere	+' order by DocDate , SerialNo '
	
	Print @StrSelect1	 
	Print @StrSelect2
	set @StrSelect1=@StrSelect1+@StrSelect2	 
	 
	EXEC sp_executesql @StrSelect1;

end 
GO
