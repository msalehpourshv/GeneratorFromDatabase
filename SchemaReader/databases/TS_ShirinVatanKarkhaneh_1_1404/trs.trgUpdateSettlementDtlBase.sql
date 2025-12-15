USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TAKRO SYSTEM, Jafari>
-- Create date: <1397/01/19>
-- Description:	بروز رسانی مبدا ها در یک فیلد
-- =============================================
Create   TRIGGER [trs].[trgUpdateSettlementDtlBase]
   ON  trs.tblSettlementDtl
   WITH ENCRYPTION
   After Insert,
    Update
AS 
BEGIN
	SET NOCOUNT ON;
	
   DECLARE @ProcessID AS Int 
   DECLARE @ProcessNo AS Int 
   DECLARE @FiscalYear AS Int 
   DECLARE @SerialNo AS Int 
   DECLARE @RowNo AS Int 
     
	DECLARE csr_inserted CURSOR FOR
	SELECT	ProcessID ,ProcessNo ,FiscalYear,SerialNo ,RowNo
	FROM	inserted 
   
	OPEN csr_inserted 
		
	FETCH NEXT FROM csr_inserted INTO 		@ProcessID ,@ProcessNo ,@FiscalYear,@SerialNo ,@RowNo
	WHILE @@FETCH_STATUS = 0
		BEGIN
				Update trs.tblSettlementDtl
				  
					Set 
					   SettlementID=lTrim(str(ProcessID))+'@'+lTrim(str(ProcessNo))+'@'+lTrim(str(FiscalYear))+'@'+lTrim(str(SerialNo))
					 ,  BaseDstID=lTrim(str(BaseDstProcessID))+'@'+lTrim(str(BaseDstProcessNo))+'@'+lTrim(str(BaseDstFiscalYear))+'@'+lTrim(str(BaseDstSerialNo))
					 , BaseSaleID=lTrim(str(BaseSaleProcessID))+'@'+lTrim(str(BaseSaleProcessNo))+'@'+lTrim(str(BaseSaleFiscalYear))+'@'+lTrim(str(BaseSaleSerialNo))
					 , BasePayID=lTrim(str(BasePayProcessID))+'@'+lTrim(str(BasePayProcessNo))+'@'+lTrim(str(BasePayFiscalYear))+'@'+lTrim(str(BasePaySerialNo))
					 , BaseRetID=lTrim(str(BaseRetProcessID))+'@'+lTrim(str(BaseRetProcessNo))+'@'+lTrim(str(BaseRetFiscalYear))+'@'+lTrim(str(BaseRetSerialNo))				
					Where ProcessID=@ProcessID and ProcessNo = @ProcessNo and FiscalYear =@FiscalYear and SerialNo =@SerialNo  and RowNo =@RowNo 

				FETCH NEXT FROM csr_inserted INTO 		@ProcessID ,@ProcessNo ,@FiscalYear,@SerialNo ,@RowNo
		END
				
	Close csr_inserted
	Deallocate csr_inserted
			
END

GO
