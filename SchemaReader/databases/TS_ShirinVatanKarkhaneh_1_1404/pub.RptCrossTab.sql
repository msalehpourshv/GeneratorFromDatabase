USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1389/06/17
-- Viewed By	 : 
-- Last Modified :
-- Last Modifier :
-- Description   :
-- ==============================================
CREATE PROCEDURE [pub].[RptCrossTab]
	@RowFieldName	VarChar(50),
	@ColFieldName	VarChar(50),
	@SumFieldName	VarChar(50),
	@TableName		VarChar(50),
	@RowFieldText	VarChar(50) = '',
	@ColFieldText	VarChar(50) = '',
	@FilterText		NVarChar(2000) = ''
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(4000);
DECLARE @StrFrom	NVarChar(1000);
DECLARE @StrWhere	NVarChar(2000);
Begin 
	SET NOCOUNT ON;

	-- init ----------------------------------------------------------------------------------------
	if (@FilterText is null)
		set @FilterText = '';

	if (@FilterText = '')
		set @FilterText = '(1=1)';
	------------------------------------------------------------------------------------------------
	-- select --------------------------------------------------------------------------------------
	set @StrSelect	= 
	' SELECT ' + @RowFieldName + ' as RowField, ' + @ColFieldName + ' ColFiled, ' + @SumFieldName + ' as SumFiled ' +
	' FROM ' + @TableName + 
	' WHERE ' + @FilterText
	------------------------------------------------------------------------------------------------
	-- run -----------------------------------------------------------------------------------------
	print @StrSelect;
	exec sp_executesql @StrSelect;
	------------------------------------------------------------------------------------------------
End
GO
