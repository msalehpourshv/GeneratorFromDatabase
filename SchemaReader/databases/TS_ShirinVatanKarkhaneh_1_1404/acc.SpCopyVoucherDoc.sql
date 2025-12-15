USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1387/01/12
-- Viewed By	 : 
-- Last Modified : 1388/06/03
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description   : کپی یک سند
-- =============================================
CREATE PROCEDURE [acc].[SpCopyVoucherDoc]
	@SerialNoSource		Int,
	@SerialNoTarget		Int,
	@DocDate			VarChar(10),
	@DocDesc			NVarChar(1000),
	@DocDesc2			VarChar(1000),
	@SessionNo			Int
	WITH ENCRYPTION
AS
DECLARE	@RecID	bigint;
BEGIN
	SET NOCOUNT ON;

	-------------------------------------------------
	CREATE TABLE #tmp(Id bigint)
	
	insert into	#tmp
	exec [hst].[funGetUniqueId]

	select @RecID = Id from #tmp
	-------------------------------------------------

	BEGIN TRANSACTION

	BEGIN TRY 
		-- 1- Hdr --
		DECLARE @MainSerialNo as int
		SELECT @MainSerialNo = ISNULL(MAX(OldSerialNo),0)+1
		FROM acc.tblVoucherHdr

		INSERT INTO acc.tblVoucherHdr(SerialNo, DocDate, DocRegisterState, DocDesc, DocDesc2,VchKind, RecID, SessionNo, OldSerialNo)
		VALUES (@SerialNoTarget, @DocDate, 1, @DocDesc, @DocDesc2, 1, @RecID, @SessionNo, @MainSerialNo)

		-- 2- Dtl --
		INSERT INTO acc.tblVoucherDtl(SerialNo, RowNo, SourceProcessID, SourceProcessNo, SourceFiscalYear, SourceSerialNo, DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, IsAutoDoc, SessionNo, VchKind, DocRowNo, SourceDocType, IsShowDetail)
			SELECT	@SerialNoTarget, RowNo, 0, 0, 0, 0, @DocDate, AcntCode, Debit, Credit, RecDesc, RecDesc2, 0, SessionNo, 1, DocRowNo, 0, IsShowDetail
			FROM	acc.tblVoucherDtl
			WHERE	SerialNo = @SerialNoSource
					
		COMMIT TRANSACTION
		RETURN 1
		
	END TRY

	BEGIN CATCH
		Declare @StrErrorMessage As Nvarchar(1024)
		Set @StrErrorMessage = ERROR_MESSAGE() 
		raiserror (@StrErrorMessage, 16, 1)
		ROLLBACK TRANSACTION
		RETURN 0
	END CATCH

END
GO
