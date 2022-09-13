
/*
***
**** S4M Security Example Script.
*** Identity column check.
*/


IF SUBSTRING('##tableCheck',1,1)='#'
BEGIN
	IF OBJECT_ID('tempdb..'+'##tableCheck') IS NOT NULL EXECUTE ('DROP TABLE tempdb..'+'##tableCheck')
END ELSE
BEGIN
	IF OBJECT_ID('##tableCheck') IS NOT NULL EXECUTE ('DROP TABLE '+'##tableCheck')
END

create table ##tableCheck(
	 table_name varchar(50)
	,column_name varchar(50)
	,last_rec_number integer
	,identity_number integer
)

declare @tableName varchar(50)
declare @columnName varchar(50)
declare @identity_deger sql_variant
declare @SQL varchar(1000)


declare tbl_cursor cursor for select IT.name, IC.name ,isnull(IC.last_value,0) as last_value FROM sys.identity_columns IC inner join sys.tables IT on IT.object_id = IC.object_id
open tbl_cursor fetch next from tbl_cursor into @tableName, @columnName, @identity_deger

while @@FETCH_STATUS = 0 
begin
	
	set @SQL = 'insert into ##tableCheck (table_name,column_name, last_rec_number,identity_number ) values ('''+@tableName+''', '''+@columnName+''' ,(select isnull(max('+@columnName+'),0) from '+@tableName+') ,'+convert(varchar(50),@identity_deger)+' )';	
	exec(@SQL)

	fetch next from tbl_cursor into @tableName, @columnName, @identity_deger
end

close tbl_cursor
deallocate tbl_cursor


select * from ##tableCheck where (last_rec_number + 1) < identity_number