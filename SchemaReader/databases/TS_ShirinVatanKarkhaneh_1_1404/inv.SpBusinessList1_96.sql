USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/01/16
-- Viewed By	 : 
-- Last Modified : 1392/04/05
-- Description	 : 
-- ==============================================
Create PROCEDURE [inv].[SpBusinessList1_96]
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	

WITH ENCRYPTION
AS
declare	@RetPID int
declare	@DateFr char(10)
declare	@DateTo char(10)
declare @MaxSmallDealAmount as bigint
--declare @TaxOverWorthBeforOverLoadInBuy as bit
Declare @ProcessID	int, -- 55 or 90
		@GoodsName	nvarchar(50), 
		@TTMSCode	nvarchar(50),
		@DocYear	char(4), -- 4 digit
		@DocSeason	int, -- 1 .. 4
		@TaxOnly	bit,
		@CRCOnly	bit,
		@DateStep   bit,
		@WithAgreeNo bit ,
		@ProductWithBuy bit ,
		@GoodsBaseCalc as tinyint,
		@processType as int,
		@ZeroForEmptyAgreeNo as bit,
		@SendSumFormat  as bit,
		@DiscountType  as bit,
		@StrWhereH		NVarChar(Max),
		@StrWhereIN		NVarChar(Max),
		@LangID			Char(1),
		@SessionNo		Int, 
		@ReportID		Int,
		@UserID			Int,		
		@HasVAT			bit,
		@UserIsAdmin	bit
Declare @StrSelect			NVarChar(max);		
 Begin
 
 	SET @ProcessID			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
 	SET @GoodsName			    = LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
 	SET @TTMSCode			    = LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
 	SET @DocYear			    = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @DocSeason			    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	SET @TaxOnly		        = LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	SET @CRCOnly			    = LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
	SET @DateStep		        = LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
	SET @WithAgreeNo		    = LTrim(pub.funSplitString(@ExtraParams, '@', 9));
	SET @GoodsBaseCalc			= LTrim(pub.funSplitString(@ExtraParams, '@', 10)); 
	SET @processType			= LTrim(pub.funSplitString(@ExtraParams, '@', 11)); 
	SET @ZeroForEmptyAgreeNo  	= LTrim(pub.funSplitString(@ExtraParams, '@', 12));
	SET @SendSumFormat  	    = LTrim(pub.funSplitString(@ExtraParams, '@', 13)); 
	SET @DiscountType   	    = LTrim(pub.funSplitString(@ExtraParams, '@', 14)); 
	SET @StrWhereIN   			= LTrim(pub.funSplitString(@ExtraParams, '@', 15)); 
	SET @ProductWithBuy 		= LTrim(pub.funSplitString(@ExtraParams, '@', 16)); 
	SET @HasVAT 				= LTrim(pub.funSplitString(@ExtraParams, '@', 17)); 
	
	SET @LangID				 = pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo			 = pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID			 = pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID				 = pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin		 = pub.funSplitString(@RepInfo, '@', 5);

	if @processType=2
		SET @DiscountType = 1

	SET @MaxSmallDealAmount = 0
	SET @MaxSmallDealAmount = (select SettingValue  from pub.tblSettings where SettingKey='MaxSmallDealAmount')
	DECLARE @PrdWageForOnePoduct AS BIT

	SET @PrdWageForOnePoduct = 'False'
	
	SELECT @PrdWageForOnePoduct = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PrdWageForOnePoduct'

	if @ProcessID = 55 set @RetPID = 60
	if @ProcessID = 90 set @RetPID = 100
	if @ProcessID = 49 set @RetPID = 47

	if (@DocSeason = 1)
	begin
		set @DateFr = '01/01'
		set @DateTo = '03/31'
	end

	if (@DocSeason = 2)
	begin
		set @DateFr = '04/01'
		set @DateTo = '06/31'
	end

	if (@DocSeason = 3)
	begin
		set @DateFr = '07/01'
		set @DateTo = '09/31'
	end

	if (@DocSeason = 4)
	begin
		set @DateFr = '10/01'
		set @DateTo = '12/31'
	end
		
