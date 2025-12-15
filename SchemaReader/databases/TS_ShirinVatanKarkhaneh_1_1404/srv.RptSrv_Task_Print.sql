USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem  \ Nogrehpasand
-- Create date   : 1391/05/23
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : (چاپ سفارش کار ( برگ ارائه خدمات پشتيباني
-- =============================================
CREATE PROCEDURE [srv].[RptSrv_Task_Print] 
	
	@SerialFr			int= 0,
	@SerialTo			int= 0,
	@FiscalYear			INT=0,
	@CurrentSerialNo	INT =0,
	@AcntPart			INT =2,
	@RepInfo			NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS

DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(2000);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
declare @db_0000	nvarchar(50);

BEGIN 
	-- ============================ S T A R T =====================================================

	-- Init --------------------------
	SET NOCOUNT ON;
	
	set @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

--
	set @StrWhere = '(1=1)'
	
	IF (@CurrentSerialNo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND th.SerialNo=' + STR(@CurrentSerialNo)
		
	IF (@SerialFr IS NOT null)
		SET @StrWhere = @StrWhere + ' AND th.SerialNo >= ' + STR(@SerialFr)
	IF (@SerialTo IS NOT null)
		SET @StrWhere = @StrWhere + ' AND th.SerialNo <= ' + STR(@SerialTo)
	
	IF (@FiscalYear IS NOT null)
		SET @StrWhere = @StrWhere + ' AND th.FiscalYear=' + STR(@FiscalYear)
		
-- ================ SELECT ===========================

	SET @StrSelect = '
	SELECT  rd.ServiceID, rd.RequestDesc, rd.HaveInvoice, rd.DoingDate, rd.DoingTime, rd.ContractDate, rd.ContractNo, 
			rd.Priority, rd.Confirm, rd.Qty, rd.TaskRegister, rd.ConfirmStatus, rd.ServiceKindID, td.AgreeDate, td.AgreeTime,td.Duration,
			rh.ContactDate, rh.ContactTime, rh.PhonerName, rh.CompanyID, th.DocDate, th.AdminCode, th.TaskDate, th.RegDate, 
			th.RegTime, pd.PersonnelID, ra.RequestCode, ra.RequestRow, th.SerialNo,
			acc.funGetServiceNameFull(rd.ServiceID,' + STR(@LangID) + ') ServiceName,
			prs.funGetPersonnelName(pd.PersonnelID,' + STR(@LangID) + ') PersonnelName,
			acc.funGetAcntName(rh.CompanyID,' + STR(@AcntPart) + ',' + STR(@LangID) + ') AcntName,
			(
				select top 1 UserSignature
				from ' + ltrim(@db_0000) + '.usr.tblUsers
				where PersonnelID=th.AdminCode
			) AdminSignature
	FROM srv.tblServiceTaskHdr th
			 LEFT JOIN srv.tblServiceTaskDtl td 
				 ON th.ProcessID = td.ProcessID AND th.ProcessNo = td.ProcessNo 
				 AND th.FiscalYear = td.FiscalYear AND th.SerialNo = td.SerialNo   
		          
			 LEFT JOIN srv.tblServiceTaskPersonnelDtl pd
				 ON td.ProcessID=pd.ProcessID AND td.ProcessNo=pd.ProcessNo
				  AND td.FiscalYear=pd.FiscalYear AND td.SerialNo=pd.SerialNo 
		         
			 LEFT JOIN srv.tblServiceTaskAtm1 ra 
				 ON th.ProcessID = ra.ProcessID AND th.ProcessNo = ra.ProcessNo  
				 AND th.FiscalYear = ra.FiscalYear AND th.SerialNo = ra.SerialNo
				 AND td.DocRowNo=ra.DocRowNo 
		         
			 LEFT JOIN srv.tblServiceRequestHdr rh 
				 ON ra.ProcessID=rh.ProcessID AND ra.ProcessNo=rh.ProcessNo AND 
				 ra.RequestFiscalYear = rh.FiscalYear And ra.RequestCode = rh.SerialNo 
		         
			 LEFT JOIN srv.tblServiceRequestDtl rd
				 ON ra.ProcessID = rd.ProcessID AND ra.ProcessNo = rd.ProcessNo
				 AND ra.RequestFiscalYear = rd.FiscalYear AND ra.RequestCode = rd.SerialNo 
				 AND ra.RequestRow=rd.DocRowNo
	WHERE ' + @StrWhere

-- ================ SELECT ===========================

	-- Exeute --------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

	--=========================================================================================
END
GO
