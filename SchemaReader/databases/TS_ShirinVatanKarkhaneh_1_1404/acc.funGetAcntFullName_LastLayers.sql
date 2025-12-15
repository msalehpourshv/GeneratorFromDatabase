USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		: TakroSystem\ZiA
-- Create date	: 1394-08-10 
-- Description	: Full Acnt Name
-- =============================================
CREATE FUNCTION [acc].[funGetAcntFullName_LastLayers]
(
	@AcntFullCode AS VarChar(20)
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS
BEGIN
	declare @Result as nvarchar(500)
	declare @PartName as nvarchar(100)

	declare @Part1Code as varchar(20)
	declare @Part2Code as varchar(20)
	declare @Part3Code as varchar(20)
	declare @Part4Code as varchar(20)
	
	set @Result = ''
	set @PartName = ''
	
	set @Part1Code = ''
	set @Part2Code = ''
	set @Part3Code = ''
	set @Part4Code = ''

	set @Part1Code = pub.funSplitString(@AcntFullCode,' ',1)	
	set @Part2Code = pub.funSplitString(@AcntFullCode,' ',2)	
	set @Part3Code = pub.funSplitString(@AcntFullCode,' ',3)	
	set @Part4Code = pub.funSplitString(@AcntFullCode,' ',4)
	
	if (@Part1Code <> '')
	begin
		if (@Result <> '') set @Result = @Result + ' > '
		
		select @PartName = AcntName
		from acc.tblAcntDtl
		where AcntCode = @Part1Code and PartNumber=1 and LanguageID=1
	
		set @Result = @Result + ISNULL(@PartName,'')
	end
	
	if (@Part2Code <> '')
	begin
		if (@Result <> '') set @Result = @Result + ' > '
		
		select @PartName = AcntName
		from acc.tblAcntDtl
		where AcntCode = @Part2Code and PartNumber=2 and LanguageID=1
	
		set @Result = @Result + ISNULL(@PartName,'')
	end
	
	if (@Part3Code <> '')
	begin
		if (@Result <> '') set @Result = @Result + ' > '
		
		select @PartName = AcntName
		from acc.tblAcntDtl
		where AcntCode = @Part3Code and PartNumber=3 and LanguageID=1
	
		set @Result = @Result + ISNULL(@PartName,'')
	end
	
	if (@Part4Code <> '')
	begin
		if (@Result <> '') set @Result = @Result + ' > '
		
		select @PartName = AcntName
		from acc.tblAcntDtl
		where AcntCode = @Part4Code and PartNumber=4 and LanguageID=1
	
		set @Result = @Result + ISNULL(@PartName,'')
	end			
	 
	RETURN	@Result
END

GO
