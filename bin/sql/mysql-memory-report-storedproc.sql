#####################################################################
## NAME: memory_report_sp.sql
## AUTHOR: Madeline Everett
## LICENSE: GPL v3
##
## INSTALL METHODS: 
##  a) install via linux shell
##     $> mysql --user=root -p mysql < memory_report_sp.sql
##  b) install via mysql command line
##     mysql> use mysql; import memory_report_sp.sql
##
## USAGE:
##  execute the stored procedure to generate the report
##     mysql> use mysql; 
##     mysql> call memory_report();
##
## EXAMPLE OUTPUT:
##  [localhost mysql://root@localhost/mysql > call memory_report();
##  +-----------------------------+----------+
##  | VARIABLE                    | VALUE    |
##  +-----------------------------+----------+
##  | TOTAL_BUFFERS_GLOBAL        | 42.00 M  |
##  | TOTAL_BUFFERS_PER_THREAD    | 2.72 M   |
##  | MAX_CONNECTIONS_LIMIT       | 151      |
##  | MAX_CONNECTIONS_USED        | 2        |
##  | MAX_CONNECTION_USED_PERCENT | 1.32 %   |
##  | TOTAL_MEMORY_LIMIT          | 452.53 M |
##  | TOTAL_MEMORY_ACTIVE         | 47.44 M  |
##  | TOTAL_MEMORY_ACTIVE_PERCENT | 10.48 %  |
##  | HEAP_TABLE_LIMIT            | 16.00 M  |
##  | TEMP_TABLE_LIMIT            | 16.00 M  |
##  +-----------------------------+----------+
##  10 rows in set (0.02 sec)
#####################################################################

DELIMITER $$
DROP PROCEDURE IF EXISTS `memory_report` $$
CREATE PROCEDURE `memory_report` ()
BEGIN


#####################################################################
## Declare some variables
#####################################################################
DECLARE SUM_SGA BIGINT UNSIGNED;
DECLARE SUM_PGA BIGINT UNSIGNED;
DECLARE MAX_CONNECTIONS_LIMIT INT;
DECLARE MAX_CONNECTIONS_USED INT;
DECLARE CONNECTION_RATIO FLOAT;
DECLARE TOTAL_HEAP BIGINT UNSIGNED;
DECLARE TOTAL_TEMPTABLE BIGINT UNSIGNED;
DECLARE k VARCHAR(255);
DECLARE v BIGINT UNSIGNED;
DECLARE TICK BOOL;

DECLARE MEM_LIMIT BIGINT UNSIGNED;
DECLARE MEM_USED BIGINT UNSIGNED;
DECLARE MEM_PERC FLOAT;
DECLARE MAX_CONNECTION_USED_PERCENT FLOAT;

#####################################################################
## Declare the queries
#####################################################################
DECLARE GLOBALS CURSOR FOR SELECT 
	VARIABLE_NAME, VARIABLE_VALUE
	FROM INFORMATION_SCHEMA.GLOBAL_VARIABLES
	WHERE VARIABLE_NAME IN
		('query_cache_size',
		'key_buffer_size',
		'innodb_buffer_pool_size',
		'innodb_additional_mem_pool_size',
		'innodb_log_buffer_size',
		'read_buffer_size',
		'read_rnd_buffer_size',
		'sort_buffer_size',
		'thread_stack',
		'join_buffer_size',
		'binlog_cache_size',
		'max_connections',	
		'max_heap_table_size',
		'tmp_table_size') 
	UNION
	SELECT VARIABLE_NAME, VARIABLE_VALUE
	FROM INFORMATION_SCHEMA.GLOBAL_STATUS
	WHERE VARIABLE_NAME IN
		('max_used_connections');


DECLARE CONTINUE HANDLER FOR NOT FOUND SET TICK = 1;


#####################################################################
## Set default values
#####################################################################
SET SUM_SGA = 0;
SET SUM_PGA = 0;
SET MAX_CONNECTIONS_LIMIT = 0;
SET MAX_CONNECTIONS_USED = 0;
SET CONNECTION_RATIO = 0;
SET TOTAL_HEAP = 0;
SET TOTAL_TEMPTABLE = 0;


#####################################################################
## Query global variables
#####################################################################
SET TICK = 0;
OPEN GLOBALS;
looper:LOOP
      FETCH GLOBALS INTO k,v;
  IF TICK = 1 THEN
    LEAVE looper;
  END IF;

    IF k in ('query_cache_size','key_buffer_size','innodb_buffer_pool_size','innodb_additional_mem_pool_size','innodb_log_buffer_size') 
       THEN SET SUM_SGA = SUM_SGA + v;
    ELSEIF k in ('read_buffer_size','read_rnd_buffer_size','sort_buffer_size','thread_stack','join_buffer_size','binlog_cache_size') 	
       THEN SET SUM_PGA = SUM_PGA + v;
    ELSEIF k in ('max_connections') THEN SET MAX_CONNECTIONS_LIMIT = v;
    ELSEIF k in ('max_heap_table_size') THEN SET TOTAL_HEAP = v;
    ELSEIF k in ('tmp_table_size','max_heap_table_size')
     THEN SET TOTAL_TEMPTABLE = IF ((TOTAL_TEMPTABLE > v), TOTAL_TEMPTABLE, v);
    ELSEIF k in ('max_used_connections') THEN SET MAX_CONNECTIONS_USED = v;

    END IF;

END LOOP;
CLOSE GLOBALS;


#####################################################################
## Output report
#####################################################################
SET MEM_LIMIT = ROUND((SUM_SGA + (MAX_CONNECTIONS_LIMIT * SUM_PGA))/POW(1024,2),2); 
SET MEM_USED = ROUND((SUM_SGA + (MAX_CONNECTIONS_USED * SUM_PGA))/POW(1024,2),2);
SET MEM_PERC = ROUND((MEM_USED * 100)/MEM_LIMIT,2);
SET MAX_CONNECTION_USED_PERCENT = ROUND((MAX_CONNECTIONS_USED * 100)/MAX_CONNECTIONS_LIMIT,2);

SELECT "GLOBAL_BUFFERS_TOTAL" AS VARIABLE, CONCAT(ROUND(SUM_SGA/POW(1024,2),2),' M') AS VALUE UNION
SELECT "THREAD_BUFFERS_TOTAL", CONCAT(ROUND((SUM_PGA * MAX_CONNECTIONS_LIMIT)/POW(1024,2),2),' M') UNION
SELECT "THREAD_BUFFERS_EACH", CONCAT(ROUND(SUM_PGA/POW(1024,2),2),' M') UNION

SELECT "MAX_CONNECTIONS_LIMIT", MAX_CONNECTIONS_LIMIT UNION
SELECT "MAX_CONNECTIONS_USED", MAX_CONNECTIONS_USED UNION
SELECT "MAX_CONNECTION_USED_PERCENT", CONCAT(MAX_CONNECTION_USED_PERCENT, ' %') UNION

SELECT "MEMORY_UTILIZATION_LIMIT", CONCAT(MEM_LIMIT,' M') UNION
SELECT "MEMORY_UTILIZATION_ACTIVE", CONCAT(MEM_USED,' M') UNION
SELECT "MEMORY_UTILIZATION_RATIO", CONCAT(MEM_PERC,' %') UNION

SELECT "HEAP_TABLE_LIMIT", CONCAT(ROUND(TOTAL_HEAP / POW(1024,2),2),' M') UNION
SELECT "TEMP_TABLE_LIMIT", CONCAT(ROUND(TOTAL_TEMPTABLE / POW(1024,2),2),' M') ;

END $$
DELIMITER ;
