USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hamid
-- Create date   : 93/09/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
CREATE FUNCTION [inv].[FunCustomerGoodsRemain] 
(
	@GoodsID			VarChar(20) = Null,
	@AcntCode			VarChar(20) = Null
)
RETURNS float
WITH ENCRYPTION
AS
BEGIN
	
	Declare @GoodsRemain As Float
	SET @GoodsRemain = -1
	
	Select @GoodsRemain = 
	(
	 Select CG.CountGoods 
	 From sal.tblCustomGoodsDtl CG
	 Inner Join acc.tblAcnt A ON A.CustomerKindID = CG.CustomerKindID
	 Where A.AcntCode = @AcntCode And CG.GoodsID = @GoodsID
	)
	
	IF @GoodsRemain Is Null 
		Set @GoodsRemain = -1

	RETURN @GoodsRemain
	
END
GO
