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
--[inv].[sp_api_TakroSystem_GetRetSaleDtlForPos]100,1,1,1404,10,0,1,1,6
CREATE PROCEDURE [inv].[sp_api_TakroSystem_GetRetSaleDtlForPos]
@ProcessId	AS INT,
@ProcessNo	AS INT,
@SerialNo	AS INT,
@FiscalYear AS INT,
@TaxOverWorthPercentInSale AS INT,
@TollOverWorthPercentInSale AS INT,
@PartNumber AS INT,
@FROM AS INT ,
@To AS INT 

WITH ENCRYPTION
 AS
BEGIN

	BEGIN --DUPLICATE QUERY
	
	DECLARE @QryRet NVARCHAR(MAX)
	DECLARE @QryRet1 NVARCHAR(MAX)

	DECLARE @BaseProcessId	AS INT
	DECLARE @BaseProcessNo	AS INT
	DECLARE @BaseSerialNo	AS INT
	DECLARE @BaseFiscalYear AS INT

	DECLARE @PriceQuery AS NVARCHAR(MAX)='ISNULL(CAST(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 AND G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END 
					AS DECIMAL(28,7)),0)'

	DECLARE @QtyQuery AS NVARCHAR(MAX)='ISNULL(ROUND( CAST(GoodsQuantity AS float),7,0),0)'

	DECLARE @GoodsJoinQuery AS NVARCHAR(MAX)='LEFT JOIN inv.tblGoods G 
						 ON  G.GoodsID=SUBSTRING(D.GoodsID,'+ str(@FROM)+','+ str(@To)+')
						 AND G.PartNumber='+ str(@PartNumber)+''

	DECLARE @JoinTaxOverWorhQuery AS NVARCHAR(MAX) = '('+@PriceQuery+'*'+@QtyQuery+'-DiscountDtl)- 
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

	DECLARE @TaxOverWorhQuery  AS NVARCHAR(MAX)= 'CAST(FLOOR(
	(MainPrice*QtyNew-DiscountDtl)- ((MainPrice*QtyNew-DiscountDtl)/
	CASE 
	WHEN G.Tax<>0 THEN 100+G.Tax
	WHEN G.NotContainTax=1 THEN 1
	WHEN G.NotContainTax=0 AND G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
	END  * 
	CASE 
	WHEN G.NotContainTax=1 THEN 1
	WHEN G.NotContainTax=0 THEN 100
	END )) AS DECIMAL(28,0))'

	DECLARE @edJoin nvarchar(max)=
