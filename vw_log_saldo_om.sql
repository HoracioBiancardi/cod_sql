








--vw_log_saldo_om 


with base as (
SELECT    
CURRENT_DATE ()-1 AS data
,*                                                                            
FROM  `facily-817c2.facily_wp_logistic.log_pedidos_logistica`  
where date(data_pedido) > '2021-11-12'

)


select
Data
,case 
      when date(data_pedido) >='2021-11-12' and date(data_pedido) <'2022-02-01' then 'A PARTIR DE 11/11'
      when date(data_pedido) >='2022-02-01' Then 'Apartir de 01/02/2022'end as tipo_pedido
,tipo_filial
,id_filial as seller_id
,replace(upper(`facily-817c2.facily_wp_logistic_aux.fnc_REMOVE_ACENTOS`(p2.post_title)),';','') AS seller_name
 
       ,COALESCE((select wp11.meta_value from `facily-817c2.facily_wp_logistic.wp_postmeta` wp11
                where  wp11.post_id = cast(base.id_filial as INT64)
                AND   wp11.meta_key = 'address_postcode'
                and wp11.meta_id = (select max(wpd.meta_id) from `facily-817c2.facily_wp_logistic.wp_postmeta` wpd where wpd.post_id = wp11.post_id and wpd.meta_key = wp11.meta_key))) as CEP
      ,COALESCE((select wp12.meta_value from `facily-817c2.facily_wp_logistic.wp_postmeta` wp12
                where  wp12.post_id = cast(base.id_filial as INT64)
                AND   wp12.meta_key = 'address_1'
                and wp12.meta_id = (select max(wpd.meta_id) from `facily-817c2.facily_wp_logistic.wp_postmeta` wpd where wpd.post_id = wp12.post_id and wpd.meta_key = wp12.meta_key))) as Endereco
      ,COALESCE((select wp13.meta_value from `facily-817c2.facily_wp_logistic.wp_postmeta` wp13
                where  wp13.post_id = cast(base.id_filial as INT64)
                AND   wp13.meta_key = 'address_neighborhood'
                and wp13.meta_id = (select max(wpd.meta_id) from `facily-817c2.facily_wp_logistic.wp_postmeta` wpd where wpd.post_id = wp13.post_id and wpd.meta_key = wp13.meta_key))) as Bairro
      ,COALESCE((select wp14.meta_value from `facily-817c2.facily_wp_logistic.wp_postmeta` wp14
                where  wp14.post_id = cast(base.id_filial as INT64)
                AND   wp14.meta_key = 'address_city'
                and wp14.meta_id = (select max(wpd.meta_id) from `facily-817c2.facily_wp_logistic.wp_postmeta` wpd where wpd.post_id = wp14.post_id and wpd.meta_key = wp14.meta_key))) as Cidade  
,Regiao
,p2.post_status AS status_seller
,case when status_atual_om = 'wc-delivery_finished'
      then 'DELIVERY FINISHED'
      when status_atual_om = 'wc-waiting_vend_acpt'
      then 'WAITING VENDOR ACCEPT'
      when status_atual_om = 'wc-ready-dispatch'
      then 'READY DISPATCH'
      when status_atual_om = 'wc-ready-collect'
      then 'READY COLLECT'
      when status_atual_om = 'wc-in-separation'
      then 'IN SEPARATION'
      when status_atual_om = 'wc-in-route-cd'
      then 'IN ROUTE CD'
      when status_atual_om = 'wc-in-route-rua'
      then 'IN ROUTE RUA'
      when status_atual_om = 'wc-cancelled'
      then 'CANCELLED'
      else 'NAO CLASSIFICADO'
      end as status_atual
, sum(case when flag_cd is not null then 1 else 0 end) as FLAG_CD
,round(avg(case when flag_CD is not null and flag_CD > wc_waiting_vend_acpt then date_diff(flag_cd,wc_waiting_vend_acpt,Day) else null end),2) as LT_Waiting_Flag
 ,round(avg(case when FLAG_CD is not null
                then CASE WHEN in_route_rua IS NOT NULL AND status_atual_om in ('wc-in-route','wc-in-route-rua')
                          THEN DATE_DIFF(current_datetime('America/Sao_Paulo'), cast(in_route_rua AS datetime), DAY)
                          ELSE  DATE_DIFF(current_datetime('America/Sao_Paulo'), cast(dt_ult_modificacao AS datetime), DAY)
                          END
                     else null
                     end),2) AS Lead_Time_com_flag
