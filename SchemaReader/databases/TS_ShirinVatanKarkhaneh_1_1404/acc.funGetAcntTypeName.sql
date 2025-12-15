USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\Ahmadnejad
-- Create Date   : 1387/11/17
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : 
-- Description	 : Returns AcntType Name
-- ==============================================
CREATE FUNCTION [acc].[funGetAcntTypeName]
(
	@AcntTypeCode	Int,
	@LanguageID		TinyInt
)
RETURNS NVarChar(100)
WITH ENCRYPTION
AS
BEGIN
	DECLARE @StrResult NVarChar(100)
	SET @StrResult = ''

	SELECT @StrResult = 
		CASE @AcntTypeCode
			WHEN 11	THEN 'دارائيهای جاری'
			WHEN 12	THEN 'دارائيهای غیرجاری'
			WHEN 21	THEN 'بدهيهای جاری'
			WHEN 22	THEN 'بدهيهای غیرجاری'
			WHEN 31	THEN 'حقوق صاحبان سهام'
			WHEN 41	THEN 'فروش و درآمدها'
			WHEN 51	THEN 'قیمت تمام شده کالاهای فروش رفته'
			WHEN 61	THEN 'هزینه های فعالیت'
			WHEN 62	THEN 'سایر هزینه ها و درآمدهای غیر عملیاتی'
			WHEN 81	THEN 'حسابهای جذب و انحراف'
			WHEN 91	THEN 'حسابهای انتظامي'
			WHEN 92	THEN 'طرف حسابهای انتظامي'
		END

	RETURN @StrResult
END
GO
