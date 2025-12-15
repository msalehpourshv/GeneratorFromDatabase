USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1399/03/18
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : <  خدمات برای CRM  >
-- ==============================================
Create PROCEDURE crm.SpServiceForTSCRM
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
			DROP TABLE #tblServiceID
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	 Insert into  #tblAcntCode (AcntCode) 
	 SELECT	Distinct a.AcntCode	FROM	acc.tblServicesHdr a

 CREATE TABLE #tblServiceID
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)
	
	 Insert into  #tblServiceID (AcntCode) 
		SELECT	Distinct ServiceID	FROM	acc.tblServicesDtl  
	
 
 					
	SET @StrWhere=''
	 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
	SET @StrWhere =  '   AND a.AcntCode in (SELECT  AcntCode FROM  #tblAcntCode    ) '
		
	 exec pub.SpFilterByPermission2 '#tblServiceID', 'AcntCode', 'acc.tblAcnt', @UserID;
	SET @StrWhere = @StrWhere+ '   AND b.ServiceID in (SELECT  AcntCode FROM  #tblServiceID    ) '

	set @StrSelect='	
			SELECT 
				a.SerialNo	,a.DocDate	,a.AcntCode	,a.DescHdr	,a.ServiceDiscount	,a.TaxOverWorthAcntCode	,a.TaxOverWorthCost	,a.VchNo	,a.DiscountAcntCode	 ,a.VchDate	,a.ExpertCode	,a.ProcessID	,a.ProcessNo	,a.FiscalYear	,a.TollOverWorthAcntCode	,a.TollOverWorthCost	,a.CashAmount	,a.ChequeAmount	,a.DiscountPercent	,a.VisitorAcntCode	,a.VisitorPercent	,a.TaskTax	,a.TaskTaxAcntCode	,a.DocStep	,a.Amount	,a.Price
				,b.RowNo	,b.ServiceID	,b.DescDtl	,b.ServiceQuantity	,b.ServiceAmount	,b.DocRowNo	,b.DiscountPercentDtl	,b.DiscountDtl	,b.DueDate	,b.DocStep
				, pub.GetCodeName(a.AcntCode, 1) AcntName, pub.GetCodeName(a.VisitorAcntCode, 1) VisitorName
			FROM	acc.tblServicesDtl  b
				inner join acc.tblServicesHdr a	on a.ProcessID=b.ProcessID and  a.ProcessNo=b.ProcessNo and  a.FiscalYear=b.FiscalYear and  a.SerialNo=b.SerialNo
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
