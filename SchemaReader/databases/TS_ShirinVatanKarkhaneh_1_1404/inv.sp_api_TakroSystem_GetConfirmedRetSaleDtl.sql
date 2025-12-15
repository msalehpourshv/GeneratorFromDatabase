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
CREATE PROCEDURE [inv].[sp_api_TakroSystem_GetConfirmedRetSaleDtl]
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
	DECLARE @Query5 NVARCHAR(MAX)

	DECLARE @QryRet NVARCHAR(MAX)
BEGIN TRY


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
 

set @QryRet=' SELECT D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo  ,
		   	    SUM(ISNULL(ROUND(case when '+ str(@TotalPrice)+'=1 and '+ str(@Sal2)+'=1 then cast(SubUnitQuantity  as float) else
				CASE WHEN '+ str(@2Qty)+'=0 and '+ str(@2Price)+'=1 
					THEN cast(SubUnitQuantity2  as float) 
				ELSE CASE WHEN  '+ str(@2Qty)+'=0 and ('+ str(@HasDST)+'=1 or '+ str(@Sal2)+'=1 ) 
					THEN cast(SubUnitQuantity   as float) ELSE  cast(GoodsQuantity  as float) END END END,7,0),0)) AS SGoodsQuantity,
				SUM(TaxOverWorthCostDtl)	AS STaxOverWorthCostDtl,
				SUM(TollOverWorthCostDtl)	AS STollOverWorthCostDtl,
				SUM(DiscountDtl+ Case when DiscountTaxOverWorth=0 then 0 else TaxOverWorthCostDtl+TollOverWorthCostDtl end)		AS SDiscountDtl				
			from inv.tblStorageDocsDtl D			 
			inner JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear				
		WHERE  D.ProcessID=100 AND D.SerialNo<='+ str(@SerialNo)+'
		GROUP BY D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo '

 

if exists (select * from master.sys.databases where name=@BaseDBNAME) and @MainDBNAME<>@DBNAME
begin
	Set @Query3=' 	
			union all 
			select D.SerialNo ,D.ProcessID,D.ProcessNo,D.FiscalYear,SubUnitID,DocRowNo,
					D.TaxOverWorthCostDtl,D.IsReward,CommissionerContractID,GoodsID,DiscountDtl,CurrencyAmount,D.RowNo,
					H.DiscountTaxOverWorth as IsDiscountTaxOverWorth,
			ISNULL(ROUND(case when '+ str(@TotalPrice)+'=1 and '+ str(@Sal2)+'=1 then cast(SubUnitQuantity as float) else
			CASE WHEN '+ str(@2Qty)+'=0 and '+ str(@2Price)+'=1 
				THEN cast(SubUnitQuantity2  as float)  
			ELSE CASE WHEN  '+ str(@2Qty)+'=0 and ('+ str(@HasDST)+'=1 or '+ str(@Sal2)+'=1 )
				THEN cast(SubUnitQuantity   as float) ELSE  cast(GoodsQuantity  as float) END END END,7,0),0) AS  QtyNew,	
			ISNULL(CAST(case when '+ str(@TotalPrice)+'=1 and '+ str(@Sal2)+'=1 then 
			case when GoodsQuantity=SubUnitQuantity then GoodsPrice else			SubUnitPrice2 end 
			else			
			CASE WHEN  '+ str(@2Qty)+'=0 and '+ str(@2Price)+'=1 THEN SubUnitPrice2    ELSE CASE WHEN  '+ str(@2Qty)+'=0 and ('+ str(@HasDST)+'=1 or '+ str(@Sal2)+'=1 ) THEN SubUnitPrice     ELSE  GoodsPrice    END END END AS float),0) AS PriceNew
			, DiscountDtl+ Case when DiscountTaxOverWorth=0 then 0 else TaxOverWorthCostDtl+TollOverWorthCostDtl end  DiscountDtlAll 
			from '+@BaseDBNAME+'.inv.tblStorageDocsDtl D					 
			inner JOIN '+@BaseDBNAME+'.inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear			
			 '
	Set @Query4=' union all 
		select BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo 
		 from '+@BaseDBNAME+'.inv.tblStorageDocsHdr 
		 where SerialNo='+ str(@SerialNo)+' AND ProcessID='+ str(@ProcessId)+' AND ProcessNo='+ str(@ProcessNo)+' AND FiscalYear='+ str(@FiscalYear)+'		
		 '


