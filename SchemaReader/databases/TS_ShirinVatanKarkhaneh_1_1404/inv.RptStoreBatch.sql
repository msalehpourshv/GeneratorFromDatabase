USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1396/06/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : آخرین وضعیت بچهای دستور کار
-- ==============================================
CREATE PROCEDURE [inv].[RptStoreBatch]
	@ExtraParams		NVarChar(Max) = '',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
---- Declarations ---------------
BEGIN
	DECLARE @StrSelect		NVarChar(max);
	DECLARE @StrWhere		NVarChar(max);

	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int;
	DECLARE	@UserID			Int;
	DECLARE	@UserIsAdmin	bit;

	DECLARE	@BaseProcessID	Varchar(20);
	DECLARE	@BaseProcessNo	Int;
	DECLARE	@BaseFiscalYear	Int; 
	DECLARE	@BaseSerialNo	Int;
	DECLARE	@SelectedProcs	Varchar(100);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	----------------------------------------------------
	SET @BaseProcessID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @BaseProcessNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @BaseFiscalYear		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @BaseSerialNo		= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @SelectedProcs		= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 

	SET @StrWhere = '1 = 1'

	IF (@BaseProcessID <> '0') And (@BaseProcessID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND BaseProcessID In (' + @BaseProcessID + ')'
		
	IF (@BaseProcessNo <> 0) And (@BaseProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND BaseProcessNo = ' + LTrim(Str(@BaseProcessNo))		

	IF (@BaseFiscalYear <> 0) And (@BaseFiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND BaseFiscalYear = ' + LTrim(Str(@BaseFiscalYear))	
		
	IF (@BaseSerialNo <> 0) And (@BaseSerialNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND BaseSerialNo = ' + LTrim(Str(@BaseSerialNo))	
				
	-- ============================================== 
	BEGIN TRY
		DROP TABLE ##BatchNo
	END TRY
	BEGIN CATCH
	END CATCH
				
	Select BatchNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo,DocDate BuildDate,DocDate StartTime,  DocDate, 
		   StoreID, SerialNo, ConstText3 UserName, ProcessID, ConstText3 ProcessName
	Into ##BatchNo 
	From inv.tblStorageDocsDtl 
	Where 1 = 0
 
	-- ============================================== 
	Set @StrSelect = '
	Insert Into ##BatchNo
	Select BatchNo, BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, '''', '''', '''', '''', 0, '''', 0, ''''
	From   inv.tblBatch
	Where  ' + @StrWhere
	--============================================'
 
	Print @StrSelect
	Exec sp_executesql @StrSelect; 
	
	--Select * From ##BatchNo
	
	-- ============================================== 
	Set @StrSelect = '
	Update ##BatchNo
	Set DocDate   = isnull(a1.DocDate ,''''),
	    StoreID	  = isnull(case when a1.StoreID	= '''' then b.StoreID else a1.StoreID end, ''''),
		SerialNo  = isnull(a1.SerialNo  ,0),
		UserName  = pub.GetUserName(b.SessionNo),
		ProcessID = a1.ProcessID
	From ##BatchNo c 
	Inner Join (Select * From inv.tblStorageDocsDtl Where BatchNo <> '''') a1 On c.BatchNo = a1.BatchNo
	Inner Join 
	(
		Select aa.DocDate,aa.BatchNo,Max(VolumeRowNo) VolumeRowNo 
		From
		(
			Select Max(DocDate) DocDate, BatchNo 
			From inv.tblStorageDocsDtl 
			Group by BatchNo
		 ) aa
		Inner Join inv.tblStorageDocsDtl bb ON aa.BatchNo = bb.BatchNo and aa.DocDate = bb.DocDate
		Group By aa.DocDate,aa.BatchNo
	  ) a2 ON a1.DocDate =a2.DocDate and a1.BatchNo=a2.BatchNo and a1.VolumeRowNo=a2.VolumeRowNo
	Inner Join inv.tblStorageDocsHdr b ON a1.ProcessID = b.ProcessID and a1.ProcessNo = b.ProcessNo and 
										  a1.FiscalYear = b.FiscalYear and a1.SerialNo = b.SerialNo'	
	Print @StrSelect
	Exec sp_executesql @StrSelect; 
	
	-- ============================================== 
	SET @StrSelect = '
	Update ##BatchNo
	Set StartTime = b.StartTime,BuildDate = b.FinishDate
	From ##BatchNo a 
	Inner Join pln.tblTaskOrderDtl b on a.BaseSerialNo=b.SerialNo  
	Inner Join inv.tblStorageDocsDtl c ON c.BaseProcessID  = b.ProcessID and c.BaseProcessNo = b.ProcessNo and 
										  c.BaseFiscalYear = b.FiscalYear and c.BaseSerialNo = b.SerialNo  and 
										  c.BaseDocRowNo = b.DocRowNo and a.BatchNo = c.BatchNo'	
	Print @StrSelect
	Exec sp_executesql @StrSelect; 
	
	-- ============================================== 
	SET @StrSelect = 'Update ##BatchNo
					  Set ProcessName = P.ProcessName
					  From ##BatchNo c 
					  Inner Join pub.tblProcess P on P.ProcessID = c.ProcessID'

	Print @StrSelect
	Exec sp_executesql @StrSelect; 

	-- ============================================== 
	Set @StrSelect = '
	Select Row_Number() Over(Order By BatchNo) [ردیف], 
		   BatchNo		  [بچ],
		   Case When BaseProcessID = 610 Then 
				''دستور کار'' 
		   Else
				''رسید موقت'' 
		   End			  [نوع بچ],
		   BaseFiscalYear [سال مالی],
		   BaseSerialNo   [ش.برگه],
		   BuildDate	  [تاریخ تولید],
		   StartTime      [ساعت تولید],
		   DocDate		  [تاریخ],
		   StoreID		  [انبار],
		   SerialNo		  [سریال],
		   UserName		  [کاربر],
		   ProcessName    [مراحل]
	From  ##BatchNo 
	Where ProcessID IN (' + @SelectedProcs + ')'

	Print @StrSelect
	Exec sp_executesql @StrSelect;
END
GO
