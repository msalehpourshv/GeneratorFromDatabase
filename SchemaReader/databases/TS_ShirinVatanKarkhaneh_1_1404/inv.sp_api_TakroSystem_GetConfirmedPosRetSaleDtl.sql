USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1400/08/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_TakroSystem_GetConfirmedPosRetSaleDtl]
@ProcessId AS int,
@ProcessNo AS int,
@SerialNo AS int,
@FiscalYear AS int,
@TPCanceled as int,
@TPEdited as int,
@BaseFiscalYear as int

WITH ENCRYPTION
 AS
BEGIN
BEGIN -- DECLARE VALUE
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @TaxOverWorthPercentInSale AS INT
	DECLARE @TollOverWorthPercentInSale INT
	declare @From as int
	declare @To as int
	declare @PartNumber as int
	declare @Len1 as int
	declare @Len2 as int
	declare @Len3 as int
	declare @Len4 as int
	DECLARE @TotalPrice bit
	DECLARE @2Qty bit
	DECLARE @2Price bit
	DECLARE @Sal2 bit
	DECLARE @HasDST bit
	DECLARE @Query1 NVARCHAR(MAX)
	DECLARE @Query2 NVARCHAR(MAX)
	DECLARE @Query3 NVARCHAR(MAX)
	DECLARE @Query4 NVARCHAR(MAX)
	DECLARE @QryRet NVARCHAR(MAX)
	DECLARE @TaxOverWorhQuery NVARCHAR(MAX)
	DECLARE @JoinTaxOverWorhQuery NVARCHAR(MAX)
	DECLARE @PriceQuery NVARCHAR(MAX)
	DECLARE @QtyQuery NVARCHAR(MAX)
	DECLARE @GoodsJoinQuery NVARCHAR(MAX)
END

BEGIN TRY

BEGIN --CHECK PRICE AND QUANTITY FROM SETTING AND GOODSLAYER
	--<NativeText("دو ستونی بودن مقدار در فرم ها")>
	--  Public Shared Inv_QuantityIsTwoColumn As Boolean = False ' مقدار اصلی و فرعی در خرید و فروش
	--<NativeText("قیمت اصلی و فرعی در خرید و فروش")>
	-- Public Shared Inv_ShowSecondPrice As Boolean = False ' قیمت اصلی و فرعی در خرید و فروش
	-- <NativeText("قیمت فروش بر اساس واحد فرعی")>
	-- Public Shared Sal_SaleWithSecondryPrice As Boolean = False  'قیمت فروش بر اساس واحد فرعی
	
	SELECT @TotalPrice=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Inv_CalcTotalPriceWithUnitType'
	SELECT @2Qty=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Inv_QuantityIsTwoColumn'
	SELECT @2Price=SettingValue FROM pub.tblSettings 	WHERE SettingKey = 'Inv_ShowSecondPrice'
	SELECT @Sal2=SettingValue 	FROM pub.tblSettings 	WHERE SettingKey = 'Sal_SaleWithSecondryPrice'
	SELECT @HasDST=SettingValue FROM pub.tblSettings 	WHERE SettingKey = 'HasDST'

	SELECT @TaxOverWorthPercentInSale=SettingValue FROM pub.tblSettings 
	WHERE SettingKey = 'TaxOverWorthPercentInSale'

	SET @TotalPrice=ISNULL(@TotalPrice,0)
	SELECT @TollOverWorthPercentInSale=SettingValue FROM pub.tblSettings 
	WHERE SettingKey = 'TollOverWorthPercentInSale'

	select @PartNumber=isnull(SettingValue,0) from pub.tblSettings
	where SettingKey = 'UnitPart' and 1=1

	select @Len1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=1 
	select @Len2=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7 +Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=2
	select @Len3=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=3 
	select @Len4=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' and PartNumber=4
	
	if(@PartNumber=0)
	 set @PartNumber=1

	if(@PartNumber=1)
	begin
	 set @To=@Len1
	 set @From= 1
	end

	if(@PartNumber=2)
	begin
	 set @To=@Len2
	 set @From= @Len1+1
	end

	if(@PartNumber=3)
	begin
	 set @To=@Len3
	 set @From= @Len1+@Len2+1
	end

	if(@PartNumber=4)
	begin
	 set @To=@Len4
	 set @From= @Len1+@Len2+@Len3+1
	end