SET @DateFr = @DocYear + '/'  + @DateFr
SET @DateTo = @DocYear + '/'  + @DateTo

-------#SHdr-----------------------------------------------------------------
update inv.tblStorageDocsHdr set NoSentSale2TTMS=1	where SendTaxTollState=3  and ProcessID in (90,100) and  NoSentSale2TTMS=0	

Select ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,VchDate,AcntCode,Discount,Discount2+Discount3 Discount2,TaxOverWorthCost,TollOverWorthCost,Discount+Discount2+Discount3+ CASE WHEN DiscountTaxOverWorth=1 THEN TaxOverWorthCost+TollOverWorthCost else 0 end SumDiscountHdr
		,DiscountTaxOverWorth,CurrencyTypeID,CurrencyRate,Cast(Case When (ProcessID = @RetPID) Then 1 Else 0 End As Bit) IsReturn,AgreeNo,
		KotagNo Kotaj_No,KotagDate Kotaj_Date,[AssessmentLocation] Gomrok_Arzyabi,[ExitLocation] Gomrok_khoruj,PriceParvane,ForoushType,TTMSPayOffTypeID,VchNo
 INTO #SHdr
FROM inv.tblStorageDocsHdr
where (ProcessID=@ProcessID or ProcessID=@RetPID OR (@ProductWithBuy = '1' and @ProcessID = 55 and ProcessID=80 ) ) 
and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End >= @DateFr 
and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End <=@DateTo
AND ((@TaxOnly = 0) OR (@TaxOnly = 1 AND TaxOverWorthCost + TaxOverWorthCost > 0)) And NoSentTTMS=0  And (NoSentSale2TTMS=0 or NoSentSale2TTMS=2)
---and SerialNo=1
   
----------#SDtl--------------------------------------------------------------

select H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,D.DocRowNo,D.DiscountDtl,D.TaxOverWorthCostDtl,D.TollOverWorthCostDtl,
       D.GoodsID,(D.GoodsQuantity*CASE WHEN D.ProcessID=80 then 
                               D.Wage/CASE WHEN D.WageRate = 50 OR D.FormulaProductCount=0 OR @PrdWageForOnePoduct = 'True' OR D.FormulaNo=0 THEN 1 ELSE D.FormulaProductCount END 
						  else D.GoodsPrice end-D.DiscountDtl+D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl+
						  ISNULL((SELECT ROUND(SUM(AtomAmount* GoodsQuantity),3) 
							    FROM inv.tblStorageDocsAtom A 
							    WHERE A.ProcessID=D.ProcessID AND A.ProcessNo=D.ProcessNo AND 
									  A.FiscalYear=D.FiscalYear AND A.SerialNo=D.SerialNo AND
								      A.DocRowNo=D.DocRowNo AND (HasVAT='True' or @HasVAT='True')),0)
						  ) SumPriceDtlWithTax,
			  (D.GoodsQuantity*CASE WHEN D.ProcessID=80 then 
                               D.Wage/CASE WHEN D.WageRate = 50 OR D.FormulaProductCount=0 OR @PrdWageForOnePoduct = 'True' OR D.FormulaNo=0 THEN 1 ELSE D.FormulaProductCount END 
						  else D.GoodsPrice end+
						  ISNULL((SELECT ROUND(SUM(AtomAmount* GoodsQuantity),3) 
							    FROM inv.tblStorageDocsAtom A 
							    WHERE A.ProcessID=D.ProcessID AND A.ProcessNo=D.ProcessNo AND 
									  A.FiscalYear=D.FiscalYear AND A.SerialNo=D.SerialNo AND
								      A.DocRowNo=D.DocRowNo AND (HasVAT='True' or @HasVAT='True')),0)) SumPriceDtl,CurrencyAmount,D.PriceParvane
	  INTO  #SDtl					   
