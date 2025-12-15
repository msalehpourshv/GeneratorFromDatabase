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
CREATE PROCEDURE [srv].[RptSrv_PersonnelWork_Month]
	@FromDate			CHAR(10) = Null,
	@ToDate				CHAR(10) = Null,
	@PersonnelID		VarChar(20) = Null,
	@CompanyID			VarChar(20) = Null,
	@AcntPart			Tinyint = 2,
	@GroupByDatePrs		Bit = Null,
	@GroupByDateCompany Bit = Null,
	@RepInfo			NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);

Declare @StrSelect1	NVarChar(4000);
Declare @StrFrom1	NVarChar(4000);
Declare @StrWhere1	NVarChar(4000);

Declare @StrSelect2	NVarChar(4000);
Declare @StrFrom2	NVarChar(4000);
Declare @StrWhere2	NVarChar(4000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	-- Init Variables -------------------------------------
	IF @GroupByDatePrs Is Null Set @GroupByDatePrs = 'True';
	IF @GroupByDateCompany Is Null Set @GroupByDateCompany = 'False';
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- Where Clause -----------------------------------------
	Select @StrWhere1 = '1 = 1'
	Select @StrWhere2 = '1 = 1'

	IF (@FromDate Is Not Null)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND EventDate >= ''' + @FromDate + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND DocDate >= ''' + @FromDate + ''''
	End
	
  	IF (@ToDate Is Not Null)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND EventDate <= ''' + @ToDate + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND DocDate <= ''' + @ToDate + ''''
	End
	
  	IF (@PersonnelID Is Not Null)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND PersonelID = ''' + @PersonnelID + '''' 
		SET @StrWhere2 = @StrWhere2 + ' AND PersonnelID = ''' + @PersonnelID + '''' 
	End
	
  	IF (@CompanyID Is Not Null)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND 
		    (srv.funGetCompanyID (SA2.SerialNo ,SA2.FiscalYear ,SA2.DocRowNo ,
             SA2.PersonelID)) = ''' + @CompanyID + '''' 
	
		SET @StrWhere2 = @StrWhere2 + ' AND CompanyID = ''' + @CompanyID + '''' 
	End

	-- Select Clause -------------------------------------------
	IF @GroupByDatePrs = 'True' And @GroupByDateCompany = 'False'
	BEGIN
		SET @StrSelect1 = '
		Select prs.funGetPersonnelName(PersonelID,1) As PersonnelName ,COUNT(*)as DayinMonth ,SubString(EventDate,6,2)DocMonth ,
               '''' As CompanyName ,SUM(Duration)as duration,''�����'' as Type 
		From srv.tblServiceTaskAtm2 SA2
		WHERE ' + @StrWhere1 + ' Group By SubString(EventDate,6,2) ,PersonelID Union '
	
		SET @StrSelect2 = '
		Select prs.funGetPersonnelName(PersonnelID,1) As PersonnelName ,COUNT(*)as DayinMonth ,SubString(DocDate,6,2)DocMonth ,
			   '''' As CompanyName ,SUM(Duration)as Duration,''���� �����'' as Type
		From srv.tblTelService
		WHERE ' + @StrWhere2 + ' Group By SubString(DocDate,6,2) ,PersonnelID '
	END
	
	IF @GroupByDatePrs = 'False' And @GroupByDateCompany = 'True'
	BEGIN
		SET @StrSelect1 = '
		Select COUNT(*)as DayinMonth ,SubString(EventDate,6,2)DocMonth ,
        acc.funGetAcntName((srv.funGetCompanyID (SA2.SerialNo ,SA2.FiscalYear ,
        SA2.DocRowNo ,SA2.PersonelID)),' + Str(@AcntPart) + ',' + LTRIM(str(@LangID)) + ') As CompanyName ,
        SUM(Duration)as Duration,''�����'' as Type 
		From srv.tblServiceTaskAtm2 SA2
		WHERE ' + @StrWhere1 + ' Group By SubString(EventDate,6,2),
		(srv.funGetCompanyID (SA2.SerialNo ,SA2.FiscalYear ,SA2.DocRowNo ,SA2.PersonelID)) Union '
	
		SET @StrSelect2 = '
		Select COUNT(*)as DayinMonth ,SubString(DocDate,6,2)DocMonth ,
		acc.funGetAcntName(CompanyID,' + Str(@AcntPart) + ',' + LTRIM(str(@LangID)) + ') As CompanyName ,
        SUM(Duration)as duration,''���� �����'' as Type
		From srv.tblTelService		
		WHERE ' + @StrWhere2 + ' Group By SubString(DocDate,6,2) ,CompanyID '
	END	

	SET @StrSelect = @StrSelect1 + @StrSelect2	
	
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
