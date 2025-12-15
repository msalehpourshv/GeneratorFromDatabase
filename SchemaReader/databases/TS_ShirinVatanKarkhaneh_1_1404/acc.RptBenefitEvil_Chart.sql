USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 1386/01/15
-- Viewed By	 : 
-- Last Modified : 1386/08/09
-- Description: Benefit And Evil Chart'      
-- =============================================
CREATE PROCEDURE [acc].[RptBenefitEvil_Chart]
	WITH ENCRYPTION
AS
	Declare @idx1 Int
	Declare @idx2 Int
	Declare @Month Char(2)

	Create Table #tblDays
	(
		Days Char(5) COLLATE Arabic_CS_AS
	);

	Create Table #tblResult
	(
		DocDate		Char(5) COLLATE Arabic_CS_AS, 
		Incoming	BigInt, 
		Expense		BigInt,
		MonthNo		Char(2) COLLATE Arabic_CS_AS, 
		IncomingMonth	BigInt, 
		ExpenseMonth	BigInt
	);
BEGIN -- ===== S T A R T ===============================================================

	SET NOCOUNT ON;
	Declare @Layer1Len Tinyint

	-- Set @Layer1Len ---
	SELECT @Layer1Len = Layer1
	FROM   pub.tblCodeLayer
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	-- Fill Table Variable With Year Days --
	Set @idx1 = 1
	While @idx1 <= 12
	Begin
		Set @idx2 = 1

		While @idx2 <= 31
		Begin
			Insert Into #tblDays	
			Values ( 
				Case When Len(LTrim(Str(@idx1))) < 2 Then '0' Else '' End + Ltrim(Str(@idx1)) + '/' + 
				Case When Len(LTrim(Str(@idx2))) < 2 Then '0' Else '' End + LTrim(Str(@idx2)))	
			Set @idx2 = @idx2 + 1
		End

		Set @idx1 = @idx1 + 1
	End

	------------------------------------
	-- Set @Layer1Len --------
	SELECT @Layer1Len = Layer1
	FROM   pub.tblCodeLayer
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)
	--------------------------
	-- Select ----------------
	INSERT INTO #tblResult(DocDate, Incoming, Expense, MonthNo)
	SELECT T.DocDate DocDate, Sum(T.RemainIncoming) Incoming, Sum(T.RemainExpense) Expense, Left(DocDate, 2) MonthNo
	FROM
	(
		SELECT	Case When A.AcntType = 41 Then (D.Credit - D.Debit) Else 0 End AS RemainIncoming,
				Case When A.AcntType IN (51,61,62) Then (D.Debit - D.Credit) Else 0 End AS RemainExpense , 
				RIGHT(DocDate, 5) DocDate
		FROM	acc.tblVoucherDtl D INNER JOIN acc.tblAcnt A On	A.PartNumber = 1 AND Left(D.AcntCode, @Layer1Len) = A.AcntCode
		WHERE	(D.VchKind NOT IN (0, 3, 4)) AND (A.AcntType IN (41,51,61,62))
		UNION ALL
		SELECT	0, 0, Days DocDate
		FROM	#tblDays
	) T
	GROUP BY T.DocDate
	Order By DocDate
	--------------------------------------------------------
	Set @idx1 = 1

	While @idx1 <= 12
	Begin
		Set @Month = Case When Len(LTrim(Str(@idx1))) < 2 Then '0' Else '' End + Ltrim(Str(@idx1)) 

		Update #tblResult	
		Set IncomingMonth =
			(	Select Sum(T.Incoming)
				From   #tblResult	T
				Where  LEFT(T.DocDate, 2) <= @Month	),
			ExpenseMonth =
			(	Select Sum(T.Expense)
				From   #tblResult	T
				Where  LEFT(T.DocDate, 2) <= @Month	),
			MonthNo = @Month
		Where LEFT(DocDate, 2) = @Month AND RIGHT(DocDate, 2) = '01'

		Set @idx1 = @idx1 + 1
	End

	Select *
	From #tblResult
END







GO
