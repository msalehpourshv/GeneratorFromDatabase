USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Zia
-- Creation Date : 
-- Viewed By	 : 
-- Last Modified : 1390/10/07
-- Last Modifier : TakroSystem\Zia
-- Description   : موجودی اول دوره انبار
-- ==============================================


Create PROCEDURE [inv].[RptStore_Prim_Doc]
	@ProcessID		Int = 50, -- Store Primary Process ID
	@ProcessNo		Int = 1,
	@FiscalYear		Int,     -- Two digits
	@SerialNo		Int,
	@FiscalYearTo	Int,     -- Two digits
	@SerialNoTo		Int,
	@GoodsIDMask	NVarChar(1000) = Null
WITH ENCRYPTION
AS 
Declare @LanguageID TinyInt;
Begin --============== S T A R T  C O D E ===================================================

	SET NoCount On;

	-- I N I T ----------------------------------------------------------------
	If (@ProcessNo  Is Null)	SET @ProcessNo  = 1;
	If (@LanguageID Is Null)	SET @LanguageID = 1;
	If (@FiscalYearTo Is Null)	SET @FiscalYearTo = @FiscalYear;
	If (@SerialNoTo Is Null)	SET @SerialNoTo = @SerialNo;
	
	DECLARE @str_Goods  tinyint
    Declare @str_GoodsSum tinyint
    DECLARE @UnitPart TINYINT
	DECLARE @ShowContainerAndPos bit

	Set @ShowContainerAndPos = SubString(@GoodsIDMask,1,Len(@GoodsIDMask))
	Set	@GoodsIDMask = SubString(@GoodsIDMask,Len(@GoodsIDMask)-1,1)

	SET @UnitPart  = 1
    
    SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

    select @str_Goods = IsNull(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
    from pub.tblCodeLayer 
    where TableName='inv.tblGoods' AND PartNumber<@UnitPart

    IF @UnitPart IS NULL or @UnitPart = 0
    SET @UnitPart = 1

    select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
    from pub.tblCodeLayer 
    where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	-- S E L E C T ------------------------------------------------------------
	If (@GoodsIDMask Is Null)
		SELECT	H.FiscalYear, H.SerialNo, D.DocRowNo, 	D.GoodsID,
		    	D.GoodsQuantity,D.SubUnitQuantity, S.StoreName, 
				H.DocDesc, D.DocDate, 
				--G.GoodsName,
				 [pub].[funGetGoodsName](D.GoodsID,@LanguageID) GoodsName ,
				 D.BatchNo,[inv].[funGetBatchName](D.BatchNo,@LanguageID) BatchName,
				 U.UnitName, H.StoreID, D.GoodsPrice,D.SubUnitPrice,
				pub.GetUserName(H.SessionNo) AS UserName, 
				pub.GetUserName(H.SessionNo) AS UserName1,
				pub.GetUserName(H.SessionNo2) AS UserName2,
				pub.GetUserName(H.SessionNo3) AS UserName3,
				pub.GetUserName(H.SessionNo4) AS UserName4,
				pub.GetUserName(H.SessionNo5) AS UserName5,
				GH.TechnicalNo, GH.TechnicalSpecifications,	
				H.VchNo, D.SubUnitPrice2, D.SubUnitQuantity2, @ShowContainerAndPos ShowContainerAndPos
		FROM    [inv].[tblStorageDocsDtl] AS D
					INNER JOIN [inv].[tblStorageDocsHdr] H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					--LEFT  JOIN [inv].[tblGoods] GH ON GH.GoodsID = D.GoodsID 
					LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,@str_Goods+1,@str_GoodsSum) AND GH.PartNumber=@UnitPart
					--LEFT  JOIN [inv].[tblGoodsDtl] G ON G.GoodsID = D.GoodsID AND G.LanguageID = @LanguageID
					LEFT  JOIN [inv].[tblUnitsDtl] U ON U.UnitID = D.SubUnitID AND U.LanguageID = @LanguageID
					LEFT  JOIN [inv].[tblStoresDtl] S ON S.StoreID = H.StoreID AND S.LanguageID = @LanguageID
		WHERE   H.ProcessID = @ProcessID AND H.ProcessNo = @ProcessNo AND
				H.FiscalYear >= @FiscalYear AND H.SerialNo >= @SerialNo AND
				H.FiscalYear <= @FiscalYearTo AND H.SerialNo <= @SerialNoTo
	Else
		SELECT	H.FiscalYear, H.SerialNo, D.DocRowNo, 
		D.GoodsID, D.GoodsQuantity,D.SubUnitQuantity, S.StoreName, 
				H.DocDesc, D.DocDate,
				 [pub].[funGetGoodsName](D.GoodsID,@LanguageID) GoodsName , 
				 D.BatchNo,[inv].[funGetBatchName](D.BatchNo,@LanguageID) BatchName,
				--G.GoodsName,
				U.UnitName, H.StoreID, D.GoodsPrice,D.SubUnitPrice,
				pub.GetUserName(H.SessionNo) AS UserName,
				pub.GetUserName(H.SessionNo) AS UserName1,
				pub.GetUserName(H.SessionNo2) AS UserName2,
				pub.GetUserName(H.SessionNo3) AS UserName3,
				pub.GetUserName(H.SessionNo4) AS UserName4,
				pub.GetUserName(H.SessionNo5) AS UserName5,
				GH.TechnicalNo, GH.TechnicalSpecifications,	
				H.VchNo, D.SubUnitPrice2, D.SubUnitQuantity2, @ShowContainerAndPos ShowContainerAndPos
		FROM    [inv].[tblStorageDocsDtl] AS D
					INNER JOIN [inv].[tblStorageDocsHdr] H ON H.ProcessID = D.ProcessID AND H.ProcessNo = D.ProcessNo AND H.FiscalYear = D.FiscalYear AND H.SerialNo = D.SerialNo
					--LEFT  JOIN [inv].[tblGoods] GH ON GH.GoodsID = D.GoodsID 
					LEFT JOIN inv.tblGoods GH ON GH.GoodsID=SUBSTRING(D.GoodsID,@str_Goods+1,@str_GoodsSum) AND GH.PartNumber=@UnitPart
					--LEFT  JOIN [inv].[tblGoodsDtl] G ON G.GoodsID = D.GoodsID AND G.LanguageID = @LanguageID
					LEFT  JOIN [inv].[tblUnitsDtl] U ON U.UnitID = D.SubUnitID AND U.LanguageID = @LanguageID
					LEFT  JOIN [inv].[tblStoresDtl] S ON S.StoreID = H.StoreID AND S.LanguageID = @LanguageID
		WHERE   H.ProcessID = @ProcessID AND H.ProcessNo = @ProcessNo AND
				H.FiscalYear >= @FiscalYear AND H.SerialNo >= @SerialNo AND
				H.FiscalYear <= @FiscalYearTo AND H.SerialNo <= @SerialNoTo AND
				D.GoodsID LIKE RTrim(Replace(@GoodsIDMask, ' ', '_')) + '%'
End
GO