set @QryRet= @QryRet+ '
			union all 
			SELECT D.BaseProcessID,D.BaseProcessNo,D.BaseFiscalYear,D.BaseSerialNo,D.BaseDocRowNo  ,
		   	    SUM(ISNULL(ROUND(case when '+ str(@TotalPrice)+'=1 and '+ str(@Sal2)+'=1 then cast(SubUnitQuantity  as float) else
				CASE WHEN '+ str(@2Qty)+'=0 and '+ str(@2Price)+'=1 
					THEN cast(SubUnitQuantity2  as float) 
				ELSE CASE WHEN  '+ str(@2Qty)+'=0 and ('+ str(@HasDST)+'=1 or '+ str(@Sal2)+'=1 ) 
					THEN cast(SubUnitQuantity   as float) ELSE  cast(GoodsQuantity  as float) END END END,7,0),0)) AS SGoodsQuantity,
				SUM(TaxOverWorthCostDtl)	AS STaxOverWorthCostDtl,
				SUM(TollOverWorthCostDtl)	AS STollOverWorthCostDtl,
				SUM(DiscountDtl+ Case when DiscountTaxOverWorth=0 then 0 else TaxOverWorthCostDtl+TollOverWorthCostDtl end)		AS SDiscountDtl				
			from '+@BaseDBNAME+'.inv.tblStorageDocsDtl D			 
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

------------------------------------------------------------------------------------------------------------------------------------------------------------------------
	if(@TPCanceled=0)
	begin
		set @Query1='SELECT 
----------------------------------ãÍÇÓÈå ãÈáÛ äÞÏí	
		CASE
		WHEN PayType=0 THEN 0
		WHEN  PayType=1 THEN CAST(floor(			
			(    (PriceNew*QtyNew -D1.DiscountDtlAll) -
				 (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(SSR.SDiscountDtl,0))
			))as decimal)
							
		WHEN PayType=2 THEN 0
		END Cop,	
		CAST(pub.funDecimalPlace(ISNULL(D1.CurrencyAmount,0) ,4)AS DECIMAL (28,4))AS CurrencyAmount,
-------------------------
		CASE 
		WHEN TPInp =7 THEN CAST(pub.funDecimalPlace( G.GoodsWeight * (QtyNew  - ISNULL(SSR.SGoodsQuantity,0))
						   ,3) AS DECIMAL(28,3))		
		WHEN TPInp<>7 THEN CAST(0 AS DECIMAL)		
		END WeightDtl,
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
	    Cast(PriceNew as decimal(27,7))GoodsPrice,
-------------------------
		CAST(floor(			
			 (PriceNew*QtyNew) - (PriceNew  * ISNULL(SSR.SGoodsQuantity,0))
		) AS DECIMAL(28,0)) AS PriceBeforDiscount,
-------------------------
		CAST(floor(
		   ( (PriceNew*QtyNew -D1.DiscountDtlAll) - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(SSR.SDiscountDtl,0)) )
		)AS DECIMAL(28,0)) AS PriceAfterDiscount,
------------------------
		CASE
		WHEN ISNULL(D1.TaxOverWorthCostDtl,0)<>0 THEN
			CAST(floor( floor
			((PriceNew*QtyNew -D1.DiscountDtlAll) - 
			 (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(SSR.SDiscountDtl,0)) )  
			*
			CASE
				WHEN IsDiscountTaxOverWorth=1 THEN
					CAST((ROUND((D1.TaxOverWorthCostDtl*100)/(((PriceNew*QtyNew)-D1.DiscountDtl)-D1.TaxOverWorthCostDtl),2)) as decimal)
				WHEN IsDiscountTaxOverWorth=0 THEN 
					CAST((ROUND((D1.TaxOverWorthCostDtl*100)/((PriceNew*QtyNew)-D1.DiscountDtl),2)) as decimal)
			END
			/100 ) AS DECIMAL(28,0))
		WHEN ISNULL(D1.TaxOverWorthCostDtl,0)=0 THEN CAST (0 AS DECIMAL)
		END TaxOverWorth,
