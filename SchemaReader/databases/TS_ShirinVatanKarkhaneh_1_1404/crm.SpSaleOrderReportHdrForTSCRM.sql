USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H.Sadeghi
-- Create date   : 1400/08/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < سفارش فروش برای CRM  >
-- ==============================================
-- crm.SpSaleOrderReportHdrForTSCRM
Create PROCEDURE crm.SpSaleOrderReportHdrForTSCRM
	@AcntCode			Varchar(20)=NULL, 
	@FrSerialNo			int=NULL,
	@ToSerialNo			int=NULL,
	@FrDate				char(10)=NULL,
	@ToDate				char(10)=NULL,
	@UserID				int

WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect nVarchar(max)
	Declare @StrWhere nVarchar(max)

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
	CREATE TABLE #tblAcntCode(AcntCode 	Varchar(20)collate arabic_cs_as null)

	Insert into  #tblAcntCode (AcntCode) 
	SELECT	Distinct a.AcntCode
	FROM	inv.tblPreSaleDtl a
	
	SET @StrWhere=''
	exec pub.SpFilterByPermission2 '#tblAcntCode', 'AcntCode', 'acc.tblAcnt', @UserID;
	SET @StrWhere =  '   AND a.AcntCode in (SELECT  AcntCode FROM  #tblAcntCode    ) '

		
	SELECT		SerialNo,DocDate,AcntCode,Debit,Credit,RecDesc
		into #tblRemain
	FROM	acc.tblVoucherDtl where 1=0
 
	set @StrSelect='	
			SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.DocDate
					,a.StoreID,StoreName,a.AcntCode, pub.GetCodeName(a.AcntCode, 1) AcntName,a.DocStep
					,a.SaleTypeID,isnull(SaleTypeName,'''') SaleTypeName,a.VisitorAcntCode, pub.GetCodeName(a.VisitorAcntCode, 1) VisitorName,a.VisitorPercent
					,a.VisitorAcntCode2,pub.GetCodeName(a.VisitorAcntCode2, 1) VisitorName2,a.VisitorPercent2
					,a.DiscountPercent	,a.Discount	,a.Discount2,a.TransportationCost	,a.TransportationIncome	
					,a.PackingCost	,a.TaxCost	,a.TaxOverWorthCost	,a.OtherCost	,a.OtherIncome	,a.TollOverWorthCost	
					,a.EarnestMoney	,a.EarnestMoneyPercent	,a.EarnestMoneyAcntCode	,a.Price	,a.Amount
			FROM sal.tblSaleOrderHdr a	
			Left join  inv.tblStoresDtl s  on a.StoreID =s.StoreID and s.LanguageID=1
			Left join   sal.tblSaleTypesDtl st  on a.SaleTypeID =st.SaleTypeID and st.LanguageID=1
			WHERE 	ProcessID=180 '
		
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
