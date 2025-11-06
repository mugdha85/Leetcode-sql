# Write your MySQL query statement below

with trans_agg as
(select
    count(id) as 'approved_count',
    country,
    sum(amount) as 'approved_amount',
    DATE_FORMAT(Transactions.trans_date,'%Y-%m') as 'month'
from
    Transactions
where state = 'approved'
group by    
    DATE_FORMAT(Transactions.trans_date,'%Y-%m'),
    country
)  
,
chbk_agg_amt as
    (
        select
            count(c.trans_id) as chargeback_count,
            t.country,
            DATE_FORMAT(c.trans_date,'%Y-%m') as 'charge_back_month',
            sum(t.amount) as 'chargeback_amount'
        from
            Transactions t 
        inner join Chargebacks c
        on t.id = c.trans_id
        group by
            t.country,
            DATE_FORMAT(c.trans_date,'%Y-%m')
    )  
select
    trans_agg.month,
    trans_agg.country,
    approved_count,
    approved_amount,
    ifnull(chargeback_count,0) as chargeback_count,
    ifnull(chargeback_amount,0) as chargeback_amount
from
    trans_agg
left join
    chbk_agg_amt
on 
    trans_agg.month = chbk_agg_amt.charge_back_month
and 
    trans_agg.country = chbk_agg_amt.country

union
    select
    chbk_agg_amt.charge_back_month as month,
    chbk_agg_amt.country,
    ifnull(approved_count,0) as approved_count,
    ifnull(approved_amount,0) as approved_amount,
    chargeback_count,
    chargeback_amount
from
    trans_agg
right join
    chbk_agg_amt
on 
    chbk_agg_amt.charge_back_month = trans_agg.month
and 
    trans_agg.country = chbk_agg_amt.country