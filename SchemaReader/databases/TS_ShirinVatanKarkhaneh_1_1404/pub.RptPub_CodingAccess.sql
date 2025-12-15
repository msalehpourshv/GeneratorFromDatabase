USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/02/19
-- Viewed By	 : 
-- Last Modified : 1390/08/17
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
CREATE PROCEDURE [pub].[RptPub_CodingAccess]
	@TableName	varchar(100) = 'acc.tblAcntRng',
	@PartNumber	int = 0,
	@UsersList	varchar(200)= Null,
	@RepOptions	VarChar(10) = '1000',
	@RepInfo	NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE	@StrSelect	NVarChar(4000);
DECLARE	@StrFrom	NVarChar(4000);
DECLARE	@StrWhere	NVarChar(4000);
DECLARE	@StrDB0000	VarChar(100);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int; 
DECLARE	@UserID			Int;
DECLARE	@UserIsAdmin	bit;
DECLARE	@BranchDBName	NVarChar(50);

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	Select @BranchDBName = pub.funGetBranchDBName();

	-- Init -------------------------------------------------------------------
	IF (@RepInfo	Is Null)	SET @RepInfo = '1@1@1'
	IF (@RepOptions	Is Null)	SET @RepOptions = '1000'

	--SET @ShowQuantity	= Substring(@RepOptions, 1, 1)

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @UserID		= pub.funSplitString(@RepInfo, '@', 4);
	SET @UserIsAdmin= pub.funSplitString(@RepInfo, '@', 5);
	---------------------------------------------------------------------------
	-- Where Clause -----------------------------------------------------------
	set @StrDB0000 = LEFT(db_name(), Len(db_name()) - 4) + '0000'
	Set @StrWhere = '(1=1)'

	IF (@UsersList is not null) and (ltrim(@UsersList) <> '')
		SET @StrWhere = @StrWhere + ' AND (D.UserID in (' + @UsersList + '))'
		
	if (@PartNumber>0)
		SET @StrWhere = @StrWhere + ' AND (D.PartNumber=' + str(@PartNumber) + ')'
	------------------------------------------------------------
	-- Select Clause -------------------------------------------
	SET @StrSelect = '
	SELECT	D.UserID, ' + @BranchDBName + '.pub.funUserFullName(D.UserID) As UserName, D.FromCode, D.ToCode, D.AllowCodeView, D.AllowDefine, D.AllowChange, 
			D.AllowDelete, D.AllowEdit, D.AllowCodeClosedEdit, D.AccessAllCode,
			' + ltrim(@StrDB0000) + '.[pub].[funUserName](D.UserID) UserName,
			' + ltrim(@StrDB0000) + '.[pub].[funUserFullName](D.UserID) FullName
	FROM	' + @TableName + ' D
	WHERE	' + @StrWhere + '
	ORDER BY UserID'
	------------------------------------------------------------
	-- Run -----------------------------------------------------
	print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
