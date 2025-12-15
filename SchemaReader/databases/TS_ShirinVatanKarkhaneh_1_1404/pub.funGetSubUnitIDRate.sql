USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pub].[funGetSubUnitIDRate]
(
--Declare	
@GoodsID	VarChar(20)=NULL, --'501000101100000014'--
@UnitID	VarChar(20)=NULL	--'0000007'--
)
RETURNS Float
WITH ENCRYPTION
AS
Begin -- === S T A R T ===========================================


declare @BaseUnitID	VarChar(20)
declare @SubUnitID	VarChar(20)
declare @Result	Float

select @BaseUnitID=[pub].[funGetGoodsUnitID] (@GoodsID)
select @SubUnitID=[pub].[funGetGoodsSubUnitID] (@GoodsID)

set @Result=0
if @BaseUnitID=@UnitID
		set @Result=1
  else
  begin  --تبدیل واحد اصلی به فرعی      
		Select @Result=MainUnitValue/UnitValue
		from  inv.tblSubUnitsDtl 
		Where       GoodsID =@GoodsID and   ShowInInvoice=1

  end
  
	return isnull(@Result,0)
	
	
End   -- === E N D ===============================================



GO
