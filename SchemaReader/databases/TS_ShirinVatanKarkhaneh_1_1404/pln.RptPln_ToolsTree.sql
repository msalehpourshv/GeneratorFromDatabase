USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/12/08
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : 
-- =============================================
CREATE PROCEDURE [pln].[RptPln_ToolsTree]
	@SelectedTools	Int = 0,
	@RepOptions		VarChar(10) = '111',
	@RepInfo		VarChar(20) = '1@1@1'
WITH ENCRYPTION
AS
DECLARE	@LangID		Int;
DECLARE	@SessionNo	Int; 
DECLARE	@ReportID	Int; 

declare @StrSelect	nvarchar(4000)
declare @StrWhere	nvarchar(4000)
declare @StrFrom	nvarchar(4000)
Begin
	SET NOCOUNT ON;

	-- init -------------------------------------------------------------------
	IF (@RepInfo Is Null)	SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	-------------------------------------------------------------------------------------
	set @StrWhere = '(1=1)'

	if (@SelectedTools > 0)
	begin
		set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'R.SuperToolID')
		--set @StrWhere = @StrWhere + ' and ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedTools, 'R.SubToolID')
	end;
	-------------------------------------------------------------------------------------
	set @StrSelect = '
	select	R.SuperToolID, R.SubToolID, T1.ToolName as SuperToolName, T2.ToolName as SubToolName
	from
	(
		select	SuperToolID, SubToolID
		from	pln.tblToolRelations
		union all
		select	ToolID, null
		from	pln.tblTools
		where   (ToolID <> '''') and ToolID not in (select SuperToolID from pln.tblToolRelations)
	) R 
		left join pln.tblTools T1 on T1.ToolID = R.SuperToolID
		left join pln.tblTools T2 on T2.ToolID = R.SubToolID
	WHERE ' + @StrWhere
	-------------------------------------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
End
GO
