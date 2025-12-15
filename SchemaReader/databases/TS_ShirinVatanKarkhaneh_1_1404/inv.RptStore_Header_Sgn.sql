USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Creation Date : 1393/01/16
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE inv.RptStore_Header_Sgn
	@ProcessID			Int = 90,  -- default is sale
	@ProcessNo			Int = Null,
	@FiscalYearFr		Int = Null,
	@SerialNoFr			Int = Null,
	@FiscalYearTo		Int = Null,
	@SerialNoTo			Int = Null,
	@DocDateFr			VarChar(60) = Null,
	@DocDateTo			VarChar(60) = Null,
	@VchNoFr			Int = Null,
	@VchNoTo			Int = Null,
	@SelectedStore		Int = Null,
	@SelectedStore2		Int = Null,
	@SelectedAcnt1		Int = 0, 
	@SelectedAcnt2		Int = 0, 
	@SelectedAcnt3		Int = 0, 
	@SelectedAcnt4		Int = 0, 
	@RepOptions			VarChar(20) = '12',
	@SortFields			NVarChar(100) = Null,
	@RepInfo			NVarChar(100) = '1@1@1',
	@ExtraParams		NVarChar(200) = ''
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(max);
DECLARE @StrFrom	NVarChar(max);
DECLARE @StrWhere	NVarChar(max);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID	Int; -- برای حالت کدهای انتخابی

DECLARE @SignLevel	int;
DECLARE @UseVch2	bit;
DECLARE @Vch		varchar(20);