FROM inv.tblStorageDocsDtl D
INNER JOIN inv.tblStorageDocsHdr H
ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
where (D.ProcessID=@ProcessID or D.ProcessID=@RetPID OR (@ProductWithBuy = '1' and @ProcessID = 55 and D.ProcessID=80 ) ) 
and Case When @DateStep = 0 Then D.DocDate Else Case When VchDate <> '' Then VchDate Else  D.DocDate End End >= @DateFr 
and Case When @DateStep = 0 Then D.DocDate Else Case When VchDate <> '' Then VchDate Else  D.DocDate End End <=@DateTo
AND ((@CRCOnly = 0) Or ( @CRCOnly = 1 and D.GoodsAmount > 0)) And NoSentTTMS=0   And (NoSentSale2TTMS=0 or NoSentSale2TTMS=2)
-------#SGroupDtl-----------------------------------------------------------------

SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,
   SUM(D.GoodsQuantity*CASE WHEN D.ProcessID=80 then 
                               D.Wage/CASE WHEN D.WageRate = 50 OR D.FormulaProductCount=0 OR @PrdWageForOnePoduct = 'True' OR D.FormulaNo=0 THEN 1 ELSE D.FormulaProductCount END 
						  else D.GoodsPrice end -D.DiscountDtl+D.TaxOverWorthCostDtl+D.TollOverWorthCostDtl) SumPrice,SUM(TaxOverWorthCostDtl+TollOverWorthCostDtl) SumTaxToll
	INTO #SGroupDtl	
FROM inv.tblStorageDocsDtl D
INNER JOIN inv.tblStorageDocsHdr H
ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
where (D.ProcessID=@ProcessID or D.ProcessID=@RetPID OR (@ProductWithBuy = '1' and @ProcessID = 55 and D.ProcessID=80 ) ) 
and Case When @DateStep = 0 Then D.DocDate Else Case When VchDate <> '' Then VchDate Else  D.DocDate End End >= @DateFr 
and Case When @DateStep = 0 Then D.DocDate Else Case When VchDate <> '' Then VchDate Else  D.DocDate End End <=@DateTo
AND ((@CRCOnly = 0) Or ( @CRCOnly = 1 and D.GoodsAmount > 0)) And NoSentTTMS=0
group by H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo 

-------------------------------------------------------------------------------------
update #SGroupDtl
set SumPrice=SumPrice+A.GAtomAmount
from #SGroupDtl D
inner join ( SELECT isnull(SUM(AtomAmount* GoodsQuantity),0) GAtomAmount,ProcessID,ProcessNo,FiscalYear,SerialNo,HasVAT
FROM inv.tblStorageDocsAtom A 
Group by ProcessID,ProcessNo,FiscalYear,SerialNo,HasVAT) A 
on A.ProcessID=D.ProcessID AND A.ProcessNo=D.ProcessNo AND 
	A.FiscalYear=D.FiscalYear AND A.SerialNo=D.SerialNo AND (A.HasVAT='True' or @HasVAT='True')

if @ProcessID = 49 	
BEGIN
		-------#SHdr-----------------------------------------------------------------
		INSERT INTO #SHdr
		Select ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,VchDate,AcntCode,ServiceDiscount Discount,0 Discount2,TaxOverWorthCost,TollOverWorthCost,ServiceDiscount  SumDiscountHdr
				,0 DiscountTaxOverWorth,'' CurrencyTypeID,0 CurrencyRate,Cast(Case When (ProcessID = @RetPID) Then 1 Else 0 End As Bit) IsReturn,'' AgreeNo,
				''  Kotaj_No,'' Kotaj_Date,'' Gomrok_Arzyabi,'' Gomrok_khoruj,0 PriceParvane,0 ForoushType,'' TTMSPayOffTypeID,VchNo
		FROM acc.tblServicesHdr
		where (ProcessID=@ProcessID or ProcessID=@RetPID ) 
		and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End >= @DateFr 
		and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End <=@DateTo
		AND ((@TaxOnly = 0) OR (@TaxOnly = 1 AND TaxOverWorthCost + TaxOverWorthCost > 0)) 
		----------#SDtl--------------------------------------------------------------
		
		INSERT INTO #SDtl
		select H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,DocRowNo,DiscountDtl,TaxOverWorthCostDtl,TollOverWorthCostDtl,
			   ServiceID GoodsID,(ServiceQuantity* ServiceAmount - DiscountDtl+TaxOverWorthCostDtl+TollOverWorthCostDtl) SumPriceDtlWithTax,
					  (ServiceQuantity*ServiceAmount) SumPriceDtl,0 CurrencyAmount,0 PriceParvane
		FROM acc.tblServicesDtl D
		INNER JOIN acc.tblServicesHdr H
		ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
		where (H.ProcessID=@ProcessID or H.ProcessID=@RetPID ) 
		and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End >= @DateFr 
		and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End <=@DateTo

		-------#SGroupDtl-----------------------------------------------------------------

		INSERT	INTO #SGroupDtl	
		SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,
		   SUM(ServiceQuantity*ServiceAmount -DiscountDtl+TaxOverWorthCostDtl+TollOverWorthCostDtl) SumPrice,SUM(TaxOverWorthCostDtl+TollOverWorthCostDtl) SumTaxToll
		FROM acc.tblServicesDtl D
		INNER JOIN acc.tblServicesHdr H
		ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
		where (H.ProcessID=@ProcessID or H.ProcessID=@RetPID ) 
		and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End >= @DateFr 
		and Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End <=@DateTo
		group by H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo 
