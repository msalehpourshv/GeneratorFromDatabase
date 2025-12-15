USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Creation date : 1401/10/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 :  تعریف مشتری
-- ===============================================
Create PROCEDURE lyl.RptCustomerInfo
	@ExtraParams		NVarChar(Max) = '',
	@RepInfo			NVarChar(100) = '1@1@1',
	@RepOptions			VarChar(20) = '111' -- bit array	
WITH ENCRYPTION
AS
BEGIN

DECLARE @StrWhere  NVarChar(2000)
DECLARE @StrSelect NVarChar(2000)

DECLARE	@LangID		Char(1);
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int;
 
	--============================ S T A R T ===========================================

	SET NOCOUNT ON;

	Set @StrWhere='1=1'				
	-- SELECT --------------------------------------------------------------------------
	SET @StrSelect = '
	select a.*,LanguageID	,FirstName	,LastName,	Adress,	Case When Gender=1 then ''آقای ''  else '' خانم''   end GenderType 
	from lyl.tblCustomerInfo a 
		left join lyl.tblCustomerInfoDtl b on a.CustomerInfoID=b.CustomerInfoID
	WHERE ' + @StrWhere

	Print @StrSelect;
	Exec sp_executesql @StrSelect;

END
GO
