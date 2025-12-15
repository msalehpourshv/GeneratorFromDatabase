USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 88/05/28
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE PROCEDURE [trs].[SpReplacePayableReturnCode]
	@strOldCode	varchar(20),
	@StrNewCode	varchar(20),
	@ProcessID	INT,
	@ProcessNo	TinyInt,
	@FiscalYear	SmallInt,
	@SerialNo	Int,
	@RowNo		Int

	WITH ENCRYPTION
AS

BEGIN
	
	UPDATE	trs.tblPayDtl 
	SET CreditCode = @StrNewCode
	WHERE	ProcessID = @ProcessID AND 
			ProcessNo = @ProcessNo AND 
			FiscalYear = @FiscalYear AND 
			SerialNo = @SerialNo AND 
			RowNo = @RowNo AND 
			CreditCode = @strOldCode

END












GO
