USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1390/02/07
-- Viewed By	 : 
-- Last Modified : 
-- Modifier		 : 
-- Description	 : واحد فرعی
-- ==============================================
CREATE FUNCTION [inv].[funSubUnit2Name]
(
	@GoodsID	varchar(20)
)
returns nvarchar(50)
WITH ENCRYPTION
AS
Begin
Return
(
	select isnull((
	select UnitName
	from inv.tblUnitsDtl 
	where UnitID =
			(
				select top 1 SubUnitID
				from inv.tblSubUnitsDtl S
				where (GoodsID = @GoodsID OR GoodsID='') and (ShowInInvoice = 1)
				ORDER BY GoodsID desc

			))
	,'')
);
End
GO
