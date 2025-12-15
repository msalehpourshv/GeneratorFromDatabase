USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Creation date : 1388/03/02
-- Viewed By	 : 
-- Last Modified : 1392/06/25
-- Last Modifier : TakroSystem\Ahmadnejad
-- Description	 : دفترچه تلفن
-- ===============================================
CREATE PROCEDURE [pub].[RptTel]
	@Prefix			VarChar(20) = Null,
	@LocationID		VarChar(20) = Null,
	@LastName		NVarChar(50) = Null,
	@CompanyName	NVarChar(Max) = Null
WITH ENCRYPTION
AS
DECLARE @StrWhere  NVarChar(2000)
DECLARE @StrSelect NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;

DECLARE	@bolFilterType	Bit;
DECLARE	@strFilterType	NVarChar(50);
DECLARE	@strFilterType2	NVarChar(50);

DECLARE	@CompName			NVarChar(50) 	
DECLARE	@Name				NVarChar(50) 	
DECLARE	@PrefixCode			VarChar(15)  	
DECLARE	@Tel				NVarChar(50) 	
DECLARE	@Mobile				NVarChar(50) 	
DECLARE	@SMSMobile			NVarChar(50) 	
DECLARE	@Fax				NVarChar(50) 	
DECLARE	@PostCode			NVarChar(50) 	
DECLARE	@NationalIDNumber	NVarChar(50) 	
DECLARE	@Email				NVarChar(50) 	
DECLARE	@Website			NVarChar(50) 	
DECLARE	@CustomerKindID		VarChar(20)  	
DECLARE	@OtherTels			NVarChar(20) 	
DECLARE	@Address			NVarChar(20) 	
DECLARE	@Address2			NVarChar(50) 	
DECLARE	@Description		NVarChar(50) 	
DECLARE	@TelExtraField1		NVarChar(1000) 	
DECLARE	@TelExtraField2		NVarChar(1000)  
DECLARE	@TelExtraField3		NVarChar(1000)  
DECLARE	@TelExtraField4		NVarChar(1000)  
DECLARE	@TelExtraField5		NVarChar(1000)

