--vw_resumo_diario





-- consulta base WP tabela padrao
WITH BASE AS (
SELECT a.*,replace(upper(`facily-817c2.facily_wp_logistic_aux.fnc_REMOVE_ACENTOS`(place_name)),';','') as place_name2 from `facily-817c2.facily_wp_logistic.log_pedidos_logistica` a 
)

-- consulta pedidos que estao na reversa
, em_reversa as (
select distinct y.* from `facily-817c2.facily_wp_logistic_aux.tb_dados_reversa_v2` y
where y.tempo_entre_carreg_entrada_CD > 4
and date(y.data_entrada_CD) = current_date('America/Sao_Paulo')-1
)

--select * from revisao_status 
--where regiao is null
--and tipo_filial = '3P'
--and date(wc_waiting_vend_acpt_revisado) = current_date('America/Sao_Paulo')-1


SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'01 - Vendas' dado
,date(wc_waiting_vend_acpt) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from wc_waiting_vend_acpt)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from wc_waiting_vend_acpt))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base
where date(wc_waiting_vend_acpt) = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'02 - Separacao' dado
,date(in_separation) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from in_separation)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from in_separation))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base
where date(in_separation) = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT
a.tipo_filial
,a.regiao
,a.categoria
,a.onboarding_auto
,case when a.categoria = 'flv'
      then 'FLV'
      else a.filial
      end as filial
,a.place_name2
,case when date(a.data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,case when r.em_reversa is not null
      then '05 - Reversa'
      else '03 - Pronto para Despacho'
      end dado
,date(a.ready_dispatch) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from a.ready_dispatch)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from a.ready_dispatch))
      end as semana_ref
,count(a.pedido) as contagem_pedidos
FROM base a
    left join em_reversa r
    on r.pedido = a.pedido
    and r.motivo_reversa is null
where date(a.ready_dispatch) = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT
a.tipo_filial
,a.regiao
,a.categoria
,a.onboarding_auto
,case when a.categoria = 'flv'
      then 'FLV'
      else a.filial
      end as filial
,a.place_name2
,case when date(a.data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,case when r.em_reversa is not null
      then '05 - Reversa'
      else '03 - Pronto para Despacho'
      end dado
,date(a.om_deliver_fail) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from a.om_deliver_fail)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from a.om_deliver_fail))
      end as semana_ref
,count(a.pedido) as contagem_pedidos
FROM base a
    left join em_reversa r
    on r.pedido = a.pedido
where date(a.om_deliver_fail) = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'04 - Recebido na Facily' dado
,date(first_entrada_cd) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from first_entrada_cd)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from first_entrada_cd))
      end as semana_ref
,count(case when tipo_filial = '3P'
            then pedido
            else null 
            end) as contagem_pedidos
FROM base 
where date(first_entrada_cd) = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11
 
union all 
/* retirado dados de hubs 26-04-2022
SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'05 - Carregado para HUB' dado
,date(data_transf_CD_HUB) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from data_transf_CD_HUB)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from data_transf_CD_HUB))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base 
where date(data_transf_CD_HUB)  = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'06 - Saldo transferencia HUB' dado
,date(current_date('America/Sao_Paulo')-1) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from current_date('America/Sao_Paulo')-1)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from current_date('America/Sao_Paulo')-1))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base 
where date(data_transf_CD_HUB) > '2021-11-11'
and data_chegada_transf is null
and status_atual_OM not in ('wc-delivery_finished','wc-ready-collect','wc-cancelled','wc-refunded','wc-returned','wc-in-route-rua')
group by 1,2,3,4,5,6,7,8,9,10,11

union all

SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'07 - Recebido no HUB' dado
,date(data_chegada_transf) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from data_chegada_transf)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from data_chegada_transf))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base 
where date(data_chegada_transf)  = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all 
*/
SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'06 - Carregado para PDR' dado
,date(in_route_rua) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from in_route_rua)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from in_route_rua))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base 
where date(in_route_rua) = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all

-- 06 - realocados
SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'07 - Realocados' dado
,date(b.data_evento) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from b.data_evento)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from b.data_evento))
      end as semana_ref
,count(base.pedido) as contagem_pedidos
FROM base, `facily-817c2.facily_wp_logistic_aux.tb_dados_realocacao` b
where date(b.data_evento) = current_date('America/Sao_Paulo')-1
and base.pedido = safe_cast(b.pedido as int64)
group by 1,2,3,4,5,6,7,8,9,10,11


union all 

SELECT
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'08 - Entregue no PDR' dado
,case when ready_collect is null and delivery_finished is not null
      then date(delivery_finished)
      else date(ready_collect)
      end as data_ref
,case when ready_collect is null and delivery_finished is not null
      then case when concat('SEM - ',extract(week(SUNDAY) from delivery_finished)) = 'SEM - 0'
                then 'SEM - 52'
                else concat('SEM - ',extract(week(SUNDAY) from delivery_finished))
                end
      else case when concat('SEM - ',extract(week(SUNDAY) from ready_collect)) = 'SEM - 0'
                then 'SEM - 52'
                else concat('SEM - ',extract(week(SUNDAY) from ready_collect))
                end
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base
where date(ready_collect) = current_date('America/Sao_Paulo')-1 or (ready_collect is null and date(delivery_finished) = current_date('America/Sao_Paulo')-1)
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT
tipo_filial
,regiao
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,onboarding_auto
,Filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'09 - Finalizados' dado
,date(delivery_finished) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from delivery_finished)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from delivery_finished))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base
where date(delivery_finished) = current_date('America/Sao_Paulo')-1
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT 
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'10 - Cancelados' dado
,date(wc_cancelled) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from wc_cancelled)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from wc_cancelled))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base
where date(wc_cancelled) = current_date('America/Sao_Paulo')-1
and wc_waiting_vend_acpt is not null
group by 1,2,3,4,5,6,7,8,9,10,11

union all 

SELECT 
tipo_filial
,regiao
,categoria
,onboarding_auto
,case when categoria = 'flv'
      then 'FLV'
      else filial
      end as filial
,place_name2
,case when date(data_pedido) < '2021-11-12'
      then 'ANTERIOR A 12/11/21'
      else 'POSTERIOR A 11/11/21'
      end as tipo_backlog
,'' as HUB
,'10 - Cancelados' dado
,date(wc_refunded) data_ref
,case when concat('SEM - ',extract(week(SUNDAY) from wc_refunded)) = 'SEM - 0'
      then 'SEM - 52'
      else concat('SEM - ',extract(week(SUNDAY) from wc_refunded))
      end as semana_ref
,count(pedido) as contagem_pedidos
FROM base
where date(wc_refunded) = current_date('America/Sao_Paulo')-1
and wc_waiting_vend_acpt is not null
group by 1,2,3,4,5,6,7,8,9,10,11

