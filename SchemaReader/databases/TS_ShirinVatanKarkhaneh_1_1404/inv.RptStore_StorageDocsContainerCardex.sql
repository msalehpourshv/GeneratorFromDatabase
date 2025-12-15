USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/01/21
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.RptStore_StorageDocsContainerCardex	
	@ProcessID		int,
	@ProcessNo		int,
	@FiscalYear		int,
	@SerialNo		int,
	@DocRowNo		int,
	@ExtraParams	NVarChar(200)	= Null
WITH ENCRYPTION
AS 
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);

DECLARE	@LangID				Char(1);
DECLARE	@SessionNo			Int; 
DECLARE	@ReportID			Int;
DECLARE	@UserID				Int;
DECLARE	@UserIsAdmin		Bit;

BEGIN --============== S T A R T  C O D E ===================================================

	Set @StrSelect = ''
	Set @StrWhere = ' '
	Set NoCount On;

	-- W H E R E --------------------------------------------------------------
		Set @StrWhere = @StrWhere + ' AND SS.ProcessID = ''' + LTrim(RTrim(str(@ProcessID))) + ''''
		Set @StrWhere = @StrWhere + ' AND SS.ProcessNo = ''' + LTrim(RTrim(str(@ProcessNo))) + ''''
		Set @StrWhere = @StrWhere + ' AND SS.FiscalYear = ''' + LTrim(RTrim(str(@FiscalYear))) + ''''
		Set @StrWhere = @StrWhere + ' AND SS.SerialNo = ''' + LTrim(RTrim(str(@SerialNo))) + ''''
		Set @StrWhere = @StrWhere + ' AND SS.DocRowNo = ''' + LTrim(RTrim(str(@DocRowNo))) + ''''

	-- S E L E C T ------------------------------------------------------------
 
		Set @StrSelect = '
			SELECT	(NumberPerContainer * SS.EnterKind) ContainerCount, 
					SS.ContainerID, 
					SS.ContainerStoresID,
					inv.funGetContainerStoresName(SS.ContainerStoresID,1) ContainerStoresName,
					SS.ExpireDate, 
					ISNULL([pub].[funChangeDate_PersianToGergorian](SS.ExpireDate),'''') As GExpireDate,
					SS.ProductionDate, 
					ISNULL([pub].[funChangeDate_PersianToGergorian](SS.ProductionDate),'''') As GProductionDate,
					B.BatchName,
					B.BatchNo,
					B.BatchExtraField1,
					B.BatchExtraField2,
					B.BatchExtraField3,
					B.BatchExtraField4
			FROM inv.tblStorageDocsSerials SS
			LEFT JOIN inv.tblBatchDtl B ON B.BatchNo = SS.BatchNo AND B.LanguageID = 1  
			WHERE 1 = 1 ' + @StrWhere + ' '
	 
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
