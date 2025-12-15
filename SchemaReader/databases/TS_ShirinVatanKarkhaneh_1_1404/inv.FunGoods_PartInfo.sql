USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create  FUNCTION [inv].[FunGoods_PartInfo] 
(
	@PartNo		Int = 1,
	@fullCode   varchar(20)
)
RETURNS NVarChar(50)
WITH ENCRYPTION
AS

BEGIN
	declare @result as nvarchar(100)
	DECLARE @Part1Start	Int;
DECLARE @Part2Start	Int;
DECLARE @Part3Start	Int;
DECLARE @Part4Start	Int;
DECLARE @Part1Len	Int;
DECLARE @Part2Len	Int;
DECLARE @Part3Len	Int;
DECLARE @Part4Len	Int,
	@PartStart	Int  ,
	@PartLen	Int  

	-- Declare the return variable here
Begin

	SET		@Part1Start = 1;
	SELECT	@Part1Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 1)

	SELECT	@Part2Start = @Part1Start + @Part1Len  ;
	SELECT	@Part2Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 2)

	SELECT	@Part3Start = @Part2Start + @Part2Len  ;
	SELECT	@Part3Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 3)

	SELECT	@Part4Start = @Part3Start + @Part3Len  ;
	SELECT	@Part4Len = Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'inv.tblGoods') AND (PartNumber = 4)
	
	IF (@PartNo = 1)
	begin
		set @PartStart = @Part1Start
		set @PartLen = @Part1Len
	end

	IF (@PartNo = 2)
	begin
		set @PartStart = @Part2Start
		set @PartLen = @Part2Len
	end

	IF (@PartNo = 3)
	begin
		set @PartStart = @Part3Start
		set @PartLen = @Part3Len
	end

	IF (@PartNo = 4)
	begin
		set @PartStart = @Part4Start
		set @PartLen = @Part4Len
	end	
	 
set @result=(  select   SUBSTRING( @fullCode ,	@PartStart ,@PartLen	))
	RETURN  @result
end
END
GO
