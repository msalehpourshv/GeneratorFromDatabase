USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/03/21
-- Viewed By	 : 
-- Last Modified : 1390/10/21
-- Last Modifier : TakroSystem\Zia
-- Description	 : Daily Book Report 
-- =======================================
Create PROCEDURE [acc].[RptAcc_Journal]
	@LayerLen		Int, -- طول لایه ای که به آن طول باید اطلاعات برگردانده شود
	@DateFr			Char(10) = Null,
	@DateTo			Char(10) = Null,
	@SerialNoFr		Int = Null,
	@SerialNoTo		Int = Null,
	@SerialOldFr	Int = Null,
	@SerialOldTo	Int = Null,
	@RepOptions		varchar(100) = '00001010803101',
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @HeaderDesc1	Bit; -- شرح زیر برگه
DECLARE @HeaderDesc2	Bit; -- ضمائم
DECLARE @DetailDesc1	Bit; -- شرح اول ردیف
DECLARE @DetailDesc2	Bit; -- شرح دوم ردیف
DECLARE @IsSummary		Bit; -- گزارش خلاصه باشد یا نه؟
DECLARE @SortByDate		Bit; -- مرتب بر اساس تاریخ باشد یا سریال؟
DECLARE @IsSummaryEx	Bit;
DECLARE @AcntStart		int;
DECLARE @AcntLen		int;
DECLARE @Acnt1Len		int;
DECLARE @IsSummaryDate	int;
--DECLARE @UseRemain		int;

DECLARE @StrQuery	NVarChar(Max);
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(1000);
DECLARE @StrGroup	NVarChar(1000);

DECLARE @StrDscFldH1	NVarChar(100);
DECLARE @StrDscFldH2	NVarChar(100);
DECLARE @StrDscFldD1	NVarChar(100);
DECLARE @StrDscFldD2	NVarChar(100);
DECLARE @StrSerialNo	NVarChar(150);
DECLARE @StrOldSerialNo	NVarChar(150);
DECLARE @StrSerialNoGrpBy		NVarChar(150);
DECLARE @StrOldSerialNoGrpBy	NVarChar(150);
DECLARE @StrDocDate		NVarChar(150);
DECLARE @StrPrevAcntCode	NVarChar(1024);
DECLARE @StrAcntCode1	NVarChar(1024);
DECLARE @StrAcntCode2	NVarChar(1024);
DECLARE @StrAcntCode3	NVarChar(1024);
DECLARE @StrAcntCode4	NVarChar(1024);
DECLARE @UseOldSerial	bit;

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@SelectedAcnt1	int;
DECLARE	@SelectedAcnt2	int;
DECLARE	@SelectedAcnt3	int;
DECLARE	@SelectedAcnt4	int;
DECLARE	@IncludePrimary		Bit; -- شامل سند افتتاحیه باشد؟
DECLARE	@IncludeFinish		Bit; -- شامل سند اختتامیه باشد؟
DECLARE	@IncludeClosed		Bit; -- شامل سند بستن حساب باشد؟
DECLARE	@ShowEntezami		bit;
DECLARE @ShowNoteVchKind	bit;
DECLARE @ExportToExcel		bit;
DECLARE @Layer11	int
DECLARE @Layer12	int
DECLARE @Layer13	int
DECLARE @Layer14	int

DECLARE @Layer21	int
DECLARE @Layer22	int
DECLARE @Layer23	int
DECLARE @Layer24	int

DECLARE @Layer31	int
DECLARE @Layer32	int
DECLARE @Layer33	int
DECLARE @Layer34	int

DECLARE @Layer41	int
DECLARE @Layer42	int
DECLARE @Layer43	int
DECLARE @Layer44	int
DECLARE @SqlLayer	Varchar(2000)
DECLARE @AcntCode1	VarChar(1024);
DECLARE @AcntCode2	VarChar(1024);
DECLARE @AcntCode3	VarChar(1024);
DECLARE @AcntCode4	VarChar(1024);
	
BEGIN 
	------------------------------------------------------------------------
	SET NOCOUNT ON;

DECLARE @AcntStart1		int;
DECLARE @AcntLen1		int;
DECLARE @AcntStart2		int;
DECLARE @AcntLen2		int;
DECLARE @AcntStart3		int;
DECLARE @AcntLen3		int;
DECLARE @AcntStart4		int;
DECLARE @AcntLen4		int;
DECLARE @PartNumber		int;

DECLARE @AcntPart1		int;
DECLARE @AcntLayerSum1	int;

DECLARE @AcntPart2		int;
DECLARE @AcntLayerSum2	int;

DECLARE @AcntPart3		int;
DECLARE @AcntLayerSum3	int;

DECLARE @PartSum1		varchar(5);
DECLARE @PartSum2		varchar(5);
DECLARE @PartSum3		varchar(5);

