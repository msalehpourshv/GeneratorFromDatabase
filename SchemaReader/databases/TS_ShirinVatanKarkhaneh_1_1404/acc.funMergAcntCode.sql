USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO
-- select [acc].[funMergAcntCode]('611 ','120901 09001')
-- =============================================
-- Author:		jafari
-- Create date: 96/06/16
-- Description:	
-- دو کد را دریافت و سپس آنها را ترکیب میکند
-- =============================================


Create FUNCTION [acc].[funMergAcntCode]
(
	@Acnt1  AS VarChar(20),
	@Acnt2  AS VarChar(20) 
)
RETURNS NVarChar(2044)
WITH ENCRYPTION
AS
BEGIN
--Declare @Acnt2  AS VarChar(20) ='09876543210987654321'
--Declare @Acnt1  AS VarChar(20) ='12345678901234567'
DECLARE @strRet AS  VarChar(20) 

    Set @strRet =''
    
     Declare @lenAcnt int
                Declare @lenAcnt2 int
                Set @lenAcnt = Len(@Acnt1)
                Set @lenAcnt2 = Len(@Acnt2)
                
                Declare @len1  int 
                Declare @len2  int 
                Declare @len3  int 
                Declare @len4  int 

            If @lenAcnt2 > @lenAcnt 
             begin
			   
              
                Select @len1=[acc].[funGetAcntLayerStartandLen](1,2)
                Select @len2=[acc].[funGetAcntLayerStartandLen](2,2)+@len1+1
                Select @len3=[acc].[funGetAcntLayerStartandLen](3,2)+@len2+1
                Select @len4=[acc].[funGetAcntLayerStartandLen](4,2)+@len3+1
                
                --Select [acc].[funGetAcntLayerStartandLen](1,2),
                --[acc].[funGetAcntLayerStartandLen](2,2),
                --[acc].[funGetAcntLayerStartandLen](3,2),
                --[acc].[funGetAcntLayerStartandLen](4,2)
                --Select @len1,@len2,@len3,@len4,@lenAcnt,@lenAcnt2
                

                
                set @strRet = @Acnt1
                                
                If @lenAcnt <= @len1 and @lenAcnt2 > @len1 
                  set  @strRet = substring (@Acnt1,1, @len1 ) + Space(@len1 - @lenAcnt+1) + substring (@Acnt2, @len1 + 2, LEN(@Acnt2)-(@len1+1))
                Else If @lenAcnt <= @len2  and @lenAcnt2 > @len2
					set  @strRet = substring (@Acnt1,1, @len2 ) + Space(@len2 - @lenAcnt+1) + substring (@Acnt2, @len2 + 2, LEN(@Acnt2)-(@len2+1))
                Else If @lenAcnt <= @len3 and @lenAcnt2 > @len3 
		        	set  @strRet = substring (@Acnt1,1, @len3 ) + Space(@len3 - @lenAcnt+1) + substring (@Acnt2, @len3 + 2, LEN(@Acnt2)-(@len3+1))
                Else If @lenAcnt <= @len4 and @lenAcnt2 > @len4
	            	set  @strRet = substring (@Acnt1,1, @len4 ) + Space(@len4 - @lenAcnt+1) + substring (@Acnt2, @len4 + 2, LEN(@Acnt2)-(@len4+1))
			end
            Else
                set @strRet = @Acnt1
                
                
--                Select @strRet
      
	RETURN @strRet
END
GO
