/*
============================================================
1-2 과제. order_items 실행계획 해석
============================================================
[문제 설명]
order_items에서 product_id가 100인 주문상품을 조회하고,
EXPLAIN과 EXPLAIN ANALYZE를 이용해 실행계획을 직접 분석하세요.

※ 새로운 최적화 기법을 적용하는 문제가 아니라,
   필수 문제에서 배운 실행계획 읽기 방법을 반복 적용하는 문제입니다.

[요구사항]
1. order_items에서 product_id = 100인 행을 조회하세요.
2. 다음 컬럼을 출력하세요.
   - order_item_id
   - order_id
   - product_id
   - qty
   - price
3. 같은 SELECT문에 EXPLAIN을 적용하세요.
4. 같은 SELECT문에 EXPLAIN ANALYZE를 적용하세요.
5. 다음 항목을 확인해 기록하세요.
   - 스캔 방식
   - cost의 시작 비용 : 0
   - cost의 총 비용 : 6947
   - 예상 rows : 25
   - actual rows : 16
   - Rows Removed by Filter : 199984
   - Execution Time : 132.921ms
6. 예상 rows와 actual rows를 비교하여
   옵티마이저의 예상이 실제 결과와 어느 정도 일치하는지 설명하세요.
   - 예상치인 25보다 실제 결과가 16으로 예상치가 실제 결과보다 다소 높게 추정되었다.
7. 다음 질문에 답하세요.
   Q1. 가장 먼저 확인해야 할 데이터 접근 방식은 무엇인가요?
   - order_items 테이블에 대해 Parallel Seq Scan 방식으로 접근하고 있다.
   
   Q2. Seq Scan은 테이블의 데이터를 어떤 방식으로 확인하나요?
   - 테이블의 데이터를 순서대로 읽으면서 각 행이 product_id = 100 조건을 만족하는지 확인한다.

[제출 결과]
- SELECT문
- EXPLAIN SQL
- EXPLAIN ANALYZE SQL
- 주요 실행계획 항목
- 예상 rows와 actual rows 비교
- Q1~Q2 답변
*/

-- [코드 작성란]
select *
from order_items oi  
where product_id = 100;

explain
select *
from order_items oi  
where product_id = 100;

explain analyze
select *
from order_items oi  
where product_id = 100;

/*
============================================================
2-1 과제. 범위 검색에서 B-Tree 인덱스 확인
============================================================
[문제 설명]
products.price에 B-Tree 인덱스를 생성하고
price가 100 이상 120 미만인 범위 조회의 실행계획을 비교하세요.

※ 필수 문제와 동일한 수준의 독립 실습입니다.

[요구사항]
1. products.price의 최솟값과 최댓값을 확인하세요.
2. idx_products_price 인덱스가 있다면 삭제하세요.
3. price >= 100 AND price < 120 조건에 EXPLAIN ANALYZE를 적용하세요.
4. 인덱스 생성 전 다음 항목을 기록하세요.
   - 스캔 방식
   - cost
   - actual rows
   - Execution Time
5. products.price에 idx_products_price 인덱스를 생성하세요.
6. 동일한 SELECT문에 다시 EXPLAIN ANALYZE를 적용하세요.
7. 인덱스 생성 후 다음 항목을 기록하세요.
   - 스캔 방식
   - cost
   - actual rows
   - Execution Time
8. 인덱스 생성 전후 결과를 비교하세요.
9. 실습이 끝나면 idx_products_price 인덱스를 삭제하세요.
10. 다음 질문에 답하세요.
    Q1. B-Tree 인덱스는 등호 검색 외에 어떤 비교 조건에 활용될 수 있나요?
    Q2. B-Tree 인덱스가 범위 검색에서 검색 범위를 줄일 수 있는 이유는 무엇인가요?
    Q3. 인덱스를 많이 만들수록 INSERT, UPDATE, DELETE 비용이 커질 수 있는 이유는 무엇인가요?

[제출 결과]
- MIN/MAX 확인 SQL
- DROP INDEX 문
- 인덱스 생성 전 EXPLAIN ANALYZE
- 개선 전 기록표
- CREATE INDEX 문
- 인덱스 생성 후 EXPLAIN ANALYZE
- 개선 후 기록표
- 전후 비교
- 최종 DROP INDEX 문
- Q1~Q3 답변
*/

-- [코드 작성란]
--MIN/MAX 확인 SQL
select min(price) as min_price, max(price) as max_price
from products;

--DROP INDEX 문
drop index if exists idx_products_price;

--인덱스 생성 전 EXPLAIN ANALYZE
explain analyze
select price
from products p 
where price >= 100 AND price < 120;

--CREATE INDEX문
create index idx_products_price on products (price);

-- 인덱스 생성 후 EXPLAIN ANALYZE
explain analyze
select price
from products p 
where price >= 100 AND price < 120;

--최종 DROP INDEX
drop index idx_products_price;

