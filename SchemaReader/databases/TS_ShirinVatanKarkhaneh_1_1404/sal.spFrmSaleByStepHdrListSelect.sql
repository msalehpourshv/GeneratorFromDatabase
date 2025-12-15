USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 1393/09/23 - Hamid
-- Description   : 
-- =============================================
Create PROCEDURE sal.spFrmSaleByStepHdrListSelect
	@AccessAllCodes bit,
	@UserID         int,
	@BaseProcessID	tinyint,
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@DocDate		Char(10),
	@AcntCode		varchar(20),
	@StoreID		varchar(20),
	@DocStep		Int,
	@CurrentDocStep	Int,
	@SerialNo		Int,
	@FiscalYear		Smallint,
	@FromDate		varchar(10)='',
	@ToDate			varchar(10)='',
	@FromSerialNo	Int=0,
	@ToSerialNo	    Int=0,
	@AccConfirmForOdoo	char(10)='',
	@TransferSerialNo	varchar(1000)='',
	@ExtraParams		NVarChar(Max) = ''
WITH ENCRYPTION
 AS
BEGIN
SET NOCOUNT ON;
	
	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @NotPermissionForDocStepForms			BIT;
	DECLARE @AgreeNo		varchar(20)
	DECLARE @PermissionFilter	NVarChar(Max) 
	SET @NotPermissionForDocStepForms='False'
	SET @AgreeNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @PermissionFilter	= pub.funSplitString(@ExtraParams, '@', 9);
	SET @NotPermissionForDocStepForms	= pub.funSplitString(@ExtraParams, '@', 10);
	set @PermissionFilter=isnull(@PermissionFilter,'')
	set @PermissionFilter= REPLACE(@PermissionFilter,'''','''''')

	DECLARE @LanguageID AS TinyInt
	SET @LanguageID = pub.funGetCurrentLanguageID()
	DECLARE @SalOrder_ConfirmDocStep Bit
	DECLARE @SalOrderDocStep tinyint
	DECLARE @PreSaleDocStep tinyint
	DECLARE @PreSal_GetRemain AS BIT
	DECLARE @HasConfirmForPreSale BIT
	DECLARE @SalRet_RetToSalOdr AS BIT
	DECLARE @GetRemainSaleOrder AS  Nvarchar(5);
	Declare @StrSelect			NVarChar(max);
	Declare @StrWhere			NVarChar(max);

	SET @SalOrder_ConfirmDocStep = 'False'
	SET @HasConfirmForPreSale = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	SET @PreSal_GetRemain = 'False'
	SET @GetRemainSaleOrder = 'False'

	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	SELECT @HasConfirmForPreSale=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'HasConfirmForPreSale'
	
	SELECT @PreSal_GetRemain=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'PreSal_GetRemain'
	
	SELECT @GetRemainSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'GetRemainSaleOrder'
	
	-- =============================
	DECLARE @ConfirmCountInSaleOrder AS tinyint
	SET @ConfirmCountInSaleOrder = 0
	SELECT @ConfirmCountInSaleOrder = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'ConfirmCountInSaleOrder'
				
	IF @SalOrder_ConfirmDocStep = 'False'
		SET @SalOrderDocStep = 1
	ELSE
		SET @SalOrderDocStep = 2

	IF @HasConfirmForPreSale = 'False'
		SET @PreSaleDocStep = 1
	ELSE
		SET @PreSaleDocStep = 2
				
	DECLARE @DontCheckProcessNoInSale AS BIT
	SET @DontCheckProcessNoInSale = 'False'
	DECLARE @UnitPart TINYINT
	SET @UnitPart  = 1

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

		set @StrSelect=''
		set @StrWhere=''
DECLARE @ConfirmCountSale  tinyint
DECLARE @ConfirmStepSale  tinyint
DECLARE @strDocStep	as nvarchar(1000)
DECLARE @strDocStep_SaleRet	as nvarchar(1000)
set @strDocStep =' DocStep='+str(@DocStep)+' '
if (@ProcessID=90 and @BaseProcessID=0) OR @ProcessID=100
begin
	if @ProcessNo=1
		begin
			SELECT @ConfirmCountSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmCountInSale1'
			SELECT @ConfirmStepSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmStepInSale1'	
			 If @ConfirmCountSale > 0 And @ConfirmStepSale = 0 
                  SELECT  @ConfirmStepSale = 3
		end
	if @ProcessNo=2
		begin
			SELECT @ConfirmCountSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmCountInSale2'
			SELECT @ConfirmStepSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmStepInSale2'	
			 If @ConfirmCountSale > 0 And @ConfirmStepSale = 0 
                  SELECT  @ConfirmStepSale = 3
		end
	if @ProcessNo=3
			begin
				SELECT @ConfirmCountSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmCountInSale3'
				SELECT @ConfirmStepSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmStepInSale3'	
			 If @ConfirmCountSale > 0 And @ConfirmStepSale = 0 
                   SELECT  @ConfirmStepSale = 3
			end
	if @ProcessNo=4
			begin
				SELECT @ConfirmCountSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmCountInSale4'
				SELECT @ConfirmStepSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmStepInSale4'	
			 If @ConfirmCountSale > 0 And @ConfirmStepSale = 0 
                   SELECT @ConfirmStepSale = 3
			end
	if @ProcessNo=10
		begin
			SELECT @ConfirmCountSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmCountInSale10'
			SELECT @ConfirmStepSale = SettingValue 	FROM pub.tblSettings	WHERE SettingKey = 'ConfirmStepInSale10'	
			 If @ConfirmCountSale > 0 And @ConfirmStepSale = 0 
                   SELECT @ConfirmStepSale = 3
		end		
     If (SELECT SettingValue FROM pub.tblSettings	WHERE SettingKey = 'ConfirmInNumericStep' )='true'
	    set @ConfirmStepSale = 2
     If  @ConfirmCountSale = 0 
        set @ConfirmStepSale = 0
 set  @ConfirmCountSale= isnull(@ConfirmCountSale,0)
 set  @ConfirmStepSale= isnull(@ConfirmStepSale,0)
-------------------------------------------------------------------------------------	
--  مخصوص زمانی که از مرحله تعدادی لیست مراحل مجوز را باز میکنیم
set @strDocStep =' DocStep='+str(@DocStep)+' '

if @DocStep=@ConfirmStepSale and @ConfirmCountSale>0
	begin
		set @strDocStep =' ( DocStep='+str(@DocStep)+' and  SgnSN1>0 )'
	    if @ConfirmCountSale>1
			set @strDocStep =' ( DocStep='+str(@DocStep)+'  and SgnSN1>0 and SgnSN2>0 )'
	    if @ConfirmCountSale>2
			set @strDocStep =' ( DocStep='+str(@DocStep)+'  and SgnSN1>0 and SgnSN2>0 and SgnSN3>0 )'
	    if @ConfirmCountSale>3
			set @strDocStep =' ( DocStep='+str(@DocStep)+'  and SgnSN1>0 and SgnSN2>0 and SgnSN3>0 and SgnSN4>0 )'
	    if @ConfirmCountSale>4
			set @strDocStep =' ( DocStep='+str(@DocStep)+'  and SgnSN1>0 and SgnSN2>0 and SgnSN3>0 and SgnSN4>0 and SgnSN4>0 )'
	end

if  @ProcessID=100
	begin

		if @ConfirmCountSale>1
			set @strDocStep =' ( DocStep>='+str(@ConfirmStepSale)+' and  SgnSN1>0 )'
	    if @ConfirmCountSale>1
			set @strDocStep =' ( DocStep>='+str(@ConfirmStepSale)+'  and SgnSN1>0 and SgnSN2>0 )'
	    if @ConfirmCountSale>2
			set @strDocStep =' ( DocStep>='+str(@ConfirmStepSale)+'  and SgnSN1>0 and SgnSN2>0 and SgnSN3>0 )'
	    if @ConfirmCountSale>3
			set @strDocStep =' ( DocStep>='+str(@ConfirmStepSale)+'  and SgnSN1>0 and SgnSN2>0 and SgnSN3>0 and SgnSN4>0 )'
	    if @ConfirmCountSale>4
			set @strDocStep =' ( DocStep>='+str(@ConfirmStepSale)+'  and SgnSN1>0 and SgnSN2>0 and SgnSN3>0 and SgnSN4>0 and SgnSN4>0 )'
	end
end

SET @strDocStep_SaleRet = @strDocStep 

-------------------------------------------------------------------------------------	
IF @DocDate =''
	BEGIN	
	
	set @AcntCode=isnull(@AcntCode,'')
	declare @Step char(1)=0

	IF @NotPermissionForDocStepForms=1
		SET @Step = 1

	IF @ProcessID=@BaseProcessID
		SET @Step = 1
	
	set @StrWhere ='WHERE ProcessID= '+str(@ProcessID)+' AND ProcessNo= '+str(@ProcessNo )+' 
				AND ('''+@AcntCode+''' = '''' OR AcntCode = '''+@AcntCode+''' )
				AND ('''+@FromDate+'''= '''' OR a.DocDate>='''+@FromDate+''')
				AND ('''+@ToDate+''' = '''' OR a.DocDate<='''+@ToDate+''' )
				AND ('+str(@FromSerialNo)+' = 0 OR a.SerialNo>='+str(@FromSerialNo)+' )
				AND ('+str(@ToSerialNo)+' = 0 OR a.SerialNo<='+str(@ToSerialNo)+' )
				and ((('+str(@DocStep)+' = -1 OR '+@strDocStep+') 
				or(DocStep='+str(@CurrentDocStep)+ ' and	'+str(@ConfirmCount)+'>0))
					AND (('+str(@Sgn1)+'=0 and SgnSN1=0) or ('+str(@Sgn1)+'>0 and SgnSN1>0)  )
					and (('+str(@Sgn2)+'=0 and SgnSN2=0) or ('+str(@Sgn2)+'>0 and SgnSN2>0)  )
					and (('+str(@Sgn3)+'=0 and SgnSN3=0) or ('+str(@Sgn3)+'>0 and SgnSN3>0)  )
					and (('+str(@Sgn4)+'=0 and SgnSN4=0) or ('+str(@Sgn4)+'>0 and SgnSN4>0)  )
					and (('+str(@Sgn5)+'=0 and SgnSN5=0) or ('+str(@Sgn5)+'>0 and SgnSN5>0)  ))
				'				 

	IF @AccConfirmForOdoo='1'
		SET @StrWhere += ' AND a.AccConfirmForOdoo=1 '
	IF @AccConfirmForOdoo='2'
		SET @StrWhere += ' AND a.AccConfirmForOdoo=0 '
	
	IF @TransferSerialNo<>''
		SET @StrWhere += ' AND a.TransferSerialNo=N''' + @TransferSerialNo + ''' '

	IF @AccessAllCodes = 'True'
		BEGIN
		set @StrSelect='
			SELECT Distinct ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,StoreID,DocStep,Price,Amount,
				   [pub].[GetStoreName](StoreID,'+str(@LanguageID)+')  StoreName,AcntCode,[pub].[GetCodeName](AcntCode,'+str(@LanguageID)+') AcntName,
				   SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5,HasNoDiscountDtl,VisitorAcntCode,[pub].[GetCodeName](VisitorAcntCode,'+str(@LanguageID)+') VisitorAcntName,(SELECT COUNT(s.GoodsID) from inv.tblStorageDocsDtl s
														 inner join inv.tblGoods g
														 on SUBSTRING(s.GoodsID,'+str(@str_Goods+1)+','+str(@str_GoodsSum)+')=g.GoodsID AND g.PartNumber = '+str(@UnitPart)+'
														 and g.IsService=''False''
														 where ProcessID= a.ProcessID AND ProcessNo= a.ProcessNo AND FiscalYear=a.FiscalYear and SerialNo=a.SerialNo ) GoodsCount
			FROM inv.tblStorageDocsHdr a
			'+ @StrWhere +'
			'
			print @StrSelect	
		Exec sp_executesql @StrSelect; 
		END
	ELSE		
		BEGIN	

			set @StrSelect='SELECT * FROM (
				SELECT  Distinct  acc.funIsCodeClosed(a.AcntCode) IsCodeClosed,ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,a.StoreID,DocStep,Price,Amount,
							   [pub].[GetStoreName](a.StoreID,'+str(@LanguageID)+')  StoreName,AcntCode,[pub].[GetCodeName](AcntCode,'+str(@LanguageID)+') AcntName,
								  SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5,HasNoDiscountDtl,VisitorAcntCode,[pub].[GetCodeName](VisitorAcntCode,'+str(@LanguageID)+') VisitorAcntName,(SELECT COUNT(s.GoodsID) from inv.tblStorageDocsDtl s
														 inner join inv.tblGoods g
														 on SUBSTRING(s.GoodsID,'+str(@str_Goods+1)+','+str(@str_GoodsSum)+')=g.GoodsID AND g.PartNumber = '+str(@UnitPart)+'
														 and g.IsService=''False''
														 where ProcessID= a.ProcessID AND ProcessNo= a.ProcessNo AND FiscalYear=a.FiscalYear and SerialNo=a.SerialNo ) GoodsCount
				FROM inv.tblStorageDocsHdr a 
				INNER JOIN (SELECT H.StoreID FROM inv.tblStores AS H 
							WHERE H.StoreID <> '''' AND ((SELECT COUNT(*) 
							FROM inv.tblStoresRng R
							WHERE R.UserID = '+str(@UserID)+' AND 
								 R.AllowCodeView=1 AND 
								 LEFT(H.StoreID,LEN(FromCode)) >= FromCode AND
								 LEFT(H.StoreID, LEN(ToCode)) <= ToCode) > 0) ) B
				ON a.StoreID=B.StoreID		  
				'+ @StrWhere +'
			) C
			WHERE IsCodeClosed = 0		'

			print @StrSelect
			Exec sp_executesql @StrSelect; 
		END	  
	END
