USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 1393/08/21 - Hamid
-- Description   : 
-- =============================================
--[inv].[spFrmStorageDocsByStepHdrListSelect] @ProcessID=90,@ProcessNo=1,@BaseProcessID=180,@DocDate='1393/07/29',@AcntCode=NULL,@StoreID='1',@DocStep=0,@SerialNo=NULL,@FiscalYear=NULL
Create PROCEDURE inv.spFrmStorageDocsByStepHdrListSelect
	@ProcessID		int,
	@ProcessNo		int,
	@BaseProcessID	int,
	@DocDate		Char(10),
	@AcntCode		varchar(20),
	@StoreID		varchar(20),
	@DocStep		Tinyint,
	@SerialNo       Int,
	@FiscalYear     SmallInt   ,
	@ExtraParams	NVarChar(Max) ,
	@OneStep		BIT
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

--======================================
DECLARE @BuyDocStep TinyInt
DECLARE @DocStepCondition AS Bit

SELECT @DocStepCondition=SettingValue
FROM   pub.tblSettings
WHERE SettingKey = 'DocStepConditionInBuyRet'

DECLARE @Buy_DontCheckDateConvertTempReceiptToBuy AS Bit

SELECT @Buy_DontCheckDateConvertTempReceiptToBuy=SettingValue
FROM   pub.tblSettings
WHERE SettingKey = 'Buy_DontCheckDateConvertTempReceiptToBuy'

IF @DocStepCondition = 'False' 
	SET @BuyDocStep = 1
ELSE
	SET @BuyDocStep = 2
	
-- ===============================================
Declare @pub_UserIsAdmin Bit;
SET @pub_UserIsAdmin = 0
 
		
-- ===============================================
Declare @pub_AccessAllCodesStore Bit;
SET @pub_AccessAllCodesStore = 0
 
--======================================
DECLARE @LanguageID AS TinyInt
SET @LanguageID = pub.funGetCurrentLanguageID()

declare @UserID float
declare @Var1 float
declare @Var2 float
declare @Var3 float
declare @Var4 float
declare @CT1 Nvarchar(100)
declare @CT2 Nvarchar(100)
declare @CT3 Nvarchar(100)
declare @CT4 Nvarchar(100)
Declare @ConfirmCount	int;
DECLARE @Sgn1			BIT;
DECLARE @Sgn2			BIT;
DECLARE @Sgn3			BIT;
DECLARE @Sgn4			BIT;
DECLARE @Sgn5			BIT;
DECLARE @Confirm		BIT;
Declare @TaskFiscalYear	int;
Declare @TaskSerialNo	int;

SET @Var1				= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
SET @Var2				= LTrim(pub.funSplitString(@ExtraParams, '@', 2)); 
SET @Var3				= LTrim(pub.funSplitString(@ExtraParams, '@', 3));
SET @Var4				= LTrim(pub.funSplitString(@ExtraParams, '@', 4)); 
SET @CT1				= LTrim(pub.funSplitString(@ExtraParams, '@', 5)); 
SET @CT2				= LTrim(pub.funSplitString(@ExtraParams, '@', 6)); 
SET @CT3				= LTrim(pub.funSplitString(@ExtraParams, '@', 7)); 
SET @CT4				= LTrim(pub.funSplitString(@ExtraParams, '@', 8)); 
SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 9);
SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 10);
SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 11);
SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 12);
SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 13);
SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 14);
SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 15);
SET @pub_UserIsAdmin	= pub.funSplitString(@ExtraParams, '@', 16);
SET @pub_AccessAllCodesStore	= pub.funSplitString(@ExtraParams, '@', 17);
SET @UserID				= pub.funSplitString(@ExtraParams, '@', 18);
SET @TaskFiscalYear		= pub.funSplitString(@ExtraParams, '@', 19);
SET @TaskSerialNo		= pub.funSplitString(@ExtraParams, '@', 20);

--select  @Var1 , @Var2, @Var3, @Var4, @CT1 , @CT2 , @CT3 , @CT4 