/*

인덱스 생성 전 
- 스캔 방식 : Seq Scan
- cost : 0.00..205.00
- actual rows : 35
- Execution Time : 0.309ms

인덱스 생성 후
- 스캔 방식 : Index Only Scan
- cost : 0.29..5.12
- actual rows : 35
- Execution Time : 0.014ms

인덱스 생성 후 동일한 결과를 더 적은 비용과 더 짧은 실행 시간으로 조회할 수 있었다.

Q1 B-Tree 인덱스는 =뿐만 아니라 <, <=, >, >=, BETWEEN과 같은 범위 비교 조건에도 활용될 수 있다.
Q2 B-Tree 인덱스는 값이 정렬된 구조로 관리되기 때문에 범위의 시작 위치를 빠르게 찾고, 필요한 범위의 값만 탐색할 수 있다.
   따라서 테이블의 모든 행을 확인하지 않아도 되어 검색 범위를 줄일 수 있다.
Q3 데이터가 INSERT, UPDATE, DELETE 될 때 테이블의 데이터뿐만 아니라 관련된 인덱스도 함께 갱신해야 하기 때문이다.
   따라서 인덱스가 많을수록 유지해야 하는 인덱스가 증가하여 데이터 변경 작업의 비용이 커질 수 있다.


*/

/*
============================================================
2-2 과제. 작은 테이블의 인덱스 추가 여부 판단하기
============================================================
[문제 설명]
매장 조회 기능에서 특정 도시의 매장을 검색한다고 가정합니다.

stores 테이블은 전체 데이터가 100행으로 매우 작고,
city 컬럼에는 몇 개의 도시만 반복해서 저장되어 있습니다.

실제 데이터 분포와 실행계획을 확인한 뒤
stores.city에 인덱스를 추가하는 것이 효과적인 선택인지 판단하세요.

※ 과제는 필수 문제와 동일한 수준입니다.
   새로운 인덱스 기법을 사용하는 것이 아니라
   이번 강에서 배운 판단 기준을 스스로 적용하는 문제입니다.

[요구사항]
1. stores 테이블의 전체 행 수를 조회하세요.
2. city의 고유값 수를 조회하세요.
3. city별 행 수와 전체에서 차지하는 비율을 조회하세요.
4. 기존 idx_stores_city 인덱스가 있다면 삭제하세요.
5. city = 'Mumbai' 조건에 EXPLAIN ANALYZE를 적용하세요.
6. stores.city에 idx_stores_city 인덱스를 생성하세요.
7. 같은 조건에 다시 EXPLAIN ANALYZE를 적용하세요.
8. 인덱스 생성 전후의 스캔 방식과 Execution Time을 비교하세요.
9. 다음 네 가지 기준으로 stores.city 인덱스의 적절성을 판단하세요.
   - 카디널리티
   - 선택도
   - 테이블 크기
   - 인덱스 유지 비용
10. 최종적으로 "인덱스 추가를 적극적으로 권장한다 / 우선순위가 낮다" 중 하나를 선택하고 근거를 작성하세요.
11. 실습 종료 후 idx_stores_city 인덱스를 삭제하세요.

[제출 결과]
- 데이터 분포 확인 SQL
- 인덱스 생성 전 EXPLAIN ANALYZE
- CREATE INDEX 문
- 인덱스 생성 후 EXPLAIN ANALYZE
- 네 가지 기준에 따른 판단
- 최종 결론
- DROP INDEX 문
*/

-- [코드 작성란]
-- STORES 테이블 전체 행 수: 100개
select count(*)
from stores s ;

--city의 고유값 수: 4개
select count(distinct city)
from stores s ;

--city별 행 수와 차지하는 비율
select city, count(*) as cnt, count(*) * 100 / sum(count(*)) over () as ratio
from stores s 
group by city;
/*
Bangalore: 21행, 21%
Delhi: 21행, 21%
Pune: 27행, 27%
Mumbai: 31행, 31%
 */

drop index if exists idx_stores_city;

explain analyze
select city
from stores
where city = 'Mumbai';

create index idx_stores_city on stores(city);

explain analyze
select city
from stores
where city = 'Mumbai';

drop index idx_stores_city;

/*
8. 인덱스 생성 전후 비교
인덱스 생성 전
- 스캔 방식: Seq Scan
- Execution Time: 0.068ms

인덱스 생성 후
- 스캔 방식: Seq Scan
- Execution Time: 0.057ms

9. 다음 네 가지 기준으로 stores.city 인덱스의 적절성을 판단하세요.
- 카디널리티: stores.city의 카디널리티는 4로, 전체 100행에 비해 고유값의 종류가 적어 카디널리티가 낮다. 
		   이는 같은 city 값이 많이 반복되어 인덱스로 특정 값을 찾아도 많은 행이 연결될 가능성이 커 인덱스로 적절하지 않다.
- 선택도: 검색 범위를 크게 줄이지 않아 인덱스로 적절하지 않다.
- 테이블 크기: 테이블은 전체 100행으로 크기가 매우 작다. 전체 테이블을 순차적으로 조회하는 비용 자체가 작기 때문에 인덱스를 
			이용하는 것보다 Seq Scan이 효율적일 수 있다. 따라서 테이블 크기 측면에서는 인덱스의 필요성이 낮다.
- 인덱스 유지 비용: 인덱스를 생성하면 INSERT, UPDATE, DELETE가 발생할 때 테이블뿐만 아니라 인덱스도 함께 갱신해야 한다.
				현재는 인덱스로 얻을 수 있는 조회 성능 개선이 크지 않은 반면 유지 비용은 추가되므로 유지 비용 측면에서
				인덱스의 적절성이 낮다.

10. 최종판단
인덱스 추가의 우선순위가 낮다. 고유값이 4개로 카디널리티가 낮고, Mumbai 검색 시 전체 100행 중 31행이 조회되어 검색 범위를 크게 줄이지 못한다.
또한 테이블 자체가 100행으로 매우 작아 Seq Scan의 비용도 낮다. 실제 실행 계획에서도 인덱스 생성 후 Index Scan으로 변경되지 않고
Seq Scan이 그대로 사용되었다. 여기에 INSERT, UPDATE, DELETE 시 인덱스 유지 비용도 발생한다.
따라서 stores.city에 인덱스를 추가하는 것은 현재 상황에서는 우선순위가 낮다고 판단할 수 있다.

 */

