USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 88/01/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [acc].[SpControlSelectedUserVchNo]
	@intVchNo	Int,				-- شماره سند
    @strVchDate	Char(10),			-- تاریخ سند
	@ProcessID	Int ,
	@ProcessNo	Int ,
	@FiscalYear	Int ,
	@SerialNo	Int 
	WITH ENCRYPTION
AS

	DECLARE @bolNewVoucher	Bit
	DECLARE @intMaxRowNo	Int
	DECLARE @intMaxDocRowNo Int

BEGIN
	SET NOCOUNT ON;


	DECLARE @ReturnValue Tinyint
	DECLARE @DocRegisterState3 INT
	DECLARE @DocDate3 Varchar(10)
	DECLARE @LastSortDate Varchar(10)
	DECLARE @DocIsReserved INT
	
	SET @LastSortDate = ''
	SET @ReturnValue = 0

	SELECT TOP 1 @DocRegisterState3=H.DocRegisterState ,@DocDate3=H.DocDate
	FROM acc.tblVoucherHdr H
	INNER JOIN acc.tblVoucherDtl D ON H.SerialNo=D.SerialNo
	WHERE H.SerialNo=@intVchNo AND 
	  NOT(SourceProcessID  = @ProcessID AND
	      SourceProcessNo  = @ProcessNo AND
	      SourceFiscalYear = @FiscalYear AND
	      SourceFiscalYear = @FiscalYear 
	     )

	SELECT TOP 1 @DocIsReserved = COUNT(*)
	FROM acc.tblVoucherSerials H
	INNER JOIN acc.tblVoucherDtl D ON H.VchNo = D.SerialNo
	WHERE D.SerialNo = @intVchNo
	  AND H.IsReserved = 'True' 
	  AND H.DocDate <> @strVchDate


	IF @DocRegisterState3 > 1
		Set @ReturnValue = 2 --'این شماره سند قفل شده است'

	IF @ReturnValue = 0 AND @DocDate3 <> @strVchDate 
		Set @ReturnValue = 3 --'تاریخ این شماره سند با تاریخ سند انتخابی یکی نیست'

	IF @ReturnValue = 0
		BEGIN
			SELECT @LastSortDate = SettingValue 
			FROM pub.tblSettings
			WHERE SettingKey = 'LastSortDate'
			
			IF @strVchDate <= @LastSortDate
				Set @ReturnValue = 4 --'در محدوده اين تاريخ مرتب شده است'
		END

	IF @ReturnValue = 0
		BEGIN
			DECLARE @AllFormLockVoucherNo int
			SET @AllFormLockVoucherNo = 0

			SELECT @AllFormLockVoucherNo = SettingValue 
			FROM pub.tblSettings
			WHERE SettingKey='AllFormLockVoucherNo'
			
			IF @intVchNo<=@AllFormLockVoucherNo
				Set @ReturnValue = 5 --' این شماره عطف قفل شده است'
		END
	
	IF @DocIsReserved > 0
		Set @ReturnValue = 6 --سند رزور شده است
		
	SELECT  @ReturnValue AS State

END
GO
