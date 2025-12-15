USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 Create  Procedure [acc].[SpBalanceSourceVoucher]
	@SerialNo int,
	@intSourceProcessID		TinyInt,
	@intSourceProcessNo		TinyInt,
	@intSourceFiscalYear	SmallInt,
	@intSourceSerialNo		Int,
	@AcntCode VARCHAR(20)
	WITH ENCRYPTION
AS
BEGIN
	DECLARE @sumVoucher as BIGINT
	SELECT @sumVoucher = ISNULL(SUM(Credit-Debit),0)
	FROM acc.tblVoucherDtl
	WHERE SerialNo = @SerialNo
	and 	SourceProcessID	= @intSourceProcessID		
    and 	SourceProcessNo=@intSourceProcessNo		
	and     SourceFiscalYear= @intSourceFiscalYear	
    and 	SourceSerialNo=@intSourceSerialNo		
	
	IF @sumVoucher<>0 AND ABS(@sumVoucher)<100
	BEGIN
		DECLARE @RowNo as INT
		DECLARE @Debit as BIGINT
		
		SELECT TOP 1 @RowNo=RowNo,@Debit=Debit
		FROM acc.tblVoucherDtl
		WHERE SerialNo = @SerialNo AND AcntCode = @AcntCode
		and 	SourceProcessID	= @intSourceProcessID		
    and 	SourceProcessNo=@intSourceProcessNo		
	and     SourceFiscalYear= @intSourceFiscalYear	
    and 	SourceSerialNo=@intSourceSerialNo		
		
		IF @Debit>0
			UPDATE acc.tblVoucherDtl
			SET Debit = Debit + @sumVoucher
			WHERE SerialNo = @SerialNo AND RowNo = @RowNo
			and 	SourceProcessID	= @intSourceProcessID		
    and 	SourceProcessNo=@intSourceProcessNo		
	and     SourceFiscalYear= @intSourceFiscalYear	
    and 	SourceSerialNo=@intSourceSerialNo		
		ELSe
			UPDATE acc.tblVoucherDtl
			SET Credit = Credit - @sumVoucher
			WHERE SerialNo = @SerialNo AND RowNo = @RowNo
			and 	SourceProcessID	= @intSourceProcessID		
    and 	SourceProcessNo=@intSourceProcessNo		
	and     SourceFiscalYear= @intSourceFiscalYear	
    and 	SourceSerialNo=@intSourceSerialNo		
		 
	END 
			
	
END
GO
