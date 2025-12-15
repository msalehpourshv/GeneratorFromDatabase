USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation Date : 1391/02/23
-- Viewed By	 : 
-- Last Modified : 1391/02/23
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- ==============================================
CREATE FUNCTION [pub].[funLayerSum]
(
	@Table	varchar(100),
	@PartNo int,
	@Level	int
)
RETURNS int
WITH ENCRYPTION
AS
BEGIN
	DECLARE @Result AS int
	
	if (@Level=1)
		select @Result=Layer1
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else if (@Level=2)
		select @Result=Layer1+Layer2
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else if (@Level=3)
		select @Result=Layer1+Layer2+Layer3
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else if (@Level=4)
		select @Result=Layer1+Layer2+Layer3+Layer4
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else if (@Level=5)
		select @Result=Layer1+Layer2+Layer3+Layer4+Layer5
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else if (@Level=6)
		select @Result=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else if (@Level=7)
		select @Result=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else if (@Level=8)
		select @Result=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)
		
	else 
		select @Result=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
		from pub.tblCodeLayer
		where (TableName=@Table) and (PartNumber=@PartNo)

	RETURN @Result
END



GO