ELSE IF @ProcessID = 90
	IF @BaseProcessID = 240
		BEGIN

			DECLARE @ConfirmState1 tinyint
			DECLARE @ConfirmState2 tinyint
			
			DECLARE @PreSaleConfirmDayLimit AS Int
			DECLARE @PreSaleConfirmHourLimit AS Varchar(10)
				
			SELECT @PreSaleConfirmDayLimit=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'PreSaleConfirmDay'	
			
			SELECT @PreSaleConfirmHourLimit=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'PreSaleConfirmHour'	
			
			IF @PreSaleConfirmDayLimit <> 0 And @PreSaleConfirmHourLimit <> '' And @PreSaleConfirmHourLimit Is Not Null
			Begin
				SET @ConfirmState1 = 1
				SET @ConfirmState2 = 1
			End
			ELSE
			Begin
				SET @ConfirmState1 = 0
				SET @ConfirmState2 = 3
			End
			
			SELECT @DontCheckProcessNoInSale=SettingValue
			FROM pub.tblSettings
			WHERE SettingKey = 'DontCheckProcessNoInSale'

			IF @PreSal_GetRemain = 0
			
				SELECT DISTINCT CmrCnf.ProcessID, CmrCnf.ProcessNo, CmrCnf.FiscalYear, CmrCnf.SerialNo, CmrCnf.DocDate,
								CmrCnf.AcntCode, [pub].[GetCodeName](AcntCode,@LanguageID) AcntName, CmrCnf.VisitorAcntCode,[pub].[GetCodeName](CmrCnf.VisitorAcntCode,@LanguageID) VisitorAcntName, 
								CmrCnf.VisitorAcntCode2,[pub].[GetCodeName](CmrCnf.VisitorAcntCode2,@LanguageID) VisitorAcntName2, CmrCnf.StoreID, CmrCnf.LocationID
				FROM [inv].[FunGetPreSale] (@AcntCode,@DocDate,@PreSaleDocStep) AS CmrCnf
				INNER JOIN 		
				(	
				 SELECT DISTINCT ProcessID , ProcessNo , FiscalYear , SerialNo 
				 FROM  [inv].[FunGetPreSale](@AcntCode,@DocDate,@PreSaleDocStep)  
				 WHERE (ProcessNo = @ProcessNo OR @DontCheckProcessNoInSale = 'True' )			 
				 
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
					CmrCnf.FiscalYear = StorageDocs.FiscalYear AND CmrCnf.SerialNo = StorageDocs.SerialNo AND
					CmrCnf.ConfirmState >= @ConfirmState1 And CmrCnf.ConfirmState <= @ConfirmState2 AND CmrCnf.DocStep >= @PreSaleDocStep
		
			ELSE	
				SELECT	DISTINCT Cnf.ProcessID, Cnf.ProcessNo, Cnf.FiscalYear, Cnf.SerialNo, Cnf.DocDate, Cnf.AcntCode,
							     Cnf.AcntCode, [pub].[GetCodeName](Cnf.AcntCode,@LanguageID) AcntName, PH.VisitorAcntCode
							     ,[pub].[GetCodeName](PH.VisitorAcntCode,@LanguageID) VisitorAcntName
							     ,[pub].[GetCodeName](PH.VisitorAcntCode2,@LanguageID) VisitorAcntName2, 
								 PH.VisitorAcntCode2, PH.StoreID, PH.LocationID
				FROM inv.tblPreSaleDtl Cnf
				Inner Join (SELECT ProcessID,ProcessNo,FiscalYear,SerialNo from inv.tblPreSaleHdr 
							except	
							SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo from sal.tblSaleOrderDtl where ProcessID=180 and BaseProcessID=240
							)S
				ON Cnf.ProcessID = S.ProcessID AND Cnf.ProcessNo = S.ProcessNo AND Cnf.FiscalYear = S.FiscalYear AND Cnf.SerialNo = S.SerialNo
				INNER JOIN inv.tblPreSaleHdr PH ON Cnf.ProcessID = PH.ProcessID AND Cnf.ProcessNo = PH.ProcessNo AND 
												   Cnf.FiscalYear = PH.FiscalYear AND Cnf.SerialNo = PH.SerialNo AND
												   PH.ConfirmState >= @ConfirmState1 And PH.ConfirmState <= @ConfirmState2				
				LEFT JOIN 
				(
					Select BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo,Sum(GoodsQuantity) ConfirmQuantity 
					From inv.tblStorageDocsDtl
					Where BaseProcessID = 240 AND --DocStep = @DocStep AND
					 (@AcntCode IS NULL OR AcntCode = @AcntCode) AND DocDate <= @DocDate 
					Group BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, BaseDocRowNo
				) sd ON	Cnf.ProcessID = sd.BaseProcessID AND Cnf.ProcessNo = sd.BaseProcessNo AND 
						Cnf.FiscalYear = sd.BaseFiscalYear AND Cnf.SerialNo = sd.BaseSerialNo AND 
						Cnf.DocRowNo = sd.BaseDocRowNo
				WHERE Cnf.GoodsQuantity - ISNULL(sd.ConfirmQuantity,0) > 0 
				  AND PH.ConfirmState <> 2 and PH.DocStep >= @PreSaleDocStep
		END
	ELSE IF @BaseProcessID = 55
	BEGIN
		DECLARE @TempFiscalYear SMALLINT		
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
	BEGIN
		SELECT A.*, H.DocDate, H.AcntCode, pub.GetCodeName(H.AcntCode, @LanguageID) AcntName,
			   acc.funIsCodeClosed(@AcntCode) IsCodeClosed
		FROM
		(
			SELECT ProcessID, 0 ProcessNo, 0 FiscalYear, SerialNo 
			FROM inv.tblBaskulSalesHdr H
			WHERE ProcessID = @BaseProcessID 
			EXCEPT
			SELECT BaseProcessID, 0 BaseProcessNo, 0 BaseFiscalYear, BaseSerialNo
			FROM inv.tblStorageDocsHdr 
			WHERE ProcessID = @ProcessID And BaseProcessID = @BaseProcessID
		) A
		Inner Join inv.tblBaskulSalesHdr H ON A.ProcessID = H.ProcessID And A.SerialNo = H.SerialNo
		WHERE acc.funIsCodeClosed(@AcntCode) = 0
	
		--===============================		
	END		
	ELSE	-- ====== SaleOrder
	BEGIN
		SELECT @DontCheckProcessNoInSale=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DontCheckProcessNoInSale'
					
		IF @DontCheckProcessNoInSale = 'True' 
			SET @ProcessNo = NULL		
		SELECT *  FROM (
			SELECT   DISTINCT acc.funIsCodeClosed(AcntCode) IsCodeClosed, CmrCnf.ProcessID, CmrCnf.ProcessNo, CmrCnf.FiscalYear, 
							  CmrCnf.SerialNo ,CmrCnf.DocDate,AgreeNo,DocDesc,AcntCode,[pub].[GetCodeName](AcntCode,@LanguageID) AcntName,
							  CmrCnf.SgnSN1, CmrCnf.SgnSN2, CmrCnf.SgnSN3, CmrCnf.SgnSN4, CmrCnf.SgnSN5,HasNoDiscountDtl,VisitorAcntCode
							  ,[pub].[GetCodeName](VisitorAcntCode,@LanguageID) VisitorAcntName,StoreID, CmrCnf.SettlementDate
				From
					(
						SELECT DISTINCT * 
						FROM  [cmr].[FunGetSaleOrder](@AcntCode,@DocDate,@SalOrderDocStep,@SalRet_RetToSalOdr,0,0)  a
						WHERE (@ProcessNo IS NULL OR ProcessNo = @ProcessNo)
						AND (@AcntCode  is null  or a.AcntCode like ''+ @AcntCode +'%')
						AND (@FromSerialNo  =0  or a.SerialNo >= @FromSerialNo )
						AND (@ToSerialNo  =0 or a.SerialNo <= @ToSerialNo )
						AND (@SerialNo  is null  or a.SerialNo = @SerialNo )
						AND (@FiscalYear  is null  or a.FiscalYear = @FiscalYear )
						AND (@FromDate =''  or a.DocDate >= @FromDate )
						AND (@ToDate =''  or a.DocDate <= @ToDate )		
						AND (@AgreeNo = '' OR a.AgreeNo=@AgreeNo )
						AND (@GetRemainSaleOrder='True' OR 
						     (SELECT top 1 COUNT(*) from inv.tblStorageDocsDtl b
							  WHERE b.BaseProcessID =a.ProcessID AND  b.BaseProcessNo=a.ProcessNo  AND 
							 	    b.BaseFiscalYear =a.FiscalYear  AND  b.BaseSerialNo=a.SerialNo )=0)
						--WHERE ProcessNo = @ProcessNo			
					) CmrCnf 
				--LEFT JOIN 
				--	(
				--		Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , BaseDocRowNo ,ConfirmQuantity 
				--		From [cmr].[FunGetBaseSaleGoods](@AcntCode,@DocDate,1,2,@SerialNo,@FiscalYear) 
				--	) StorageDocs
				--	ON CmrCnf.ProcessID = StorageDocs.BaseProcessID AND  CmrCnf.ProcessNo = StorageDocs.BaseProcessNo AND 
				--	CmrCnf.FiscalYear = StorageDocs.BaseFiscalYear AND CmrCnf.SerialNo = StorageDocs.BaseSerialNo AND 
				--	CmrCnf.DocRowNo = StorageDocs.BaseDocRowNo
				WHERE (CmrCnf.ConfirmQuantity ) >0 -- - ISNULL(StorageDocs.ConfirmQuantity,0))>0 
		) A  WHERE 	IsCodeClosed = 0 And 
										(
											(@ConfirmCountInSaleOrder = 0)
											OR (@ConfirmCountInSaleOrder = 1 AND SgnSN1 <> 0)
											OR (@ConfirmCountInSaleOrder = 2 AND SgnSN1 <> 0 AND SgnSN2 <> 0)
											OR (@ConfirmCountInSaleOrder = 3 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0)
											OR (@ConfirmCountInSaleOrder = 4 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0)
											OR (@ConfirmCountInSaleOrder = 5 AND SgnSN1 <> 0 AND SgnSN2 <> 0 AND SgnSN3 <> 0 AND SgnSN4 <> 0 AND SgnSN5 <> 0)
										 )
		
	END		
	-- @ProcessID =171    برای انتخاب فروش در فرم کنترل کیفی
