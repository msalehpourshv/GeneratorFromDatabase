USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/04
-- Viewed By	 : 
-- Last Modified : 1392/03/27
-- Last Modifier : TakroSystem\Zia
-- Description   : 
-- =============================================
Create FUNCTION acc.funGetCodeInfo
(
	@AcntCode VarChar(20)
)

RETURNS	@tbl Table 
	(
		Tel						VarChar(50) COLLATE Arabic_CS_AS,
		OtherTels				VarChar(100) COLLATE Arabic_CS_AS,
		EconomicalCode			VarChar(30) COLLATE Arabic_CS_AS,
		AcntName				NVarChar(500) COLLATE Arabic_CS_AS, 
		AcntComment				NVarChar(100) COLLATE Arabic_CS_AS,
		Address1				NVarChar(2000) COLLATE Arabic_CS_AS,
		Address2				NVarChar(2000) COLLATE Arabic_CS_AS,
		InitialGrad				BigInt,
		CustomerFirstName		NVarChar(200) COLLATE Arabic_CS_AS,
		CustomerLastName		NVarChar(200) COLLATE Arabic_CS_AS,
		ZipCode					VarChar(20) COLLATE Arabic_CS_AS,
		CompanyRegisterNo		NVarChar(30) COLLATE Arabic_CS_AS,
		NationalIDNumber		VarChar(50) COLLATE Arabic_CS_AS,
		LocationID				VarChar(20) COLLATE Arabic_CS_AS,
		Mobile					VarChar(50) COLLATE Arabic_CS_AS,
		SMSMobile				VarChar(100) COLLATE Arabic_CS_AS,
		OrganzationName			nvarchar(2000) COLLATE Arabic_CS_AS,
		MaxDebitRemain			float,
		MaxReceivableRemain		float,
		DistributionPoint		nvarchar(50),
		AsnafID					nvarchar(10),
		Sequence				int,
		Fax						varchar(50) COLLATE Arabic_CS_AS,
		Email					varchar(50) COLLATE Arabic_CS_AS,

		InternetAddress			varchar(80) COLLATE Arabic_CS_AS,

		MemberDate				varchar(10) COLLATE Arabic_CS_AS,
		VisitPathID1			varchar(20) COLLATE Arabic_CS_AS,
		VisitPathID2			varchar(20) COLLATE Arabic_CS_AS,
		VisitPathID3			varchar(20) COLLATE Arabic_CS_AS,
		VisitPathID4			varchar(20) COLLATE Arabic_CS_AS,
		CampaignID				varchar(20) COLLATE Arabic_CS_AS,
		TransporterID			varchar(20) COLLATE Arabic_CS_AS,
		NationalIdentity		nvarchar(50) COLLATE Arabic_CS_AS,
		AccExtraField1			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField2			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField3			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField4			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField5			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField6			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField7			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField8			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField9			nvarchar(500) COLLATE Arabic_CS_AS,
		AccExtraField10			nvarchar(500) COLLATE Arabic_CS_AS,
		SaleCustomerType		INT ,
		BuyCustomerType			INT,
		CustomerKindID			varchar(20) COLLATE Arabic_CS_AS,
		SalesRoomClass			varchar(20) COLLATE Arabic_CS_AS,
		SaleCash				int,
		TableauText				nvarchar(200) COLLATE Arabic_CS_AS,
		AcntContainTax			Bit,
		PersonType				Tinyint,
		PersonTypeName			varchar(50),
		AccountNumber			varchar(50),
		ShabaAccountNumber		varchar(50),
		PayIdentity				varchar(50),
		CodeClosed				Bit,
		StoreZipCode			varchar(20) COLLATE Arabic_CS_AS
	)