/*
============================================================
3-1 과제. 여러 단계 분석을 CTE로 구조화하기
============================================================
[문제 설명]
운영팀에서 고객별 구매금액을 계산한 뒤,
총 구매금액이 50,000 이상인 우수 고객만 추려
도시별 우수 고객 수와 구매금액을 집계하려고 합니다.

이번 문제에서는 여러 단계의 로직을 CTE로 나누어
쿼리의 흐름을 명확하게 표현하세요.

※ 과제는 필수 문제와 동일한 수준입니다.
   새로운 SQL 문법을 사용하는 것이 아니라,
   이번 강에서 배운 CTE 구조화를 한 번 더 적용하는 문제입니다.

[요구사항]
1. 첫 번째 CTE customer_totals를 작성하세요.
   - orders와 order_items를 order_id 기준으로 JOIN
   - customer_id별 총 구매금액 계산
   - 총 구매금액 컬럼명은 total_amount
2. 두 번째 CTE high_value_customers를 작성하세요.
   - customer_totals에서 total_amount가 50,000 이상인 고객만 선택
3. high_value_customers와 customers를 customer_id 기준으로 JOIN하세요.
4. 도시별로 다음 값을 계산하세요.
   - 우수 고객 수: vip_customer_count
   - 우수 고객 총 구매금액: vip_total_amount
5. vip_total_amount가 높은 순서대로 정렬하세요.
6. 작성한 전체 CTE 쿼리에 EXPLAIN을 적용하여 실행계획을 확인하세요.
7. 실행계획에서 CTE가 본문에 인라인된 형태인지,
   별도의 CTE Scan이 나타나는지 확인하세요.
8. 다음 질문에 답하세요.
   Q1. 이 문제를 하나의 중첩 서브쿼리로 작성하는 것보다 CTE로 나누었을 때 어떤 장점이 있나요?
   Q2. customer_totals와 high_value_customers라는 이름은 각각 어떤 처리 단계를 의미하나요?
   Q3. 성능 차이가 거의 없다면 CTE와 중첩 서브쿼리 중 어떤 기준으로 구조를 선택하는 것이 좋나요?
   Q4. 이번 EXPLAIN 결과를 기준으로 CTE가 실제 실행 단계에서
       반드시 별도의 중간 결과로 저장되었다고 말할 수 있나요?
       실행계획을 근거로 설명하세요.

[제출 결과]
- 전체 CTE SQL
- 도시별 집계 결과
- EXPLAIN 실행계획
- CTE 인라인 또는 CTE Scan 여부 확인
- Q1~Q4 답변
*/

-- [코드 작성란]
with customer_totals as (
	select o.customer_id, sum(oi.qty * oi.price) as total_amount
	from orders o 
	join order_items oi
		on o.order_id = oi.order_id 
	group by o.customer_id
),
high_value_customers as (
	select *
	from customer_totals
	where total_amount >= 50000
)
select c.city, count(c.customer_id) as vip_customer_count, sum(high_value_customers.total_amount) as vip_total_amount
from high_value_customers
join customers c 
	on c.customer_id = high_value_customers.customer_id
group by c.city 
order by vip_total_amount desc;

explain
with customer_totals as (
	select o.customer_id, sum(oi.qty * oi.price) as total_amount
	from orders o 
	join order_items oi
		on o.order_id = oi.order_id 
	group by o.customer_id
),
high_value_customers as (
	select *
	from customer_totals
	where total_amount >= 50000
)
select c.city, count(c.customer_id) as vip_customer_count, sum(high_value_customers.total_amount) as vip_total_amount
from high_value_customers
join customers c 
	on c.customer_id = high_value_customers.customer_id
group by c.city 
order by vip_total_amount desc;

/*
7.
실행계획을 확인한 결과 별도의 CTE Scan은 나타나지 않았다.
customer_totals는 Subquery Scan 형태로 전체 실행 계획에 포함되어 있으며, high_value_customers의 total_amount >= 50000 조건 역시 집계 과정의 Filter로 적용되어 있다.
따라서 이 쿼리의 CTE들은 별도로 물리화되어 스캔되는 것이 아니라 본문의 실행 계획에 인라인되어 최적화된 것으로 볼 수 있다.

8.
Q1.
CTE를 사용하면 복잡한 쿼리를 의미 있는 처리 단게별로 나눌 수 있어 가독성과 유지보수성이 좋아진다.
또한 문제가 발생했을 때 어느 처리 단게에서 문제가 발생했는지 확인하기도 쉽다.

Q2.
customer_totals는 orders와 order_items를 order_id로 JOIN한 뒤 customer_id별로 그룹화하여 고객별 총 구매금액을 계산하는 집계 단계이다.
high_value_customers는 그 결과에서 total_amount >= 50000인 고객만 선택하는 필터링 단계이다.

Q3.
성능 차이가 거의 없다면 쿼리의 가독성, 유지보수성, 재사용성 등을 기준으로 선택하는 것이 좋다.

Q4.
실행계획을 확인했을 때 별도의 CTE Scan이 나타나지 않았으므로 CTE가 반드시 별도의 중간 결과로 저장되었다고 말할 수 없다.
customer_totals가 Subquery Scan으로 나타나고, high_value_customers 의 조건인 total_amount >=50000도
Finalize HashAggregate의 Filter로 포함되어 있어 CTE를 본문 실행 계획에 인라인하여 하나의 실행계획으로 최적화한 것으로 볼 수 있다.

 */

