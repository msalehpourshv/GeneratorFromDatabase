USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Create date   : 1392/10/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : <Gain And Loss Report>     
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_GainNLossEx]
	@DocDateFr		Char(10) = Null,
	@DocDateTo		Char(10) = Null,
	@HasSecondLayer	Bit = 0, -- شامل لایه دوم باشد یانه؟
	@HasZeroRemain	Bit = 0, -- شامل حسابهای با مانده صفر باشد یا نه؟
	@ShowFinishDocs	Bit = 1, -- اختتامیه
	@ShowClosedDocs	Bit = 1 -- بستن حساب
WITH ENCRYPTION
AS
Declare @StrSelect		NVarChar(2000)
Declare @StrWhere		NVarChar(1000)

Declare @StrAcntCode1	VarChar(1000)
Declare @StrAcntCode2	VarChar(1000)

Declare @StrLayer1Len	VarChar(2)
Declare @StrLayer2Len	VarChar(2)
declare @LanguageID		int;
BEGIN ------------------------------------------------------------------------

	SET NOCOUNT ON;

	SET @LanguageID = pub.funGetCurrentLanguageID();

	IF (@ShowFinishDocs Is Null)	SET @ShowFinishDocs = 1
	IF (@ShowClosedDocs Is Null)	SET @ShowClosedDocs = 1

	SELECT	@StrLayer1Len = Cast(Layer1 AS VarChar(2)), @StrLayer2Len = Cast(Layer1 + Layer2 AS VarChar(2))
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	-- Where Clause --
	Set @StrWhere = '(VchKind <> 0) 
		AND ((A.AcntType = 41) OR (A.AcntType = 51) OR (A.AcntType = 61) OR (A.AcntType = 62))
		AND not (D.AcntCode in (
				select SaleAcntCode
				from inv.tblStores
				union 
				select SaleCostAcntCode
				from inv.tblStores
				union 
				select SaleReturnAcntCode
				from inv.tblStores
				union 
				select SaleDiscountAcntCode
				from inv.tblStores
			) and D.SourceProcessID in (90, 100))'

	If (@DocDateFr Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DocDateFr + ''')'

	If (@DocDateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DocDateTo + ''')'

	If (@ShowFinishDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 3)'

	If (@ShowClosedDocs = 0)
		Set @StrWhere = @StrWhere + ' AND (VchKind <> 4)'

	-- Select Clause --
	Set @StrAcntCode1 = 'LEFT(D.AcntCode, ' + @StrLayer1Len + ')'
	
	Set @StrSelect = '
		SELECT	Cast(LEFT(D.AcntCode, ' + @StrLayer1Len + ') As VarChar(20)) AS AcntCode, 
				SUM(D.Debit - D.Credit) AS Remain, AcntType,
				pub.GetCodeName(' + @StrAcntCode1 + ', 1) AS AcntName
		FROM	acc.tblVoucherDtl D INNER JOIN acc.tblAcnt A ON
					(' + @StrAcntCode1 + ' = A.AcntCode) AND (PartNumber = 1)
		WHERE	' + @StrWhere + '
		GROUP BY ' + @StrAcntCode1 + ', AcntType'

	/* Second Layer is Needed */
	If (@HasSecondLayer = 1)
	Begin
		Set @StrAcntCode2 = 'LEFT(D.AcntCode, ' + @StrLayer2Len + ')'

		Set @StrSelect = @StrSelect + '
		UNION ALL
		SELECT	' + @StrAcntCode2 + ' AS AcntCode,
				Sum(D.Debit - D.Credit) AS Remain, A.AcntType AS AcntType,
				pub.GetCodeName(' + @StrAcntCode2 + ', 1) AS AcntName
		FROM	acc.tblVoucherDtl D 
				INNER JOIN acc.tblAcnt A ON
					(A.PartNumber = 1) AND (' + @StrAcntCode1 + ' = A.AcntCode)
				INNER JOIN acc.tblAcnt B ON
					(B.PartNumber = 1) AND (' + @StrAcntCode2 + ' = B.AcntCode)
		WHERE	Len(D.AcntCode) > ' + @StrLayer1Len + ' and ' + @StrWhere + '
		GROUP BY ' + @StrAcntCode2 + ', A.AcntType '
	End

	Set @StrSelect = '
		SELECT T.*
		FROM 
		(
		' + @StrSelect + '
		) T'

	If (@HasZeroRemain = 0) 
		Set @StrSelect = @StrSelect + '
		WHERE (T.Remain <> 0) '

	Set @StrSelect = @StrSelect + '
		ORDER BY T.AcntType, LEFT(T.AcntCode, ' + @StrLayer1Len + '), AcntCode'

	Print @StrSelect;
	Exec sp_executesql @StrSelect;
END
GO
