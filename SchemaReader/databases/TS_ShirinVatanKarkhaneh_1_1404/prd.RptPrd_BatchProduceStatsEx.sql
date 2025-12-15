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
-- Description   : <ارسال یک بچ>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_BatchProduceStatsEx]
	@BatchNo		nvarchar(20) = null,
	@DateFrom			Char(10) = Null,
	@DateTo				Char(10) = Null,
	@ExtraParams		NVarChar(200) = '-1@-1@-1@-1@-1@-1@-1@-1',
	@RepOptions		varchar(10) = '',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(2000)
DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@DecReturn	bit
BEGIN
	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@BatchNo		Is Null)	set @BatchNo = '';

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @DecReturn		= pub.funSplitString(@ExtraParams, '@', 1);

	SET @StrWhere='  And 1=1'
	If @DateFrom Is Not Null
		SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DateFrom + ''''
	If @DateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DateTo + ''''

	If @BatchNo Is Not Null
		SET @StrWhere = @StrWhere + ' AND H.BatchNo = ''' + @BatchNo + ''''
	
	
--	set @Qty = Substring(@RepOptions, 1, 1);
--	set @Prc = Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------
	-- where section ----------------------------------------------------------

	-- select section ---------------------------------------------------------
if @DecReturn='False '	
	SET @StrSelect='	
	SELECT T.*, [pub].[funGetGoodsName](T.GoodsID, ' + LTrim(RTrim(@LangID)) + ') As GoodsName
	FROM
	(
		SELECT	D.GoodsID, 
				isnull(sum(D.GoodsQuantity), 0) SumQuantity, 
				isnull(sum(D.GoodsQuantity*D.GoodsPrice), 0) SumPrice,
				isnull(sum(D.GoodsQuantity*D.GoodsAmount), 0) SumAmount
		FROM	inv.tblStorageDocsDtl D
					inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
		WHERE	(H.ProcessID in (70,82,83))'+ @StrWhere +'
		GROUP BY D.GoodsID
	) T	
	ORDER BY GoodsID'
else

	SET @StrSelect='
	SELECT T1.GoodsID,
		T1.SumQuantity- isnull(T2.SumQuantity,0) SumQuantity  ,
		T1.SumPrice-isnull( T2.SumPrice,0) SumPrice  ,
		T1.SumAmount- isnull(T2.SumAmount,0) SumAmount  , [pub].[funGetGoodsName](T1.GoodsID, ' + LTrim(RTrim(@LangID)) + ') As GoodsName
	FROM
	(
		SELECT	D.GoodsID, 
				isnull(sum(D.GoodsQuantity), 0) SumQuantity, 
				isnull(sum(D.GoodsQuantity*D.GoodsPrice), 0) SumPrice,
				isnull(sum(D.GoodsQuantity*D.GoodsAmount), 0) SumAmount
		FROM	inv.tblStorageDocsDtl D
					inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
		WHERE	(H.ProcessID in (70,82,83))'+ @StrWhere +'
		GROUP BY D.GoodsID
	) T1
	left join 	
	(
		SELECT	D.GoodsID, 
				isnull(sum(D.GoodsQuantity), 0) SumQuantity, 
				isnull(sum(D.GoodsQuantity*D.GoodsPrice), 0) SumPrice,
				isnull(sum(D.GoodsQuantity*D.GoodsAmount), 0) SumAmount
		FROM	inv.tblStorageDocsDtl D
					inner join inv.tblStorageDocsHdr H on H.ProcessID = D.ProcessID and H.ProcessNo = D.ProcessNo and H.FiscalYear = D.FiscalYear and H.SerialNo = D.SerialNo
		WHERE	(H.ProcessID = 75)'+ @StrWhere +'
		GROUP BY D.GoodsID
	) T2  on T1.GoodsID=T2.GoodsID
	ORDER BY GoodsID'

	Print @StrSelect;	
	EXEC sp_executesql @StrSelect;
END
GO