END
----------#Main--------------------------------------------------------------

select *,SumPriceDtlWithTax-TaxOverWorthCostDtl-TollOverWorthCostDtl+ TaxDtl+TollDtl-DiscountHdr PurePrice, DiscountDtl+DiscountHdr TotalDiscount  
	Into #Main
FROM (
SELECT H.ProcessID,H.ProcessNo,H.FiscalYear,H.SerialNo,D.DocRowNo,GoodsID,SumPriceDtl,H.AcntCode,H.DocDate,H.AgreeNo,
	   H.VchDate,H.CurrencyTypeID,CurrencyRate,ForoushType, Kotaj_No, Kotaj_Date, Gomrok_Arzyabi, Gomrok_khoruj,H.PriceParvane PriceParvaneHdr,D.PriceParvane PriceParvaneDtl, IsReturn,
       DiscountDtl ,TaxOverWorthCostDtl,TollOverWorthCostDtl,H.Discount,Discount2,CurrencyAmount,
	   DiscountTaxOverWorth,TaxOverWorthCost,TollOverWorthCost,SumDiscountHdr,SumPrice,SumPriceDtlWithTax,VchNo,
	 (SumDiscountHdr*SumPriceDtlWithTax)/SumPrice DiscountHdr,TTMSPayOffTypeID,
	   case when SumTaxToll=0 then ROUND((TaxOverWorthCost*SumPriceDtlWithTax)/SumPrice,0) else TaxOverWorthCostDtl END TaxDtl,
	   case when SumTaxToll=0 then ROUND((TollOverWorthCost*SumPriceDtlWithTax)/SumPrice,0) else TollOverWorthCostDtl END TollDtl
	 
FROM #SDtl	D
inner join #SHdr H ON H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
INNER JOIN #SGroupDtl D2 ON H.ProcessID=D2.ProcessID and H.ProcessNo=D2.ProcessNo AND H.FiscalYear=D2.FiscalYear and H.SerialNo=D2.SerialNo
where SumPrice>0
) a 
--where SerialNo=156

----- Set Round Diffrent
update #Main 
SET TaxDtl = TaxDtl - round(TaxDif,0),
    TollDtl = TollDtl - round(TollDif,0)
from #Main a
inner join 
(select ProcessID,ProcessNo,FiscalYear,SerialNo,SUM(TaxDtl)-TaxOverWorthCost  TaxDif ,SUM(TollDtl)-TollOverWorthCost  TollDif
from #Main
where TollOverWorthCostDtl=0
group by ProcessID,ProcessNo,FiscalYear,SerialNo,TaxOverWorthCost,TollOverWorthCost
having SUM(TaxDtl)<>TaxOverWorthCost OR SUM(TollDtl) <>TollOverWorthCost
) b
on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
INNER JOIN 
(
select * 
from (SELECT  ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,GoodsID ,ROW_NUMBER()over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo order by ProcessID,ProcessNo,FiscalYear,SerialNo,DocRowNo,GoodsID ) R
	  From #Main
	  )a
	  where R=1
)c
on a.ProcessID=c.ProcessID and a.ProcessNo=c.ProcessNo and a.FiscalYear=c.FiscalYear and a.SerialNo=c.SerialNo and a.DocRowNo=c.DocRowNo and a.GoodsID=c.GoodsID

