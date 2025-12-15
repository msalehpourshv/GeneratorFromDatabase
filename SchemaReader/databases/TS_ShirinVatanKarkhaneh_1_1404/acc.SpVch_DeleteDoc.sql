USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =========== TS-QC:OK ========================
-- Author        : Hadi Sadeghi
-- Create date   : 86/07/04
-- Viewed By	 : Majid Mohammadi
-- Last Modified : 86/11/23
-- Description   : 
-- =============================================

CREATE  PROCEDURE [acc].[SpVch_DeleteDoc]
	@intVchNo				Int,
	@intSourceProcessID		SmallInt,
	@intSourceProcessNo		tinyint ,
	@intSourceFiscalYear	SmallInt ,
	@intSourceSerialNo		Int ,
	@StrSourceCodeFieldValue VARCHAR(500)=''
	
	WITH ENCRYPTION
AS
BEGIN
	SET NOCOUNT ON;

	DECLARE @AccVoucherCreateInReservedList BIT

	SET @AccVoucherCreateInReservedList = 'False'
	
	SELECT @AccVoucherCreateInReservedList = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'AccVoucherCreateInReservedList'
	
	Declare @Pub_SendDoc2OtherSoftWare as bit
	
	SELECT @Pub_SendDoc2OtherSoftWare = SettingValue
	FROM pub.tblSettings 
	WHERE SettingKey = 'Pub_SendDoc2OtherSoftWare' 
	set @Pub_SendDoc2OtherSoftWare=isnull(@Pub_SendDoc2OtherSoftWare, 'False')


----- باقيمانده تعداد سطرهاي سند را نشان مي دهد

	DELETE FROM acc.tblVoucherDtl
	WHERE SourceDocType = 0 AND
		  SourceProcessID = @intSourceProcessID   AND 
		  SourceProcessNo = @intSourceProcessNo   AND 
		  SourceFiscalYear= @intSourceFiscalYear  AND 
		  SourceSerialNo  = @intSourceSerialNo  
		  AND SourceCodeFieldValue = @StrSourceCodeFieldValue

--  حذف تطبیق های سند	
	DELETE FROM acc.tblAccState
	WHERE (SourceProcessID1 = @intSourceProcessID   
		AND SourceProcessNo1 = @intSourceProcessNo   
		AND SourceFiscalYear1= @intSourceFiscalYear  
		AND SourceSerialNo1  = @intSourceSerialNo )
	or	(SourceProcessID2 = @intSourceProcessID   
		AND SourceProcessNo2 = @intSourceProcessNo   
		AND SourceFiscalYear2= @intSourceFiscalYear  
		AND SourceSerialNo2  = @intSourceSerialNo )
		  
	DELETE FROM acc.tblVoucher2AccState
	WHERE SourceProcessID = @intSourceProcessID   
		AND SourceProcessNo = @intSourceProcessNo   
		AND SourceFiscalYear= @intSourceFiscalYear  
		AND SourceSerialNo  = @intSourceSerialNo 

	IF ((SELECT TOP 1 SerialNo 
	     FROM acc.tblVoucherDtl
         WHERE SerialNo=@intVchNo) IS NULL)

			BEGIN
				DELETE FROM acc.tblVoucherHdr 
				WHERE SerialNo=@intVchNo
				IF @AccVoucherCreateInReservedList = 'False'
					DELETE FROM acc.tblVoucherSerials 
					WHERE VchNo=@intVchNo AND IsReserved = 'False'
			END
		
		ELSE

			BEGIN

				alter table acc.tblVoucherDtl disable trigger trgVoucherDtlUpdate

				UPDATE acc.tblVoucherDtl 
				SET DocRowNo=ROW_N
				FROM acc.tblVoucherDtl, 
					(SELECT RowNo,ROW_NUMBER() OVER(ORDER BY DocRowNo) As ROW_N
					 FROM	acc.tblVoucherDtl
					 WHERE	SerialNo=@intVchNo) t 
				WHERE acc.tblVoucherDtl.SerialNo=@intVchNo AND acc.tblVoucherDtl.RowNo=t.RowNo  and DocRowNo<>ROW_N
			
				alter table acc.tblVoucherDtl enable trigger trgVoucherDtlUpdate

			END

	IF @intSourceProcessID in (450,455,460,469,470,471,472,480,485,486,490,495,500,505,520)  and @Pub_SendDoc2OtherSoftWare='True'
	BEGIN			
			insert into pub.tblSendDoc2OtherSoftWare
			Select @intVchNo ,@intSourceProcessID ,@intSourceProcessNo,@intSourceFiscalYear,@intSourceSerialNo , 2, Getdate()
	END
END
GO
