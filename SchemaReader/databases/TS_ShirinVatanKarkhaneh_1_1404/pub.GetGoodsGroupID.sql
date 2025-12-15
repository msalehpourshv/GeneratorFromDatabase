USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[GetGoodsGroupID]
(
	@GoodsID VarChar(20)
)
RETURNS VarChar(20) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	Declare @StrResult AS VarChar(20)

	Select @StrResult = GoodsGroupID
	From   inv.tblGoodsGroupsGoodsListDtl
	Where  GoodsID = @GoodsID

	Return @StrResult

END -- ======================================================


















GO
