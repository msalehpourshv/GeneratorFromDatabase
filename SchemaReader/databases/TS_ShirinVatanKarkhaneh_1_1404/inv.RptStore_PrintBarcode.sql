USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1387/01/21
-- Viewed By	 : 
-- Last Modified : 1392/07/11
-- Last Modifier : TakroSystem\Zia
-- Description   : لیست قیمت فروش کالاها
-- ==============================================
Create PROCEDURE [inv].[RptStore_PrintBarcode]
	@ProcessID		int=50,
	@ProcessNo		int=1,
	@FiscalYear		int=95,
	@SerialNo		int=1,
	@SortFields		NVarChar(100) = Null,
	@ExtraParams	NVarChar(400) = '',
	@RepInfo		NVarChar(100) = '1@1@1'

WITH ENCRYPTION
AS 
---- Declarations ---------------
DECLARE @StrSelect		NVarChar(4000);
DECLARE @StrWhere		NVarChar(4000);
DECLARE @StrFrom		NVarChar(4000);
DECLARE @FldGoodsID		VarChar(20);
DECLARE @FldGoodsName	NVarChar(100);
DECLARE @BatchNo		VarChar(20);

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@ReportID		Int;
DECLARE	@QtyInRow		Int;
DECLARE	@ExtraQty		Int;
DECLARE	@PrintOne		Int;
DECLARE	@price			NVarChar(500);
DECLARE @StoreID		VarChar(20) ;
DECLARE @DocDate		VarChar(10) ;
Declare @SaleTypeID		VarChar(20) ;
DECLARE @UnitPart		TINYINT

DECLARE @SelectedGoods	Int;

DECLARE @ByMainUnit	Bit;
DECLARE @Tolerance  Bit; 

BEGIN --============== S T A R T  C O D E ===================================================
	
	SET @SelectedGoods = 0
	SET	@QtyInRow	=0
	SET @UnitPart  = 1

	SET @StrWhere = '1 = 1'
	
	--==============
	SELECT @UnitPart = SettingValue from pub.tblSettings where SettingKey = 'UnitPart'

	IF @UnitPart IS NULL or @UnitPart = 0
		SET @UnitPart = 1

	DECLARE @str_Goods  tinyint,
			@str_GoodsSum tinyint

	select @str_Goods = ISNULL(SUM (Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9),0)
	from pub.tblCodeLayer 
	where TableName='inv.tblGoods' AND PartNumber<@UnitPart

	select @str_GoodsSum = Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9
	from pub.tblCodeLayer 
	where TableName= 'inv.tblGoods' AND PartNumber=@UnitPart

	SET NOCOUNT ON;
	 
	if @ExtraParams <> ''
	begin 
		SET @SaleTypeID		= LTrim(pub.funSplitString(@ExtraParams, '@', 1));
		SET @StoreID		= LTrim(pub.funSplitString(@ExtraParams, '@', 2));
		SET @DocDate		= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
		SET @SelectedGoods	= LTrim(pub.funSplitString(@ExtraParams, '@', 4));
		SET @ByMainUnit		= LTrim(pub.funSplitString(@ExtraParams, '@', 5));
		SET @QtyInRow		= LTrim(pub.funSplitString(@ExtraParams, '@', 6));
	end 
		print 	@QtyInRow	
		set @PrintOne	= LTrim(pub.funSplitString(@ExtraParams, '@', 11));
		set @Tolerance	= LTrim(pub.funSplitString(@ExtraParams, '@', 12));
		SET @ExtraQty	= LTrim(pub.funSplitString(@ExtraParams, '@', 13));

	--print '@ExtraParams=' + @ExtraParams
	--print '@SaleTypeID='+ @SaleTypeID
	--print '@StoreID='+ @StoreID
	--print '@DocDate='+ @DocDate
	
	set @ExtraQty = isnull(@ExtraQty,0)
 
	-- Init Variables ---------------------------
	IF (@RepInfo Is Null)		SET @RepInfo = '1@1@1';

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);

BEGIN TRY
		DROP TABLE #tblGoods
		END TRY
		BEGIN CATCH
		END CATCH

CREATE TABLE #tblGoods
	(
		GoodsID			VarChar(20)   COLLATE ARABIC_CS_AS,
		GoodsName		NVarChar(120)  COLLATE ARABIC_CS_AS,
		BarCode			VarChar(20) COLLATE ARABIC_CS_AS,
		DocRowNo		int,
		SalePrice		float,
		GoodsQuantity	float,
		BatchNo			VarChar(20)   COLLATE ARABIC_CS_AS,
		AcntCode			VarChar(20)   COLLATE ARABIC_CS_AS,
		AcntName		NVarChar(120)  COLLATE ARABIC_CS_AS,
		UserGoodsAmount float,
		ProdPrice float,
		UserPrice float,
		MinSalePrice float
	)
	