/*
============================================================
3-2 과제. 주문-배송 복합 데이터셋 구성 및 결과 검증
============================================================
모든 주문을 유지하면서 배송 정보 결합하기

[문제 설명]
물류 운영팀에서 모든 주문을 기준으로 배송 정보를 함께 확인하려고 합니다.

배송 정보가 없는 주문도 결과에서 사라지면 안 되므로,
적절한 JOIN 종류를 선택해야 합니다.

또한 조인 후 주문 수가 의도와 맞는지 검증해야 합니다.

※ 과제는 필수 문제와 동일한 수준입니다.
   이번 강에서 배운 JOIN 종류 선택과 결과 검증을 스스로 적용하는 문제입니다.

[요구사항]
1. orders를 기준 테이블로 사용하세요.
2. customers를 customer_id 기준으로 JOIN하세요.
3. shipments를 order_id 기준으로 연결하되,
   배송 정보가 없는 주문도 유지되도록 적절한 JOIN 종류를 사용하세요.
4. 다음 컬럼을 조회하세요.
   - orders.order_id
   - orders.order_date
   - customers.customer_id
   - customers.city
   - shipments.shipment_id
   - shipments.status
5. orders 전체 행 수를 확인하세요.
6. 최종 조인 결과의 전체 행 수를 확인하세요.
7. shipment_id가 NULL인 주문 수를 확인하세요.
8. order_id별 행 수를 GROUP BY하고,
   2행 이상 나타나는 주문이 있는지 확인하세요.
9. 다음 질문에 답하세요.
   Q1. shipments를 INNER JOIN이 아니라 LEFT JOIN으로 연결해야 하는 이유는 무엇인가요?
   	- INNER JOIN을 하게 되면 배송 정보가 없는 주문은 제외되기 때문에 orders 테이블을 기준으로 LEFT JOIN을 해야 한다.
   	
   Q2. shipment_id가 NULL인 행은 어떤 의미인가요?
   	- 주문 정보는 있으나 배송 정보가 없는 주문을 의미한다.
   	
   Q3. 조인 후 행 수가 orders보다 많아졌다면 어떤 관계나 데이터를 먼저 점검해야 하나요?
   	- 하나의 order_id에 여러개의 shipments 행이 연결되는 관계인지를 먼저 확인해야 한다.
   	- shipments에서 동일한 order_id가 여러 번 존재한다면 하나의 주문이 여러 배송과 JOIN되면서 결과 행 수가 증가할 수 있다.
   	
   Q4. 조인 결과 검증을 위해 행 수, 중복, NULL을 함께 확인해야 하는 이유는 무엇인가요?
   	- 행 수를 확인하면 JOIN으로 데이터가 예상보다 증가하거나 감소했는지 알 수 있다.
   	- 중복을 확인하면 하나의 주문에 여러 행이 연결되었는지 확인할 수 있다.
   	- NULL을 확인하면 연결되는 배송 정보가 없는 주문이 있는지 알 수 있다. 
   	- 위 세 가지를 모두 확인함에 따라 JOIN 결과가 의도한 데이터 구조와 일치하는지 판단할 수 있다.
   	
   Q5. LEFT JOIN한 shipments의 status 조건을 ON 절에 작성하는 경우와 WHERE 절에 작성하는 경우 결과가 어떻게 달라질 수 있나요?
   	- ON절에 조건 작성시 조건에 맞는 배송 정보만 연결하면서 orders의 주문은 모두 유지된다.
   	- WHERE절에 조건 작성시 JOIN 이후 조건에 맞지 않는 행과 NULL인 행을 제거하기 때문에 배송 정보가 없는 주문이 제외될 수 있다.

[제출 결과]
- 다단계 JOIN SQL
- orders 행 수
- 조인 후 행 수
- 배송 정보 없는 주문 수
- order_id 중복 검증
- Q1~Q5 답변
*/

-- [코드 작성란]
select o.order_id, o.order_date, c.customer_id, c.city, s.shipment_id, s.status
from orders o 
join customers c
	on c.customer_id = o.customer_id 
left join shipments s 
	on o.order_id = s.order_id;

-- orders 전체 행 수: 300,000행
select count(*) as row_count
from orders o ;

-- 최종 조인 결과의 전체 행 수: 300,000행
select count(*) as joined_row_count
from orders o 
join customers c
	on c.customer_id = o.customer_id 
left join shipments s 
	on o.order_id = s.order_id;

-- shipment_id가 NULL인 주문 수: 0
select count(*) as null_count
from orders o 
join customers c
	on c.customer_id = o.customer_id 
