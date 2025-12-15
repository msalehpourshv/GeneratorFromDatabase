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
CREATE PROCEDURE [srv].[RptSrv_PersonnelWork_Day]
	@Date		    CHAR(10) = Null,
	@PersonnelID	VarChar(20) = Null,
	@CompanyID		VarChar(20) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect	NVarChar(4000);

Declare @StrSelect1	NVarChar(2000);
Declare @StrFrom1	NVarChar(2000);
Declare @StrWhere1	NVarChar(2000);

Declare @StrSelect2	NVarChar(2000);
Declare @StrFrom2	NVarChar(2000);
Declare @StrWhere2	NVarChar(2000);

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
DECLARE @db_0000	nvarchar(50);

Begin -- ============== S T A R T  C O D E ====================================

	SET NOCOUNT ON;

	--========================
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart
		
	SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
	
	-- Init Variables -------------------------------------
		
	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

	-- Where Clause -----------------------------------------
	Select @StrWhere1 = '1 = 1'
	Select @StrWhere2 = '1 = 1'

	IF (@Date IS NOT NULL)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND EventDate <= ''' + @Date + ''''
		SET @StrWhere2 = @StrWhere2 + ' AND DocDate <= ''' + @Date + ''''
	End
		
  	IF (@PersonnelID IS NOT NULL)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND PersonelID = ''' + @PersonnelID + '''' 
		SET @StrWhere2 = @StrWhere2 + ' AND PersonnelID = ''' + @PersonnelID + '''' 
	End
		
  	IF (@CompanyID IS NOT NULL)
	Begin
		SET @StrWhere1 = @StrWhere1 + ' AND 
			(srv.funGetCompanyID (SA2.SerialNo ,SA2.FiscalYear ,SA2.DocRowNo ,
			 SA2.PersonelID)) = ''' + @CompanyID + '''' 
	
		SET @StrWhere2 = @StrWhere2 + ' AND CompanyID = ''' + @CompanyID + '''' 
	End
		
	-- Select Clause -------------------------------------------
	print 1
	SET @StrSelect1 = '
    Select prs.funGetPersonnelName(PersonelID,1) As PersonnelName ,EventDate ,Sum(Duration) As Duration ,
           ''�����'' As Type, '''' As GoodsID, '''' As GoodsName, '''' As UnitID, '''' As UnitName
    From srv.tblServiceTaskAtm2 SA2
	WHERE ' + @StrWhere1 + ' 
	Group By PersonelID ,EventDate UNION '
	
	SET @StrSelect2 = '
    Select prs.funGetPersonnelName(T.PersonnelID,1) As PersonnelName ,T.DocDate ,Sum(T.Duration) As Duration ,
           ''���� �����'' As Type, T.GoodsID, [pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + ') GoodsName, 
           IsNull(S.UnitID, '''') UnitID, IsNull(U.UnitName, '''') UnitName
    From srv.tblTelService T
	LEFT JOIN inv.tblGoods S ON S.GoodsID=SUBSTRING(T.GoodsID,' + ltrim(rtrim(STR(@str_Goods+1))) + ',' + ltrim(rtrim(STR(@str_GoodsSum))) + ') AND S.PartNumber=' + ltrim(rtrim(STR(@UnitPart)))+ '
	LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = S.UnitID AND U.LanguageID = ' + LTRIM(str(@LangID)) + '    
	WHERE ' + @StrWhere2 + ' 
	Group By T.PersonnelID ,T.DocDate, T.GoodsID, [pub].[funGetGoodsName](T.GoodsID,' + LTrim(RTrim(@LangID)) + '), S.UnitID, U.UnitName '

	SET @StrSelect = @StrSelect1 + @StrSelect2

	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
End
GO
