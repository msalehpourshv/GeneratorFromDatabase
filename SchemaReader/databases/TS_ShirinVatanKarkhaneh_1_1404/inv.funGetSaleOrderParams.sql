USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE FUNCTION [inv].[funGetSaleOrderParams]
(
@ProcessID Int, 
@ProcessNo Int, 
@FiscalYear int , 
@SerialNo int, 
@DocRowNo int
)
RETURNS NVARCHAR(max) 
WITH ENCRYPTION
AS
BEGIN
declare @Result nvarchar(max) =''

declare @ParamName nvarchar(400),
		@ParamValue nvarchar(400),
		@ParamState tinyint,
		@TextParam nvarchar(1000),
		@NumericParam varchar(100)
	declare csr_P cursor for
		select ParamName,ParamValue,ParamState,TextParam,NumericParam
		from sal.tblSaleOrderParamAtom
		where ProcessID=@ProcessID
		  AND ProcessNo=@ProcessNo
		  AND FiscalYear=@FiscalYear
		  AND SerialNo=@SerialNo
		  AND DocRowNo=@DocRowNo
		and   (ParamValue<>'' OR TextParam<>'' OR NumericParam<>0)
	open csr_P;
	
	fetch next from csr_P into @ParamName,@ParamValue,@ParamState,@TextParam,@NumericParam;

	while (@@FETCH_STATUS = 0)
	begin
		IF @ParamState = 1
			SET @ParamValue = [pub].[funGetGoodsName](@ParamValue,1)
		IF @ParamState = 2
			SELECT  @ParamValue = CustomGoodsParamName
			FROM inv.tblCustomGoodsParamDtl
			where CustomGoodsParamID = @ParamValue and LanguageID=1
			
		set @Result = @Result + @ParamName + '-' + 
					case when @ParamState =1 OR @ParamState =2 then @ParamValue
					     WHEN  @ParamState =3 THEN @TextParam
					     WHEN  @ParamState =4 THEN @NumericParam END + ' | ' 
		fetch next from csr_P into @ParamName,@ParamValue,@ParamState,@TextParam,@NumericParam;

	end

	close csr_P;
	deallocate csr_P;
	
	return @Result
END
GO
