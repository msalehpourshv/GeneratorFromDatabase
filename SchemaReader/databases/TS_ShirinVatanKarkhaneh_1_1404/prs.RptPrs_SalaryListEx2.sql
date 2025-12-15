USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

--exec "TS_ArvinTabriz_1_1395"."prs"."RptPrs_SalaryListEx2";1 1, 5, 0, NULL, NULL, NULL, NULL, '1395/05/31', '000', N'1@9129@200111@0@1'
-- =========== TS-QC:UPDATED ====================
-- Author		 : TakroSystem\ZiA
-- Creation date : 1393/08/22
-- Viewed By	 : 
-- Last Modified : 
-- Last Modifier : TakroSystem\ZiA
-- Description	 : لیست حقوق و مزایای سالانه پرسنل
-- ==============================================
Create PROCEDURE [prs].[RptPrs_SalaryListEx2]
	@MonthFr	TinyInt=2,
	@MonthTo	TinyInt=2,
	@SelectedPrs	Int = 0,
	@DecreeTypeID	VarChar(20) = Null,
	@DepartmentID	VarChar(20) = Null,
	@WorkShopID		VarChar(20) = Null,
	@JobID			VarChar(20) = Null,
	@RemainDate		Char(10) = '9999/99/99',
	@RepOptions		VarChar(100) = '000',  -- bit array options
	@RepInfo		NVarChar(100) = '1@1@1'
WITH ENCRYPTION
AS 
declare @MonthFrName	nvarchar(100)
declare @MonthToName	nvarchar(100)


	--Close crs_Benefits
	--Deallocate crs_Benefits	
	--return 
	
	
set @MonthFrName = case 
when @MonthFr=1 then N'فروردین'
when @MonthFr=2 then N'اردیبهشت'
when @MonthFr=3 then N'خرداد'
when @MonthFr=4 then N'تیر'
when @MonthFr=5 then N'مرداد'
when @MonthFr=6 then N'شهریور'
when @MonthFr=7 then N'مهر'
when @MonthFr=8 then N'آبان'
when @MonthFr=9 then N'آذر'
when @MonthFr=10 then N'دی'
when @MonthFr=11 then N'بهمن'
when @MonthFr=12 then N'اسفند'
end

set @MonthToName = case 
when @MonthTo=1 then N'فروردین'
when @MonthTo=2 then N'اردیبهشت'
when @MonthTo=3 then N'خرداد'
when @MonthTo=4 then N'تیر'
when @MonthTo=5 then N'مرداد'
when @MonthTo=6 then N'شهریور'
when @MonthTo=7 then N'مهر'
when @MonthTo=8 then N'آبان'
when @MonthTo=9 then N'آذر'
when @MonthTo=10 then N'دی'
when @MonthTo=11 then N'بهمن'
when @MonthTo=12 then N'اسفند'
end
 

DECLARE @StrSelect	NVarChar(MAX);
DECLARE @StrFrom	NVarChar(MAX);
DECLARE @StrWhere	NVarChar(MAX);
DECLARE @StrWherePrs	NVarChar(MAX);
DECLARE @MonthCode	TinyInt;

DECLARE @ShowRemain		Bit; -- مانده حساب قبلی بیاید؟
DECLARE @ShowAll		Bit; -- مانده حساب قبلی بیاید؟
DECLARE @ShowNegSal		Bit; -- حقوق منفی نمایش داده شود؟
DECLARE @ShowCele320		Bit; -- نمایش عیدی
DECLARE @ShowCele325		Bit; -- نمایش پایانکار

DECLARE	@LangID			Char(1);
DECLARE	@SessionNo		Int; 
DECLARE	@Pay		Int; 
DECLARE	@ReportID		Int; 

declare @TitleOfBenefit	nvarchar(50)
declare @TitleOfBenefitType	int
declare @BenefitType	int
declare @PersonnelID	varchar(20)

DECLARE @StrFieldsSum1	NVarChar(4000);
DECLARE @StrFieldsSum2	NVarChar(4000);
DECLARE @StrFieldList1	NVarChar(4000);
DECLARE @StrFieldList2	NVarChar(4000);

DECLARE @BenefitName01	nvarchar(50);
DECLARE @BenefitName02	nvarchar(50);
DECLARE @BenefitName03	nvarchar(50);
DECLARE @BenefitName04	nvarchar(50);
DECLARE @BenefitName05	nvarchar(50);
DECLARE @BenefitName06	nvarchar(50);
DECLARE @BenefitName07	nvarchar(50);
DECLARE @BenefitName08	nvarchar(50);
DECLARE @BenefitName09	nvarchar(50);
DECLARE @BenefitName10	nvarchar(50);
DECLARE @BenefitName11	nvarchar(50);
DECLARE @BenefitName12	nvarchar(50);
DECLARE @BenefitName13	nvarchar(50);
DECLARE @BenefitName14	nvarchar(50);
DECLARE @BenefitName15	nvarchar(50);
DECLARE @BenefitName16	nvarchar(50);
DECLARE @BenefitName17	nvarchar(50);
DECLARE @BenefitName18	nvarchar(50);
DECLARE @BenefitName19	nvarchar(50);
DECLARE @BenefitName20	nvarchar(50);
DECLARE @BenefitName21	nvarchar(50);
DECLARE @BenefitName22	nvarchar(50);
DECLARE @BenefitName23	nvarchar(50);
DECLARE @BenefitName24	nvarchar(50);
DECLARE @BenefitName25	nvarchar(50);
DECLARE @BenefitName26	nvarchar(50);
DECLARE @BenefitName27	nvarchar(50);
DECLARE @BenefitName28	nvarchar(50);
DECLARE @BenefitName29	nvarchar(50);
DECLARE @BenefitName30	nvarchar(50);
DECLARE @BenefitName31	nvarchar(50);
DECLARE @BenefitName32	nvarchar(50);
DECLARE @BenefitName33	nvarchar(50);
DECLARE @BenefitName34	nvarchar(50);
DECLARE @BenefitName35	nvarchar(50);
DECLARE @BenefitName36	nvarchar(50);
DECLARE @BenefitName37	nvarchar(50);
DECLARE @BenefitName38	nvarchar(50);
DECLARE @BenefitName39	nvarchar(50);
DECLARE @BenefitName40	nvarchar(50);
DECLARE @BenefitName41	nvarchar(50);
DECLARE @BenefitName42	nvarchar(50);
DECLARE @BenefitName43	nvarchar(50);
DECLARE @BenefitName44	nvarchar(50);
DECLARE @BenefitName45	nvarchar(50);
DECLARE @BenefitName46	nvarchar(50);
DECLARE @BenefitName47	nvarchar(50);
DECLARE @BenefitName48	nvarchar(50);
DECLARE @BenefitName49	nvarchar(50);
DECLARE @BenefitName50	nvarchar(50);
DECLARE @BenefitName51	nvarchar(50);
DECLARE @BenefitName52	nvarchar(50);
DECLARE @BenefitName53	nvarchar(50);
DECLARE @BenefitName54	nvarchar(50);
DECLARE @BenefitName55	nvarchar(50);
DECLARE @BenefitName56	nvarchar(50);
DECLARE @BenefitName57	nvarchar(50);
DECLARE @BenefitName58	nvarchar(50);
DECLARE @BenefitName59	nvarchar(50);
DECLARE @BenefitName60	nvarchar(50);
DECLARE @BenefitName100	nvarchar(50);
DECLARE @BenefitName101	nvarchar(50);

