USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid	
-- Create date   : 1394/09/22
-- Viewed By	 : Hadi Sadeghi
-- Last Modified : 
-- Last Modifier : 
-- Description   : برگ رسید موقت انبار
-- =============================================
Create PROCEDURE [inv].[RptStore_TempReceipt_Doc2]
	@ProcessID		Int = 170, -- Temp Receipt Process ID
	@ProcessNo		Int = 1, 
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@BaseProcessID	Int = 150,
	@BaseProcessNo	Int = Null,
	@BaseFiscalYear	Int = Null,
	@BaseSerialNo	Int = Null,
	@GoodsID		Varchar(20) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
		
WITH ENCRYPTION
AS 

DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrSelectA	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrWhere2	NVarChar(4000);

DECLARE @LanguageID		TinyInt;
DECLARE @SessionNo		VarChar(10);
DECLARE @ReportID		VarChar(10);
DECLARE @IntProcessID	Int;

DECLARE @db_0000   nvarchar(50)
DECLARE @BaseDocRowNo	Int ;

Begin --============== S T A R T  C O D E ===================================================

	SET NoCount On;

	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

	-- ==========
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- ==========
	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID		Int,
		UserSign	Image
	);
	
	------
	SET @StrSelectA = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + ltrim(rtrim(@db_0000)) + '.usr.tblUsers U '
	
	--print @StrSelectA;
	Exec sp_executesql @StrSelectA;

	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	If (@ProcessNo	  Is Null)	SET @ProcessNo  = 1;
	If (@LanguageID	  Is Null)	SET @LanguageID = 1
	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo	  Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@GoodsID	  Is Null)	SET @GoodsID	= '';

	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);	
	SET @BaseDocRowNo	= pub.funSplitString(@RepInfo, '@', 6);	
	
	set @BaseDocRowNo=isnull(@BaseDocRowNo,0)
	IF @ProcessID = 170
		Set @IntProcessID = @BaseProcessID
	
	--============================= Where
	SET @StrWhere = 'C.ProcessID = ' + LTrim(RTrim(Str(@IntProcessID))) + ' AND C.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	SET @StrWhere2 = 'C.ProcessID = ' + LTrim(RTrim(Str(@IntProcessID))) + ' AND C.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	
	If (@FiscalYear	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (C.FiscalYear > ' + LTrim(RTrim(Str(@FiscalYear))) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND C.SerialNo >= ' + LTrim(RTrim(Str(@SerialNo))) + ')) '

		SET @StrWhere2 = @StrWhere2 + ' AND (C.FiscalYear > ' + LTrim(RTrim(Str(@FiscalYear))) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND C.SerialNo >= ' + LTrim(RTrim(Str(@SerialNo))) + ')) '		
	End

	If (@FiscalYearTo Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (C.FiscalYear < ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND C.SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo))) + ')) '
		
		SET @StrWhere2 = @StrWhere2 + ' AND (C.FiscalYear < ' + LTrim(RTrim(Str(@FiscalYearTo))) + ' OR 
		(C.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND C.SerialNo <= ' + LTrim(RTrim(Str(@SerialNoTo))) + ')) '		
	End

	If (@GoodsID Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND C.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''''	
		SET @StrWhere2 = @StrWhere2 + ' AND C.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''''	
	End
		
	If (@BaseProcessID	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (T.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (O.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
	End
	
	If (@BaseProcessNo	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (T.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (O.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
	End

	If (@BaseFiscalYear	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (T.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (O.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
	End
		
	If (@BaseSerialNo	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (T.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	
		SET @StrWhere2 = @StrWhere2 + ' AND (O.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	
	End
	If (@BaseDocRowNo>0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (T.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'	
		SET @StrWhere2 = @StrWhere2 + ' AND (O.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'	
	End

if @BaseProcessID=150
begin
		
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	Select TmpReceipt.*, H.DocDesc, S.StoreName, [pub].[funGetGoodsName](TmpReceipt.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName, U.UnitName,
		   pub.GetCodeName(TmpReceipt.AcntCode, ' + LTrim(RTrim(Str(@LanguageID))) + ') AcntName,
		   pub.GetUserName(H.SessionNo) AS UserName, S1.UserSign as UserSignature1
	From 
	(
		Select T.* 
		From cmr.tblCMRDtl C
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And T.BaseFiscalYear = C.FiscalYear And 
					T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo

		Where ' + @StrWhere + '
		Union
		--====
		Select T.* 
		From cmr.tblCMRDtl C
		Left Join cmr.tblOrderDtl O ON O.BaseProcessID = C.ProcessID And O.BaseProcessNo = C.ProcessNo And O.BaseFiscalYear = C.FiscalYear And 
					O.BaseSerialNo = C.SerialNo And O.BaseDocRowNo = C.DocRowNo

		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = O.ProcessID And T.BaseProcessNo = O.ProcessNo And T.BaseFiscalYear = O.FiscalYear And 
					T.BaseSerialNo = O.SerialNo And T.BaseDocRowNo = O.DocRowNo
					
		Where ' + @StrWhere2 + '
	)TmpReceipt
	INNER JOIN [inv].[tblInvTempReceiptHdr] H ON H.ProcessID = TmpReceipt.ProcessID AND H.ProcessNo = TmpReceipt.ProcessNo AND 
												 H.FiscalYear = TmpReceipt.FiscalYear AND H.SerialNo = TmpReceipt.SerialNo
	LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(TmpReceipt.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT  JOIN [inv].[tblUnitsDtl] U ON U.UnitID = TmpReceipt.SubUnitID AND U.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
	LEFT  JOIN [inv].[tblStoresDtl] S ON S.StoreID = TmpReceipt.StoreID AND S.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
	LEFT JOIN #tbl_Invoice_Signatures S1 on S1.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo) '
end 
else
begin
		
	-- S E L E C T ------------------------------------------------------------
	SET @StrSelect = '
	Select TmpReceipt.*, H.DocDesc, S.StoreName, [pub].[funGetGoodsName](TmpReceipt.GoodsID,' + LTrim(RTrim(@LanguageID)) + ') GoodsName, U.UnitName,
		   pub.GetCodeName(TmpReceipt.AcntCode, ' + LTrim(RTrim(Str(@LanguageID))) + ') AcntName,
		   pub.GetUserName(H.SessionNo) AS UserName, S1.UserSign as UserSignature1
	From 
	(
		Select T.* 
		From cmr.tblOrderDtl C
		Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And T.BaseFiscalYear = C.FiscalYear And 
					T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo

		Where ' + @StrWhere + '
		
	)TmpReceipt
	INNER JOIN [inv].[tblInvTempReceiptHdr] H ON H.ProcessID = TmpReceipt.ProcessID AND H.ProcessNo = TmpReceipt.ProcessNo AND 
												 H.FiscalYear = TmpReceipt.FiscalYear AND H.SerialNo = TmpReceipt.SerialNo
	LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID=SUBSTRING(TmpReceipt.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND GD.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT  JOIN [inv].[tblUnitsDtl] U ON U.UnitID = TmpReceipt.SubUnitID AND U.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
	LEFT  JOIN [inv].[tblStoresDtl] S ON S.StoreID = TmpReceipt.StoreID AND S.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
	LEFT JOIN #tbl_Invoice_Signatures S1 on S1.UserID = ' + ltrim(rtrim(@db_0000))+ '.[pub].[funGetUserID](H.SessionNo) '
end 
	--================================		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
End
GO
