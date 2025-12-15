USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/10/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [prd].[RptPrd_Payroll_Variance]

	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@SelectedGoods	Int = 0,
	@SelectedDepts	Int = 0,
	@PayrollRate	Float = 0,
	@ExtraParams	NVarChar(100) = '',
	@RepOptions		VarChar(10) = '',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)
DECLARE @StrWhere	NVarChar(max)
DECLARE @StrFrom	NVarChar(max)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

Begin

	SET NOCOUNT ON;

	-- I N I T -----------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions	= '11';

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	---------------------------------------------------------------------------
	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = '1 = 1'

	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
		
	IF (@DocDateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	IF (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.ProductID')
		
	--IF (@SelectedDepts > 0)
	--	SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedDepts, 'SD.DepartmentID')
	--IF (@SelectedTools > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'D.ToolID')
	--IF (@SelectedPrsns > 0)
		--SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrsns, 'O.OperatorID')
	---------------------------------------------------------------------------
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	SELECT T.ProductID, [pub].[funGetGoodsName](T.ProductID, ' + Ltrim(RTrim(@LangID)) + ') As ProductName, T.ProductCount, SD.LastProduceStepTime StandardTime,
		   (T.ProductCount * SD.LastProduceStepTime) AS TotalNecceseryTime, T.TotalTime RealTotalTime,
		   ((T.ProductCount * SD.LastProduceStepTime) -  T.TotalTime) As TimeVariance,
		   T.FiscalYear, T.SerialNo, T.DocDate, T.ProduceStepID, T.StartDate, 
			  
			SH.ProduceMethodName, T.ExecCount, SD.ProduceStepName
	FROM
	(
		SELECT  H.ProductID, H.FiscalYear, H.SerialNo, H.DocDate, D.ProduceStepID, D.ProduceStepSerialNo,
				D.StartDate, D.TotalTime, ISNULL(SUM(I.GoodsQuantity), 0) ProductCount,
				ISNULL(SUM(D.AcceptableCount+D.UnacceptableCount),0) ExecCount
		FROM	pln.tblTaskOrderDtl D
					INNER JOIN pln.tblTaskOrderHdr H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND 
												   H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
												   
					LEFT  JOIN pln.tblItemRelations R ON (R.ProcessID = H.ProcessID) AND (R.ProcessNo = H.ProcessNo) AND 
														 (R.FiscalYear = H.FiscalYear) AND (R.SerialNo = H.SerialNo) AND 
														 (R.BaseProcessID = 600)
							                             
					LEFT  JOIN inv.tblStorageDocsDtl I ON I.BaseProcessID=D.ProcessID AND I.BaseProcessNo=D.ProcessNo AND 
														  I.BaseFiscalYear=D.FiscalYear AND I.BaseSerialNo=D.SerialNo AND 
														  I.BaseDocRowNo=D.DocRowNo and I.ProcessID=72

		WHERE ' + @StrWhere + '
		GROUP BY H.ProductID, H.FiscalYear, H.SerialNo, H.DocDate, D.ProduceStepID, D.ProduceStepSerialNo, D.StartDate, D.TotalTime
	) T 
	  INNER JOIN pln.tblProduceStepDtl SD ON (SD.ProductID = T.ProductID) AND (SD.SerialNo = T.ProduceStepSerialNo) and (SD.ProduceStepID = T.ProduceStepID)
	  INNER JOIN pln.tblProduceStepHdr SH ON (SH.ProductID = T.ProductID) AND (SH.SerialNo = T.ProduceStepSerialNo) 
	ORDER BY ProductID '
   	---------------------------------------------------------------------------
	---------------------------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	---------------------------------------------------------------------------
End
GO
