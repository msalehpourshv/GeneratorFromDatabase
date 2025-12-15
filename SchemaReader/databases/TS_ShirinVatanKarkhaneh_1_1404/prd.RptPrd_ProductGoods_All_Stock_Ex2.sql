USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/25
-- Viewed By	 : 
-- Last Modified : 1390/05/04
-- Last Modifier : TakroSystem\Zia
-- Description	 : برای تولید مواد اولیه جهت انتقال کالا
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_ProductGoods_All_Stock_Ex2]
	@ProductID			varchar(20) = null, -- not used
	@ProductQuantity	float = 0,          -- not used        
	@FormulaNo			int = 0,
	@ToDate				char(10),
	@RepOptions		varchar(10) = '101',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
declare	@LangID		char(1);
declare	@SessionNo	int; 
declare	@ReportID	int; 
declare	@UserID		int; 

Begin
	set NOCOUNT ON;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	

	create table #tbl_Inner
	(
		GoodsID		varchar(20) collate arabic_cs_as not null,
		Quantity	float not null,
		Balance		float not null,
		GoodsName	nvarchar(100) not null,
		UnitID		varchar(20) collate arabic_cs_as not null,
		UnitName	nvarchar(100) not null,
		SumCMR		float not null,
		SumBuy		float not null,
		LastAmount	float not null
	);
	
	SELECT d.ProductID,(d.GoodsQuantity/h.ProductCount)*@ProductQuantity as Quantity,
		   d.GoodsID,h.SerialNo,[pub].[funGetGoodsName](d.GoodsID,1) As GoodsName, 
		   d.UnitID,inv.funGetUnitName(UnitID,1)UnitName,
	       inv.funGetGoodsRemain(null,null,null,null,null,null,d.GoodsID,null,@ToDate,0)Balance
    FROM prd.tblFormulasDtl d
	INNER JOIN prd.tblFormulasHdr h	ON d.ProductID=h.ProductID and d.SerialNo=h.SerialNo
	WHERE d.ProductID=@ProductID and h.SerialNo=@FormulaNo
	---------------------------------------------------------------------------

End
GO
