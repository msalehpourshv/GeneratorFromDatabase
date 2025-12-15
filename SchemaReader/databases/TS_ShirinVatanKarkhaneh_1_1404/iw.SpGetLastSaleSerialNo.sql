USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1403/08/02
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < شماره آخرین فاکتور +1  >
-- ==============================================
Create PROCEDURE iw.SpGetLastSaleSerialNo
	@UserID		int,
	@StationID	varchar(20) ,
	@ProcessNo	int,
	@FiscalYear	int

WITH ENCRYPTION
AS
BEGIN	
	Declare @maxSerialNo int
	select  @maxSerialNo=isnull(max(SerialNo),0)+1
	from   inv.tblStorageDocsHdr H
	where ProcessID=90	and ProcessNo=@ProcessNo	 and FiscalYear=@FiscalYear

	Select @maxSerialNo maxSerialNo
END
GO
