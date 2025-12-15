USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1404/06/18
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 : 
-- ==============================================
Create FUNCTION trs.funGetChequeLastState
(
	@VolumeFiscalYear	SmallInt, 
	@VolumeRowNo		Int,
	@PayTypeID			Int,
	@Amount				float,
	@ChequeNo			bigint,
	@ChequeDate			Varchar(10)
)
RETURNS TinyInt
WITH ENCRYPTION
AS

BEGIN

	declare @Result as int
	
	if @VolumeRowNo=0 
		RETURN 0

	Select top 1 	@Result=ProcessID			
		from trs.tblPayDtl	 
		where VolumeFiscalYear=@VolumeFiscalYear
		and VolumeRowNo =@VolumeRowNo		
		and PayTypeID=	@PayTypeID				
		and Amount=	@Amount				
		and ChequeNo=@ChequeNo		
		and ChequeDate=@ChequeDate	
		Order by DocDate Desc , EventNo Desc

		
	RETURN ISnull(@Result,0)
END

GO
