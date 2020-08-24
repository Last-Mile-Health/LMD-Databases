-- Steps to adding access lists to lastmile_ncha for existing users

-- Step 1: login into linux command line as lastmiledata
-- Step 2: connect to MySQL command line from linux command line as root localhost
--        mysql --user=root  --password=LastMile14 --host=localhost
-- Step 3. Run these commands for every user.  They need to exisit first

-- select * from mysql.user
-- select * from mysql.db
 
/*

grant select, show view on `lastmile\_ncha`.* to 'lastmile_XYZ'@'%';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_XYZ'@'ip-166-62-33-107.secureserver.net';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_XYZ'@'166.62.33.107';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_XYZ'@'locahost';


grant select, show view on `lastmile\_ncha`.* to 'lastmile_jgargar'@'%';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jgargar'@'ip-166-62-33-107.secureserver.net';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jgargar'@'166.62.33.107';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jgargar'@'locahost';

grant select, show view on `lastmile\_ncha`.* to 'lastmile_ewhite'@'%';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_ewhite'@'ip-166-62-33-107.secureserver.net';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_ewhite'@'166.62.33.107';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_ewhite'@'locahost';

*/



grant select, show view on `lastmile\_ncha`.* to 'lastmile_mckenna'@'%';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_mckenna'@'ip-166-62-33-107.secureserver.net';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_mckenna'@'166.62.33.107';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_mckenna'@'locahost';
flush privileges;

grant select, show view on `lastmile\_ncha`.* to 'lastmile_jkrause'@'%';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jkrause'@'ip-166-62-33-107.secureserver.net';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jkrause'@'166.62.33.107';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jkrause'@'locahost';
flush privileges;

grant select, show view on `lastmile\_ncha`.* to 'lastmile_ngordon'@'%';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_ngordon'@'ip-166-62-33-107.secureserver.net';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_ngordon'@'166.62.33.107';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_ngordon'@'locahost';
flush privileges;

grant select, show view on `lastmile\_ncha`.* to 'lastmile_jdowney'@'%';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jdowney'@'ip-166-62-33-107.secureserver.net';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jdowney'@'166.62.33.107';
grant select, show view on `lastmile\_ncha`.* to 'lastmile_jdowney'@'locahost';
flush privileges;




/*

user:		lastmile_mckenna
password:	coR^xF8i@.r3

user:		lastmile_guest
password:	PC4^B}1mlbLW

user:		lastmile_jkrause
password:	UOzP{)KO[ld^


user: 		lastmile_ngordon
password:	4WPWsfp)mX-t
		 
user:		lastmile_jdowney
password:	PRryzY(bO^j-


*/



flush privileges;



/* Revoking those same privileges...

revoke select, show view on `lastmile\_ncha`.* from 'lastmile_jgargar'@'%';
revoke select, show view on `lastmile\_ncha`.* from 'lastmile_jgargar'@'ip-166-62-33-107.secureserver.net';
revoke select, show view on `lastmile\_ncha`.* from 'lastmile_jgargar'@'166.62.33.107';
revoke select, show view on `lastmile\_ncha`.* from 'lastmile_jgargar'@'locahost';

*/


flush privileges;