------------------------------------------------------------------------
SELECT AcntCode,GoodsID,N'نام کالا برای ارسال به تتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتتت' GoodsName, CurrencyTypeID, SerialNo, DocRowNo,DocDate , CurrencyAmount, CurrencyRate,
		   ForoushType, Kotaj_No, Kotaj_Date, Gomrok_Arzyabi, Gomrok_khoruj,PriceParvaneDtl PriceParvane, 
		   IsReturn,VchDate,TTMSPayOffTypeID,VchNo,AgreeNo,
		   TaxDtl,
		   TollDtl,
		   PurePrice,
		   TotalDiscount

	INTO #GoodsBaseCalc
	FROM #Main
	where 1=2
	  
----------------------------بر اساس فاکتور جمع گردد -------------------------------------------
if @GoodsBaseCalc=0
BEGIN

	INSERT INTO #GoodsBaseCalc 
	SELECT AcntCode,@TTMSCode GoodsID,@GoodsName GoodsName, CurrencyTypeID,SerialNo,0 DocRowNo, DocDate, CurrencyAmount, CurrencyRate,
		   ForoushType, Kotaj_No, Kotaj_Date, Gomrok_Arzyabi, Gomrok_khoruj,PriceParvaneHdr, IsReturn,VchDate,TTMSPayOffTypeID,VchNo,AgreeNo,
		   SUM(TaxDtl) TaxDtl,
		   SUM(TollDtl) TollDtl,
		   SUM(PurePrice) PurePrice,
		   SUM(TotalDiscount) TotalDiscount

	FROM #Main
	--where SerialNo=156
	GROUP BY AcntCode, CurrencyTypeID,SerialNo, DocDate, CurrencyAmount, CurrencyRate, 
			 ForoushType, Kotaj_No, Kotaj_Date, Gomrok_Arzyabi, Gomrok_khoruj,PriceParvaneHdr, IsReturn,VchDate,TTMSPayOffTypeID,VchNo,AgreeNo
END
----------------------------بر اساس مشتری کالا جمع گردد -------------------------------------------
ELSE if @GoodsBaseCalc=1
BEGIN

	INSERT INTO #GoodsBaseCalc 
	SELECT AcntCode,X.GoodsID,ISNULL(pub.funGetGoodsName(X.GoodsID,1),acc.funGetServiceName(X.GoodsID,1)) GoodsName,CurrencyTypeID, SerialNo, DocRowNo,DocDate , CurrencyAmount, CurrencyRate,
		   ForoushType, Kotaj_No, Kotaj_Date, Gomrok_Arzyabi, Gomrok_khoruj,PriceParvaneDtl, IsReturn,VchDate,TTMSPayOffTypeID,VchNo,AgreeNo,
		   TaxDtl,
		   TollDtl,
		   PurePrice,
		   TotalDiscount

	--INTO #B2
	FROM #Main X
	
