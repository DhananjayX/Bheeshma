


if exists (select 1 from sys.sysobjects where name like 'sp_s1' )

 begin 
		drop proc dbo.Sp_s1 
		print 'dropped sp_s1 '
 end

go

go
	print 'creating sp_s1'
go
---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
create proc dbo.Sp_s1 @txt VARCHAR(1000)
AS
  -- Create  by Dhananjay Kulkarni for saving developer's life and making database search more meaningful!! ;)
  BEGIN
      --1. if last 2 chars are D1 then -- only in SP_name    
      IF ( Len(@txt) > 2 )
        BEGIN
            IF Substring (@txt, Len(@txt) - 1, 2) = 'd1'
              BEGIN
                  -- only in sp name :    
                  SET @txt = '%' + Ltrim(Rtrim(Substring(@txt, 1, Len(@txt) - 2)
                                         ))
                             +
                             '%'

					  SELECT DISTINCT    isnull(OBJECT_SCHEMA_NAME(id),'') +'.' + [name] as Name,
									  'Sp name'
					  FROM   sys.sysobjects o
					  WHERE  name LIKE @txt
							 AND xtype = 'P' and isnull(OBJECT_SCHEMA_NAME(id),'')<> 'AUDIT'
				  union 
						SELECT DISTINCT  isnull(OBJECT_SCHEMA_NAME(id),'') +'.' + [name],
						'Function name'
						FROM   sys.sysobjects
						WHERE  name LIKE @txt
						AND xtype = 'FN' and isnull(OBJECT_SCHEMA_NAME(id),'')<> 'AUDIT'

						union 

						SELECT DISTINCT  isnull(OBJECT_SCHEMA_NAME(id),'') +'.' + [name],
						'View name'
						FROM   sys.sysobjects
						WHERE  name LIKE @txt
						AND xtype = 'v' and isnull(OBJECT_SCHEMA_NAME(id),'')<> 'AUDIT'

                  RETURN
              END

            IF Substring (@txt, Len(@txt) - 1, 2) = 'd2'
              BEGIN
                  --2. if last 2 chars are D2 then --only in table name or columns name      
                  SET @txt = '%' + Ltrim(Rtrim(Substring(@txt, 1, Len(@txt) - 2)
                                         ))
                             +
                             '%'

                  SELECT DISTINCT isnull(s.name,'') + '.' + t.name as ObjectName, 'Table name'
                  FROM   sys.sysobjects  o 
				  inner join sys.tables  t on t.object_id = o.id 
				  inner join sys.schemas s on  s.schema_id = t.schema_id and s.name <> 'AUDIT'
                  WHERE  o.name LIKE @txt AND xtype = 'U'
                         
                  UNION ALL
				  
				  --SELECT DISTINCT  isnull(s.name,'') + '.' + t.name as ObjectName, 'View'
      --            FROM   sys.sysobjects  o 
				  --inner join sys.schemas s on  s.schema_id = t.schema_id
      --            WHERE  o.name LIKE @txt AND xtype = 'V'
                         
				  --Union all	

                   SELECT DISTINCT  isnull(s.name,'') + '.' +  Object_name(c.id), 'Column:' + CONVERT(VARCHAR, c.name)
                  FROM   sys.syscolumns c 
                  inner join sys.tables t on t.object_id = c.id 
				  inner join sys.schemas s on  s.schema_id = t.schema_id and  s.name <> 'AUDIT'
                  WHERE  c.name LIKE @txt
                         AND Objectproperty (c.id, 'IsUserTable') = 1
                  ORDER  BY 2 DESC,  1

                  RETURN
              END

            IF Substring (@txt, Len(@txt), 1) = 'x'
              BEGIN
                  --3. if last 2 chars are D3 then --only in table name or columns name      
                  SET @txt = Substring (@txt, 1, Len(@txt) - 1)

                  DECLARE @qry VARCHAR(200)

                  SET @qry = 'select * from ' + @txt

                  EXECUTE (@qry)

                  RETURN
              END
        END

      --3. if nothing then all duniya    
      SET @txt = '%' + @txt + '%'

      --1. sp name + table name     
      SELECT DISTINCT [name],
                      CASE
                        WHEN xtype = 'u' THEN 'Table name'
                        WHEN xtype = 'p' THEN 'Stored proc'
                        ELSE 'other obj than table/sp'
                      END AS TYPE
      FROM   sysobjects
      WHERE  name LIKE @txt
      UNION ALL
      -- text in sp     
      SELECT DISTINCT Object_name(id),
                      'text in this SP'
      FROM   dbo.syscomments
      WHERE  TEXT LIKE @txt
      UNION ALL
      -- in column names     
      SELECT DISTINCT Object_name([id]),
                      'Column:' + CONVERT(VARCHAR, [name])
      FROM   syscolumns
      WHERE  name LIKE @txt
             AND Objectproperty (id, 'IsUserTable') = 1
      ORDER  BY 2 DESC,
                1
  END  
    

go

