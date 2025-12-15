USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem/Hamid
-- Create date   : 393/08/15
-- Viewed By	 : 
-- Last Modified : 1393/09/10
-- Last Modifier : TakroSystem/Hamid
-- Description   : 
-- =============================================
Create PROCEDURE [inv].[RptStore_StorageDocsSerials_ForProcesses]
	@ProcessID		 Int = 90,  -- Default Is Sale
	@ProcessNo		 Int = 1,
	@FiscalYear		 Int = 93,
	@SerialNo		 Int = 1,
	@DocRowNo		 Int = 1,
	@FromExpDate	 Varchar(20) = Null,
	@ToExpDate		 Varchar(20) = Null,	
	@BatchNoFrom	 Varchar(20) = Null,
	@BatchNoTo		 Varchar(20) = Null,	
	@SerialNoFrom	 Varchar(20) = Null,
	@SerialNoTo		 Varchar(20) = Null			
WITH ENCRYPTION
AS 
DECLARE @LanguageID TinyInt;
DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrWhere	NVarChar(Max);
DECLARE @HasSerial  Bit;

DECLARE @Count		Int;

Begin --============== S T A R T  C O D E ===================================================

	SET @LanguageID = pub.funGetCurrentLanguageID();

	Set @StrSelect = ''
	Set @StrWhere = '1 = 1'

	Set NoCount On;

	-- I N I T ----------------------------------------------------------------
	IF (@LanguageID Is Null)	SET @LanguageID = 1

	-- W H E R E --------------------------------------------------------------
	--IF (@FromExpDate Is Not Null And @FromExpDate <> '')
	--	Set @StrWhere = @StrWhere + ' And SS.ExpireDate >= ''' + LTrim(RTrim(@FromExpDate)) + ''''
		
	--IF (@ToExpDate Is Not Null And @ToExpDate <> '')
	--	Set @StrWhere = @StrWhere + ' And SS.ExpireDate <= ''' + LTrim(RTrim(@ToExpDate)) + ''''	
		
	--IF (@BatchNoFrom Is Not Null And @BatchNoFrom <> '0')
	--	Set @StrWhere = @StrWhere + ' And Cast(SS.BatchNo as BigInt) >= ''' + LTrim(RTrim(@BatchNoFrom)) + ''''
		
	--IF (@BatchNoTo Is Not Null And @BatchNoTo <> '0')
	--	Set @StrWhere = @StrWhere + ' And Cast(SS.BatchNo as BigInt) <= ''' + LTrim(RTrim(@BatchNoTo)) + ''''	
		
	--IF (@SerialNoFrom Is Not Null And @SerialNoFrom <> '0')
	--	Set @StrWhere = @StrWhere + ' And SS.ProductSerialID >= ''' + LTrim(RTrim(@SerialNoFrom)) + ''''
		
	--IF (@SerialNoTo Is Not Null And @SerialNoTo <> '0')
	--	Set @StrWhere = @StrWhere + ' And SS.ProductSerialID <= ''' + LTrim(RTrim(@SerialNoTo)) + ''''					
		
	---- S E L E C T ------------------------------------------------------------
	--Set @StrSelect = '
	--Select SS.ProcessID, SS.ProcessNo, SS.FiscalYear, SS.SerialNo, P.ProductID As GoodsID ,SS.ProductSerialID, SS.BatchNo, 
	--	   SS.ExpireDate, [pub].[funChangeDate_PersianToGergorian](SS.ExpireDate) As GExpireDate 
	--From inv.tblStorageDocsSerials SS
	--INNER JOIN pln.tblProductSerials P ON P.ProductSerialID = SS.ProductSerialID
	--Where SS.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' And SS.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo))) + ' And 
	--	  SS.FiscalYear = ' + LTrim(RTrim(Str(@FiscalYear))) + ' And SS.SerialNo = ' + LTrim(RTrim(Str(@SerialNo))) + ' And 
	--	  SS.DocRowNo = ' + LTrim(RTrim(Str(@DocRowNo))) + ' And ' + @StrWhere
		  
	---- Run -----------------------------------------------------
	--Print @StrSelect;
	--Exec sp_executesql @StrSelect;
	--------------------------------------------------------------
	Select @Count = COUNT(*)
	From inv.tblStorageDocsSerials SS
	LEFT JOIN pln.tblProductSerials P ON P.ProductSerialID = SS.ProductSerialID
	Where SS.ProcessID = @ProcessID And SS.ProcessNo = @ProcessNo And 
		  SS.FiscalYear = @FiscalYear And SS.SerialNo = @SerialNo And 
		  SS.DocRowNo = @DocRowNo
		  	
	IF 	@Count > 0	
	BEGIN  	
		Select SS.ProcessID, SS.ProcessNo, SS.FiscalYear, SS.SerialNo, ISNULL(P.ProductID,'') As GoodsID, 
			   SS.ProductSerialID, SS.BatchNo, SS.ExpireDate,SS.DescRetSaleID,ISNULL(d.DescRetSaleName,'')  DescRetSaleName, 
			   ISNULL([pub].[funChangeDate_PersianToGergorian](SS.ExpireDate),'') As GExpireDate, 
			   ISNULL(P.SerialPrefix, '0') SerialPrefix, CAST( ISNULL(P.SerialNo, '')  as varchar(50)) ProductSerialNo,CAST('' as varchar(1000)) AllSerials
		into #AllSerials_ForProcesses 
		From inv.tblStorageDocsSerials SS
		LEFT JOIN pln.tblProductSerials P ON P.ProductSerialID = SS.ProductSerialID
		LEFT JOIN sal.tblDescRetSaleDtl d ON d.DescRetSaleID = SS.DescRetSaleID 
		Where SS.ProcessID = @ProcessID And SS.ProcessNo = @ProcessNo And 
			  SS.FiscalYear = @FiscalYear And SS.SerialNo = @SerialNo And 
			  SS.DocRowNo = @DocRowNo

		DECLARE @strSNSum varchar(1000)
		SET @strSNSum=''

		SELECT @strSNSum = COALESCE(@strSNSum + ' - ', ' ') + PSerialNo
		FROM   inv.tblStorageDocsSerials 
		WHERE ProcessID=@ProcessID 
			and ProcessNo=@ProcessNo 
			and FiscalYear=@FiscalYear 
			and SerialNo=@SerialNo 
			and DocRowNo=@DocRowNo 

		IF LEN(@strSNSum)> 0
			SEt @strSNSum = SUBSTRING(@strSNSum,4,LEN(@strSNSum))
			
		UPDATE #AllSerials_ForProcesses
		SET AllSerials=@strSNSum
		FROM #AllSerials_ForProcesses
	 
		SELECT * FROM #AllSerials_ForProcesses		
	END
	ELSE			  
		Select D.ProcessID, D.ProcessNo, D.FiscalYear, D.SerialNo, ISNULL(D.GoodsID,'') As GoodsID,
			   0 ProductSerialID, D.BatchNo, '' ExpireDate,'' DescRetSaleID,''  DescRetSaleName, '' GExpireDate, 
			   '0' SerialPrefix, CAST(  ''  as varchar(50))  ProductSerialNo,CAST('' as varchar(1000)) AllSerials
		From inv.tblStorageDocsDtl D
		Where D.ProcessID = @ProcessID And D.ProcessNo = @ProcessNo And 
			  D.FiscalYear = @FiscalYear And D.SerialNo = @SerialNo And 
			  D.DocRowNo = @DocRowNo
END
GO
