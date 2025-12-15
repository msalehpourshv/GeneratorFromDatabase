USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1394/02/17
-- Viewed By	 : 
-- Last Modified : 1394/02/17
-- Last Modifier : TakroSystem\Zia
-- Description	 : برای تولید مواد اولیه جهت انتقال کالا
-- ==============================================
Create PROCEDURE [prd].[RptPrd_ProductGoods_All_Stock_Ex4]
	@SerialsNoList	varchar(100)='6731,7624',
	@ToDate			char(10) = '1394/04/01',
	@RepOptions		varchar(10) = '101',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@StrCommand	nvarchar(max);
declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@ReportID	int; 
declare	@UserID		int; 

declare	@ProductID1			varchar(20)  -- not used
declare	@ProductQuantity1	float         -- not used        
declare	@FormulaNo1			int

Begin
	set NOCOUNT ON;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	
	create table #tbl_Prd_ProductGoods_All_Stock_Ex3_Temp
	(
		ProductID	varchar(20) collate arabic_cs_as,
		ProductQty	float,
		StoreID		varchar(20) collate arabic_cs_as not null,
		FormulaNo	int,
		ProcessID	int,
		ProcessNo	int,
		FiscalYear	int,
		SerialNo	int,
		DocRowNo	int,
		BaseFiscalYear	int,
		BaseSerialNo	int
		
	)

	if   CHARINDEX ('/', @SerialsNoList)>0 
		begin
			set @SerialsNoList= replace ( @SerialsNoList,',',''',''')	
			set @SerialsNoList= ''''+ @SerialsNoList+ ''''
			set @StrCommand = '
				insert into #tbl_Prd_ProductGoods_All_Stock_Ex3_Temp(ProductID, ProductQty,StoreID, FormulaNo,
				ProcessID ,ProcessNo,FiscalYear,SerialNo,BaseFiscalYear,BaseSerialNo)
				select ProductID, OrderCount,UsageStoreID, FormulaNo,ProcessID ,ProcessNo,FiscalYear,SerialNo,BaseFiscalYear,BaseSerialNo
				from pln.tblTaskOrderHdr
				where  Cast(FiscalYear as char(4))+''/''+  cast(SerialNo  as nvarchar(10)) in (' + @SerialsNoList + ') '
		end 
	else
		begin	 
			set @StrCommand = '
				insert into #tbl_Prd_ProductGoods_All_Stock_Ex3_Temp(ProductID, ProductQty,StoreID, FormulaNo,
				ProcessID ,ProcessNo,FiscalYear,SerialNo,BaseFiscalYear,BaseSerialNo)
				select ProductID, OrderCount,UsageStoreID, FormulaNo,ProcessID ,ProcessNo,FiscalYear,SerialNo,BaseFiscalYear,BaseSerialNo
				from pln.tblTaskOrderHdr
				where SerialNo in (' + @SerialsNoList + ') '
		end 
	print @StrCommand
	exec sp_executesql @StrCommand
	
	select T.*, [pub].[funGetGoodsName](T.GoodsID, @LangID) As GoodsName, 
		   [pub].[funGetGoodsUnitName] (T.GoodsID, @LangID) As UnitName,
		   inv.funGetGoodsRemain(null,null,null,null,null,null,
		   T.GoodsID,null,@ToDate,0) as Balance
			
						
	from
	(
		select	X.GoodsID, X.UnitID, (Quantity) Quantity,
		X.ProcessID ,X.ProcessNo,X.FiscalYear,X.SerialNo,X.StoreID,X.BaseFiscalYear,X.BaseSerialNo
		
		
		from
		(
			select	D.GoodsID, D.UnitID,
					(D.GoodsQuantity/H.ProductCount) * T.ProductQty as Quantity,
			T.ProcessID ,T.ProcessNo,T.FiscalYear,T.SerialNo,T.BaseFiscalYear,T.BaseSerialNo ,T.StoreID 
			from prd.tblFormulasDtl D
				inner join prd.tblFormulasHdr H 
				on D.ProductID=H.ProductID and D.SerialNo=H.SerialNo
				inner join #tbl_Prd_ProductGoods_All_Stock_Ex3_Temp T 
				on T.ProductID =D.ProductID and T.FormulaNo=D.SerialNo
		 ) X
		 --group by X.GoodsID, X.GoodsID, X.UnitID 
	 ) T
	---------------------------------------------------------------------------
End
GO
