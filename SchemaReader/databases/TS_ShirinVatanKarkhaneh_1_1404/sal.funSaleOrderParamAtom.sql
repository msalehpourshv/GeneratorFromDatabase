USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Jafari
-- Create date   : 98/04/11
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create function  sal.funSaleOrderParamAtom(
@ProcessID Int, 
@ProcessNo Int, 
@FiscalYear int , 
@SerialNo int, 
@DocRowNo int)RETURNS NVarChar(2000) 

	 	WITH ENCRYPTION
AS
BEGIN

DECLARE @ParamValue	   NVARCHAR(50)
DECLARE @ParamValueName    NVARCHAR(2000)

IF (select COUNT(*)
		from sal.tblSaleOrderParamAtom
		where  ProcessID= @ProcessID  
		and ProcessNo= @ProcessNo  
		and FiscalYear= @FiscalYear   
		and SerialNo= @SerialNo  
		and DocRowNo= @DocRowNo) =0
return ''

 set @ParamValueName =''

		select @ParamValueName = COALESCE(@ParamValueName + ' | ', ' ') + 
		ISNULL( 
		Case When ParamState=1 then (Select GoodsName From inv.tblGoodsDtl where GoodsID = ParamValue and LanguageID=1  )
			 When ParamState=2 then 
			 (Select CustomGoodsParamName From inv.tblCustomGoodsParamDtl where CustomGoodsParamID = ParamValue and LanguageID=1  )
			 When ParamState=3 then TextParam
			 When ParamState=4 then CAST( NumericParam as Varchar(10))
		else ''
		end 
		, '') --ParamValueName
		 from sal.tblSaleOrderParamAtom
		 where  ProcessID= @ProcessID  
			and ProcessNo= @ProcessNo  
			and FiscalYear= @FiscalYear   
			and SerialNo= @SerialNo  
			and DocRowNo= @DocRowNo

if LEN (@ParamValueName)> 3

	set @ParamValueName=Substring (@ParamValueName ,3, LEN (@ParamValueName))
return @ParamValueName

 
END

GO
