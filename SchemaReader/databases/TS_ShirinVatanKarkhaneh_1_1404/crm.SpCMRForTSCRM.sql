USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1398/09/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : <  درخواست خرید کالا برای CRM  >
-- ==============================================
Create PROCEDURE crm.SpCMRForTSCRM
	@AcntCode			Varchar(20), 
	@FrSerialNo			int,
	@ToSerialNo			int,
	@FrDate				char(10),
	@ToDate				char(10)
WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect nVarchar(max)
	Declare @StrWhere nVarchar(max)
	declare @UserID				int;
	SELECT @UserID = isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'UserExternalCRM'	

	if @UserID=0
		set @UserID=-1

	declare @PartNumber				int;
	declare @PartStart				int;
	declare @PartLen				int;
	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)
	select @PartStart=[acc].[FunGetAcntInfoForRemain](2)
	select @PartLen=[acc].[FunGetAcntInfoForRemain](3)

	BEGIN TRY
			DROP TABLE #tblAcntCode
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)

	 Insert into  #tblAcntCode (AcntCode) 
	 SELECT	Distinct a.AcntCode	
		FROM	cmr.tblCMRDtl  b
					inner join cmr.tblCMRHdr a
					on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and  a.FiscalYear=b.FiscalYear and  a.SerialNo=b.SerialNo
	SET @StrWhere=''
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		SET @StrWhere =  '   AND a.AcntCode in (SELECT  AcntCode FROM  #tblAcntCode    ) '
		
	SELECT		SerialNo,DocDate,AcntCode,Debit,Credit,RecDesc
		into #tblRemain
	FROM	acc.tblVoucherDtl where 1=0
 
	set @StrSelect='	
			SELECT 
			
			b.ProcessID	,b.ProcessNo	,b.FiscalYear	,b.SerialNo	,b.RowNo	,b.DocRowNo	,b.DocStep	,b.DocDate	,b.AcntCode	,b.GoodsID	,b.SubUnitID	,b.SubUnitQuantity	,b.ConfirmQuantity	,b.GoodsQuantity	,b.DescDtl	,b.OrderDate	,b.BaseProcessID	,b.BaseProcessNo	,b.BaseFiscalYear	,b.BaseSerialNo	,b.BaseDocRowNo	,b.BaseDocDate	,b.Priority	,b.DescDtl2
			,GoodsName,GoodsQuantity
					,a.AcntCode, pub.GetCodeName(a.AcntCode, 1) AcntName,b.AcntCode AcntCodeDtl,pub.GetCodeName(b.AcntCode, 1) AcntNameDtl
					,DescDtl,b.DocStep 
					,  SubUnitQuantity,SubUnitID,IsNull(U.UnitName,'''') As SubUnitName
					
					FROM	cmr.tblCMRDtl  b
					inner join cmr.tblCMRHdr a	on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and  a.FiscalYear=b.FiscalYear and  a.SerialNo=b.SerialNo
					inner join  inv.tblGoodsDtl  g  on b.GoodsID =g.GoodsID and g.LanguageID=1
					 Left Join inv.tblUnitsDtl U ON b.SubUnitID = U.UnitID 
			WHERE 	1=1 '
		if (@AcntCode<> '' and  not (@AcntCode is null))
					set @StrSelect= @StrSelect+ '	AND SUBSTRING(a.AcntCode,'+str(@PartStart)+' ,'+str(@PartLen)+' ) = '''+@AcntCode+ ''''
		if @FrSerialNo<>0
			set @StrSelect= @StrSelect+ '	AND a.SerialNo>= '+str(@FrSerialNo)+ ''
		if @ToSerialNo<>0
			set @StrSelect= @StrSelect+ '	AND a.SerialNo<= '+str(@ToSerialNo)+ ''
		if (@FrDate<> '' and  not (@FrDate is  null))
				set @StrSelect= @StrSelect+ '	and ( a.DocDate>='''+@FrDate+''' )'
		if (@ToDate<> '' and  not (@ToDate is null))
			set @StrSelect= @StrSelect+ '	and ( a.DocDate<='''+@ToDate+''' )'
	
		 set @StrSelect= @StrSelect + @StrWhere
			
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	  
END


GO
