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
-- ==============================================r
create PROCEDURE [pln].[RptPln__InProductGoods]
	@StoreID		varchar(20)='888',
	@ToDate			char(10) = '1394/02/31',
	@ProuductID		varchar(20)=null,
	@RepOptions		varchar(100) = '101',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS

declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@ReportID	int; 
declare	@UserID		int; 
declare	@strSelect		nvarchar(max); 
declare	@strWhere		nvarchar(4000); 
declare	@ProducerAcntCode		varchar(20); 

Begin
	set NOCOUNT ON;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	
	set @ProducerAcntCode= pub.funSplitString(@RepOptions, '@', 1);
	

set @strWhere= ' 1=1  AND p.TaskStateID in (3,2,7) '
 
 If @ProuductID is not null
		SET @strWhere = @strWhere + ' AND  p.ProductID=''' + @ProuductID + ''''
If @ToDate is not null
		SET @strWhere = @strWhere + ' AND  p.DocDate <=''' + @ToDate + ''''

If @ProducerAcntCode is not null and @ProducerAcntCode <> ''
		SET @strWhere = @strWhere + ' AND  p.ProducerAcntCode =''' + @ProducerAcntCode + ''''
		
	---------------------------------------------------------------------------
	
set @strSelect='SELECT distinct p.SerialNo,p.FiscalYear, 
p.ProductID,f.GoodsID,f.GoodsQuantity,fh.ProductCount ,p.OrderCount,
pub.GetGoodsName(f.GoodsID,1) GoodsName,pub.GetGoodsName(f.ProductID,1) ProductName,
[inv].[funGetGoodsRemain](null,null,null,null,null,'''+ @StoreID +''',f.GoodsID,null,'''+ @ToDate +''',0) Remain,

(
	SELECT ISNULL(SUM(GoodsQuantity),0) from inv.tblStorageDocsDtl d
	WHERE d.ProcessID=125 AND p.ProcessID=d.BaseProcessID and p.ProcessNo=d.BaseProcessNo
	and p.FiscalYear=d.BaseFiscalYear and p.SerialNo=d.BaseSerialNo
)Qty

 FROM  pln.tblTaskOrderHdr p
	INNER JOIN prd.tblFormulasDtl f
	ON p.ProductID=f.ProductID AND f.SerialNo=p.FormulaNo
	INNER  JOIN prd.tblFormulasHdr fh
	ON fh.ProductID=f.ProductID AND fh.SerialNo= f.SerialNo

WHERE ' + @strWhere



	-- RUN -------------------------------------------------------
	PRINT @strSelect;
	EXEC sp_executesql @strSelect;
	--------------------------------------------------------------

 
	 
End
GO