left join shipments s 
	on o.order_id = s.order_id
where shipment_id is null;

-- order_id별 행 수를 GROUP BY하고, 2행 이상 나타나는 주문이 있는지 확인: 없음
SELECT
    o.order_id,
    COUNT(*) AS row_count
FROM orders o
join customers c
	on c.customer_id = o.customer_id 
left join shipments s 
	on o.order_id = s.order_id
GROUP BY o.order_id
HAVING COUNT(*) >= 2;

/*
============================================================
4-1 과제. 주문 상세 행을 유지하면서 고객별 구매금액 계산하기
============================================================

고객별 총 구매금액을 윈도우 함수로 표시하기

[문제 설명]
고객별 총 구매금액을 계산하되,
각 주문 상품 행도 그대로 유지해야 합니다.

GROUP BY로 고객별 합계를 만들면 주문별·상품별 상세 행이 사라집니다.
이번에는 윈도우 함수를 이용해 상세 행을 유지하면서
고객별 총 구매금액을 같은 결과에서 확인하세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 order_items를 order_id 기준으로 JOIN하세요.
2. 주문상품별 구매금액은 qty * price로 계산하세요.
3. 다음 컬럼을 조회하세요.
   - orders.order_id
   - orders.customer_id
   - order_items.product_id
   - order_items.qty
   - order_items.price
   - item_amount
4. SUM(qty * price) OVER (PARTITION BY customer_id)를 사용하여
   customer_total_amount를 계산하세요.
5. 결과를 customer_id, order_id, product_id 순으로 정렬하세요.
6. 다음 질문에 답하세요.
   Q1. customer_total_amount가 같은 고객의 여러 행에서 반복되는 이유는 무엇인가요?
   	- 윈도우 함수는 GROUP BY와 달리 기존 상세 행을 하나로 합치지 않고 유지한 상태에서 계산하기 때문에, 같은 고객의 각 주문상품 행에 동일한 고객별 총 구매금액이 표시됨
   	
   Q2. GROUP BY로 같은 고객별 합계를 계산했다면 어떤 상세 정보가 사라지나요?
   	- 고객별로 GROUP BY하면 고객당 하나의 집계 결과로 줄어들기 때문에 order_id, product_id, qty, price 같은 개별 주문상품 정보가 겨로가에서 사라진다.
   	
   Q3. 개별 주문상품과 고객별 총 구매금액을 동시에 봐야 하는 분석에서 윈도우 함수가 적합한 이유는 무엇인가요?
   	- 윈도우 함수는 개별 행을 삭제하지 않으면서 고객별 총 구매금액을 같이 조회할 수 있기 때문에 적합하다.
   	
   Q4. 윈도우 함수에서 PARTITION BY, ORDER BY, 프레임은 각각 어떤 역할을 하나요?
   	- PARTITION BY는 누구끼리 계산할지 그룹을 나누고, ORDER BY는 그 그룹 안에서의 계산 순서를 정하며,
   	- 프레임은 현재 행을 기준으로 실제 계산에 포함할 행의 범위를 정한다.
   	

[제출 결과]
- 전체 SQL
- 결과 확인
- Q1~Q4 답변
*/

-- [코드 작성란]
select 
	o.order_id,
	o.customer_id,
	oi.product_id,
	oi.qty, 
	oi.price,
	oi.qty * oi.price as item_amount,
	sum(qty * price) over (partition by customer_id) as customer_total_amount
from orders o 
join order_items oi
	on oi.order_id = o.order_id 
order by customer_id, order_id, product_id;




/*
============================================================
4-2 과제. NTILE을 이용한 고객 구매등급 분류
============================================================

고객을 구매금액 기준 4개 그룹으로 나누기

[문제 설명]
마케팅팀에서 고객별 총 구매금액을 기준으로
고객을 4개 그룹으로 나누려고 합니다.

구매금액이 높은 고객부터 정렬하고
NTILE(4)를 이용하여 전체 고객 수를 최대한 균등하게 4개 그룹으로 나누세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 order_items를 order_id 기준으로 JOIN하세요.
2. 고객별 총 구매금액을 SUM(qty * price)로 계산하세요.
3. 총 구매금액 컬럼명은 total_amount로 지정하세요.
4. NTILE(4)를 이용하여 구매금액이 높은 고객부터
   customer_group 1~4를 부여하세요.
5. 결과는 customer_group 오름차순,
   total_amount 내림차순으로 정렬하세요.
6. 각 customer_group별 고객 수를 확인하세요.
7. 각 customer_group별 평균 구매금액을 계산하세요.
8. 다음 질문에 답하세요.
   Q1. NTILE(4)는 금액 범위를 정확히 4등분하나요,
       아니면 고객 수를 기준으로 최대한 균등하게 나누나요?
   	- 고객 수를 기준으로 최대한 균등하게 나눔
   Q2. customer_group = 1은 어떤 고객군으로 해석할 수 있나요?
   	- 총 구매금액이 높은 순으로 고객을 정렬했을 때 상위 약 25%에 해당하는 고객군이다.
   	
   Q3. 이 결과를 마케팅 업무에 어떻게 활용할 수 있나요?
   	- 구매금액에 따라 고객군을 나누어 그룹별로 차별화된 마케팅 전략을 수립할 수 있다.

[제출 결과]
- 고객별 총 구매금액 CTE
- NTILE(4) 적용 SQL
- 그룹별 고객 수
- 그룹별 평균 구매금액
- Q1~Q3 답변
*/

