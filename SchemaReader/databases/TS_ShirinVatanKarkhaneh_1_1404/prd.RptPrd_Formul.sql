USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1392/06/15
-- Viewed By	 : 
-- Last Modified : 1392/06/15
-- Last Modifier : TakroSystem\Hamid
-- Description   : <List of Product Formulas>
-- =================================================================
Create PROCEDURE [prd].[RptPrd_Formul]
	@DocDateFr		char(10) = Null,
	@DocDateTo		char(10) = Null,
	@GoodsID			Varchar(20) = '006053000195',
	@FormulaNo      int =1,
	@RepOptions			NVarChar(200) = '111',
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS
DECLARE @StrSelect	NVarChar(max)



DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی
DECLARE	@StrWhere		NVarChar(4000);

BEGIN

	SET NOCOUNT ON;

	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@RepOptions		Is Null)	SET @RepOptions = '1'

	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	---------------------------------------------------------------------------
	
	
	SET @StrWhere = '( HR.Code = ''' + @GoodsID + ''') and (HR.SerialNo=' + ltrim(rtrim(str (@FormulaNo))) + '   )'
	
	
	IF (@DocDateFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (HR.HistoryDate>=''' + @DocDateFr + ''')'
	IF @DocDateTo Is Not Null
		SET @StrWhere = @StrWhere + ' AND (HR.HistoryDate<=''' + @DocDateTo + ''')'


-- TOP (100) PERCENT HR.HistoryID, HR.RecordID, HR.ProcessID, HR.ProcessNo, HR.FiscalYear, HR.SerialNo,
Set @StrSelect='
SELECT     HR.Code, HR.DocStep, HR.DocRowNo, 
                      HR.DocAtomRowNo, HR.ActionID, HR.SessionNo, HR.HistoryDate, HR.HistoryTime, HR.HistoryBatch, HR.OldValue, HR.NewValue, HR.FieldName, HR.FieldText, 
                      pub.funGetTypeText(HR.TypeID, HR.OldValue, 1) AS OldValue2, pub.funGetTypeText(HR.TypeID, HR.NewValue, 1) AS NewValue2, 

  pub.GetUserName(HR.SessionNo) AS UserName
  ,
  
  ActionName =      CASE  HR.ActionID
         WHEN 0 THEN '''+'تغییر نیافته'+'''
         WHEN 1 THEN '''+'ایجاد'+'''
         WHEN 2 THEN '''+'تغییر یافته'+'''
         WHEN 3 THEN '''+'حذف'+'''
         WHEN 4 THEN '''+'تغییر ردیف'+'''
         WHEN 5 THEN '''+'کپی سند'+'''
         WHEN 6 THEN '''+'تغییر کد'+'''
         
         ELSE '''+'----'+'''
      END, prd.FormulaName, 
      [pub].[funGetGoodsName](prd.ProductID, ' + LTrim(RTrim(@LangID)) + ') As GoodsName

	FROM          
	(
	SELECT HR.*,ISNULL(F.FieldText,x.Rec.query(''./FN'').value(''.'', ''nvarchar(2000)'')) FieldName,F.FieldText,  
		   pub.funGetTypeText(F.TypeID, x.Rec.query(''./OV'').value(''.'', ''nvarchar(2000)''), 1) AS OldValue, 
		   pub.funGetTypeText(F.TypeID, x.Rec.query(''./NV'').value(''.'', ''nvarchar(2000)''), 1) AS NewValue  , Null TypeID
	FROM hst.tblHistoryRecords HR  
	CROSS APPLY  ChangedValue.nodes(''DocumentElement/H'') x(Rec) 
	left JOIN (select * 
			   from 
				 (SELECT *,Row_Number()over(partition by ProcessID,ProcessNo,FieldName,LanguageID order by FieldID desc) r
				  from hst.tblFields a 
				  ) a  
			   where r=1) F 
	ON  cast(F.FieldName as nvarchar(2000))= x.Rec.query(''./FN'').value(''.'', ''nvarchar(2000)'')  AND  
		HR.ProcessID=F.ProcessID and HR.ProcessNo=F.ProcessNo  
	WHERE   not(ChangedValue IS NULL)   
	UNION ALL  
	SELECT HR.*, F.FieldName, F.FieldText, 
		   pub.funGetTypeText(F.TypeID, HF.OldValue, 1) AS OldValue2, 
		   pub.funGetTypeText(F.TypeID, HF.NewValue, 1) AS NewValue2  , F.TypeID
	FROM hst.tblHistoryRecords HR  
	INNER JOIN hst.tblHistoryFields HF ON HF.HistoryID = HR.HistoryID  
	INNER JOIN hst.tblFields F ON F.FieldID = HF.FieldID  
	WHERE  (ChangedValue IS NULL OR CAST(ChangedValue as VARCHAR(mAX))='''')  	
	) HR
	INNER JOIN prd.tblFormulasHdr prd ON HR.Code = prd.ProductID AND HR.SerialNo = prd.SerialNo
	WHERE ' + @StrWhere
	------------------------------------------------------------
	SET @StrSelect = @StrSelect + ' 
	ORDER BY HR.HistoryDate, HR.HistoryTime, HR.DocRowNo, HR.DocAtomRowNo'
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
