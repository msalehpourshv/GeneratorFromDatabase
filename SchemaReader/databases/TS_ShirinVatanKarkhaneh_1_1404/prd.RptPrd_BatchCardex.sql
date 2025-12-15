USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/01/28
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <گردش یک بچ>
-- =================================================================
CREATE PROCEDURE [prd].[RptPrd_BatchCardex]
	@BatchNo		nvarchar(20) = null,
	@RepOptions		varchar(10) = '11',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

BEGIN
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '11';
	if (@BatchNo		Is Null)	set @BatchNo = '';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

--	set @Qty = Substring(@RepOptions, 1, 1);
--	set @Prc = Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------

	-- select section ---------------------------------------------------------
	select	D.FiscalYear, D.SerialNo, D.DocDate,D.VolumeRowNo, D.ProcessID, P.ProcessName, D.GoodsID, 
			[pub].[funGetGoodsName](D.GoodsID, @LangID) As GoodsName, D.GoodsQuantity, 
			D.EnterKind, D.GoodsAmount, D.GoodsPrice, D.BatchNo,D.StoreID  ,[pub].[GetStoreName](D.StoreID,@LangID) StoreName
	from	inv.tblStorageDocsDtl D
				inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
				left join pub.tblProcess P on P.ProcessID = D.ProcessID and P.ProcessNo = D.ProcessNo
	where	(D.BatchNo = @BatchNo) Or (H.BatchNo = @BatchNo)
	order By FiscalYear,D.DocDate,D.VolumeRowNo
END
GO