-- [코드 작성란]
with customer_totals as(
	select o.customer_id,
		sum(qty * price) as total_amount
	from orders o
	join order_items oi
		on oi.order_id = o.order_id
	group by o.customer_id
)
select
	customer_id,
	total_amount,
	NTILE(4) over (
		order by total_amount desc) as customer_group
from customer_totals
order by customer_group asc, total_amount desc;

--그룹별 고객 수 & 평균 구매 금액
with customer_totals as(
	select o.customer_id,
		sum(qty * price) as total_amount
	from orders o
	join order_items oi
		on oi.order_id = o.order_id
	group by o.customer_id
),
customer_groups as ( 
select
	customer_id,
	total_amount,
	NTILE(4) over (
		order by total_amount desc) as customer_group
from customer_totals
)
SELECT
    customer_group,
    COUNT(*) AS customer_count,
    AVG(total_amount) AS avg_total_amount
FROM customer_groups
GROUP BY customer_group
ORDER BY customer_group;

/*
============================================================
4-3 과제. 누적매출과 전일 대비 증감률 분석
============================================================
일별 매출 변화 리포트 만들기

[문제 설명]
운영 리포트에서 다음 정보를 한 번에 확인하려고 합니다.

- 일별 매출
- 해당 날짜까지 누적 매출
- 전일 매출
- 전일 대비 증감액
- 전일 대비 증감률

이번 강에서 배운 SUM() OVER와 LAG를 함께 사용하여
일별 매출 변화 리포트를 작성하세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 order_items를 order_id로 JOIN하세요.
2. order_date별 daily_sales를 계산하세요.
3. daily_sales_summary CTE를 작성하세요.
4. 다음 값을 계산하세요.
   - running_total
   - prev_day_sales
   - day_over_day_diff
   - day_over_day_pct
5. 전일 대비 증감률은 다음 식을 사용하세요.

   (현재 매출 - 전일 매출) / 전일 매출 * 100

6. 전일 매출이 0인 경우 오류가 발생하지 않도록 NULLIF를 사용하세요.
7. 증감률은 ROUND(..., 2)를 이용해 소수 둘째 자리까지 표시하세요.
8. 결과를 order_date 오름차순으로 정렬하세요.
9. day_over_day_pct가 음수인 날짜만 별도로 조회하세요.
10. 다음 질문에 답하세요.
    Q1. 첫 번째 날짜의 증감률이 NULL이 되는 이유는 무엇인가요?
    Q2. NULLIF(prev_day_sales, 0)를 사용하는 이유는 무엇인가요?
    Q3. day_over_day_pct가 음수라는 것은 비즈니스적으로 무엇을 의미하나요?
    Q4. 하루의 감소만으로 매출 추세가 악화되었다고 단정하기 어려운 이유는 무엇인가요?

[제출 결과]
- 전체 일별 매출 변화 SQL
- 매출 감소 날짜 조회 SQL
- Q1~Q4 답변
*/

-- [코드 작성란]
with daily_sales_summary as (
select o.order_date, sum(oi.qty * oi.price) as daily_sales
from orders o 
join order_items oi
	on oi.order_id = o.order_id
group by o.order_date)
select 
	order_date, daily_sales,
	sum(daily_sales) over (order by order_date) as running_total,
	lag(daily_sales) over (order by order_date) as prev_day_sales,
	daily_sales - lag(daily_sales) over (order by order_date) as day_over_day_diff,
	round((daily_sales - lag(daily_sales) over (order by order_date)) / 
		nullif(lag(daily_sales)over(order by order_date),0) * 100, 2) as day_over_day_pct
from daily_sales_summary
order by order_date asc;

--day_over_day_pct가 음수인 날짜만 별도 조회
with daily_sales_summary as (
select o.order_date, sum(oi.qty * oi.price) as daily_sales
from orders o 
join order_items oi
	on oi.order_id = o.order_id
group by o.order_date),
sales_result as(
select 
	order_date, daily_sales,
	sum(daily_sales) over (order by order_date) as running_total,
	lag(daily_sales) over (order by order_date) as prev_day_sales,
	daily_sales - lag(daily_sales) over (order by order_date) as day_over_day_diff,
	round((daily_sales - lag(daily_sales) over (order by order_date)) / 
		nullif(lag(daily_sales)over(order by order_date),0) * 100, 2) as day_over_day_pct
from daily_sales_summary)
select *
from sales_result 
where day_over_day_pct <0
order by order_date asc;

/*
Q1
첫 번째 날짜는 이전 날짜의 데이터가 존재하지 않기 때문에 LAG()로 가져올 전일 매출이 없어 NULL 값이 된다.
따라서 전일 대비 증감률도 계산할 수 없어 NULL이 되는 것이다.

Q2
전일 매출이 0이면 증감률 계산에서 0으로 나누는 오류가 발생할 수 있다.
전일 매출이 0일 경우 NULL로 변환하여 0으로 나누는 오류를 방지한다.

Q3
해당 날짜의 매출이 전일 대비 매출액이 감소했다는 의미한다.

Q4
하루의 매출이 전일보다 감소했더라도 장기적으로는 매출이 증가하는 추세일 수 있다.
여러 날짜의 데이터를 함께 확인해야 한다.

 */


