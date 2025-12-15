USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Jafari
-- Create date   : 1398/09/27
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- ----------------------------------------------
-- Description	 : < مانده حساب مشتریان برای CRM  رز>
-- ==============================================
Create PROCEDURE crm.SpAcntInfo
	@AcntCode			Varchar(20)
	
WITH ENCRYPTION
AS
BEGIN
	Declare @StrSelect nVarchar(max)
	Declare @StrWhere nVarchar(max)
	declare @UserID				int;

	SELECT @UserID = isnull(SettingValue,-1) FROM pub.tblSettings	WHERE SettingKey = 'UserExternalCRM'	

	if @UserID=0
		set @UserID=-1

	declare @PartNumber				int;
	select @PartNumber=[acc].[FunGetAcntInfoForRemain](1)

	BEGIN TRY
			DROP TABLE #tblAcntCode
		END TRY
		BEGIN CATCH
		END CATCH
	 CREATE TABLE #tblAcntCode
	(
	AcntCode 			Varchar(20)collate arabic_cs_as null
	)

	 Insert into  #tblAcntCode (AcntCode) 
	 SELECT	Distinct a.AcntCode	
		FROM	acc.tblAcnt  a
			where PartNumber =@PartNumber 

 	DELETE 
	from  #tblAcntCode 
		where   AcntCode not in (
		    select AcntCode		 from  #tblAcntCode A
				where 1=1  AND(
							(Select COUNT(*) from acc.tblAcntRng
								where acc.tblAcntRng.UserID=@UserID AND AllowCodeView=1 AND acc.tblAcntRng.PartNumber=@PartNumber  AND
								(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
							AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
							)>0 
							
							OR 
								(Select COUNT(*) from acc.tblAcntRng
								where  acc.tblAcntRng.UserID=@UserID AND acc.tblAcntRng.PartNumber=@PartNumber  AND AccessAllCode=1)>0
							)
							
						  AND(
							(Select COUNT(*) from acc.tblAcntRng
								where acc.tblAcntRng.UserID=@UserID AND AllowCodeView=0 AND acc.tblAcntRng.PartNumber=@PartNumber  AND
								(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
							AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
							)=0 
							OR
							(Select COUNT(*) from acc.tblAcntRng
								where acc.tblAcntRng.UserID=-1 AND AllowCodeView=0 AND acc.tblAcntRng.PartNumber=@PartNumber  AND
								(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
							AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
							)=0 
							)
							
					)
					
	
	--select AcntCode		 from  #tblAcntCode
	SET @StrWhere =  ' Where 1=1 '
		SET @StrWhere +=  '   AND a.AcntCode in (SELECT  AcntCode FROM  #tblAcntCode    ) '
		
	set @StrSelect='
		SELECT	a.AcntCode,AcntName,AcntComment,FirstName,LastName,OrganzationName,Address1,Address2,
					GradDesc,DistributionPoint,AsnafID,TableauText,SensiblePoint,PlaceOldName,
					CustomerFamous,ParticularDateText1,ParticularDateText2,ParticularDateText3,ParticularDateText4,
					ManagerView,VisitorView,CodeClosed, a.LocationID,LocationName,Tel,Fax,OtherTels,ZipCode,EconomicalCode,
					MaxDebitRemain,MaxReceivableRemain,MaxDaysAfterExpiration, 
					PersonnelNo,IDNo,InitialGrad,CompanyRegisterNo,Mobile,NationalIDNumber,
					MaxReturnCheque,MemberCode,MemberDate,Email,InternetAddress,
					CustomerKindID,Sequence,FatherName,SMSMobile, 
					CompleteDate,PersonType,Zone,PossessionType,SalesRoomSituation,
					SalesRoomClass,PortalCount,GPSPoint,BirthDate,VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,
					ParticularDate1,ParticularDate2,ParticularDate3,ParticularDate4, TransporterID,NationalIdentity,
					FineExemption,FineDelayPercent,SaleCustomerType,BuyCustomerType,ComplementCredit,MinSalePrice,
					MaxSalePrice,FreeDocDays,OutStandChequeCount,OutStandChequePrice,ReturnChequeCount,OpenAccInvoiceCount,
					CampaignID, 	SaleTypeID,SaleCash,ContainTax,Gender,MaxReturnChequeDays,TransferCostIsForce,
					ValidDateIsForce,LastSaleDateAlarm, LastUpdate 
		FROM	acc.tblAcnt a
		INNER join acc.tblAcntDtl b
			ON a.PartNumber= b.PartNumber
				 and a.AcntCode= b.AcntCode AND a.PartNumber='+str(@PartNumber) +' AND b.LanguageID=1
		left join pub.tblLocationsDtl l on a.LocationID=l.LocationID  AND l.LanguageID=1	'
		 
	 set @StrSelect= @StrSelect + @StrWhere
	set @StrSelect= @StrSelect + ' and ('''+ @AcntCode+'''='''' or a.AcntCode='''+ @AcntCode+''')  '
			
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	
END



GO
