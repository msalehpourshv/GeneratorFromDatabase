USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : jafari
-- Create date   : 1400/03/25
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create FUNCTION ast.funAssetPlaqueLastState
(
@AssetPlaque Varchar(20),
@DocDate		char(10),
@EventNo		int=0,
@ProcessIN1		int=0,
@ProcessIN2		int=0,
@ProcessIN3		int=0,
@ProcessNotIN1	int=0,
@ProcessNotIN2	int=0,
@ProcessNotIN3	int=0,
@EnterKind		int=0
)
RETURNS TABLE 
WITH ENCRYPTION            
AS

RETURN 
(

select top 1 * from ast.tblAssetsDtl a
where  a.AssetPlaque=@AssetPlaque
and (isnull(@DocDate,'')=''		or ((isnull(@DocDate,'')<>''	and DocDate <@DocDate ) 
	or ( DocDate =@DocDate and @EventNo <EventNo)))
and (isnull(@ProcessIN1,0)=0	or (isnull(@ProcessIN1,0)<>0	and ProcessID =@ProcessIN1))
and (isnull(@ProcessIN2,0)=0	or (isnull(@ProcessIN2,0)<>0	and ProcessID =@ProcessIN2))
and (isnull(@ProcessIN3,0)=0	or (isnull(@ProcessIN3,0)<>0	and ProcessID =@ProcessIN3))
and (isnull(@ProcessNotIN1,0)=0 or (isnull(@ProcessNotIN1,0)<>0 and ProcessID <>@ProcessNotIN1))
and (isnull(@ProcessNotIN2,0)=0 or (isnull(@ProcessNotIN2,0)<>0 and ProcessID <>@ProcessNotIN2))
and (isnull(@ProcessNotIN3,0)=0 or (isnull(@ProcessNotIN3,0)<>0 and ProcessID <>@ProcessNotIN3))
and (isnull(@EnterKind,0)=0 or (isnull(@EnterKind,0)<>0 and EnterKind<>0))

order by DocDate Desc,EventNo Desc

)
GO
