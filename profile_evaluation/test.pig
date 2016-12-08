pyid = LOAD '$seed' AS (pyid:chararray, cate_id:chararray,score:chararray);
run -param log_name=raw_log_imp -param src_folder='$imp' /data/production/data_report/opt_reports/PigCommon/load_express_impclk.pig;
run -param log_name=raw_log_clk -param src_folder='$click' /data/production/data_report/opt_reports/PigCommon/load_express_impclk.pig;

--提取imp字段
imp = filter raw_log_imp by IdCompanyId is not null  and UserId is not null;
imp = foreach imp generate ActionFirstId as acid, IdCompanyId as cid, UserId as pyid, ActionPlatform as plat, com.ipinyou.pig.udfs.SparseDomainFromUrl(AgentUrl) as domain, AdUnitWidth as width, AdUnitHeight as high, IdAdUnitId as aduid, AgentAppId as appid;
pimp = join imp by pyid, pyid by pyid ;
pimp = foreach pimp generate acid,cid, imp::pyid as pyid, plat, domain, width, high, aduid, appid, score, cate_id;

--和click匹配
clk = filter raw_log_clk by IdCompanyId is not null  and UserId is not null;
pclk = join  pimp by acid left outer , clk by ActionFirstId;
res = foreach pclk generate acid, ActionId ,cid, pyid, plat, domain, width, high, aduid, appid, score,cate_id, ($16 is not null?'1':'0') as is_click; 

--res = distinct res;

store res into '$out';
