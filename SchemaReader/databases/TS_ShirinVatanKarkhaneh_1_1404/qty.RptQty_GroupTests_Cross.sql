USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/11/20
-- Viewed By	 : 
-- Last Modified : 1389/11/23
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- =============================================
Create PROCEDURE [qty].[RptQty_GroupTests_Cross] 
	@TestGroupID	varchar(20),
	@DocDateFr		char(10) = NULL,
	@DocDateTo		char(10) = NULL,
	@FiscalFr		Int = NULL,
	@SerialFr		Int = NULL,
	@FiscalTo		Int = NULL,
	@SerialTo		Int = NULL,
	@SelectedGoods	int = NULL,
	@SelectedTests	int = NULL,
	@SelectedBatch	int = NULL,
	@ValueFr		float = NULL,
	@ValueTo		float = NULL,
	@RowDesc		nvarchar(250) = NULL,
	@DocDesc		nvarchar(250) = NULL,
	@SortFields		nvarchar(100) = NULL,
	@RepOptions		nvarchar(10) = '111011',  -- bit array options
	@RepInfo		nvarchar(100) = '1@1@1',
	@ExtraParams	nvarchar(200) = ''
WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(max);
DECLARE @StrFrom		NVarChar(max);
DECLARE @StrWhere		NVarChar(max);
DECLARE @StrFieldsID	NVarChar(max);
DECLARE @StrFieldsIDPivot NVarChar(max);
DECLARE @StrFieldsMax	NVarChar(max);
DECLARE @StrCodeField	NVarChar(500);
DECLARE @StrNameField	NVarChar(500);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;

	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';
	IF (@RepOptions Is Null)	SET @RepOptions = '1';
	IF (@SelectedTests Is Null)	SET @SelectedTests = 0;
	IF (@SelectedGoods Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedBatch Is NULL) SET @SelectedBatch = 0;

	If (@FiscalFr	Is Null)	SET @SerialFr = Null;
	If (@FiscalTo	Is Null)	SET @SerialTo = Null;
	If (@SerialFr	Is Null)	SET @FiscalFr = Null;
	If (@SerialTo	Is Null)	SET @FiscalTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

