USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Create date   : 1401/02/15
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 :
-- ==============================================
Create FUNCTION [sal].[funGetPayOffDiscountPercent]
(
	@CustomerKindID	varchar(20),
	@PayOffTypeID	varchar(20),
	@Price			Float
)
returns float
WITH ENCRYPTION
AS
Begin
	declare @RetPercent float

	SELECT TOP 1 @RetPercent=DiscountPercent
	FROM  [sal].[tblPayOffDiscountsDtl] 
	where [CustomerKindID]=@CustomerKindID AND 
	      [PayOffTypeID]= @PayOffTypeID AND
		  [FromPrice]<=@Price AND [ToPrice]>=@Price

	return @RetPercent

End
GO
