USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Alian Pour
-- Create date   : 1403/05/10
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [inv].[sp_api_TakroSystem_IsConfilictGoodsInfo]
@ProcessId as int,
@ProcessNo as int,
@SerialNo as int,
@FiscalYear as int

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @TaxOverWorthPercentInSale as INT
	DECLARE @TollOverWorthPercentInSale INT
	declare @From as int
	declare @To as int
	declare @PartNumber as int
	declare @Len1 as int
	declare @Len2 as int
	declare @Len3 as int
	declare @Len4 as int

BEGIN TRY

	SELECT @TaxOverWorthPercentInSale=SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'TaxOverWorthPercentInSale'

	SELECT @TollOverWorthPercentInSale=SettingValue 
	FROM pub.tblSettings 
	WHERE SettingKey = 'TollOverWorthPercentInSale'


	select @PartNumber=isnull(SettingValue,0) from pub.tblSettings
	where SettingKey = 'UnitPart' AND 1=1

	select @Len1=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' AND PartNumber=1 
	select @Len2=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' AND PartNumber=2
	select @Len3=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' AND PartNumber=3 
	select @Len4=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9 from pub.tblCodeLayer where TableName='inv.tblGoods' AND PartNumber=4
	
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

    --------------------------------------------------UPDATE-------------------------------------------------------

	update 	D
	set SealedTaxRatio = CASE WHEN SealedTaxRatio=0 THEN
		CASE
		WHEN TaxOverWorthCostDtl=0 AND IsReward=0 THEN 0
		WHEN CAST(ISNULL(G.Tax,0)+ISNULL(G.Toll,0) AS DECIMAL)=0  THEN  CAST(@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale AS decimal)
		WHEN CAST(ISNULL(G.Tax ,0)+ISNULL(G.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(G.Tax,0 )+ISNULL(G.Toll,0 ) AS DECIMAL) end
		ELSE SealedTaxRatio END,

	SealedGoodsCID = CASE WHEN SealedGoodsCID='' THEN LTRIM(RTRIM(inv.FunGetGoodsCID( substring(D.GoodsID,@From,@To))))
	ELSE SealedGoodsCID END

	from  inv.tblStorageDocsDtl D
	LEFT JOIN inv.tblGoods G ON G.GoodsID=substring(D.GoodsID,@From,@To) AND G.PartNumber= @PartNumber
	WHERE D.SerialNo=@SerialNo AND D.ProcessID=@ProcessId AND D.ProcessNo=@ProcessNo AND D.FiscalYear=@FiscalYear and (SealedTaxRatio=0 or SealedGoodsCID='' )

	----------------------------------------------------GET--------------------------------------------------------
	
	SELECT 
	G.GoodsID,
	CASE WHEN ISNULL(D.SealedTaxRatio,0)=0 or ISNULL(D.SealedTaxRatio,0)=
	CASE
	WHEN TaxOverWorthCostDtl=0 AND IsReward=0 THEN 0
	WHEN CAST(ISNULL(G.Tax,0)+ISNULL(G.Toll,0) AS DECIMAL)=0  THEN  CAST(@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale AS decimal)
	WHEN CAST(ISNULL(G.Tax ,0)+ISNULL(G.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(G.Tax,0 )+ISNULL(G.Toll,0 ) AS DECIMAL)
	END THEN 0

	WHEN ISNULL(D.SealedTaxRatio,0)<> 0 AND  ISNULL(D.SealedTaxRatio,0)<>
	CASE
	WHEN TaxOverWorthCostDtl=0 AND IsReward=0 THEN 0
	WHEN CAST(ISNULL(G.Tax,0)+ISNULL(G.Toll,0) AS DECIMAL)=0  THEN  CAST(@TaxOverWorthPercentInSale+@TollOverWorthPercentInSale AS decimal)
	WHEN CAST(ISNULL(G.Tax ,0)+ISNULL(G.Toll ,0)AS DECIMAL)<>0 THEN CAST( ISNULL(G.Tax,0 )+ISNULL(G.Toll,0 ) AS DECIMAL)
	END THEN 1
	END IsTaxConfilict,

	CASE 
	WHEN ISNULL(D.SealedGoodsCID,'') = ''  OR  ISNULL(D.SealedGoodsCID,'')=  LTRIM(RTRIM(inv.FunGetGoodsCID( substring(D.GoodsID,@From,@To)))) THEN 0
	WHEN ISNULL(D.SealedGoodsCID,'') <> '' AND ISNULL(D.SealedGoodsCID,'')<> LTRIM(RTRIM(inv.FunGetGoodsCID( substring(D.GoodsID,@From,@To)))) THEN 1
	END IsGoodsCIDConfilict

	from  inv.tblStorageDocsDtl D
	
	LEFT JOIN inv.tblGoods G ON G.GoodsID=substring(D.GoodsID,@From,@To) AND G.PartNumber= @PartNumber
	WHERE D.SerialNo=@SerialNo AND D.ProcessID=@ProcessId AND D.ProcessNo=@ProcessNo AND D.FiscalYear=@FiscalYear


END TRY

BEGIN CATCH
	
	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END	

GO