-------------------------
		CASE 
		WHEN TPInp<>7 THEN
		CAST(floor(			
				floor( (PriceNew*QtyNew -D1.DiscountDtlAll) - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(SSR.SDiscountDtl,0)) )	+
				CASE
					WHEN ISNULL(D1.TaxOverWorthCostDtl,0)<>0 THEN
						CAST(floor( floor( (PriceNew*QtyNew -D1.DiscountDtlAll) - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(SSR.SDiscountDtl,0)) ) 
						*
						CASE
						WHEN IsDiscountTaxOverWorth=1 THEN
							CAST((ROUND((D1.TaxOverWorthCostDtl*100)/(((PriceNew*QtyNew)-D1.DiscountDtl)-D1.TaxOverWorthCostDtl),2)) as decimal)
						WHEN IsDiscountTaxOverWorth=0 THEN 
							CAST((ROUND((D1.TaxOverWorthCostDtl*100)/((PriceNew*QtyNew)-D1.DiscountDtl),2)) as decimal)
						END
						/100 ) AS DECIMAL(28,0))
							
					WHEN ISNULL(D1.TaxOverWorthCostDtl,0)=0 THEN CAST (0 AS DECIMAL)
				END
		)AS DECIMAL(28,0))		
		WHEN TPInp=7 THEN
		CAST(floor(			
				floor( (PriceNew*QtyNew ) - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)) )	+
				CASE
					WHEN ISNULL(D1.TaxOverWorthCostDtl,0)<>0 THEN
						CAST(floor( floor( (PriceNew*QtyNew -D1.DiscountDtlAll) - (PriceNew * ISNULL(SSR.SGoodsQuantity,0)-ISNULL(SSR.SDiscountDtl,0)) ) 
						*(ROUND((D1.TaxOverWorthCostDtl*100)/((PriceNew*QtyNew)-D1.DiscountDtl),2))
						/100 ) AS DECIMAL(28,0))	
					WHEN ISNULL(D1.TaxOverWorthCostDtl,0)=0 THEN CAST (0 AS DECIMAL)
				END
		)AS DECIMAL(28,0))
		END Amount,  