END
ELSE if @GoodsBaseCalc=2
BEGIN

	DECLARE @Len int 
	select @Len  =[acc].[FunGetAcntInfoForRemain](2)

	update #Main
	SET AcntCode = SPACE(@Len-1) + SUBSTRING(AcntCode,@Len,20)
	where LEN(AcntCode)>@Len-1

	INSERT INTO #GoodsBaseCalc 
	SELECT AcntCode,X.GoodsID,ISNULL(pub.funGetGoodsName(X.GoodsID,1),acc.funGetServiceName(X.GoodsID,1)) GoodsName, CurrencyTypeID,MAX(SerialNo) SerialNo,0 DocRowNo, MAX(DocDate) DocDate, CurrencyAmount, CurrencyRate,
		   ForoushType, Kotaj_No, Kotaj_Date, Gomrok_Arzyabi, Gomrok_khoruj,PriceParvaneDtl, IsReturn,MAX(VchDate) VchDate,TTMSPayOffTypeID,0 VchNo,MAX(AgreeNo) AgreeNo,
		   SUM(TaxDtl) TaxDtl,
		   SUM(TollDtl) TollDtl,
		   SUM(PurePrice) PurePrice,
		   SUM(TotalDiscount) TotalDiscount

	--INTO #B2
	FROM #Main X	
	GROUP BY AcntCode,X.GoodsID, CurrencyTypeID,  CurrencyAmount, CurrencyRate,
			 ForoushType, Kotaj_No, Kotaj_Date, Gomrok_Arzyabi, Gomrok_khoruj,PriceParvaneDtl, IsReturn,TTMSPayOffTypeID
END
 
 	alter table #GoodsBaseCalc alter column GoodsID nvarchar(1000)  COLLATE Arabic_CS_AS null 
	Update #GoodsBaseCalc set GoodsID='0'  where   GoodsID like '%[^0-9]%' 
	
	select AcntCode, Sum(PurePrice - case when @DiscountType = 0 then 0 else  TotalDiscount  end) SumAllPrice
	into #tblSarjam 
	from  #GoodsBaseCalc  
	Group by AcntCode
	
	--select * from #tblSarjam where (@MaxSmallDealAmount*5/100) <SumAllPrice 