IF @DocDate =''
	BEGIN	 
	IF @ProcessID = 120
		SELECT Distinct H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate, H.StoreID, H.StoreID2, H.AcntCode, 
						[pub].[GetCodeName](H.AcntCode,@LanguageID) AcntName, H.VchNo, [pub].[GetStoreName](H.StoreID,@LanguageID) StoreName, 
						[pub].[GetStoreName](H.StoreID2,@LanguageID) StoreName2, DocDesc,'' DescDtl, SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5
		FROM inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H
		ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		WHERE H.ProcessID= @ProcessID AND (@ProcessNo = 0 OR H.ProcessNo= @ProcessNo )
		and (@AcntCode IS NULL OR H.AcntCode = @AcntCode )
		and (@StoreID IS NULL OR D.StoreID = @StoreID )
		and (@Var1 =0 OR D.Var1 = @Var1  )
		and (@Var2 =0 OR D.Var2 = @Var2  )
		and (@Var3 =0 OR D.Var3 = @Var3  )
		and (@Var4 =0 OR D.Var4 = @Var4  )
		and (@CT1 ='' OR D.ConstText1 like '%' + @CT1 + '%' )
		and (@CT2 ='' OR D.ConstText2 like '%' + @CT2 + '%' )
		and (@CT3 ='' OR D.ConstText3 like '%' + @CT3 + '%' )
		and (@CT4 ='' OR D.ConstText4 like '%' + @CT4 + '%' )
		and H.DocStep = @DocStep 
		and (@TaskSerialNo=0 or (D.TaskFiscalYear=@TaskFiscalYear and D.TaskSerialNo=@TaskSerialNo))
		and ([inv].[funAllowStores] (@UserID,@pub_UserIsAdmin,D.StoreID)='True'
			or [inv].[funAllowStores] (@UserID,@pub_UserIsAdmin,D.StoreID2)='True')
		 
	ELSE IF @ProcessID = 115
	BEGIN
		DECLARE @CostDate as VARCHAR(10)
		SET @CostDate = ''
		SELECT @CostDate = ISNULL(MAX(ToDate),'') from [inv].[tblStorageCosts]
		SELECT Distinct H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate, H.StoreID, H.StoreID2, H.AcntCode, 
						[pub].[GetCodeName](H.AcntCode,@LanguageID) AcntName, H.VchNo, [pub].[GetStoreName](H.StoreID,@LanguageID) StoreName, 
						[pub].[GetStoreName](H.StoreID2,@LanguageID) StoreName2, DocDesc, case WHEN @ProcessID=240 THEN DescDtl ELSE '' END DescDtl, SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5
		FROM inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H
		ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		WHERE H.ProcessID= @ProcessID AND H.ProcessNo= @ProcessNo AND  H.BaseDocType=0 AND H.VchNo=0 AND (H.DocDate>@CostDate OR @CostDate=''  )
		and (@AcntCode IS NULL OR H.AcntCode = @AcntCode ) 
		and (@StoreID IS NULL OR D.StoreID = @StoreID )
		and (@Var1 =0 OR D.Var1 = @Var1  )
		and (@Var2 =0 OR D.Var2 = @Var2  )
		and (@Var3 =0 OR D.Var3 = @Var3  )
		and (@Var4 =0 OR D.Var4 = @Var4  )
		and (@CT1 ='' OR D.ConstText1 like '%' + @CT1 + '%' )
		and (@CT2 ='' OR D.ConstText2 like '%' + @CT2 + '%' )
		and (@CT3 ='' OR D.ConstText3 like '%' + @CT3 + '%' )
		and (@CT4 ='' OR D.ConstText4 like '%' + @CT4 + '%' )
		and ((@DocStep = -1 OR H.DocStep=@DocStep) 
				or(	@ConfirmCount>0 AND H.DocStep = @DocStep+1
					AND ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
					and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
					and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
					and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
					and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				  )
				)
	END
	ELSE
		SELECT Distinct H.ProcessID, H.ProcessNo, H.FiscalYear, H.SerialNo, H.DocDate, H.StoreID, H.StoreID2, H.AcntCode, 
						[pub].[GetCodeName](H.AcntCode,@LanguageID) AcntName, H.VchNo, [pub].[GetStoreName](H.StoreID,@LanguageID) StoreName, 
						[pub].[GetStoreName](H.StoreID2,@LanguageID) StoreName2, DocDesc, case WHEN @ProcessID=240 THEN DescDtl ELSE '' END DescDtl, SgnSN1, SgnSN2, SgnSN3, SgnSN4, SgnSN5
		FROM inv.tblStorageDocsDtl D
		INNER JOIN inv.tblStorageDocsHdr H
		ON H.ProcessID=D.ProcessID AND H.ProcessNo=D.ProcessNo AND H.FiscalYear=D.FiscalYear AND H.SerialNo=D.SerialNo 
		WHERE H.ProcessID= @ProcessID AND H.ProcessNo= @ProcessNo
		and (@AcntCode IS NULL OR H.AcntCode = @AcntCode )
		and (@StoreID IS NULL OR D.StoreID = @StoreID )
		and (@Var1 =0 OR D.Var1 = @Var1  )
		and (@Var2 =0 OR D.Var2 = @Var2  )
		and (@Var3 =0 OR D.Var3 = @Var3  )
		and (@Var4 =0 OR D.Var4 = @Var4  )
		and (@CT1 ='' OR D.ConstText1 like '%' + @CT1 + '%' )
		and (@CT2 ='' OR D.ConstText2 like '%' + @CT2 + '%' )
		and (@CT3 ='' OR D.ConstText3 like '%' + @CT3 + '%' )
		and (@CT4 ='' OR D.ConstText4 like '%' + @CT4 + '%' )
		and ((@DocStep = -1 OR H.DocStep=@DocStep) 
				or(	@ConfirmCount>0 AND H.DocStep = @DocStep+1
					AND ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
					and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
					and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
					and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
					and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				  )
				) 
		--and (
		--		(@ConfirmCount=0 and (	(@Confirm=0 and D.DocStep=1)
		--							  or(@Confirm=1 and D.DocStep=2)
		--							  )
		--		)or 
		--		(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
		--		  				 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
		--						 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
		--						 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
		--						 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
		--		)
		--		)	

	END
