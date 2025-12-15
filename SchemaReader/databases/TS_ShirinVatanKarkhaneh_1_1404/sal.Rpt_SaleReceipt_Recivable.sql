USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Hamid
-- Create date   : 1395/04/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\Hamid
-- Description   : ������ ������� �� ������
-- =============================================
--EXEC [sal].[Rpt_SaleReceipt_Recivable] 1, 1, 90, 1, 96, 596, N'', N'111301 07 080700003@1.00@1.00@1.00@0.00'
CREATE PROCEDURE [sal].[Rpt_SaleReceipt_Recivable]
	@ProcessID		Int = 1,
	@ProcessNo		Int = Null,
	@BaseProcessID	Int = Null,
	@BaseProcessNo	Int = Null,
	@BaseFiscalYear	Int = Null,
	@BaseSerialNo	Int = Null,
	@RepInfo		NVarChar(100) = '1@1@1',
	@ExtraParams	NVarChar(500) = Null

WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrWhere	NVarChar(4000);

DECLARE @LangID		Char(1);
DECLARE @SessionNo	VarChar(10);
DECLARE @ReportID	VarChar(10);
DECLARE @Db0000		VarChar(50);

DECLARE @Eqal		NVarChar(2000);
DECLARE @Remain1	NVarChar(1);
DECLARE @Remain2	NVarChar(1);
DECLARE @Remain3	NVarChar(1);
DECLARE @Remain4	NVarChar(1);
DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int;

DECLARE @AcntCode	VarChar(20);

select @Db0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'