DECLARE @DeductName01	nvarchar(50);
DECLARE @DeductName02	nvarchar(50);
DECLARE @DeductName03	nvarchar(50);
DECLARE @DeductName04	nvarchar(50);
DECLARE @DeductName05	nvarchar(50);
DECLARE @DeductName06	nvarchar(50);
DECLARE @DeductName07	nvarchar(50);
DECLARE @DeductName08	nvarchar(50);
DECLARE @DeductName09	nvarchar(50);
DECLARE @DeductName10	nvarchar(50);
DECLARE @DeductName11	nvarchar(50);
DECLARE @DeductName12	nvarchar(50);
DECLARE @DeductName13	nvarchar(50);
DECLARE @DeductName14	nvarchar(50);
DECLARE @DeductName15	nvarchar(50);
DECLARE @DeductName16	nvarchar(50);
DECLARE @DeductName17	nvarchar(50);
DECLARE @DeductName18	nvarchar(50);		
DECLARE @DeductName19	nvarchar(50);		
DECLARE @DeductName20	nvarchar(50);		
DECLARE @DeductName21	nvarchar(50);		
DECLARE @DeductName22	nvarchar(50);		
DECLARE @DeductName23	nvarchar(50);		
DECLARE @DeductName24	nvarchar(50);		
DECLARE @DeductName25	nvarchar(50);		
DECLARE @DeductName26	nvarchar(50);		
DECLARE @DeductName27	nvarchar(50);		
DECLARE @DeductName28	nvarchar(50);		
DECLARE @DeductName29	nvarchar(50);		
DECLARE @DeductName30	nvarchar(50);		
DECLARE @DeductName31	nvarchar(50);		
DECLARE @DeductName32	nvarchar(50);		
DECLARE @DeductName33	nvarchar(50);		
DECLARE @DeductName34	nvarchar(50);		
DECLARE @DeductName35	nvarchar(50);		
DECLARE @DeductName36	nvarchar(50);		
DECLARE @DeductName37	nvarchar(50);		
DECLARE @DeductName38	nvarchar(50);		
DECLARE @DeductName39	nvarchar(50);		
DECLARE @DeductName40	nvarchar(50);		
DECLARE @DeductName41	nvarchar(50);		
DECLARE @DeductName42	nvarchar(50);		
DECLARE @DeductName43	nvarchar(50);		
DECLARE @DeductName44	nvarchar(50);		
DECLARE @DeductName45	nvarchar(50);		
DECLARE @DeductName46	nvarchar(50);		
DECLARE @DeductName47	nvarchar(50);		
DECLARE @DeductName48	nvarchar(50);		
DECLARE @DeductName49	nvarchar(50);		
DECLARE @DeductName50	nvarchar(50);		
DECLARE @DeductName51	nvarchar(50);		
DECLARE @DeductName52	nvarchar(50);		
DECLARE @DeductName53	nvarchar(50);		
DECLARE @DeductName54	nvarchar(50);		
DECLARE @DeductName55	nvarchar(50);		
DECLARE @DeductName56	nvarchar(50);		
DECLARE @DeductName57	nvarchar(50);		
DECLARE @DeductName58	nvarchar(50);		
DECLARE @DeductName59	nvarchar(50);		
DECLARE @DeductName60	nvarchar(50);		
DECLARE @DeductName100	nvarchar(50);		
DECLARE @DeductName101	nvarchar(50);		
DECLARE @SelectedInsur	Int ;
DECLARE @OrderField	nvarchar(50);		
declare @ShowDtlBasePay	int 


Begin 
	--============== S T A R T  C O D E =======================================

	SET NOCOUNT ON;

	---- Init ------------------------------------------
	IF (@RepInfo		Is Null)	SET @RepInfo = '1@1@1'
	IF (@SelectedPrs	Is Null)	SET @SelectedPrs = 0

	--SET @ShowRemain	= Substring(@RepOptions, 1, 1)
	--SET @ShowNegSal	= Substring(@RepOptions, 2, 1)
	--SET @ShowAll	= Substring(@RepOptions, 3, 1)
	
	SET @ShowRemain		= pub.funSplitString(@RepOptions, '@', 1);
	SET @ShowNegSal		= pub.funSplitString(@RepOptions, '@', 2);
	SET @Pay			= pub.funSplitString(@RepOptions, '@', 3);
	SET @ShowAll		= pub.funSplitString(@RepOptions, '@', 4);
	SET @ShowCele320	= pub.funSplitString(@RepOptions, '@', 5);
	SET @ShowCele325	= pub.funSplitString(@RepOptions, '@', 6);


