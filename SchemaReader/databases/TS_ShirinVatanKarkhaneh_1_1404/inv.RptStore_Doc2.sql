USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Create date   : 1387/01/06
-- Viewed By	 : 
-- Last Modified : 1393/09/05
-- Last Modifier : TakroSystem\Hamid
-- Description	 : برگ انبار
-- ==============================================
Create PROCEDURE [inv].[RptStore_Doc2]
	@ProcessID		Int = 55,
	@ProcessNo		Int = 1,
	@FiscalYear		Int = Null,
	@SerialNo		Int = Null,
	@FiscalYearTo	Int = Null,
	@SerialNoTo		Int = Null,
	@BaseProcessID	Int = 150,
	@BaseProcessNo	Int = Null,
	@BaseFiscalYear	Int = Null,
	@BaseSerialNo	Int = Null,
	@GoodsID		Varchar(20) = Null,
	@RepInfo		NVarChar(100) = '1@1@1'	
	--@ExtraParams	NVarChar(500) = ''
	
WITH ENCRYPTION
AS

DECLARE @StrSelect	NVarChar(Max);
DECLARE @StrSelect21	NVarChar(Max);
DECLARE @StrSelect22	NVarChar(Max) = '';
DECLARE @StrSelect3	NVarChar(Max);
DECLARE @StrWhere	NVarChar(4000);
DECLARE @StrWhere1	NVarChar(4000);
DECLARE @StrWhere2	NVarChar(4000);
DECLARE @StrWhere3	NVarChar(4000);
DECLARE @StrWhere4	NVarChar(4000);

DECLARE @LanguageID		TinyInt;
DECLARE @IsDistribute	bit;
DECLARE @IsSettle		bit;
DECLARE @IsMultiLng		bit;

DECLARE @db_0000		NVarchar(50)
SET @db_0000 = Substring(db_name(), 1, Len(db_name()) - 4) + '0000'
DECLARE @BaseDocRowNo	Int ;

