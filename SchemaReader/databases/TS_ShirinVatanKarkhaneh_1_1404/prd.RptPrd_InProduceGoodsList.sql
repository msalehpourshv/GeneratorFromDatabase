USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create date   : 1386/12/26
-- Viewed By	 : 
-- Last Modified : 1390/03/05
-- Last Modifier : TakroSystem\Zia
-- Description	 : 
-- ==============================================
Create PROCEDURE [prd].[RptPrd_InProduceGoodsList]
	@SelectedGoods		Int = 0, 
	@SelectedAcnt1		Int = Null, -- کد واحد تولید
	@SelectedAcnt2		Int = Null, -- کد واحد تولید
	@SelectedAcnt3		Int = Null, -- کد واحد تولید
	@SelectedAcnt4		Int = Null, -- کد واحد تولید
	@DocDateFr			Char(10) = Null,
	@DocDateTo			Char(10) = Null,
	@IncludeQuantity	Bit = 1, -- شامل ستون مقدار
	@IncludePrice		Bit = 1, -- شامل ستون قیمت
	@RepInfo			NVarChar(100) = '1@1@1' -- bit array options
WITH ENCRYPTION
AS 
---- Declarations ---------------
Declare @StrSelect	NVarChar(4000);
Declare @StrFrom	NVarChar(1000);
Declare @StrWhere	NVarChar(2000);
Declare @StrDate	NVarChar(2000);
declare @BatchNo	nvarchar(20)

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; -- برای حالت کدهای انتخابی
DECLARE	@ReportID		Int; -- برای حالت کدهای انتخابی
declare @DateField	nvarchar(20);
declare @Prd_ProduceIsOneStep	BIT;
declare @DocStep	nvarchar(20);
Declare @WithFormula as varchar(10)

BEGIN --============== S T A R T  C O D E ===================================================

	SET NOCOUNT ON;

	SET @BatchNo = ''
	-- I N I T ------------------------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1';
	IF (@SelectedGoods	Is Null)	SET @SelectedGoods = 0;
	IF (@SelectedAcnt1	Is Null)	SET @SelectedAcnt1 = 0;
	IF (@SelectedAcnt2	Is Null)	SET @SelectedAcnt2 = 0;
	IF (@SelectedAcnt3	Is Null)	SET @SelectedAcnt3 = 0;
	IF (@SelectedAcnt4	Is Null)	SET @SelectedAcnt4 = 0;

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @WithFormula	= pub.funSplitString(@RepInfo, '@', 6);
	SET @BatchNo	= pub.funSplitString(@RepInfo, '@', 8);

	SET @StrDate = ''
	
	if (@IncludePrice = 1)
		set @DateField = 'SndH.DocDate'	
		--set @DateField = 'VchDate2'
	else
		set @DateField = 'SndH.DocDate'	

if (select count(*) from pub.tblSettings
	where SettingKey='Prd_ProduceIsOneStep')>0
		select @Prd_ProduceIsOneStep=SettingValue from pub.tblSettings
		where SettingKey='Prd_ProduceIsOneStep'	 

