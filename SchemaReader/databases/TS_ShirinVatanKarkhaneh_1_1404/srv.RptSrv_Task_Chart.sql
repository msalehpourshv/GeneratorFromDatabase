USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Reza Nogrehpasand
-- Create date   : 1393/05/13
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :  
-- =============================================
create PROCEDURE [srv].[RptSrv_Task_Chart] 
	
	@FromDate			CHAR(10)=null,
	@ToDate				CHAR(10)=null,
	@PerssonelID		VarChar(20)=null,
	@SprintID			VARCHAR(20)=null,
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(MAX);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
declare @db_0000	nvarchar(50);

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

--
set @StrWhere='where 1=1'


	
IF (@SprintID IS NOT null)
		SET @StrWhere = @StrWhere + ' AND h.SprintID=''' + @SprintID + '''' 
			


IF (@PerssonelID IS NOT null)
		SET @StrWhere  = @StrWhere  + ' AND p.PersonnelID=''' + @PerssonelID + '''' 
		
	IF (@FromDate IS NOT null)
		SET @StrWhere  = @StrWhere  + ' AND h.DocDate >=''' + @FromDate + ''''
		
	IF (@ToDate IS NOT null)
		SET @StrWhere  = @StrWhere  + ' AND h.DocDate <=''' + @ToDate + ''''	 	


		
-- ================ SELECT ===========================
			
	set @StrSelect='select 
		(select sum(d.Duration) from srv.tblServiceTaskHdr h
		inner join srv.tblServiceTaskDtl d
		on h.FiscalYear=d.FiscalYear and h.SerialNo=d.SerialNo
		inner join srv.tblServiceTaskPersonnelDtl p
		on h.FiscalYear=p.FiscalYear and h.SerialNo=p.SerialNo ' 
		+ @StrWhere + ' and TaskStatus<>1 ) NotFinished,

		(select sum(d.Duration) from srv.tblServiceTaskHdr h
		inner join srv.tblServiceTaskDtl d
		on h.FiscalYear=d.FiscalYear and h.SerialNo=d.SerialNo
		inner join srv.tblServiceTaskPersonnelDtl p
		on h.FiscalYear=p.FiscalYear and h.SerialNo=p.SerialNo '
		+ @StrWhere + '  and TaskStatus=1 ) Finished'
	 
	 		 
-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
