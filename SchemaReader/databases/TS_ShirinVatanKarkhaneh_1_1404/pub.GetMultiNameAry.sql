USE TS_ShirinVatanKarkhaneh_1_1404
GO
SET ANSI_NULLS, QUOTED_IDENTIFIER ON
GO

CREATE PROCEDURE [pub].[GetMultiNameAry]
@StrCode VarChar(30),
@StrTableName       NVarChar(200),
@StrDtlTableName    NVarChar(100),
@StrSearchFieldName NVarChar(100),
@StrReturnFieldName NVarChar(100),
@PartNumberColumnIsExist BIT

WITH EXECUTE AS CALLER , ENCRYPTION
AS
BEGIN

declare @tblTempMulti TABLE (
	[AcntName] [NVarChar](500) COLLATE Arabic_CS_AS NULL
)

DECLARE @str_Multi1layerSum tinyint,
        @str_Multi2layerSum tinyint,
        @str_Multi3layerSum tinyint,
        @str_Multi4layerSum tinyint,
        @str_Multi5layerSum tinyint,
        @intCurrentMulti2 tinyint,
        @intCurrentMulti3 tinyint,
        @intCurrentMulti4 tinyint,
        @intCurrentMulti5 tinyint,
        @StrCodeName NVarChar(500),
        @str_Multi1layerLen varchar(20),
        @str_Multi2layerLen varchar(20),
        @str_Multi3layerLen varchar(20),
        @str_Multi4layerLen varchar(20),
        @str_Multi5layerLen varchar(20),
        @intPart int ,
        @intLevel int 

select @str_Multi1layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2) ,
       @str_Multi1layerLen = str(0,2)+ 
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
where TableName=@StrTableName AND PartNumber in (0,1)
PRINT @str_Multi1layerSum
PRINT @str_Multi1layerLen

select @str_Multi2layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Multi2layerLen = str(0,2)+ 
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
where TableName= @StrTableName AND PartNumber=2

select @str_Multi3layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Multi3layerLen = str(0,2)+ 
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
where TableName=@StrTableName AND PartNumber=3

select @str_Multi4layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Multi4layerLen = str(0,2)+ 
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
where TableName=@StrTableName AND PartNumber=4


select @str_Multi5layerSum = str(Layer1+Layer2+Layer3+Layer4+Layer5+Layer6+Layer7+Layer8+Layer9, 2),
       @str_Multi5layerLen = str(0,2)+ 
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
where TableName=@StrTableName AND PartNumber=5

set @intPart  = 1

SET @intCurrentMulti2 = @str_Multi1layerSum + 1
SET @intCurrentMulti3 = @str_Multi1layerSum + @str_Multi2layerSum + 1
SET @intCurrentMulti4 = @str_Multi1layerSum + @str_Multi2layerSum + @str_Multi3layerSum + 1
SET @intCurrentMulti5 = @str_Multi1layerSum + @str_Multi2layerSum + @str_Multi3layerSum + @str_Multi4layerSum + 1

DECLARE @SQLString NVarChar(4000);
DECLARE @ParmDefinition NVarChar(500);
DECLARE @Flag tinyInt

