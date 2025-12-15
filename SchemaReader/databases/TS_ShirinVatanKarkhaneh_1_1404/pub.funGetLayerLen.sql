USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ============================================
-- Author        : jafari	
-- Create date   : 1401/09/05
-- Viewed By	 : 
-- Last Modified : 
-- Description   : Leyer len and Start
-- =============================================
Create FUNCTION pub.funGetLayerLen
(
	@TableName Varchar(50),
	@PartNumber TinyInt,
	@Layer TinyInt,
	@TypeRet TinyInt
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN

DECLARE @Result AS int 

-------- LAYERS LEN CLAUSE -----------------------------------------------------------------------
	SELECT	@Result = 1;
if @TypeRet=1
	SELECT	@Result =
		Case when @Layer=1 then 1 
			when @Layer=2 then Layer1+1
			when @Layer=3 then Layer2+Layer1+1
			when @Layer=4 then Layer3+Layer2+Layer1+1
			when @Layer=5 then Layer4+Layer3+Layer2+Layer1+1
			when @Layer=6 then Layer5+Layer4+Layer3+Layer2+Layer1+1
			when @Layer=7 then Layer6+Layer5+Layer4+Layer3+Layer2+Layer1+1
			when @Layer=8 then Layer7+Layer6+Layer5+Layer4+Layer3+Layer2+Layer1+1
			when @Layer=9 then Layer8+Layer7+Layer6+Layer5+Layer4+Layer3+Layer2+Layer1+1	
		else 
			0
		end  
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = @TableName) AND (PartNumber = @PartNumber)
if @TypeRet=2
	SELECT	@Result =
		Case when @Layer=1 then Layer1 
			when @Layer=2 then Layer2
			when @Layer=3 then Layer3
			when @Layer=4 then Layer4
			when @Layer=5 then Layer5
			when @Layer=6 then Layer6
			when @Layer=7 then Layer7
			when @Layer=8 then Layer8
			when @Layer=9 then Layer9
	else 
		0
	end  
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = @TableName) AND (PartNumber = @PartNumber)
	
RETURN isnull(@Result,0)

END
GO