DECLARE @GID			NVarChar(20) ;
DECLARE @GName			NVarChar(1000) ;
DECLARE @DocRowNo		int;
DECLARE @Qty			float ;
DECLARE @Qty2			float ;
DECLARE @UsrGodsAmnt	float ;
DECLARE @ProdPrice		float ;
DECLARE @UserPrice		float ;
DECLARE @MinSalePrice	float ;
DECLARE @AcntCode		NVarChar(20) ;
DECLARE @AcntName		NVarChar(1000) ;

if @ProcessID=1
begin

--print 'State  csr2  '

DECLARE csr2 CURSOR FOR 
 
SELECT GoodsID, CEILING(Case When @ByMainUnit = 1 Then ISNULL(SUM(GoodsQuantity * EnterKind), 0) Else ISNULL(SUM(SubUnitQuantity * EnterKind), 0) End / @QtyInRow ) AS GoodsQuantity
, [pub].[funGetGoodsName](GoodsID, @LangID) GoodsName, 0,Case When @ByMainUnit = 1 Then ISNULL(SUM(GoodsQuantity * EnterKind), 0) Else ISNULL(SUM(SubUnitQuantity * EnterKind), 0) End 
,BatchNo,AcntCode, pub.GetCodeName(AcntCode, 1) AS AcntName,UserGoodsAmount,0 ProdPrice,0 UserPrice,0 MinSalePrice
FROM   inv.tblStorageDocsDtl  
WHERE (DocDate <= @DocDate) AND (StoreID = @StoreID)
GROUP BY GoodsID, StoreID,BatchNo,AcntCode,UserGoodsAmount
 
	OPEN csr2
	FETCH NEXT FROM csr2 INTO @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice

	WHILE @@Fetch_Status = 0
	BEGIN
		while @Qty+@ExtraQty>0
			BEGIN
			insert into #tblGoods(GoodsID,GoodsName,BarCode,SalePrice,DocRowNo,GoodsQuantity,BatchNo,AcntCode,AcntName,UserGoodsAmount,ProdPrice,UserPrice,MinSalePrice)
			select @GID,@GName,'',0,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
		
			Set @Qty=@Qty-1
			
			END

		FETCH NEXT FROM csr2 INTO  @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
	END

	CLOSE csr2
	DEALLOCATE csr2

end 
else if @ProcessID=170
begin

 --print 'State  csr1   '
	--SET @ByMainUnit = 0
DECLARE csr3 CURSOR FOR 

SELECT D.GoodsID, case when @PrintOne=1 then 1 else 
CEILING(Case When @ByMainUnit = 1 Then D.GoodsQuantity Else D.SubUnitQuantity End / @QtyInRow) end AS GoodsQuantity, [pub].[funGetGoodsName](D.GoodsID, @LangID) GoodsName, DocRowNo,Case When @ByMainUnit = 1 Then D.GoodsQuantity Else D.SubUnitQuantity End
,BatchNo,AcntCode, pub.GetCodeName(AcntCode, 1) AS AcntName, 0 UserGoodsAmount,0 ProdPrice,0 UserPrice,0 MinSalePrice
	FROM inv.tblInvTempReceiptDtl D
		WHERE ConfirmQuantity>0 and Recognition NOT IN (0, 4)  and DocStep=2
			and (D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear = @FiscalYear) AND (D.SerialNo = @SerialNo)
 
	OPEN csr3
	FETCH NEXT FROM csr3 INTO @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice

	WHILE @@Fetch_Status = 0
	BEGIN
		while @Qty+@ExtraQty>0
			BEGIN
			insert into #tblGoods(GoodsID,GoodsName,BarCode,SalePrice,DocRowNo,GoodsQuantity,BatchNo,AcntCode,AcntName,UserGoodsAmount,ProdPrice,UserPrice,MinSalePrice)
			select @GID,@GName,'',0,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
		
			Set @Qty=@Qty-1
			
			END

		FETCH NEXT FROM csr3 INTO  @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
	END

	CLOSE csr3
	DEALLOCATE csr3
end 
else if @ProcessID=180
begin

 --print 'State  csr1   '
	--SET @ByMainUnit = 0
