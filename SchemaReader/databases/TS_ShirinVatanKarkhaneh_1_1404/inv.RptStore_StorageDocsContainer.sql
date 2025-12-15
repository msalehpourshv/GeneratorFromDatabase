USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari
-- Create date   : 1402/01/20
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.RptStore_StorageDocsContainer
	@GoodsID			Varchar(20)		= Null,
	@StoreID				Varchar(20)		= Null,
	@ContainerID		Varchar(20)		= Null,
	@ContainerID2		Varchar(20)		= Null,
	@ExtraParams		NVarChar(200)	= Null
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
	IF (@ContainerID Is Not Null And @ContainerID <> '')
		Set @StrWhere = @StrWhere + ' And a.ContainerID >= ''' + LTrim(RTrim(@ContainerID)) + ''''
		
	IF (@ContainerID2 Is Not Null And @ContainerID2 <> '')
		Set @StrWhere = @StrWhere + ' And a.ContainerID <= ''' + LTrim(RTrim(@ContainerID2)) + ''''		
	

	IF (@GoodsID Is Not Null And @GoodsID <> '')
		Set @StrWhere = @StrWhere + ' And b.GoodsID = ''' + @GoodsID + ''''
	IF (@StoreID Is Not Null And @StoreID <> '')
		Set @StrWhere = @StrWhere + ' And a.StoreID = ''' + @StoreID + ''''


	-- S E L E C T ------------------------------------------------------------
 
		Set @StrSelect = '
			select Sum(NumberPerContainer*a.EnterKind) ContainerCount, ContainerID, GoodsID, a.StoreID, 
				   inv.funGetContainerStoresName(a.ContainerStoresID,1) ContainerStoresName , a.ContainerStoresID
			from inv.tblStorageDocsSerials a 
			inner join inv.tblStorageDocsDtl  b
					on  a.ProcessID=b.ProcessID
					AND  a.ProcessNo=b.ProcessNo
					AND a.FiscalYear=b.FiscalYear
					AND a.SerialNo=b.SerialNo
					AND a.DocRowNo=b.DocRowNo
			WHERE 1 = 1 ' + @StrWhere + '
			group by ContainerID , GoodsID, a.StoreID, a.ContainerStoresID
			HAVING Sum(NumberPerContainer*a.EnterKind)  <> 0 '
	 
	-- Run -----------------------------------------------------
	Print @StrSelect;
	Exec sp_executesql @StrSelect;
	------------------------------------------------------------
END
GO