--select @ShowRemain,@ShowNegSal,@Pay,@ShowAll

	SET @LangID		= pub.funSplitString(@RepInfo, '@', 1);
	SET @SessionNo	= pub.funSplitString(@RepInfo, '@', 2);
	SET @ReportID	= pub.funSplitString(@RepInfo, '@', 3);
	SET @SelectedInsur	= pub.funSplitString(@RepInfo, '@', 6);
	SET @OrderField	= pub.funSplitString(@RepInfo, '@', 7);
	SET @ShowDtlBasePay	= pub.funSplitString(@RepInfo, '@', 8);

	IF @OrderField = ''
		SET @OrderField=' T.PersonnelID '

	BEGIN TRY
		DROP TABLE #tbl_RptPrs_SalaryList_B
		DROP TABLE #tbl_RptPrs_SalaryList_M		
	END TRY
	BEGIN CATCH
	END CATCH

	CREATE TABLE #tbl_RptPrs_SalaryList_B
	(
		PersonnelID		NVarChar(100) COLLATE ARABIC_CS_AS
	);

	CREATE TABLE #tbl_RptPrs_SalaryList_M
	(
		PersonnelID		NVarChar(100) COLLATE ARABIC_CS_AS,
		BenefitName		NVarChar(50) COLLATE ARABIC_CS_AS,
		BenefitAmount	Float,
		BenefitTime		varchar(50),
		BenefitUnit		nvarchar(30),
		BenefitType		Int
	);
 			
	CREATE TABLE #tbl_RptPrs_SalaryList_R
	(
		PersonnelID		varchar(20) collate arabic_cs_as not null,
		BenefitName01	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName02	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName03	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName04	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName05	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName06	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName07	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName08	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName09	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName10	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName11	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName12	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName13	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName14	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName15	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName16	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName17	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName18	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName19	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName20	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName21	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName22	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName23	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName24	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName25	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName26	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName27	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName28	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName29	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName30	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName31	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName32	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName33	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName34	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName35	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName36	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName37	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName38	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName39	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName40	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName41	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName42	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName43	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName44	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName45	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName46	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName47	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName48	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName49	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName50	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName51	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName52	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName53	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName54	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName55	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName56	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName57	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName58	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName59	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName60	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName100	nvarchar(50) COLLATE ARABIC_CS_AS null,
		BenefitName101	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		
		DeductName01	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName02	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName03	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName04	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName05	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName06	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName07	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName08	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName09	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName10	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName11	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName12	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName13	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName14	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName15	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName16	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName17	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName18	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName19	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName20	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName21	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName22	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName23	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName24	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName25	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName26	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName27	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName28	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName29	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName30	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName31	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName32	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName33	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName34	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName35	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName36	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName37	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName38	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName39	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName40	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName41	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName42	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName43	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName44	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName45	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName46	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName47	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName48	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName49	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName50	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName51	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName52	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName53	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName54	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName55	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName56	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName57	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName58	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName59	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName60	nvarchar(50) COLLATE ARABIC_CS_AS null,
		DeductName100	nvarchar(50) COLLATE ARABIC_CS_AS null,		
		DeductName101	nvarchar(50) COLLATE ARABIC_CS_AS null,		
			
		BenefitAmount01	float null,
		BenefitAmount02	float null,
		BenefitAmount03	float null,
		BenefitAmount04	float null,
		BenefitAmount05	float null,
		BenefitAmount06	float null,
		BenefitAmount07	float null,
		BenefitAmount08	float null,
		BenefitAmount09	float null,
		BenefitAmount10	float null,
		BenefitAmount11	float null,
		BenefitAmount12	float null,
		BenefitAmount13	float null,
		BenefitAmount14	float null,
		BenefitAmount15	float null,
		BenefitAmount16	float null,
		BenefitAmount17	float null,
		BenefitAmount18	float null,
		BenefitAmount19	float null,
		BenefitAmount20	float null,
		BenefitAmount21	float null,
		BenefitAmount22	float null,
		BenefitAmount23	float null,
		BenefitAmount24	float null,
		BenefitAmount25	float null,
		BenefitAmount26	float null,
		BenefitAmount27	float null,
		BenefitAmount28	float null,
		BenefitAmount29	float null,
		BenefitAmount30	float null,
		BenefitAmount31	float null,
		BenefitAmount32	float null,
		BenefitAmount33	float null,
		BenefitAmount34	float null,
		BenefitAmount35	float null,
		BenefitAmount36	float null,
		BenefitAmount37	float null,
		BenefitAmount38	float null,
		BenefitAmount39	float null,
		BenefitAmount40	float null,
		BenefitAmount41	float null,
		BenefitAmount42	float null,
		BenefitAmount43	float null,
		BenefitAmount44	float null,
		BenefitAmount45	float null,
		BenefitAmount46	float null,
		BenefitAmount47	float null,
		BenefitAmount48	float null,
		BenefitAmount49	float null,
		BenefitAmount50	float null,
		BenefitAmount51	float null,
		BenefitAmount52	float null,
		BenefitAmount53	float null,
		BenefitAmount54	float null,
		BenefitAmount55	float null,
		BenefitAmount56	float null,
		BenefitAmount57	float null,
		BenefitAmount58	float null,
		BenefitAmount59	float null,
		BenefitAmount60	float null,
		BenefitAmount100	float null,
		BenefitAmount101	float null,

		BenefitDesc01	Nvarchar(50) null,
		BenefitDesc02	Nvarchar(50) null,
		BenefitDesc03	Nvarchar(50) null,
		BenefitDesc04	Nvarchar(50) null,
		BenefitDesc05	Nvarchar(50) null,
		BenefitDesc06	Nvarchar(50) null,
		BenefitDesc07	Nvarchar(50) null,
		BenefitDesc08	Nvarchar(50) null,
		BenefitDesc09	Nvarchar(50) null,
		BenefitDesc10	Nvarchar(50) null,
		BenefitDesc11	Nvarchar(50) null,
		BenefitDesc12	Nvarchar(50) null,
		BenefitDesc13	Nvarchar(50) null,
		BenefitDesc14	Nvarchar(50) null,
		BenefitDesc15	Nvarchar(50) null,
		BenefitDesc16	Nvarchar(50) null,
		BenefitDesc17	Nvarchar(50) null,
		BenefitDesc18	Nvarchar(50) null,
		BenefitDesc19	Nvarchar(50) null,
		BenefitDesc20	Nvarchar(50) null,
		BenefitDesc21	Nvarchar(50) null,
		BenefitDesc22	Nvarchar(50) null,
		BenefitDesc23	Nvarchar(50) null,
		BenefitDesc24	Nvarchar(50) null,
		BenefitDesc25	Nvarchar(50) null,
		BenefitDesc26	Nvarchar(50) null,
		BenefitDesc27	Nvarchar(50) null,
		BenefitDesc28	Nvarchar(50) null,
		BenefitDesc29	Nvarchar(50) null,
		BenefitDesc30	Nvarchar(50) null,
		BenefitDesc31	Nvarchar(50) null,
		BenefitDesc32	Nvarchar(50) null,
		BenefitDesc33	Nvarchar(50) null,
		BenefitDesc34	Nvarchar(50) null,
		BenefitDesc35	Nvarchar(50) null,
		BenefitDesc36	Nvarchar(50) null,
		BenefitDesc37	Nvarchar(50) null,
		BenefitDesc38	Nvarchar(50) null,
		BenefitDesc39	Nvarchar(50) null,
		BenefitDesc40	Nvarchar(50) null,
		BenefitDesc41	Nvarchar(50) null,
		BenefitDesc42	Nvarchar(50) null,
		BenefitDesc43	Nvarchar(50) null,
		BenefitDesc44	Nvarchar(50) null,
		BenefitDesc45	Nvarchar(50) null,
		BenefitDesc46	Nvarchar(50) null,
		BenefitDesc47	Nvarchar(50) null,
		BenefitDesc48	Nvarchar(50) null,
		BenefitDesc49	Nvarchar(50) null,
		BenefitDesc50	Nvarchar(50) null,
		BenefitDesc51	Nvarchar(50) null,
		BenefitDesc52	Nvarchar(50) null,
		BenefitDesc53	Nvarchar(50) null,
		BenefitDesc54	Nvarchar(50) null,
		BenefitDesc55	Nvarchar(50) null,
		BenefitDesc56	Nvarchar(50) null,
		BenefitDesc57	Nvarchar(50) null,
		BenefitDesc58	Nvarchar(50) null,
		BenefitDesc59	Nvarchar(50) null,
		BenefitDesc60	Nvarchar(50) null,
		BenefitDesc100	Nvarchar(50) null,
		BenefitDesc101	Nvarchar(50) null,
		
		DeductAmount01	float null,
		DeductAmount02	float null,
		DeductAmount03	float null,
		DeductAmount04	float null,
		DeductAmount05	float null,
		DeductAmount06	float null,
		DeductAmount07	float null,
		DeductAmount08	float null,
		DeductAmount09	float null,
		DeductAmount10	float null,
		DeductAmount11	float null,
		DeductAmount12	float null,
		DeductAmount13	float null,
		DeductAmount14	float null,
		DeductAmount15	float null,
		DeductAmount16	float null,
		DeductAmount17	float null,
		DeductAmount18	float null,	
		DeductAmount19	float null,		
		DeductAmount20	float null,		
		DeductAmount21	float null,		
		DeductAmount22	float null,		
		DeductAmount23	float null,		
		DeductAmount24	float null,		
		DeductAmount25	float null,		
		DeductAmount26	float null,		
		DeductAmount27	float null,		
		DeductAmount28	float null,		
		DeductAmount29	float null,		
		DeductAmount30	float null,		
		DeductAmount31	float null,
		DeductAmount32	float null,
		DeductAmount33	float null,
		DeductAmount34	float null,
		DeductAmount35	float null,
		DeductAmount36	float null,
		DeductAmount37	float null,
		DeductAmount38	float null,
		DeductAmount39	float null,
		DeductAmount40	float null,
		DeductAmount41	float null,
		DeductAmount42	float null,
		DeductAmount43	float null,
		DeductAmount44	float null,
		DeductAmount45	float null,
		DeductAmount46	float null,
		DeductAmount47	float null,
		DeductAmount48	float null,	
		DeductAmount49	float null,		
		DeductAmount50	float null,		
		DeductAmount51	float null,		
		DeductAmount52	float null,		
		DeductAmount53	float null,		
		DeductAmount54	float null,		
		DeductAmount55	float null,		
		DeductAmount56	float null,		
		DeductAmount57	float null,		
		DeductAmount58	float null,		
		DeductAmount59	float null,		
		DeductAmount60	float null,		
		DeductAmount100	float null,		
		DeductAmount101	float null,

		DeductDesc01	Nvarchar(50) null,
		DeductDesc02	Nvarchar(50) null,
		DeductDesc03	Nvarchar(50) null,
		DeductDesc04	Nvarchar(50) null,
		DeductDesc05	Nvarchar(50) null,
		DeductDesc06	Nvarchar(50) null,
		DeductDesc07	Nvarchar(50) null,
		DeductDesc08	Nvarchar(50) null,
		DeductDesc09	Nvarchar(50) null,
		DeductDesc10	Nvarchar(50) null,
		DeductDesc11	Nvarchar(50) null,
		DeductDesc12	Nvarchar(50) null,
		DeductDesc13	Nvarchar(50) null,
		DeductDesc14	Nvarchar(50) null,
		DeductDesc15	Nvarchar(50) null,
		DeductDesc16	Nvarchar(50) null,
		DeductDesc17	Nvarchar(50) null,
		DeductDesc18	Nvarchar(50) null,
		DeductDesc19	Nvarchar(50) null,
		DeductDesc20	Nvarchar(50) null,
		DeductDesc21	Nvarchar(50) null,
		DeductDesc22	Nvarchar(50) null,
		DeductDesc23	Nvarchar(50) null,
		DeductDesc24	Nvarchar(50) null,
		DeductDesc25	Nvarchar(50) null,
		DeductDesc26	Nvarchar(50) null,
		DeductDesc27	Nvarchar(50) null,
		DeductDesc28	Nvarchar(50) null,
		DeductDesc29	Nvarchar(50) null,
		DeductDesc30	Nvarchar(50) null,
		DeductDesc31	Nvarchar(50) null,
		DeductDesc32	Nvarchar(50) null,
		DeductDesc33	Nvarchar(50) null,
		DeductDesc34	Nvarchar(50) null,
		DeductDesc35	Nvarchar(50) null,
		DeductDesc36	Nvarchar(50) null,
		DeductDesc37	Nvarchar(50) null,
		DeductDesc38	Nvarchar(50) null,
		DeductDesc39	Nvarchar(50) null,
		DeductDesc40	Nvarchar(50) null,
		DeductDesc41	Nvarchar(50) null,
		DeductDesc42	Nvarchar(50) null,
		DeductDesc43	Nvarchar(50) null,
		DeductDesc44	Nvarchar(50) null,
		DeductDesc45	Nvarchar(50) null,
		DeductDesc46	Nvarchar(50) null,
		DeductDesc47	Nvarchar(50) null,
		DeductDesc48	Nvarchar(50) null,
		DeductDesc49	Nvarchar(50) null,
		DeductDesc50	Nvarchar(50) null,
		DeductDesc51	Nvarchar(50) null,
		DeductDesc52	Nvarchar(50) null,
		DeductDesc53	Nvarchar(50) null,
		DeductDesc54	Nvarchar(50) null,
		DeductDesc55	Nvarchar(50) null,
		DeductDesc56	Nvarchar(50) null,
		DeductDesc57	Nvarchar(50) null,
		DeductDesc58	Nvarchar(50) null,
		DeductDesc59	Nvarchar(50) null,
		DeductDesc60	Nvarchar(50) null,
		DeductDesc100	Nvarchar(50) null,
		DeductDesc101	Nvarchar(50) null
	)
	----------------------------------------------------
	
	SET @StrWhere = 'S.MonthCode >= ' + LTrim(Str(@MonthFr)) +' and S.MonthCode <= ' + LTrim(Str(@MonthTo))
	SET @StrWherePrs = 'MonthCode >= ' + LTrim(Str(@MonthFr)) +' and MonthCode <= ' + LTrim(Str(@MonthTo))
	
	IF (@SelectedPrs > 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedPrs, 'S.PersonnelID')

	If (@DecreeTypeID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DecreeTypeID = ''' + @DecreeTypeID + ''''
	If (@WorkShopID	Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.WorkShopID = ''' + @WorkShopID + ''''
	If (@DepartmentID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.DepartmentID LIKE ''' + @DepartmentID + '%'''
	If (@JobID Is Not Null)
		SET @StrWhere = @StrWhere + ' AND D.JobID = ''' + @JobID + ''''
	IF (@SelectedInsur <> 0)
		SET @StrWhere = @StrWhere + ' AND ' + pub.funGetFilterString(@SessionNo, @ReportID, @SelectedInsur, 'D.InsuranceTypeID') 
		
	--SET @StrWhere = @StrWhere + ' AND PAD.IsDefault = 1 '
		
	--------------------------------------------------------------------

	INSERT INTO #tbl_RptPrs_SalaryList_B(PersonnelID)
	SELECT distinct S.PersonnelID
	FROM  prs.tblFunctionsDtl F 
		INNER JOIN prs.tblSalaryCalculation S ON F.PersonnelID = S.PersonnelID AND F.MonthCode = S.MonthCode
		INNER JOIN prs.tblDecreeHdr D ON S.DecreeSerialNo = D.SerialNo AND S.PersonnelID = D.PersonnelID AND F.PersonnelID = D.PersonnelID
	WHERE S.MonthCode >= @MonthFr  and S.MonthCode <= @MonthTo  
	ORDER BY S.PersonnelID

	DECLARE @MyRepOptions VarChar(10)

	IF (@ShowRemain = 1) 
		SET @MyRepOptions = '11'
	ELSE
		SET @MyRepOptions = '01'

IF (@ShowCele320= 1) 
SET @MyRepOptions = @MyRepOptions +'1'
else
SET @MyRepOptions = @MyRepOptions +'0'

IF (@ShowCele325= 1) 
SET @MyRepOptions = @MyRepOptions +'1'
else
SET @MyRepOptions = @MyRepOptions +'0'

IF (@ShowAll= 1) 
SET @MyRepOptions = @MyRepOptions +'11011'
else
SET @MyRepOptions = @MyRepOptions +'11010'

--select @MonthCode, @SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, null, @MyRepOptions, @RepInfo
--EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthFr, @SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, null, @MyRepOptions, @RepInfo
	 	
set @MonthCode  = @MonthFr 
while @MonthCode <= @MonthTo
begin

	SET @RepInfo	= pub.funSplitString(@RepInfo, '@', 1)	
				+'@'+ pub.funSplitString(@RepInfo, '@', 2)	
				+'@'+ pub.funSplitString(@RepInfo, '@', 3)	
				+'@'+ pub.funSplitString(@RepInfo, '@', 4)	
				+'@'+ pub.funSplitString(@RepInfo, '@', 5)
				+'@'--6
				+'@'--7
				+'@'+ ltrim(str(@ShowDtlBasePay))--8;

	INSERT INTO #tbl_RptPrs_SalaryList_M
	EXEC [prs].[RptPrs_SalaryBillsDtl] @MonthCode, @SelectedPrs, @DecreeTypeID, @DepartmentID, @WorkShopID, @JobID, @RemainDate, null, @MyRepOptions, @RepInfo

		IF (@ShowNegSal = 1) 
		Begin
				Delete  from #tbl_RptPrs_SalaryList_M
				where PersonnelID in (
				select PersonnelID From 
				(Select PersonnelID,
				ISNULL(SUM(CASE WHEN (M.BenefitType>0) THEN M.BenefitAmount ELSE 0 END), 0) BenefitSum,
				ISNULL(SUM(CASE WHEN (M.BenefitType <0) THEN M.BenefitAmount ELSE 0 END), 0) DeductionSum
				From #tbl_RptPrs_SalaryList_M M				
				Group By PersonnelID
				) T
				Where (T.BenefitSum - T.DeductionSum) < @Pay
				)
		end
		
	set @MonthCode = @MonthCode +1
end

--برای نمایش تمامی مزایا و کسورات بدون داشتن مبالغ
-- insert into  #tbl_RptPrs_SalaryList_M	
--select '', BenefitName ,  0, 0,0,BenefitType from prs.tblBenefitOrder 
--where BenefitName not in (  SELECT  BenefitName   FROM      #tbl_RptPrs_SalaryList_M	  )

 declare @BenefitOrder int
	-------------------------------------------
	
	declare crs_Benefits cursor for
	 	
		select distinct ltrim(rtrim(BenefitName)),BenefitType,BenefitOrder
		from  prs.tblBenefitOrder   
		where BenefitType >0
		and BenefitName in (  SELECT  BenefitName   FROM      #tbl_RptPrs_SalaryList_M	  )
		ORDER BY BenefitOrder DESC, ltrim(rtrim(BenefitName))		
		
	Open crs_Benefits
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName01 = @TitleOfBenefit 
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName02 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName03 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName04 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName05 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName06 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName07 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName08 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName09 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName10 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName11 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName12 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName13 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName14 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName15 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName16 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName17 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName18 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName19 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName20 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName21 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName22 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName23 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName24 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName25 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName26 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName27 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName28 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName29 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName30 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName31 = @TitleOfBenefit 
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName32 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName33 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName34 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName35 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName36 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName37 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName38 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName39 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName40 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName41 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName42 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName43 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName44 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName45 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName46 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName47 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName48 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName49 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName50 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName51 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName52 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName53 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName54 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName55 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName56 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName57 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName58 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName59 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @BenefitName60 = @TitleOfBenefit

	Close crs_Benefits
	Deallocate crs_Benefits	
------------------------------------------
		
	declare crs_Benefits cursor for
	 	select distinct ltrim(rtrim(BenefitName)),BenefitType,BenefitOrder
		from  prs.tblBenefitOrder   
		where BenefitType <0
			and BenefitName in (  SELECT  BenefitName   FROM      #tbl_RptPrs_SalaryList_M	  )
		ORDER BY BenefitOrder DESC, ltrim(rtrim(BenefitName))
		
	Open crs_Benefits
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName01 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName02 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName03 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName04 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName05 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName06 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName07 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName08 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName09 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName10 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName11 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName12 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName13 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName14 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName15 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName16 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName17 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName18 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName19 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName20 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName21 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName22 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName23 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName24 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName25 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName26 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName27 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName28 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName29 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName30 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName31 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName32 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName33 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName34 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName35 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName36 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName37 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName38 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName39 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName40 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName41 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName42 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName43 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName44 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName45 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName46 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName47 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName48 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName49 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName50 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName51 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName52 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName53 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName54 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName55 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName56 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName57 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName58 = @TitleOfBenefit
	
	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName59 = @TitleOfBenefit

	FETCH NEXT FROM crs_Benefits INTO @TitleOfBenefit,@TitleOfBenefitType,@BenefitOrder
	if (@@FETCH_STATUS=0) set @DeductName60 = @TitleOfBenefit
	
	Close crs_Benefits
	Deallocate crs_Benefits	
	
	
	set @BenefitName100 = 'سایر مزایا'
	set @BenefitName101 = 'کارکرد'
	set @DeductName100 = 'سایر کسورات'
	
	--------------------------------------------
	
	declare crs_Benefits cursor for
		select distinct PersonnelID
		from #tbl_RptPrs_SalaryList_M
		order by PersonnelID desc
		
	Open crs_Benefits
	FETCH NEXT FROM crs_Benefits INTO @PersonnelID	
		
	while (@@FETCH_STATUS=0)
	begin
		insert into #tbl_RptPrs_SalaryList_R(
			PersonnelID,
			BenefitName01,BenefitName02,BenefitName03,BenefitName04,BenefitName05,
			BenefitName06,BenefitName07,BenefitName08,BenefitName09,BenefitName10,
			BenefitName11,BenefitName12,BenefitName13,BenefitName14,BenefitName15,
			BenefitName16,BenefitName17,BenefitName18,BenefitName19,BenefitName20,
			BenefitName21,BenefitName22,BenefitName23,BenefitName24,BenefitName25,
			BenefitName26,BenefitName27,BenefitName28,BenefitName29,BenefitName30,
			BenefitName31,BenefitName32,BenefitName33,BenefitName34,BenefitName35,
			BenefitName36,BenefitName37,BenefitName38,BenefitName39,BenefitName40,
			BenefitName41,BenefitName42,BenefitName43,BenefitName44,BenefitName45,
			BenefitName46,BenefitName47,BenefitName48,BenefitName49,BenefitName50,
			BenefitName51,BenefitName52,BenefitName53,BenefitName54,BenefitName55,
			BenefitName56,BenefitName57,BenefitName58,BenefitName59,BenefitName60,
			BenefitName100,
			BenefitName101,
			DeductName01,DeductName02,DeductName03,DeductName04,DeductName05,
			DeductName06,DeductName07,DeductName08,DeductName09,DeductName10,
			DeductName11,DeductName12,DeductName13,DeductName14,DeductName15,
			DeductName16,DeductName17,DeductName18,DeductName19,DeductName20,
			DeductName21,DeductName22,DeductName23,DeductName24,DeductName25,
			DeductName26,DeductName27,DeductName28,DeductName29,DeductName30,
			DeductName31,DeductName32,DeductName33,DeductName34,DeductName35,
			DeductName36,DeductName37,DeductName38,DeductName39,DeductName40,
			DeductName41,DeductName42,DeductName43,DeductName44,DeductName45,
			DeductName46,DeductName47,DeductName48,DeductName49,DeductName50,
			DeductName51,DeductName52,DeductName53,DeductName54,DeductName55,
			DeductName56,DeductName57,DeductName58,DeductName59,DeductName60,
			DeductName100,
			DeductName101,
			BenefitAmount01,BenefitAmount02,BenefitAmount03,BenefitAmount04,BenefitAmount05,
			BenefitAmount06,BenefitAmount07,BenefitAmount08,BenefitAmount09,BenefitAmount10,
			BenefitAmount11,BenefitAmount12,BenefitAmount13,BenefitAmount14,BenefitAmount15,
			BenefitAmount16,BenefitAmount17,BenefitAmount18,BenefitAmount19,BenefitAmount20,
			BenefitAmount21,BenefitAmount22,BenefitAmount23,BenefitAmount24,BenefitAmount25,
			BenefitAmount26,BenefitAmount27,BenefitAmount28,BenefitAmount29,BenefitAmount30,
			BenefitAmount31,BenefitAmount32,BenefitAmount33,BenefitAmount34,BenefitAmount35,
			BenefitAmount36,BenefitAmount37,BenefitAmount38,BenefitAmount39,BenefitAmount40,
			BenefitAmount41,BenefitAmount42,BenefitAmount43,BenefitAmount44,BenefitAmount45,
			BenefitAmount46,BenefitAmount47,BenefitAmount48,BenefitAmount49,BenefitAmount50,
			BenefitAmount51,BenefitAmount52,BenefitAmount53,BenefitAmount54,BenefitAmount55,
			BenefitAmount56,BenefitAmount57,BenefitAmount58,BenefitAmount59,BenefitAmount60,
			BenefitAmount100,
			BenefitAmount101,			
			DeductAmount01,DeductAmount02,DeductAmount03,DeductAmount04,DeductAmount05,
			DeductAmount06,DeductAmount07,DeductAmount08,DeductAmount09,DeductAmount10,
			DeductAmount11,DeductAmount12,DeductAmount13,DeductAmount14,DeductAmount15,
			DeductAmount16,DeductAmount17,DeductAmount18,DeductAmount19,DeductAmount20,
			DeductAmount21,DeductAmount22,DeductAmount23,DeductAmount24,DeductAmount25,
			DeductAmount26,DeductAmount27,DeductAmount28,DeductAmount29,DeductAmount30,
			DeductAmount31,DeductAmount32,DeductAmount33,DeductAmount34,DeductAmount35,
			DeductAmount36,DeductAmount37,DeductAmount38,DeductAmount39,DeductAmount40,
			DeductAmount41,DeductAmount42,DeductAmount43,DeductAmount44,DeductAmount45,
			DeductAmount46,DeductAmount47,DeductAmount48,DeductAmount49,DeductAmount50,
			DeductAmount51,DeductAmount52,DeductAmount53,DeductAmount54,DeductAmount55,
			DeductAmount56,DeductAmount57,DeductAmount58,DeductAmount59,DeductAmount60,
			DeductAmount100,
			DeductAmount101
			)
		values(
			@PersonnelID,
			@BenefitName01,@BenefitName02,@BenefitName03,@BenefitName04,@BenefitName05,
			@BenefitName06,@BenefitName07,@BenefitName08,@BenefitName09,@BenefitName10,
			@BenefitName11,@BenefitName12,@BenefitName13,@BenefitName14,@BenefitName15,
			@BenefitName16,@BenefitName17,@BenefitName18,@BenefitName19,@BenefitName20,
			@BenefitName21,@BenefitName22,@BenefitName23,@BenefitName24,@BenefitName25,
			@BenefitName26,@BenefitName27,@BenefitName28,@BenefitName29,@BenefitName30,
			@BenefitName31,@BenefitName32,@BenefitName33,@BenefitName34,@BenefitName35,
			@BenefitName36,@BenefitName37,@BenefitName38,@BenefitName39,@BenefitName40,
			@BenefitName41,@BenefitName42,@BenefitName43,@BenefitName44,@BenefitName45,
			@BenefitName46,@BenefitName47,@BenefitName48,@BenefitName49,@BenefitName50,
			@BenefitName51,@BenefitName52,@BenefitName53,@BenefitName54,@BenefitName55,
			@BenefitName56,@BenefitName57,@BenefitName58,@BenefitName59,@BenefitName60,
			@BenefitName100,
			@BenefitName101,
			@DeductName01,@DeductName02,@DeductName03,@DeductName04,@DeductName05,
			@DeductName06,@DeductName07,@DeductName08,@DeductName09,@DeductName10,
			@DeductName11,@DeductName12,@DeductName13,@DeductName14,@DeductName15,
			@DeductName16,@DeductName17,@DeductName18,@DeductName19,@DeductName20,
			@DeductName21,@DeductName22,@DeductName23,@DeductName24,@DeductName25,
			@DeductName26,@DeductName27,@DeductName28,@DeductName28,@DeductName30,
			@DeductName31,@DeductName32,@DeductName33,@DeductName34,@DeductName35,
			@DeductName36,@DeductName37,@DeductName38,@DeductName39,@DeductName40,
			@DeductName41,@DeductName42,@DeductName43,@DeductName44,@DeductName45,
			@DeductName46,@DeductName47,@DeductName48,@DeductName49,@DeductName50,
			@DeductName51,@DeductName52,@DeductName53,@DeductName54,@DeductName55,
			@DeductName56,@DeductName57,@DeductName58,@DeductName58,@DeductName60,
			@DeductName100,
			@DeductName101,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0,0,0,0,
			0,0)
			
		FETCH NEXT FROM crs_Benefits INTO @PersonnelID	
	end	
		
	Close crs_Benefits
	Deallocate crs_Benefits	
	--select * from #tbl_RptPrs_SalaryList_M 
	update #tbl_RptPrs_SalaryList_R set 
		BenefitAmount01=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName01)) and BenefitType>0),
		BenefitAmount02=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName02)) and BenefitType>0),
		BenefitAmount03=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName03)) and BenefitType>0),
		BenefitAmount04=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName04)) and BenefitType>0),
		BenefitAmount05=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName05)) and BenefitType>0),
		BenefitAmount06=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName06)) and BenefitType>0),
		BenefitAmount07=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName07)) and BenefitType>0),
		BenefitAmount08=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName08)) and BenefitType>0),
		BenefitAmount09=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName09)) and BenefitType>0),
		BenefitAmount10=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName10)) and BenefitType>0),
		BenefitAmount11=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName11)) and BenefitType>0),
		BenefitAmount12=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName12)) and BenefitType>0),
		BenefitAmount13=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName13)) and BenefitType>0),
		BenefitAmount14=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName14)) and BenefitType>0),
		BenefitAmount15=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName15)) and BenefitType>0),
		BenefitAmount16=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName16)) and BenefitType>0),
		BenefitAmount17=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName17)) and BenefitType>0),
		BenefitAmount18=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName18)) and BenefitType>0),
		BenefitAmount19=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName19)) and BenefitType>0),
		BenefitAmount20=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName20)) and BenefitType>0),
		BenefitAmount21=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName21)) and BenefitType>0),
		BenefitAmount22=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName22)) and BenefitType>0),
		BenefitAmount23=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName23)) and BenefitType>0),
		BenefitAmount24=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName24)) and BenefitType>0),
		BenefitAmount25=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName25)) and BenefitType>0),
		BenefitAmount26=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName26)) and BenefitType>0),
		BenefitAmount27=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName27)) and BenefitType>0),
		BenefitAmount28=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName28)) and BenefitType>0),
		BenefitAmount29=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName29)) and BenefitType>0),
		BenefitAmount30=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName30)) and BenefitType>0),
		BenefitAmount31=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName31)) and BenefitType>0),
		BenefitAmount32=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName32)) and BenefitType>0),
		BenefitAmount33=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName33)) and BenefitType>0),
		BenefitAmount34=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName34)) and BenefitType>0),
		BenefitAmount35=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName35)) and BenefitType>0),
		BenefitAmount36=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName36)) and BenefitType>0),
		BenefitAmount37=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName37)) and BenefitType>0),
		BenefitAmount38=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName38)) and BenefitType>0),
		BenefitAmount39=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName39)) and BenefitType>0),
		BenefitAmount40=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName40)) and BenefitType>0),
		BenefitAmount41=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName41)) and BenefitType>0),
		BenefitAmount42=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName42)) and BenefitType>0),
		BenefitAmount43=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName43)) and BenefitType>0),
		BenefitAmount44=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName44)) and BenefitType>0),
		BenefitAmount45=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName45)) and BenefitType>0),
		BenefitAmount46=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName46)) and BenefitType>0),
		BenefitAmount47=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName47)) and BenefitType>0),
		BenefitAmount48=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName48)) and BenefitType>0),
		BenefitAmount49=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName49)) and BenefitType>0),
		BenefitAmount50=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName50)) and BenefitType>0),
		BenefitAmount51=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName51)) and BenefitType>0),
		BenefitAmount52=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName52)) and BenefitType>0),
		BenefitAmount53=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName53)) and BenefitType>0),
		BenefitAmount54=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName54)) and BenefitType>0),
		BenefitAmount55=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName55)) and BenefitType>0),
		BenefitAmount56=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName56)) and BenefitType>0),
		BenefitAmount57=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName57)) and BenefitType>0),
		BenefitAmount58=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName58)) and BenefitType>0),
		BenefitAmount59=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName59)) and BenefitType>0),
		BenefitAmount60=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName60)) and BenefitType>0),
		BenefitAmount100=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and M.BenefitType>0 and  M.BenefitName not in (
			@BenefitName01, @BenefitName02, @BenefitName03, @BenefitName04, @BenefitName05, @BenefitName06,
			@BenefitName07, @BenefitName08, @BenefitName09, @BenefitName10, @BenefitName11, @BenefitName12,
			@BenefitName13, @BenefitName14, @BenefitName15, @BenefitName16, @BenefitName17, @BenefitName18,
			@BenefitName19, @BenefitName20, @BenefitName21, @BenefitName22, @BenefitName23, @BenefitName24, 
			@BenefitName25, @BenefitName26, @BenefitName27, @BenefitName28, @BenefitName29, @BenefitName30,
			@BenefitName31, @BenefitName32, @BenefitName33, @BenefitName34, @BenefitName35, @BenefitName36,
			@BenefitName37, @BenefitName38, @BenefitName39, @BenefitName40, @BenefitName41, @BenefitName42,
			@BenefitName43, @BenefitName44, @BenefitName45, @BenefitName46, @BenefitName47, @BenefitName48,
			@BenefitName49, @BenefitName50, @BenefitName51, @BenefitName52, @BenefitName53, @BenefitName54, 
			@BenefitName55, @BenefitName56, @BenefitName57, @BenefitName58, @BenefitName59, @BenefitName60)),

		BenefitDesc01=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName01)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc02=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName02)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc03=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName03)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc04=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName04)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc05=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName05)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc06=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName06)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc07=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName07)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc08=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName08)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc09=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName09)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc10=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName10)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc11=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName11)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc12=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName12)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc13=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName13)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc14=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName14)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc15=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName15)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc16=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName16)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc17=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName17)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc18=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName18)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc19=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName19)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc20=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName20)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc21=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName21)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc22=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName22)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc23=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName23)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc24=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName24)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc25=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName25)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc26=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName26)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc27=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName27)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc28=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName28)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc29=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName29)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc30=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName30)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc31=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName31)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc32=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName32)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc33=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName33)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc34=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName34)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc35=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName35)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc36=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName36)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc37=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName37)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc38=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName38)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc39=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName39)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc40=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName40)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc41=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName41)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc42=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName42)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc43=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName43)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc44=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName44)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc45=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName45)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc46=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName46)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc47=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName47)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc48=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName48)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc49=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName49)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc50=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName50)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc51=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName51)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc52=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName52)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc53=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName53)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc54=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName54)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc55=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName55)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc56=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName56)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc57=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName57)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc58=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName58)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc59=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName59)) and BenefitType>0  and @MonthFr=@MonthTo),
		BenefitDesc60=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.BenefitName60)) and BenefitType>0  and @MonthFr=@MonthTo),
		

		DeductAmount01=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName01)) and BenefitType<0),
		DeductAmount02=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName02)) and BenefitType<0),
		DeductAmount03=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName03)) and BenefitType<0),
		DeductAmount04=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName04)) and BenefitType<0),
		DeductAmount05=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName05)) and BenefitType<0),
		DeductAmount06=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName06)) and BenefitType<0),
		DeductAmount07=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName07)) and BenefitType<0),
		DeductAmount08=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName08)) and BenefitType<0),
		DeductAmount09=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName09)) and BenefitType<0),
		DeductAmount10=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName10)) and BenefitType<0),
		DeductAmount11=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName11)) and BenefitType<0),
		DeductAmount12=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(  M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName12)) and BenefitType<0),
		DeductAmount13=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName13)) and BenefitType<0),
		DeductAmount14=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName14)) and BenefitType<0),
		DeductAmount15=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName15)) and BenefitType<0),
		DeductAmount16=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName16)) and BenefitType<0),
		DeductAmount17=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName17)) and BenefitType<0),
		DeductAmount18=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName18)) and BenefitType<0),
		DeductAmount19=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName19)) and BenefitType<0),
		DeductAmount20=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName20)) and BenefitType<0),
		DeductAmount21=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName21)) and BenefitType<0),
		DeductAmount22=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName22)) and BenefitType<0),
		DeductAmount23=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName23)) and BenefitType<0),
		DeductAmount24=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName24)) and BenefitType<0),
		DeductAmount25=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName25)) and BenefitType<0),
		DeductAmount26=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName26)) and BenefitType<0),
		DeductAmount27=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName27)) and BenefitType<0),
		DeductAmount28=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName28)) and BenefitType<0),
		DeductAmount29=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName29)) and BenefitType<0),
		DeductAmount30=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName30)) and BenefitType<0),
		DeductAmount31=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName31)) and BenefitType<0),
		DeductAmount32=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName32)) and BenefitType<0),
		DeductAmount33=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName33)) and BenefitType<0),
		DeductAmount34=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName34)) and BenefitType<0),
		DeductAmount35=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName35)) and BenefitType<0),
		DeductAmount36=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName36)) and BenefitType<0),
		DeductAmount37=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName37)) and BenefitType<0),
		DeductAmount38=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName38)) and BenefitType<0),
		DeductAmount39=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName39)) and BenefitType<0),
		DeductAmount40=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName40)) and BenefitType<0),
		DeductAmount41=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName41)) and BenefitType<0),
		DeductAmount42=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim(  M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName42)) and BenefitType<0),
		DeductAmount43=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName43)) and BenefitType<0),
		DeductAmount44=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName44)) and BenefitType<0),
		DeductAmount45=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName45)) and BenefitType<0),
		DeductAmount46=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName46)) and BenefitType<0),
		DeductAmount47=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName47)) and BenefitType<0),
		DeductAmount48=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName48)) and BenefitType<0),
		DeductAmount49=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName49)) and BenefitType<0),
		DeductAmount50=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName50)) and BenefitType<0),
		DeductAmount51=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName51)) and BenefitType<0),
		DeductAmount52=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName52)) and BenefitType<0),
		DeductAmount53=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName53)) and BenefitType<0),
		DeductAmount54=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName54)) and BenefitType<0),
		DeductAmount55=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName55)) and BenefitType<0),
		DeductAmount56=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName56)) and BenefitType<0),
		DeductAmount57=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName57)) and BenefitType<0),
		DeductAmount58=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName58)) and BenefitType<0),
		DeductAmount59=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName59)) and BenefitType<0),
		DeductAmount60=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and  ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName60)) and BenefitType<0),
		DeductAmount100=(select isnull(sum(BenefitAmount),0) from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and M.BenefitType<0 and M.BenefitName not in (
			DeductName01, DeductName02, DeductName03, DeductName04, DeductName05, DeductName06,
			DeductName07, DeductName08, DeductName09, DeductName10, DeductName11, DeductName12,
			DeductName13, DeductName14, DeductName15, DeductName16, DeductName17, DeductName18, 
			DeductName19, DeductName20, DeductName21, DeductName22, DeductName23, DeductName24,
			DeductName25, DeductName26, DeductName27, DeductName28, DeductName29, DeductName30,
			DeductName31, DeductName32, DeductName33, DeductName34, DeductName35, DeductName36,
			DeductName37, DeductName38, DeductName39, DeductName40, DeductName41, DeductName42,
			DeductName43, DeductName44, DeductName45, DeductName46, DeductName47, DeductName48, 
			DeductName49, DeductName50, DeductName51, DeductName52, DeductName53, DeductName54,
			DeductName55, DeductName56, DeductName57, DeductName58, DeductName59, DeductName60)),
		DeductDesc01=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName01)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc02=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName02)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc03=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName03)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc04=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName04)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc05=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName05)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc06=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName06)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc07=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName07)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc08=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName08)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc09=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName09)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc10=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName10)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc11=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName11)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc12=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName12)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc13=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName13)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc14=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName14)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc15=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName15)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc16=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName16)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc17=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName17)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc18=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName18)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc19=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName19)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc20=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName20)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc21=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName21)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc22=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName22)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc23=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName23)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc24=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName24)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc25=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName25)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc26=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName26)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc27=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName27)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc28=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName28)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc29=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName29)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc30=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName30)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc31=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName31)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc32=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName32)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc33=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName33)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc34=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName34)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc35=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName35)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc36=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName36)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc37=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName37)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc38=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName38)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc39=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName39)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc40=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName40)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc41=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName41)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc42=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName42)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc43=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName43)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc44=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName44)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc45=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName45)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc46=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName46)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc47=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName47)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc48=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName48)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc49=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName49)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc50=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName50)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc51=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName51)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc52=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName52)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc53=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName53)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc54=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName54)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc55=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName55)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc56=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName56)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc57=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName57)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc58=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName58)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc59=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName59)) and BenefitType<0  and @MonthFr=@MonthTo),
		DeductDesc60=(select top 1 isnull(ltrim(rtrim(BenefitTime))+' '+ltrim(rtrim(BenefitUnit)),'') from #tbl_RptPrs_SalaryList_M M where M.PersonnelID=#tbl_RptPrs_SalaryList_R.PersonnelID and ltrim(rtrim( M.BenefitName))=ltrim(rtrim(#tbl_RptPrs_SalaryList_R.DeductName60)) and BenefitType<0  and @MonthFr=@MonthTo)
					
			
	select   *,cast(0 as bigint) InsuranceBasepay,cast(0 as float) as Basepay,cast(0 as bigint) EmployerInsur ,cast(0 as bigint) DoleAmount,cast(0 as float) as  InsurableAmount
	,cast(0 as bigint) JobCategoryPay,cast(0 as bigint) PastWagesDailyPay,cast(0 as bigint) DailyInferiorPay,cast(0 as bigint) DailyInferiorPayRemain
	,cast(0 as bigint) JobCategoryPayInsure	,cast(0 as bigint) PastWagesDailyPayInsure,cast(0 as bigint) DailyInferiorPayInsure	,cast(0 as bigint) DailyInferiorPayRemainInsure
	into #tblX
	from #tbl_RptPrs_SalaryList_R
	order by PersonnelID

	SET @StrSelect = 'update  #tblX
	Set InsuranceBasepay=S.InsuranceBasepay
	,Basepay =S.Basepay, EmployerInsur =S.EmployerInsur , DoleAmount=S.DoleAmount , InsurableAmount=S.InsurableAmount
	,JobCategoryPay=S.JobCategoryPay	,PastWagesDailyPay=S.PastWagesDailyPay	,DailyInferiorPay=S.DailyInferiorPay,DailyInferiorPayRemain=S.DailyInferiorPayRemain
	,JobCategoryPayInsure=S.JobCategoryPayInsure	,PastWagesDailyPayInsure=S.PastWagesDailyPayInsure
	,DailyInferiorPayInsure=S.DailyInferiorPayInsure	,DailyInferiorPayRemainInsure=S.DailyInferiorPayRemainInsure
		from  #tblX M
		inner join (select Sum(D.InsuranceBasepay) InsuranceBasepay
		,Sum(D.Basepay) Basepay, Sum(S.EmployerInsur ) EmployerInsur , Sum(S.DoleAmount) DoleAmount, Sum(S.InsurableAmount) InsurableAmount
		, Sum(D.JobCategoryPay) JobCategoryPay
		, Sum(D.PastWagesDailyPay) PastWagesDailyPay
		, Sum(D.DailyInferiorPay) DailyInferiorPay
		, Sum(D.DailyInferiorPayRemain) DailyInferiorPayRemain
		, Sum(D.JobCategoryPayInsure) JobCategoryPayInsure
		, Sum(D.PastWagesDailyPayInsure) PastWagesDailyPayInsure
		, Sum(D.DailyInferiorPayInsure) DailyInferiorPayInsure
		, Sum(D.DailyInferiorPayRemainInsure) DailyInferiorPayRemainInsure
		, S.PersonnelID
		FROM 	prs.tblSalaryCalculation S 
		INNER JOIN prs.tblDecreeHdr D ON S.DecreeSerialNo = D.SerialNo AND S.PersonnelID = D.PersonnelID 
		WHERE ' + @StrWhere + ' 
		GROUP BY S.PersonnelID) S ON M.PersonnelID = S.PersonnelID '
	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
		
	SET @StrSelect = '
		SELECT distinct '+ str(@MonthFr )+' MonthFr ,'+ str(@MonthTo )+' MonthTo, CAST('''+ @MonthFrName +''' as Nvarchar(20)) MonthFrName ,CAST('''+ @MonthToName +''' as Nvarchar(20)) MonthToName,T.*, P.FirstName + '' '' + P.LastName PersonnelName,P.LastName 
		,F.*,PP.NationalIDNumber
		, isnull(Cost320,0) Cost320, isnull(Cost325,0) Cost325
		,HireDate,InsuranceHireDate,QuitJobDate,Sons,Daughters,CardNumber
		,S.* , [prs].[funGetAccountNo](T.PersonnelID) AS AccountNo, PP.InsuranceID
		FROM
		(
			SELECT	M.*, WD.WorkShopName, JD.JobName, DD.DepartmentName, DD.DepartmentID --,InsuranceBasepay,Basepay,EmployerInsur ,DoleAmount,InsurableAmount
			FROM prs.tblSalaryCalculation S 
						inner join  (Select max (DecreeSerialNo) DecreeSerialNo , PersonnelID from prs.tblSalaryCalculation WHERE  MonthCode <= ' + LTrim(Str(@MonthTo))+'  Group by PersonnelID )SS On S.PersonnelID=SS.PersonnelID
						INNER JOIN prs.tblDecreeHdr D ON SS.DecreeSerialNo = D.SerialNo AND S.PersonnelID = D.PersonnelID 
						INNER JOIN #tblX M ON M.PersonnelID = S.PersonnelID 
						left join prs.tblDepartmentsDtl DD On DD.DepartmentID=D.DepartmentID  and DD.LanguageID=1
		                left join prs.tblJobsDtl JD On JD.JobID=D.JobID  and JD.LanguageID=1
	            	    left join prs.tblWorkShopsDtl WD On WD.WorkShopID=D.WorkShopID and WD.LanguageID=1
			WHERE ' + @StrWhere + '
			and S.MonthCode <= ' + LTrim(Str(@MonthTo))+' 
		) T 
		INNER JOIN #tbl_RptPrs_SalaryList_B B ON B.PersonnelID = T.PersonnelID
		INNER JOIN prs.tblPersonnels PP ON PP.PersonnelID = T.PersonnelID 
		INNER JOIN prs.tblPersonnelsDtl P ON P.PersonnelID = T.PersonnelID 
		INNER JOIN (
					select PersonnelID PersonnelID1 , 
					SUM(MonthlyFunction) MonthlyFunction,
					SUM(InsuranceFunction) InsuranceFunction,
					SUM(Absence) Absence,
					SUM(LeaveWithoutPay) LeaveWithoutPay,
					SUM(SickLeave) SickLeave,
					SUM(LeaveDay) LeaveDay,
					SUM(RedeemedVacationDays) RedeemedVacationDays,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(VacationOvertime))) VacationOvertime,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(HourlyOvertime))) HourlyOvertime,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(Delay)))Delay,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(WorkDeduction)))WorkDeduction,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(LeaveTime)))LeaveTime,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(HourlyLeaveWithoutPay)))HourlyLeaveWithoutPay,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(WithoutContactWorkDeduction)))WithoutContactWorkDeduction,
					prs.funGetHourMinutes(SUM(prs.funGetMinutes(RedeemedVacationTime)))RedeemedVacationTime
					from prs.tblFunctionsDtl F
					WHERE ' + @StrWherePrs + '
					group by PersonnelID
		) F
		ON F.PersonnelID1=B.PersonnelID		
		INNER JOIN (
					select PersonnelID PersonnelID2 
					, IsNull(SUM(S.DoleAmount ), 0) DoleAmount
					, IsNull(SUM(S.EmployerInsur ), 0) EmployerInsur 
					, IsNull(SUM(S.EmployeeInsur ), 0) EmployeeInsur 
	 				FROM prs.tblSalaryCalculation  S
					WHERE ' + @StrWherePrs + '
					group by PersonnelID
		) S
		ON S.PersonnelID2=B.PersonnelID		
		
		left join ( select SUM(Cost) Cost320 ,PersonnelID from prs.tblCelebrationDtl where ProcessID=320 group by PersonnelID) C320
		ON F.PersonnelID1=C320.PersonnelID		
		left join ( select SUM(Cost) Cost325 ,PersonnelID from prs.tblCelebrationDtl where ProcessID=325 group by PersonnelID) C325
		ON F.PersonnelID1=C325.PersonnelID		
		order by ' + @OrderField

	Print @StrSelect;
	EXEC sp_executesql @StrSelect;
End
GO
