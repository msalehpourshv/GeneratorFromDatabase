USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- ==============================================
-- Author:		 Sadeghi, Hadi
-- Create date: 
-- Description:
-- ==============================================

--[pub].[spGetCodeNameAry] '110101','acc.tblAcnt1','acc.tblAcnt1Dtl','AcntCode','AcntName',1
--[pub].[spGetCodeNameAry] '1','trs.tblOurBanks','trs.tblOurBanksDtl','BankCode','BankName',1

CREATE PROCEDURE [pub].[spGetCodeNameAry]
(@StrCode            NVarChar(20),
 @StrTableName       NVarChar(100),
 @StrDtlTableName    NVarChar(100),
 @StrSearchFieldName NVarChar(100),
 @StrReturnFieldName NVarChar(100),
 @bolEndLayerComplet bit=Null,
 @bytPartNumebr      tinyint=1)
WITH ENCRYPTION
As 
BEGIN

IF @bolEndLayerComplet IS Null SET @bolEndLayerComplet=1

declare @tblTempAcnt TABLE (
	[AcntName] [NVarChar](500) COLLATE Arabic_CS_AS NULL
)

DECLARE @str_Acnt1layerSum tinyint,
        @StrCodeName NVarChar(500),
        @str_Acnt1layerLen varchar(20),
        @intLevel int

SELECT @str_Acnt1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2), 
       @str_Acnt1layerLen = str(0,2)+ 
                            str(Layer1,2)+ 
                            str(Layer1+Layer2,2)+
                            str(Layer1+Layer2+Layer3,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7,2)+
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8,2)+ 
                            str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9,2) 
from pub.tblCodeLayer 
where TableName=@StrTableName AND  PartNumber=@bytPartNumebr

DECLARE @SQLString NVarChar(4000);
DECLARE @ParmDefinition NVarChar(500);

set @intLevel=1

while @intLevel<10
   begin

       if ( (@bolEndLayerComplet=0 AND substring(@str_Acnt1layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Acnt1layerLen,(@intLevel*2)+1,2)) OR (LEN(@StrCode)>=substring(@str_Acnt1layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Acnt1layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Acnt1layerLen,((@intLevel-1)*2)+1,2)))))
          begin
			
			   if (@bolEndLayerComplet=0 AND substring(@str_Acnt1layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Acnt1layerLen,(@intLevel*2)+1,2))
			       set @bolEndLayerComplet=1

			   SET @SQLString = N'SELECT @StrCodeName1= '+@StrReturnFieldName+'
								  FROM ' + @StrDtlTableName+'
								  WHERE '+@StrSearchFieldName+'=substring(@StrCode1,1,convert(int,ltrim(substring(@str_Acnt1layerLen1,(@intLevel1*2)+1,2))))';
               if @bytPartNumebr>1
					SET @SQLString +=' and PartNumber='+ str(@bytPartNumebr)+''
			   SET @ParmDefinition = N'@StrCode1 VarChar(20),@str_Acnt1layerLen1 varchar(20),@intLevel1 int , @StrCodeName1  NVarChar(500) OUTPUT';--,@StrDtlTableName1 NVarChar(50),@StrFieldName1 NVarChar(50),@StrFieldName1=@StrFieldName

			   EXECUTE sp_executesql @SQLString, @ParmDefinition, @StrCode1 = @StrCode,@str_Acnt1layerLen1=@str_Acnt1layerLen,@intLevel1=@intLevel, @StrCodeName1=@StrCodeName OUTPUT;

          end
       else
          begin
             set @StrCodeName=''
          end

   INSERT INTO @tblTempAcnt values ( @StrCodeName )

   set @intLevel=@intLevel+1

end

select * from @tblTempAcnt

END
GO
