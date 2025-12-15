USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/02/06
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 : نسبت واحد فرعی
-- ==============================================
CREATE FUNCTION [inv].[funSubUnit2]
(
	@GoodsID	varchar(20)
)
returns float
WITH ENCRYPTION
AS
Begin
Return
(
	select isnull ((
		select top 1 isnull(UnitValue / MainUnitValue, 0) as UnitScale2
		from inv.tblSubUnitsDtl
		where (GoodsID = @GoodsID OR GoodsID='') and (ShowInInvoice = 1)
		ORDER BY GoodsID desc

		),0)
);
End
GO
