USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
 -- =========== TS-QC:OK ========================
-- Author        : Mahdi Mostafavi	
-- Create date   : 1403/03/29
-- Viewed By	 : 
-- Last Modified : 
-- Description   : 
-- =============================================
Create PROCEDURE [sal].[Sp_DarbMotaghed_SendMessageOverSaleConfirmFromSite]
	@strDBName000		 as varchar(50),
	@DocDate			 as nvarchar(10),
	@DocDesc			 as nvarchar(1000),
	@BaseSerialNo		 as int,
	@SerialNo			 as int,
	@CustomerFullName	 as nvarchar(500)
WITH ENCRYPTION
AS

DECLARE @FromUser				varchar(10)
DECLARE @strText				NVarChar(1000)
DECLARE @strExecute				NVarChar(max)
DECLARE @strDate				varchar(10)
DECLARE @strTime				varchar(8)

BEGIN
	SET NOCOUNT ON;

	Select @FromUser = SettingValue 
	from pub.tblSettings 
	where SettingKey ='UserExternalCRM'
	
	Select @strText=SettingValue
	from TS.pub.tblSettings 
	where SettingKey ='Odoo_MessageFormat'

	Select @strText = REPLACE(@strText,'<1>',@SerialNo),
	@strText = REPLACE(@strText,'<2>',@BaseSerialNo),
	@strText = REPLACE(@strText,'<3>',@DocDate),
	@strText = REPLACE(@strText,'<4>',@DocDesc),
	@strText = REPLACE(@strText,'<5>',@CustomerFullName)

	Select @strDate = pub.funChangeDate_GergorianToPersian(GetDate())
	Select @strTime = Right(Left(CONVERT(varchar(10),GetDate(),108),8),8)
	IF (@strText is not null) and (@strText <> '') and (@FromUser > -1)
	Begin
		set @strExecute = '
	DECLARE @UserID					varchar(10)

	DECLARE csr CURSOR FOR
			select UserID from '+@strDBName000+'.usr.tblParameterAccess
			where ParameterEn=''AllowAccConfirmSalesFromSite'' and Access=1
	OPEN csr
	FETCH NEXT FROM csr INTO @UserID

		WHILE (@@FETCH_STATUS = 0)
			BEGIN
				insert into '+@strDBName000+'.pub.tblUsersMessage 
							(FromUser,  ToUser,  SendDate, SendTime, [Subject], Context)
					  values('+@FromUser+',@UserID,'''+ @strDate+''', '''+@strTime+''', ''����� �� ���� �� Odoo'', '''+@strText+''')

				FETCH NEXT FROM csr INTO @UserID
			END
	CLOSE csr
	DEALLOCATE csr'
	print @strExecute	
	EXECUTE sp_executesql @strExecute
	end
End
GO
