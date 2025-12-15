USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Hadi Sadeghi
-- Create date   : 1397/11/04
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [srv].[SPServiceRequestForOneCompany] 
	@CompanyID VARCHAR(30)='0100001',
	@IsAdmin bit=1,
	@UserID INT=0,
	@Service1Len INT=0,
	@Service2Len INT=0,
	@Service3Len INT=0,
	@Service4Len INT=0

WITH ENCRYPTION
AS
BEGIN ;
	SELECT SRH.DocDate [تاریخ], LTRIM(STR(SRH.FiscalYear)) + '/' + LTRIM(STR(SRH.SerialNo)) +'-' + LTRIM(STR(SRH.SerialNo)) [شماره برگه],
		   PhonerName [تماس گیرنده],prs.funGetPersonnelName(SRH.PersonnelID,1) [ثبت کننده],
		   K.ServiceKindName [نوع خدمات],acc.funGetServiceNameFull(SRD.ServiceID,1) [نام کار],RequestDesc [شرح],
		   Value2 [فوریت],ReqImportance [اهمیت],
		   CASE TaskStatus WHEN 1 THEN 'خاتمه یافته' WHEN 2 THEN 'عدم انجام' WHEN 3 then 'خاتمه یافته' else case TaskRegister when 0 then 'شروع نشده' ELSE 'در دست اقدام' END END [وضعیت]
	FROM srv.tblServiceRequestHdr SRH
	INNER JOIN srv.tblServiceRequestDtl SRD
	ON SRH.ProcessID=SRD.ProcessID
	AND SRH.ProcessNo=SRD.ProcessNo
	AND SRH.FiscalYear=SRD.FiscalYear
	AND SRH.SerialNo=SRD.SerialNo
	LEFT JOIN srv.tblServiceKindDtl K on K.ServiceKindID = SRD.ServiceKindID
	WHERE CompanyID = @CompanyID  
	AND (@IsAdmin = 1 OR 
			(
			 ([srv].[funServiceKindPermitted] (@UserID,K.ServiceKindID)=1) AND
			 (@Service1Len = 0 OR (@Service1Len>0 AND [acc].[funServiceCodingPermitted](@UserID,SUBSTRING(SRD.ServiceID,1,@Service1Len),1)=1)) AND
			 (@Service2Len = 0 OR (@Service2Len>0 AND [acc].[funServiceCodingPermitted](@UserID,SUBSTRING(SRD.ServiceID,2 + @Service1Len ,@Service2Len),1)=1)) AND
			 (@Service3Len = 0 OR (@Service3Len>0 AND [acc].[funServiceCodingPermitted](@UserID,SUBSTRING(SRD.ServiceID,3 + @Service1Len + @Service2Len ,@Service3Len),1)=1)) AND
			 (@Service4Len = 0 OR (@Service4Len>0 AND [acc].[funServiceCodingPermitted](@UserID,SUBSTRING(SRD.ServiceID,4 + @Service1Len + @Service2Len + @Service3Len  ,@Service4Len),1)=1)) 
			)
		)
	ORDER BY SRH.DocDate DESC,SRH.SerialNo DESC,SRD.DocRowNo
END
GO
