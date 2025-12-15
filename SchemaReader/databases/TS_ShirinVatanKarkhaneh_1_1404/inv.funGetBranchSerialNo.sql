USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [inv].[funGetBranchSerialNo] 
(
	@ProcessID int,
	@ProcessNo int,
	@AcntCode Varchar(20),
	@FiscalYear int
)
RETURNS Float
WITH ENCRYPTION
AS
BEGIN


	DECLARE @BranchSerialNo  INT
	DECLARE @BranchPartNo  INT
	DECLARE @WithProcessNo  bit

	SET  @BranchSerialNo = 0
	
	SELECT @BranchPartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberBranchPartNo'

Set @WithProcessNo=0
SELECT @WithProcessNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'salBranchSerialNoWithProcessNo'


	Declare @BranchPartStart	TinyInt;
	Declare @BranchPartLen		TinyInt;
		
	---- CALC LEN ----
		  select @BranchPartStart  = acc.funGetAcntLayerStartandLen(@BranchPartNo,1)
		  select @BranchPartLen  = acc.funGetAcntLayerStartandLen(@BranchPartNo,2)
 
		

if @WithProcessNo=0
begin
	select @BranchSerialNo=ISNULL(MAX(BranchSerialNo) ,0) from inv.tblStorageDocsHdr
	where ProcessID=@ProcessID AND FiscalYear=@FiscalYear and SUBSTRING(AcntCode,@BranchPartStart,@BranchPartLen)=SUBSTRING(@AcntCode,@BranchPartStart,@BranchPartLen)
end 
else
begin
	select @BranchSerialNo=ISNULL(MAX(BranchSerialNo),0)  from inv.tblStorageDocsHdr
	where ProcessID=@ProcessID AND FiscalYear=@FiscalYear  and ProcessNo=@ProcessNo and SUBSTRING(AcntCode,@BranchPartStart,@BranchPartLen)=SUBSTRING(@AcntCode,@BranchPartStart,@BranchPartLen)
end 

	RETURN isnull(@BranchSerialNo,-1) + 1

END
GO