DECLARE csr180 CURSOR FOR 

SELECT D.GoodsID, case when @PrintOne=1 then 1 else 
CEILING(Case When @ByMainUnit = 1 Then D.GoodsQuantity Else D.SubUnitQuantity End / @QtyInRow) end AS GoodsQuantity, [pub].[funGetGoodsName](D.GoodsID, @LangID) GoodsName, D.DocRowNo,Case When @ByMainUnit = 1 Then D.GoodsQuantity Else D.SubUnitQuantity End
,BatchNo,AcntCode, pub.GetCodeName(AcntCode, 1) AS AcntName, 0 UserGoodsAmount,P.ProdPrice,P.UserPrice,P.MinSalePrice
	FROM  sal.tblSaleOrderDtl D
	left join sal.tblGoodsPricesDtl P on D.GoodsID=P.GoodsID and   D.SaleTypeID=P.SaleTypeID 
		WHERE (D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear = @FiscalYear) AND (D.SerialNo = @SerialNo)
 
	OPEN csr180
	FETCH NEXT FROM csr180 INTO @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice

	WHILE @@Fetch_Status = 0
	BEGIN
		while @Qty+@ExtraQty>0
			BEGIN
			insert into #tblGoods(GoodsID,GoodsName,BarCode,SalePrice,DocRowNo,GoodsQuantity,BatchNo,AcntCode,AcntName,UserGoodsAmount,ProdPrice,UserPrice,MinSalePrice)
			select @GID,@GName,'',0,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
		
			Set @Qty=@Qty-1
			
			END

		FETCH NEXT FROM csr180 INTO  @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
	END

	CLOSE csr180
	DEALLOCATE csr180
end 

else if @ProcessID=600
begin

	SELECT D.ProductID GoodsID, case when @PrintOne=1 then 1 else 
		CEILING(ProductCount / @QtyInRow) end GoodsQuantity
		, [pub].[funGetGoodsName](ProductID, @LangID) GoodsName, DocRowNo,ProductCount 
		,BatchNo,'' AcntCode, '' AcntName
	into #TblTemp600
	FROM  pln.tblProduceOrderDtl D
	WHERE 1=0


	if @Tolerance='True'
		insert into #TblTemp600
		select Distinct p.ProductID GoodsID, case when @PrintOne=1 then 1 else CEILING( abs(p.ProductCount - d.GoodsQuantity) / @QtyInRow)  end  GoodsQuantity
			, [pub].[funGetGoodsName](p.ProductID, @LangID) GoodsName, p.DocRowNo,abs(p.ProductCount - d.GoodsQuantity) ,p.BatchNo,'' AcntCode, '' AcntName
			,0 UserGoodsAmount,0 ProdPrice,0 UserPrice,0 MinSalePrice
		from inv.tblStorageDocsDtl d
		inner join pln.tblTaskOrderHdr t on d.BaseProcessID=t.ProcessID and  d.BaseProcessNo=t.ProcessNo and  d.BaseFiscalYear=t.FiscalYear and  d.BaseSerialNo=t.SerialNo
		inner join pln.tblProduceOrderDtl p on t.BaseProcessID=p.ProcessID and t.BaseProcessNo=p.ProcessNo and t.BaseFiscalYear=p.FiscalYear and t.BaseSerialNo=p.SerialNo 
			and t.BaseDocRowNo=p.DocRowNo and t.ProductID=p.ProductID	
		where d.ProcessID=72 and p.ProcessID=@ProcessID	and p.ProcessNo=@ProcessNo	and p.FiscalYear=@FiscalYear	and p.SerialNo=@SerialNo
	else
		insert into #TblTemp600
		SELECT D.ProductID GoodsID, case when @PrintOne=1 then 1 else CEILING(D.ProductCount / @QtyInRow)  end  GoodsQuantity
			, [pub].[funGetGoodsName](D.ProductID, @LangID) GoodsName, DocRowNo,D.ProductCount ,BatchNo,'' AcntCode, '' AcntName
			,0 UserGoodsAmount,0 ProdPrice,0 UserPrice,0 MinSalePrice
		FROM  pln.tblProduceOrderDtl D
		WHERE (D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear = @FiscalYear) AND (D.SerialNo = @SerialNo)
 
 	DECLARE csr4 CURSOR FOR 
		select * from #TblTemp600
	OPEN csr4
	FETCH NEXT FROM csr4 INTO @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice

	WHILE @@Fetch_Status = 0
	BEGIN
		while @Qty+@ExtraQty>0
			BEGIN
			insert into #tblGoods(GoodsID,GoodsName,BarCode,SalePrice,DocRowNo,GoodsQuantity,BatchNo,AcntCode,AcntName,UserGoodsAmount,ProdPrice,UserPrice,MinSalePrice)
			select @GID,@GName,'',0,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
		
			Set @Qty=@Qty-1
			
			END

		FETCH NEXT FROM csr4 INTO  @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
	END

	CLOSE csr4
	DEALLOCATE csr4
