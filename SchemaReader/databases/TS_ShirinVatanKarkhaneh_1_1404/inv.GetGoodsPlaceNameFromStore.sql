USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1400/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :  
-- =============   =================================
Create FUNCTION inv.GetGoodsPlaceNameFromStore
(
	@StoreID VarChar(20), 
	@DocRowNo VarChar(20), 
	@LanguageID AS TinyInt
)
	RETURNS NVarChar(500) 
WITH ENCRYPTION
AS

Begin -- ====================================================

	--SET @LanguageID = pub.funGetCurrentLanguageID();

	Declare @StrResult AS NVarChar(500)

	
select  @StrResult= (select   stuff((			select ' ' + convert(varchar(50), S.GoodsPlaceID +' ( ' +GoodsPlaceName +' ) ')		
	from inv.tblGoodsStatusAtom S 	
	LEFT JOIN inv.tblGoodsPlaceDtl GP ON GP.GoodsPlaceID = S.GoodsPlaceID AND LanguageID=1
		where S.StoreID=@StoreID and S.DocRowNo=@DocRowNo			for xml path('')		),1,1,''))  


	Return isnull(@StrResult,'')

END
GO
