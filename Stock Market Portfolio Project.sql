-- Exploring and ordering data

Select distinct `Stock Index`
	from dataprojectsql.economy;

Select
	max(`Close Price`) as maxCP,
    max(`Open Price`) as maxOP,
    max(`Daily High`) as maxDH,
    max(`Daily Low`) as maxDL
    from dataprojectsql.economy;

Select*
	from dataprojectsql.economy
    order by 1,2;

-- Cleaning and correcting data
SET SQL_SAFE_UPDATES = 0;

alter table dataprojectsql.economy
	modify column `date` date;

Alter Table dataprojectsql.economy
Add column `index` Decimal(1,0),
add column `close_price_rounded` Decimal(6,2),
add column `daily_high_rounded` Decimal(6,2),
add column `daily_low_rounded` Decimal(6,2);

Update dataprojectsql.economy
Set
close_price_rounded = Round(`Close Price`, 2),
daily_high_rounded = Round(`Daily High`, 2),
daily_low_rounded =  Round(`Daily Low`, 2),
`index` = 
	case
		When `Stock Index` = 'Dow Jones' Then 1
        When `Stock Index` = 'S&P 500' Then 2
        When `Stock Index` = 'NASDAQ' Then 3
	End;

-- Ensuring data is correct
DESC dataprojectsql.economy;

select*
	from dataprojectsql.economy 
    limit 10;

-- Prepare data for visualization and analysis

Create or Replace View dataprojectsql.stocks_monthly_data as 
With daily_change as (Select `date`, `Stock Index`, `Daily low`, `Daily high`, `Close price`,
((`Close Price`- lag(`Close Price`) over (partition by `index` order by date))
/nullif(Lag(`Close Price`) over (partition by `index` order by date),0))*100 as daily_return,
(`Daily High` - `daily low`)/nullif(`close price`,0)*100 as percentage_range
from dataprojectsql.economy
)
Select 
`Stock Index`, Year(`date`) as `year`, month (`date`) as `month`,
avg(daily_return) as avg_monthly_return,
stddev_samp(daily_return) as monthly_volativility,
avg(percentage_range) as avg_monthly_range,
count(daily_return) as n_month
from daily_change
Where daily_return is not null
group by `Stock Index`, Year(`date`), month(`date`);

-- Review new table
select*
	from dataprojectsql.stocks_monthly_data
    limit 200;
    
Select distinct `Stock Index`
	from dataprojectsql.stocks_monthly_data;

SET SQL_SAFE_UPDATES = 1;