END

BEGIN --DUPLICATED QUERY
	SET @PriceQuery='ISNULL(CAST(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END 
					AS DECIMAL(28,7)),0)'

	SET @QtyQuery='ISNULL(ROUND( CAST(GoodsQuantity AS float),7,0),0)'

	SET @GoodsJoinQuery='LEFT JOIN inv.tblGoods G 
						 ON  G.GoodsID=substring(D.GoodsID,'+ str(@From)+','+ str(@To)+')
						 AND G.PartNumber='+ str(@PartNumber)+''

	SET @JoinTaxOverWorhQuery = '('+@PriceQuery+'*'+@QtyQuery+'-DiscountDtl)- 
	(('+@PriceQuery+'*'+@QtyQuery+'-DiscountDtl)/
	CASE 
	WHEN G.Tax<>0 THEN 100+G.Tax
	WHEN G.NotContainTax=1 THEN 1
	WHEN G.NotContainTax=0 AND  G.Tax=0 THEN 100 + '+str( @TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale) +'
	END  * 
	CASE 
	WHEN G.NotContainTax=1 THEN 1
	WHEN G.NotContainTax=0 THEN 100
	END)'

	SET @TaxOverWorhQuery = 'CAST(FLOOR(
	(MainPrice*QtyNew-DiscountDtl)- ((MainPrice*QtyNew-DiscountDtl)/
	CASE 
	WHEN G.Tax<>0 THEN 100+G.Tax
	WHEN G.NotContainTax=1 THEN 1
	WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
	END  * 
	CASE 
	WHEN G.NotContainTax=1 THEN 1
	WHEN G.NotContainTax=0 THEN 100
	END )) AS DECIMAL(28,0))'

	DECLARE @edJoin nvarchar(max)=
'					INNER JOIN 
						(SELECT D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,
							SUM((D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )
						    *GoodsQuantity-DiscountDtl) AS TotalAmount
						 FROM inv.tblStorageDocsDtl D
						 INNER JOIN inv.tblGoods G  ON D.GoodsID=G.GoodsID
						 INNER JOIN inv.tblStorageDocsHdr H 
						 ON D.ProcessID =H.ProcessID  AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear and D.SerialNo=H.SerialNo 
						 WHERE (Discount+Discount2+Discount3)> 0 and  NotDiscount = 0 and 
							(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 and G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )*
						    GoodsQuantity-DiscountDtl<>0-- فقط رکوردهایی که شامل سرشکن می‌شوند
						 GROUP BY D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.BranchID
						 ) ed ON D.ProcessID =ed.ProcessID  AND D.ProcessNo=ed.ProcessNo AND D.FiscalYear=ed.FiscalYear and D.SerialNo=ed.SerialNo '

	DECLARE @FromSelectD1 nvarchar(max)=
					'FROM (SELECT 
					    D.SerialNo ,D.ProcessID,D.ProcessNo,D.FiscalYear,SubUnitID,DocRowNo,CommissionerContractID,D.GoodsID,DiscountDtl,CurrencyAmount,D.RowNo,
						--R
						ROW_NUMBER()over (partition by D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo order by D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,RowNo ) R,
						--DiscountAmount
						Discount+Discount2+Discount3 DiscountAmount,	
						--DistributedDiscount
						 ROUND( ((
						 '+@PriceQuery+'*'+@QtyQuery+'-DiscountDtl) / ed.TotalAmount) * 
						 (Discount+Discount2+Discount3),0) AS DistributedDiscount, -- سرشکن به نسبت Amount
						--TotalPure
						 ('+@PriceQuery+'*'+@QtyQuery+')-DiscountDtl- ROUND( ((
						'+@PriceQuery+'*'+@QtyQuery+'-DiscountDtl) / ed.TotalAmount) *
						 (Discount+Discount2+Discount3),0) 
						 AS TotalPure,
