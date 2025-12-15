USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Nogrepasand
-- Create date   : 1391/11/30
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
create  PROCEDURE [sal].[SalSp_insertinto_ContractDtl2]
	@SerialNo		int = null,
	@BaseProcessID	int = null,
	@FiscalYear		int=null,
	@ProcessNo		int=null,
	@BranchID		VarChar(20) = '001',
	@BaseSerialNo	int = null,
	@EarnDate		Char(10) = null,
	@BaseFiscalYear	int = null
	
	
WITH ENCRYPTION
AS
BEGIN
	DECLARE @RowNo AS INT
	DECLARE @DocRowNo AS INT
	
	SELECT @RowNo = ISNULL(MAX(RowNo),0)+1 FROM sal.tblRestaurantContractDtl2
	WHERE SerialNo = @SerialNo AND ProcessID=@BaseProcessID AND BranchID=@BranchID
	and FiscalYear=@FiscalYear
	
	SELECT @DocRowNo = ISNULL(MAX(DocRowNo),0)+1 FROM sal.tblRestaurantContractDtl2
	WHERE SerialNo = @SerialNo AND ProcessID=@BaseProcessID AND BranchID=@BranchID
	and FiscalYear=@FiscalYear
	
	insert into sal.tblRestaurantContractDtl2
	(SerialNo, ProcessID,ProcessNo,FiscalYear, BranchID, RowNo, DocRowNo, BaseSerialNo,  EarnDate,BaseFiscalYear)
	VALUES
	(@SerialNo,@BaseProcessID,@ProcessNo,@FiscalYear,@BranchID,@RowNo,@DocRowNo,@BaseSerialNo,@EarnDate,@BaseFiscalYear)
END
GO