BEGIN 
	--============================ S T A R T ===========================================

	SET NOCOUNT ON;

	SET @Prefix = LTRIM(RTRIM(@Prefix));
	
	-- ================	
	SET @CompName			= LTrim(pub.funSplitString(@CompanyName, '@', 1)); 
	SET @Name				= LTrim(pub.funSplitString(@CompanyName, '@', 2)); 
	SET @PrefixCode			= LTrim(pub.funSplitString(@CompanyName, '@', 3)); 
	SET @Tel				= LTrim(pub.funSplitString(@CompanyName, '@', 4)); 
	SET @Mobile				= LTrim(pub.funSplitString(@CompanyName, '@', 5)); 
	SET @SMSMobile			= LTrim(pub.funSplitString(@CompanyName, '@', 6)); 
	SET @Fax				= LTrim(pub.funSplitString(@CompanyName, '@', 7)); 
	SET @PostCode			= LTrim(pub.funSplitString(@CompanyName, '@', 8)); 
	SET @NationalIDNumber	= LTrim(pub.funSplitString(@CompanyName, '@', 9)); 
	SET @Email				= LTrim(pub.funSplitString(@CompanyName, '@', 10)); 
	SET @Website			= LTrim(pub.funSplitString(@CompanyName, '@', 11)); 
	SET @CustomerKindID		= LTrim(pub.funSplitString(@CompanyName, '@', 12)); 
	SET @OtherTels			= LTrim(pub.funSplitString(@CompanyName, '@', 13)); 
	SET @Address			= LTrim(pub.funSplitString(@CompanyName, '@', 14)); 
	SET @Address2			= LTrim(pub.funSplitString(@CompanyName, '@', 15)); 
	SET @Description		= LTrim(pub.funSplitString(@CompanyName, '@', 16)); 
	SET @TelExtraField1		= LTrim(pub.funSplitString(@CompanyName, '@', 17)); 
	SET @TelExtraField2		= LTrim(pub.funSplitString(@CompanyName, '@', 18)); 
	SET @TelExtraField3		= LTrim(pub.funSplitString(@CompanyName, '@', 19)); 
	SET @TelExtraField4		= LTrim(pub.funSplitString(@CompanyName, '@', 20)); 
	SET @TelExtraField5		= LTrim(pub.funSplitString(@CompanyName, '@', 21)); 
	SET @bolFilterType		= LTrim(pub.funSplitString(@CompanyName, '@', 22)); 

	-- ================	
	SET @strFilterType = 'LIKE'
	SET @strFilterType2 = '%'
	
	IF @bolFilterType = 1
	Begin
		SET @strFilterType = '='
		SET @strFilterType2 = ''
	End
		
	-- WHERE --------------------------------------------------------------------------
	SET @StrWhere = '(H.TelID <> '''')'
	
	if (@Prefix is not null) and (@Prefix <> '')
		SET @StrWhere = @StrWhere + ' AND (Left(H.TelID,' + LTrim(RTrim(STR(LEN(@Prefix)))) + ') = ''' + @Prefix + ''') and (Len(H.TelID) > ''' + @Prefix + ''')'

	IF (@LocationID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (H.LocationID = ''' + @LocationID + ''')'

	IF (@LastName Is Not Null)
		SET @StrWhere = @StrWhere + ' AND (D.LastName ' + @strFilterType + ' ''' + @LastName + '' + @strFilterType2 + ''')'

	IF (@CompName <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.CompanyName ' + @strFilterType + ' ''' + @CompName + '' + @strFilterType2 + ''')'

	IF (@Name <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.FirstName ' + @strFilterType + ' ''' + @Name + '' + @strFilterType2 + ''')'
		
	IF (@PrefixCode <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.PrefixCode ' + @strFilterType + ' ''' + @PrefixCode + '' + @strFilterType2 + ''')'
		
	IF (@Tel <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.Tel ' + @strFilterType + ' ''' + @Tel + '' + @strFilterType2 + ''')'

	IF (@Mobile <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.Mobile ' + @strFilterType + ' ''' + @Mobile + '' + @strFilterType2 + ''')'
		
	IF (@SMSMobile <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.SMSMobile ' + @strFilterType + ' ''' + @SMSMobile + '' + @strFilterType2 + ''')'
		
	IF (@Fax <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.Fax ' + @strFilterType + ' ''' + @Fax + '' + @strFilterType2 + ''')'
		
	IF (@PostCode <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.ZipCode ' + @strFilterType + ' ''' + @PostCode + '' + @strFilterType2 + ''')'										
		
	IF (@NationalIDNumber <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.NationalIDNumber ' + @strFilterType + ' ''' + @NationalIDNumber + '' + @strFilterType2 + ''')'	
		
	IF (@Email <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.EMail ' + @strFilterType + ' ''' + @Email + '' + @strFilterType2 + ''')'							
					
	IF (@Website <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.Website ' + @strFilterType + ' ''' + @Website + '' + @strFilterType2 + ''')'
		
	IF (@CustomerKindID <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.CustomerKindID = ''' + @CustomerKindID + '' + @strFilterType2 + ''')'
		
	IF (@OtherTels <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (H.OtherTels ' + @strFilterType + ' ''' + @OtherTels + '' + @strFilterType2 + ''')'
		
	IF (@Address <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.Address ' + @strFilterType + ' ''' + @Address + '' + @strFilterType2 + ''')'
		
	IF (@Address2 <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.Address2 ' + @strFilterType + ' ''' + @Address2 + '' + @strFilterType2 + ''')'									
				
	IF (@Description <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.Description ' + @strFilterType + ' ''' + @Description + '' + @strFilterType2 + ''')'
		
	IF (@TelExtraField1 <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.TelExtraField1 ' + @strFilterType + ' ''' + @TelExtraField1 + '' + @strFilterType2 + ''')'
		
	IF (@TelExtraField2 <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.TelExtraField2 ' + @strFilterType + ' ''' + @TelExtraField2 + '' + @strFilterType2 + ''')'
		
	IF (@TelExtraField3 <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.TelExtraField3 ' + @strFilterType + ' ''' + @TelExtraField3 + '' + @strFilterType2 + ''')'
		
	IF (@TelExtraField4 <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.TelExtraField4 ' + @strFilterType + ' ''' + @TelExtraField4 + '' + @strFilterType2 + ''')'
		
	IF (@TelExtraField5 <> 'Null')
		SET @StrWhere = @StrWhere + ' AND (D.TelExtraField5 ' + @strFilterType + ' ''' + @TelExtraField5 + '' + @strFilterType2 + ''')'								
					
	-- SELECT --------------------------------------------------------------------------
	SET @StrSelect = '
	SELECT  H.*, D.TelID, D.FirstName, D.LastName, D.CompanyName, 
			D.Address, D.Description, D.Address2, LD.LocationName
	FROM	pub.tblTel H 
	INNER JOIN pub.tblTelDtl D ON D.TelID = H.TelID 
	LEFT  OUTER JOIN pub.tblLocationsDtl LD ON LD.LocationID = H.LocationID 
	WHERE ' + @StrWhere

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

END
GO
