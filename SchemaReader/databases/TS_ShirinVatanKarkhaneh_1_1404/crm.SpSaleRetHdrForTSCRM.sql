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
-- Description	 : <  فروش کالا برای CRM  >
-- ==============================================
Create PROCEDURE crm.SpSaleRetHdrForTSCRM
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
	 SELECT	Distinct  AcntCode	
		FROM	 inv.tblStorageDocsHdr 
				
	SET @StrWhere=''
		 exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
		SET @StrWhere =  '   AND AcntCode in (SELECT  AcntCode FROM  #tblAcntCode    ) '
		
	SELECT		SerialNo,DocDate,AcntCode,Debit,Credit,RecDesc
		into #tblRemain
	FROM	acc.tblVoucherDtl where 1=0
 
	set @StrSelect='select a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.DocStep,a.DocDate,a.StoreID,s.StoreName,a.AcntCode
						, pub.GetCodeName(a.AcntCode, 1) AcntName,a.VisitorAcntCode, pub.GetCodeName(a.VisitorAcntCode, 1) VisitorAcntName
						,a.Price,a.Amount,a.DiscountPercent,a.Discount,a.Discount2+a.Discount3  Discount2,a.TotalLineDiscount,a.SaleTypeID,t.SaleTypeName
						,a.AfterSaleDiscount,a.TaxOverWorthCost,a.TollOverWorthCost 
						,a.BaseProcessID,a.BaseProcessNo,a.BaseFiscalYear,a.BaseSerialNo,a.BaseDocType,a.VchNo,a.DocDesc
					FROM inv.tblStorageDocsHdr a
						left Join inv.tblStoresDtl	s  on a.StoreID =s.StoreID and s.LanguageID=1	
						left Join sal.tblSaleTypesDtl	t  on a.SaleTypeID =t.SaleTypeID and t.LanguageID=1	
					where ProcessID in (90,100)
'
		if (@AcntCode<> '' and  not (@AcntCode is null))
					set @StrSelect= @StrSelect+ '	AND SUBSTRING(AcntCode,'+str(@PartStart)+' ,'+str(@PartLen)+' ) = '''+@AcntCode+ ''''
		if @FrSerialNo<>0
			set @StrSelect= @StrSelect+ '	AND SerialNo>= '+str(@FrSerialNo)+ ''
		if @ToSerialNo<>0
			set @StrSelect= @StrSelect+ '	AND SerialNo<= '+str(@ToSerialNo)+ ''
		if (@FrDate<> '' and  not (@FrDate is  null))
				set @StrSelect= @StrSelect+ '	and ( DocDate>='''+@FrDate+''' )'
		if (@ToDate<> '' and  not (@ToDate is null))
			set @StrSelect= @StrSelect+ '	and ( DocDate<='''+@ToDate+''' )'
	
		 set @StrSelect= @StrSelect + @StrWhere
			
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	  
END


GO
