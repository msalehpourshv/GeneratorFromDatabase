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
Create PROCEDURE pln.RptPln_OrderWorkFault
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

	
	  select I.* 
	  , pub.funSecondToHM(FaultTime ) FaultTimeHM
	  , pub.funSecondToHM(FaultTimeStart ) StartTime
	  , pub.funSecondToHM(FaultTimeEnd ) EndTime
	  , F.FaultName 
	  from pln.tblFaultItems I
	  left join pln.tblFaults F on I.FaultID =F.FaultID
	  where SerialNo=@SerialNo

	   
END
GO
