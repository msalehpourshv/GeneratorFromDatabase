USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/01/16
-- Viewed By	 : 
-- Last Modified : 1386/08/09
-- Description: گزارش ترازنامه
-- =============================================
CREATE PROCEDURE [acc].[RptAcc_Balancing2]
	@DateFrom	Char(10) = Null,
	@DateTo		Char(10) = Null,
	@HasSecondLayer	Bit = 0, -- شامل لایه دوم باشد یا نه؟
	@HasZeroRemain	Bit = 0 -- شامل حسابهای با مانده صفر باشد یا نه؟
WITH ENCRYPTION
AS
	Declare @StrSelect		NVarChar(2000)
	Declare @StrWhere		NVarChar(1000)
	Declare @StrLayer1Len	NVarChar(100)
	Declare @StrLayer2Len	NVarChar(100)
	Declare @StrAcntCode1	NVarChar(1000)
	Declare @StrAcntCode2	NVarChar(1000)
BEGIN
	SET NOCOUNT ON;

	Select	@StrLayer1Len = Cast(Layer1 AS VarChar(2)), @StrLayer2Len = Cast(Layer1 + Layer2 AS VarChar(2))
	From	pub.tblCodeLayer 
	Where	(TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	-- Where Clause --------------------------
	Set @StrWhere = '(D.VchKind <> 0) AND ((A.AcntType <> 1) AND (A.AcntType <> 2))';

	If	(@DateFrom Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (DocDate >= ''' + @DateFrom + ''')'

	If	(@DateTo Is Not Null)
		Set @StrWhere = @StrWhere + ' AND (DocDate <= ''' + @DateTo + ''')'

	-- Select Clause --
	Set @StrAcntCode1 = 'LEFT(D.AcntCode, ' + @StrLayer1Len + ')'

	Set @StrSelect = '
		SELECT	Cast(LEFT(D.AcntCode, ' + @StrLayer1Len + ') As VarChar(20)) AS AcntCode, 
				SUM(D.Debit - D.Credit) AS Remain, A.AcntType,
				pub.GetCodeName(' + @StrAcntCode1 + ', 1) AS AcntName
		FROM	acc.tblVoucherDtl D INNER JOIN acc.tblAcnt A ON
					(' + @StrAcntCode1 + ' = A.AcntCode) AND (PartNumber = 1)
		WHERE	' + @StrWhere + '
		GROUP BY ' + @StrAcntCode1 + ', A.AcntType'
	
	If (@HasSecondLayer = 1)	/* If Second Layer Reqiure Too */
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
		WHERE	' + @StrWhere + '
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
		ORDER BY T.AcntType, LEFT(T.AcntCode, ' + @StrLayer1Len + ')'
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
    
END
GO