if @Prd_ProduceIsOneStep = 'True'
	set @DocStep ='(0,1,2)'
  else
	set @DocStep ='(0,2)'
	
	---------------------------------------------------------------------------

	-- W H E R E --------------------------------------------------------------
	SET @StrWhere = ' AND SndH.ProcessID = 70'

	If (@DocDateFr Is Not Null) OR (@DocDateTo Is Not Null)
		If (@DocDateFr = @DocDateTo)
		begin
			SET @StrDate = @StrDate + ' AND DocDate  = ''' + @DocDateFr + ''''
			SET @StrWhere = @StrWhere + ' AND ' + LTrim(@DateField) + '  = ''' + @DocDateFr + ''''
		end
		Else 
		Begin
			If (@DocDateFr Is Not Null)
			begin
				SET @StrDate = @StrDate + ' AND DocDate >= ''' + @DocDateFr + ''''
				SET @StrWhere = @StrWhere + ' AND ' + LTrim(@DateField) + ' >= ''' + @DocDateFr + ''''
			end
			If (@DocDateTo Is Not Null)
			begin
				SET @StrDate = @StrDate + ' AND DocDate <> '''' AND DocDate <= ''' + @DocDateTo + ''''
				SET @StrWhere = @StrWhere + ' AND '  + LTrim(@DateField) + ' <> '''' AND ' + LTrim(@DateField) + ' <= ''' + @DocDateTo + ''''
			end
		End

	If (@SelectedGoods > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedGoods, 'SndH.ProductID') 

	If (@SelectedAcnt1 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt1, 'SndH.AcntCode')
	If (@SelectedAcnt2 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt2, 'SndH.AcntCode')
	If (@SelectedAcnt3 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt3, 'SndH.AcntCode')
	If (@SelectedAcnt4 > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedAcnt4, 'SndH.AcntCode')
	---------------------------------------------------------------------------

	-- S E L E C T ------------------------------------------------------------
	IF @WithFormula = '3'
	SET @StrSelect = '
				SELECT SndH.ProcessID, SndH.ProcessNo, SndH.FiscalYear, SndH.SerialNo, SndH.BatchNo, 
					   SndD.GoodsID, SndH.DocDate, SndH.DocDesc, SndH.AcntCode, SndD.GoodsAmount,
					   SUM((SndD.GoodsQuantity*(ProductCount-PrdQuantity))/ProductCount-ISNULL(gdsQuantity,0)) GoodsQuantity,
						[pub].[funGetGoodsName](SndD.GoodsID, ' + @LangID + ') GoodsName,
						[pub].[GetCodeName](SndH.AcntCode, ' + @LangID + ') AS AcntName
				FROM 
				(   
					SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.ProductID,a.ProductCount ,0 PrdQuantity, 
						   a.BatchNo, a.DocDate, a.DocDesc, a.AcntCode
					FROM inv.tblStorageDocsHdr a
					iNNER JOIN (
						SELECT a.BatchNo,a.ProductCount ,ProductID,AcntCode
						FROM inv.tblStorageDocsHdr a 
						WHERE a.ProcessID = 70 '+ @StrDate +'
						EXCEPT
						SELECT b.BatchNo,Sum(b.GoodsQuantity) GoodsQuantity ,GoodsID,AcntCode
						FROM inv.tblStorageDocsDtl b 
						WHERE b.ProcessID = 80 '+ @StrDate +'
						Group by b.BatchNo,GoodsID,AcntCode
						) b On a.BatchNo=b.BatchNo and a.ProductID=b.ProductID AND a.AcntCode=b.AcntCode
						WHERE a.ProcessNo=1
				) SndH
				INNER JOIN inv.tblStorageDocsDtl SndD ON SndH.ProcessID=SndD.ProcessID and SndH.ProcessNo=SndD.ProcessNo and 
														 SndH.FiscalYear=SndD.FiscalYear and SndH.SerialNo=SndD.SerialNo
				LEFT JOIN 
				(
					 SELECT b.BatchNo,GoodsID,SUM(GoodsQuantity) gdsQuantity 
					 FROM (Select * from  inv.tblStorageDocsDtl WHERE  a.ProcessID=75 '+ @StrDate +')a
					 INNER JOIN inv.tblStorageDocsHdr b
					 on a.ProcessID=b.ProcessID and a.ProcessNo=b.ProcessNo and a.FiscalYear=b.FiscalYear and a.SerialNo=b.SerialNo
					 WHERE  a.ProcessID=75  
					 GROUP BY b.BatchNo, GoodsID
				) SndRet ON SndH.BatchNo = SndRet.BatchNo AND SndD.GoodsID = SndRet.GoodsID
				WHERE (SndD.GoodsQuantity * (ProductCount - PrdQuantity)) / ProductCount - ISNULL(gdsQuantity,0) > 0 ' + @StrWhere + '
				GROUP BY SndH.ProcessID, SndH.ProcessNo, SndH.FiscalYear, SndH.SerialNo, SndD.GoodsID, SndH.BatchNo, 
					 SndH.DocDate, SndH.DocDesc, SndH.AcntCode, SndD.GoodsAmount '
	ELSE
		SET @StrSelect = '
		SELECT SndH.ProcessID, SndH.ProcessNo, SndH.FiscalYear, SndH.SerialNo, SndH.BatchNo, 
			   SndD.GoodsID, SndH.DocDate, SndH.DocDesc, SndH.AcntCode, SndD.GoodsAmount,
			   SUM((SndD.GoodsQuantity*(ProductCount-PrdQuantity))/ProductCount-ISNULL(gdsQuantity,0)) GoodsQuantity,
				[pub].[funGetGoodsName](SndD.GoodsID, ' + @LangID + ') GoodsName,
				[pub].[GetCodeName](SndH.AcntCode, ' + @LangID + ') AS AcntName
		FROM 
		(   
			SELECT a.ProcessID,a.ProcessNo,a.FiscalYear,a.SerialNo,a.ProductID,a.ProductCount ,ISNULL(PrdQuantity,0) PrdQuantity, 
				   BatchNo, DocDate, DocDesc, AcntCode--, ISNULL(c.GoodsAmount,0) GoodsAmount
			FROM inv.tblStorageDocsHdr a 
			Left JOIN 
			(
				SELECT BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, 
					   SUM(GoodsQuantity) PrdQuantity--, GoodsAmount
				FROM inv.tblStorageDocsDtl WHERE  ProcessID=80 '+ @StrDate +'
				GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo--, GoodsAmount
			 ) c ON a.ProcessID = c.BaseProcessID and a.ProcessNo=c.BaseProcessNo and 
					a.FiscalYear = c.BaseFiscalYear AND a.SerialNo=c.BaseSerialNo
			WHERE a.ProcessID = 70  AND a.BatchNo='''' and ProductCount>ISNULL(PrdQuantity,0) '+ @StrDate +'
		) SndH
		INNER JOIN inv.tblStorageDocsDtl SndD ON SndH.ProcessID=SndD.ProcessID and SndH.ProcessNo=SndD.ProcessNo and 
												 SndH.FiscalYear=SndD.FiscalYear and SndH.SerialNo=SndD.SerialNo
		LEFT JOIN 
		(
			 SELECT BaseProcessID,BaseProcessNo,BaseFiscalYear,BaseSerialNo,GoodsID,SUM(GoodsQuantity) gdsQuantity 
			 FROM inv.tblStorageDocsDtl 
			 WHERE  ProcessID=75  '+ @StrDate +'
			 GROUP BY BaseProcessID, BaseProcessNo, BaseFiscalYear, BaseSerialNo, GoodsID
		) SndRet ON SndH.ProcessID = SndRet.BaseProcessID and SndH.ProcessNo = SndRet.BaseProcessNo and 
					SndH.FiscalYear = SndRet.BaseFiscalYear and SndH.SerialNo = SndRet.BaseSerialNo AND
					SndD.GoodsID = SndRet.GoodsID
		WHERE (SndD.GoodsQuantity * (ProductCount - PrdQuantity)) / ProductCount - ISNULL(gdsQuantity,0) > 0 ' + @StrWhere + '
		GROUP BY SndH.ProcessID, SndH.ProcessNo, SndH.FiscalYear, SndH.SerialNo, SndD.GoodsID, SndH.BatchNo, 
			 SndH.DocDate, SndH.DocDesc, SndH.AcntCode, SndD.GoodsAmount '
	--------------------------------------------------------------

	-- RUN -------------------------------------------------------
	PRINT @StrSelect;
	EXEC sp_executesql @StrSelect;
	--------------------------------------------------------------
END
GO
