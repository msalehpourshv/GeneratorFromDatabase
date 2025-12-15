USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--[hst].[spGetViewHistory] 50,0,0,1911826,'','',1
Create PROCEDURE [hst].[spGetViewHistory]
	@ProcessID     int,
	@FiscalYear    int,
	@SerialNo      int,
	@RecordID      int,
	@FrDate		   VarChar(10),
	@ToDate        varChar(10),
	@LanguageID	   SmallInt,
	@Code		   varchar(50)=''
WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect	NVarChar(4000);
	Declare @strWhr		NVarChar(4000);
	
	SET @strWhr = ''
	
    If @RecordID > 0 
        SET @strWhr = ' AND HR.RecordID = ' + LTRIM(RTRIM(STR(@RecordID)))

    If @ProcessID <> 0 
        SET @strWhr = @strWhr + ' AND HR.ProcessID = ' + LTRIM(RTRIM(STR(@ProcessID)))
    
    If @FiscalYear <> 0 
        SET @strWhr = @strWhr + ' AND HR.FiscalYear = ' + LTRIM(RTRIM(STR(@FiscalYear)))

    If @SerialNo <> 0 
        SET @strWhr = @strWhr + ' AND HR.SerialNo = ' + LTRIM(RTRIM(STR(@SerialNo))) 

    If @FrDate <> '' 
        SET @strWhr = @strWhr + ' AND HR.HistoryDate >= '''+ @FrDate +''''

    If @ToDate <> '' 
        SET @strWhr = @strWhr + ' AND HR.HistoryDate <= ''' + @ToDate + ''''

	If @Code <> '' 
        SET @strWhr = @strWhr + ' AND HR.Code = ''' + @Code + ''''

	set @StrSelect = '
	SELECT HR.*,ISNULL(F.FieldText,x.Rec.query(''./FN'').value(''.'', ''nvarchar(2000)'')) FieldName
	,isNull(F.FieldText,ISNULL(F.FieldText,x.Rec.query(''./FN'').value(''.'', ''nvarchar(2000)''))) FieldText,  
		   pub.funGetTypeText(F.TypeID, x.Rec.query(''./OV'').value(''.'', ''nvarchar(2000)''), 1) AS OldValue2, 
		   pub.funGetTypeText(F.TypeID, x.Rec.query(''./NV'').value(''.'', ''nvarchar(2000)''), 1) AS NewValue2 
		   ,ISNULL(F.FieldName,ISNULL(F.FieldText,x.Rec.query(''./FN'').value(''.'', ''nvarchar(2000)''))) FieldNameEN
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
	WHERE   not(ChangedValue IS NULL)  ' + @strWhr + ' 
	UNION ALL  
	SELECT HR.*, F.FieldName, F.FieldText, 
		   pub.funGetTypeText(F.TypeID, HF.OldValue, 1) AS OldValue2, 
		   pub.funGetTypeText(F.TypeID, HF.NewValue, 1) AS NewValue2  
		   ,ISNULL(F.FieldName,'''') FieldNameEN
	FROM hst.tblHistoryRecords HR  
	INNER JOIN hst.tblHistoryFields HF ON HF.HistoryID = HR.HistoryID  
	INNER JOIN hst.tblFields F ON F.FieldID = HF.FieldID  
	WHERE  (ChangedValue IS NULL OR CAST(ChangedValue as VARCHAR(mAX))='''') ' + @strWhr + ' 
	ORDER BY HistoryDate, HistoryTime, DocRowNo, DocAtomRowNo'

		Print @StrSelect;
	Exec sp_executesql @StrSelect;
END

GO
