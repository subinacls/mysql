drop procedure outTCP;
drop procedure outUDP;
drop procedure outICMP;
drop event hourlydump;

delimiter //
create procedure outTCP()
BEGIN
	drop TEMPORARY table if exists tmp_outfile;
	create TEMPORARY table tmp_outfile AS (select * from TCP);
	select @tcpdump:=concat("select 'date','dstmac','srcmac','ethproto','ethver','ttl','ipproto','srcip','dstip','sport','dport','seqnum','acknum','datalen','data' union all select date,dstmac,srcmac,ethproto,ethver,ttl,ipproto,srcip,dstip,sport,dport,seqnum,acknum,datalen,data INTO OUTFILE '/var/lib/mysql-files/TCP_DUMP_",DATE_FORMAT(NOW(),'%Y_%m_%d_%H_%m'),".csv' FIELDS TERMINATED BY ',' FROM tmp_outfile;");
	prepare stmt from @tcpdump;
	execute stmt;
END//
create procedure outUDP()
BEGIN
	drop TEMPORARY table if exists tmp_outfile;
	create TEMPORARY table tmp_outfile AS (select * from UDP);
	select @udpdump:=concat("select 'date','dstmac','srcmac','ethproto','ethver','ttl','ipproto','srcip','dstip','sport','dport','datalen','data' union all select date,dstmac,srcmac,ethproto,ethver,ttl,ipproto,srcip,dstip,sport,dport,datalen,data INTO OUTFILE '/var/lib/mysql-files/UDP_DUMP_",DATE_FORMAT(NOW(),'%Y_%m_%d_%H_%m'),".csv' FIELDS TERMINATED BY ',' FROM tmp_outfile;");
	prepare stmt from @udpdump;
	execute stmt;
END//
create procedure outICMP()
BEGIN
	drop TEMPORARY table if exists tmp_outfile;
	create TEMPORARY table tmp_outfile AS (select * from ICMP);
	select @icmpdump:=concat("select 'date','dstmac','srcmac','ethproto','ethver','ttl','ipproto','srcip','dstip','datalen','data' union all select date,dstmac,srcmac,ethproto,ethver,ttl,ipproto,srcip,dstip,datalen,data INTO OUTFILE '/var/lib/mysql-files/ICMP_DUMP_",DATE_FORMAT(NOW(),'%Y_%m_%d_%H_%m'),".csv' FIELDS TERMINATED BY ',' FROM tmp_outfile;");
	prepare stmt from @icmpdump;
	execute stmt;
END//
delimiter ;
CREATE EVENT dailydump
ON SCHEDULE EVERY 24 HOURS
DO
	call outTCP();
	call outUDP();
	call outICMP();

