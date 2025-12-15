USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:NOTOK =====================
-- Author        : Hadi Sadeghi
-- Create date   : 86/12/01
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE inv.spFrmInvTempReceiptHdrListSelect 
	@ProcessID		tinyint,
	@ProcessNo		tinyint,
	@BaseProcessID	tinyint,
	@DocDate		Char(10),
	@AcntCode		Varchar(20),
	@StoreID		Varchar(20),
	@DocStep		Tinyint,
	@SerialNo		Int,
	@FiscalYear		Smallint,
	@FindAllReceipt Bit,
	@GoodsID		VARCHAR(20),
	@FromDate		Char(10),
	@ToDate			Char(10),
	@ExtraParams	NVarChar(Max) = ''
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
	DECLARE @Confirm		BIT;

	SET @ConfirmCount		= pub.funSplitString(@ExtraParams, '@', 2);
	SET @Sgn1				= pub.funSplitString(@ExtraParams, '@', 3);
	SET @Sgn2				= pub.funSplitString(@ExtraParams, '@', 4);
	SET @Sgn3				= pub.funSplitString(@ExtraParams, '@', 5);
	SET @Sgn4				= pub.funSplitString(@ExtraParams, '@', 6);
	SET @Sgn5				= pub.funSplitString(@ExtraParams, '@', 7);
	SET @Confirm			= pub.funSplitString(@ExtraParams, '@', 8);

IF @DocDate =''
begin

	SELECT Distinct b.ProcessID,b.ProcessNo,b.FiscalYear,b.SerialNo,b.DocDate 
	FROM inv.tblInvTempReceiptDtl b
	inner join inv.tblInvTempReceiptHdr a
	on b.ProcessID =a.ProcessID 
	and b.ProcessNo=a.ProcessNo
	and b.FiscalYear=a.FiscalYear
	and b.SerialNo=a.SerialNo
	WHERE b.ProcessID= @ProcessID AND b.ProcessNo= @ProcessNo AND (@FindAllReceipt='True' OR b.Recognition=0)
	AND (@GoodsID = '' OR b.GoodsID=@GoodsID) 
	AND (@FromDate = '' OR b.DocDate>=@FromDate) 
	AND (@ToDate = '' OR b.DocDate<=@ToDate) 
	and (
						(@ConfirmCount=0 and (	(@Confirm=0 and b.DocStep=1)
											  or(@Confirm=1 and b.DocStep=2)
											  )
						)or 
						(@ConfirmCount>0 and ((@Sgn1=0 and SgnSN1=0) or (@Sgn1>0 and SgnSN1>0)  )
				  						 and ((@Sgn2=0 and SgnSN2=0) or (@Sgn2>0 and SgnSN2>0)  )
										 and ((@Sgn3=0 and SgnSN3=0) or (@Sgn3>0 and SgnSN3>0)  )
										 and ((@Sgn4=0 and SgnSN4=0) or (@Sgn4>0 and SgnSN4>0)  )
										 and ((@Sgn5=0 and SgnSN5=0) or (@Sgn5>0 and SgnSN5>0)  )
				)
				)	
end
ELSE IF @ProcessID=170 -- رسید موقت
-------------------------------------------------------------------------------------------------------------------
		   
				select Distinct ProcessID , ProcessNo , FiscalYear , SerialNo ,DocDate
					, DocDesc , AcntName
				from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0)
				where (@AcntCode IS NULL OR AcntCode = @AcntCode) 
						AND  DocDate<=@DocDate 
						AND ConfirmQuantity>0
						AND ( 
							(@BaseProcessID =160 and  DocStep=2) 
							or 
							(@BaseProcessID =150 AND   DocStep =2)
						)
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

ELSE IF @ProcessID=175  or  @ProcessID=176  --برگشت از رسید موقت
SELECT * FROM (
	select Distinct acc.funIsCodeClosed(AcntCode) IsCodeClosed, ProcessID , ProcessNo , FiscalYear , SerialNo ,DocDate
	, DocDesc , AcntName
	from cmr.FunCmrGoodsQtyRemain(@BaseProcessID,@ProcessNo,0,0,0,0,0,0,0,0)
	where (@AcntCode IS NULL OR AcntCode = @AcntCode) 
		AND  DocDate<=@DocDate 
		AND ConfirmQuantity>0
		AND DocStep=2
	--	and (( @BaseProcessID=170 and   Recognition in(1,2,3))or( @BaseProcessID=@ProcessID and   Recognition in(1,2,3,4)))
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
GO
