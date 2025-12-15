USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [sal].[RptSale_GoodsExit]
	@ProcessID		Tinyint  	  = 93,
	@ProcessNo		Tinyint  	  = 1,
	@FiscalYearFr	Int 		  = Null,
	@SerialNoFr		Int 		  = Null,
	@FiscalYearTo	Int 		  = Null,
	@SerialNoTo		Int 		  = Null,
	@SelectedGoods	int 		  = 0,
	@SelectedStore	int 		  = 0,
	@DocDateFr		Char(10) 	  = Null,
	@DocDateTo		Char(10) 	  = Null,
	@RepOptions		VarChar(10)	  = '10',
	@ExtraParams	NVarChar(200) = '@0@@@-1@-1',
	@RepInfo		NVarChar(100) = '1@1@1'	
WITH ENCRYPTION
AS

BEGIN

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی

SET NOCOUNT ON;

	DECLARE @StrSelect	NVarChar(Max);
	DECLARE @StrWhere	NVarChar(Max);
	
	-- ==========
	DECLARE @UserName NVarChar(4000)
	SET @UserName = ''
	SELECT @UserName = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'Pub_CurrentUserName'
		
	-- ==========
	DECLARE @CompanyName NVarChar(50)
	IF (SELECT Count(*) FROM pub.tblSettings WHERE SettingKey = 'CompanyCompanyName') > 0
	Begin
		SELECT @CompanyName = Cast(SettingValue as nvarchar(500))
		FROM pub.tblSettings
		WHERE SettingKey = 'CompanyCompanyName'
	END
	ELSE
	BEGIN
		SET @CompanyName = 'گروه صنعتی'
	END
		
	--==============
	IF (@RepOptions Is Null)	SET @RepOptions = '10';
	IF (@ExtraParams Is Null)	SET @ExtraParams = '@0@@@-1@-1';
		
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
		
	--==============
	SET @LangID = pub.funGetCurrentLanguageID();

	--==============
	IF (@ProcessNo Is Null)			SET @ProcessNo = 1;
	IF (@FiscalYearFr Is Null)		SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)		SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)		SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)		SET @FiscalYearTo = Null;	
	IF (@SelectedGoods Is Null)		SET @SelectedGoods = 0;
	IF (@SelectedStore Is Null)		SET @SelectedStore = 0;	
		
	--==============
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber < @UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- ============================================================= Where
	SET @StrSelect = ''
	SET @StrWhere = ' D.ProcessID = ' + LTrim(Str(@ProcessID)) + 'AND D.ProcessNo = ' + LTrim(Str(@ProcessNo))
	
	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'A.GoodsID')
		
	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'A.StoreID')

	IF (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND D.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 

	IF (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (D.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND D.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 
		
	If (@DocDateFr Is Not Null And @DocDateFr <> '') OR (@DocDateTo Is Not Null And @DocDateTo <> '')
		If (@DocDateFr = @DocDateTo)
			Set @StrWhere = @StrWhere + ' AND (H.DocDate  = ''' + @DocDateFr + ''')'
		Else 
		Begin
			If (@DocDateFr Is Not Null And @DocDateFr <> '')
				Set @StrWhere = @StrWhere + ' AND (H.DocDate >= ''' + @DocDateFr + ''')'
			If (@DocDateTo Is Not Null And @DocDateTo <> '')
				Set @StrWhere = @StrWhere + ' AND (H.DocDate <= ''' + @DocDateTo + ''')'
		End
								
	-- ============================================================= Select
	SET @StrSelect = '
		Select D.*, [pub].[funGetGoodsName](D.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, H.C1 CarNo, H.C2 Sender, H.C3 Reciver,
			   pub.GetStoreName(D.StoreID,1)AS StoreName, [pub].[GetCodeName](D.AcntCode, ' + LTrim(RTrim(@LangID)) + ') AcntName, 
			   ''' + @CompanyName + ''' CompanyName
		From inv.tblStorageDocsHdr H
		Inner Join inv.tblStorageDocsDtl D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
											  H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
		Where ' + @StrWhere
	-- =============================================================
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	-- =============================================================
		
END
GO
