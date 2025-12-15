USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create Procedure [acc].[SpBalanceVoucher]
	@SerialNo int,
	@AcntCode VARCHAR(20),
	@intSourceProcessID		smallint=0,
	@intSourceProcessNo		smallint=0,
	@intSourceFiscalYear	SmallInt=0,
	@intSourceSerialNo		Int=0
	WITH ENCRYPTION
AS
BEGIN
	DECLARE @sumVoucher as BIGINT
	DECLARE @Dif as BIGINT
	set @Dif=1100
	IF @intSourceProcessID=0
		SET @Dif = 30000

	IF(select COUNT(*) FROM acc.tblVoucherHdr WHERE SerialNo = @SerialNo and DocDesc2 like N'%تسهیم%')>0
		SET @Dif = 250000
	
	SELECT @sumVoucher = ISNULL(SUM(Credit-Debit),0)
	FROM acc.tblVoucherDtl 
	WHERE SerialNo = @SerialNo and ((SourceProcessID=@intSourceProcessID and SourceProcessNo=@intSourceProcessNo
	and SourceSerialNo=@intSourceSerialNo and SourceFiscalYear=@intSourceFiscalYear ) OR (0=@intSourceProcessID and 0=@intSourceProcessNo
	and 0=@intSourceSerialNo and 0=@intSourceFiscalYear ))
	
	IF @sumVoucher<>0 AND ABS(@sumVoucher)<@Dif
	BEGIN
		DECLARE @RowNo as INT
		DECLARE @Debit as BIGINT
		
		SELECT TOP 1 @RowNo=RowNo,@Debit=Debit
		FROM acc.tblVoucherDtl
		WHERE SerialNo = @SerialNo AND AcntCode = @AcntCode 
		and ((SourceProcessID=@intSourceProcessID and SourceProcessNo=@intSourceProcessNo
	      and SourceSerialNo=@intSourceSerialNo and SourceFiscalYear=@intSourceFiscalYear) OR 
	      ( 0=@intSourceProcessID and 0=@intSourceProcessNo and 
	        0=@intSourceSerialNo and 0=@intSourceFiscalYear
		   )) AND (Debit >ABS(@sumVoucher) OR Credit>ABS(@sumVoucher))
		
		IF @Debit>0
			UPDATE acc.tblVoucherDtl
			SET Debit = Debit + @sumVoucher
			WHERE SerialNo = @SerialNo AND RowNo = @RowNo 
			and ((SourceProcessID=@intSourceProcessID and SourceProcessNo=@intSourceProcessNo
	          and SourceSerialNo=@intSourceSerialNo and SourceFiscalYear=@intSourceFiscalYear) OR 
	            ( 0=@intSourceProcessID and 0=@intSourceProcessNo and 
	              0=@intSourceSerialNo and 0=@intSourceFiscalYear
				))
		ELSe
			UPDATE acc.tblVoucherDtl
			SET Credit = Credit - @sumVoucher
			WHERE SerialNo = @SerialNo AND RowNo = @RowNo 			
		    and ((SourceProcessID=@intSourceProcessID and SourceProcessNo=@intSourceProcessNo
	          and SourceSerialNo=@intSourceSerialNo and SourceFiscalYear=@intSourceFiscalYear) OR 
	            ( 0=@intSourceProcessID and 0=@intSourceProcessNo and 
	              0=@intSourceSerialNo and 0=@intSourceFiscalYear)
	             )
		 
	END 
			
	
END
GO