while @intPart<6
begin
set @intLevel=1
set @Flag=0
   while @intLevel<10
     begin
       if @intPart=1
         begin
           if  (( @Flag = 0 AND substring(@str_Multi1layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi1layerLen,(@intLevel*2)+1,2)) OR (LEN(RTRIM(substring(@StrCode,1,convert(int,ltrim(substring(@str_Multi1layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Multi1layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Multi1layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Multi1layerLen,((@intLevel-1)*2)+1,2)))))
              begin
				IF substring(@str_Multi1layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi1layerLen,(@intLevel*2)+1,2)
					set @Flag = 1
				
  				   SET @SQLString = N'SELECT @StrCodeName1= '+@StrReturnFieldName+'
						  FROM ' + @StrDtlTableName+'
						  WHERE '+@StrSearchFieldName+'=substring(''' + @StrCode + ''',1,convert(int,ltrim(substring(''' + @str_Multi1layerLen + ''',(@intLevel1*2)+1,2))))'

					IF @PartNumberColumnIsExist = 'True'
						SET @SQLString = @SQLString + 'AND PartNumber in (1,0)';

				   SET @ParmDefinition = N'@intLevel1 int , @StrCodeName1  NVarChar(500) OUTPUT';
				   EXECUTE sp_executesql @SQLString, @ParmDefinition,@intLevel1=@intLevel, @StrCodeName1=@StrCodeName OUTPUT;
print @SQLString
print @StrCodeName

              end
           else
              begin
                 set @StrCodeName=''
print 555
              end
         end
       else if @intPart=2
         begin
           if (( @Flag = 0 AND substring(@str_Multi2layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi2layerLen,(@intLevel*2)+1,2)) OR (LEN(RTRIM(substring(@StrCode,@intCurrentMulti2,convert(int,ltrim(substring(@str_Multi2layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Multi2layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Multi2layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Multi2layerLen,((@intLevel-1)*2)+1,2)))))
              begin
				IF substring(@str_Multi2layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi2layerLen,(@intLevel*2)+1,2)
					set @Flag = 1
				              
 				   SET @SQLString = N'SELECT @StrCodeName1= '+@StrReturnFieldName+'
						  FROM ' + @StrDtlTableName+'
						  WHERE '+@StrSearchFieldName+'=substring(''' + @StrCode + ''',' + LTRIM(STR(@intCurrentMulti2)) + ',convert(int,ltrim(substring(''' + @str_Multi2layerLen + ''',(@intLevel1*2)+1,2)))) '

					IF @PartNumberColumnIsExist = 'True'
						SET @SQLString = @SQLString + 'AND PartNumber = 2 ';

				   SET @ParmDefinition = N'@intLevel1 int , @StrCodeName1  NVarChar(500) OUTPUT';

				   EXECUTE sp_executesql @SQLString, @ParmDefinition,@intLevel1=@intLevel, @StrCodeName1=@StrCodeName OUTPUT;

              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=3
         begin
           if (( @Flag = 0 AND substring(@str_Multi2layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi2layerLen,(@intLevel*2)+1,2)) OR (LEN(RTRIM(substring(@StrCode,@intCurrentMulti3,convert(int,ltrim(substring(@str_Multi3layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Multi3layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Multi3layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Multi3layerLen,((@intLevel-1)*2)+1,2)))))
              begin
				IF substring(@str_Multi3layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi3layerLen,(@intLevel*2)+1,2)
					set @Flag = 1
              
 				   SET @SQLString = N'SELECT @StrCodeName1= '+@StrReturnFieldName+'
						  FROM ' + @StrDtlTableName+'
						  WHERE '+@StrSearchFieldName+'=substring(''' + @StrCode + ''',' + LTRIM(STR(@intCurrentMulti3)) + ',convert(int,ltrim(substring(''' + @str_Multi3layerLen + ''',(@intLevel1*2)+1,2))))'

					IF @PartNumberColumnIsExist = 'True'
						SET @SQLString = @SQLString + 'AND PartNumber = 3 ';
						
				   SET @ParmDefinition = N'@intLevel1 int , @StrCodeName1  NVarChar(500) OUTPUT';

				   EXECUTE sp_executesql @SQLString, @ParmDefinition,@intLevel1=@intLevel, @StrCodeName1=@StrCodeName OUTPUT;
              
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=4
         begin
           if (( @Flag = 0 AND substring(@str_Multi2layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi2layerLen,(@intLevel*2)+1,2)) OR (LEN(RTRIM(substring(@StrCode,@intCurrentMulti4,convert(int,ltrim(substring(@str_Multi4layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Multi4layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Multi4layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Multi4layerLen,((@intLevel-1)*2)+1,2)))))
              begin
				IF substring(@str_Multi4layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi4layerLen,(@intLevel*2)+1,2)
					set @Flag = 1
              
 				   SET @SQLString = N'SELECT @StrCodeName1= '+@StrReturnFieldName+'
						  FROM ' + @StrDtlTableName+'
						  WHERE '+@StrSearchFieldName+'=substring(''' + @StrCode + ''',' + LTRIM(STR(@intCurrentMulti4)) + ',convert(int,ltrim(substring(''' + @str_Multi4layerLen + ''',(@intLevel1*2)+1,2))))'

					IF @PartNumberColumnIsExist = 'True'
						SET @SQLString = @SQLString + 'AND PartNumber = 4 ';

				   SET @ParmDefinition = N'@intLevel1 int , @StrCodeName1  NVarChar(500) OUTPUT';

				   EXECUTE sp_executesql @SQLString, @ParmDefinition,@intLevel1=@intLevel, @StrCodeName1=@StrCodeName OUTPUT;
              end
           else
              begin
                 set @StrCodeName=''
              end
         end
       else if @intPart=5
         begin
           if (( @Flag = 0 AND substring(@str_Multi2layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi2layerLen,(@intLevel*2)+1,2)) OR (LEN(RTRIM(substring(@StrCode,@intCurrentMulti5,convert(int,ltrim(substring(@str_Multi5layerLen,(@intLevel*2)+1,2))))))>=substring(@str_Multi5layerLen,(@intLevel*2)+1,2) AND convert(int,ltrim(substring(@str_Multi5layerLen,(@intLevel*2)+1,2)))>convert(int,ltrim(substring(@str_Multi5layerLen,((@intLevel-1)*2)+1,2)))))
              begin
				IF substring(@str_Multi5layerLen,((@intLevel+1)*2)+1,2)=substring(@str_Multi5layerLen,(@intLevel*2)+1,2)
					set @Flag = 1
              
 				   SET @SQLString = N'SELECT @StrCodeName1= '+@StrReturnFieldName+'
						  FROM ' + @StrDtlTableName+'
						  WHERE '+@StrSearchFieldName+'=substring(''' + @StrCode + ''',' + LTRIM(STR(@intCurrentMulti5)) + ',convert(int,ltrim(substring(''' + @str_Multi5layerLen + ''',(@intLevel1*2)+1,2))))'

					IF @PartNumberColumnIsExist = 'True'
						SET @SQLString = @SQLString + 'AND PartNumber = 5 ';

				   SET @ParmDefinition = N'@intLevel1 int , @StrCodeName1  NVarChar(500) OUTPUT';

				   EXECUTE sp_executesql @SQLString, @ParmDefinition,@intLevel1=@intLevel, @StrCodeName1=@StrCodeName OUTPUT;              

              end
           else
              begin
                 set @StrCodeName=''
              end
         end
         
        INSERT INTO @tblTempMulti values ( @StrCodeName )
        set @intLevel=@intLevel+1
     end
   set @intPart=@intPart+1
end

select * from @tblTempMulti

END



















GO