Begin --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

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
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
	
	-- ===========
	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len + 1;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len + 1;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len + 1;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)
			
	-- I N I T ----------------------------------------------------------------
	IF (@RepInfo	  Is Null)	SET @RepInfo     = '1@1@1'
	IF (@ProcessNo	  Is Null)	SET @ProcessNo   = 1;

	--IF (@FiscalYear		Is Null)	SET @SerialNo	    = Null;
	IF (@BaseFiscalYear Is Null)	SET @BaseSerialNo   = Null;
	--IF (@SerialNo	    Is Null)	SET @FiscalYear		= Null;
	IF (@BaseSerialNo	Is Null)	SET @BaseFiscalYear = Null;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
 
	IF Str(@LangID) = 0 
		SET @LangID = 1
		
	SET @AcntCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
	SET @Remain1			= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	SET @Remain2			= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	SET @Remain3			= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @Remain4			= LTrim(pub.funSplitString(@ExtraParams, '@', 5))		
	
	-- =================================================================
	SET @StrWhere = '
	H.ProcessID IN (1, 10, 17, 20, 21, 23, 40) AND H.ProcessNo = ' + LTrim(Str(@ProcessNo)) + ' AND 
    PD.ChequeNo Not IN (
							Select D.ChequeNo 
							From trs.tblPayHdr H
							Inner Join trs.tblPayDtl D ON D.ProcessID = H.ProcessID And D.ProcessNo = H.ProcessNo And
														  D.FiscalYear = H.FiscalYear And D.SerialNo = H.SerialNo
							Where H.ProcessID IN (12,22) And H.ProcessNo = 1 And D.PayTypeID IN (6, 26) 
					    ) AND PD.PayTypeID IN (6, 26) --AND PD.ProcessID NOT IN (12,22)
		 '

	--If (@BaseProcessID Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND (H.BaseProcessID = ' + LTrim(Str(@BaseProcessID)) + ')'
		
	--If (@BaseProcessNo Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND (H.BaseProcessNo = ' + LTrim(Str(@BaseProcessNo)) + ')'		

	--If (@BaseFiscalYear Is Not Null)
	--	SET @StrWhere = @StrWhere + ' AND (H.BaseFiscalYear = ' + LTrim(Str(@BaseFiscalYear)) + ' AND H.BaseSerialNo = ' + LTrim(Str(@BaseSerialNo)) + ')'
		
	SET @Eqal = '1 = 1'
	
	IF (@Remain1 = 1)
		SET @Eqal = @Eqal + ' AND Substring(VOL.CreditCode,' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ') = Substring(''' + LTrim(RTrim(@AcntCode)) + ''',' + LTrim(Str(@Part1Start)) + ',' + LTrim(Str(@Part1Len)) + ')'
	IF (@Remain2 = 1)
		SET @Eqal = @Eqal + ' AND Substring(VOL.CreditCode,' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ') = Substring(''' + LTrim(RTrim(@AcntCode)) + ''',' + LTrim(Str(@Part2Start)) + ',' + LTrim(Str(@Part2Len)) + ')'
	IF (@Remain3 = 1)
		SET @Eqal = @Eqal + ' AND Substring(VOL.CreditCode,' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ') = Substring(''' + LTrim(RTrim(@AcntCode)) + ''',' + LTrim(Str(@Part3Start)) + ',' + LTrim(Str(@Part3Len)) + ')'
	IF (@Remain4 = 1)
		SET @Eqal = @Eqal + ' AND Substring(VOL.CreditCode,' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ') = Substring(''' + LTrim(RTrim(@AcntCode)) + ''',' + LTrim(Str(@Part4Start)) + ',' + LTrim(Str(@Part4Len)) + ')'
				
	IF @Eqal <> '' 
		SET @StrWhere = @StrWhere + ' AND (' + @Eqal + ')'
						
	--============================
	SET @StrSelect = '
	SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.BaseProcessID, H.BaseProcessNo, H.BaseFiscalYear, H.BaseSerialNo,
		   H.BaseDocType, PD.Amount, PD.PayTypeID, PD.VolumeRowNo, PD.CurrencyTypeID, PD.CurrencyRate,
		   PD.CurrencyAmount, PD.LocationID, PD.LocationID2, PD.BankTypeID, ISNULL(BT.BankTypeName,'''') BankTypeName, PD.BankTypeID2, 
		   PD.BranchCode, PD.BranchName, PD.BranchCode2, PD.BranchName2, PD.AccountNo, PD.AccountNo2, PD.AccOwnerName, PD.AccOwnerName2, 
		   PD.ChequeNo, PD.ChequeBookID, PD.ChequeBookFiscalYear, PD.EventNo, PD.ChequeDate, PD.DeliverTo, PD.RowDesc, PD.BankSnNo, 
		   PD.AccountOwnerType,PD.DebitCode, pub.GetCodeName(PD.DebitCode, 1) AS DebitName,
		   PD.CreditCode, pub.GetCodeName(PD.CreditCode, 1) AS CreditName,
		   [pub].[GetUserName](H.SessionNo) AS UserName,
		   [pub].[GetUserName](H.SessionNo2) AS UserName2,
		   [pub].[GetUserName](H.SessionNo3) AS UserName3,
		   [pub].[GetUserName](H.SessionNo4) AS UserName4
	FROM	trs.tblPayDtl AS PD
	INNER JOIN trs.tblPayHdr H ON PD.ProcessID = H.ProcessID And PD.ProcessNo = H.ProcessNo And
								  PD.FiscalYear = H.FiscalYear And PD.SerialNo = H.SerialNo	
	LEFT  JOIN pub.tblLocationsDtl AS LD ON LD.LocationID = PD.LocationID AND LD.LanguageID = 1
	LEFT  JOIN trs.tblBankTypesDtl AS BT ON BT.BankTypeID = PD.BankTypeID AND BT.LanguageID = 1
	INNER JOIN 
	(
		SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo,
				(
					SELECT Top 1 CreditCode
					FROM	trs.tblPayDtl
					WHERE	ProcessID IN (1,10) AND 
							PayTypeID IN (6,26) AND 
							VolumeFiscalYear = PD2.VolumeFiscalYear AND
							VolumeRowNo = PD2.VolumeRowNo
					ORDER By EventNo ASC
				) AS CreditCode
		FROM	trs.tblPayDtl AS PD2
		WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo > -1
		GROUP BY VolumeFiscalYear, VolumeRowNo
	) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
			 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE ' + @StrWhere + '
	ORDER BY H.FiscalYear, H.SerialNo'

	--============================
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
END
GO