WITH ENCRYPTION
AS 
Begin
	DECLARE	@StrAcnt1Start	TinyInt
	DECLARE	@StrAcnt2Start	TinyInt
	DECLARE	@StrAcnt3Start	TinyInt
	DECLARE	@StrAcnt4Start	TinyInt

	DECLARE	@StrAcnt1Len	TinyInt
	DECLARE	@StrAcnt2Len	TinyInt
	DECLARE	@StrAcnt3Len	TinyInt
	DECLARE	@StrAcnt4Len	TinyInt

	DECLARE	@StrAcnt1End	TinyInt
	DECLARE	@StrAcnt2End	TinyInt
	DECLARE	@StrAcnt3End	TinyInt
	DECLARE	@StrAcnt4End	TinyInt

	DECLARE	@intCurrent		TinyInt
	DECLARE	@intLangID		TinyInt

	SET @intLangID = pub.funGetCurrentLanguageID()

	SELECT	@StrAcnt1Start = 1;

	SELECT	@StrAcnt1End = @StrAcnt1Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1
	FROM	pub.tblCodeLayer 
	WHERE  (TableName = 'acc.tblAcnt') AND (PartNumber = 1)

	SELECT	@StrAcnt1Len = @StrAcnt1End + 1 - @StrAcnt1Start;

	--------------------------------------------------------------------

	SELECT	@StrAcnt2Start = @StrAcnt1End + 2;

	SELECT	@StrAcnt2End = @StrAcnt2Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 2)

	SELECT	@StrAcnt2Len = @StrAcnt2End + 1 - @StrAcnt2Start;

	--------------------------------------------------------------------

	SELECT	@StrAcnt3Start = @StrAcnt2End + 2;

	SELECT	@StrAcnt3End = @StrAcnt3Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 3)

	SELECT	@StrAcnt3Len = @StrAcnt3End + 1 - @StrAcnt3Start;

	--------------------------------------------------------------------

	SELECT	@StrAcnt4Start = @StrAcnt3End + 2;

	SELECT	@StrAcnt4End = @StrAcnt4Start + Layer1 + Layer2 + Layer3 + Layer4 + Layer5 + Layer6 + Layer7 + Layer8 + Layer9 - 1 
	FROM	pub.tblCodeLayer 
	WHERE	(TableName = 'acc.tblAcnt') AND (PartNumber = 4)

	SELECT	@StrAcnt4Len = @StrAcnt4End + 1 - @StrAcnt4Start;

	--------------------------------------------------------------------
	Declare @NamePartNo AS Tinyint
	
	SET @NamePartNo = 0
	
	SELECT @NamePartNo = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	--------------------------------------------------------------------
	IF @NamePartNo > 0
		BEGIN
			IF @NamePartNo = 1 AND LEN(@AcntCode) >= @StrAcnt1Start  
			  BEGIN 
					INSERT INTO @tbl
					Select	Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
							LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
							MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, InternetAddress, MemberDate, 
							VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID,NationalIdentity, 
							AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
							A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass, A.SaleCash,
							AD.TableauText, A.ContainTax,A.PersonType,
							case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
							A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
					FROM	acc.tblAcnt A 
								INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber 
					WHERE  A.PartNumber = 1 AND A.AcntCode = Substring(@AcntCode, 1, @StrAcnt1Len)  AND LanguageID = @intLangID 
			  End
			ELSE IF @NamePartNo = 2  AND LEN(@AcntCode)>=@StrAcnt2Start
			  BEGIN 
					INSERT INTO @tbl		
					Select	Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
							LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
							MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, InternetAddress, MemberDate, 
							VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID,NationalIdentity,
							AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
							A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass, A.SaleCash, AD.TableauText, 
							A.ContainTax,A.PersonType,
							case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
							A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
					FROM	acc.tblAcnt A
									INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber 
					WHERE  A.PartNumber = 2 AND A.AcntCode  = Substring(@AcntCode, @StrAcnt2Start, @StrAcnt2Len) AND LanguageID = @intLangID 
			  END 
			ELSE IF @NamePartNo = 3 AND LEN(@AcntCode)>=@StrAcnt3Start
			  BEGIN 
					INSERT INTO @tbl
					Select	Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
							LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
							MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, InternetAddress, MemberDate, 
							VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID,NationalIdentity,
							AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
							A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass, A.SaleCash, AD.TableauText, 
							A.ContainTax,A.PersonType,
							case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
							A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
					FROM	acc.tblAcnt A 
								INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber 
					WHERE  A.PartNumber = 3 AND A.AcntCode  = Substring(@AcntCode, @StrAcnt3Start, @StrAcnt3Len) AND LanguageID = @intLangID 
			  END 
			ELSE IF @NamePartNo = 4 AND LEN(@AcntCode)>=@StrAcnt4Start
			  BEGIN 
					INSERT INTO @tbl		
					Select	Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
							LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
							MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, InternetAddress, MemberDate, 
							VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID,NationalIdentity,
							AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
							A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass ,A.SaleCash, AD.TableauText, 
							A.ContainTax ,A.PersonType,
							case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
							A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
					FROM	acc.tblAcnt A 
								INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber 
					WHERE  A.PartNumber = 4 AND A.AcntCode  = Substring(@AcntCode, @StrAcnt4Start, @StrAcnt4Len) AND LanguageID = @intLangID
			  End 					
		END
	--------------------------------------------------------------------
	IF (SELECT COUNT(*) FROM @tbl)=0
		BEGIN
			If Len(@AcntCode) <= @StrAcnt1End
			Begin
				INSERT INTO @tbl		
				SELECT	DISTINCT Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
								 LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
								 MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, InternetAddress,
								 MemberDate, VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID, NationalIdentity,
								 AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
								 A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass, A.SaleCash, AD.TableauText, 
								 A.ContainTax ,A.PersonType,
								 case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
								 A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
				FROM	acc.tblAcnt A 
							INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber
				WHERE	A.PartNumber = 1 AND A.AcntCode = @AcntCode  AND LanguageID = @intLangID
			End

			Else If Len(@AcntCode) <= @StrAcnt2End
			Begin
				INSERT INTO @tbl		
				SELECT	DISTINCT  Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, 
								  FirstName, LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, 
								  OrganzationName, MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, 
								  Fax, Email, InternetAddress, MemberDate, VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID,
								  NationalIdentity,AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
								  A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass ,A.SaleCash, 
								  AD.TableauText, A.ContainTax ,A.PersonType,
								  case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
								  A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
				FROM	acc.tblAcnt A 
							INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber
				WHERE	A.PartNumber = 2 AND A.AcntCode = Substring(@AcntCode, @StrAcnt2Start, @StrAcnt2Len)  AND LanguageID = @intLangID
			End 

			Else If Len(@AcntCode) <= @StrAcnt3End
			Begin
	   			INSERT INTO @tbl		
				SELECT	DISTINCT  Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
								  LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
								  MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, InternetAddress,
								  MemberDate, VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID,
								  NationalIdentity,AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
								  A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass,
								  A.SaleCash, AD.TableauText, A.ContainTax ,A.PersonType,
								  case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
								  A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
				FROM	acc.tblAcnt A 
							INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber
				WHERE	A.PartNumber = 3 AND A.AcntCode = Substring(@AcntCode, @StrAcnt3Start, @StrAcnt3Len)  AND LanguageID = @intLangID
			End

			Else If Len(@AcntCode) <= @StrAcnt4End
			Begin
	   			INSERT INTO @tbl		
				SELECT	DISTINCT  Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
								  LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
								  MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, InternetAddress,
								  MemberDate, VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,CampaignID,TransporterID,
								  NationalIdentity,AccExtraField1, AccExtraField2, AccExtraField3, AccExtraField4, AccExtraField5, AccExtraField6, AccExtraField7, AccExtraField8, AccExtraField9, AccExtraField10,
								  A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass, 
								  A.SaleCash, AD.TableauText, A.ContainTax ,A.PersonType,
								  case when A.PersonType=0 then '' when A.PersonType=1 then 'حقیقی' when A.PersonType=2 then 'حقوقی' when A.PersonType=3 then 'مشارکت مدنی' when A.PersonType=4 then 'اتباع غیر ایرانی' when A.PersonType=5 then 'مصرف کننده نهایی' end PersonTypeName,
								  A.AccountNumber,A.ShabaAccountNumber,A.PayIdentity,CodeClosed,StoreZipCode
				FROM	acc.tblAcnt A 
							INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber
				WHERE	A.PartNumber = 4 AND A.AcntCode = Substring(@AcntCode, @StrAcnt4Start, @StrAcnt4Len)  AND LanguageID = @intLangID
			End
		End
		update @tbl
		set AcntName= pub.GetCodeName(@AcntCode,1)
	RETURN

END
GO
