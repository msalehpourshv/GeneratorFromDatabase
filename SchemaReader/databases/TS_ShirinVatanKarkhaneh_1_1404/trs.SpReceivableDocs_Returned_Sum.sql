USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : Ahmadnejad
-- Create date   : 86/12/19
-- Viewed By	 : 
-- Last Modified : 
-- Description	 : Returns sum of a persons Returned cheques.
-- ----------------------------------------------
-- 
-- ==============================================
Create PROCEDURE [trs].[SpReceivableDocs_Returned_Sum]
	@AcntCode AS VarChar(20),
	@ProcessNo AS TinyInt = 1,
	@IsConfirmed AS TINYINT=0
WITH ENCRYPTION
As
DECLARE @StrSQL		AS NVarChar(1000)
DECLARE @StrParams	AS NVarChar(500)
DECLARE @StrSelect	AS NVarChar(4000)
DECLARE @StrTmpl	AS NVarChar(4000)
DECLARE @StrDB		AS NVarChar(100)
DECLARE @StrPrevDB	AS NVarChar(100)
DECLARE @count	as int;
Begin 

	SET @StrSelect = N' '

	--Drop table  #tblPayDtl
	SELECT  IsNull((PD.Amount), 0) Amount,  IsNull((PD.VolumeFiscalYear), 0)  VolumeFiscalYear,   IsNull((PD.VolumeRowNo), 0) VolumeRowNo
	into #tblPayDtl
	FROM	 [trs].tblPayDtl PD
	where 1=0

	SET @StrTmpl = N'
	insert into #tblPayDtl
	SELECT  IsNull((PD.Amount), 0),  IsNull((PD.VolumeFiscalYear), 0)
	       ,   IsNull((PD.VolumeRowNo), 0)
	FROM	[@DBNAME].[trs].tblPayDtl AS PD  with (nolock)
			INNER JOIN 
			(
				SELECT A.*,CreditCode FROM 
				(
				SELECT	VolumeFiscalYear, VolumeRowNo, Max(EventNo) AS EventNo
				FROM	[@DBNAME].[trs].tblPayDtl AS PD2  with (nolock)
				WHERE	PD2.PayTypeID IN (6, 26) AND PD2.ProcessNo in (1,2)
				GROUP BY VolumeFiscalYear, VolumeRowNo
				)A , 
				(SELECT VolumeFiscalYear, VolumeRowNo,CreditCode
					 FROM	[@DBNAME].trs.tblPayDtl  with (nolock)
					 WHERE	ProcessID IN (1,10) AND 
							PayTypeID IN (6,26) AND 
							CreditCode = ''' + @AcntCode + '''
				) B
				WHERE A.VolumeFiscalYear=B.VolumeFiscalYear AND A.VolumeRowNo=B.VolumeRowNo 
			) VOL ON PD.VolumeFiscalYear = VOL.VolumeFiscalYear AND 
					 PD.VolumeRowNo = VOL.VolumeRowNo AND PD.EventNo = VOL.EventNo
	WHERE	PD.PayTypeID IN (6, 26) AND
			ProcessID IN (13, 18, 24) AND
			PD.ProcessNo in (1,2) AND
			VOL.CreditCode = ''' + @AcntCode + ''''
	IF  @IsConfirmed = 1
		SET @StrTmpl = @StrTmpl + ' AND IsConfirmed=''True'''
	IF  @IsConfirmed = 2
		SET @StrTmpl = @StrTmpl + ' AND IsConfirmed=''False'''
	

	SET @StrSelect = @StrSelect + Replace(@StrTmpl, '@DBNAME', db_name())

	-- Recursive to all years before current year --
	SET @StrDB = db_name()
	SET @StrPrevDB = @StrDB

	set @count = 1;

	While (@count < 3)
	Begin
		
		SET @StrDB = @StrPrevDB

		Exec [pub].[SpGetPrevDBName] @StrDB, @StrPrevDB OUTPUT

		If (@StrPrevDB = '') 
			BREAK

		SET @StrSelect = @StrSelect + '	' + Replace(@StrTmpl, '@DBNAME', @StrPrevDB)

		set @count = @count + 1;
	End
	
	Print @StrSelect;
	Exec sp_executesql @StrSelect;

	SELECT IsNull(Sum(Amount), 0) Sum, IsNull(Count(Amount), 0) Count 
	from (select  Distinct  * from 	 #tblPayDtl)aa
	
End
GO
