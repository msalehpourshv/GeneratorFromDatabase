USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Mostafavi
-- Create date   : 1403/06/11
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Returns Sum of UnPaied Cheques of a Person(s).
-- ----------------------------------------------
-- 
-- ==============================================
Create PROCEDURE [trs].[SpReceivableDocs_UnReceipt_SumForSaleOrder_Commercial_Non]
	@AcntCode	AS VarChar(20),
	@ProcessNo	AS TinyInt = 1,
	@DateFrom	AS Char(10),
	@StartTargetLayer tinyint,
	@LenTargetLayer tinyint,
	@PayTypeID as Varchar(10)
WITH ENCRYPTION
As
DECLARE @StrSQL		AS NVarChar(1000)
DECLARE @StrParams	AS NVarChar(500);
DECLARE @StrSelect	AS NVarChar(4000)
DECLARE @StrPrevDB		AS NVarChar(100)
DECLARE @StrDB			AS NVarChar(100)
DECLARE @f			AS float
Begin 

	Set NOCOUNT ON;
	set @f = 0
	-- اسناد دریافتنی موجود در صندوق و موجود در بانک
		SELECT	@f = IsNull(Sum(PD.Amount), 0)
	FROM	[trs].tblPayDtl AS PD
			INNER JOIN 
			(
				SELECT VolumeFiscalYear, VolumeRowNo,CreditCode  Credit
				,(
					SELECT	 Max(EventNo)
					FROM	[trs].tblPayDtl AS b
					WHERE	b.PayTypeID = @PayTypeID AND b.ProcessNo = @ProcessNo AND a.VolumeFiscalYear=b.VolumeFiscalYear and a.VolumeRowNo=b.VolumeRowNo
					GROUP BY VolumeFiscalYear, VolumeRowNo
				)EventNo
				 FROM	trs.tblPayDtl a
				 WHERE	ProcessID IN (1,10) AND 
						PayTypeID = @PayTypeID AND 
						SUBSTRING(CreditCode,@StartTargetLayer,@LenTargetLayer) = SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer)

			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID = @PayTypeID AND 
			PD.ProcessID IN (1, 10, 17, 20, 21, 23, 40) AND 
			PD.ProcessNo = @ProcessNo AND
			SUBSTRING(VOL.Credit,@StartTargetLayer,@LenTargetLayer) =SUBSTRING(@AcntCode,@StartTargetLayer,@LenTargetLayer)

	-- اسناد دریافتنی واگذار شده به اشخاص
	begin try
		--drop table ##t0 
		drop table ##t1 
		drop table ##t2 
		drop table ##t3 
	end try
	begin catch
	end catch

	--create table ##t0 (val bigint null)
	create table ##t1 (val bigint null)
	create table ##t2 (val bigint null)
	create table ##t3 (val bigint null)

	--insert into ##t0 (val)
	--exec sp_executesql @StrSelect

	IF LTRIM(@DateFrom)=''
		SELECT @DateFrom = SUBSTRING(pub.funFarsiDate(GetDate()),1,10)

	insert into ##t1
	exec [trs].[SpReceivableDocs_UnReceipt_SumInner] @AcntCode, @ProcessNo, @DateFrom, @StartTargetLayer, @LenTargetLayer

	------- 1 Year Before ----------------------------------
	SET @StrDB = db_name()
	Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

	If (@StrPrevDB <> '')
	begin
		set @StrSelect = '
		insert into ##t2
		exec ' + @StrPrevDB + '.[trs].[SpReceivableDocs_UnReceipt_SumInner] ''' + @AcntCode + ''',' + Str(@ProcessNo) + ',''' + @DateFrom + ''',' + Str(@StartTargetLayer) + ',' + Str(@LenTargetLayer)
		exec sp_executesql @StrSelect;
	end
	else
		goto RUN

	------- 2 Years Before ----------------------------------
	SET @StrDB = @StrPrevDB
	Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

	If (@StrPrevDB <> '') 
	begin
		set @StrSelect = '
		insert into ##t3
		exec ' + @StrPrevDB + '.[trs].[SpReceivableDocs_UnReceipt_SumInner] ''' + @AcntCode + ''',' + Str(@ProcessNo) + ',''' + @DateFrom + ''',' + Str(@StartTargetLayer) + ',' + Str(@LenTargetLayer)
		exec sp_executesql @StrSelect;
	end
	else
		goto RUN
	--------------------------------------------------------
RUN:

	select isnull(@f , 0) + ISNULL((select SUM(isnull(val, 0))  from ##t1),0) + ISNULL((select SUM(isnull(val, 0)) from ##t2 ),0) + ISNULL((select SUM(isnull(val, 0)) from ##t3),0)

End
GO