'
	
	DECLARE @FromSelectD2 nvarchar(max)=
					'FROM (     SELECT SUM(DistributedDiscount)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo order by ProcessID,ProcessNo,FiscalYear,SerialNo) TotalDistributedDiscount,
				   MAX(R)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo order by ProcessID,ProcessNo,FiscalYear,SerialNo) MaxRow,* '

	DECLARE @Discount nvarchar(max)='
					CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount)+ DiscountDtlAll
					  ELSE DistributedDiscount+DiscountDtlAll END '
	
	DECLARE @Discount1 nvarchar(max)='
					CASE WHEN '+@Discount+'-ISNULL(SSR.SDiscountDtl,0) <0 THEN 0 ELSE 
					'+@Discount+' END '
END

BEGIN --CHECK DATABASE
	declare @DBNAME as varchar(100)
	declare @BaseDBNAME as varchar(100)

	declare @MainDBNAME as varchar(100)
	select @MainDBNAME=db_name()
	select @DBNAME=substring (@MainDBNAME,1 , len(@MainDBNAME)-4)+ ltrim(str(@BaseFiscalYear))

	if(select count(*) from inv.tblStorageDocsDtl
	where SerialNo=@SerialNo and FiscalYear=@FiscalYear and ProcessNo=@ProcessNo and ProcessID=@ProcessId
	and BaseFiscalYear<>@FiscalYear)>0
	begin
		SET @BaseDBNAME=@DBNAME
	end

	else
	begin
		SET @BaseDBNAME=@MainDBNAME
	end
END
print @BaseDBNAME

--------------------------------------------------------------------------------------------------------
select 0 MainDiscount, 0TotalDistributedDiscount	,0MaxRow,	SerialNo,	ProcessID	,ProcessNo,	FiscalYear,	SubUnitID	,DocRowNo,
CommissionerContractID,	GoodsID,	DiscountDtl,	CurrencyAmount,	RowNo,0	R	,0DiscountAmount	,0DistributedDiscount,
0TotalPure,	TaxOverWorthCostDtl,0	QtyNew,0	PriceNew,0	MainPrice	,0DiscountDtlAll,	BaseProcessID,
BaseSerialNo,	BaseProcessNo,	BaseFiscalYear	,BaseDocRowNo,GoodsQuantity,GoodsPrice
into #tblStorageDocsDtlNew
from inv.tblStorageDocsDtl 
where 1=0


insert into #tblStorageDocsDtlNew
exec [inv].[sp_api_TakroSystem_GetRetSaleDtlForPos] @ProcessId,@ProcessNo,@SerialNo,@FiscalYear,
@TaxOverWorthPercentInSale,@TollOverWorthPercentInSale,@PartNumber,@From,@To
--------------------------------------------------------------------------------------------------------

set @QryRet=' SELECT D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo  ,
		   	    SUM('+@QtyQuery+') AS SGoodsQuantity,
				SUM('+@JoinTaxOverWorhQuery+')	AS STaxOverWorthCostDtl,
				SUM(DistributedDiscount)		AS SDiscountDtl				
			from #tblStorageDocsDtlNew D
			'+@GoodsJoinQuery+'
			inner JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear				
		    WHERE  D.ProcessID=100 AND D.SerialNo<='+ str(@SerialNo)+'
		    GROUP BY D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo '

