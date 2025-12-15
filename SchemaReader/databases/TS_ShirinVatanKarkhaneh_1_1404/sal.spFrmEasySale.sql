USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1401-01-10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < فروش خورا دام و طیور مشخصات مشتری>
-- ==============================================
Create PROCEDURE sal.spFrmEasySale
	@CallType			int,
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrSelect		NVarChar(Max)
	declare @AcntCode		varchar(20)
	declare @PartNumber		int
	Declare @StartLayer		TINYINT;
	Declare @LayerLen		TINYINT;
	declare @PartType		int

	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	select @StartLayer=[acc].[FunGetAcntInfoForRemain](2)
	select @LayerLen=[acc].[FunGetAcntInfoForRemain](3)

if @CallType=1
begin	
	SET @AcntCode		= pub.funSplitString(@ExtraParams, '@', 1);
	SET @PartType		= pub.funSplitString(@ExtraParams, '@', 2);

	SET @StrSelect = ' Select NationalIDNumber, ''موبایل : ''+Mobile +    ''     آدرس : '' + Address1   AcntInfo
	From acc.tblAcnt  a
	inner join acc.tblAcntDtl  b on a.AcntCode=b.AcntCode and a.PartNumber=b.PartNumber
	where a.AcntCode		=''' + @AcntCode+ ''' and  a.PartNumber='+ str(@PartNumber)
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

end
	 
if @CallType=2
begin	
	SET @AcntCode		= pub.funSplitString(@ExtraParams, '@', 1);

	SET @StrSelect = ' Select  ltrim(rtrim(str(a.FiscalYear)))+''/''+ ltrim(rtrim(str(a.SerialNo))) SerialNo, a.DocDate DocDate , a.Amount Amount 
	,GoodsID  ,pub.funGetGoodsName (GoodsID,1)  GoodsName,cast( SubUnitQuantity as float ) SubUnitQuantity ,GoodsPrice 
	From inv.tblStorageDocsHdr a 
	inner join inv.tblStorageDocsDtl b
	on a.ProcessID=b.ProcessID 
		and a.ProcessNo=b.ProcessNo
		and a.FiscalYear=b.FiscalYear
		and a.SerialNo=b.SerialNo
	where   substring(a.AcntCode,'+str(@StartLayer)+','+str(@LayerLen)+')= ''' + @AcntCode+ ''' and a.ProcessNo=2
	order by a.DocDate Desc 
	'
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

end

if @CallType=3
begin	
	SET @AcntCode		= pub.funSplitString(@ExtraParams, '@', 1);

	SET @StrSelect = 'select 
						FlockTypeName [طیور] , Quantity [تعداد] from sal.tblFlockDtl D
	                    inner join  sal.tblFlockTypeDtl F  on D.FlockTypeID=F.FlockTypeID and LanguageID=1
						where SerialNo = (
						select top 1 isnull(SerialNo,0) from sal.tblFlockHdr  
						where AcntCode=''' + @AcntCode+ '''  
						order by DocDate desc , SerialNo Desc 
						) 
						and  AcntCode=''' + @AcntCode+ '''  '
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

end

END
GO
