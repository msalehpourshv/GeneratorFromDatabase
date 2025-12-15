USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NotOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 90/12/02
-- Viewed By	 : 
-- Last Modified : 93/07/26
-- Description   : 
-- =============================================			   
CREATE PROCEDURE [sal].[spFrmDistributionHdrListSelect]
	@ProcessID		Smallint,
	@DocDate		Char(10),
	@StoreID		NvarChar(20),
	@FilterInfo		NVarChar(100) = '@@0@0@@0@1'

WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

DECLARE @LanguageID AS TinyInt
DECLARE @FromDate		Char(10);
DECLARE @ToDate	    	Char(10);
DECLARE @FromSerialNo	Int;
DECLARE @ToSerialNo		Int;
DECLARE @UserID			NVarChar(4000);
DECLARE @UserIsAdmin	BIT;
DECLARE @RegVch	tinyint;
DECLARE @BranchManagerConfirmed	tinyint;
DECLARE @Confirmed	tinyint;
DECLARE @SaleRetsConfirmed	tinyint;


--================================
	Set @FromDate		=''
	Set @ToDate	    	=''
	Set @FromSerialNo	=0
	Set @ToSerialNo		=0
	
	-- Init -------------------------------------------------
	IF (@FilterInfo Is Null)	SET @FilterInfo ='@@@0@0@0@1@0@0@0'

	SET @FromDate		= pub.funSplitString(@FilterInfo, '@', 1);
	SET @ToDate			= pub.funSplitString(@FilterInfo, '@', 2);
	SET @FromSerialNo	= pub.funSplitString(@FilterInfo, '@', 3);
	SET @ToSerialNo		= pub.funSplitString(@FilterInfo, '@', 4);
	SET @UserID			= pub.funSplitString(@FilterInfo, '@', 5);
	SET @UserIsAdmin	= pub.funSplitString(@FilterInfo, '@', 6);
	SET @RegVch	= pub.funSplitString(@FilterInfo, '@', 7);
	SET @BranchManagerConfirmed	= pub.funSplitString(@FilterInfo, '@', 8);
	SET @Confirmed	= pub.funSplitString(@FilterInfo, '@', 9);
	SET @SaleRetsConfirmed	= pub.funSplitString(@FilterInfo, '@', 10);
	
	SET @LanguageID = pub.funGetCurrentLanguageID()


	--=====================================
	--=====================================
	
	SELECT Distinct  ProcessID,SerialNo,DocDate,SessionNo5 as RegVch,Confirmed,SaleRetsConfirmed,BranchManagerConfirmed
	FROM [sal].[tblDistributionsHdr]
	WHERE ProcessID= @ProcessID AND
		(@FromDate ='' OR (@FromDate <> '' AND DocDate >= @FromDate )) AND
		(@ToDate ='' OR (@ToDate <> '' AND DocDate <= @ToDate )) AND
		(@FromSerialNo =0 OR (@FromSerialNo <> 0 AND SerialNo >= @FromSerialNo )) AND
		(@ToSerialNo =0 OR (@ToSerialNo <> 0 AND SerialNo  <= @ToSerialNo )) AND
		((@UserIsAdmin = 1 AND (@StoreID ='' OR (@StoreID <> '' AND StoreID =  @StoreID  ))) OR
		(@UserIsAdmin = 0 AND [inv].[funStorePermitted](@UserID,StoreID)=1 AND (@StoreID ='' OR (@StoreID <> '' AND StoreID =  @StoreID  ))) ) AND
		(@Confirmed = 1 OR ( @Confirmed = 2 AND  Confirmed= 'True') OR ( @Confirmed = 3 AND  Confirmed= 'False')) AND
		((@BranchManagerConfirmed=1 ) OR ( @BranchManagerConfirmed=2 AND BranchManagerConfirmed= 'True') OR ( @BranchManagerConfirmed=3 AND BranchManagerConfirmed= 'False')) AND
		( (@SaleRetsConfirmed= 1) OR ( @SaleRetsConfirmed= 2 AND SaleRetsConfirmed= 'True') OR ( @SaleRetsConfirmed= 3 AND SaleRetsConfirmed= 'False')) AND
		((@RegVch=1) OR (@RegVch=2 AND SessionNo5>0 ) OR (@RegVch=3 AND SessionNo5=0 ))
END
GO