,round(avg(case when FLAG_CD is null
                then CASE WHEN in_route_rua IS NOT NULL AND status_atual_om in ('wc-in-route','wc-in-route-rua')
                          THEN DATE_DIFF(current_datetime('America/Sao_Paulo'), cast(in_route_rua AS datetime), DAY)
                          ELSE  DATE_DIFF(current_datetime('America/Sao_Paulo'), cast(dt_ult_modificacao AS datetime), DAY)
                          END
                     else null
                     end ),2)AS Lead_Time_sem_flag
,round(avg(CASE WHEN in_route_rua IS NOT NULL AND status_atual_om in ('wc-in-route','wc-in-route-rua')
                THEN DATE_DIFF(current_datetime('America/Sao_Paulo'), cast(in_route_rua AS datetime), DAY)
                ELSE  DATE_DIFF(current_datetime('America/Sao_Paulo'), cast(dt_ult_modificacao AS datetime), DAY)
                END),2) AS Lead_Time,
   
              round(avg(case   when (flag_CD is null or flag_cd < wc_waiting_vend_acpt) and status_atual_OM in ('wc-waiting_vend_acpt','wc-ready-dispatch','wc-in-separation') then date_diff(Current_Date(),wc_waiting_vend_acpt,Day)
                     when (flag_cd is null  or flag_cd < wc_waiting_vend_acpt) and status_atual_OM not in ('wc-waiting_vend_acpt','wc-ready-dispatch','wc-in-separation') then null 
                     when (flag_cd is not null and flag_cd > wc_waiting_vend_acpt) and ready_collect is not null then date_diff(flag_CD,wc_waiting_vend_acpt,day)
                      when (flag_cd is not null and flag_cd > wc_waiting_vend_acpt )and ready_collect is null then date_diff(flag_CD,wc_waiting_vend_acpt,day)
                      end),2) as LT_SELLER,

               round(avg(case   when flag_CD is null or flag_cd < wc_waiting_vend_acpt or status_atual_OM in ('wc-waiting_vend_acpt','wc-ready-dispatch','wc-in-separation') then null
                     --when flag_cd is null  or flag_cd < wc_waiting_vend_acpt or status_atual_OM not in ('wc-waiting_vend_acpt','wc-ready-dispatch','wc-in-separation') then null 
                     when (flag_cd is not null and flag_cd > wc_waiting_vend_acpt) and ready_collect is not null then date_diff(ready_collect,flag_cd,day)
                      when (flag_cd is not null and flag_cd > wc_waiting_vend_acpt )and ready_collect is null then date_diff(current_Date(),flag_CD,day)
                      end),2) as LT_LOGISTICA,

                       round(avg(case   when (flag_CD is null or flag_cd < wc_waiting_vend_acpt) and status_atual_OM in ('wc-waiting_vend_acpt','wc-ready-dispatch','wc-in-separation') then date_diff(Current_Date(),wc_waiting_vend_acpt,Day)
                     when (flag_cd is null  or flag_cd < wc_waiting_vend_acpt) and status_atual_OM not in ('wc-waiting_vend_acpt','wc-ready-dispatch','wc-in-separation') then  date_diff(Current_Date(),wc_waiting_vend_acpt,Day)
                     when (flag_cd is not null and flag_cd > wc_waiting_vend_acpt) and ready_collect is not null then date_diff(ready_collect,wc_waiting_vend_acpt,day)
                      when (flag_cd is not null and flag_cd > wc_waiting_vend_acpt )and ready_collect is null then date_diff(current_Date(),wc_waiting_vend_acpt,day)
                      end),2) as LT_TOTAL             


           
,count(pedido) as Quantidade  
from base
LEFT JOIN `facily-817c2.facily_wp_logistic.wp_posts` p2
ON        p2.id = safe_cast(id_filial AS int64)
where safe_cast(id_filial AS int64) NOT IN (1164213,18314680,18315285,33496964,43703269,43703262,43703140,43774751,43774886,43774863,173538,1446483,225022,9074606,225023,33349035,33187924,40448202,41855661,42920355,19842413,331313)
and status_atual_OM in ('wc-delivery_finished','wc-waiting_vend_acpt','wc-ready-dispatch','wc-ready-collect','wc-in-separation','wc-in-route','wc-in-route-rua','wc-cancelled','wc-in-route-cd')
group by 1,2,3,4,5,6,7,8,9,10,11,12
