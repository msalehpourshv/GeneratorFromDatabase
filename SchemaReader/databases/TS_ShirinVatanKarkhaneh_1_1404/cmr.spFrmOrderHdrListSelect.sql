USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/04
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [cmr].[spFrmOrderHdrListSelect] 
	@ProcessID		tinyint,
	@DocDate		Char(10),
	@AcntCode		varchar(20),
	@SerialNo		Int,
	@FiscalYear		Smallint,
	@ExtraParams	NVarChar(Max) = ''
 
WITH ENCRYPTION
AS
BEGIN
SET NOCOUNT ON;

	Declare @ProcessNo Tinyint
	Declare @ConfirmCount	int;
	DECLARE @Sgn1			BIT;
	DECLARE @Sgn2			BIT;
	DECLARE @Sgn3			BIT;
	DECLARE @Sgn4			BIT;
	DECLARE @Sgn5			BIT;
	DECLARE @Confirm		BIT;
	DECLARE @Goods			Varchar(1000);
	DECLARE @SqlStr			Varchar(1000);

	SET @ProcessNo			= LTrim(pub.funSplitString(@ExtraParams, '@', 1)); 
	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);
	SET @Goods				= pub.funSplitString(@ExtraParams, '@', 9);
	SET @SqlStr				= pub.funSplitString(@ExtraParams, '@', 10);

	if @ProcessNo is null 	set @ProcessNo=0

	Declare @DocStep Tinyint=0
		set @DocStep=2


	set @SqlStr	=ISNULL(@SqlStr	,'')
	set @Goods	=ISNULL(@Goods	,'')
	set @ProcessNo	=ISNULL(@ProcessNo	,'1')
	set @FiscalYear	=ISNULL(@FiscalYear	,0)
	set @SerialNo	=ISNULL(@SerialNo	,0)
	set @DocDate	=ISNULL(@DocDate	,'')
	set @AcntCode	=ISNULL(@AcntCode	,'Null')
	set @ConfirmCount	=ISNULL(@ConfirmCount	,0)
	set @Confirm	=ISNULL(@Confirm	,0)
	set @Sgn1	=ISNULL(@Sgn1	,0)
	set @Sgn2	=ISNULL(@Sgn2	,0)
	set @Sgn3	=ISNULL(@Sgn3	,0)
	set @Sgn4	=ISNULL(@Sgn4	,0)
	set @Sgn5	=ISNULL(@Sgn5	,0)
	

IF @ProcessID=160
	BEGIN
		IF @DocDate =''
			BEGIN
				DECLARE @StrSelect1		NVarChar(Max);
				set @StrSelect1 = '	
		 		SELECT Distinct ProcessID,ProcessNo,FiscalYear,SerialNo,DocDate,pub.GetCodeName('+@AcntCode+',1) AcntName
				FROM cmr.tblOrderHdr 
				WHERE ProcessID= '+ str(@ProcessID)+'    and ('+str(@ProcessNo)+'=0 or ProcessNo='+str(@ProcessNo)+')
				and (
				('+str(@ConfirmCount)+'=0 and (	('+str(@Confirm)+'=0 and DocStep=1)
									  or('+str(@Confirm)+'=1 and DocStep=2)
									  )
				)or 
				('+str(@ConfirmCount)+'>0 and (('+str(@Sgn1)+'=0 and SgnSN1=0) or ('+str(@Sgn1)+'>0 and SgnSN1>0)  )
				  				 and (('+str(@Sgn2)+'=0 and SgnSN2=0) or ('+str(@Sgn2)+'>0 and SgnSN2>0)  )
								 and (('+str(@Sgn3)+'=0 and SgnSN3=0) or ('+str(@Sgn3)+'>0 and SgnSN3>0)  )
								 and (('+str(@Sgn4)+'=0 and SgnSN4=0) or ('+str(@Sgn4)+'>0 and SgnSN4>0)  )
								 and (('+str(@Sgn5)+'=0 and SgnSN5=0) or ('+str(@Sgn5)+'>0 and SgnSN5>0)  )
				)
				)'+@SqlStr+''
			print   @StrSelect1;             
			EXEC sp_executesql @StrSelect1
			END
		ELSE 
