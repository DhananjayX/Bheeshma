
go
begin try 
	drop proc [dbo].[sp_INS]                              
end try
begin catch
	print 'sp exists already'
end catch

go

CREATE procedure  [dbo].[sp_INS]                              
(                                                          
   @Query  Varchar(MAX)                                                          
)                              

AS                              

SET nocount ON                  

DECLARE @WithStrINdex as INT                            
DECLARE @WhereStrINdex as INT                            
DECLARE @INDExtouse as INT                            

DECLARE @SchemaAndTAble VArchar(270)                            
DECLARE @Schema_name  varchar(30)                            
DECLARE @Table_name  varchar(240)                            
DECLARE @Condition  Varchar(MAX)                             

SET @WithStrINdex=0                            

SELECT @WithStrINdex=CHARINDEX('With',@Query )                            
, @WhereStrINdex=CHARINDEX('WHERE', @Query)                            

IF(@WithStrINdex!=0)                            
SELECT @INDExtouse=@WithStrINdex                            
ELSE                            
SELECT @INDExtouse=@WhereStrINdex                            

SELECT @SchemaAndTAble=Left (@Query,@INDExtouse-1)                                                     
SELECT @SchemaAndTAble=Ltrim (Rtrim( @SchemaAndTAble))                            

SELECT @Schema_name= Left (@SchemaAndTAble, CharIndex('.',@SchemaAndTAble )-1)                            
,      @Table_name = SUBSTRING(  @SchemaAndTAble , CharIndex('.',@SchemaAndTAble )+1,LEN(@SchemaAndTAble) )                            

,      @CONDITION=SUBSTRING(@Query,@WhereStrINdex+6,LEN(@Query))--27+6                            


DECLARE @COLUMNS  table (Row_number SmallINT , Column_Name VArchar(Max) )                              
DECLARE @CONDITIONS as varchar(MAX)                              
DECLARE @Total_Rows as SmallINT                              
DECLARE @Counter as SmallINT              

DECLARE @ComaCol as varchar(max)            
SELECT @ComaCol=''                   

SET @Counter=1                              
SET @CONDITIONS=''                              

INSERT INTO @COLUMNS                              
SELECT Row_number()Over (Order by ORDINAL_POSITION ) [Count], Column_Name 
FROM INformation_schema.columns 
WHERE Table_schema=@Schema_name AND table_name=@Table_name         


SELECT @Total_Rows= Count(1) 
FROM @COLUMNS                              

SELECT @Table_name= '['+@Table_name+']'                      

SELECT @Schema_name='['+@Schema_name+']'                      

While (@Counter<=@Total_Rows )                              
begin                               
--PRINT @Counter                              

SELECT @ComaCol= @ComaCol+'['+Column_Name+'],'            
FROM @COLUMNS                              
WHERE [Row_number]=@Counter                          

SELECT @CONDITIONS=@CONDITIONS+ ' + Case When ['+Column_Name+'] is null then ''Null'' Else '''''''' + Replace( Convert(varchar(Max),['+Column_Name+']  ) ,'''''''',''''  ) +'''''''' end+'+''','''                                                     
FROM @COLUMNS                              
WHERE [Row_number]=@Counter                              

SET @Counter=@Counter+1                              

End                              

SELECT @CONDITIONS=Right(@CONDITIONS,LEN(@CONDITIONS)-2)                              

SELECT @CONDITIONS=LEFT(@CONDITIONS,LEN(@CONDITIONS)-4)              
SELECT @ComaCol= substring (@ComaCol,0,  len(@ComaCol) )                            

SELECT @CONDITIONS= '''INSERT INTO '+@Schema_name+'.'+@Table_name+ '('+@ComaCol+')' +' Values( '+'''' + '+'+@CONDITIONS                              

SELECT @CONDITIONS=@CONDITIONS+'+'+ ''')'''                              

SELECT @CONDITIONS= 'Select  '+@CONDITIONS +'FRom  ' +@Schema_name+'.'+@Table_name+' With(NOLOCK) ' + ' Where '+@Condition                              
print(@CONDITIONS)                              
Exec(@CONDITIONS)

go

print 'sp created successfully'
