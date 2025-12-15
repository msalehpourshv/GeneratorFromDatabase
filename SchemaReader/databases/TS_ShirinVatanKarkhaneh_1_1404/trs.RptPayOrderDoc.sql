USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1388/05/03
-- Viewed By	 : 
-- Last Modified : 1393/03/31
-- Description	 : <Pay Order>
-- ----------------------------------------------
-- ����� �ѐ ����� ������
-- ==============================================
Create PROCEDURE [trs].[RptPayOrderDoc]
	@ProcessID		Int=0,
	@ProcessNo		Int=0,
	@FiscalYear		Int=0,
	@SerialNo		Int=0,
	@FiscalYearTo	Int=0,
	@SerialNoTo		Int=0,
	@RepInfo		NVarChar(100) = Null
WITH ENCRYPTION
As
DECLARE @LangID		Char(1)
DECLARE @SessionNo	VarChar(10)
DECLARE @ReportID	VarChar(10)
declare @db_0000	nvarchar(50)
declare @Select		nvarchar(4000)
declare @Today		char(10)
DECLARE @StrSelect		NVarChar(Max);
DECLARE @StrWhere		NVarChar(Max);

Begin  

	SET NOCOUNT ON;

	-- Init Variables -----------------------------------------------
	If (@RepInfo	Is Null)	SET @RepInfo    = '1@1@1'
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;

	SET	@LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	set @Today = pub.funFarsiDate(Getdate())
	-----------------------------------------------------------------
	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	
	-- Where ----------------------------------------
	IF (@FiscalYear Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	IF (@FiscalYearTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
	
	create table #tbl_PayOrderDoc_Signatures
	(
		UserID		int,
		UserSign	image
	);
	
	SET @StrSelect = '
	INSERT INTO #tbl_PayOrderDoc_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@db_0000)) + '.usr.tblUsers U '
		
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;		
	
	--=======================
	CREATE TABLE #tbl_Session1
	(
		SerialNo	Int,
		UserID		Int
	);
	
	SET @StrSelect = '
	INSERT INTO #tbl_Session1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo1)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_Session2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo2)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	CREATE TABLE #tbl_Session3
	(
		SerialNo	Int,
		UserID		Int	);

	SET @StrSelect = '
	INSERT INTO #tbl_Session3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo3)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

	--=======================
	CREATE TABLE #tbl_SgnSN1
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN1)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
	
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_SgnSN2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN2)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	

	--=======================
	CREATE TABLE #tbl_SgnSN3
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN3)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
			
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;		
		
	--=======================
	CREATE TABLE #tbl_SgnSN4
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN4(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN4)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	--=======================
	CREATE TABLE #tbl_SgnSN5
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN5(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN5)
	FROM trs.tblPayHdr H 
	Where ' + @StrWhere
		
	--PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;	
	
	SELECT	D.*,[pub].[funGetLocationName] (TargetLocationID,1)TargetLocationName, [pub].[funGetBankTypeName]  (TargetBankID, 1) TargetBankName , 
			pub.GetCodeName([trs].[funGetChequeOwner](D.VolumeFiscalYear, D.VolumeRowNo,D.PayTypeID), 1)  AS FirstCreditName,
			pub.funGetBankTypeName(D.BankTypeID, 1) AS BankTypeName,
			pub.GetCodeName(D.DebitCode,1) As DebitName, pub.GetCodeName(D.CreditCode, 1) As CreditName,
			pub.GetCodeName(D.VisitorAcntCode,1) As VisitorAcntName,
		    H.DebitCode AS DebitCodeHdr, H.CreditCode AS CreditCodeHdr,
			H.CollectorAcntCode, H.VchNo, H.DescHdr, L.LocationName, 
			pub.GetCodeName(H.DebitCode, @LangID) AS DebitNameHdr,
			pub.GetCodeName(H.CreditCode, @LangID) AS CreditNameHdr,
			pub.funFarsiDateDiff('Day', H.DocDate, Case When D.ChequeDate = '' Then H.DocDate Else D.ChequeDate End) AS Duration
			--pub.funFarsiDateDiff('Day', H.DocDate, case when D.ChequeDate = '' then '1300/01/01' else D.ChequeDate end) AS Duration,
			,
			H.Sgn1, H.Sgn2, H.Sgn3,
			Case When H.SessionNo=0 Then '''' Else pub.GetUserName(H.SessionNo) End SessionUserName0,
			Case When H.SessionNo1=0 Then '''' Else pub.GetUserName(H.SessionNo1) End SessionUserName1,
			Case When H.SessionNo2=0 Then '''' Else pub.GetUserName(H.SessionNo2) End SessionUserName2,
			Case When H.SessionNo3=0 Then '''' Else pub.GetUserName(H.SessionNo3) End SessionUserName3,
			Case When H.SessionNo4=0 Then '''' Else pub.GetUserName(H.SessionNo4) End SessionUserName4,
			Case When H.SgnSN1=0 Then '''' Else pub.GetUserName(H.SgnSN1) End UserName,
			Case When H.SgnSN2=0 Then '''' Else pub.GetUserName(H.SgnSN2) End UserName1,
			Case When H.SgnSN3=0 Then '''' Else pub.GetUserName(H.SgnSN3) end UserName2,
			Case When H.SgnSN4=0 Then '''' Else pub.GetUserName(H.SgnSN4) End UserName3,
			Case When H.SgnSN5=0 Then '''' Else pub.GetUserName(H.SgnSN5) End UserName4,
			S1.UserSign As UserSignature,
			--S1.UserSign As UserSignature1,
			--S2.UserSign As UserSignature2,
			--S3.UserSign As UserSignature3,
			S4.UserSign As UserSignature1,
			S5.UserSign As UserSignature2,
			S6.UserSign As UserSignature3,
			S4.UserSign As Signature1,
			S5.UserSign As Signature2,
			S6.UserSign As Signature3,
			S7.UserSign As Signature4,
			S8.UserSign As Signature5,
			F.*,F2.AccountNumber AccountNumber2,F2.ShabaAccountNumber ShabaAccountNumber2
	FROM	trs.tblPayDtl AS D
				INNER JOIN trs.tblPayHdr AS H ON D.ProcessID = H.ProcessID AND D.ProcessNo = H.ProcessNo AND D.FiscalYear = H.FiscalYear AND D.SerialNo = H.SerialNo
				OUTER APPLY acc.funGetCodeInfo(H.DebitCode) F
				OUTER APPLY acc.funGetCodeInfo(D.CreditCode) F2
				LEFT JOIN pub.tblLocationsDtl L ON L.LocationID = F.LocationID
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S1 on S1.UserID = (SELECT UserID FROM #tbl_Session1 Where SerialNo = H.SerialNo)
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S2 on S2.UserID = (SELECT UserID FROM #tbl_Session2 Where SerialNo = H.SerialNo)
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S3 on S3.UserID = (SELECT UserID FROM #tbl_Session3 Where SerialNo = H.SerialNo)
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S4 on S4.UserID = (SELECT UserID FROM #tbl_SgnSN1 Where SerialNo = H.SerialNo)
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S5 on S5.UserID = (SELECT UserID FROM #tbl_SgnSN2 Where SerialNo = H.SerialNo)
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S6 on S6.UserID = (SELECT UserID FROM #tbl_SgnSN3 Where SerialNo = H.SerialNo)
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S7 on S7.UserID = (SELECT UserID FROM #tbl_SgnSN4 Where SerialNo = H.SerialNo)
				LEFT  JOIN #tbl_PayOrderDoc_Signatures S8 on S8.UserID = (SELECT UserID FROM #tbl_SgnSN5 Where SerialNo = H.SerialNo)
	WHERE	(D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND 
			(D.FiscalYear >= @FiscalYear) AND (D.SerialNo >= @SerialNo) AND
			(D.FiscalYear <= @FiscalYearTo) AND (D.SerialNo <= @SerialNoTo)
End
GO
