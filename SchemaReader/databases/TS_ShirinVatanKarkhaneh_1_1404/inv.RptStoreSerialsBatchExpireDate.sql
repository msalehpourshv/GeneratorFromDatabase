USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Jafari	
-- Create date   : 1396/06/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : آخرین وضعیت بچهای دستور کار
-- ==============================================
CREATE PROCEDURE [inv].[RptStoreSerialsBatchExpireDate]
	@ExtraParams		NVarChar(Max) = '@@@@90',
	@RepOptions			VarChar(20) = '111' ,-- bit array	
	@RepInfo			NVarChar(100) = '1@1@1'
	
WITH ENCRYPTION
AS
---- Declarations ---------------
BEGIN
	DECLARE @StrSelect		NVarChar(max);
	DECLARE @StrWhere		NVarChar(max);

	DECLARE	@LangID			Char(1);
	DECLARE	@SessionNo		Int; 
	DECLARE	@ReportID		Int;

	DECLARE	@SerialPrefix NVarchar(20);
	DECLARE	@FromSerial   NVarchar(20);
	DECLARE	@ToSerial	  NVarchar(20);
	DECLARE	@ProductID	  NVarchar(20);
	DECLARE	@SelectedProcs	Varchar(100);

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	
	----------------------------------------------------
	SET @SerialPrefix	= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @FromSerial		= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
	SET @ToSerial		= LTrim(pub.funSplitString(@ExtraParams, '@', 3)); 
	SET @ProductID      = LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
	SET @SelectedProcs	= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 

	SET @StrWhere = '1 = 1'

	IF (@SerialPrefix <> '') And (@SerialPrefix Is Not Null)
		SET @StrWhere = @StrWhere + ' AND SerialPrefix = ''' + @SerialPrefix + ''''
		
	IF (@FromSerial <> '') And (@FromSerial Is Not Null)
		SET @StrWhere = @StrWhere + ' AND SerialNo >= ''' + @FromSerial + ''''

	IF (@ToSerial <> '') And (@ToSerial Is Not Null)
		SET @StrWhere = @StrWhere + ' AND SerialNo <= ''' + @ToSerial + ''''
	
	IF (@ProductID <> '') And (@ProductID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND ProductID = ''' + @ProductID + ''''			
 
	-- ============================================== 
	Set @StrSelect = '
	Select ProductSerialID
	From   pln.tblProductSerials
	Where  ' + @StrWhere
	
	-- ============================================== 
	Set @StrSelect = ' 
		  SELECT  Row_Number() Over(Order By PSerialNo) [ردیف], 
				   PSerialNo  [شماره سریال],
				   a.FiscalYear [سال مالی],
				   a.SerialNo   [ش.برگه],
				   a.DocDate		  [تاریخ],
				   a.StoreID		  [انبار],
				   P.ProcessName    [مراحل]
		  FROM (SELECT * 
				 from (
						Select SD.ProcessID,SD.ProcessNo,SD.FiscalYear,SD.SerialNo,SD.DocRowNo,SD.StoreID,SS.PSerialNo, SS.ProductSerialID ,SD.GoodsID,DocDate,VolumeRowNo,ROW_NUMBER()over(partition by SS.ProductSerialID order by SD.GoodsID,DocDate desc,VolumeRowNo desc) Row_Nu
						From inv.tblStorageDocsDtl SD
						INNER JOIN(SELECT * FROM  inv.tblStorageDocsSerials 
								   WHERE ProductSerialID IN (' + @StrSelect + ')) SS
						ON  SD.ProcessID=SS.ProcessID
						AND SD.ProcessNo=SS.ProcessNo
						AND SD.FiscalYear=SS.FiscalYear
						AND SD.SerialNo=SS.SerialNo
						AND SD.DocRowNo=SS.DocRowNo
					  ) a
				 where Row_Nu = 1) a 
		 LEFT Join pub.tblProcess P on P.ProcessID = a.ProcessID AND P.ProcessNo=a.ProcessNo
		 Where a.ProcessID IN (' + @SelectedProcs + ')'	


	Print @StrSelect
	Exec sp_executesql @StrSelect;
END
GO
