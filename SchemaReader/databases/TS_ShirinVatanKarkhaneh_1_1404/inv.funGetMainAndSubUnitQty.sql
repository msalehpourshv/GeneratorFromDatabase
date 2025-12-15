USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 97/10/16
-- Viewed By	 : 
-- Last Modified : 
-- Description   : تابعی برای دریافت اطلاعات واحد اصلی و فرعی با کد کالا و مقدار آن
-- =============================================
Create FUNCTION [inv].[funGetMainAndSubUnitQty](
	@GoodsID VarChar(20) ,
	@Qty	Float
)
RETURNS nVarchar(1000) 
WITH ENCRYPTION
AS
begin

DECLARE @Result	nVarchar(1000) ;
select 
@Result	= 
	case when MainUnitValue IS null 
		then ltrim(str(@Qty))
			+'@0'
			+'@'+G.UnitID+'@'
			+'@1'
			+'@1'
			+'@'+@GoodsID+'@'+ltrim(str(@Qty))
			+'@'+U1.UnitName
			+'@'
	  else
			ltrim(str(case when  MainUnitValue>=UnitValue 	then  
					case when MainUnitValue<@Qty then FLOOR (@Qty / MainUnitValue) 	else  @Qty  end 
			else 
					case when UnitValue<@Qty then	FLOOR (@Qty / UnitValue) 	else  0    end 
			end )) +'@'+ 		
			ltrim(str(case when  MainUnitValue>=UnitValue 	then 
					case when MainUnitValue<@Qty then @Qty- FLOOR (@Qty / MainUnitValue)*MainUnitValue 	else  0  end 
			else 
					case when UnitValue<@Qty then @Qty- FLOOR (@Qty / UnitValue)*UnitValue 	else  @Qty  end 
			end )) 			
			+'@'+G.UnitID+'@'+SubUnitID
			+'@'+ltrim(str(MainUnitValue))+'@'+ltrim(str(UnitValue))
			+'@'+@GoodsID+'@'+ltrim(str(@Qty))
			+'@'+U1.UnitName
			+'@'+ U2.UnitName 	 
			end 
		from inv.tblGoods G  
		left join inv.tblSubUnitsDtl S on G.GoodsID = S.GoodsID And ShowInInvoice = 1
		left  join inv.tblUnitsDtl U1 on U1.UnitID= G.UnitID and U1.LanguageID=1
		left  join inv.tblUnitsDtl U2 on U2.UnitID= S.SubUnitID and U2.LanguageID=1
		where G.GoodsID = @GoodsID 
	
	
	return @Result
	
end 
GO
