USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Hamid
-- Create date   : 1392/07/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [srv].[RptSrv_PersonnelWork_Work]
	@FromDate			CHAR(10) = Null,
	@ToDate				CHAR(10) = Null,
	@PersonnelID		VarChar(20) = Null,
	@CodeClosedPrs		bit='False',
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);

Declare @StrWhere	NVarChar(4000);
Declare @StrWhere1	NVarChar(4000);
Declare @StrWhere2	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
 
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- Where Clause -----------------------------------------
	set @StrWhere = ' 1 = 1 '
	set @StrWhere1 = ' 1 = 1 '
	set @StrWhere2 = ' 1 = 1 '
	
	IF (@CodeClosedPrs='False' )
	 SET @StrWhere = @StrWhere + ' AND p.CodeClosed=0 ' 
	
	IF (@FromDate Is Not Null)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND a2.EventDate >= ''' + @FromDate + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND t.DocDate >= ''' + @FromDate + ''''
	End
	
  	IF (@ToDate Is Not Null)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND a2.EventDate <= ''' + @ToDate + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND t.DocDate <= ''' + @ToDate + ''''
	End
	
  	IF (@PersonnelID Is Not Null)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND a2.PersonelID = ''' + @PersonnelID + '''' 
		SET @StrWhere2 = @StrWhere2 + ' AND t.PersonnelID = ''' + @PersonnelID + '''' 
	End
   
	-- Select Clause -------------------------------------------
	 SET @StrSelect =
	 'SELECT p.PersonnelID,prs.funGetPersonnelName(PersonnelID,1) As PersonnelName,
			(Select  ISNULL(Sum(a2.Duration),0)Duration  
			 From srv.tblServiceTaskAtm2 a2
			 WHERE '+ @StrWhere1 +' and a2.PersonelID=p.PersonnelID),

		(Select ISNULL(SUM(Duration),0)  
		 From srv.tblTelService t
		 WHERE '+ @StrWhere2 +' and t.PersonnelID=p.PersonnelID) TelDuration
				
		FROM prs.tblPersonnels p 
		 
		WHERE '+ @StrWhere +' AND PersonnelID<>''''
		-- and not 
		--(
		--	(Select  ISNULL(Sum(a2.Duration),0)Duration  
		--	From srv.tblServiceTaskAtm2 a2
		--	WHERE '+ @StrWhere1 +' and a2.PersonelID=p.PersonnelID  )=0 

		--	AND (Select ISNULL(SUM(Duration),0)  
		--	From srv.tblTelService t
		--	WHERE '+ @StrWhere2 +' and t.PersonnelID=p.PersonnelID)=0
		--)'

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	PRINT @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