-------------------------	
		CAST(floor(D1.DiscountDtlAll - ISNULL(SSR.SDiscountDtl,0))AS DECIMAL(28,0)) AS DiscountDtl,		
		---------------------------------------------------ãÇáíÇÊ-------------------------------------------------------------------------------------------------	
		D1.IsReward,
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

		WHEN ISNULL(D1.TaxOverWorthCostDtl,0)=0 and ISNULL(D1.IsReward,0)=0 THEN CAST(0 AS DECIMAL)
		WHEN D1.TaxOverWorthCostDtl <>0  THEN  
			CASE
				WHEN IsDiscountTaxOverWorth=1 THEN
					CAST((ROUND((D1.TaxOverWorthCostDtl*100)/(((PriceNew*QtyNew)-D1.DiscountDtl)-D1.TaxOverWorthCostDtl),2)) as decimal)
				WHEN IsDiscountTaxOverWorth=0 THEN 
					CAST((ROUND((D1.TaxOverWorthCostDtl*100)/((PriceNew*QtyNew)-D1.DiscountDtl),2)) as decimal)
			END
		WHEN ISNULL(D1.IsReward,0)=1 THEN
			CASE
				WHEN CAST(ISNULL(GG.Tax,0)+ISNULL(GG.Toll,0) AS DECIMAL)=0  THEN  CAST(
				(SELECT CAST(ISNULL(SettingValue ,0) AS INT)+
					(SELECT CAST(ISNULL(SettingValue ,0) AS INT) FROM '+@BaseDBNAME +'.pub.tblSettings WHERE SettingKey=''TollOverWorthPercentInSale'')
				 FROM '+@BaseDBNAME +'.pub.tblSettings WHERE SettingKey = ''TaxOverWorthPercentInSale''
				)
				AS DECIMAL)
				WHEN CAST(ISNULL(GG.Tax ,0)+ISNULL(GG.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(GG.Tax,0 )+ISNULL(GG.Toll,0 ) AS DECIMAL)
			END
		END Tax,
		----------------------------------------------
		CAST(U.TPUnitID  AS NVARCHAR(50)) AS UnitID ,LTRIM(RTRIM(inv.FunGetGoodsCID( substring(D1.GoodsID,'+ str(@From)+','+ str(@To)+')))) AS GoodsCId,pub.funGetGoodsName( substring(D1.GoodsID,'+ str(@From)+','+ str(@To)+'),1) AS GoodsName,PayType,D1.RowNo,
		CommissionerContractID 		
'
		set @Query2='
		from 
			(
			 select SerialNo ,ProcessID,ProcessNo,FiscalYear,SubUnitID,DocRowNo,
					TaxOverWorthCostDtl,IsReward,CommissionerContractID,GoodsID,DiscountDtl,CurrencyAmount,RowNo,
					IsDiscountTaxOverWorth,QtyNew,PriceNew,DiscountDtlAll
		 from (
			select D.SerialNo ,D.ProcessID,D.ProcessNo,D.FiscalYear,SubUnitID,DocRowNo,
					D.TaxOverWorthCostDtl,D.IsReward,CommissionerContractID,GoodsID,DiscountDtl,CurrencyAmount,D.RowNo,
					H.DiscountTaxOverWorth as IsDiscountTaxOverWorth,
			ISNULL(ROUND(case when '+ str(@TotalPrice)+'=1 and '+ str(@Sal2)+'=1 then cast(SubUnitQuantity  as float) else
			CASE WHEN '+ str(@2Qty)+'=0 and '+ str(@2Price)+'=1 
				THEN cast(SubUnitQuantity2  as float) 
			ELSE CASE WHEN  '+ str(@2Qty)+'=0 and ('+ str(@HasDST)+'=1 or '+ str(@Sal2)+'=1 ) 
				THEN cast(SubUnitQuantity   as float) ELSE  cast(GoodsQuantity  as float) END END END,7,0),0) AS  QtyNew,	
			ISNULL(CAST(case when '+ str(@TotalPrice)+'=1 and '+ str(@Sal2)+'=1 then 
			case when GoodsQuantity=SubUnitQuantity then GoodsPrice else			SubUnitPrice2 end 
			else			
			CASE WHEN  '+ str(@2Qty)+'=0 and '+ str(@2Price)+'=1 THEN SubUnitPrice2    ELSE CASE WHEN  '+ str(@2Qty)+'=0 and ('+ str(@HasDST)+'=1 or '+ str(@Sal2)+'=1 ) THEN SubUnitPrice     ELSE  GoodsPrice    END END END AS float),0) AS PriceNew
			, DiscountDtl+ Case when DiscountTaxOverWorth=0 then 0 else TaxOverWorthCostDtl+TollOverWorthCostDtl end  DiscountDtlAll 
			from inv.tblStorageDocsDtl D			 
			inner JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear			
			'+ @Query3+ '
			)aaaa
		 group by SerialNo ,ProcessID,ProcessNo,FiscalYear,SubUnitID,DocRowNo,
					TaxOverWorthCostDtl,IsReward,CommissionerContractID,GoodsID,DiscountDtl,CurrencyAmount,RowNo,
					IsDiscountTaxOverWorth,QtyNew,PriceNew,DiscountDtlAll
		) D1'
		set @Query5=' --JOINS RET SALE HDR GET KEYS OF SALE
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
		(
		select BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo	,Sum(SGoodsQuantity	)SGoodsQuantity	,Sum(STaxOverWorthCostDtl	)STaxOverWorthCostDtl	,Sum(STollOverWorthCostDtl	)STollOverWorthCostDtl	,Sum(SDiscountDtl)SDiscountDtl
		from(
		
		'+@QryRet+'
		
		)aaa
		group by BaseProcessID	,BaseProcessNo	,BaseFiscalYear	,BaseSerialNo	,BaseDocRowNo
		
		) SSR 
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


		set @Query1=@Query1+@Query2+@Query5
		--print @Query1
		exec sp_executesql @Query1
	end
	
END TRY

BEGIN CATCH
	
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH
END
GO
