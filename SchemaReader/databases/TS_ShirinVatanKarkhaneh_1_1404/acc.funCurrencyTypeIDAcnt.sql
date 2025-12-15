USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : jafari
-- Create date   : 1401/12/06
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create FUNCTION acc.funCurrencyTypeIDAcnt
(
	@FullCode	VarChar(20)

)
RETURNS NVarChar(250)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS VarChar(20);
	DECLARE @Start	AS int;
	DECLARE @Len	AS int;
	 

 
 
select @Start= acc.funGetAcntLayerStartandLen(4,1)

if len(@FullCode)>=@Start
begin
	select @Len= acc.funGetAcntLayerStartandLen(4,2)	
	SELECT	@Result = isnull(CurrencyTypeIDAcnt,'')
	FROM	acc.tblAcnt
	WHERE	AcntCode = Substring(@FullCode, @Start, @Len) AND PartNumber = 4
	if @Result<>''
		RETURN isnull(@Result,'')
end
select @Start= acc.funGetAcntLayerStartandLen(3,1)

if len(@FullCode)>=@Start
begin
	select @Len= acc.funGetAcntLayerStartandLen(3,2)	
	SELECT	@Result = isnull(CurrencyTypeIDAcnt,'')
	FROM	acc.tblAcnt
	WHERE	AcntCode = Substring(@FullCode, @Start, @Len) AND PartNumber =3
	if @Result<>''
		RETURN isnull(@Result,'')
end 

select @Start= acc.funGetAcntLayerStartandLen(2,1)

if len(@FullCode)>=@Start
begin
	select @Len= acc.funGetAcntLayerStartandLen(2,2)	
	SELECT	@Result = isnull(CurrencyTypeIDAcnt,'')
	FROM	acc.tblAcnt
	WHERE	AcntCode = Substring(@FullCode, @Start, @Len) AND PartNumber =2
	if @Result<>''
		RETURN isnull(@Result,'')
end 

select @Start= acc.funGetAcntLayerStartandLen(1,1)

if len(@FullCode)>=@Start
begin
	select @Len= acc.funGetAcntLayerStartandLen(1,2)	
	SELECT	@Result = isnull(CurrencyTypeIDAcnt,'')
	FROM	acc.tblAcnt
	WHERE	AcntCode = Substring(@FullCode, @Start, @Len) AND PartNumber =1
	if @Result<>''
		RETURN isnull(@Result,'')
end 


	RETURN isnull(@Result,'')
END
GO
