USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- =============================================
-- Author:		<TAKRO SYSTEM, Jafari>
-- Create date: <1396/08/16>
-- Description:	جلوگیری از حذف چکهای گردش یافته
-- =============================================
create   TRIGGER [trs].[trgChkDelete]
   ON  trs.tblPayDtl
   WITH ENCRYPTION
   After Delete
AS 
BEGIN
	SET NOCOUNT ON;
	
	Declare @ChequeNo as bigint
	Declare @VolumeRowNo as int
	Declare @VolumeFiscalYear int
	Declare @ChequeCount as int
	Declare @StrErr1	NVARCHAR(4000)
	
	
	Declare curDelChequw Cursor  For 
	SELECT	ChequeNo,VolumeRowNo,VolumeFiscalYear
	From Deleted where ProcessID in(1,10) and PayTypeID in(6,26)
	
						
		Open curDelChequw
	
		FETCH NEXT FROM curDelChequw INTO	@ChequeNo,@VolumeRowNo,@VolumeFiscalYear
		
		WHILE @@FETCH_STATUS = 0
				BEGIN
				
		select @ChequeCount = COUNT(*)  from   trs.tblPayDtl
		where ProcessID  not in(1,10) and PayTypeID in(6,26) AND @ChequeNo=ChequeNo  and VolumeRowNo=@VolumeRowNo and VolumeFiscalYear=@VolumeFiscalYear
				
			IF @ChequeCount > 0
							BEGIN
								ROlLBACK
								Close curDelChequw
								Deallocate curDelChequw
								SET @StrErr1 =  pub.funReverseForCrystal('چک با شماره ' + str(@ChequeNo) + ' استفاده شده و قابل حذف نیست' )
								raiserror (@StrErr1, 16, 1)
							END

				FETCH NEXT FROM curDelChequw INTO	@ChequeNo,@VolumeRowNo,@VolumeFiscalYear
			END
				
			Close curDelChequw
			Deallocate curDelChequw
				
END

GO