end 
else
begin
  --print 'State  csr1   '
	--SET @ByMainUnit = 0
DECLARE csr1 CURSOR FOR 

SELECT D.GoodsID, case when @PrintOne=1 then 1 else 
CEILING(Case When @ByMainUnit = 1 Then D.GoodsQuantity Else D.SubUnitQuantity End / @QtyInRow) end AS GoodsQuantity, [pub].[funGetGoodsName](D.GoodsID, @LangID) GoodsName, D.DocRowNo,Case When @ByMainUnit = 1 Then D.GoodsQuantity Else D.SubUnitQuantity End
,BatchNo,AcntCode, pub.GetCodeName(AcntCode, 1) AS AcntName,UserGoodsAmount,ProdPrice,P.UserPrice,P.MinSalePrice
FROM   inv.tblStorageDocsDtl AS D          
left join sal.tblGoodsPricesDtl P on D.GoodsID=P.GoodsID and   D.SaleTypeID=P.SaleTypeID            
WHERE (D.ProcessID = @ProcessID) AND (D.ProcessNo = @ProcessNo) AND (D.FiscalYear = @FiscalYear) AND (D.SerialNo = @SerialNo)
 
	OPEN csr1
	FETCH NEXT FROM csr1 INTO @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice

	WHILE @@Fetch_Status = 0
	BEGIN
		while @Qty+@ExtraQty>0
			BEGIN
			insert into #tblGoods(GoodsID,GoodsName,BarCode,SalePrice,DocRowNo,GoodsQuantity,BatchNo,AcntCode,AcntName,UserGoodsAmount,ProdPrice,UserPrice,MinSalePrice)
			select @GID,@GName,'',0,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
		
			Set @Qty=@Qty-1
			
			END

		FETCH NEXT FROM csr1 INTO  @GID, @Qty,@GName,@DocRowNo,@Qty2,@BatchNo,@AcntCode,@AcntName,@UsrGodsAmnt,@ProdPrice,@UserPrice,@MinSalePrice
	END

	CLOSE csr1
	DEALLOCATE csr1

end

set @SaleTypeID = LTRIM(Rtrim( @SaleTypeID ))

update #tblGoods
set BarCode = IsNull([inv].[FunGetGoodsBarCode] (G.GoodsID), '')
	From #tblGoods G  INNER JOIN inv.tblGoods D 
	ON D.GoodsID = G.GoodsID 
                      
update #tblGoods
set SalePrice =  H.SalePrice 
From #tblGoods G  INNER JOIN sal.tblGoodsPricesDtl H 
ON H.GoodsID = G.GoodsID 
where LTRIM(Rtrim(  H.SaleTypeID))  =   LTRIM(Rtrim( @SaleTypeID ))

	--================== Where
	If (@SelectedGoods > 0)
	begin
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'T.GoodsID') 
	end	
	--select * into tblGoods  from  #tblGoods 
