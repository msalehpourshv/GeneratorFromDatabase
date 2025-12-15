USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 87/06/24
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : انتقال امتیازها به سال مالی بعد
-- =============================================
CREATE PROCEDURE [acc].[SpTransferGrades]
	@NextFiscalYear Char(4),  -- (سال مالی بعد (چهار رقمی
	@BasePrice		BigInt,   -- مبلغ پایه امتیاز
	@IncludePrimDoc Bit		  -- احتساب سند افتتاحیه و اختتامیه
WITH ENCRYPTION
AS
DECLARE @CurYear		Char(4)
DECLARE @EndDate		Char(10)
DECLARE @NextDB			VarChar(100)
DECLARE @StrSQL			NVarChar(1000)
BEGIN 
--============= START ============================================================================================
	CREATE TABLE #tblTemp(
		MyAcntCode		Varchar(20), 
		MyAcntName		VarChar(200), 
		MyAcntComment	VarChar(200), 
		MyAcntRemain	BigInt, 
		MyInitialGrade	BigInt, 
		MyAllAcntGrade	BigInt)

	SET @CurYear = RIGHT(db_name(), 4)
	SET @EndDate = RTrim(LTRim(@NextFiscalYear + '/01/01'))

	INSERT INTO #tblTemp
	EXEC [acc].[RptAcntGrade] NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, 
				@EndDate, @BasePrice, 0, 0, 0, @IncludePrimDoc, 0, 1, 1, NULL

	SET @NextDB = db_name()
	SET @NextDB = LEFT(@NextDB, Len(@NextDB) - 4) + @NextFiscalYear

	SET @StrSQL = '
	UPDATE [' + @NextDB + '].[acc].[tblAcnt] 
	SET InitialGrad = IsNull(
		(
			SELECT MyAllAcntGrade + MyInitialGrade
			FROM #tblTemp
			WHERE MyAcntCode = AcntCode
		), 0)'

	EXEC sp_executesql @StrSQL;

	DROP TABLE #tblTemp

END
GO