Begin --============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	-- Init ------------------------------------------
	SET @LanguageID = pub.funGetCurrentLanguageID();
	SET @IsDistribute = 0;
	SET @IsMultiLng = 0;

	SET @BaseDocRowNo	= pub.funSplitString(@RepInfo, '@', 6);	
	set @BaseDocRowNo=isnull(@BaseDocRowNo,0)

	SELECT @IsMultiLng = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'IsMultiLanguage'
	
	--SET @IsMultiLng		  = LTrim(pub.funSplitString(@ExtraParams, '@', 1));	
	--SET @HasSerial		  = LTrim(pub.funSplitString(@ExtraParams, '@', 2));
	--SET @FromExpireDate	  = LTrim(pub.funSplitString(@ExtraParams, '@', 3));
	--SET @ToExpireDate       = LTrim(pub.funSplitString(@ExtraParams, '@', 4));
	--SET @Batch			  = LTrim(pub.funSplitString(@ExtraParams, '@', 5));	
	
	SELECT @IsDistribute = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'SalIsDistribution'

	SELECT @IsSettle = isnull(SettingValue, 0)
	FROM pub.tblSettings
	WHERE SettingKey = 'InvHasSettlementKind'
	
	IF (@ProcessNo Is Null)		SET @ProcessNo = 1;
	IF (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	IF (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	
	--===============================================
		--=======================
	CREATE TABLE #tbl_Invoice_Signatures
	(
		UserID   Int,
		UserSign Image
	);

	SET @StrSelect = '
	INSERT INTO #tbl_Invoice_Signatures(UserID, UserSign)
	SELECT UserID, UserSignature
	FROM ' + LTrim(RTrim(@db_0000)) + '.usr.tblUsers U '
		
	EXEC sp_executesql @StrSelect;		
	
	--=======================
	CREATE TABLE #tbl_Session1
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_Session2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_Session2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SessionNo2)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	EXEC sp_executesql @StrSelect;	
	
	--=======================
	CREATE TABLE #tbl_SgnSN1
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN1(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN1)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
	
	EXEC sp_executesql @StrSelect;
	
	--=======================
	CREATE TABLE #tbl_SgnSN2
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN2(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN2)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	EXEC sp_executesql @StrSelect;	

	--=======================
	CREATE TABLE #tbl_SgnSN3
	(
		SerialNo	Int,
		UserID		Int	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN3(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN3)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
			
	EXEC sp_executesql @StrSelect;		
		
	--=======================
	CREATE TABLE #tbl_SgnSN4
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN4(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN4)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	EXEC sp_executesql @StrSelect;	
	
	--=======================
	CREATE TABLE #tbl_SgnSN5
	(
		SerialNo	Int,
		UserID		Int
	);
		
	SET @StrSelect = '
	INSERT INTO #tbl_SgnSN5(SerialNo, UserID)
	SELECT H.SerialNo, ' + @db_0000 + '.[pub].[funGetUserID](H.SgnSN5)
	FROM inv.tblStorageDocsHdr H 
	Where ' + @StrWhere
		
	EXEC sp_executesql @StrSelect;					
	--------------------------------------------------
	
	-- Where ----------------------------------------
	SET @StrWhere = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID))) + ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	SET @StrWhere1 = 'H.ProcessID = ' + LTrim(RTrim(Str(@ProcessID)))
	---  به خاطر ثبت درخواست در ProcessNo 1 و خرید در ProcessNo 2
	if @BaseProcessID<>150 and @BaseProcessID<>160 and @BaseProcessID<>170 
		SET @StrWhere1  += ' AND H.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))

	SET @StrWhere2 = 'C.ProcessID = ' +  LTRIM(STR(@BaseProcessID)) + ' AND C.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	SET @StrWhere3 = 'C.ProcessID = ' +  LTRIM(STR(@BaseProcessID)) + ' AND C.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	SET @StrWhere4 = 'C.ProcessID = ' +  LTRIM(STR(@BaseProcessID)) + ' AND C.ProcessNo = ' + LTrim(RTrim(Str(@ProcessNo)))
	
	If (@GoodsID Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''')'	
		--SET @StrWhere1 = @StrWhere1 + ' AND (TmpReceipt.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''')'	
		SET @StrWhere2 = @StrWhere2 + ' AND (C.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''')'	
		SET @StrWhere3 = @StrWhere3 + ' AND (C.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''')'	
		SET @StrWhere4 = @StrWhere4 + ' AND (C.GoodsID = ''' + LTrim(RTrim(@GoodsID)) + ''')'	
	End
	
	IF (@FiscalYear Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
		--SET @StrWhere1 = @StrWhere1 + ' AND ((H.FiscalYear >' + LTrim(Str(@FiscalYear)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYear)) + ' AND H.SerialNo >= ' + LTrim(Str(@SerialNo)) + ')) '
	End
	IF (@FiscalYearTo Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
		--SET @StrWhere1 = @StrWhere1 + ' AND ((H.FiscalYear < ' + LTrim(Str(@FiscalYearTo)) + ') OR (H.FiscalYear = ' + LTrim(Str(@FiscalYearTo)) + ' AND H.SerialNo <= ' + LTrim(Str(@SerialNoTo)) + ')) '		
	End
		
	If (@BaseProcessID	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
		--SET @StrWhere1 = @StrWhere1 + ' AND (TmpReceipt.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (SS.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (T.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (O.BaseProcessID = ' + LTrim(RTrim(Str(@BaseProcessID))) + ')'
	End
		
	If (@BaseProcessNo	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
		--SET @StrWhere1 = @StrWhere1 + ' AND (TmpReceipt.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (SS.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (T.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (O.BaseProcessNo = ' + LTrim(RTrim(Str(@BaseProcessNo))) + ')'
	End
		
	If (@BaseFiscalYear	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
		--SET @StrWhere1 = @StrWhere1 + ' AND (TmpReceipt.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
		SET @StrWhere2 = @StrWhere2 + ' AND (SS.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
		SET @StrWhere3 = @StrWhere3 + ' AND (T.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
		SET @StrWhere4 = @StrWhere4 + ' AND (O.BaseFiscalYear = ' + LTrim(RTrim(Str(@BaseFiscalYear))) + ')'
	End
		
	If (@BaseSerialNo	Is Not Null)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	
		--SET @StrWhere1 = @StrWhere1 + ' AND (TmpReceipt.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	
		SET @StrWhere2 = @StrWhere2 + ' AND (SS.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	
		SET @StrWhere3 = @StrWhere3 + ' AND (T.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	
		SET @StrWhere4 = @StrWhere4 + ' AND (O.BaseSerialNo = ' + LTrim(RTrim(Str(@BaseSerialNo))) + ')'	
	End
		
	If (@BaseDocRowNo>0)
	Begin
		SET @StrWhere = @StrWhere + ' AND (D.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'	
		--SET @StrWhere1 = @StrWhere1 + ' AND (TmpReceipt.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'	
		SET @StrWhere2 = @StrWhere2 + ' AND (SS.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'	
		SET @StrWhere3 = @StrWhere3 + ' AND (T.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'	
		SET @StrWhere4 = @StrWhere4 + ' AND (O.BaseDocRowNo = ' + LTrim(RTrim(Str(@BaseDocRowNo))) + ')'	
	End
		

				
	-- SELECT Clause ----------------------------------------
	IF @ProcessID = 230
	SET @StrSelect = '
		SELECT H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, D.DocRowNo, H.DocDate, H.StoreID, S.StoreName, 
		       H.AcntCode, pub.GetCodeName(H.AcntCode, ' + Str(@LanguageID) + ') AS AcntName,
			   D.GoodsID, pub.funGetGoodsName(D.GoodsID,' + Str(@LanguageID) + ')GoodsName, D.SubUnitQuantity, D.SubUnitID, U.UnitName, D.DescDtl DocDesc,
			   pub.GetUserName(H.SessionNo) AS UserName
			   
		FROM inv.tblStoresRequestsHdr H
		Inner Join inv.tblStoresRequestsDtl D ON H.ProcessID = D.ProcessID And H.ProcessNo = D.ProcessNo And
												 H.FiscalYear = D.FiscalYear And H.SerialNo = D.SerialNo
		--INNER JOIN inv.tblGoodsDtl G ON G.GoodsID = D.GoodsID	                                     
		INNER JOIN inv.tblUnitsDtl U ON U.UnitID = D.SubUnitID
		LEFT  JOIN inv.tblStoresDtl S ON S.StoreID = D.StoreID AND S.LanguageID = ' + Str(@LanguageID) + '
		WHERE ' + @StrWhere + '
		ORDER BY DocRowNo'	
		
	ELSE
	SET @StrSelect = '
		SELECT	TmpReceipt.*, Cast(' + LTrim(RTrim(Str(@IsMultiLng))) + ' As Bit) As IsMultiLng, H.VchNo, H.VchNo2, H.ProductID, inv.funGetGoodsRemain(Null,Null,Null,Null,Null,Null,H.ProductID,Null,H.DocDate,0) As ProductRemain, 
				H.ProductCount, H.DocDesc, H.EarnestMoney, H.DocDate2,
				pub.GetCodeName(H.VisitorAcntCode, ' + LTrim(RTrim(Str(@LanguageID))) + ') AS VisitorAcntName, H.DriverID,
				H.TaxOverWorthCost, (H.Discount + H.Discount2+ H.Discount3) AS Discount, H.TaxCost,
				H.DiscountPercent, H.TollOverWorthCost, H.TotalLineDiscount, pub.funGetGoodsName(TmpReceipt.GoodsID,' + LTrim(RTrim(Str(@LanguageID))) + ') GoodsName, 
				GH.ExtraField1, GH.ExtraField2, GH.ExtraField3, GH.ExtraField4, GH.ExtraField5,
				pub.funGetGoodsName(H.ProductID, ' + LTrim(RTrim(Str(@LanguageID))) + ') As ProductName, H.OtherIncome, H.OtherCost,
				pub.funGetGoodsName(TmpReceipt.GoodsID2, ' + LTrim(RTrim(Str(@LanguageID))) + ') AS GoodsName2, STD.SaleTypeName,
				F.*, TmpReceipt.AtomAmount AS OverloadAmount, T.TransporterName, U.UnitName, W.UnitName UnitName2, H.PackingCost,
				S.StoreName, S2.StoreName AS StoreName2, Cast(''بسته بندي'' AS VarChar(100)) AS Packing,
				SH.StoreKeeperID, SK.StoreKeeperName, pub.funGetLocationName(F.LocationID,1) AS LocationName,
				H.TransportationCost, H.TransportationIncome, T2.TransporterName AS TransporterName2,
				pub.funGetLocationName(H.LocationID,1) AS LocationName2, IsNull(P.ProcessName, '''') AS ProcessName,
				AH1.Tel As HdrAcntTel,AH2.Tel As DtlAcntTel, H.CashAmount, H.ChequeAmount,
				pub.GetUserName(H.SessionNo) AS UserName, 
				pub.GetUserName(H.SessionNo) AS UserName1, 
				pub.GetUserName(H.SessionNo2) AS UserName2, 
				pub.GetUserName(H.SessionNo3) AS UserName3, 
				pub.GetUserName(H.SessionNo4) AS UserName4, 
				pub.GetUserName(H.SessionNo5) AS UserName5, Cast(' + LTrim(RTrim(Str(@IsDistribute))) + ' As Bit) AS IsDistribute, 
				AfterSaleDiscount, Cast(' + LTrim(RTrim(Str(@IsSettle))) + ' As Bit) AS HasSettlement, V.UnitValue, V.MainUnitValue,
				inv.funSubUnit2(TmpReceipt.GoodsID) UnitScale, X.UnitName MainUnitName,
				inv.funSubUnit2Name(TmpReceipt.GoodsID) UnitNameX,TransporterID2,
				GH.TechnicalSpecifications, GH.TechnicalNo,
				H.AgreeNo AS AgreeNoHdr, H.ComssionCostPrice, H.BasculePrice, H.LaborPrice, H.TransportPrice,
				 IsNull((Select Top 1 SS.ProductSerialID From inv.tblStorageDocsSerials SS 
				  Where SS.ProcessID = TmpReceipt.ProcessID And SS.ProcessNo = TmpReceipt.ProcessNo And 
						SS.FiscalYear = TmpReceipt.FiscalYear And SS.SerialNo = TmpReceipt.SerialNo And 
						SS.DocRowNo = TmpReceipt.DocRowNo),0) As ProductSerialID,		 
				 IsNull((Select Top 1 SS.BatchNo From inv.tblStorageDocsSerials SS 
				  Where SS.ProcessID = TmpReceipt.ProcessID And SS.ProcessNo = TmpReceipt.ProcessNo And 
						SS.FiscalYear = TmpReceipt.FiscalYear And SS.SerialNo = TmpReceipt.SerialNo And 
						SS.DocRowNo = TmpReceipt.DocRowNo),'''') As PrdBatchNo,
				 IsNull((Select Top 1 SS.ExpireDate From inv.tblStorageDocsSerials SS 
				  Where SS.ProcessID = TmpReceipt.ProcessID And SS.ProcessNo = TmpReceipt.ProcessNo And 
						SS.FiscalYear = TmpReceipt.FiscalYear And SS.SerialNo = TmpReceipt.SerialNo And 
						SS.DocRowNo = TmpReceipt.DocRowNo),'''') As PrdExpireDate,	
				IsNull((
					SELECT TOP 1 SettingValue
					FROM pub.tblSettings
					WHERE SettingKey = ''TitleSale' + LTrim(Str(@ProcessNo)) + '''), '''') AS SaleName,
				IsNull((
					SELECT TOP 1 SettingValue
					FROM pub.tblSettings
					WHERE SettingKey = ''TitleBuy' + LTrim(Str(@ProcessNo)) + '''), '''') AS BuyName,
					inv.UQ2(TmpReceipt.GoodsID,TmpReceipt.SubUnitID) SQ2, H.C1, H.C2, H.C3, H.C4, H.C5, H.C6,H.C7, H.C8, H.C9, H.C10, H.C11, H.C12,
					Case When H.SgnSN1=0 Then '''' Else pub.GetUserName(H.SgnSN1) End Signer1Name,
					Case When H.SgnSN2=0 Then '''' Else pub.GetUserName(H.SgnSN2) End Signer2Name,
					Case When H.SgnSN3=0 Then '''' Else pub.GetUserName(H.SgnSN3) end Signer3Name,
					Case When H.SgnSN4=0 Then '''' Else pub.GetUserName(H.SgnSN4) End Signer4Name,
					Case When H.SgnSN5=0 Then '''' Else pub.GetUserName(H.SgnSN5) End Signer5Name,
					S1.UserSign As UserSignature1,
					S8.UserSign As UserSignature2,
					S3.UserSign As Signature1,
					S4.UserSign As Signature2,
					S5.UserSign As Signature3,
					S6.UserSign As Signature4,
					S7.UserSign As Signature5 '
														
	PRINT @StrSelect;
	if  @BaseProcessID = 150 
	BEGIN
		SET @StrSelect21 = '
			From 
			(
				Select SS.* 
				From cmr.tblCMRDtl C
				Inner Join 
				(Select S1.* 					
				 From inv.tblStorageDocsDtl S1 
				 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = S1.ProcessID And SH.ProcessNo = S1.ProcessNo And SH.FiscalYear = S1.FiscalYear And 
												  SH.SerialNo = S1.SerialNo
				 Where S1.ProcessID = 55) SS ON SS.BaseProcessID = C.ProcessID And SS.BaseProcessNo = C.ProcessNo And SS.BaseFiscalYear = C.FiscalYear And 
											  SS.BaseSerialNo = C.SerialNo And SS.BaseDocRowNo = C.DocRowNo

				Where ' + @StrWhere2 + '
				Union
			
				--====	
				Select SS.* 
				From cmr.tblCMRDtl C
				Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And T.BaseFiscalYear = C.FiscalYear And 
							T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo

				 Inner Join 
				(Select S1.* 					
				 From inv.tblStorageDocsDtl S1 
				 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = S1.ProcessID And SH.ProcessNo = S1.ProcessNo And SH.FiscalYear = S1.FiscalYear And 
												  SH.SerialNo = S1.SerialNo
				 Where S1.ProcessID = 55) SS ON SS.BaseProcessID = T.ProcessID And SS.BaseProcessNo = T.ProcessNo And SS.BaseFiscalYear = T.FiscalYear And 
											  SS.BaseSerialNo = T.SerialNo And SS.BaseDocRowNo = T.DocRowNo

				Where ' + @StrWhere3 + '
				Union
				'
		SET @StrSelect22 =
				'			
				--====	
				Select SS.* 
				From cmr.tblCMRDtl C
				Left Join cmr.tblOrderDtl O ON O.BaseProcessID = C.ProcessID And O.BaseProcessNo = C.ProcessNo And O.BaseFiscalYear = C.FiscalYear And 
							O.BaseSerialNo = C.SerialNo And O.BaseDocRowNo = C.DocRowNo

				 Inner Join 
				(Select S1.* 					
				 From inv.tblStorageDocsDtl S1 
				 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = S1.ProcessID And SH.ProcessNo = S1.ProcessNo And SH.FiscalYear = S1.FiscalYear And 
												  SH.SerialNo = S1.SerialNo
				 Where S1.ProcessID = 55) SS ON SS.BaseProcessID = O.ProcessID And SS.BaseProcessNo = O.ProcessNo And SS.BaseFiscalYear = O.FiscalYear And 
											  SS.BaseSerialNo = O.SerialNo And SS.BaseDocRowNo = O.DocRowNo

				Where ' + @StrWhere4 + '
				Union
			
				--====
				Select SS.* 
				From cmr.tblCMRDtl C
				Left Join cmr.tblOrderDtl O ON O.BaseProcessID = C.ProcessID And O.BaseProcessNo = C.ProcessNo And O.BaseFiscalYear = C.FiscalYear And 
							O.BaseSerialNo = C.SerialNo And O.BaseDocRowNo = C.DocRowNo

				Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = O.ProcessID And T.BaseProcessNo = O.ProcessNo And T.BaseFiscalYear = O.FiscalYear And 
							T.BaseSerialNo = O.SerialNo And T.BaseDocRowNo = O.DocRowNo
						
				 Left Join 
				(Select S1.* 					
				 From inv.tblStorageDocsDtl S1 
				 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = S1.ProcessID And SH.ProcessNo = S1.ProcessNo And SH.FiscalYear = S1.FiscalYear And 
												  SH.SerialNo = S1.SerialNo
				 Where S1.ProcessID = 55) SS ON SS.BaseProcessID = T.ProcessID And SS.BaseProcessNo = T.ProcessNo And SS.BaseFiscalYear = T.FiscalYear And 
											  SS.BaseSerialNo = T.SerialNo And SS.BaseDocRowNo = T.DocRowNo
										  					
				Where ' + @StrWhere4 + ')TmpReceipt'
	END
	if  @BaseProcessID = 160 

		SET @StrSelect21 = '
			From 
			(
				Select SS.* 
				From cmr.tblOrderDtl C
				Inner Join 
				(Select S1.* 					
				 From inv.tblStorageDocsDtl S1 
				 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = S1.ProcessID And SH.ProcessNo = S1.ProcessNo And SH.FiscalYear = S1.FiscalYear And 
												  SH.SerialNo = S1.SerialNo
				 Where S1.ProcessID = 55) SS ON SS.BaseProcessID = C.ProcessID And SS.BaseProcessNo = C.ProcessNo And SS.BaseFiscalYear = C.FiscalYear And 
											  SS.BaseSerialNo = C.SerialNo And SS.BaseDocRowNo = C.DocRowNo

				Where ' + @StrWhere2 + '
				Union
			
				--====	
				Select SS.* 
				From cmr.tblOrderDtl C
				Inner Join inv.tblInvTempReceiptDtl T ON T.BaseProcessID = C.ProcessID And T.BaseProcessNo = C.ProcessNo And T.BaseFiscalYear = C.FiscalYear And 
							T.BaseSerialNo = C.SerialNo And T.BaseDocRowNo = C.DocRowNo

				 Inner Join 
				(Select S1.* 					
				 From inv.tblStorageDocsDtl S1 
				 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = S1.ProcessID And SH.ProcessNo = S1.ProcessNo And SH.FiscalYear = S1.FiscalYear And 
												  SH.SerialNo = S1.SerialNo
				 Where S1.ProcessID = 55) SS ON SS.BaseProcessID = T.ProcessID And SS.BaseProcessNo = T.ProcessNo And SS.BaseFiscalYear = T.FiscalYear And 
											  SS.BaseSerialNo = T.SerialNo And SS.BaseDocRowNo = T.DocRowNo

				Where ' + @StrWhere3 + '
			
			)TmpReceipt'
	if  @BaseProcessID = 170 

		SET @StrSelect21 = '
			From 
			(
				Select SS.* 
				From inv.tblInvTempReceiptDtl C
				Inner Join 
				(Select S1.* 					
				 From inv.tblStorageDocsDtl S1 
				 Inner Join inv.tblStorageDocsHdr SH ON SH.ProcessID = S1.ProcessID And SH.ProcessNo = S1.ProcessNo And SH.FiscalYear = S1.FiscalYear And 
												  SH.SerialNo = S1.SerialNo
				 Where S1.ProcessID = 55) SS ON SS.BaseProcessID = C.ProcessID And SS.BaseProcessNo = C.ProcessNo And SS.BaseFiscalYear = C.FiscalYear And 
											  SS.BaseSerialNo = C.SerialNo And SS.BaseDocRowNo = C.DocRowNo

				Where ' + @StrWhere2 + '
				
			
			)TmpReceipt'
	PRINT @StrSelect21;
	SET @StrSelect3 = '		
		INNER JOIN inv.tblStorageDocsHdr H ON H.ProcessID = TmpReceipt.ProcessID AND H.ProcessNo = TmpReceipt.ProcessNo AND 
											  H.FiscalYear = TmpReceipt.FiscalYear AND H.SerialNo = TmpReceipt.SerialNo
		LEFT JOIN sal.tblTransportersDtl T ON H.TransporterID = T.TransporterID AND T.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN sal.tblTransportersDtl T2 ON H.TransporterID2 = T2.TransporterID AND T.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN inv.tblUnitsDtl U ON U.UnitID = TmpReceipt.SubUnitID AND U.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN inv.tblSubUnitsDtl V ON V.GoodsID = TmpReceipt.GoodsID AND V.ShowInInvoice= ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN inv.tblStores SH ON SH.StoreID = TmpReceipt.StoreID
		LEFT JOIN inv.tblStoreKeepersDtl SK ON SH.StoreKeeperID = SK.StoreKeeperID AND SK.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN inv.tblGoodsDtl GD ON GD.GoodsID = TmpReceipt.GoodsID AND GD.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN inv.tblGoods	  GH ON GH.GoodsID = TmpReceipt.GoodsID 
		LEFT JOIN pub.tblProcess P ON P.ProcessID = TmpReceipt.ProcessID AND P.ProcessNo = TmpReceipt.ProcessNo
		LEFT JOIN inv.tblUnitsDtl W ON W.UnitID = V.SubUnitID	
		LEFT JOIN inv.tblUnitsDtl X ON X.UnitID = GH.UnitID	
		LEFT JOIN inv.tblStoresDtl S ON S.StoreID = TmpReceipt.StoreID AND S.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN inv.tblStoresDtl S2 ON S2.StoreID = TmpReceipt.StoreID2 AND S2.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		LEFT JOIN sal.tblSaleTypesDtl STD ON STD.SaleTypeID = TmpReceipt.SaleTypeID AND STD.LanguageID = ' + LTrim(RTrim(Str(@LanguageID))) + '
		OUTER APPLY acc.funGetCodeInfo(H.AcntCode) AS F
		LEFT JOIN acc.tblAcnt AH1 ON AH1.AcntCode = H.AcntCode
		LEFT JOIN acc.tblAcnt AH2 ON AH2.AcntCode = TmpReceipt.AcntCode	
		LEFT  JOIN #tbl_Invoice_Signatures S1 on S1.UserID = (SELECT UserID FROM #tbl_Session1 Where SerialNo = H.SerialNo)
		LEFT  JOIN #tbl_Invoice_Signatures S8 on S8.UserID = (SELECT UserID FROM #tbl_Session2 Where SerialNo = H.SerialNo)
		LEFT  JOIN #tbl_Invoice_Signatures S3 on S3.UserID = (SELECT UserID FROM #tbl_SgnSN1 Where SerialNo = H.SerialNo)
		LEFT  JOIN #tbl_Invoice_Signatures S4 on S4.UserID = (SELECT UserID FROM #tbl_SgnSN2 Where SerialNo = H.SerialNo)
		LEFT  JOIN #tbl_Invoice_Signatures S5 on S5.UserID = (SELECT UserID FROM #tbl_SgnSN3 Where SerialNo = H.SerialNo)
		LEFT  JOIN #tbl_Invoice_Signatures S6 on S6.UserID = (SELECT UserID FROM #tbl_SgnSN4 Where SerialNo = H.SerialNo)
		LEFT  JOIN #tbl_Invoice_Signatures S7 on S7.UserID = (SELECT UserID FROM #tbl_SgnSN5 Where SerialNo = H.SerialNo)
					
		WHERE ' + @StrWhere1 + '
		ORDER BY DocRowNo'
		
	PRINT @StrSelect3;
	SET @StrSelect = @StrSelect + @StrSelect21 + @StrSelect22 + @StrSelect3
	
	--===================================
	EXEC sp_executesql @StrSelect;	
	--===================================
End
GO