SET @StrSelect =' Select T.GoodsID, T.GoodsName, IsNull([inv].[FunGetGoodsBarCode] (T.GoodsID), '''') BarCode, T.DocRowNo, T.SalePrice,T.UserGoodsAmount,
                      T.ProdPrice,T.UserPrice,T.MinSalePrice, H.CodeClosed, H.UnitID, H.TechnicalSpecifications, H.TechnicalNo, H.MiscSpecifications, H.GoodsLength, H.GoodsWidth, H.GoodsHeight, 
                      H.GoodsWeight, H.MapNo, H.MasterCode, H.CheckBuyRequest, H.CheckBuyOrder, H.CheckQualityControl, H.RecID, H.SessionNo, H.GlobalCodingID, 
                      H.IranCodeID,H.FitPoint, H.SetPoint, H.BatchSize, H.HasSerial, H.UseFactor, 
					  H.ExtraField1, H.ExtraField2, H.ExtraField3, H.ExtraField4, H.ExtraField5, H.ExtraField6, H.ExtraField7, H.ExtraField8, H.ExtraField9, H.ExtraField10,
					  H.ExtraField11, H.ExtraField12, H.ExtraField13, H.ExtraField14, H.ExtraField15, H.ExtraField16, H.ExtraField17, H.ExtraField18, H.ExtraField19, H.ExtraField20,					  
                      H.CostCenterAcntCode, H.ProduceWithoutFormula, H.GoodsClassificationID, H.PrinterID, H.ShowInSaleMenu, H.GoodsPrice, H.SpecialCode, H.NationalCode, 
                      H.DrugKindID, H.CompanyID, H.MinSaleCeiling, H.MaxBuyCeiling, H.QtyInPerPacket,  H.BuyPrice, H.IsRation, H.RationQty, H.IsCombination, 
                      H.CombinationAmount, H.IsMammyDrug, H.IsSalePermit, H.IsComplementDrug, H.IsDecorDrug, H.IsNotInventoryCountDrug, H.IsNotTariffDrug, H.IsComrade, 
                      H.VisitorPercent, H.DoseID, H.SpecialAlarm, H.GenericCode, H.IsOTC, H.DrugSetID, H.UseExpireDate, H.GenericID, H.IsService, H.IsCombined, H.IsSendInfo, 
                      H.ContainTax, H.HasExpireDate, H.HasBatchNo, H.HasLentgh, H.SaleTypeID, H.DfStoreID, H.GoodsGroup, H.SubGroup, H.PublisherAcntCode, H.GoodsCount, 
                      H.GoodsType, H.PrintTurn, H.PrintYear, H.PageCount, H.BuyPricePercent, D.LanguageID, D.GoodsName2, D.GenericName, 
                      D.Author, D.Translator, D.GoodsLocation,
                      U.UnitName,U.UnitID,CASE WHEN  UDS.GoodsID IS NULL THEN U.UnitID ELSE UDS.SubUnitID END SubUnitID 
			         ,ISNULL(U2.UnitName,'''') SubUnitName,isnull(UDS.UnitValue,1) UnitValue ,isnull(UDS.MainUnitValue,1) MainUnitValue
					 ,T.GoodsQuantity,T.BatchNo,T.AcntCode,T.AcntName,BC.BarCodeImage,BC2.BarCodeImage  BatchImage,BC3.BarCodeImage ImageBarCode,QRCodeImage, I.GoodsImage
                 FROM inv.tblGoods  H 
                      INNER JOIN inv.tblGoodsDtl D  ON H.GoodsID = D.GoodsID AND H.PartNumber=D.PartNumber AND H.PartNumber=' + LTRIM(STR(@UnitPart)) + '
                      INNER JOIN  #tblGoods T   ON H.GoodsID = SUBSTRING(T.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ')  
					  LEFT  JOIN inv.tblGoodsImages I ON I.GoodsID =  SUBSTRING(T.GoodsID,' + LTrim(RTrim(@str_Goods)) + ' + 1, ' + LTrim(RTrim(@str_GoodsSum)) + ')
				      left  JOIN inv.tblSubUnitsDtl UDS ON H.GoodsID=UDS.GoodsID AND UDS.ShowInInvoice=1
		              left  join inv.tblUnitsDtl U2 on U2.UnitID = UDS.SubUnitID AND U2.LanguageID =  1
				      LEFT  JOIN inv.tblUnitsDtl U ON U.UnitID = H.UnitID AND U.LanguageID = 1
					  LEFT  JOIN rpt.tblBarCodeImage BC	ON BC.BarCode = T.GoodsID and BC.SessionNo='+ str(@SessionNo)+' and BC.ReportID='+ str(@ReportID)+' and BC.Type=1
					  LEFT  JOIN rpt.tblBarCodeImage BC2 ON BC2.BarCode = T.BatchNo and BC2.SessionNo='+ str(@SessionNo)+' and BC2.ReportID='+ str(@ReportID)+'  and BC2.Type=2
					  LEFT  JOIN rpt.tblBarCodeImage BC3 ON BC3.BarCode = T.BarCode and BC3.SessionNo='+ str(@SessionNo)+' and BC3.ReportID='+ str(@ReportID)+'  and BC3.Type=3
					  LEFT  JOIN rpt.tblQRCodeImage QR ON QR.QRCode = T.GoodsID and QR.SessionNo='+ str(@SessionNo)+' and QR.ReportID='+ str(@ReportID)+'  
				      Where ' + @StrWhere

If (@SortFields Is Not Null) AND (@SortFields <> '')
		SET @StrSelect = @StrSelect + '
		ORDER BY ' + @SortFields
	
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;

END
GO