--	SET @IsGrouped	= Substring(@RepOptions, 1, 1);
	--=========================================================================================
	-- Where Section -------------------------------
	set @StrWhere = '1=1 '
	
	if (@TestGroupID <>'')
		set @StrWhere = @StrWhere + ' AND (H.TestGroupID = ''' + @TestGroupID + ''')';
		
	if (@DocDateFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
	if (@DocDateTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'

	if (@SerialFr Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialFr)) + '))' 
	if (@SerialTo Is Not Null)
		set @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialTo)) + '))' 

	if (@SelectedGoods > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'H.GoodsID') 
	if (@SelectedTests > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTests, 'D.TestID') 
	if (@SelectedBatch > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedBatch, 'H.BatchNo') 
	--=========================================================================================
	set @StrFieldsID = '';
	set @StrFieldsIDPivot = '';
	set @StrFieldsMax = '';

	declare crs_Fields cursor for
		select Distinct T.TestID, T.TestName
		from qty.tblQCTestValues V 
				inner join qty.tblQCTests T on T.TestID = V.TestID
		where (@TestGroupID = '' OR TestGroupID = @TestGroupID)
		
	open crs_Fields
	fetch next from crs_Fields into @StrCodeField, @StrNameField
	
	while (@@fetch_status = 0)
	begin
		set @StrFieldsID = @StrFieldsID + '(' + @StrCodeField + '),'
		SET @StrFieldsIDPivot = @StrFieldsIDPivot + '['''+ Case When @StrCodeField is null Then '' else @StrCodeField end + '''],'
		--set @StrFieldsMax = @StrFieldsMax + '(' + '''' + @StrCodeField + '''' +') as [' + @StrNameField + '],'
		SET @StrFieldsMax = @StrFieldsMax + '(' + '''' + @StrCodeField + '''' +') as [' + CASE WHEN @StrFieldsMax LIKE '%' + @StrNameField + '%' THEN  @StrNameField + '-' + @StrCodeField  ELSE @StrNameField END + '],'	
		fetch next from crs_Fields into @StrCodeField, @StrNameField
	end

	close crs_Fields;
	deallocate crs_Fields;
	
	Set @StrFieldsIDPivot = substring(@StrFieldsIDPivot,0,len(@StrFieldsIDPivot))

	IF @StrFieldsIDPivot = ''
		Set @StrFieldsIDPivot = '['''']'

	SET @StrSelect = '
	SELECT H.TestGroupID,
		   H.SerialNo,
		   H.GoodsID,
		   H.BatchNo,
		   inv.funGetBatchName (H.BatchNo, '+ @LangID +') BatchName,
		   D.TestDate, 
		   D.TestID 
		   --,D.TestValue
		   ,CASE WHEN D.TestValue > ValueTo THEN ''UP'' + CAST(D.TestValue AS VARCHAR) ELSE 
		    CASE WHEN D.TestValue < ValueFr THEN ''DWN'' + CAST(D.TestValue AS VARCHAR) ELSE 
			'' '' + CAST(D.TestValue AS VARCHAR) END END TestValue,
		   FaultID,
		   P.ProcessName,
		   H.SourceFiscalYear,
		   H.SourceSerialNo,
		   H.SourceDocRowNo,
		   V.TextValue
	INTO #tbl_Result
	FROM qty.tblQCTestDocsDtl D
	INNER JOIN qty.tblQCTestDocsHdr H ON H.ProcessID = D.ProcessID 
									 AND H.ProcessNo = D.ProcessNo 
									 AND H.FiscalYear = D.FiscalYear 
									 AND H.SerialNo = D.SerialNo
	LEFT JOIN qty.tblQCTestValues V ON V.TestID = D.TestID 
								   AND V.TestGroupID = H.TestGroupID 
								   AND V.TestID = V.TestID 
								   AND V.GoodsID = H.GoodsIDBase
	LEFT JOIN pub.tblProcess P ON P.ProcessID = H.SourceProcessID AND P.ProcessNo = H.SourceProcessNo
				
	WHERE ' + @StrWhere + '
	------------------------
	SELECT '''' [استاندارد],' + @StrFieldsMax + ' 
		   TestDate AS [تاریخ],
		   FaultName AS [نام خطا],
		   T.FaultID  AS [کد خطا], 
		   ISNULL(G.GoodsName, '''') AS [نام محصول], 
		   T.GoodsID AS [کد محصول],
		   T.BatchNo AS [شماره بچ],
		   T.BatchName AS [نام بچ],
		   TestGroupName AS [نام گروه آزمون], 
		   T.TestGroupID AS [کد گروه آزمون], 
		   SerialNo AS [شماره برگه],
		   ProcessName AS [نام فرایند مرجع],
		   SourceFiscalYear AS [سال مالی مرجع],
		   SourceSerialNo AS [شماره برگه مرجع],
		   SourceDocRowNo AS [ردیف مرجع],
		   TextValue AS [مقدار متنی]
	FROM
	(
	 SELECT SerialNo,
			TestGroupID, 
			GoodsID,
			BatchNo,
			BatchName,
			TestDate, 
			' + @StrFieldsMax + ' 
			FaultID,
		    ProcessName,
		    SourceFiscalYear,
		    SourceSerialNo,
		    SourceDocRowNo,
			TextValue
	 FROM #tbl_Result P 
			PIVOT 
			(
				MAX(P.TestValue)
				FOR P.TestID IN (' + @StrFieldsIDPivot + ')
			) AS PVT 
	) T	
	LEFT JOIN inv.tblGoodsDtl G ON G.GoodsID = T.GoodsID
	LEFT JOIN qty.tblQCTestGroups Q ON Q.TestGroupID = T.TestGroupID
	LEFT JOIN pln.tblFaults F ON F.FaultID = T.FaultID
	--group by SerialNo, T.GoodsID, G.GoodsName, TestDate  
 '
	-- Select section -------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	--=========================================================================================
	
END
--go
--EXEC [qty].[RptQty_GroupTests_Cross] '11'
GO
