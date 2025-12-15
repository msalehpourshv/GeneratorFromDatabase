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
Create FUNCTION [acc].[funGetCodeInfo_RemainCalculation]
(
	@AcntCode VarChar(20),
	@NamePartNo AS Tinyint
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
		MemberDate				varchar(10) COLLATE Arabic_CS_AS,
		VisitPathID1			varchar(20) COLLATE Arabic_CS_AS,
		VisitPathID2			varchar(20) COLLATE Arabic_CS_AS,
		VisitPathID3			varchar(20) COLLATE Arabic_CS_AS,
		VisitPathID4			varchar(20) COLLATE Arabic_CS_AS,
		TransporterID			varchar(20) COLLATE Arabic_CS_AS,
		NationalIdentity		nvarchar(50) COLLATE Arabic_CS_AS,
		SaleCustomerType		INT ,
		BuyCustomerType			INT,
		CustomerKindID			varchar(20) COLLATE Arabic_CS_AS,
		SalesRoomClass			varchar(20) COLLATE Arabic_CS_AS,
		SaleCash				int,
		TableauText				nvarchar(200) COLLATE Arabic_CS_AS,
		AcntContainTax			Bit,
		PersonType				Tinyint,
		AccountNumber			varchar(50),
		ShabaAccountNumber		varchar(50)
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

	
	--------------------------------------------------------------------
	--Declare 
	
	--SET @NamePartNo = 0
	
	--SELECT @NamePartNo = SettingValue
	--FROM pub.tblSettings
	--WHERE SettingKey = 'AcntPartNumberForRemainCalculation'

	--------------------------------------------------------------------
	IF @NamePartNo > 0
		BEGIN
			INSERT INTO @tbl
			Select	Tel, OtherTels, EconomicalCode, AcntName, AcntComment, Address1, Address2, InitialGrad, FirstName, 
					LastName, ZipCode, CompanyRegisterNo, NationalIDNumber, LocationID, Mobile, SMSMobile, OrganzationName, 
					MaxDebitRemain, MaxReceivableRemain, DistributionPoint, AsnafID, Sequence, Fax, Email, MemberDate, 
					VisitPathID1,VisitPathID2,VisitPathID3,VisitPathID4,TransporterID,NationalIdentity,
					A.SaleCustomerType,A.BuyCustomerType,A.CustomerKindID,A.SalesRoomClass, A.SaleCash, 
					AD.TableauText, A.ContainTax,A.PersonType,A.AccountNumber,A.ShabaAccountNumber
			FROM	acc.tblAcnt A 
						INNER JOIN acc.tblAcntDtl AD ON A.AcntCode = AD.AcntCode AND A.PartNumber = AD.PartNumber 
			WHERE  A.PartNumber = @NamePartNo AND A.AcntCode = @AcntCode AND LanguageID = @intLangID 
		END
	--------------------------------------------------------------------
	
	RETURN

END
GO