BEGIN --GET DATA FROM LAST YEAR
if exists (select * from master.sys.databases where name=@BaseDBNAME) and @MainDBNAME<>@DBNAME
begin
	
	Set @Query3=' union all 
			select *
				'+@FromSelectD2+'
					'+@FromSelectD1+'
							'+@JoinTaxOverWorhQuery+' AS TaxOverWorthCostDtl,
							'+@QtyQuery+' AS  QtyNew,	
							'+@PriceQuery+' AS PriceNew,
							ISNULL(CAST(D.GoodsPrice  AS DECIMAL(28,7)),0) AS MainPrice,
							DiscountDtl AS DiscountDtlAll 
							FROM '+@BaseDBNAME+'.inv.tblStorageDocsDtl D
							'+@GoodsJoinQuery+'
							'+@edJoin+'
							inner JOIN '+@BaseDBNAME+'.inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear
					)D
				)D
			 '

	Set @Query4=' union all 
		 select 
		 BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
		 from '+@BaseDBNAME+'.inv.tblStorageDocsHdr 
		 where SerialNo='+ str(@SerialNo)+' AND ProcessID='+ str(@ProcessId)+' AND ProcessNo='+ str(@ProcessNo)+' AND FiscalYear='+ str(@FiscalYear)+'		
		 '

	set @QryRet= @QryRet+ '
			union all 
			SELECT D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo  ,
		   	    SUM('+@QtyQuery+')		    AS SGoodsQuantity,
				SUM('+@JoinTaxOverWorhQuery+')	AS STaxOverWorthCostDtl,
				SUM(DistributedDiscount)		    AS SDiscountDtl				
			from #tblStorageDocsDtlNew D
			'+@GoodsJoinQuery+'
			inner JOIN '+@BaseDBNAME+'.inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear				
		WHERE  D.ProcessID=100 
		GROUP BY D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo '
end
else
begin
	set @DBNAME=@MainDBNAME
	Set @Query3=''
	Set @Query4=''
end
END

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if(@TPCanceled=0)
	begin
		set @Query1='SELECT 
		----------------------------------ãÍÇÓÈå ãÈáÛ äÞÏí	
		CAST(floor(			
			(    (PriceNew*QtyNew -'+@Discount1+') -
				 (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(CASE WHEN '+@Discount+'-SSR.SDiscountDtl <0 THEN 0 ELSE SSR.SDiscountDtl END ,0))
			))as decimal) AS Cop,	

		CAST(pub.funDecimalPlace(ISNULL(D1.CurrencyAmount,0) ,4)AS DECIMAL (28,4))AS CurrencyAmount,
-------------------------
		CAST(0 AS DECIMAL) AS WeightDtl,