ELSE IF @ProcessID = 100 or @ProcessID = 171
IF @BaseProcessID = 171
	BEGIN	
	select Distinct ProcessID	,ProcessNo	,FiscalYear,	SerialNo,	StoreID	,DocDate	,AcntCode,	AcntName,	DocDesc	
		from cmr.FunCmrGoodsQtyRemain(171,0,0,0,0,0,0,0,0,0) a		
		where ConfirmQuantity>0 AND Recognition=1
		AND (@AcntCode  is null  or a.AcntCode = @AcntCode )
		AND (@SerialNo  is null  or a.SerialNo = @SerialNo )
		AND (@FiscalYear  is null  or a.FiscalYear = @FiscalYear )
		AND (@FromDate =''  or a.DocDate >= @FromDate )
		AND (@ToDate =''  or a.DocDate <= @ToDate )

	end
	else IF @BaseProcessID = 90
	BEGIN
		SELECT @DontCheckProcessNoInSale=SettingValue
		FROM pub.tblSettings
		WHERE SettingKey = 'DontCheckProcessNoInSale'
					
		IF @DontCheckProcessNoInSale = 'True' AND @ProcessID = 90 
			SET @ProcessNo = NULL		
			
		DECLARE @TempFiscalYear1 SMALLINT
		DECLARE @StrSelect1	NVarChar(4000)
		DECLARE @BaseFiscalYear1 SMALLINT
		Declare @DocStep_Sale int 
		
		Declare @SaleOrderAcntCode Varchar(20)	
		SELECT @SaleOrderAcntCode = SettingValue FROM pub.tblSettings WHERE SettingKey = 'SaleOrderAcntCode'

		SET @DocStep_Sale = 0
		select @DocStep_Sale = ISNULL(MAX(DocStep),0) from inv.tblStorageDocsHdr
		WHERE   ProcessID=90 AND ProcessNo=@ProcessNo and DocStep<90

		IF @DocStep_Sale<1
			SET @DocStep_Sale = -1
		ELSE
			SET @DocStep_Sale=1

		SET @TempFiscalYear1 = RIGHT(DB_NAME(),4)
		SET @BaseFiscalYear1 = @TempFiscalYear1
		
		SELECT * INTO #tblS1
		FROM [cmr].[FunGetSale](@AcntCode,@DocDate,@BaseFiscalYear1)
		WHERE BaseProcessNo = @ProcessNo	
		
		--SET @TempFiscalYear1 = @TempFiscalYear1 + 1
		
		WHILE (SELECT COUNT(NAME) from master.sys.databases
			   WHERE name= LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1)))=1
		   BEGIN
				SET @StrSelect1 = '
						INSERT INTO #tblS1
						SELECT * 
						FROM ' + LEFT(DB_NAME(),LEN(DB_NAME())-4) + LTRIM(STR(@TempFiscalYear1)) + '.[cmr].[FunGetSale](''' + ISNULL(@AcntCode,'') + ''',''' + @DocDate + ''',' + LTRIM(STR(@BaseFiscalYear1)) + ')
						WHERE BaseProcessNo = ' + LTRIM(STR(@ProcessNo))
				PRINT @StrSelect1
				Exec sp_executesql @StrSelect1; 
				SET @TempFiscalYear1 = @TempFiscalYear1 + 1	   	
		   END
		 
		  	SELECT BaseProcessID , BaseProcessNo , BaseFiscalYear , 
						   BaseSerialNo , BaseDocRowNo, ISNULL(SUM(ConfirmQuantity),0) ConfirmQuantity
						   into #tblS12
					FROM #tblS1
					GROUP BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
							 BaseSerialNo , BaseDocRowNo
		      -- =====================================
			SELECT A.* ,SgnSN1,SgnSN2,SgnSN3, SgnSN4, SgnSN5,HasNoDiscountDtl,B.DocStep	into #tblTempSaleByStep	
			FROM 
			(
				SELECT DISTINCT acc.funIsCodeClosed(OD.AcntCode) IsCodeClosed, OD.ProcessID, OD.ProcessNo, OD.FiscalYear, 
								OD.SerialNo,OD.DocDate,OD.AcntCode, StoreID, [pub].[GetStoreName](StoreID,@LanguageID) StoreName,
								[pub].[GetCodeName](OD.AcntCode,@LanguageID) AcntName
				FROM inv.tblStorageDocsDtl OD
				--	-------------------------------------------------------------------			
	 
				LEFT JOIN
				#tblS12 Cn ON Cn.BaseProcessID  = OD.ProcessID AND Cn.BaseProcessNo = OD.ProcessNo AND 
						Cn.BaseFiscalYear = OD.FiscalYear AND Cn.BaseSerialNo = OD.SerialNo and  Cn.BaseDocRowNo= OD.DocRowNo
				WHERE  OD.ProcessID=90 AND (@ProcessNo IS NULL OR ProcessNo = @ProcessNo) AND (@AcntCode IS NULL OR OD.AcntCode LIKE @AcntCode + '%') AND 
					   OD.GoodsQuantity - ISNULL(Cn.ConfirmQuantity,0) > 0 And OD.DocStep > @DocStep_Sale
			) A 
			INNER JOIN inv.tblStorageDocsHdr B
			ON A.ProcessID  = B.ProcessID AND A.ProcessNo = B.ProcessNo AND 
			   A.FiscalYear = B.FiscalYear AND A.SerialNo = B.SerialNo
			WHERE IsCodeClosed = 0 And (B.ProcessID<>90 or  (B.ProcessID=90 and B.TPInp<>7)) And  
				((SELECT COUNT(*) FROM inv.tblStorageDocsDtl a 
				   WHERE  IsReward=0 and a.ProcessID  = A.ProcessID AND a.ProcessNo = A.ProcessNo AND 
						  a.FiscalYear = A.FiscalYear AND a.SerialNo = A.SerialNo )=0 OR 
				(------------حذف اطلاعاتی که اسناد آنها ازنوع یادداشت است------------------------------------------------------
				  SELECT COUNT(*)	from acc.tblVoucherDtl  v 
				  WHERE v.SourceProcessID= A.ProcessID and  v.SourceProcessNo= A.ProcessNo
				  and  v.SourceFiscalYear= A.FiscalYear and  v.SourceSerialNo= A.SerialNo
				  and (v.AcntCode= A.AcntCode or v.AcntCode=[pub].[funMergCode](@SaleOrderAcntCode,A.AcntCode)) and v.VchKind<>0 
				  ) > 0)
		    
		    -- =====================================	
		---برای مرحله تخفیفات پس از فروش	
		SELECT @strDocStep_SaleRet = REPLACE(@strDocStep_SaleRet,'DocStep=','DocStep>=')
			    
		SET @StrSelect = '
			SELECT *  
			FROM #tblTempSaleByStep
			WHERE 1=1 ' + @PermissionFilter + '
			  AND ('+str(@DocStep)+' = -1 OR '+@strDocStep_SaleRet+')
			ORDER BY DocDate'
		PRINT @StrSelect
		Exec sp_executesql @StrSelect; 

	END
	DROP TABLE #tblTempSaleByStep	
	--WHERE (OD.ConfirmQuantity - ISNULL(cn.ConfirmQuantity,0))>0 
END
GO
