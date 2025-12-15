USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/11/16
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 1388/09/21
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : لیست تفکیکی سفارشات مشتری و کالا 
-- =============================================
CREATE PROCEDURE [sal].[RptSaleOrder_List_All]
	@ProcessNo		Int = 1,
	@GoodsID		VarChar(20),
	@AcntCode		VarChar(20),
	@VisitorCode1	Int = NULL,
	@VisitorCode2	Int = NULL,
	@VisitorCode3	Int = NULL,
	@VisitorCode4	Int = NULL,
	@RepOptions		VarChar(20) = '02', -- bit array
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(2000);
DECLARE @StrWhereS	NVarChar(2000);

DECLARE @CancelSum	float;
DECLARE @SoldSum	float;

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);

DECLARE @DocStep	Int;
DECLARE @RemainOnly	Bit;
Begin --============== S T A R T  C O D E ===================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	SET NOCOUNT ON;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo      = '1@1@1';
	IF (@ProcessNo	  Is Null)	SET @ProcessNo    = 1;
	IF (@VisitorCode1 Is Null)	SET @VisitorCode1 = 0;
	IF (@VisitorCode2 Is Null)	SET @VisitorCode2 = 0;
	IF (@VisitorCode3 Is Null)	SET @VisitorCode3 = 0;
	IF (@VisitorCode4 Is Null)	SET @VisitorCode4 = 0;
	
	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @RemainOnly	= Substring(@RepOptions, 1, 1);
	SET @DocStep	= Substring(@RepOptions, 2, 1);
	---------------------------------------------------------------------------
	SET @StrWhere =	'(D.ProcessNo=' + Str(@ProcessNo) + ') AND D.AcntCode = ''' + @AcntCode + ''' AND D.GoodsID = ''' + @GoodsID + ''''

	-- Visitor
	If	(@VisitorCode1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode1, 'H.VisitorAcntCode')
	If	(@VisitorCode2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode2, 'H.VisitorAcntCode')
	If	(@VisitorCode3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode3, 'H.VisitorAcntCode')
	If	(@VisitorCode4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @VisitorCode4, 'H.VisitorAcntCode')

	SET @StrWhereS = @StrWhere 

	If (@RemainOnly = 1)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.ProcessID=180)'

		If (@DocStep Is Not Null) and (@DocStep > 0)
			Set @StrWhere = @StrWhere + ' AND (D.DocStep = ' + Str(@DocStep) + ')'
	End
	Else
	Begin
		SET @StrWhere  = @StrWhere  + ' AND D.ProcessID IN (180,185)'
		SET @StrWhereS = @StrWhereS + ' AND D.ProcessID IN (90,100)'
	End

	-- S E L E C T ------------------------------------------------------------
	If (@RemainOnly = 1)
	Begin
		SELECT	@CancelSum = IsNull(Sum(CNL.GoodsQuantity), 0)
		FROM	sal.tblSaleOrderDtl AS CNL
		WHERE	CNL.ProcessID = 185 AND CNL.ProcessNo = @ProcessNo AND AcntCode = @AcntCode AND GoodsID = @GoodsID

		SELECT	@SoldSum = IsNull(Sum(Sold - SoldRet), 0)
		FROM
		(
			SELECT	GoodsQuantity AS Sold, 
					(
						SELECT	IsNull(Sum(GoodsQuantity), 0) AS SoldRet
						FROM    inv.tblStorageDocsDtl
						WHERE   BaseProcessID = SD.ProcessID AND BaseProcessNo = SD.ProcessNo AND BaseFiscalYear = SD.FiscalYear AND BaseSerialNo = SD.SerialNo AND	BaseDocRowNo = SD.DocRowNo
					) AS SoldRet
			FROM	inv.tblStorageDocsDtl SD
			WHERE	SD.ProcessID = 90 AND SD.ProcessNo = @ProcessNo AND AcntCode = @AcntCode AND GoodsID = @GoodsID
		) SaleAndRet

	End
	Else
	Begin
		SELECT	@CancelSum = 0
		SELECT	@SoldSum = 0
	End

	SET @StrSelect = '
		SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, 
				D.GoodsQuantity, D.BaseFiscalYear, D.BaseSerialNo, D.BaseDocRowNo, 
				D.DescDtl, ' + Str(@CancelSum) + ' AS CancelSum, ' + Str(@SoldSum) + ' AS SoldSum
		FROM	sal.tblSaleOrderDtl AS D
					INNER JOIN sal.tblSaleOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
		WHERE	' + @StrWhere

	If (@RemainOnly = 0)
		SET @StrSelect = @StrSelect + '
		UNION all
		SELECT	D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate, D.AcntCode, 
				D.GoodsQuantity, D.BaseFiscalYear, D.BaseSerialNo, D.BaseDocRowNo, 
				D.DescDtl, 0 AS CancelSum, 0 AS SoldSum
		FROM	inv.tblStorageDocsDtl D
		WHERE	' + @StrWhereS
		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
