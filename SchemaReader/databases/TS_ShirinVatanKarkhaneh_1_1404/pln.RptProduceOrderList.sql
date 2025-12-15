USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1401/11/26
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : گزارش برنامه ریزی
-- ==============================================
Create PROCEDURE pln.RptProduceOrderList
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS begin
---- Declarations ---------------
Declare @StrSelect				NVarChar(max);
Declare @StrWhereIN				NVarChar(max);
Declare @StrWhereD				NVarChar(max);
Declare @ProcessID				Varchar(20) 
Declare @ProcessNo				Varchar(20) 
DECLARE	@LangID					Char(1);
declare @FiscalYear				int;
declare @FiscalYearFrom			int;
declare @SerialNoFrom			int;
declare @FiscalYearTo			int;
declare @SerialNoTo				int;
declare @CalType				int;

SET @LangID				=1
 
SET @CalType				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @ProcessID				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @ProcessNo				= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
SET @FiscalYear				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @StrWhereIN				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @FiscalYearFrom			= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @SerialNoFrom			= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @FiscalYearTo			= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @SerialNoTo				= LTrim(pub.funSplitString(@ExtraParams, '@', 9)); 

SET @StrWhereD = '  D.ProcessID = '+str(@ProcessID)+' '

if @FiscalYearFrom>0
	SET @StrWhereD = @StrWhereD + ' AND (H.FiscalYear =' + str(@FiscalYearFrom) + ')'
if @SerialNoFrom>0
	SET @StrWhereD = @StrWhereD + ' AND (H.SerialNo >=' + str(@SerialNoFrom) + ')'
if @FiscalYearTo>0
	SET @StrWhereD = @StrWhereD + ' AND (H.FiscalYear =' + str(@FiscalYearTo) + ')'
if @SerialNoTo>0
	SET @StrWhereD = @StrWhereD + ' AND (H.SerialNo <=' + str(@SerialNoTo) + ')'
	
If (@StrWhereIN Is Not Null  and  LTRIM(rtrim(@StrWhereIN ))<>'')
	SET @StrWhereD = @StrWhereD + @StrWhereIN

if @CalType=1
set @StrSelect='
 SELECT Distinct H.DocDate
FROM pln.tblProduceOrderDtl D  
inner join pln.tblProduceOrderHdr H on  H.ProcessID=D.ProcessID  and H.ProcessNo=D.ProcessNo  and H.SerialNo=D.SerialNo  and H.FiscalYear= D.FiscalYear
left join pln.tblProduceStepHdr PS on D.ProductID=PS.ProductID and D.StepNo=PS.SerialNo  
left join (select   sum(OperatorCount) OperatorCount,ProductID,SerialNo from pln.tblProduceStepDtl group by ProductID,SerialNo) PD on D.ProductID=PD.ProductID and D.StepNo=PD.SerialNo  
 WHERE'+ @StrWhereD +'
   ORDER BY H.DocDate '

if @CalType=2

set @StrSelect='
 SELECT isnull(ShiftTypeID, '''') ShiftTypeID,emp.funGetShiftTypeName(ShiftTypeID,'+str(@LangID)+') ShiftTypeName,isnull(PS.ProductionLineID,'''') ProductionLineID,pln.funGetProductionLineName(PS.ProductionLineID,'+str(@LangID)+')ProductionLineName 
 , D.ProductID,
 pub.funGetGoodsName(D.ProductID,'+str(@LangID)+') AS ProductName,D.FormulaNo,D.ProductCount, OperatorCount,D.DescDtl,H.DocDate,H.FiscalYear,H.SerialNo,H.ProcessNo
FROM pln.tblProduceOrderDtl D  
inner join pln.tblProduceOrderHdr H on  H.ProcessID=D.ProcessID  and H.ProcessNo=D.ProcessNo  and  H.SerialNo=D.SerialNo  and H.FiscalYear= D.FiscalYear
left join pln.tblProduceStepHdr PS on D.ProductID=PS.ProductID and D.StepNo=PS.SerialNo  
left join (select   sum(OperatorCount) OperatorCount,ProductID,SerialNo from pln.tblProduceStepDtl group by ProductID,SerialNo) PD on D.ProductID=PD.ProductID and D.StepNo=PD.SerialNo  
 WHERE   '+ @StrWhereD +'  
 ORDER BY H.DocDate,ShiftTypeID,PS.ProductionLineID,D.FiscalYear , D.SerialNo,D.DocRowNo '
 
print @StrSelect
Exec sp_executesql @StrSelect;

end 
GO
