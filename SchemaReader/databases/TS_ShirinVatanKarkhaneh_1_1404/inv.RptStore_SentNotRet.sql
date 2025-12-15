USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/02/22
-- Viewed By	 : 
-- Last Modified : 1391/01/20
-- Last Modifier : TakroSystem\Zia
-- Description   : <کالای ارسالی دریافت نشده>
-- =================================================================
Create PROCEDURE [inv].[RptStore_SentNotRet] 
	@ProcessID			Int = 130,
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@SelectedGoods		Int = Null,
	@SelectedAcnt1		Int = Null,
	@SelectedAcnt2		Int = Null,
	@SelectedAcnt3		Int = Null,
	@SelectedAcnt4		Int = Null,
	@DocDateFr			char(10) = Null,
	@DocDateTo			char(10) = Null,
	@SortFields			NVarChar(100) = Null,
	@RepOptions			VarChar(10) = '',  -- bit array options
	@RepInfo			NVarChar(100) = '1@1@1'	
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(4000)
--DECLARE @StrFrom	NVarChar(2000)
DECLARE @StrWhere	NVarChar(2000)
DECLARE @RetProcessID	Int;
DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE @SenderDepartmentID Int;
BEGIN

	SET NOCOUNT ON;

	-- init ------------------------------------------------------------
	if (@RepInfo		Is Null)	set @RepInfo = '1@1@1';
	if (@RepOptions		Is Null)	set @RepOptions = '';
	if (@SelectedGoods	Is Null)	set @SelectedGoods = 0;
	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0;
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0;
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0;
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0;

	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	if (@SortFields is null)	set @SortFields = 'GoodsID';
	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	set @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	set @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	set @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	set @SenderDepartmentID	= pub.funSplitString(@RepInfo, '@', 6);

	---------------------------------------------------------------------------

	-- where section ----------------------------------------------------------
	set @StrWhere = '(ProcessID = ' + ltrim(str(@ProcessID)) + ')';

	set @RetProcessID = 0;
	if @ProcessID = 130 set @RetProcessID = 135;
	if @ProcessID = 136 set @RetProcessID = 131;

	IF (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ')'

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	If (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		If (@DocDateFr = @DocDateTo)
			SET @StrWhere = @StrWhere + ' AND D.DocDate  = ''' + @DocDateFr + ''''
		Else 
		Begin
			If (@DocDateFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND D.DocDate >= ''' + @DocDateFr + ''''
			If (@DocDateTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND D.DocDate <= ''' + @DocDateTo + ''''
		End
	IF (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'D.AcntCode')
	IF (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'D.AcntCode')
	IF (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'D.AcntCode')
	IF (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'D.AcntCode')
	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'D.GoodsID') 
		
	
SET @StrSelect = 'select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, D.DocRowNo, D.DocDate,
			D.GoodsID, D.GoodsQuantity -isnull(R.GoodsQuantity,0) GoodsQuantity ,isnull(D.GoodsQuantity,0) GoodsQuantity1,isnull(R.GoodsQuantity,0) GoodsQuantity2,  D.GoodsAmount, D.GoodsPrice, D.StoreID,
			[pub].[funGetGoodsName] (D.GoodsID,'+str(@LangID)+') GoodsName,
			D.AcntCode, pub.GetCodeName(D.AcntCode, '+str(@LangID)+') AcntName, DEP.DepartmentName
 from 
 (SELECT *  FROM  inv.tblStorageDocsDtl D  WHERE ' + @StrWhere + ' )D
  inner  JOIN inv.tblStorageDocsHdr H on D.ProcessID=H.ProcessID and D.ProcessNo=H.ProcessNo and D.FiscalYear=H.FiscalYear AND D.SerialNo=H.SerialNo 
  left  Join prs.tblDepartmentsDtl DEP on DEP.DepartmentID=H.SenderDepartmentID
 left join 
 ( SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,SUM(GoodsQuantity) GoodsQuantity  ,GoodsID
   FROM  inv.tblStorageDocsDtl R   
   WHERE R.ProcessID = ' + ltrim(str(@RetProcessID)) + ' 
   GROUP BY BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,BaseDocRowNo,GoodsID
   )R
 on R.BaseProcessID=D.ProcessID   
 And R.BaseProcessNo=D.ProcessNo
 And R.BaseFiscalYear=D.FiscalYear 
 And R.BaseSerialNo=D.SerialNo
 And R.BaseDocRowNo=D.DocRowNo 
 And R.GoodsID=D.GoodsID 
 where  D.GoodsQuantity -isnull(R.GoodsQuantity,0)>0'  
 if (@SenderDepartmentID > 0)
		set @StrSelect = @StrSelect + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SenderDepartmentID, 'H.SenderDepartmentID')  
 + ' order by ' + @SortFields
print @StrSelect;
exec sp_executesql @StrSelect;
	---------------------------------------------------------------------------
END
GO