ELSE IF (@ProcessID = 120 or @ProcessID = 128)  And @BaseProcessID = 127 -- انتقال بین انبارها
	
	SELECT * 
	,isnull(stuff((select '', '',  '  '+IsNull(LTrim(RTrim(Str(Sale.TaskFiscalYear))) + '/' + LTrim(RTrim(Str(Sale.TaskSerialNo))), '')  
			From inv.tblStoresRequestsDtl Sale
			Where Sale.ProcessID = H.ProcessID And Sale.ProcessNo = H.ProcessNo 
				And Sale.FiscalYear = H.FiscalYear And Sale.SerialNo = H.SerialNo
				and TaskFiscalYear<>0
			for xml path('')		),1,1,'') , '') TaskSerialNo
	
	FROM (
		SELECT DISTINCT	acc.funIsCodeClosed(@AcntCode) IsCodeClosed, CmrCnf.ProcessID, CmrCnf.ProcessNo, CmrCnf.FiscalYear, 
						CmrCnf.SerialNo, CmrCnf.DocDate, StoreID, pub.GetStoreName(StoreID,1) AS StoreName, 
						StoreID2, pub.GetStoreName(StoreID2,1) AS StoreName2,
						CmrCnf.SgnSN1, CmrCnf.SgnSN2, CmrCnf.SgnSN3, CmrCnf.SgnSN4, CmrCnf.SgnSN5,DocDesc --, CmrCnf.DocRowNo
		FROM
			(
				SELECT	A.ProcessID, A.ProcessNo, A.FiscalYear, A.SerialNo, A.DocRowNo, A.DocDate, 
						A.GoodsQuantity - ISNULL(B.GoodsQuantity,0) as ConfirmQuantity, A.StoreID, A.StoreID2,
						H.SgnSN1, H.SgnSN2, H.SgnSN3, H.SgnSN4, H.SgnSN5,H.DocDesc
				FROM  inv.tblStoresRequestsDtl A
				LEFT JOIN ( Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) GoodsQuantity From inv.tblStoresRequestsDtl 
				group by  BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo)B
				ON A.ProcessID = B.BaseProcessID AND A.ProcessNo = B.BaseProcessNo AND  A.FiscalYear = B.BaseFiscalYear AND 
    			   A.SerialNo  = B.BaseSerialNo AND  A.DocRowNo  = B.BaseDocRowNo 
				INNER JOIN inv.tblStoresRequestsHdr H ON A.ProcessID = H.ProcessID AND A.ProcessNo = H.ProcessNo AND 
														 A.FiscalYear = H.FiscalYear AND A.SerialNo  = H.SerialNo
				
				WHERE A.ProcessID = 127 AND A.ProcessNo = @ProcessNo AND A.GoodsQuantity - ISNULL(B.GoodsQuantity,0)>0 
					and (@TaskSerialNo=0 or (TaskFiscalYear=@TaskFiscalYear and TaskSerialNo=@TaskSerialNo))
				
			) CmrCnf 
		LEFT JOIN 
			(
				Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
						Cnf.ConfirmQuantity  AS ConfirmQuantity 
				From
					(
						Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
						From inv.tblStorageDocsDtl
						Where ProcessID = 120 AND BaseProcessID > 0 AND
							 (@AcntCode IS NULL   OR AcntCode = @AcntCode) AND  DocDate <= @DocDate AND
							 (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
								 BaseDocRowNo
					) Cnf
			) CmrOrder
			ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
			CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
			CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
		WHERE CmrCnf.DocDate <= @DocDate AND CmrCnf.ConfirmQuantity - ISNULL(CmrOrder.ConfirmQuantity,0)>0
	) H 
	WHERE IsCodeClosed = 0 
		and ([inv].[funAllowStores] (@UserID,@pub_UserIsAdmin,StoreID)='True'
			or [inv].[funAllowStores] (@UserID,@pub_UserIsAdmin,StoreID2)='True')
		----and inv.funGetUserIOAccess(D.StoreID2,@UserID,1,1)='True'
		--AND 
		--	(@pub_UserIsAdmin = 'True' OR @pub_AccessAllCodesStore = 'True' OR 
		--	((SELECT COUNT(*) 
		--	  FROM inv.tblStoresRng R 
		--	  WHERE R.UserID = @UserID AND R.AllowCodeView = 1 AND LEFT(A.StoreID, LEN(FromCode)) >= FromCode AND 
		--			LEFT(A.StoreID, LEN(ToCode)) <= ToCode) > 0))
		--				AND ((SELECT COUNT(*) 
		--		FROM inv.tblUsersIOAccessDtl 
		--		WHERE StoreID=A.StoreID AND UserID=@UserID)=0 OR 
		--			 ISNULL((SELECT TOP 1  [Output] 
		--			  FROM inv.tblUsersIOAccessDtl 
		--			  WHERE StoreID=A.StoreID AND UserID=@UserID),'True')='True')--inv.funGetUserIOAccess(StoreID,@UserID,-1,1)='True'	
