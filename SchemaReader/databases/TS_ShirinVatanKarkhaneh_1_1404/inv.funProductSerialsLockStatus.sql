USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
--select [pub].[funProductSerialsLockStatus]('1398')
Create FUNCTION [inv].[funProductSerialsLockStatus]
(
	-- Add the parameters for the function here
	@ProcessID		Smallint,
	@ProcessNo		Tinyint	,
	@FiscalYear		Smallint ,
	@SerialNo		Int	,
	@DocRowNo		Int	,
	@ProductSerialID INT
)
RETURNS VARCHAR(30)
WITH ENCRYPTION

AS
BEGIN
	DECLARE @Result VARCHAR(30)
	DECLARE @LockProcessNo VARCHAR(2)
	DECLARE @LockSerialNo VARCHAR(100)
	DECLARE	@DocDate		VARCHAR(10)
	DECLARE @VolumeRowNo	INT	
	
	SEt @Result = 0
	IF @ProcessID = 171
	BEGIN

		Select TOP 1 @Result = a.ProcessID , @LockProcessNo = a.ProcessNo, @LockSerialNo = a.SerialNo
		from inv.tblStorageDocsSerials a
		inner join inv.tblStorageDocsDtl b
		on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and 
		   a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
		 where ProductSerialID = @ProductSerialID and a.ProcessID=100 AND 
			  (SourceProcessID=@ProcessID and SourceProcessNo=@ProcessNo and 
			   SourceFiscalYear=@FiscalYear and SourceSerialNo=@SerialNo)

	END
	ELSE
	BEGIN
		Select TOP 1 @DocDate = b.DocDate , @VolumeRowNo = b.VolumeRowNo
		from (SELECT * from inv.tblStorageDocsSerials
			  WHERE ProcessID=@ProcessID and ProcessNo=@ProcessNo and 
					FiscalYear=@FiscalYear and SerialNo=@SerialNo and 
					DocRowNo=@DocRowNo and ProductSerialID = @ProductSerialID
			   ) a
		inner join inv.tblStorageDocsDtl b
		on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and 
		   a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo

	
		Select TOP 1 @Result = a.ProcessID , @LockProcessNo = a.ProcessNo, @LockSerialNo = a.SerialNo
		from inv.tblStorageDocsSerials a
		inner join inv.tblStorageDocsDtl b
		on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and 
		   a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo and a.DocRowNo=b.DocRowNo
		 where ProductSerialID = @ProductSerialID and a.ProcessID<>125 AND 
			  ((DocDate=@DocDate and VolumeRowNo>@VolumeRowNo) OR (DocDate>@DocDate))--AND ProcessID=50
		 order by DocDate,VolumeRowNo
	 END
	IF @Result = 0
		Return ''
	ELSE
		Return 'ProcessID-' + LTRIM(STR(@Result)) + '-' + LTRIM(STR(@LockProcessNo))+ '-' + LTRIM(STR(@LockSerialNo))  

 	RETURN @Result

END
GO
