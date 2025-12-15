USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\H Sadeghi
-- Create date   : 1399/10/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < پیش فاکتورها برای CRM  >
-- ==============================================
--crm.SpPreSaleDtlForTSCRM 240,1,1399,1
Create PROCEDURE crm.SpPreSaleDtlForTSCRM
	@ProcessID			int=0, 
	@ProcessNo			int=0,
	@FiscalYear			int=0,
	@SerialNo			int=0,
	@UserID             int

WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect nVarchar(max)
	Declare @StrWhere nVarchar(max)
	--declare @UserID				int;
	--SELECT @UserID = isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'UserExternalCRM'	

	--if @UserID=0
		set @UserID=1

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
	SET @StrWhere =  '   AND b.AcntCode in (SELECT  AcntCode FROM  #tblAcntCode    ) '
 
	set @StrSelect='	
			SELECT b.ProcessID,b.ProcessNo,b.FiscalYear,b.SerialNo,RowNo,b.DocDate,b.GoodsID,GoodsName,GoodsQuantity,GoodsAmount
					,b.StoreID,StoreName,pub.GetCodeName(b.AcntCode, 1) AcntNameDtl,DocRowNo
					,b.DiscountPercent DiscountPercentDtl,b.Discount DiscountDtl,b.Discount2 Discount2Dtl,DescDtl,b.DocStep,MainAmount
					,b.SaleTypeID,SaleTypeName,TaxOverWorthCostDtl,TollOverWorthCostDtl,SubUnitQuantity,SubUnitID,IsNull(U.UnitName,'''') As SubUnitName,b.VisitorAcntCode, pub.GetCodeName(b.VisitorAcntCode, 1) VisitorName,b.VisitorPercent,b.VisitorAcntCode2
					,pub.GetCodeName(b.VisitorAcntCode2, 1) VisitorName2,b.VisitorPercent2
					FROM	inv.tblPreSaleDtl  b
					inner join  inv.tblGoodsDtl  g  on b.GoodsID =g.GoodsID and g.LanguageID=1
					Left join  inv.tblStoresDtl s  on b.StoreID =s.StoreID and s.LanguageID=1
					Left join   sal.tblSaleTypesDtl st  on b.SaleTypeID =st.SaleTypeID and st.LanguageID=1
					 Left Join inv.tblUnitsDtl U ON b.SubUnitID = U.UnitID 
			WHERE 	b.SerialNo= '+str(@SerialNo)+ '
			   AND  b.ProcessID='+str(@ProcessID)+ '
			   AND  b.ProcessNo='+str(@ProcessNo)+ '
			   AND  b.FiscalYear='+str(@FiscalYear) + @StrWhere
			
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	  
END
GO