/*
============================================================
5-1 과제. JOIN + 정렬 실행계획 해석
============================================================
고객 주문 조회 실행계획 분석

[문제 설명]
고객 주문 정보를 조회하면서
주문일 기준으로 정렬하는 쿼리의 실행계획을 분석하세요.

이번 문제에서는 실행계획에서
Scan → Join → Sort 흐름을 직접 확인하는 것이 핵심입니다.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. orders와 customers를 customer_id 기준으로 JOIN하세요.
2. 2023년 주문만 조회하세요.
3. 다음 컬럼을 조회하세요.
   - orders.order_id
   - orders.order_date
   - customers.customer_id
   - customers.city
4. 결과를 order_date DESC로 정렬하세요.
5. EXPLAIN ANALYZE를 적용하세요.
6. 실행계획에서 다음 항목을 확인하세요.
   - orders Scan 방식
   - customers Scan 방식
   - Join 방식
   - Sort
   - estimated rows
   - actual rows
   - Execution Time
7. 실행계획을 아래에서 위로 읽으면서 실제 처리 흐름을 설명하세요.
8. 가장 먼저 확인할 병목 후보 노드를 하나 선택하고 이유를 작성하세요.
9. 다음 질문에 답하세요.
   Q1. Scan 노드에서는 무엇을 확인해야 하나요?
   Q2. Join 노드에서는 무엇을 확인해야 하나요?
   Q3. Sort 노드에서는 무엇을 확인해야 하나요?
   Q4. Seq Scan이 나타났다고 해서 무조건 잘못된 실행계획이라고 할 수 있나요?

[제출 결과]
- 전체 SQL
- EXPLAIN ANALYZE 결과
- 실행 흐름
- 병목 후보
- Q1~Q4 답변
*/

-- [코드 작성란]
explain analyze
select o.order_id, o.order_date, c.customer_id, c.city
from orders o
join customers c
	on c.customer_id = o.customer_id
where order_date between '2023-01-01' and '2023-12-31'
order by order_date desc;


/*
6. 실행계획에서 다음 항목을 확인하세요.
   - orders Scan 방식 : Seq Scan
   - customers Scan 방식 : Seq Scan
   - Join 방식 : Hash Join
   - Sort : external merge
   - estimated rows : 76,138
   - actual rows : 75,023
   - Execution Time : 43.221 ms
   
7. 실행계획을 아래에서 위로 읽으면서 실제 처리 흐름을 설명하세요.
orders 300,000행을 Seq Scan > 2023년이 아닌 224,977행 제거 > orders 75,023행 남음
customers 50,0900행을 Seq Scan > customers를 customer_id 기준 Hash로 준비
customer_id를 기준으로 Hash Join > Join 결과 75,023행
order_date DESC로 75,023행 정렬 (일부 디스크 사용)
>>최종 결과 75,023행

8. 가장 먼저 확인할 병목 후보 노드를 하나 선택하고 이유를 작성하세요.
	Sort 노드를 선택할 것이다. 정렬하는 과정에서 external merge가 사용되었고 디스크를 사용했으며
	temp read/write도 발생했기 때문에 성능 관점에서 확인할 가치가 있다.
	
9.
Q1. Scan 노드에서는 무엇을 확인해야 하나요?
	어떤 테이블을 읽는지, Seq Scan인지 Index Scan인지, 몇 행이 필터링 됐는지,
	예상 행 수와 실제 행 수가 얼마나 다른지 등을 본다.
Q2. Join 노드에서는 무엇을 확인해야 하나요?
	어떤 JOIN 방식이 선택됐는지, JOIN 조건이 무엇인지, JOIN 전후 행 수가 어떻게 변했는지 확인하는 것이 중요
Q3. Sort 노드에서는 무엇을 확인해야 하나요?
	무엇을 기준으로 정렬했는지, 몇 행을 정렬했는지, 정렬 방식이 무엇인지, 메모리 안에서 처리했는지,
	디스크를 사용했는지를 본다.
Q4. Seq Scan이 나타났다고 해서 무조건 잘못된 실행계획이라고 할 수 있나요?
	NO. Seq Scan은 테이블 전체를 순차적으로 읽는 방식을 선택했다는 뜻이다.
	읽어야 할 데이터가 많거나 테이블이 작다면 오히려 Seq Scan이 합리적일 수 있다.

*/