---------------------------	
		ISNULL(C.ISOCode,'''') AS CurrencyType,		
		cast(pub.funDecimalPlace(CurrencyRate ,4)as decimal(28,4)) AS CurrencyRate,
-------------------------
		CASE 
		WHEN CurrencyRate=0 THEN CAST(0 AS DECIMAL)
		WHEN CurrencyRate<>0 THEN CAST(pub.funDecimalPlace(PriceNew* (QtyNew - ISNULL(SSR.SGoodsQuantity,0))   / CurrencyRate,4) AS DECIMAL(28,4))
		END Sscv,
-------------------------
		QtyNew - ISNULL(SSR.SGoodsQuantity,0)  AS SubUnitQuantity,
-------------------------
	    PriceNew AS GoodsPrice,
-------------------------
		CAST(floor(			
			 (PriceNew*QtyNew) - (PriceNew  * ISNULL(SSR.SGoodsQuantity,0))
		) AS DECIMAL(28,0)) AS PriceBeforDiscount,
-------------------------
		CAST(floor(
		   ( (PriceNew*QtyNew -'+@Discount1+') - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(CASE WHEN '+@Discount+'-SSR.SDiscountDtl <0 THEN 0 ELSE SSR.SDiscountDtl END,0)) )
		)AS DECIMAL(28,0)) AS PriceAfterDiscount,
------------------------
		CAST(FLOOR(
		CAST(floor(
		   ( (PriceNew*QtyNew -'+@Discount1+') - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(CASE WHEN '+@Discount+'-SSR.SDiscountDtl <0 THEN 0 ELSE SSR.SDiscountDtl END,0)) )
		)AS DECIMAL(28,0))*
		CASE 
		WHEN G.Tax<>0 THEN G.Tax
		WHEN G.NotContainTax=1 THEN 0
		WHEN G.NotContainTax=0 and G.Tax=0 THEN'+ STR(@TaxOverWorthPercentInSale)+'+'+STR(@TollOverWorthPercentInSale)+'
		END /100 )AS DECIMAL(28,0))
		 TaxOverWorth,
-------------------------
		CAST(
		CAST(floor(
		   ( (PriceNew*QtyNew -'+@Discount1+') - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(CASE WHEN '+@Discount+'-SSR.SDiscountDtl <0 THEN 0 ELSE SSR.SDiscountDtl END,0)) )
		)AS DECIMAL(28,0))+	
		CAST(FLOOR(
		CAST(floor(
		   ( (PriceNew*QtyNew -'+@Discount1+') - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(CASE WHEN '+@Discount+'-SSR.SDiscountDtl <0 THEN 0 ELSE SSR.SDiscountDtl END,0)) )
		)AS DECIMAL(28,0))*
		CASE 
		WHEN G.Tax<>0 THEN G.Tax
		WHEN G.NotContainTax=1 THEN 0
		WHEN G.NotContainTax=0 and G.Tax=0 THEN'+ STR(@TaxOverWorthPercentInSale)+'+'+STR(@TollOverWorthPercentInSale)+'
		END /100 )AS DECIMAL(28,0))AS DECIMAL(28,0))
		AS Amount,  
-------------------------	
		CAST(floor('+@Discount1+' - ISNULL(CASE WHEN '+@Discount+'-SSR.SDiscountDtl <0 THEN 0 ELSE SSR.SDiscountDtl END,0))AS DECIMAL(28,0)) AS DiscountDtl,
		---------------------------------------------------ãÇáíÇÊ-------------------------------------------------------------------------------------------------	
		CASE 
		WHEN ISNULL(G.NotContainTax,0)=1 THEN 0
		WHEN ISNULL(D1.DiscountDtl,0)=(PriceNew*QtyNew ) THEN 
		CASE
			WHEN CAST(ISNULL(GG.Tax,0)+ISNULL(GG.Toll,0) AS DECIMAL)=0  THEN  CAST(
				(SELECT CAST(ISNULL(SettingValue ,0) AS INT)+
					(SELECT CAST(ISNULL(SettingValue ,0) AS INT) FROM '+@BaseDBNAME +'.pub.tblSettings WHERE SettingKey=''TollOverWorthPercentInSale'')
				 FROM '+@BaseDBNAME +'.pub.tblSettings WHERE SettingKey = ''TaxOverWorthPercentInSale''
				)
				AS DECIMAL)
				WHEN CAST(ISNULL(GG.Tax ,0)+ISNULL(GG.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(GG.Tax,0 )+ISNULL(GG.Toll,0 ) AS DECIMAL)
		END

		WHEN ISNULL('+@TaxOverWorhQuery+',0)=0 and ISNULL(10,0)=0 THEN CAST(0 AS DECIMAL)
		WHEN '+@TaxOverWorhQuery+' <>0  THEN  
			CAST((ROUND(('+@TaxOverWorhQuery+'*100)/((PriceNew*QtyNew)-CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
					  ELSE DistributedDiscount END +DiscountDtl),2)) as decimal)
		END Tax,
		----------------------------------------------
		CAST(U.TPUnitID  AS NVARCHAR(50)) AS UnitID ,LTRIM(RTRIM(inv.FunGetGoodsCID( substring(D1.GoodsID,'+ str(@From)+','+ str(@To)+')))) AS GoodsCId,pub.funGetGoodsName( substring(D1.GoodsID,'+ str(@From)+','+ str(@To)+'),1) AS GoodsName,PayType,D1.RowNo,
		CommissionerContractID 		'
		set @Query2='
		from 
			(select *
				'+@FromSelectD2+'
					'+@FromSelectD1+'
					'+@JoinTaxOverWorhQuery+' AS TaxOverWorthCostDtl,
					'+@QtyQuery+' AS  QtyNew,	
					'+@PriceQuery+' AS PriceNew,
					ISNULL(CAST(D.GoodsPrice  AS DECIMAL(28,7)),0) AS MainPrice,
					DiscountDtl AS DiscountDtlAll 
					from inv.tblStorageDocsDtl D
					'+@GoodsJoinQuery+'
					'+@edJoin+'
					inner JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear			
					)D
				)D
			'+ @Query3+ '
		) D1
		--JOINS RET SALE HDR GET KEYS OF SALE
		inner join 
		(
		 select  BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
		 from (
		 	 select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
			 from inv.tblStorageDocsHdr 
			 where SerialNo='+ str(@SerialNo)+' AND ProcessID='+ str(@ProcessId)+' AND ProcessNo='+ str(@ProcessNo)+' AND FiscalYear='+ str(@FiscalYear)+'
			 '+ @Query4+ '
		 )aaaa
		 group by BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo
		 ) Sal
		on D1.SerialNo=Sal.BaseSerialNo AND D1.ProcessID=Sal.BaseProcessID AND D1.ProcessNo=Sal.BaseProcessNo AND D1.FiscalYear=Sal.BaseFiscalYear
		-- JOINS SUM OF REST SALES
		LEFT JOIN 	
		('+@QryRet+') SSR 
		on D1.SerialNo=SSR.BaseSerialNo AND D1.ProcessID=SSR.BaseProcessID AND D1.ProcessNo=SSR.BaseProcessNo AND D1.FiscalYear=SSR.BaseFiscalYear AND D1.DocRowNo=SSR.BaseDocRowNo 
		LEFT JOIN inv.tblGoods G ON G.GoodsID=substring(D1.GoodsID,'+ str(@From)+','+ str(@To)+')  AND G.PartNumber='+ str(@PartNumber)+' 
		LEFT JOIN (SELECT * from inv.tblStorageDocsHdr where SerialNo='+ str(@SerialNo)+' AND ProcessID='+ str(@ProcessId)+' AND ProcessNo='+ str(@ProcessNo)+' AND FiscalYear='+ str(@FiscalYear)+') H 
		ON  H.BaseProcessID=D1.ProcessID and H.BaseProcessNo=D1.ProcessNo and H.BaseFiscalYear=D1.FiscalYear and H.BaseSerialNo=D1.SerialNo 
		
				LEFT JOIN inv.tblUnits U ON U.UnitID = CASE WHEN '+str(@2Qty)+'=0 and '+str(@2Price)+'=1 THEN ISNULL((select top 1 SubUnitID 
	                                                                             FROM inv.tblSubUnitsDtl SU 
																				 WHERE SU.GoodsID=D1.GoodsID  and ShowInInvoice=1  ),D1.SubUnitID) ELSE D1.SubUnitID  END

		LEFT JOIN pub.tblCurrencyTypes C ON C.CurrencyTypeID=H.CurrencyTypeID
		LEFT JOIN '+@BaseDBNAME +'.inv.tblGoods GG ON GG.GoodsID=substring(D1.GoodsID,'+ str(@From)+','+ str(@To)+') AND GG.PartNumber='+ str(@PartNumber)+'

		WHERE  QtyNew - ISNULL(SSR.SGoodsQuantity,0) >0
		order by D1.DocRowNo '
		
		--print @QryRet


		set @Query1=  @Query1+@Query2
		print @Query1
		exec sp_executesql @Query1
	
	
	end
	
END TRY

BEGIN CATCH
	
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH
END
GO
