USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author		 : jafari	
-- Create date	 : 1401/06/24
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
Create PROCEDURE pln.RptPln_OrderWorkOperators
	@FiscalYear		Int = 0,
	@SerialNo		Int = 0,
	@FiscalYearTo		Int = 0,
	@SerialNoTo		Int = 0,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE @StrSelect	Nvarchar(4000);
DECLARE @StrWhere	Nvarchar(4000);
DECLARE	@LangID		NvarChar(1);
DECLARE	@SessionNo	Int;
DECLARE	@ReportID	Int;
DECLARE	@OrderCount	Float;
DECLARE	@GoodsQuantity	Float;
DECLARE	@ProductCount	Float;
DECLARE	@ProductID		varchar(20);

BEGIN
	SET NOCOUNT ON;

	-- ---------------------------------------------------------------------------------
	IF @RepInfo IS NULL SET @RepInfo = '1@1@1'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-- ---------------------------------------------------------------------------------

	select 0 TaskOrderOperatorID,O.ProcessID,O.ProcessNo,O.FiscalYear,O.SerialNo,0 RowNo,O.OperatorID, FirstName, LastName	  
	  ,'' StartTime	,''FinishTime	,''TotalTime	,''StartDate	,''FinishDate,pub.funSecondToHM(Sum(TotalTime) ) TotalTimeHM
	  from pln.tblTaskOrderOperators O
	  left join prs.tblPersonnelsDtl P on P.PersonnelID =O.OperatorID
	  inner join  pln.tblTaskOrderDtl T on O.ProcessID=T.ProcessID
		 and  O.ProcessNo=T.ProcessNo
		 and  O.FiscalYear=T.FiscalYear
		 and  O.SerialNo=T.SerialNo
		 and  O.RowNo=T.DocRowNo
	  where O.SerialNo=@SerialNo
	  Group by  O.ProcessID,O.ProcessNo,O.FiscalYear,O.SerialNo,O.OperatorID, FirstName, LastName
	  	   
END
GO
