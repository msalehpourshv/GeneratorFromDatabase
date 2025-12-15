USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [pln].[funGetOpratorName] 
(
	@ProcessID	Int,
	@ProcessNo	Int,
	@FiscalYear	Int,
	@SerialNo	Int,
	@RowNo	Int
)
RETURNS NVarChar(500)
WITH ENCRYPTION
AS

BEGIN
	
	Declare @OperatorID varchar(500)
	Declare @OperatorName varchar(500)
	SET @OperatorName = ''
	
	IF EXISTS(	SELECT TOP 1   O.OperatorID
		FROM pln.tblTaskOrderOperators O
		WHERE O.ProcessID=@ProcessID and O.ProcessNo=@ProcessNo 
		and O.FiscalYear=@FiscalYear and O.SerialNo=@SerialNo AND RowNo = @RowNo)
	BEGIN
		Declare	curOperators CURSOR For 
			Select Distinct O.OperatorID
			From pln.tblTaskOrderOperators O
			where O.ProcessID=@ProcessID and O.ProcessNo=@ProcessNo 
			and O.FiscalYear=@FiscalYear and O.SerialNo=@SerialNo AND RowNo = @RowNo
			
															   
		Open  curOperators; 
		Fetch NEXT From curOperators Into @OperatorID

		While (@@Fetch_Status = 0)
			BEGIN
				SET @OperatorName = @OperatorName + prs.funGetPersonnelName(@OperatorID,1) + ' - '
				
				Fetch NEXT From curOperators Into @OperatorID
			END

		Close curOperators;
		Deallocate curOperators;
		
		SET @OperatorName = SubString(@OperatorName,1,Len(@OperatorName) - 2)
	END 
	RETURN @OperatorName
END
GO
