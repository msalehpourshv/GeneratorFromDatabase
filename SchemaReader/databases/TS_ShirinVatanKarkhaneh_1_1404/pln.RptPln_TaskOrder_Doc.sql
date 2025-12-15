USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1388/12/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- ==============================================
Create PROCEDURE [pln].[RptPln_TaskOrder_Doc]
	@ProcessID		Int = 610,
	@ProcessNo		Int = 1,
	@FiscalYearFr	Int = Null,
	@SerialNoFr		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@RepOptions		VarChar(10) = '110', -- bit array options
	@ExtraParam		NVarChar(500) = '0@15', -- [0=filled,1=rows]
	@RepInfo		NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrFrom	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;

DECLARE @IsFilled	Int;
DECLARE @EmptyRows	Int;
DECLARE @FieldList	NVarChar(2000);
DECLARE	@Serials	varchar(300);
DECLARE @ProdOrdrSerials1	Int;
DECLARE @ProdOrdrSerials2	Int;
DECLARE @PrintOnlyProduct	bit;

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	-- Init Variables --------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '011';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @IsFilled	= pub.funSplitString(@ExtraParam, '@', 1);
	SET @EmptyRows	= pub.funSplitString(@ExtraParam, '@', 2);
	SET @Serials	= pub.funSplitString(@ExtraParam, '@', 3);	
	SET @ProdOrdrSerials1	= pub.funSplitString(@ExtraParam, '@', 4);	
	SET @ProdOrdrSerials2	= pub.funSplitString(@ExtraParam, '@', 5);	
	SET @PrintOnlyProduct	= pub.funSplitString(@ExtraParam, '@', 6);	
	-- --------------------------------------------------
 
	Set @StrWhere = ' (H.ProcessID = ' + LTrim(Str(@ProcessID)) + ') AND (H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	if (@Serials <> '' and @Serials <> 'null')
		SET @StrWhere = @StrWhere + ' AND (H.SerialNo in (' + LTrim(@Serials) + '))' 

	if @ProdOrdrSerials1 Is Not Null and @ProdOrdrSerials1 > 0  
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND PO.SerialNo>= ' + LTrim(Str(@ProdOrdrSerials1)) + '))' 
	      
	if @ProdOrdrSerials2 Is Not Null and @ProdOrdrSerials2 > 0  
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND PO.SerialNo<= ' + LTrim(Str(@ProdOrdrSerials2)) + '))' 

	If (@SerialNoFr Is Not Null) and (@SerialNoFr > 0)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null) and (@SerialNoTo > 0)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
	
	SET @FieldList = ' H.*, D.RowNo, D.DocRowNo, D.ProduceStepID, D.ProduceStepTime, D.ToolID, D.ToolFixTime, 
			D.StartTime, D.FinishTime, D.TotalTime, D.AcceptableCount, D.UnacceptableCount, D.OverProduct, 
			D.ProductDeduction, D.StartDate, D.FinishDate, D.ProductCostAmount, D.ProduceStepSerialNo,
			GDS.GoodsName, GDP.GoodsName AS ProductName, GS.GoodsLength, GS.GoodsWidth, GS.GoodsHeight,GS2.ExtraField1 , GS2.ExtraField2 , GS2.ExtraField3 , GS2.ExtraField4 , GS2.ExtraField5,
			R.BaseFiscalYear, R.BaseSerialNo, R.BaseDocRowNo,
			pub.GetUserName(H.SessionNo) AS UserName,
			prs.funGetPersonnelName(H.Confirmer1ID, ' + @LangID + ') Confirmer1Name, 
			prs.funGetPersonnelName(H.Confirmer2ID, ' + @LangID + ') Confirmer2Name, 
			prs.funGetPersonnelName(H.Confirmer3ID, ' + @LangID + ') Confirmer3Name, 
			prs.funGetPersonnelName(H.Approver1ID, ' + @LangID + ')	Approver1Name, 
			prs.funGetPersonnelName(H.Approver2ID, ' + @LangID + ') Approver2Name, 
			prs.funGetPersonnelName(H.Approver3ID, ' + @LangID + ') Approver3Name 
			,isnull(PO.BaseProcessID,0) ProcessIDOrder ,isnull(PO.BaseProcessNo,0) ProcessNoOrder ,isnull(PO.BaseFiscalYear,0) FiscalYearOrder ,isnull(PO.BaseSerialNo,0) SerialNoOrder, isnull(PO.BaseDocRowNo,0) DocRowNoOrder
			,isnull(SO.AcntCode,'''') AcntCodeOrder , pub.GetCodeName(SO.AcntCode,' + @LangID + ') AS AcntNameOrder 
			,isnull(SO.BaseProcessID,0) ProcessIDPreSale ,isnull(SO.BaseProcessNo,0) ProcessNoPreSale ,isnull(SO.BaseFiscalYear,0) FiscalYearPreSale ,isnull(SO.BaseSerialNo,0) SerialNoPreSale
			,isnull(SO.DocDesc,'''') DocDescOrder ,isnull(SOD.DescDtl,'''') DescDtlOrder 
			,isnull((Select Count (*) from sal.tblSaleOrderParamAtom a where a.ProcessID = PO.BaseProcessID  AND a.ProcessNo = PO.BaseProcessNo AND a.FiscalYear = PO.BaseFiscalYear  AND a.SerialNo = PO.BaseSerialNo AND a.DocRowNo = PO.BaseDocRowNo ),0 ) CountOrderParamAtom'
	If (@IsFilled = 1)
		SET @StrFrom = ' pln.tblTaskOrderHdr H
					LEFT JOIN pln.tblTaskOrderDtl D ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo 
					'
	Else
		SET @StrFrom = ' pln.tblTaskOrderHdr H
					LEFT JOIN pln.tblTaskOrderDtl D ON H.ProcessID = -D.ProcessID AND H.ProcessNo = -D.ProcessNo AND H.FiscalYear = -D.FiscalYear AND H.SerialNo = -D.SerialNo
					-- multiply by row count
					CROSS JOIN (SELECT TOP ' + LTrim(Str(@EmptyRows)) + ' * FROM inv.tblGoods) M 
					'
	SET @StrFrom =@StrFrom +  '
					LEFT JOIN inv.tblGoods	  GS  ON H.GoodsID = GS.GoodsID 
					LEFT JOIN inv.tblGoods	  GS2  ON H.ProductID = GS2.GoodsID 
					LEFT JOIN inv.tblGoodsDtl GDS ON H.GoodsID = GDS.GoodsID 
					LEFT JOIN inv.tblGoodsDtl GDP ON H.ProductID = GDP.GoodsID 
					LEFT JOIN
					(
						SELECT *
						FROM pln.tblItemRelations R
						WHERE R.BaseProcessID = 600 -- produce order 
					) AS R ON R.ProcessID = H.ProcessID AND R.ProcessNo = H.ProcessNo AND R.FiscalYear = H.FiscalYear AND R.SerialNo = H.SerialNo					
					inner JOIN pln.tblProduceOrderDtl PO
						ON PO.ProcessID = H.BaseProcessID AND PO.ProcessNo = H.BaseProcessNo AND PO.FiscalYear = H.BaseFiscalYear AND PO.SerialNo = H.BaseSerialNo AND PO.DocRowNo = H.ProdDocRowNo	'
	if @PrintOnlyProduct='True'
		SET @StrFrom =@StrFrom + ' and H.ProductID=PO.ProductID '
	 						
	SET @StrFrom =@StrFrom +  '
					LEFT JOIN sal.tblSaleOrderHdr SO
						ON SO.ProcessID = PO.BaseProcessID AND SO.ProcessNo = PO.BaseProcessNo AND SO.FiscalYear = PO.BaseFiscalYear AND SO.SerialNo = PO.BaseSerialNo 
					LEFT JOIN sal.tblSaleOrderDtl SOD
						ON SOD.ProcessID = PO.BaseProcessID AND SOD.ProcessNo = PO.BaseProcessNo AND SOD.FiscalYear = PO.BaseFiscalYear AND SOD.SerialNo = PO.BaseSerialNo  AND SOD.DocRowNo = PO.BaseDocRowNo		
					 '
	SET @StrSelect = 
	' SELECT ' + @FieldList + 
	' FROM ' + @StrFrom +
	' WHERE ' + @StrWhere +
	' ORDER BY H.SerialNo, D.DocRowNo'

	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
End
GO
