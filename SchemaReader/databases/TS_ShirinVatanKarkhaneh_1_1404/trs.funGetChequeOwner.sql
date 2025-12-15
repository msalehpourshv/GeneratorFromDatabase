USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
Create FUNCTION [trs].[funGetChequeOwner] 
(
	@VolumeFiscalYear	SmallInt,
	@VolumeRowNo		Int	,
	@PayTypeID			Int	 
	
)
RETURNS VarChar(20)
WITH ENCRYPTION
AS

BEGIN -- ============== S T A R T  C O D E =====================================

	Declare @Result AS VarChar(20)
if (@VolumeRowNo=0  )
begin 
select @Result=''
end
else
begin
	IF @PayTypeID = 16
	SELECT Top 1 @Result =  case when isnull(d.CreditCode,'') ='' then isnull(a.AtomAcntCode,'') else isnull(d.CreditCode,'') end 
		FROM	trs.tblPayDtl d
		left join trs.tblPayAtm a 	on a.ProcessID=d.ProcessID and 	 a.ProcessNo=d.ProcessNo and 	  a.FiscalYear=d.FiscalYear and 	   a.SerialNo=d.SerialNo and 	   a.DocRowNo=d.DocRowNo
		WHERE	d.ProcessID IN (31) AND 
				VolumeFiscalYear = @VolumeFiscalYear AND 
				VolumeRowNo = @VolumeRowNo
				AND ((@PayTypeID = 31 AND PayTypeID = 31) OR (@PayTypeID <> 31 AND @PayTypeID IN (16))) 
			
		ORDER By EventNo ASC
	ELSE
	SELECT Top 1 @Result =  case when isnull(d.CreditCode,'') ='' then isnull(a.AtomAcntCode,'') else isnull(d.CreditCode,'') end 
		FROM	trs.tblPayDtl d
		left join trs.tblPayAtm a 	on a.ProcessID=d.ProcessID and 	 a.ProcessNo=d.ProcessNo and 	  a.FiscalYear=d.FiscalYear and 	   a.SerialNo=d.SerialNo and 	   a.DocRowNo=d.DocRowNo
		WHERE	d.ProcessID IN (1,10,20) AND 
				VolumeFiscalYear = @VolumeFiscalYear AND 
				VolumeRowNo = @VolumeRowNo
				AND ((@PayTypeID = 31 AND PayTypeID = 31) OR (@PayTypeID <> 31 AND @PayTypeID IN (6,26))) 
			
		ORDER By EventNo ASC
end
	

	Return @Result
END
GO