-------------------------------------------------------------------------------------------------------------------
		DECLARE @StrSelect2		NVarChar(Max);
		set @StrSelect2 = '
		Select	Distinct ProcessID , ProcessNo , FiscalYear , SerialNo ,DocDate,pub.GetCodeName('+@AcntCode+',1) AcntName
		From cmr.FunCmrGoodsQtyRemain(150,'+str(@ProcessNo)+','+str(@FiscalYear)+','+str(@SerialNo)+',0,0,0,0,0,0)
		WHERE acc.funIsCodeClosed('+@AcntCode+') = 0
		and DocDate <='''+@DocDate+'''
		and ('+@AcntCode+' IS NULL   OR AcntCode = '+@AcntCode+') 
		and ConfirmQuantity>0		 
		and (
				('+str(@ConfirmCount)+'=0 and (	('+str(@Confirm)+'=0 and DocStep=1)
									  or('+str(@Confirm)+'=1 and DocStep=2)
									  )
				)or 
				('+str(@ConfirmCount)+'>0 and (('+str(@Sgn1)+'=0 and SgnSN1=0) or ('+str(@Sgn1)+'>0 and SgnSN1>0)  )
				  				 and (('+str(@Sgn2)+'=0 and SgnSN2=0) or ('+str(@Sgn2)+'>0 and SgnSN2>0)  )
								 and (('+str(@Sgn3)+'=0 and SgnSN3=0) or ('+str(@Sgn3)+'>0 and SgnSN3>0)  )
								 and (('+str(@Sgn4)+'=0 and SgnSN4=0) or ('+str(@Sgn4)+'>0 and SgnSN4>0)  )
								 and (('+str(@Sgn5)+'=0 and SgnSN5=0) or ('+str(@Sgn5)+'>0 and SgnSN5>0)  )
				)
				)'+@SqlStr+''
		print   @StrSelect2;             
		EXEC sp_executesql @StrSelect2
	END
-------------------------------------------------------------------------------------------------------------------
ELSE IF @ProcessID=165
begin

 

	DECLARE @StrSelect3		NVarChar(Max);
	set @StrSelect3 = '
	Select	Distinct ProcessID , ProcessNo , FiscalYear , SerialNo ,DocDate, pub.GetCodeName('+@AcntCode+',1) AcntName
	From cmr.FunCmrGoodsQtyRemain(160,'+str(@ProcessNo)+','+str(@FiscalYear)+',0,0,0,0,0,0,0)
	WHERE acc.funIsCodeClosed('+@AcntCode+') = 0
	and DocDate <='''+@DocDate+'''
	and ('+@AcntCode+' IS NULL   OR AcntCode = '+@AcntCode+') 
	and ConfirmQuantity>0
	and (
			('+str(@ConfirmCount)+'=0 and (	('+str(@Confirm)+'=0 and DocStep=1)
								  or('+str(@Confirm)+'=1 and DocStep=2)
								  )
			)or 
			('+str(@ConfirmCount)+'>0 and (('+str(@Sgn1)+'=0 and SgnSN1=0) or ('+str(@Sgn1)+'>0 and SgnSN1>0)  )
			  				 and (('+str(@Sgn2)+'=0 and SgnSN2=0) or ('+str(@Sgn2)+'>0 and SgnSN2>0)  )
							 and (('+str(@Sgn3)+'=0 and SgnSN3=0) or ('+str(@Sgn3)+'>0 and SgnSN3>0)  )
							 and (('+str(@Sgn4)+'=0 and SgnSN4=0) or ('+str(@Sgn4)+'>0 and SgnSN4>0)  )
							 and (('+str(@Sgn5)+'=0 and SgnSN5=0) or ('+str(@Sgn5)+'>0 and SgnSN5>0)  )
			)
			)
	ORDER BY FiscalYear,SerialNo' +@SqlStr+''
		print   @StrSelect3;             
	EXEC sp_executesql @StrSelect3;
end
ELSE IF @ProcessID=156	
begin


	DECLARE @StrSelect4		NVarChar(Max);
 	
	set @StrSelect4 = 	' 
		SELECT Distinct ProcessID,	ProcessNo,	FiscalYear	,SerialNo,	 DocDate	,pub.GetCodeName('+@AcntCode+',1) AcntName
		FROM cmr.tblInquiryPriceDtl 
			WHERE GoodsID in ('+ @Goods +') ' + @SqlStr + ' ' 

	print   @StrSelect4;             
	EXEC sp_executesql @StrSelect4;

	 
 end 
END
GO