DECLARE @HasSgn1	bit;
DECLARE @HasSgn2	bit;
DECLARE @HasSgn3	bit;
DECLARE @HasSgn4	bit;
DECLARE @HasSgn5	bit;
DECLARE @NotSgn1	bit;
DECLARE @NotSgn2	bit;
DECLARE @NotSgn3	bit;
DECLARE @NotSgn4	bit;
DECLARE @NotSgn5	bit;
DECLARE @Sgn1		int;
DECLARE @Sgn2		int;
DECLARE @Sgn3		int;
DECLARE @Sgn4		int;
DECLARE @Sgn5		int;
DECLARE @db_0000   nvarchar(50)

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	-- Init -------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1';
	IF (@ProcessNo	Is Null)	SET @ProcessNo = 1;
	If (@ExtraParams Is Null)   SET @ExtraParams = '';
	IF (@RepOptions	Is Null)	SET @RepOptions = '11'

	IF (@DocDateFr	Is Null)	SET @DocDateFr = '@@@';
	IF (@DocDateTo	Is Null)	SET @DocDateTo = '@@@';

	IF (@SelectedStore	Is Null)	SET @SelectedStore = 0
	IF (@SelectedStore2 Is Null)	SET @SelectedStore2 = 0
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0

	IF (@FiscalYearFr Is Null)	SET @SerialNoFr = Null;
	IF (@FiscalYearTo Is Null)	SET @SerialNoTo = Null;
	IF (@SerialNoFr	Is Null)	SET @FiscalYearFr = Null;
	IF (@SerialNoTo	Is Null)	SET @FiscalYearTo = Null;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	SET @UseVch2	= Substring(@RepOptions, 1, 1);
	SET @SignLevel	= Substring(@RepOptions, 2, 1);
		
	SET @Sgn1		= pub.funSplitString(@RepInfo, '@', 6);
	SET @Sgn2		= pub.funSplitString(@RepInfo, '@', 7);
	SET @Sgn3		= pub.funSplitString(@RepInfo, '@', 8);
	SET @Sgn4		= pub.funSplitString(@RepInfo, '@', 9);
	SET @Sgn5		= pub.funSplitString(@RepInfo, '@', 10);	
	SET @HasSgn1	= pub.funSplitString(@RepInfo, '@', 11);
	SET @HasSgn2	= pub.funSplitString(@RepInfo, '@', 12);
	SET @HasSgn3	= pub.funSplitString(@RepInfo, '@', 13);
	SET @HasSgn4	= pub.funSplitString(@RepInfo, '@', 14);
	SET @HasSgn5	= pub.funSplitString(@RepInfo, '@', 15);
	SET @NotSgn1	= pub.funSplitString(@RepInfo, '@', 16);
	SET @NotSgn2	= pub.funSplitString(@RepInfo, '@', 17);
	SET @NotSgn3	= pub.funSplitString(@RepInfo, '@', 18);
	SET @NotSgn4	= pub.funSplitString(@RepInfo, '@', 19);
	SET @NotSgn5	= pub.funSplitString(@RepInfo, '@', 20);
	
	-- Where Clause -----------------------------------------
	SET @StrWhere = ' H.ProcessID = ' + LTrim(Str(@ProcessID))

	If (@ProcessNo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND H.ProcessNo = ' + LTrim(Str(@ProcessNo))

	If (@SerialNoFr Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear > ' + LTrim(Str(@FiscalYearFr)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearFr)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNoFr)) + '))' 
	If (@SerialNoTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ' OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + '))' 

	IF @ProcessID <> 180
	BEGIN
		IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
			SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
		IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
			SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', 'H.DocDate3', 'H.DocDate4')
	END
	ELSE
	BEGIN
		IF (@DocDateFr Is Not Null) AND (@DocDateFr <> '@@@')
			SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateFr, '>=', 'H.DocDate', 'H.DocDate2', '', '')
		IF (@DocDateTo Is Not Null) AND (@DocDateTo <> '@@@')
			SET @StrWhere = @StrWhere + ' AND ' + inv.funGetDateFilter(@DocDateTo, '<=', 'H.DocDate', 'H.DocDate2', '', '')
	END

	if (@UseVch2 = 1)
		begin
			if @ProcessID <> 180
				set @Vch = 'H.VchNo2'
			else
				set @Vch = 'H.VchNo'
		end
	else
		set @Vch = 'H.VchNo'

	If (@VchNoFr Is Not Null) OR (@VchNoTo Is Not Null)
		If (@VchNoFr = @VchNoTo)
			SET @StrWhere = @StrWhere + ' AND ' + @Vch + '=' + LTrim(Str(@VchNoFr))
		Else
		Begin
			If (@VchNoFr Is Not Null)
				SET @StrWhere = @StrWhere + ' AND ' + @Vch + ' >= ' + LTrim(Str(@VchNoFr))
			If (@VchNoTo Is Not Null)
				SET @StrWhere = @StrWhere + ' AND ' + @Vch + ' <= ' + LTrim(Str(@VchNoTo))
		End

	If (@SelectedStore > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore, 'H.StoreID') 
	If (@SelectedStore2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedStore2, 'H.StoreID2')

	-- Acnt Filter 
	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'H.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'H.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'H.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'H.AcntCode')

	if (@SignLevel = 1) SET @StrWhere = @StrWhere + ' AND (H.SgnSN1 <> 0)'
	if (@SignLevel = 2) SET @StrWhere = @StrWhere + ' AND (H.SgnSN2 <> 0)'
	if (@SignLevel = 3) SET @StrWhere = @StrWhere + ' AND (H.SgnSN3 <> 0)'
	if (@SignLevel = 4) SET @StrWhere = @StrWhere + ' AND (H.SgnSN4 <> 0)'
	if (@SignLevel = 5) SET @StrWhere = @StrWhere + ' AND (H.SgnSN5 <> 0)'


	IF @Sgn1 <> '-1' and @HasSgn1 = 1
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN1)=' + str(@Sgn1) + ' '
	IF @Sgn2 <> '-1' and @HasSgn2 = 1
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN2)=' + str(@Sgn2) + ' '
	IF @Sgn3 <> '-1' and @HasSgn3 = 1
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN3)=' + str(@Sgn3) + ' '
	IF @Sgn4 <> '-1' and @HasSgn4 = 1
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN4)=' + str(@Sgn4) + ' '
	IF @Sgn5 <> '-1' and @HasSgn5 = 1
		Set @StrWhere = @StrWhere + ' And ' + ltrim(rtrim(@db_0000)) + '.pub.funGetUserID(H.SgnSN5)=' + str(@Sgn5) + ' '

	IF @HasSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1<>0 '
	IF @HasSgn2 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN2<>0 '
	IF @HasSgn3 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN3<>0 '
	IF @HasSgn4 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN4<>0 '
	IF @HasSgn5 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN5<>0 '

	IF @NotSgn1 = 1
		Set @StrWhere = @StrWhere + ' And H.SgnSN1=0 '
	IF @NotSgn2 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN2=0 '
	IF @NotSgn3 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN3=0 '
	IF @NotSgn4 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN4=0 '
	IF @NotSgn5 = 1								  
		Set @StrWhere = @StrWhere + ' And H.SgnSN5=0 '

	---------------------------------------------------------
	-- SELECT Clause ----------------------------------------

	IF @ProcessID <> 180
		SET @StrSelect = '
		SELECT H.ProcessID,
			   H.ProcessNo,
			   H.FiscalYear,
			   H.SerialNo,
			   H.DocStep,
			   H.DocDate,
			   H.StoreID, 
			   S1.StoreName, 
			   S2.StoreName StoreName2,
			   H.BaseProcessID,
			   H.BaseProcessNo,
			   H.BaseFiscalYear,
			   H.BaseSerialNo,
			   H.AcntCode,
			   H.VchNo,
			   H.VchNo2,
			   H.VchDate,
			   H.DocDesc,
			   H.DocDate2,
			   H.DocDate3,
			   H.DocDate4,
			   pub.GetCodeName(H.AcntCode, ' + @LangID + ') AS AcntName,
			   LD.LocationName,
			   F.Tel, 
			   F.Address1 + '' '' + F.Address2 AcntAddress, 
			   F.Mobile,
			   case when H.SgnSN1=0 then '''' else pub.GetUserName(H.SgnSN1) end Signer1Name,
			   case when H.SgnSN2=0 then '''' else pub.GetUserName(H.SgnSN2) end Signer2Name,
			   case when H.SgnSN3=0 then '''' else pub.GetUserName(H.SgnSN3) end Signer3Name,
			   case when H.SgnSN4=0 then '''' else pub.GetUserName(H.SgnSN4) end Signer4Name,
			   case when H.SgnSN5=0 then '''' else pub.GetUserName(H.SgnSN5) end Signer5Name
		FROM inv.vwStorageDocsHdr H 
				LEFT JOIN inv.tblStoresDtl S1 ON H.StoreID  = S1.StoreID AND S1.LanguageID = ' + @LangID + '
				LEFT JOIN inv.tblStoresDtl S2 ON H.StoreID2 = S2.StoreID AND S2.LanguageID = ' + @LangID + '
				LEFT JOIN sal.tblTransportersDtl TR ON TR.TransporterID = H.TransporterID 
				OUTER APPLY acc.funGetCodeInfo(H.AcntCode) F
				LEFT JOIN pub.tblLocationsDtl LD ON LD.LocationID = F.LocationID 
		WHERE ' + @StrWhere
	ELSE
		SET @StrSelect = '
		SELECT H.ProcessID,
			   H.ProcessNo,
			   H.FiscalYear,
			   H.SerialNo,
			   H.DocStep,
			   H.DocDate,
			   H.StoreID, 
			   S1.StoreName, 
			   '''' StoreName2,
			   H.BaseProcessID,
			   H.BaseProcessNo,
			   H.BaseFiscalYear,
			   H.BaseSerialNo,
			   H.AcntCode,
			   H.VchNo,
			   0 VchNo2,
			   '''' VchDate,
			   H.DocDesc,
			   H.DocDate2,
			   '''' DocDate3,
			   '''' DocDate4,
			   pub.GetCodeName(H.AcntCode, ' + @LangID + ') AS AcntName,
			   LD.LocationName, 
			   F.Tel, 
			   F.Address1 + '' '' + F.Address2 AcntAddress, 
			   F.Mobile,
			   case when H.SgnSN1=0 then '''' else pub.GetUserName(H.SgnSN1) end Signer1Name,
			   case when H.SgnSN2=0 then '''' else pub.GetUserName(H.SgnSN2) end Signer2Name,
			   case when H.SgnSN3=0 then '''' else pub.GetUserName(H.SgnSN3) end Signer3Name,
			   case when H.SgnSN4=0 then '''' else pub.GetUserName(H.SgnSN4) end Signer4Name,
			   case when H.SgnSN5=0 then '''' else pub.GetUserName(H.SgnSN5) end Signer5Name
		FROM sal.tblSaleOrderHdr H 
				LEFT JOIN inv.tblStoresDtl S1 ON H.StoreID  = S1.StoreID AND S1.LanguageID = ' + @LangID + '
				OUTER APPLY acc.funGetCodeInfo(H.AcntCode) F
				LEFT JOIN pub.tblLocationsDtl LD ON LD.LocationID = F.LocationID 
		WHERE ' + @StrWhere
	------------------------------------------------------------

	-- SORT Clause ---------------------------------------------
	If (@SortFields Is Not Null)
		Set @StrSelect = @StrSelect + ' 
	ORDER BY ' + @SortFields
	------------------------------------------------------------

	-- RUN -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