select  @DocSeason DocSeason,X.AcntCode, Case when @GoodsBaseCalc=1 then 0 else Case when (@MaxSmallDealAmount*5/100) <SumAllPrice then 0 else 1 end   end  Sarjam,
		0 IsHagholAmalKari,0 SayerAvarez,case when  CU.TTMSCode='' then null else CU.TTMSCode end CurrencyType, left(Address1,70) Address1,Case When L.LocationIDEx = '' Then '0' Else IsNull(L.LocationIDEx, 0) End CityCode, 
        Case When L.LocationIDEx = '' Then '0' Else IsNull(L.LocationIDEx, 0) End KeshvarCode,ISNULL(case when F.PersonType= 1 then  F.CustomerLastName else F.OrganzationName end,'') CustomerName,
  	    case when F.PersonType= 1 then  F.CustomerFirstName  else '' end CustomerFirstName,		
		case when F.PersonType= 1 then  '' else left(Replace(F.EconomicalCode,' ',''),12) end EconomicalCode, X.GoodsID, X.GoodsID GoodsIDEx, SubString(X.GoodsName,1,100) GoodsName, IsReturn, F.LocationID,
		CASE WHEN  LEFT(Replace(NationalIDNumber,'-',''), 11)<>'' and LEFT(Replace(NationalIDNumber,'-',''), 11)<>'0' THEN LEFT(Replace(NationalIDNumber,'-',''), 11) ELSE LEFT(Replace(NationalIdentity,'-',''), 11) END NationalIDNumber, OrganzationName, Case When L.LocationIDEx = '' OR L.LocationIDEx = '0' Then '0' Else LEFT(IsNull(L.LocationIDEx, 0),2) End StateCode,
		 ISNULL(Case When F.PersonType=2  then OrganzationName else CustomerLastName end,'') PersonNameEx,case when PersonType=0 then 0 else case when PersonType in (2,3) then 2 else 1  end end PersonType   , Tel, left(ZipCode,10) ZipCode,
		  NationalIdentity, case when SaleCustomerType<5 or SaleCustomerType>8 then Null else  SaleCustomerType end   SaleCustomerType,case when BuyCustomerType<5 or BuyCustomerType>8 then Null else  BuyCustomerType end  BuyCustomerType,'' EmptyString,2 CustomerType,0 Zone
		  , X.PurePrice - case when @DiscountType = 0 then 0 else  X.TotalDiscount  end SumPrice1
		  ,0 DiscountPercentDtl,
		 case when @DiscountType = 0 then ROUND(TotalDiscount,0) else 0 end Discount ,
		 0 DiscountDtl, ROUND(X.PurePrice +X.TotalDiscount-TaxDtl - TollDtl - case when @DiscountType = 0 then 0 else X.TotalDiscount end,0) SumPrice,round(TaxDtl,0) VATTax,TollDtl VATTol, 
		 X.TTMSPayOffTypeID PayTypeIDs, 
		 Case When @ProcessID = 55 and @WithAgreeNo = 1 and @ZeroForEmptyAgreeNo=0 Then X.AgreeNo 
			  When @ProcessID = 55 and @WithAgreeNo = 1 and @ZeroForEmptyAgreeNo=1 Then isnull(nullif(X.AgreeNo,''),'0')
			  Else str(X.SerialNo ) End SerialNo,
		 Case When @DateStep = 0 Then DocDate Else Case When VchDate <> '' Then VchDate Else  DocDate End End DocDate, CASE WHEN GG.TTMSCode=0 OR GG.TTMSCode=''  OR GG.TTMSCode IS NULL THEN '12' ELSE GG.TTMSCode END  KalaType, ForoushType,1 KharidType, 
		  cast( Kotaj_No as int) Kotaj_No, Kotaj_Date,cast(Gomrok_Arzyabi as int) Gomrok_Arzyabi ,cast(Gomrok_khoruj as int) Gomrok_khoruj,PriceParvane, VchDate,0 VchNo,0 MaliatMaksoore,NULL Arz_MaliatMaksoore,NULL ArzBarabari_MaliatMaksoore 
		  ,case when  X.CurrencyAmount = '' or  X.CurrencyAmount = 0 then NULL else  X.CurrencyAmount end   CurrencyAmount
			,Case When X.CurrencyTypeID = '' OR X.CurrencyTypeID = 0 Then Null Else   X.CurrencyRate  End CurrencyRate
			,Case When X.CurrencyTypeID = '' Then Null Else   0  End CurrencyTax	--Arz_MaliatArzeshAfzoodeh
			,Case When X.CurrencyTypeID = '' Then Null Else   0  End CurrencyTax2	--Arz_AvarezArzeshAfzoodeh
			,Case When X.CurrencyTypeID = '' Then Null Else   0  End CurrencyEtcTax	--Arz_SayerAvarez
			,Case When X.CurrencyRate  <> 0  Then X.TotalDiscount / X.CurrencyRate Else Null End CurrencyDiscount
			,Case When X.CurrencyTypeID = '' Then Null Else   0  End ArzBarabari_Price
			,Case When X.CurrencyTypeID = '' Then Null Else   0  End ArzBarabari_MaliatArzeshAfzoodeh
			,Case When X.CurrencyTypeID = '' Then Null Else   0  End ArzBarabari_AvarezArzeshAfzoodeh
			,Case When X.CurrencyTypeID = '' Then Null Else   0  End ArzBarabari_SayerAvarez
			,Case when X.CurrencyTypeID = '' Then Null Else   0  End ArzBarabari_TakhfifPrice
from #GoodsBaseCalc X
inner join #tblSarjam  Y on X.AcntCode=Y.AcntCode
OUTER APPLY acc.funGetCodeInfo(X.AcntCode) AS F
LEFT  JOIN pub.tblLocations L on L.LocationID = F.LocationID
LEFT JOIN  pub.tblCurrencyTypes CU on X.CurrencyTypeID = CU.CurrencyTypeID 
LEFT JOIN inv.tblGoods GG ON GG.GoodsID = X.GoodsID
Where ((@TaxOnly = 0) OR (@TaxOnly = 1 AND X.TaxDtl + X.TollDtl > 0)) 
and ( (@processType in (1,3) and   (  X.Kotaj_No='' or X.Kotaj_Date='' or X.Gomrok_Arzyabi=''  or X.Gomrok_khoruj='' ))
or (@processType in (2,4) and   (  X.Kotaj_No<>'' or X.Kotaj_Date<>'' or X.Gomrok_Arzyabi<>''  or X.Gomrok_khoruj<>'' or X.PriceParvane<>0)))
order by AcntCode

END----end
GO
