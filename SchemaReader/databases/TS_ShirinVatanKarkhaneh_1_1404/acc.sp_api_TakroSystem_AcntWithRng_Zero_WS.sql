USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
	-- =========== TS-QC:NOTOK ========================
-- Author        : Reza Moayed
-- Create date   : 1402-12-13
-- Viewed By	 : 
-- Last Modified : 
-- Description   : لیست کدهای Acnt با توجه به Part مشتری
-- =============================================
CREATE PROCEDURE [acc].[sp_api_TakroSystem_AcntWithRng_Zero_WS]

@Skip As NVARCHAR(50),
@MaxResultCount As NVARCHAR(50),
@Filter as NVARCHAR(50),
@UserID as NVARCHAR(50),
@AcntPart as TINYINT,
@IsAdmin as bit

WITH ENCRYPTION
 AS
BEGIN
	DECLARE @StrErrorMessage NVARCHAR(MAX)
	DECLARE @strQuery as NVARCHAR(Max)
	DECLARE @AcntPartConfig AS TINYINT 
	DECLARE @AcntLen AS INT 
BEGIN TRY

	select  @AcntPartConfig= ISNULL(SettingValue,0) from pub.tblSettings where SettingKey = 'AcntPartNumberForRemainCalculation'
	
	IF @AcntPartConfig < @AcntPart
	BEGIN
		SET @StrErrorMessage = N'پارت مشتریان درخواست شده موجود نیست'
		raiserror (@StrErrorMessage, 16, 1)
	END

	select  @AcntLen=Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9  FROM pub.tblCodeLayer
	WHERE TableName='acc.tblAcnt' AND PartNumber=str(@AcntPart)

	if @IsAdmin='False'

		set @strQuery=
		'
		select AcntCode,AcntName from acc.tblAcntDtl A
		where PartNumber=' + str(@AcntPart) + '

		  AND(
				(Select COUNT(*) from acc.tblAcntRng
					where acc.tblAcntRng.UserID=' + @UserID + ' AND AllowCodeView=1 AND acc.tblAcntRng.PartNumber=' + str(@AcntPart) + ' AND
					(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
				AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
				)>0 
			
				OR 
					(Select COUNT(*) from acc.tblAcntRng
					where  acc.tblAcntRng.UserID=' + @UserID + ' and acc.tblAcntRng.PartNumber=' + str(@AcntPart) + '  AND AccessAllCode=1)>0
			)
			
		  AND(
				(Select COUNT(*) from acc.tblAcntRng
					where acc.tblAcntRng.UserID=' + @UserID + ' AND AllowCodeView=0 AND acc.tblAcntRng.PartNumber=' + str(@AcntPart) + '  AND
					(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
				AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
				)=0 
				OR
				(Select COUNT(*) from acc.tblAcntRng
					where acc.tblAcntRng.UserID=-1 AND AllowCodeView=0 AND acc.tblAcntRng.PartNumber=' + str(@AcntPart) + '  AND
					(LEFT(A.AcntCode,LEN(acc.tblAcntRng.FromCode))>=LEFT(acc.tblAcntRng.FromCode,LEN(A.AcntCode))
				AND LEFT(A.AcntCode,LEN(acc.tblAcntRng.ToCode))<=LEFT(acc.tblAcntRng.ToCode,LEN(A.AcntCode)))
				)=0 
			)
		'
	else
		set @strQuery=
		'
		select AcntCode,AcntName from acc.tblAcntDtl A
		where PartNumber=' + str(@AcntPart) + '
		'
	

	if @Filter<>''
	begin
		set @strQuery=@strQuery+ ' AND( A.AcntName like ''%'+@Filter+'%'' OR A.AcntCode LIKE ''%'+@Filter+'%'')'
	End

	
	SET @strQuery=@strQuery+' 
		 ORDER BY A.AcntCode DESC
		 OFFSET ' +@Skip +' Rows 
		 FETCH NEXT ' +@MaxResultCount +' Rows ONLY '

	PRINT @strQuery
	EXEC sp_executesql @strQuery

END TRY
BEGIN CATCH


	Set @StrErrorMessage = ERROR_MESSAGE() 
	raiserror (@StrErrorMessage, 16, 1)

END CATCH

END		
GO
