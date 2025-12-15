USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/11/19
-- Viewed By	 : 
-- Last Modified : 1388/03/11
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : <Balancing Summary 2>
-- ----------------------------------------------
-- جمع برای ترازنامه جدید
-- ==============================================
CREATE PROCEDURE [acc].[RptAcc_Balancing_Sum] 
	@AcntTypeList	VarChar(50),
	@DateFr			Char(10) = Null, 
	@DateTo			Char(10) = Null,
	@IncludeFinishDocs	Bit = 1, -- اختتامیه
	@IncludeClosedDocs	Bit = 1 -- بستن حساب
WITH ENCRYPTION
AS
DECLARE @StrSelect		NVarChar(2000)
DECLARE @StrWhere		NVarChar(1000)
DECLARE @StrLayer1Len	NVarChar(100)
DECLARE @StrPreRemain	NVarChar(500)

BEGIN
	SET NOCOUNT ON;

	IF (@IncludeFinishDocs Is Null)	SET @IncludeFinishDocs = 1
	IF (@IncludeClosedDocs Is Null)	SET @IncludeClosedDocs = 1

	SELECT	@StrLayer1Len = Cast(Layer1 AS VarChar(2))
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	IF (@DateFr Is Not Null) AND LTrim(RTrim(@DateFr)) <> '0'
		SET @StrPreRemain = 'CASE WHEN (DocDate < ''' + @DateFr + ''') THEN (D.Debit - D.Credit) ELSE 0 END'
	ELSE
		SET @StrPreRemain = 'CASE WHEN (D.VchKind = 2) THEN (D.Debit - D.Credit) ELSE 0 END'
		

	-- Where Clause --------------------------
	SET @StrWhere = '(D.VchKind <> 0) AND (A.AcntType IN (' + @AcntTypeList + '))';

	IF	(@DateTo Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.DocDate <= ''' + @DateTo + ''')'

	If (@IncludeFinishDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 3)'

	If (@IncludeClosedDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 4)'

	-- Select Clause --------------------------
	SET @StrSelect = '
		SELECT	SUM(D.Debit - D.Credit) AS CurRemainSum,
				SUM(' + @StrPreRemain + ') AS PreRemainSum
		FROM	acc.tblVoucherDtl D 
					INNER JOIN acc.tblAcnt A ON	(LEFT(D.AcntCode, ' + @StrLayer1Len + ') = A.AcntCode) AND (PartNumber = 1)
		WHERE	' + @StrWhere  
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
