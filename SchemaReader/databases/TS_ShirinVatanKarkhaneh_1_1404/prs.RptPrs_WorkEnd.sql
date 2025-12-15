USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\jafari
-- Creation date : 1393/12/10
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- ==============================================
Create PROCEDURE [prs].[RptPrs_WorkEnd]
	@ProcessID int,
	@ExtraParams		NVarChar(200) = Null,
	@RepOptions		VarChar(10) = '',
	@RepInfo		NVarChar(100) = '1@1@1'
	
	
WITH ENCRYPTION
AS 
DECLARE @StrSelect			NVarChar(max),
		@StrFrom			NVarChar(max),
		@StrWhere			NVarChar(max),
		@LangID				Char(1),
		@SessionNo			Int, 
		@ReportID			Int,
		@BenefitID			varchar(20),
		@BenefitName		nvarchar(50),
		@MonthCode			nvarchar(50),	
		@FromMonthCode		TinyInt,
		@ToMonthCode		TinyInt,	
		@FromPersonnelID	VARCHAR(20),
		@ToPersonnelID		VARCHAR(20),
		@Daily				TinyInt
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		bit;	
Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1'

	SET @LangID			= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo		= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID		= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID			= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin	= pub.funSplitString(@RepInfo, '@', 5); 

	SET @StrSelect			    = LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @FromMonthCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @ToMonthCode			= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @FromPersonnelID	    = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	SET @ToPersonnelID		    = LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
	
	if @FromMonthCode=0
		set @FromMonthCode=1
	if @FromPersonnelID is null
		set @FromPersonnelID=''
	if @ToPersonnelID is null
		set @ToPersonnelID=''
	
	set @StrWhere=' and  MonthCode >='+ str(@FromMonthCode) +''
	set @StrWhere=@StrWhere+' and MonthCode <='+ str(@ToMonthCode) +''
	
	if @FromPersonnelID<>' '
		set @StrWhere=@StrWhere+' and PersonnelID >='''+ @FromPersonnelID +''''
	if @ToPersonnelID<>' '
		set @StrWhere=@StrWhere+' and PersonnelID <='''+ @ToPersonnelID +''''
	
	---------------------------------------
	if @UserIsAdmin=0 and (select count(*) from prs.tblPersonnelsRng) >0
	begin
		--If (@ExternalCall = 0) 
		begin
			BEGIN TRY
				DROP TABLE #Personnel
			END TRY
			BEGIN CATCH
			END CATCH
		END
		CREATE TABLE #Personnel
		(
			PersonnelID 			Varchar(20)collate arabic_cs_as null
		)
	
		Insert into  #Personnel (PersonnelID)	SELECT Distinct PersonnelID from prs.tblPersonnels
	 
		exec pub.SpFilterByPermission2 '#Personnel@1', 'PersonnelID', 'prs.tblPersonnels', @UserID;
		
		SET @StrWhere =   @StrWhere +' and PersonnelID in (SELECT PersonnelID FROM  #Personnel ) '

	END

	-----------------------------------------
	set @StrSelect ='	
	select prs.funGetPersonnelName(a.PersonnelID, 1) PersonnelName,a.PersonnelID
			,SumCost,isnull(SumAmount,0)SumAmount,SumTotalDays,SumManualTotalDays, SumTaxAmountCelebration
	 from (		
			SELECT  PersonnelID, SUM(Cost) AS SumCost,  sum(TotalDays	) SumTotalDays	,sum( ManualTotalDays) SumManualTotalDays			
			,isnull((Select Sum(TaxAmountCelebration) from prs.tblSalaryCalculation  b where a.PersonnelID= b.PersonnelID and (320 = '+str(@ProcessID)+') '+ @StrWhere +' GROUP BY   b.PersonnelID),0) SumTaxAmountCelebration
			FROM         prs.tblCelebrationDtl a
			where  (ProcessID = '+str(@ProcessID)+') '+ @StrWhere +'
			GROUP BY   PersonnelID) a
		left join (
			select PersonnelID,  SUM(Amount) AS SumAmount 
			FROM prs.tblSalaryPaysHdr a
			inner join  prs.tblSalaryPaysDtl  b
			on a.SerialNo=b.SerialNo and a.ProcessID=b.ProcessID
			where  (b.ProcessID = '+str(@ProcessID+1)+') '+ @StrWhere +'
			GROUP BY    PersonnelID) b 
		on a.PersonnelID=b.PersonnelID
		'
  
print @StrSelect
	EXECUTE sp_executesql @StrSelect

	
End
GO