ELSE IF @ProcessID=55 -- خرید
	BEGIN
	
	if (SELECT isnull(SettingValue,0) FROM pub.tblSettings WHERE SettingKey = 'HasCMR234')=0
		set @ProcessNo=0
	
	-------------------------------------------------------------------------------------------------------------------
	--select @AcntCode,@DocDate,@ProcessNo
	IF @BaseProcessID = 150 
	SELECT * FROM (
			SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed,ProcessID , ProcessNo , FiscalYear , SerialNo
			 ,DocDate	,AcntCode, AcntName,0 As AgreeNo,DocDesc,'' DescDtl
				from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0)
				where (@AcntCode IS NULL OR AcntCode = @AcntCode) 
						AND  DocDate<=@DocDate 
						AND ConfirmQuantity>0
						and (
							(@ConfirmCount=0 and (	(@Confirm=0 and DocStep=1)
												  or(@Confirm=1 and DocStep=2)
												  )
							)or 
							(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  							 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
											 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
											 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
											 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
							)
							)	
				) A WHERE IsCodeClosed = 0				
	ELSE IF  @BaseProcessID = 160
	begin
	 if @FiscalYear is null 
		set @FiscalYear=0
	 if @SerialNo is null 
		set @SerialNo=0
	 
	SELECT * FROM (
			SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed,ProcessID , ProcessNo , FiscalYear , SerialNo
			 ,DocDate	,AcntCode, AcntName, AgreeNo,DocDesc,'' DescDtl
				from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,@FiscalYear,@SerialNo,0,0,0,0,0,0)
				where (@AcntCode IS NULL OR AcntCode = @AcntCode) 
						AND  DocDate<=@DocDate 
						AND ConfirmQuantity>0
						and (
							(@ConfirmCount=0 and (	(@Confirm=0 and DocStep=1)
												  or(@Confirm=1 and DocStep=2)
												  )
							)or 
							(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  							 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
											 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
											 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
											 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
							)
							)	
				) A WHERE IsCodeClosed = 0
	end
	ELSE IF @BaseProcessID = 170 -- رسید موقت
	BEGIN
		IF (SELECT COUNT(SettingValue) FROM pub.tblSettings WHERE SettingKey = 'DeleteConfirmationStepInTempReceipt' AND (SettingValue='True' OR SettingValue='1'))>0
			SET @Confirm=0

		SELECT * FROM (
			SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed,ProcessID , ProcessNo , FiscalYear , SerialNo
			,DocDate	,AcntCode, AcntName,0 As AgreeNo,DocDesc,'' DescDtl,StoreID,[pub].[GetStoreName](StoreID,@LanguageID)  StoreName
			FROM cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0)
			WHERE (@AcntCode IS NULL OR AcntCode = @AcntCode OR (@BaseProcessID=170 and AcntCode='' )) 
			AND  (DocDate<=@DocDate or @Buy_DontCheckDateConvertTempReceiptToBuy='True') 
					AND ConfirmQuantity>0
					and Recognition NOT IN (0, 4)
					and (
						(@ConfirmCount=0 and (	(@Confirm=0 and DocStep=1)
												or(@Confirm=1 and DocStep=2)
												)
						)or 
						(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  							and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
											and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
											and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
											and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
						)
						)	
			) A WHERE IsCodeClosed = 0
	END
			
	ELSE IF @BaseProcessID = 56 -- باسکول خرید
		SELECT A.*, H.DocDate, H.AcntCode, pub.GetCodeName(H.AcntCode, @LanguageID) AcntName,
			   acc.funIsCodeClosed(@AcntCode) IsCodeClosed
		FROM
		(
			SELECT ProcessID, 0 ProcessNo, 0 FiscalYear, SerialNo 
			FROM inv.tblBaskulSalesHdr H
			WHERE ProcessID = @BaseProcessID and Step=4
			EXCEPT
			SELECT BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, BaseSerialNo
			FROM inv.tblStorageDocsHdr 
			WHERE ProcessID = @ProcessID And BaseProcessID = @BaseProcessID
		) A
		Inner Join inv.tblBaskulSalesHdr H ON A.ProcessID = H.ProcessID And A.SerialNo = H.SerialNo
		WHERE acc.funIsCodeClosed(@AcntCode) = 0

	ELSE IF @BaseProcessID = 90 -- فروش
		SELECT A.*, H.DocDate, H.AcntCode, pub.GetCodeName(H.AcntCode, @LanguageID) AcntName,
			   acc.funIsCodeClosed(@AcntCode) IsCodeClosed
		FROM
		(
			SELECT ProcessID, ProcessNo, FiscalYear, SerialNo
			FROM inv.tblStorageDocsHdr H
			WHERE ProcessID = @BaseProcessID 
			EXCEPT
			SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo
			FROM inv.tblStorageDocsHdr 
			WHERE ProcessID = 55 And BaseProcessID = @BaseProcessID	 
		) A
		Inner Join inv.tblStorageDocsHdr H ON 
		A.ProcessID = H.ProcessID And 
		A.ProcessNo = H.ProcessNo And 
		A.FiscalYear = H.FiscalYear And 
		A.SerialNo = H.SerialNo
		WHERE IsConfirmed='False' and acc.funIsCodeClosed(@AcntCode) = 0

	END
	
