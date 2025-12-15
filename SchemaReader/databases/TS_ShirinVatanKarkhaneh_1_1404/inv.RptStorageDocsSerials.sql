USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Hamid
-- Create date   : 393/08/15
-- Viewed By	 : 
-- Last Modified : 1393/08/15
-- Last Modifier : TakroSystem/Hamid
-- Description   : برگ سفارش خرید کالا
-- =============================================
Create PROCEDURE inv.RptStorageDocsSerials
	@ProcessID		Int = 0,
	@ProcessNo		Int = 0,
	@FiscalYear		Int = 0,
	@SerialNo		Int = 0,
	@DocRowNo  		Int = 0
	--,
	--@ExtraParams		NVarChar(Max) = '',
	--@RepInfo			NVarChar(100) = '1@1@1',
	--@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS
BEGIN

if @ProcessID=0
	select  *,CAST('' as varchar(4000)) AllSerials,CAST('' as varchar(4000)) Serials,CAST('' as varchar(4000)) SerialCID FROM    inv.tblStorageDocsSerials  
else
BEGIN
	SELECT  *,CAST('' as varchar(4000)) AllSerials ,CAST('' as varchar(4000)) Serials,CAST('' as varchar(4000)) SerialCID
	into #AllSerials 
	FROM    inv.tblStorageDocsSerials  
	where  ProcessID=@ProcessID 
		and ProcessNo=@ProcessNo 
		and FiscalYear=@FiscalYear 
		and SerialNo=@SerialNo 
		and DocRowNo=@DocRowNo 
 
	DECLARE @strSNSum varchar(4000)
	DECLARE @strSNSum1 varchar(4000)
	DECLARE @strSNSum2 varchar(4000)
	SET @strSNSum=''
	SET @strSNSum1=''
	SET @strSNSum2=''

 	SELECT 
	@strSNSum = COALESCE(@strSNSum + ' - ', ' ') + PSerialNo + CASE WHEN b.PSerialCID<>'' THEN '('+ PSerialCID+ ')' ELSE '' END
	,@strSNSum1 = COALESCE(@strSNSum1 + ' - ', ' ') + PSerialNo 
	,@strSNSum2 = COALESCE(@strSNSum2 + ' - ', ' ') + PSerialCID
	FROM   inv.tblStorageDocsSerials a
	LEFT JOIN    [pln].[tblProductSerials] b
	on a.ProductSerialID=b.ProductSerialID
	WHERE a.ProcessID=@ProcessID 
	  and a.ProcessNo=@ProcessNo 
	  and a.FiscalYear=@FiscalYear 
	  and a.SerialNo=@SerialNo 
	  and a.DocRowNo=@DocRowNo 
	IF LEN(@strSNSum)> 0
		SEt @strSNSum = SUBSTRING(@strSNSum,4,LEN(@strSNSum))
	IF LEN(@strSNSum1)> 0
		SEt @strSNSum1 = SUBSTRING(@strSNSum1,4,LEN(@strSNSum1))
	IF LEN(@strSNSum2)> 0
		SEt @strSNSum2 = SUBSTRING(@strSNSum2,4,LEN(@strSNSum2))
	
	UPDATE #AllSerials
	SET AllSerials=@strSNSum
	,Serials=@strSNSum1
	,SerialCID=@strSNSum2
	FROM #AllSerials
	 
	SELECT * FROM #AllSerials
 END
END
GO
