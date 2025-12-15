USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1391/06/01
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
CREATE FUNCTION [sal].[funSettleAverage]
(
	@ProcID		int, 
	@ProcNo		int, 
	@ProcFY		int, 
	@ProcSN		int, 
	@SaleDate	Char(10) 
)
RETURNS float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================
	
	Declare @Result	float;
	Declare @S1		float;
	Declare @S2		float;
	
	SELECT @S1 = sum(Amount * pub.funFarsiDateDiff('Day', case when (@SaleDate='') then H.DocDate else @SaleDate end, H.DocDate))
	FROM	trs.tblPayDtl D
				inner join trs.tblPayHdr H on H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	WHERE	D.ProcessID in (1,10) 
			and H.BaseProcessID = @ProcID
			and H.BaseProcessNo = @ProcNo
			and H.BaseFiscalYear = @ProcFY
			and H.BaseSerialNo = @ProcSN

	SELECT @S2 = sum(Amount)
	FROM	trs.tblPayDtl D
				inner join trs.tblPayHdr H on H.ProcessID=D.ProcessID and H.ProcessNo=D.ProcessNo and H.FiscalYear=D.FiscalYear and H.SerialNo=D.SerialNo
	WHERE	D.ProcessID in (1,10) 
			and H.BaseProcessID = @ProcID
			and H.BaseProcessNo = @ProcNo
			and H.BaseFiscalYear = @ProcFY
			and H.BaseSerialNo = @ProcSN
			
	if (@S1 is null) or (@S2 is null)
		-- no payment
		set @Result = -1
	else
	begin
		if (@S2 = 0) or (@S1 = 0)
			-- no real payment
			set @Result = -1
		else
			set @Result = cast(@S1 / @S2 as float)
	end
				
	Return @Result
	
End   -- === E N D ===============================================
GO
