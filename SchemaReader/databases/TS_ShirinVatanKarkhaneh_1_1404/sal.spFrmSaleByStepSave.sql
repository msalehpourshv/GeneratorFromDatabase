USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/22
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[spFrmSaleByStepSave] 
 @ProcessID		tinyint,
 @ProcessNo		tinyint,
 @FiscalYear	smallint,
 @SerialNo		int,
 @DocDate		Char(10),
 @AcntCode		Varchar(20),
 @BaseProcessID		tinyint,
 @LanguageID	Tinyint
WITH ENCRYPTION
 AS

BEGIN

SET NOCOUNT ON;

	Declare @strMsgText		NVarChar(2044)
	Declare @GoodsID		Varchar(20)
	Declare @BaseFiscalYear	Smallint
	Declare @BaseProcessNo	tinyint
	Declare @BaseSerialNo	Int
	Declare @BaseDocRowNo	Int
	Declare @UsedGoodsQuantity	Float
	Declare @GoodsQuantity	Float
	DECLARE @SalOrder_ConfirmDocStep Nvarchar(100)
	DECLARE @DocStep tinyint
	DECLARE @SalRet_RetToSalOdr AS BIT

	SET @SalOrder_ConfirmDocStep = 'False'
	SET @SalRet_RetToSalOdr = 'False'
	
	SELECT @SalRet_RetToSalOdr = SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalRet_RetToSalOdr' 
	
	SELECT @SalOrder_ConfirmDocStep=SettingValue
	FROM pub.tblSettings
	WHERE SettingKey = 'SalOrder_ConfirmDocStep'

	IF @SalOrder_ConfirmDocStep = 'False' 
		SET @DocStep = 1
	ELSE
		SET @DocStep = 2

		Declare	Cursor_PayDtl CURSOR For 
		select BaseFiscalYear,BaseProcessNo,BaseSerialNo,BaseDocRowNo,GoodsID ,SUM(GoodsQuantity) GoodsQuantity
		from inv.tblStorageDocsDtl 
		WHERE ProcessID = @ProcessID AND
			  ProcessNo = @ProcessNo AND
			  FiscalYear= @FiscalYear AND
			  SerialNo  = @SerialNo 
		group by BaseFiscalYear,BaseProcessNo,BaseSerialNo,BaseDocRowNo,GoodsID

		Open  Cursor_PayDtl; 

		Fetch NEXT From Cursor_PayDtl Into @BaseFiscalYear,@BaseProcessNo,@BaseSerialNo,@BaseDocRowNo,@GoodsID,@GoodsQuantity

		While (@@Fetch_Status = 0)
			BEGIN
			--print @BaseSerialNo
			--print @BaseDocRowNo
				IF @BaseProcessID = 180 
				BEGIN
					Select	@UsedGoodsQuantity = CmrCnf.ConfirmQuantity 
					From
						(
							SELECT DISTINCT * 
							FROM  [cmr].[FunGetSaleOrderBaseWithRowNo](@BaseProcessNo,@BaseFiscalYear,@BaseSerialNo,@BaseDocRowNo,@AcntCode,@DocDate,@DocStep,@SalRet_RetToSalOdr)
							WHERE	FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND
									DocRowNo = @BaseDocRowNo 
						) CmrCnf 

					IF @UsedGoodsQuantity < 0
						-- مقدار کالای %S بیش از مقدار سفارش فروش است
						SET @strMsgText=TS.pub.funGetMessages(18001,@LanguageID)
				END
				ELSE
				IF @BaseProcessID = 90
				BEGIN
					Select	@UsedGoodsQuantity = Cnf.GoodsQuantity - ISNULL(Rtn.GoodsQuantity,0)
					From
						(
							Select	ProcessID ,ProcessNo , FiscalYear , SerialNo , 
									DocRowNo , GoodsQuantity
							From inv.tblStorageDocsDtl 
							Where ProcessID = 90 AND (@AcntCode IS NULL OR AcntCode = @AcntCode) AND 
								  DocDate <= @DocDate AND DocStep in (0,2) AND
								  FiscalYear = @BaseFiscalYear AND SerialNo = @BaseSerialNo AND
								  DocRowNo = @BaseDocRowNo 

						) Cnf
					LEFT JOIN 
					(
						Select	BaseProcessID , BaseProcessNo , BaseFiscalYear , BaseSerialNo , 
								BaseDocRowNo , Sum(GoodsQuantity) GoodsQuantity
						From inv.tblStorageDocsDtl 
						Where BaseProcessID = 90 AND (@AcntCode IS NULL OR AcntCode = @AcntCode)
						Group BY BaseProcessID , BaseProcessNo , BaseFiscalYear , 
								 BaseSerialNo , BaseDocRowNo
					) Rtn
					ON	Cnf.ProcessID = Rtn.BaseProcessID AND Cnf.ProcessNo = Rtn.BaseProcessNo AND 
						Cnf.FiscalYear = Rtn.BaseFiscalYear AND Cnf.SerialNo = Rtn.BaseSerialNo AND 
						Cnf.DocRowNo = Rtn.BaseDocRowNo
		
					IF @UsedGoodsQuantity < 0
						-- مقدار کالای %S بیش از مقدار سفارش فروش است
						SET @strMsgText=TS.pub.funGetMessages(18001,@LanguageID)

				END	
				IF @strMsgText <>''
				BEGIN
					Close Cursor_PayDtl;
					Deallocate Cursor_PayDtl; 
					Raiserror (@strMsgText,16,1,@GoodsID)
					Return
				END

				Fetch NEXT From Cursor_PayDtl Into @BaseFiscalYear,@BaseProcessNo,@BaseSerialNo,@BaseDocRowNo,@GoodsID,@GoodsQuantity
			END 
		Close Cursor_PayDtl;
		Deallocate Cursor_PayDtl; 

		UPDATE inv.tblStorageDocsDtl 
		SET BaseDocRowNo = A.DocRowNo
		FROM inv.tblStorageDocsDtl B INNER JOIN 
		sal.tblSaleOrderDtl A 
		ON A.ProcessID=B.BaseProcessID AND A.ProcessNo=B.BaseProcessNo  AND 
		A.FiscalYear=B.BaseFiscalYear  AND A.SerialNo=B.BaseSerialNo  AND 
		A.GoodsID=B.GoodsID AND A.DocRowNo<>B.BaseDocRowNo 
		AND A.GoodsID NOT IN (SELECT GoodsID 
		FROM sal.tblSaleOrderDtl AA 
		WHERE AA.ProcessID = 180 AND AA.ProcessID=A.ProcessID AND 
		AA.ProcessNo=A.ProcessNo AND AA.FiscalYear=A.FiscalYear AND AA.SerialNo=A.SerialNo 
		GROUP BY ProcessID,ProcessNo,FiscalYear,SerialNo,GoodsID 
		HAVING COUNT(GoodsID)>1)
END
GO
