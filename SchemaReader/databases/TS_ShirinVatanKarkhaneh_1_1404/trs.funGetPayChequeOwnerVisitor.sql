USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : jafari	
-- Create date   : 1403/04/31-
-- Viewed By	 : 
-- Last Modified : 
-- Description   : Get VisitorCode
-- =============================================
CREATE FUNCTION trs.funGetPayChequeOwnerVisitor 
(
	@VolumeFiscalYear	SmallInt,
	@VolumeRowNo		Int,
	@PayTypeID			Tinyint
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

BEGIN -- ============== S T A R T  C O D E =====================================

	Declare @Result AS VarChar(20)
IF @PayTypeID = 18
	 
	SELECT Top 1@Result =  VisitorAcntCode
	FROM	trs.tblPayDtl
	WHERE	ProcessID IN (33) AND 
			PayTypeID IN (18) AND 
			VolumeFiscalYear = @VolumeFiscalYear AND 
			VolumeRowNo = @VolumeRowNo
	ORDER By EventNo ASC

else
	 
	SELECT Top 1 @Result = VisitorAcntCode
	FROM	trs.tblPayDtl
	WHERE	ProcessID IN (2,25) AND 
			PayTypeID IN (8,28) AND 
			VolumeFiscalYear = @VolumeFiscalYear AND 
			VolumeRowNo = @VolumeRowNo
	ORDER By EventNo ASC 

	Return @Result
END





























GO