/*
============================================================
5-2 과제. JOIN 쿼리의 날짜 인덱스 적용 전후 개선 효과 분석
============================================================
고객 도시 정보를 포함한 특정 기간 주문 조회 튜닝 결과 보고

[문제 설명]
운영 리포트에서 2023년 12월 주문과 고객 도시 정보를 함께 조회하고,
최근 주문부터 확인하는 쿼리를 반복적으로 사용한다고 가정합니다.

orders와 customers를 customer_id 기준으로 JOIN한 상태에서
먼저 현재 실행계획을 기준값으로 기록한 뒤,
orders.order_date 인덱스를 추가하여 동일한 JOIN 쿼리를 다시 측정하세요.

마지막에는 Scan → Join → Sort 흐름과 실행계획 변화,
실행시간 개선 효과와 한계를 간단한 비교 보고서 형태로 정리하세요.

※ 과제는 필수 문제와 동일한 수준입니다.

[요구사항]
1. 기존 idx_orders_order_date 인덱스가 있다면 삭제하세요.
2. orders와 customers를 customer_id 기준으로 JOIN하세요.
3. 다음 기간의 주문만 조회하세요.

   orders.order_date >= DATE '2023-12-01'
   orders.order_date <  DATE '2024-01-01'

4. 다음 컬럼을 출력하세요.
   - orders.order_id
   - orders.order_date
   - customers.customer_id
   - customers.city
5. 결과를 orders.order_date DESC로 정렬하세요.
6. 인덱스 생성 전 EXPLAIN ANALYZE 결과에서 다음 항목을 기록하세요.
   - orders 스캔 방식
   - customers 스캔 방식
   - Join 방식
   - JOIN 조건
   - Sort 여부
   - total cost
   - actual rows
   - Execution Time
7. orders.order_date에 idx_orders_order_date 인덱스를 생성하세요.
8. 동일한 JOIN 쿼리에 다시 EXPLAIN ANALYZE를 적용하세요.
9. 개선 후 동일한 항목을 기록하세요.
10. Join 노드가 개선 전후에 어떻게 달라졌는지 확인하세요.
    - Join 방식이 변경되었는지
    - Join 입력 행 수가 달라졌는지
    - Join 노드의 cost 또는 actual time이 달라졌는지
11. 실행시간 감소율을 다음 식으로 계산하세요.

   (개선 전 Execution Time - 개선 후 Execution Time)
   / 개선 전 Execution Time * 100

12. 다음 형식으로 비교 결과를 정리하세요.

   항목                  개선 전        개선 후
   ----------------------------------------------------
   orders 스캔 방식
   customers 스캔 방식
   Join 방식
   JOIN 조건
   Sort 여부
   Join 노드 변화
   total cost
   actual rows
   Execution Time
   실행시간 감소율

13. 다음 질문에 답하세요.
    Q1. 인덱스 추가 후에도 Sort가 남을 수 있나요?
    Q2. 인덱스를 추가했는데 옵티마이저가 Seq Scan을 계속 선택한다면 어떤 의미인가요?
    Q3. Join 방식이 변경되었다고 해서 반드시 성능이 개선되었다고 말할 수 있나요?
    Q4. 이번 결과만으로 모든 날짜 JOIN 조회에 order_date 인덱스가 항상 효과적이라고 결론 내릴 수 있나요?
14. 실습 종료 후 idx_orders_order_date 인덱스를 삭제하세요.

[제출 결과]
- 전체 JOIN SQL
- 개선 전 EXPLAIN ANALYZE
- CREATE INDEX 문
- 개선 후 EXPLAIN ANALYZE
- Scan / Join / Sort 비교표
- JOIN 조건 확인
- Join 노드 전후 변화 해석
- 실행시간 감소율
- Q1~Q4 답변
- DROP INDEX 문
*/

-- [코드 작성란]
drop index if exists idx_orders_order_date;

create index idx_orders_order_date on orders(order_date);

explain analyze
select o.order_id, o.order_date, c.customer_id, c.city
from orders o
join customers c
	on c.customer_id = o.customer_id
where o.order_date >= DATE '2023-12-01'
   and o.order_date <  DATE '2024-01-01'
order by o.order_date desc;

/*
         항목                  개선 전                      개선 후
   -----------------------------------------------------------------------------
   orders 스캔 방식     Parallel Seq Scan     Bitmap Heap Scan + Bitmap Index Scan
   customers 스캔 방식        Seq Scan                    Seq Scan
   Join 방식                Hash Join                    Hash Join
   JOIN 조건        o.customer_id = c.customer_id           좌동
   Sort 여부                   있음                          있음
   Join 노드 변화 
   total cost               8035.00                      4773.15
   actual rows               6,344                        6,344 
   Execution Time          31.515 ms                     11.354 ms
   실행시간 감소율                -                         약 63.96%


Q1. 인덱스 추가 후에도 Sort가 남을 수 있나요?
	YES. 인덱스가 있다고 해서 항상 인덱스의 정렬 순서를 이용하는 것은 아님.
	
Q2. 인덱스를 추가했는데 옵티마이저가 Seq Scan을 계속 선택한다면 어떤 의미인가요?
	인덱스가 존재한다고 해서 반드시 사용하는 것은 아님. 옵티마이저가 비용을 계산했을 때
	인덱스를 사용하는 것보다 Seq Scan으로 읽는 것이 더 효율적이라고 판단할 수 있음.
	특히 조건에 해당하는 행이 테이블에서 큰 비율을 차지할 경우 이런 선택이 나올 수 있음.
	
Q3. Join 방식이 변경되었다고 해서 반드시 성능이 개선되었다고 말할 수 있나요?
	NO. 이번 사례에서는 JOIN 방식은 Hash Join으로 동일한데 전체 실행시간이 크게 감소했음.

Q4. 이번 결과만으로 모든 날짜 JOIN 조회에 order_date 인덱스가 항상 효과적이라고 결론 내릴 수 있나요?
	NO. 이번에는 30만건 중 약 6,344건이라는 비교적 좁은 기간의 데이터를 찾았기 때문에 인덱스가 효과적이었음.
	조회 기간이 넓어져 대부분의 행을 가져와야 한다면 다시 Seq Scan을 선택할 수 있음.

 */

/*