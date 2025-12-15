USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/11/17
-- Viewed By	 : 
-- Last Modified : 1392/11/09
-- Last Modifier : TakroSystem\ZiA
-- Description	 : <Balancing 2>
-- ----------------------------------------------
-- ترازنامه جدید
-- ==============================================
CREATE PROCEDURE [acc].[RptAcc_Balancing] 
	@AcntType			VarChar(3),
	@DateFr				Char(10) = Null,
	@DateTo				Char(10) = Null,
	@HasSecondLayer		Bit = 0, -- شامل لایه دوم باشد یا نه؟
	@HasThirdLayer		Bit = 0, -- شامل لایه سوم باشد یا نه؟
	@HasZeroRemain		Bit = 0, -- شامل حسابهای با مانده صفر باشد یا نه؟
	@IncludeFinishDocs	Bit = 1, -- اختتامیه
	@IncludeClosedDocs	Bit = 1 -- بستن حساب
WITH ENCRYPTION
AS
DECLARE @StrSelect		NVarChar(2000)
DECLARE @StrWhere		NVarChar(1000)
DECLARE @StrLayer1Len	NVarChar(100)
DECLARE @StrLayer2Len	NVarChar(100)
DECLARE @StrLayer3Len	NVarChar(100)
DECLARE @StrAcntCode1	NVarChar(1000)
DECLARE @StrAcntCode2	NVarChar(1000)
DECLARE @StrAcntCode3	NVarChar(1000)
DECLARE @LangID			VarChar(2)
DECLARE @StrPreRemain	VarChar(2000)
DECLARE @StrFields		VarChar(4000)
BEGIN
	SET NOCOUNT ON;

	SET @LangID = LTrim(Str(pub.funGetCurrentLanguageID()));

	IF (@HasSecondLayer Is Null)	SET @HasSecondLayer = 0
	IF (@HasZeroRemain Is Null)		SET @HasZeroRemain = 0
	IF (@IncludeFinishDocs Is Null)	SET @IncludeFinishDocs = 1
	IF (@IncludeClosedDocs Is Null)	SET @IncludeClosedDocs = 1

	SELECT	@StrLayer1Len = Cast(Layer1 AS VarChar(2)), 
			@StrLayer2Len = Cast(Layer1 + Layer2 AS VarChar(2)),
			@StrLayer3Len = Cast(Layer1 + Layer2 + Layer3 AS VarChar(2))
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	-- Where Clause --------------------------
	SET @StrWhere = '(D.VchKind <> 0) AND (A.AcntType = ' + @AcntType + ')';

	IF	(@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DateTo + ''')'

	If (@IncludeFinishDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 3)'

	If (@IncludeClosedDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 4)'

	-- Select Clause --
	IF (@DateFr Is Not Null) AND LTrim(RTrim(@DateFr)) <> '0'
		SET @StrPreRemain = 'CASE WHEN (DocDate < ''' + @DateFr + ''') THEN (D.Debit - D.Credit) ELSE 0 END'
	ELSE
		SET @StrPreRemain = 'CASE WHEN (D.VchKind = 2) THEN (D.Debit - D.Credit) ELSE 0 END'
		
	SET @StrAcntCode1 = 'LEFT(D.AcntCode, ' + @StrLayer1Len + ')'

	SET @StrSelect = '
		SELECT	1 AS Layer, CAST(' + @StrAcntCode1 + ' As VarChar(20)) AS AcntCode, 
				pub.GetCodeName(' + @StrAcntCode1 + ', ' + @LangID + ') AS AcntName,
				SUM(D.Debit - D.Credit) AS CurRemain, 
				SUM(' + @StrPreRemain + ') AS PreRemain, AcntState
		FROM	acc.tblVoucherDtl D INNER JOIN acc.tblAcnt A ON
					(' + @StrAcntCode1 + ' = A.AcntCode) AND (PartNumber = 1)
		WHERE	' + @StrWhere + '
		GROUP BY ' + @StrAcntCode1 + ', AcntState '
	
	If (@HasSecondLayer = 1)	/* If Second Layer Reqiure Too */
	Begin
		SET @StrAcntCode2 = 'LEFT(D.AcntCode, ' + @StrLayer2Len + ')'

		SET @StrSelect = @StrSelect + '
		UNION ALL
		SELECT	2 AS Layer, CAST(' + @StrAcntCode2 + ' As VarChar(20)) AS AcntCode,
				pub.GetCodeName(' + @StrAcntCode2 + ', ' + @LangID + ') AS AcntName,
				SUM(D.Debit - D.Credit) AS CurRemain,
				SUM(' + @StrPreRemain + ') AS PreRemain, B.AcntState
		FROM	acc.tblVoucherDtl D 
				INNER JOIN acc.tblAcnt A ON (A.PartNumber = 1) AND (' + @StrAcntCode1 + ' = A.AcntCode)
				INNER JOIN acc.tblAcnt B ON	(B.PartNumber = 1) AND (' + @StrAcntCode2 + ' = B.AcntCode)
		WHERE	' + @StrWhere + '
		GROUP BY ' + @StrAcntCode2 + ', B.AcntState ' 
	End

	If (@HasThirdLayer = 1)	/* If Third Layer Reqiure Too */
	Begin
		SET @StrAcntCode3 = 'LEFT(D.AcntCode, ' + @StrLayer3Len + ')'

		SET @StrSelect = @StrSelect + '
		UNION ALL
		SELECT	3 AS Layer, CAST(' + @StrAcntCode3 + ' As VarChar(20)) AcntCode,
				pub.GetCodeName(' + @StrAcntCode3 + ', ' + @LangID + ') AcntName,
				SUM(D.Debit - D.Credit) CurRemain,
				SUM(' + @StrPreRemain + ') PreRemain, B.AcntState
		FROM	acc.tblVoucherDtl D 
				INNER JOIN acc.tblAcnt A ON (A.PartNumber = 1) AND (' + @StrAcntCode1 + ' = A.AcntCode)
				INNER JOIN acc.tblAcnt B ON	(B.PartNumber = 1) AND (' + @StrAcntCode3 + ' = B.AcntCode)
		WHERE	' + @StrWhere + '
		GROUP BY ' + @StrAcntCode3 + ', B.AcntState ' 
	End

	SET @StrSelect = '
		SELECT T.*
		FROM 
		(
		' + @StrSelect + '
		) T '

	If (@HasZeroRemain = 0) 
		SET @StrSelect = @StrSelect + '
		WHERE (T.CurRemain <> 0) '

	SET @StrSelect = @StrSelect + '
		ORDER BY T.AcntCode, Layer '
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
    
END
GO