SELECT @PartSum1 = SettingValue  FROM pub.tblSettings WHERE SettingKey = 'PartAndSum1'
SELECT @PartSum2 = SettingValue  FROM pub.tblSettings WHERE SettingKey = 'PartAndSum2'
SELECT @PartSum3 = SettingValue  FROM pub.tblSettings WHERE SettingKey = 'PartAndSum3'

Set @AcntPart1		= pub.funSplitString(@PartSum1,'@',1);
Set @AcntLayerSum1	= pub.funSplitString(@PartSum1,'@',2);

Set @AcntPart2		= pub.funSplitString(@PartSum2,'@',1);
Set @AcntLayerSum2	= pub.funSplitString(@PartSum2,'@',2);

Set @AcntPart3		= pub.funSplitString(@PartSum3,'@',1);
Set @AcntLayerSum3	= pub.funSplitString(@PartSum3,'@',2);

Declare @AcntLayerStart3 int;
SELECT @AcntLayerStart3 = [acc].[funGetAcntLayerStartandLen](@AcntPart3,1)

	IF @RepInfo Is Null SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @HeaderDesc1	= Substring(@RepOptions, 1, 1)
	SET @HeaderDesc2	= Substring(@RepOptions, 2, 1)
	SET @DetailDesc1	= Substring(@RepOptions, 3, 1)
	SET @DetailDesc2	= Substring(@RepOptions, 4, 1)
	SET @SortByDate		= Substring(@RepOptions, 5, 1)
	SET @IsSummary		= Substring(@RepOptions, 6, 1)
	SET @IsSummaryEx	= Substring(@RepOptions, 7, 1)
	SET @AcntStart		= Substring(@RepOptions, 8, 2)
	SET @AcntLen		= Substring(@RepOptions, 10, 2)
	SET @UseOldSerial	= Substring(@RepOptions, 12, 1)
	-- 13 is used
	SET @IsSummaryDate  = Substring(@RepOptions, 14, 1)
	--SET @UseRemain		= Substring(@RepOptions, 15, 1)

	SET @SelectedAcnt1	= pub.funSplitString(@RepOptions, '@', 2);
	SET @SelectedAcnt2	= pub.funSplitString(@RepOptions, '@', 3);
	SET @SelectedAcnt3	= pub.funSplitString(@RepOptions, '@', 4);
	SET @SelectedAcnt4	= pub.funSplitString(@RepOptions, '@', 5);
	SET	@IncludePrimary	= pub.funSplitString(@RepOptions, '@', 6);
	SET	@IncludeFinish	= pub.funSplitString(@RepOptions, '@', 7);
	SET	@IncludeClosed	= pub.funSplitString(@RepOptions, '@', 8);
	SET	@ShowEntezami	= pub.funSplitString(@RepOptions, '@', 9);
	SET @ShowNoteVchKind= pub.funSplitString(@RepOptions, '@', 10);
	SET @Acnt1Len		= pub.funSplitString(@RepOptions, '@', 11);	
	SET @PartNumber		= pub.funSplitString(@RepOptions, '@', 12); 
	SET @ExportToExcel	= pub.funSplitString(@RepOptions, '@', 16);

	if (@SelectedAcnt1	Is Null)	set @SelectedAcnt1 = 0
	if (@SelectedAcnt2	Is Null)	set @SelectedAcnt2 = 0
	if (@SelectedAcnt3	Is Null)	set @SelectedAcnt3 = 0
	if (@SelectedAcnt4	Is Null)	set @SelectedAcnt4 = 0

	IF (@ExportToExcel	Is Null)	SET @ExportToExcel = 0

	
	set @AcntStart1=acc.funGetAcntLayerStartandLen(1,1)
	set @AcntLen1=acc.funGetAcntLayerStartandLen(1,2)
	set @AcntStart2=acc.funGetAcntLayerStartandLen(2,1)
	set @AcntLen2=acc.funGetAcntLayerStartandLen(2,2)
	set @AcntStart3=acc.funGetAcntLayerStartandLen(3,1)
	set @AcntLen3=acc.funGetAcntLayerStartandLen(3,2)
	set @AcntStart4=acc.funGetAcntLayerStartandLen(4,1)
	set @AcntLen4=acc.funGetAcntLayerStartandLen(4,2)

	------------------------------------------------------------------------
	Set @StrQuery = ''
	Set @StrDscFldH1 = 'CAST('''' AS NVarChar(4000))'
	Set @StrDscFldH2 = 'CAST('''' AS NVarChar(4000))'
	Set @StrDscFldD1 = 'CAST('''' AS NVarChar(4000))'
	Set @StrDscFldD2 = 'CAST('''' AS NVarChar(4000))'
	set @StrDocDate = 'VD.DocDate'	
	
	set @StrOldSerialNo = '  cast(0 as int) minOldSerialNo ,cast(0 as int) maxOldSerialNo, VH.OldSerialNo'
	set @StrOldSerialNoGrpBy = '  VH.OldSerialNo'

	if (@UseOldSerial = 1)
		set @StrSerialNo = ' cast(0 as int) minSerialNo ,cast(0 as int) maxSerialNo, VH.OldSerialNo'
	else
		set @StrSerialNo = ' cast(0 as int) minSerialNo,cast(0 as int) maxSerialNo,VH.SerialNo'

	if (@UseOldSerial = 1)
		set @StrSerialNoGrpBy = '   VH.OldSerialNo'
	else
		set @StrSerialNoGrpBy = ' VH.SerialNo'
	
		
	if (@IsSummaryEx = 1)
	begin
		set @StrSerialNo = ' min(VH.SerialNo) minSerialNo,max(VH.SerialNo) maxSerialNo,cast(0 as int)'
		set @StrSerialNoGrpBy = ' min(VH.SerialNo) minSerialNo,max(VH.SerialNo) maxSerialNo,cast(0 as int)'
		set @StrOldSerialNo = ' min(OldSerialNo) minOldSerialNo ,max(OldSerialNo) maxOldSerialNo,cast(0 as int)'
		set @StrOldSerialNoGrpBy = ' min(OldSerialNo) minOldSerialNo ,max(OldSerialNo) maxOldSerialNo,cast(0 as int)'
		set @StrDocDate = '''----/--/--'' as DocDate'

	end;
	
	if (@IsSummaryDate = 1)
	begin
		set @StrSerialNo = ' min(VH.SerialNo) minSerialNo,max(VH.SerialNo) maxSerialNo,cast(0 as int)';
		set @StrSerialNoGrpBy = ' min(VH.SerialNo) minSerialNo,max(VH.SerialNo) maxSerialNo,cast(0 as int)';
		set @StrOldSerialNo = ' min(OldSerialNo) minOldSerialNo ,max(OldSerialNo) maxOldSerialNo,cast(0 as int)'
		set @StrOldSerialNoGrpBy = ' min(OldSerialNo) minOldSerialNo ,max(OldSerialNo) maxOldSerialNo,cast(0 as int)'
		set @IsSummary = 1;
		set @HeaderDesc1 = 0;
		set @HeaderDesc2 = 0;
		set @DetailDesc1 = 0;
		set @DetailDesc2 = 0;
	end;
		
	If	(@HeaderDesc1 = 1) 
		Set @StrDscFldH1 = ' VH.DocDesc '

	If	(@HeaderDesc2 = 1) 
		Set @StrDscFldH2 = ' VH.DocDesc2 '

	If	(@DetailDesc1 = 1) AND (@IsSummary <> 1)
		Set @StrDscFldD1 = ' VD.RecDesc '

	If	(@DetailDesc2 = 1) AND (@IsSummary <> 1)
		Set @StrDscFldD2 = ' VD.RecDesc2 '
		
	if @PartNumber<=2
	begin
		set @StrAcntCode1 = 'CAST(Substring(VD.AcntCode, 1, ' + LTrim(RTrim(Str(@LayerLen))) +') as VARCHAR(20))'
		set @StrAcntCode2 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart)) + ', ' + LTrim(Str(@AcntLen)) +')'
		set @StrPrevAcntCode = 'Substring(VD.AcntCode, 1, ' + LTrim(Str(@LayerLen)) +')'	
		set @StrAcntCode3 = '''-'''
		set @StrAcntCode4 = '''-'''
	end
	else
	begin
		set @StrAcntCode1 = 'CAST(Substring(VD.AcntCode, 1, ' + LTrim(Str(@AcntLen1)) +') as VARCHAR(20))'
		set @StrAcntCode2 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart2)) + ', ' + LTrim(Str(@AcntLen2)) +')'
		set @StrPrevAcntCode = 'Substring(VD.AcntCode, 1, ' + LTrim(Str(@AcntLen1)) +')'
		set @StrAcntCode3 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart3)) + ', ' + LTrim(Str(@AcntLen3)) +')'
		set @StrAcntCode4 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart4)) + ', ' + LTrim(Str(@AcntLen4)) +')'
	end	

	set @AcntCode1 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart1)) + ', ' + LTrim(Str(@AcntLen1)) +')'
	set @AcntCode2 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart2)) + ', ' + LTrim(Str(@AcntLen2)) +')'
	set @AcntCode3 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart3)) + ', ' + LTrim(Str(@AcntLen3)) +')'
	set @AcntCode4 = 'Substring(VD.AcntCode, ' + LTrim(Str(@AcntStart4)) + ', ' + LTrim(Str(@AcntLen4)) +')'
	
	--------نام لایه های پارت اول----------------------------------------------------------------------------------------------------------------------------------------------
	select @Layer11=Layer1,	@Layer12=Layer2	,@Layer13=Layer3	,@Layer14=Layer4 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=1
	set @Layer12=@Layer11+@Layer12
	set @Layer13=@Layer13+@Layer12
	set @Layer14=@Layer13+@Layer14

	--------نام لایه های پارت اول----------------------------------------------------------------------------------------------------------------------------------------------
	select @Layer21=Layer1,	@Layer22=Layer2	,@Layer23=Layer3	,@Layer24=Layer4 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=2
	set @Layer22=@Layer21+@Layer22
	set @Layer23=@Layer23+@Layer22
	set @Layer24=@Layer23+@Layer24
	--------نام لایه های پارت اول----------------------------------------------------------------------------------------------------------------------------------------------
	select @Layer31=Layer1,	@Layer32=Layer2	,@Layer33=Layer3	,@Layer34=Layer4 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=3
	set @Layer32=@Layer31+@Layer32
	set @Layer33=@Layer33+@Layer32
	set @Layer34=@Layer33+@Layer34
		select @Layer41=Layer1,	@Layer42=Layer2	,@Layer43=Layer3	,@Layer44=Layer4 from pub.tblCodeLayer where TableName='acc.tblAcnt' and PartNumber=4
	set @Layer42=@Layer41+@Layer42
	set @Layer43=@Layer43+@Layer42
	set @Layer44=@Layer43+@Layer44
	------------------------------------------------------------------------------------------------------------------------------------------------------
	set @SqlLayer = ''
	IF @IsSummary = 0
		set @SqlLayer=' Substring(' + @AcntCode1 + ',1,'+str(@Layer11)+') Layer1,[acc].[funGetAcntName](Substring(' + @AcntCode1 + ',1,'+str(@Layer11)+'),1 ,' + @LangID + ') Layer1Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer1,'''' Layer1Name ,'

	if @Layer12>@Layer11 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode1 + ',1,'+str(@Layer12)+') Layer2,[acc].[funGetAcntName](Substring(' + @AcntCode1 + ',1,'+str(@Layer12)+') ,1,' + @LangID + ') Layer2Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer2,'''' Layer2Name ,'
	if @Layer13>@Layer12 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode1 + ',1,'+str(@Layer13)+') Layer3,[acc].[funGetAcntName](Substring(' + @AcntCode1 + ',1,'+str(@Layer13)+') ,1,' + @LangID + ') Layer3Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer3,'''' Layer3Name ,'
	if @Layer14>@Layer13 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode1 + ',1,'+str(@Layer14)+') Layer4,[acc].[funGetAcntName](Substring(' + @AcntCode1 + ',1,'+str(@Layer14)+'),1 ,' + @LangID + ') Layer4Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer4,'''' Layer4Name ,'	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	
	IF @IsSummary = 0
		set @SqlLayer=@SqlLayer+' Substring(' + @AcntCode2 + ',1,'+str(@Layer21)+') Layer21,[acc].[funGetAcntName](Substring(' + @AcntCode2 + ',1,'+str(@Layer21)+') ,2,' + @LangID + ') Layer21Name ,'
	ELSE
		set @SqlLayer= @SqlLayer+ ' '''' Layer21,'''' Layer21Name ,'
		
	if @Layer22>@Layer21 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode2 + ',1,'+str(@Layer22)+') Layer22,[acc].[funGetAcntName](Substring(' + @AcntCode2 + ',1,'+str(@Layer22)+') ,2,' + @LangID + ') Layer22Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer22,'''' Layer22Name ,'
	if @Layer23>@Layer22 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode2 + ',1,'+str(@Layer23)+') Layer23,[acc].[funGetAcntName](Substring(' + @AcntCode2 + ',1,'+str(@Layer23)+') ,2,' + @LangID + ') Layer23Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer23,'''' Layer23Name ,'
	if @Layer24>@Layer23 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode2 + ',1,'+str(@Layer24)+') Layer24,[acc].[funGetAcntName](Substring(' + @AcntCode2 + ',1,'+str(@Layer24)+') ,2,' + @LangID + ') Layer24Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer24,'''' Layer24Name ,'	
	------------------------------------------------------------------------------------------------------------------------------------------------------
	
	IF @IsSummary = 0
		set @SqlLayer=@SqlLayer+' Substring(' + @AcntCode3 + ',1,'+str(@Layer31)+') Layer31,[acc].[funGetAcntName](Substring(' + @AcntCode3 + ',1,'+str(@Layer31)+'),3 ,' + @LangID + ') Layer31Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer31,'''' Layer31Name ,'
	if @Layer32>@Layer31 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode3 + ',1,'+str(@Layer32)+') Layer32,[acc].[funGetAcntName](Substring(' + @AcntCode3 + ',1,'+str(@Layer32)+') ,3,' + @LangID + ') Layer32Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer32,'''' Layer32Name ,'
	if @Layer33>@Layer32 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode3 + ',1,'+str(@Layer33)+') Layer33,[acc].[funGetAcntName](Substring(' + @AcntCode3 + ',1,'+str(@Layer33)+') ,3,' + @LangID + ') Layer33Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer33,'''' Layer33Name ,'
	if @Layer34>@Layer33 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode3 + ',1,'+str(@Layer34)+') Layer34,[acc].[funGetAcntName](Substring(' + @AcntCode3 + ',1,'+str(@Layer34)+') ,3,' + @LangID + ') Layer34Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer34,'''' Layer34Name ,'	
	------------------------------------------------------------------------------------------------------------------------------------------------------
			
	IF @IsSummary = 0
		set @SqlLayer=@SqlLayer+' Substring(' + @AcntCode4 + ',1,'+str(@Layer41)+') Layer41,[acc].[funGetAcntName](Substring(' + @AcntCode4 + ',1,'+str(@Layer41)+') ,4,' + @LangID + ') Layer41Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer41,'''' Layer41Name ,'
	if @Layer42>@Layer41 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode4 + ',1,'+str(@Layer42)+') Layer42,[acc].[funGetAcntName](Substring(' + @AcntCode4 + ',1,'+str(@Layer42)+'),4 ,' + @LangID + ') Layer42Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer42,'''' Layer42Name ,'
	if @Layer43>@Layer42 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode4 + ',1,'+str(@Layer43)+') Layer43,[acc].[funGetAcntName](Substring(' + @AcntCode4 + ',1,'+str(@Layer43)+') ,4,' + @LangID + ') Layer43Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer43,'''' Layer43Name ,'
	if @Layer44>@Layer43 and @IsSummary = 0
		set @SqlLayer= @SqlLayer+ ' Substring(' + @AcntCode4 + ',1,'+str(@Layer44)+') Layer44,[acc].[funGetAcntName](Substring(' + @AcntCode4 + ',1,'+str(@Layer44)+') ,4,' + @LangID + ') Layer44Name ,'
	else
		set @SqlLayer= @SqlLayer+ ' '''' Layer44,'''' Layer44Name ,'	
	
	IF @SqlLayer IS NULL SET @SqlLayer = ''
	------------------------------------------------------------------------------------------------------------------------------------------------------
	IF @ExportToExcel = 0
	BEGIN
		/* Set Select Clause */
		If (@IsSummary <> 1)	-- Detailed Select 
		begin
			Set @StrSelect = '
			SELECT	' + @StrSerialNo + ' as SerialNo,' + @StrOldSerialNo + ' as OldSerialNo, VD.DocDate, 
						Cast(' + @StrPrevAcntCode + ' As VarChar(20)) PrevAcntCode,'+@SqlLayer+'
						Cast(' + @StrAcntCode1 + ' As VarChar(20)) AcntCode,
						Cast(' + @StrAcntCode2 + ' As VarChar(20)) AcntCode2,
						Cast(' + @StrAcntCode3 + ' As VarChar(20)) AcntCode3,
						Cast(' + @StrAcntCode4 + ' As VarChar(20)) AcntCode4,
					VD.Debit, VD.Credit,
					pub.GetCodeName(' + @StrPrevAcntCode + ',' + @LangID + ') PrevAcntName, 
					acc.funGetAcntFullName(' + @StrPrevAcntCode + ') PrevAcntFullName,
					pub.GetCodeName(' + @StrAcntCode1 + ',' + @LangID + ') AcntName, 
					acc.funGetAcntFullName(' + @StrAcntCode1 + ') AcntFullName,
					A2.AcntName AcntName2, 
					acc.funGetAcntFullName(' + @StrAcntCode2 + ') AcntFullName2 , P.ProcessName'
		
		if @PartNumber>=3
				Set @StrSelect =@StrSelect+ ' ,A3.AcntName AcntName3,acc.funGetAcntFullName(' + @StrAcntCode3 + ')AcntFullName3 '
			else
				Set @StrSelect =@StrSelect+ ' ,'''' AcntName3,'''' AcntFullName3 '
		if @PartNumber=4
			Set @StrSelect =@StrSelect+ ' ,A4.AcntName AcntName4,acc.funGetAcntFullName(' + @StrAcntCode4 + ')AcntFullName4 '
			else
				Set @StrSelect =@StrSelect+ ' ,'''' AcntName4,'''' AcntFullName4 '

		Set @StrSelect =@StrSelect+	',				(Case When VD.Credit = 0 Then 0 Else 1 End) AS DocTypeCode, ' +
			@StrDscFldH1 + ' AS DocDescription, '  +
			@StrDscFldH2 + ' AS DocAttachment, '   +
			@StrDscFldD1 + ' AS RowDescription1, ' +
			@StrDscFldD2 + ' AS RowDescription2 '  	
		end 
		Else -- Summary Select
		begin
			Set @StrSelect = '
			SELECT	' + @StrSerialNo + ' as SerialNo,' + @StrOldSerialNo + ' as OldSerialNo ,' + @StrDocDate+ ', 
					' + @StrPrevAcntCode + ' PrevAcntCode,' + @StrAcntCode1 + ' AcntCode, Sum(VD.Debit) Debit, Sum(VD.Credit) Credit,
					pub.GetCodeName(' + @StrPrevAcntCode + ', ' + @LangID + ') PrevAcntName,'+@SqlLayer+' 
					acc.funGetAcntFullName(' + @StrPrevAcntCode + ') PrevAcntFullName,
					pub.GetCodeName(' + @StrAcntCode1 + ', ' + @LangID + ') AcntName, 
					acc.funGetAcntFullName(' + @StrAcntCode1 + ') AcntFullName, 
					' + case when (@IsSummaryDate=1) then '0' else '(Case When VD.Credit = 0 Then 0 Else 1 End) ' end + ' as DocTypeCode, ' +
			@StrDscFldH1 + ' AS DocDescription, '  +
			@StrDscFldH2 + ' AS DocAttachment, '   +
			@StrDscFldD1 + ' AS RowDescription1, ' +
			@StrDscFldD2 + ' AS RowDescription2 '

		end
		-- =======================================
		-- ========== Set From Clause ===========
		Set @StrFrom = '
			From acc.tblVoucherHdr VH
					Inner Join acc.tblVoucherDtl VD ON VD.SerialNo = VH.SerialNo
					Left Join pub.tblProcess P on P.ProcessID=VD.SourceProcessID and P.ProcessNo=VD.SourceProcessNo '
		if (@IsSummary = 0)
			Set @StrFrom = @StrFrom + '	left join acc.tblAcntDtl A2 on A2.AcntCode = ' + @StrAcntCode2 + ' and A2.PartNumber=2 '	

		if @PartNumber>=3
			Set @StrFrom = @StrFrom + ' left join acc.tblAcntDtl A3 on A3.AcntCode = ' + @StrAcntCode3 + ' and A3.PartNumber=3 '

		if @PartNumber=4
			Set @StrFrom = @StrFrom + ' left join acc.tblAcntDtl A4 on A4.AcntCode = ' + @StrAcntCode4 + ' and A4.PartNumber=4 '
	END
	ELSE
	BEGIN
		SET @StrSelect ='
		SELECT  --VH.SerialNo AS SerialNo,
				--ROW_NUMBER() OVER (PARTITION BY VD.SerialNo,VD.SourceProcessID,VD.SourceProcessNo,VD.SourceFiscalYear,VD.SourceSerialNo ORDER BY VD.SerialNo,VD.DocRowNo) RowNo,
				DENSE_RANK() OVER (ORDER BY VD.DocDate,VD.SerialNo,VD.SourceProcessID,VD.SourceProcessNo,VD.SourceFiscalYear,VD.SourceSerialNo ) RowNo,
				VD.DocDate AS DocDate,
				' + CASE WHEN (@AcntLayerSum1 > 0) THEN + 'Cast(CAST(Substring(VD.AcntCode, 1,'+LTrim(RTrim(str(@AcntLayerSum1)))+') AS NVARCHAR(20)) As VarChar(20))' ELSE '''''' END + ' P1Code,
				' + CASE WHEN (@AcntLayerSum1 > 0) THEN + 'CASE WHEN Cast(CAST(Substring(VD.AcntCode, 1,'+LTrim(RTrim(str(@AcntLayerSum1)))+') AS NVARCHAR(20)) As VarChar(20)) <> '''' THEN [pub].[GetCodeName](CAST(Substring(VD.AcntCode, 1, '+LTrim(RTrim(str(@AcntLayerSum1)))+') AS NVARCHAR(20)),1) ELSE '''' END ' ELSE '''''' END + ' P1Name,
				' + CASE WHEN (@AcntLayerSum2 > 0) THEN + 'Cast(CAST(Substring(VD.AcntCode, 1, '+LTrim(RTrim(str(@AcntLayerSum2)))+') AS NVARCHAR(20)) As VarChar(20))' ELSE '''''' END + ' P2Code,
				' + CASE WHEN (@AcntLayerSum2 > 0) THEN + 'CASE WHEN Cast(CAST(Substring(VD.AcntCode, 1, '+LTrim(RTrim(str(@AcntLayerSum2)))+') AS NVARCHAR(20)) As VarChar(20)) <> '''' THEN [pub].[GetCodeName](CAST(Substring(VD.AcntCode, 1, '+LTrim(RTrim(str(@AcntLayerSum2)))+') AS NVARCHAR(20)),1) ELSE '''' END' ELSE '''''' END + ' P2Name,
				--' + CASE WHEN (@AcntLayerSum3 > 0) THEN + 'Cast(CAST(Substring(VD.AcntCode, '+ LTrim(RTrim(str(@AcntLayerStart3))) +', '+LTrim(RTrim(str(@AcntLayerSum3)))+') AS NVARCHAR(20)) As VarChar(20))' ELSE '''''' END + ' P3Code ,
				--' + CASE WHEN (@AcntLayerSum3 > 0) THEN + 'CASE WHEN Cast(CAST(Substring(VD.AcntCode, '+ LTrim(RTrim(str(@AcntLayerStart3))) +', '+LTrim(RTrim(str(@AcntLayerSum3)))+') AS NVARCHAR(20)) As VarChar(20)) <> '''' THEN [pub].[GetCodeName](CAST(Substring(VD.AcntCode, 1, '+LTrim(RTrim(str(@AcntLayerSum3)))+') AS NVARCHAR(20)),1) ELSE '''' END ' ELSE '''''' END + ' P3Name ,
				SUBSTRING(VD.RecDesc,1,255) DocDesc,
				CAST (CASE WHEN VD.Debit <> 0 THEN VD.Debit ELSE NULL END AS Decimal(18)) AS Debit, 
				CAST (CASE WHEN VD.Credit <> 0 THEN VD.Credit ELSE NULL END AS Decimal(18)) AS Credit
		'
		Set @StrFrom ='
		FROM acc.tblVoucherHdr VH
		INNER JOIN acc.tblVoucherDtl VD ON VD.SerialNo = VH.SerialNo
		LEFT JOIN pub.tblProcess P ON P.ProcessID = VD.SourceProcessID AND P.ProcessNo = VD.SourceProcessNo'
	END
	
	-- =======================================
	-- ========== Set Where Clause ===========
	Set @StrWhere = '(VD.VchKind <> 0)'

	If (@DateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.DocDate >= ''' + @DateFr + ''')'

	If (@DateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.DocDate <= ''' + @DateTo + ''')'

	If (@SerialNoFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + ')'
	If (@SerialNoTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VD.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')'

	If (@SerialOldFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VH.OldSerialNo >= ' + LTrim(Str(@SerialOldFr)) + ')'
	If (@SerialOldTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (VH.OldSerialNo <= ' + LTrim(Str(@SerialOldTo)) + ')'
	
	if (@SelectedAcnt1 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'VD.AcntCode')
	if (@SelectedAcnt2 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'VD.AcntCode')
	if (@SelectedAcnt3 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'VD.AcntCode')
	if (@SelectedAcnt4 > 0)
		set @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'VD.AcntCode')
	-- Filter Starting Doc Rows
	If (@IncludePrimary = 0)
		SET @StrWhere = @StrWhere + ' AND (VD.VchKind <> 2) '
	-- Filter Finish Doc Rows
	If (@IncludeFinish = 0)
		SET @StrWhere = @StrWhere + ' AND (VD.VchKind <> 3) '
	-- Filter Closing Doc Rows
	If (@IncludeClosed = 0)
		SET @StrWhere = @StrWhere  + ' AND (VD.VchKind <> 4) '
	if (@ShowEntezami <> 1)
	begin
		declare @P1L1	int;
		select	@P1L1 = Layer1
		from	pub.tblCodeLayer 
		where	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)
		Set @StrWhere = @StrWhere  + ' AND Substring(VD.AcntCode, 1, ' + LTrim(Str(@P1L1)) + ') not in (select AcntCode from acc.tblAcnt where (PartNumber = 1) and (AcntType in (91,92)))'
	end
	if @ShowNoteVchKind = 'False'
		Set @StrWhere = @StrWhere  +' AND (VD.VchKind > 0)'
	ELSE
		Set @StrWhere =@StrWhere  + 'AND (1=1)'

	Set @StrQuery = @StrSelect + RTrim(LTrim(@StrFrom)) + '
		WHERE ' + LTrim(RTrim(@StrWhere))

	-- =======================================
	-- =========== Group By Clause ===========	
	IF @ExportToExcel = 0
	BEGIN
		If (@IsSummary = 1)
		Begin
			if (@IsSummaryDate = 1)
				Set @StrQuery = @StrQuery + 'GROUP BY VD.DocDate, (Case When VD.Credit = 0 Then 0 Else 1 End), OldSerialNo,' + @StrAcntCode1 + ',' + @StrPrevAcntCode
			else
				if (@IsSummaryEx = 1)
					Set @StrQuery = @StrQuery + '	GROUP BY (Case When VD.Credit = 0 Then 0 Else 1 End), ' + @StrAcntCode1 + ',' + @StrPrevAcntCode
				else
					Set @StrQuery = @StrQuery + '	GROUP BY ' + @StrSerialNoGrpBy + ', ' + @StrOldSerialNoGrpBy + ', (Case When VD.Credit = 0 Then 0 Else 1 End),OldSerialNo, ' + @StrAcntCode1 + ',' + @StrPrevAcntCode + ', VD.DocDate '
		
			If (@HeaderDesc1 = 1)
				Set @StrQuery = @StrQuery + ', ' + @StrDscFldH1
			If (@HeaderDesc2 = 1)
				Set @StrQuery = @StrQuery + ', ' + @StrDscFldH2
		End
	END
	--ELSE
	--BEGIN
	--	Set @StrQuery = @StrQuery  + '
	--	GROUP BY VD.DocDate, (Case When VD.Credit = 0 Then 0 Else 1 End), (Case When VD.Debit = 0 Then 0 Else 1 End)'
	--END

	/* --------------------------- */
	/* --- Set Order By Clause --- */
	IF @ExportToExcel = 0
	BEGIN
		If (@IsSummary = 1)
			if (@IsSummaryDate = 1)
				Set @StrQuery = @StrQuery + '
			ORDER BY VD.DocDate, (Case When VD.Credit = 0 Then 0 Else 1 End), ' + @StrAcntCode1
			else
			if (@IsSummaryEx = 1)
				Set @StrQuery = @StrQuery + '
			ORDER BY (Case When VD.Credit = 0 Then 0 Else 1 End), ' + @StrAcntCode1
			else
			begin
				If (@SortByDate = 1)
					Set @StrQuery = @StrQuery + '
			ORDER BY VD.DocDate,SerialNo'
				Else 
					Set @StrQuery = @StrQuery + '
			ORDER BY SerialNo'
			end
		ELSE
		BEGIN
			if (@IsSummaryDate = 1)
				Set @StrQuery = @StrQuery + '
			ORDER BY VD.DocDate, ' + @StrAcntCode1
			else
			if (@IsSummaryEx = 1)
			begin
				If (@SortByDate = 1)
				Set @StrQuery = @StrQuery + '
				ORDER BY VD.DocDate, DocTypeCode, VD.RowNo' 
				Else /* Sort By SerialNo */
				Set @StrQuery = @StrQuery + '
				ORDER BY DocTypeCode, VD.RowNo' 
			end
			else
			begin

				If (@SortByDate = 1)
				Set @StrQuery = @StrQuery + '
				ORDER BY VD.DocDate, ' + @StrSerialNoGrpBy + ', DocTypeCode, VD.RowNo' 
				Else /* Sort By SerialNo */
				Set @StrQuery = @StrQuery + '
				ORDER BY ' + @StrSerialNoGrpBy + ', DocTypeCode, VD.RowNo' 
			end
		END
	END
	ELSE
	BEGIN
		If (@IsSummary = 1)
			if (@IsSummaryDate = 1)
				Set @StrQuery = @StrQuery + '
			ORDER BY RowNo,VH.SerialNo,VD.DocDate, (Case When VD.Credit = 0 Then 0 Else 1 End)'
			else
			if (@IsSummaryEx = 1)
				Set @StrQuery = @StrQuery + '
			ORDER BY RowNo,VH.SerialNo,(Case When VD.Credit = 0 Then 0 Else 1 End)'
			else
			begin
				If (@SortByDate = 1)
					Set @StrQuery = @StrQuery + '
			ORDER BY RowNo,VH.SerialNo,VD.DocDate'
				Else 
					Set @StrQuery = @StrQuery + '
			ORDER BY RowNo,VH.SerialNo'
			end
		ELSE
		BEGIN
			if (@IsSummaryDate = 1)
				Set @StrQuery = @StrQuery + '
			ORDER BY RowNo,VH.SerialNo,VD.DocDate'
			else
			if (@IsSummaryEx = 1)
			begin
				If (@SortByDate = 1)
				Set @StrQuery = @StrQuery + '
				ORDER BY RowNo,VH.SerialNo,VD.DocDate' 
				Else /* Sort By SerialNo */
				Set @StrQuery = @StrQuery + '
				ORDER BY RowNo,VH.SerialNo' 
			end
			else
			begin

				If (@SortByDate = 1)
				Set @StrQuery = @StrQuery + '
				ORDER BY RowNo,VD.DocDate, ' + @StrSerialNoGrpBy 
				Else /* Sort By SerialNo */
				Set @StrQuery = @StrQuery + '
				ORDER BY RowNo,' + @StrSerialNoGrpBy 
			end
		END
	END
	/* --------------------------- */

	Print @StrQuery;    
	Exec sp_executesql @StrQuery;
	
END
GO
