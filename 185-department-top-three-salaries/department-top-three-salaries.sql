select
    Department,
    Employee,
    Salary
from
    (select
        d.name as Department,
        e.name as Employee,
        e.salary as Salary,
        dense_rank() over(partition by departmentId order by salary desc) as rnk
    from
        employee e
    inner join department d 
    on e.departmentId = d.id
    )emp_dept_ranked
where rnk <= 3
order by 1 asc