'					INNER JOIN 
						(SELECT  D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,
							SUM((D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 AND G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )
						    *GoodsQuantity-DiscountDtl) AS TotalAmount
						 FROM inv.tblStorageDocsDtl D
						 INNER JOIN inv.tblGoods G  ON D.GoodsID=G.GoodsID
						 INNER JOIN inv.tblStorageDocsHdr H 
						 ON D.ProcessID =H.ProcessID  AND D.ProcessNo=H.ProcessNo AND D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo 
						 WHERE (Discount+Discount2+Discount3)> 0 AND  NotDiscount = 0 AND 
							(D.GoodsPrice/
							CASE WHEN G.Tax<>0 THEN 100+G.Tax
							WHEN G.NotContainTax=1 THEN 1
							WHEN G.NotContainTax=0 AND G.Tax=0 THEN 100+'+str(@TaxOverWorthPercentInSale)+'+'+str(@TollOverWorthPercentInSale)+'
							END  * 
							CASE WHEN G.NotContainTax=1 THEN 1 WHEN G.NotContainTax=0 THEN 100 END )*
						    GoodsQuantity-DiscountDtl<>0-- فقط رکوردهایی که شامل سرشکن می‌شوند
						 GROUP BY D.ProcessID,D.ProcessNo,D.FiscalYear,D.SerialNo,D.BranchID
						 ) ed ON D.ProcessID =ed.ProcessID  AND D.ProcessNo=ed.ProcessNo AND D.FiscalYear=ed.FiscalYear AND D.SerialNo=ed.SerialNo '

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
					'FROM (     SELECT  SUM(DistributedDiscount)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo order by ProcessID,ProcessNo,FiscalYear,SerialNo) TotalDistributedDiscount,
				   MAX(R)over(partition by ProcessID,ProcessNo,FiscalYear,SerialNo order by ProcessID,ProcessNo,FiscalYear,SerialNo) MaxRow,* '

	END

	SELECT  
	@BaseProcessId=BaseProcessID,@BaseSerialNo=BaseSerialNo,@BaseProcessNo=BaseProcessNo,@BaseFiscalYear=BaseFiscalYear 
	FROM inv.tblStorageDocsHdr
	WHERE ProcessID=@ProcessId AND SerialNo=@SerialNo AND ProcessNo=@ProcessNo AND FiscalYear =@FiscalYear;

	set @QryRet='
		SELECT  
		CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
					  ELSE DistributedDiscount END +DiscountDtl MainDiscount
					  ,*
						'+@FromSelectD2+'
							'+@FromSelectD1+'
									'+@JoinTaxOverWorhQuery+' AS TaxOverWorthCostDtl,
									'+@QtyQuery+' AS  QtyNew,	
									'+@PriceQuery+' AS PriceNew,
									ISNULL(CAST(D.GoodsPrice  AS DECIMAL(28,7)),0) AS MainPrice,
									DiscountDtl AS DiscountDtlAll, 
									D.BaseProcessID,D.BaseSerialNo,D.BaseProcessNo,D.BaseFiscalYear,D.BaseDocRowNo,D.GoodsQuantity,
									D.GoodsPrice
									FROM inv.tblStorageDocsDtl D '
	set @QryRet1='
									'+@GoodsJoinQuery+'
									'+@edJoin+'
									INNER JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear
							)D
						)D
						WHERE ProcessID=100 AND BaseProcessID='+STR(@BaseProcessId)+' AND BaseSerialNo= '+STR(@BaseSerialNo)+'
						AND BaseProcessNo= '+STR(@BaseProcessNo)+' AND BaseFiscalYear='+STR(@BaseFiscalYear)

BEGIN --CHECK FISCALYEAR

	DECLARE @DBNAMEOld as varchar(100)
	DECLARE @MainDBNAME AS VARCHAR(100)= db_name()
	SELECT  @DBNAMEOld=SUBSTRING (@MainDBNAME,1 , LEN(@MainDBNAME)-4)+ ltrim(str(SUBSTRING (@MainDBNAME,LEN(@MainDBNAME)-3 ,4)-1))

	if exists (select * from master.sys.databases where name=@DBNAMEOld) and @MainDBNAME<>@DBNAMEOld
	BEGIN
	
		set @QryRet=@QryRet +'
		UNION All
		SELECT  
			CASE WHEN MaxRow=R THEN DistributedDiscount+(DiscountAmount-TotalDistributedDiscount) 
					  ELSE DistributedDiscount END +DiscountDtl DistributedDiscount
					  ,*
				'+@FromSelectD2+'
					'+@FromSelectD1+'
							'+@JoinTaxOverWorhQuery+' AS TaxOverWorthCostDtl,
							'+@QtyQuery+' AS  QtyNew,	
							'+@PriceQuery+' AS PriceNew,
							ISNULL(CAST(D.GoodsPrice  AS DECIMAL(28,7)),0) AS MainPrice,
							DiscountDtl AS DiscountDtlAll , BaseProcessID,BaseSerialNo,BaseProcessNo,BaseFiscalYear
							FROM inv.tblStorageDocsDtl D
							'+@GoodsJoinQuery+'
							'+@edJoin+'
							INNER JOIN inv.tblStorageDocsHdr H ON H.SerialNo=D.SerialNo AND H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear
					)D
				)D
				WHERE ProcessID=100 AND BaseProcessID='+STR(@BaseProcessId)+' AND BaseSerialNo= '+STR(@BaseSerialNo)+'
				AND BaseProcessNo= '+STR(@BaseProcessNo)+' AND BaseFiscalYear='+STR(@BaseFiscalYear)

	END

END 

print @QryRet
print @QryRet1
SET @QryRet = @QryRet + @QryRet1
exec sp_executesql @QryRet 
END
GO