-------------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID=60 --برگشت از خرید
BEGIN
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed, OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,OD.DocDate,OD.AcntCode,[pub].[GetCodeName](OD.AcntCode,@LanguageID) AcntName
	FROM inv.tblStorageDocsDtl OD 
	inner join  inv.tblStorageDocsHdr H
	on OD.ProcessID =H.ProcessID and OD.ProcessNo=H.ProcessNo and OD.FiscalYear=H.FiscalYear and OD.SerialNo=H.SerialNo
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
			From
				(
					Select	ProcessID , ProcessNo , FiscalYear ,SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl
					Where ProcessID = 55 AND ProcessNo=@ProcessNo AND DocStep>=@BuyDocStep AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
						Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 55 AND ProcessNo=@ProcessNo
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo	
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo 
		WHERE	Cn.GoodsQuantity>0 AND (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate
		and (
				(@ConfirmCount=0 and (	(@Confirm=0 )--  and OD.DocStep=1) برای حالتی که خرید ریالی نشده برگشت پذیر باشد
									  or(@Confirm=1 and OD.DocStep=2)
									  )
				)or 
				(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  				 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
								 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
								 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
								 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)	 
			) A WHERE IsCodeClosed = 0
END		
ELSE IF @ProcessID = 90
	IF @BaseProcessID = 240 -- پیش فاکتور
		BEGIN
			DECLARE @DocStep1 tinyint
			DECLARE @HasConfirmForPreSale AS BIT
			DECLARE @PreSal_GetRemain AS BIT
			
			SET @HasConfirmForPreSale = 'False'
			SET @PreSal_GetRemain = 'False'
			
			SELECT @HasConfirmForPreSale=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'HasConfirmForPreSale'

			SELECT @PreSal_GetRemain=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'PreSal_GetRemain'

			DECLARE @ConfirmCountInPreSale AS  TinyInt;
			SET @ConfirmCountInPreSale = 0
			SELECT @ConfirmCountInPreSale = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ConfirmCountInPreSale'
			
			IF @HasConfirmForPreSale = 'False' 
				SET @DocStep1 = 1
			ELSE
				SET @DocStep1 = 2

			IF @PreSal_GetRemain = 0
				SELECT DISTINCT CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo ,CmrCnf.DocDate  , PH.AcntCode, [pub].[GetCodeName](PH.AcntCode,@LanguageID) AcntName, PH.VisitorAcntCode, 
								 PH.VisitorAcntCode2, PH.StoreID, PH.LocationID , PH.DocDesc
				FROM [inv].[FunGetPreSale] (@AcntCode,@DocDate,@DocStep1) AS CmrCnf 
				INNER JOIN 		
				(	
					SELECT DISTINCT ProcessID , ProcessNo , FiscalYear , SerialNo 
					FROM  [inv].[FunGetPreSale](@AcntCode,@DocDate,@DocStep1)  
					WHERE ProcessNo = @ProcessNo			
				EXCEPT
					(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
					From [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear)  
					UNION
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo 
					FROM sal.tblSaleOrderDtl
					WHERE BaseProcessID=240
					)
				) AS StorageDocs
					ON CmrCnf.ProcessID = StorageDocs.ProcessID AND  CmrCnf.ProcessNo = StorageDocs.ProcessNo AND 
					CmrCnf.FiscalYear = StorageDocs.FiscalYear AND CmrCnf.SerialNo = StorageDocs.SerialNo 
				INNER JOIN inv.tblPreSaleHdr PH 
				ON CmrCnf.ProcessID = PH.ProcessID AND CmrCnf.ProcessNo = PH.ProcessNo AND 
				   CmrCnf.FiscalYear = PH.FiscalYear AND CmrCnf.SerialNo = PH.SerialNo 
			And 
				(
					(@ConfirmCountInPreSale= 0)
					OR (@ConfirmCountInPreSale = 1 AND SgnSN1 <> 0)
					OR (@ConfirmCountInPreSale = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
					OR (@ConfirmCountInPreSale = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
					OR (@ConfirmCountInPreSale = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
					OR (@ConfirmCountInPreSale = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
				 )
					
			ELSE	
				SELECT	DISTINCT Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo, Cnf.DocDate, Cnf.AcntCode,
							     Cnf.AcntCode, [pub].[GetCodeName](Cnf.AcntCode,@LanguageID) AcntName, PH.VisitorAcntCode, 
								 PH.VisitorAcntCode2, PH.StoreID, PH.LocationID , PH.DocDesc ,Cnf.DescDtl
								  ,ConstText1,ConstText2,ConstText3,ConstText4,Var1,Var2,Var3,Var4
				FROM inv.tblPreSaleDtl Cnf	
				INNER JOIN inv.tblPreSaleHdr PH ON Cnf.ProcessID = PH.ProcessID AND Cnf.ProcessNo = PH.ProcessNo AND 
												   Cnf.FiscalYear = PH.FiscalYear AND Cnf.SerialNo = PH.SerialNo 
				Inner Join (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblPreSaleHdr 
							except	
							SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from sal.tblSaleOrderDtl where ProcessID=180 and BaseProcessID=240
							)S
				ON PH.ProcessID = S.ProcessID AND PH.ProcessNo = S.ProcessNo AND PH.FiscalYear = S.FiscalYear AND PH.SerialNo = S.SerialNo
				LEFT JOIN 
				(
					Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity 
					From inv.tblStorageDocsDtl
					Where BaseProcessID = 240 AND DocStep = @DocStep AND
					 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate <= @DocDate 
					Group BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo
				) sd ON	Cnf.ProcessID = sd.BaseProcessID AND Cnf.ProcessNo = sd.BaseProcessNo AND 
						Cnf.FiscalYear = sd.BaseFiscalYear AND Cnf.SerialNo = sd.BaseSerialNo AND 
						Cnf.DocRowNo = sd.BaseDocRowNo
				WHERE PH.DocStep=@DocStep1 AND (@AcntCode IS NULL OR Cnf.AcntCode = @AcntCode) AND Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0) > 0	  	 
				and (@Var1 =0 OR Cnf.Var1 = @Var1  )
				and (@Var2 =0 OR Cnf.Var2 = @Var2  )
				and (@Var3 =0 OR Cnf.Var3 = @Var3  )
				and (@Var4 =0 OR Cnf.Var4 = @Var4  )
				and (@CT1 ='' OR Cnf.ConstText1 like '%' + @CT1 + '%' )
				and (@CT2 ='' OR Cnf.ConstText2 like '%' + @CT2 + '%' )
				and (@CT3 ='' OR Cnf.ConstText3 like '%' + @CT3 + '%' )
				and (@CT4 ='' OR Cnf.ConstText4 like '%' + @CT4 + '%' )				
				And 
				(
					(@ConfirmCountInPreSale= 0)
					OR (@ConfirmCountInPreSale = 1 AND SgnSN1 <> 0)
					OR (@ConfirmCountInPreSale = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
					OR (@ConfirmCountInPreSale = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
					OR (@ConfirmCountInPreSale = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
					OR (@ConfirmCountInPreSale = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
				 )					 
		
		END
	ELSE IF @BaseProcessID = 55 -- خرید
	BEGIN
		DECLARE @TempFiscalYear SMALLINT
		DECLARE @StrSelect	NVarChar(4000)
		DECLARE @BaseFiscalYear SMALLINT
		
		SET @TempFiscalYear = RIGHT(DB_NAME(),4)
		SET @BaseFiscalYear = @TempFiscalYear
		
		SELECT * INTO ##tblS
		FROM [cmr].[FunGetSale](@AcntCode,@DocDate,@BaseFiscalYear)
		WHERE BaseProcessNo = @ProcessNo	
		
		SET @TempFiscalYear = @TempFiscalYear + 1
		
		WHILE (SELECT COUNT(NAME) from master.sys.databases
			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)))=1
		   BEGIN
				SET @StrSelect = 'INSERT INTO ##tblS
						SELECT * 
						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear)) + '.[inv].[FunGetBuy](''' + ISNULL(@AcntCode,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear)) + ')
						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
				PRINT @StrSelect
				Exec sp_executesql @StrSelect; 
				SET @TempFiscalYear = @TempFiscalYear + 1	   	
		   END
		  
			SELECT * FROM (
				SELECT   DISTINCT acc.funIsCodeClosed(AcntCode) IsCodeClosed, OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,DocDate,AcntCode,
								StoreID,[pub].[GetStoreName](StoreID,@LanguageID)  StoreName,[pub].[GetCodeName](AcntCode,@LanguageID) AcntName
				FROM inv.tblStorageDocsDtl OD 
				LEFT JOIN
				(
					SELECT BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						   BaseSerialNo , BaseDocRowNo, ISNULL(SUM(ConfirmQuantity),0) ConfirmQuantity
					FROM ##tblS
					GROUP BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
							 BaseSerialNo , BaseDocRowNo			
				) Cn ON Cn.BaseProcessID  = OD.ProcessID AND Cn.BaseProcessNo = OD.ProcessNo AND 
						Cn.BaseFiscalYear = OD.FiscalYear AND Cn.BaseSerialNo = OD.SerialNo 
				WHERE  OD.ProcessID=55 AND OD.ProcessNo=@ProcessNo  --AND OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) >0 
			) A WHERE IsCodeClosed = 0
			
		DROP TABLE ##tblS	
	END	
	
	ELSE IF @BaseProcessID = 91 -- باسکول فروش
		SELECT A.*, H.DocDate, H.AcntCode, pub.GetCodeName(H.AcntCode, @LanguageID) AcntName,
			   acc.funIsCodeClosed(@AcntCode) IsCodeClosed
		FROM
		(
			SELECT ProcessID,   ProcessNo,   FiscalYear, SerialNo 
			FROM inv.tblBaskulSalesHdr H
			WHERE ProcessID = @BaseProcessID 
			EXCEPT
			SELECT BaseProcessID,   BaseProcessNo,   BaseFiscalYear, BaseSerialNo
			FROM inv.tblStorageDocsHdr 
			WHERE ProcessID = @ProcessID And BaseProcessID = @BaseProcessID
		) A
		Inner Join inv.tblBaskulSalesHdr H ON A.ProcessID = H.ProcessID And A.SerialNo = H.SerialNo
		WHERE acc.funIsCodeClosed(@AcntCode) = 0
		
	ELSE -- 180 - سفارش فروش
		BEGIN
			DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
			DECLARE @SalOrderDocStep tinyint
			DECLARE @SalRet_RetToSalOdr AS BIT
			DECLARE @DontCheckProcessNoInSale AS BIT

			SET @SalOrder_ConfirmDocStep = 'False'
			SET @SalRet_RetToSalOdr = 'False'
			SET @DontCheckProcessNoInSale = 'False'
			
			SELECT @SalRet_RetToSalOdr = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'SalRet_RetToSalOdr' 
			
			SELECT @SalOrder_ConfirmDocStep=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'SalOrder_ConfirmDocStep'

			SELECT @DontCheckProcessNoInSale=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'DontCheckProcessNoInSale'
			
			DECLARE @ConfirmCountInSaleOrder AS  TinyInt;
			SELECT @ConfirmCountInSaleOrder = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ConfirmCountInSaleOrder'				
							
			IF @DontCheckProcessNoInSale = 'True' AND @ProcessID = 90 
				SET @ProcessNo = NULL
				
			IF @SalOrder_ConfirmDocStep = 'False' 
				SET @SalOrderDocStep = 1
			ELSE
				SET @SalOrderDocStep = 2
			
		-- ==========================================
		SELECT * 
		FROM (
				SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed, CmrCnf.ProcessID, CmrCnf.ProcessNo, 
				CmrCnf.FiscalYear, CmrCnf.SerialNo,CmrCnf.DocDate, AcntCode, [pub].[GetCodeName](AcntCode,@LanguageID) AcntName,
				CmrCnf.TransportationCostAcntCode, CmrCnf.TransportationCost, CmrCnf.TransportationIncomeAcntCode, 
				CmrCnf.TransportationIncome, CmrCnf.VisitorAcntCodeHdr, CmrCnf.HdrVisitorPercent, CmrCnf.VisitorCost, 
				CmrCnf.PackingCost, CmrCnf.PackingCostPercent, CmrCnf.TaxCost, CmrCnf.TaxOverWorthCost, CmrCnf.TollOverWorthCost,DocDesc ,
				CmrCnf.OtherCostAcntCode, CmrCnf.OtherCost, CmrCnf.OtherIncomeAcntCode, CmrCnf.OtherIncome,SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5
				From
					(
						SELECT DISTINCT * 
						FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@SalOrderDocStep,@SalRet_RetToSalOdr,0,0) 
						WHERE (@ProcessNo IS NULL OR ProcessNo = @ProcessNo)				
					) CmrCnf 
				--LEFT JOIN 
				--	(
				--		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				--		From [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
				--	) StorageDocs
				--	ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
				--	CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
				--	CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo
				--WHERE (ISNULL(CmrCnf.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0)) > 0 
				--WHERE case when @SalRet_RetToSalOdr = 'True' then (CmrCnf.ConfirmQuantity) else (ISNULL(CmrCnf.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0)) end >0 
				WHERE (CmrCnf.ConfirmQuantity)>0-- - ISNULL(StorageDocs.ConfirmQuantity,0))>0 
		) A WHERE IsCodeClosed = 0 And 
										(
											(@ConfirmCountInSaleOrder = 0)
											OR (@ConfirmCountInSaleOrder = 1 AND SgnSN1 <> 0)
											OR (@ConfirmCountInSaleOrder = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
											OR (@ConfirmCountInSaleOrder = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
											OR (@ConfirmCountInSaleOrder = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
											OR (@ConfirmCountInSaleOrder = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
										 )

   		END
ELSE IF @ProcessID = 209 AND @BaseProcessID = 180 -- تسویه
BEGIN
	--DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	--DECLARE @SalOrderDocStep tinyint
	--DECLARE @SalRet_RetToSalOdr AS BIT
	--DECLARE @DontCheckProcessNoInSale AS BIT

	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	SET @DontCheckProcessNoInSale = 'False'
	
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	SELECT @DontCheckProcessNoInSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'DontCheckProcessNoInSale'
	
	IF @DontCheckProcessNoInSale = 'True' AND @ProcessID = 90 
		SET @ProcessNo = NULL
		
	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @SalOrderDocStep = 1
	ELSE
		SET @SalOrderDocStep = 2
	
-- ==========================================
SELECT * 
FROM (
		SELECT DISTINCT	acc.funIsCodeClosed(AcntCode) IsCodeClosed, CmrCnf.ProcessID, CmrCnf.ProcessNo, 
		CmrCnf.FiscalYear, CmrCnf.SerialNo,CmrCnf.DocDate, AcntCode, [pub].[GetCodeName](AcntCode,@LanguageID) AcntName,
		CmrCnf.TransportationCostAcntCode, CmrCnf.TransportationCost, CmrCnf.TransportationIncomeAcntCode, 
		CmrCnf.TransportationIncome, CmrCnf.VisitorAcntCodeHdr, CmrCnf.HdrVisitorPercent, CmrCnf.VisitorCost, 
		CmrCnf.PackingCost,CmrCnf.PackingCostPercent, CmrCnf.TaxCost, CmrCnf.TaxOverWorthCost, CmrCnf.TollOverWorthCost, 
		CmrCnf.OtherCostAcntCode, CmrCnf.OtherCost, CmrCnf.OtherIncomeAcntCode, CmrCnf.OtherIncome,SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5
		From
			(
				SELECT DISTINCT * 
				FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@SalOrderDocStep,@SalRet_RetToSalOdr,0,0) 
				WHERE (@ProcessNo IS NULL OR ProcessNo = @ProcessNo)				
			) CmrCnf 
		--LEFT JOIN 
		--	(
		--		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
		--		From [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
		--	) StorageDocs
		--	ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
		--	CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
		--	CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo
		--WHERE (ISNULL(CmrCnf.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0)) > 0 
		--WHERE case when @SalRet_RetToSalOdr = 'True' then (CmrCnf.ConfirmQuantity) else (ISNULL(CmrCnf.ConfirmQuantity,0) - ISNULL(StorageDocs.ConfirmQuantity,0)) end >0 
		WHERE (CmrCnf.ConfirmQuantity)>0-- - ISNULL(StorageDocs.ConfirmQuantity,0))>0 
) A WHERE IsCodeClosed = 0

END	    		
-------------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID = 110 -- مصرف داخلی
BEGIN
DECLARE @ConfirmCountInUseRequest AS  TinyInt;
			SELECT @ConfirmCountInUseRequest = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ConfirmCountInUseRequest'
set @ConfirmCountInUseRequest=ISnull(@ConfirmCountInUseRequest,0)
IF @BaseProcessID = 230
	SELECT * FROM (
		SELECT DISTINCT	acc.funIsCodeClosed(@AcntCode) IsCodeClosed, CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo ,CmrCnf.DocDate,StoreID--, CmrCnf.DocRowNo ,
		,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5
		From
			(
				SELECT	A.ProcessID , A.ProcessNo , A.FiscalYear , A.SerialNo , A.DocRowNo ,A.DocDate,A.GoodsQuantity - ISNULL(B.GoodsQuantity,0) as ConfirmQuantity ,A.StoreID
				FROM  inv.tblStoresRequestsDtl A  with(NOLOCK)
				LEFT JOIN  inv.tblStoresRequestsDtl B  with(NOLOCK)
				ON A.ProcessID = B.BaseProcessID AND A.ProcessNo = B.BaseProcessNo AND  A.FiscalYear = B.BaseFiscalYear AND 
    			   A.SerialNo  = B.BaseSerialNo AND  A.DocRowNo  = B.BaseDocRowNo AND A.GoodsQuantity - ISNULL(B.GoodsQuantity,0)>0 
				WHERE A.ProcessID = 230 
			) CmrCnf
			inner join (Select ProcessID,ProcessNo,FiscalYear,SerialNo,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5 from   inv.tblStoresRequestsHdr )OD
			ON CmrCnf.ProcessID = OD.ProcessID AND CmrCnf.ProcessNo = OD.ProcessNo AND 
				CmrCnf.FiscalYear = OD.FiscalYear AND CmrCnf.SerialNo = OD.SerialNo 
				
		LEFT JOIN 
			(
				Select	Cnf.BaseProcessID , Cnf.BaseProcessNo , Cnf.BaseFiscalYear , Cnf.BaseSerialNo , Cnf.BaseDocRowNo ,
						Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) AS ConfirmQuantity 
				From
					(
						Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity
						From inv.tblStorageDocsDtl  with(NOLOCK)
						Where ProcessID = 110 AND BaseProcessID > 0 AND DocDate <= @DocDate AND						
							 (DocStep = 0 OR DocStep = 1 OR DocStep = 2 OR DocStep = 3) AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
								 BaseDocRowNo
					) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
							Sum(GoodsQuantity) ConfirmQuantity
					From inv.tblStorageDocsDtl  with(NOLOCK)
					Where BaseProcessID = 110 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
							BaseDocRowNo
				) Rtn
				ON	Cnf.BaseProcessID = Rtn.BaseProcessID AND Cnf.BaseProcessNo = Rtn.BaseProcessNo AND 
					Cnf.BaseFiscalYear = Rtn.BaseFiscalYear AND Cnf.BaseSerialNo = Rtn.BaseSerialNo AND 
					Cnf.BaseDocRowNo = Rtn.BaseDocRowNo	
				WHERE Cnf.ConfirmQuantity - ISNULL(Rtn.ConfirmQuantity,0) > 0
			) CmrOrder
			ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
			CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
			CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
		WHERE CmrCnf.DocDate<=@DocDate  AND CmrCnf.ConfirmQuantity-ISNULL(CmrOrder.ConfirmQuantity,0)>0
			) A WHERE IsCodeClosed = 0
				And 	((@ConfirmCountInUseRequest = 0)
			OR (@ConfirmCountInUseRequest = 1 AND SgnSN1 <> 0)
			OR (@ConfirmCountInUseRequest = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
			OR (@ConfirmCountInUseRequest = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
			OR (@ConfirmCountInUseRequest = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
			OR (@ConfirmCountInUseRequest = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)
ELSE IF @BaseProcessID = 100
	SELECT distinct OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,DocDate,AcntCode
	FROM inv.tblStorageDocsHdr OD   with(NOLOCK)
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
			From
				(
					Select	ProcessID , ProcessNo , FiscalYear ,SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl  with(NOLOCK)
					Where ProcessID = 100  AND DocStep>=1 AND 
						  DocDate <= @DocDate AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
						Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl   with(NOLOCK)
				Where BaseProcessID = 100 AND ProcessID = 110 
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo	
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo 
	WHERE Cn.GoodsQuantity>0 AND DocDate<=@DocDate --AND StoreID=@StoreID
END

	 
-----------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID=115 -- برگشت مصرف داخل?

begin
DECLARE @ConfirmCountInUse AS  TinyInt;
			SELECT @ConfirmCountInUse = SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'ConfirmCountInUse'
			
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed, OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,OD.DocDate,OD.AcntCode
	,SgnSN1,SgnSN2,SgnSN3,SgnSN4,SgnSN5,H.DocDesc,H.DocStep
	FROM inv.tblStorageDocsDtl OD 
	inner join inv.tblStorageDocsHdr H
					on  OD.ProcessID = H.ProcessID AND OD.ProcessNo = H.ProcessNo AND OD.FiscalYear = H.FiscalYear AND OD.SerialNo = H.SerialNo
	INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
			From
				(
					Select	ProcessID , ProcessNo , FiscalYear ,SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl
					Where ProcessID = 110 AND ProcessNo=@ProcessNo AND 
						 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocStep>=1 AND 
						  DocDate <= @DocDate AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
						Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 110 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo	
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo 
	WHERE Cn.GoodsQuantity>0 AND (@AcntCode IS NULL OR OD.AcntCode = @AcntCode) AND OD.DocDate<=@DocDate --AND StoreID=@StoreID
		) A WHERE IsCodeClosed = 0 AND (@OneStep='True' OR (@OneStep='False' AND A.DocStep>2) )
	And 	((@ConfirmCountInUse = 0)
			OR (@ConfirmCountInUse = 1 AND SgnSN1 <> 0)
			OR (@ConfirmCountInUse = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
			OR (@ConfirmCountInUse = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
			OR (@ConfirmCountInUse = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
			OR (@ConfirmCountInUse = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
		)
end
	-------------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID=250 -- 
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(@AcntCode) IsCodeClosed, CmrCnf.ProcessID , CmrCnf.ProcessNo , CmrCnf.FiscalYear , CmrCnf.SerialNo ,CmrCnf.DocDate--, CmrCnf.DocRowNo ,
	From
		(
			Select	ProcessID , ProcessNo , FiscalYear , SerialNo , DocRowNo ,DocDate,GoodsQuantity as ConfirmQuantity 
			FROM  inv.tblStoresRequestsDtl
		) CmrCnf 
	LEFT JOIN 
		(
			Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
			From [cmr].[FunGetBaseStorageDocsGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
		) CmrOrder
		ON CmrCnf.ProcessID = CmrOrder.BaseProcessID AND  CmrCnf.ProcessNo = CmrOrder.BaseProcessNo AND 
		CmrCnf.FiscalYear = CmrOrder.BaseFiscalYear AND CmrCnf.SerialNo = CmrOrder.BaseSerialNo AND 
		CmrCnf.DocRowNo = CmrOrder.BaseDocRowNo 
	WHERE CmrCnf.DocDate<=@DocDate 
		) A WHERE IsCodeClosed = 0
	 
-----------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID=255 -- 
if @BaseProcessID<>456
begin
SELECT * FROM (
	SELECT DISTINCT	acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed, OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,DocDate,AcntCode
	FROM inv.tblStorageDocsDtl OD 
		INNER JOIN
		(
			Select	Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
			From
				(
					Select	ProcessID , ProcessNo , FiscalYear ,SerialNo , 
							DocRowNo , GoodsQuantity
					From inv.tblStorageDocsDtl
					Where ProcessID = 250 AND ProcessNo=@ProcessNo AND 
						 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocStep>=1 AND 
						  DocDate <= @DocDate AND (@SerialNo IS NULL OR (SerialNo=@SerialNo AND FiscalYear =@FiscalYear))
				) Cnf
			LEFT JOIN 
			(
				Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
						Sum(GoodsQuantity) GoodsQuantity
				From inv.tblStorageDocsDtl 
				Where BaseProcessID = 250 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = @AcntCode) 
				Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
			) Rtn
			ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
				Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
				Cnf.DocRowNo = Rtn.BaseDocRowNo	
		) Cn ON Cn.ProcessID = OD.ProcessID AND Cn.ProcessNo = OD.ProcessNo AND 
				Cn.FiscalYear = OD.FiscalYear AND Cn.SerialNo = OD.SerialNo 
	WHERE Cn.GoodsQuantity>0 AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate<=@DocDate --AND StoreID=@StoreID
		) A WHERE IsCodeClosed = 0
end
else
begin
	SELECT DISTINCT	 OD.ProcessID , OD.ProcessNo , OD.FiscalYear , OD.SerialNo,DocDate
		FROM  	(
				Select	DocDate ,Cnf.ProcessID , Cnf.ProcessNo , Cnf.FiscalYear , Cnf.SerialNo,Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0) GoodsQuantity
				From
					(
						Select	ProcessID , ProcessNo , FiscalYear ,SerialNo , 
								DocRowNo , 1 GoodsQuantity,DocDate
						From ast.tblAssetsDtl
						Where ProcessID = 456 AND ProcessNo=@ProcessNo AND DocDate <= @DocDate 
					) Cnf
				LEFT JOIN 
				(
					Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo , 
							Sum(GoodsQuantity) GoodsQuantity
					From inv.tblStorageDocsDtl 
					Where BaseProcessID = 456 AND ProcessNo=@ProcessNo AND (@AcntCode IS NULL OR AcntCode = NULL) 
					Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo
				) Rtn
				ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
					Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
					Cnf.DocRowNo = Rtn.BaseDocRowNo	
			) OD

		WHERE OD.GoodsQuantity>0  AND DocDate<= @DocDate --AND StoreID=@StoreID	
end 	 
	
END
GO
