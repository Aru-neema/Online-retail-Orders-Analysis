Use orders;
show tables;
/**
1. Write a query to display the product details (product_class_code, product_id, product_desc,
product_price) as per the following criteria and sort them descending order of category:
i) If the category is 2050, increase the price by 2000
ii) If the category is 2051, increase the price by 500
iii) If the category is 2052, increase the price by 600 
*/

SELECT PRODUCT_ID, PRODUCT_DESC, PRODUCT_CLASS_CODE, PRODUCT_PRICE, 
CASE PRODUCT_CLASS_CODE
WHEN 2050 THEN PRODUCT_PRICE+ 2000
WHEN 2051 THEN PRODUCT_PRICE+ 500
WHEN 2052 THEN PRODUCT_PRICE+ 600
ELSE PRODUCT_PRICE
END AS 'NEW_Price'
FROM PRODUCT
ORDER BY PRODUCT_CLASS_CODE;

/*
2. Write a query to display (product_class_desc, product_id, 
product_desc, product_quantity_avail ) and Show inventory status of products as below 
as per their available quantity: 

a. For Electronics and Computer categories, if available quantity is <= 10, show 
'Low stock', 11 <= qty <= 30, show 'In stock', >= 31, show 'Enough stock' 

b. For Stationery and Clothes categories, if qty <= 20, show 'Low stock', 21 <= qty <= 
80, show 'In stock', >=81, show 'Enough stock' 

c. Rest of the categories, if qty <= 15 – 'Low Stock', 16 <= qty <= 50 – 'In Stock', >= 
51 – 'Enough stock' 

For all categories, if available quantity is 0, show 'Out of 
stock'. 
*/

SELECT P.PRODUCT_ID, P.PRODUCT_DESC, P.PRODUCT_QUANTITY_AVAIL, PC.PRODUCT_CLASS_DESC, 
CASE 
     WHEN PC.PRODUCT_CLASS_CODE IN (2050,2053) THEN  -- ELECTRONICS= 2050, COMPUTER= 2053; STATIONARY= 2056, CLOTHES= 2052
     CASE
               WHEN P.PRODUCT_QUANTITY_AVAIL <=10 THEN 'LOW STOCK'
               WHEN P.PRODUCT_QUANTITY_AVAIL >=11 AND P.PRODUCT_QUANTITY_AVAIL <=30 THEN 'IN STOCK'
			   WHEN P.PRODUCT_QUANTITY_AVAIL >=31 THEN 'ENOUGH STOCK' 
	 END
     WHEN PC.PRODUCT_CLASS_CODE IN (2056, 2052) THEN
     CASE
	           WHEN P.PRODUCT_QUANTITY_AVAIL <=20 THEN 'LOW STOCK'
               WHEN P.PRODUCT_QUANTITY_AVAIL >=81 THEN 'ENOUGH STOCK'
	 END 
ELSE
    CASE
               WHEN P.PRODUCT_QUANTITY_AVAIL <=15 THEN 'LOW STOCK'
               WHEN P.PRODUCT_QUANTITY_AVAIL >=16 AND P.PRODUCT_QUANTITY_AVAIL <=50 THEN 'IN STOCK'
               WHEN P.PRODUCT_QUANTITY_AVAIL >=51 THEN 'ENOUGH STOCK'
    END 
END AS 'INVENTORY LEVELS'
FROM PRODUCT AS P
INNER JOIN PRODUCT_CLASS AS PC ON P.PRODUCT_CLASS_CODE= PC.PRODUCT_CLASS_CODE
ORDER BY PC.PRODUCT_CLASS_CODE;
/*
3. Write a query to Show the count of cities in all countries other than USA & MALAYSIA, with 
more than 1 city, in the descending order of CITIES. 
 (2 rows)[NOTE :ADDRESS TABLE
 */
SELECT COUNT(CITY) AS COUNT_CITIES, COUNTRY FROM ADDRESS
GROUP BY COUNTRY
HAVING COUNTRY NOT IN ('USA', 'MALAYSAI') AND COUNT(CITY) >1
ORDER BY COUNT_CITIES DESC;
 
 /*
 
4. Write a query to display the customer_id,customer full name ,city,pincode,and order 
details (order id, product class desc, product desc, subtotal(product_quantity * 
product_price)) for orders shipped to cities whose pin codes do not have any 0s in them. 
Sort the output on customer name, order date and subtotal.(52 ROWS) 
[NOTE : TABLE TO BE USED - online_customer, address, order_header, 
order_items, product, product_class]
*/

SELECT OH.ORDER_ID, PC.PRODUCT_CLASS_DESC, P.PRODUCT_DESC, 
(O.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS SUBTOTAL, CONCAT(C.CUSTOMER_FNAME , ' ', C.CUSTOMER_LNAME) AS CUSTOMER_NAME,
C.CUSTOMER_ID, OH.ORDER_DATE, A.CITY, A.PINCODE 
FROM ONLINE_CUSTOMER AS C
INNER JOIN ADDRESS A ON A.ADDRESS_ID =C.ADDRESS_ID
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID= C.CUSTOMER_ID
INNER JOIN ORDER_ITEMS O ON O.ORDER_ID = OH.ORDER_ID
INNER JOIN PRODUCT P ON P.PRODUCT_ID= O.PRODUCT_ID
INNER JOIN PRODUCT_CLASS PC ON PC.PRODUCT_CLASS_CODE= P.PRODUCT_CLASS_CODE

WHERE A.PINCODE NOT LIKE '%0%' AND OH.ORDER_STATUS= 'Shipped' 
ORDER BY CUSTOMER_NAME, OH.ORDER_DATE, SUBTOTAL;

/*
5. Write a Query to display product id,product description,totalquantity(sum(product quantity) for a 
given item whose product id is 201 and which item has been bought along with it maximum no. of 
times. Display only one record which has the maximum value for total quantity in this scenario. 
(USE SUB-QUERY)(1 ROW)[NOTE : ORDER_ITEMS TABLE,PRODUCT TABLE] 
*/

SELECT P.PRODUCT_ID, P.PRODUCT_DESC, SUM(O.PRODUCT_QUANTITY) AS TOTAL_QUANTITY
FROM PRODUCT P
INNER JOIN ORDER_ITEMS O ON O.PRODUCT_ID= P.PRODUCT_ID
WHERE O.ORDER_ID IN(
SELECT DISTINCT ORDER_ID FROM ORDER_ITEMS WHERE PRODUCT_ID= 201) 
GROUP BY P.PRODUCT_ID
ORDER BY TOTAL_QUANTITY DESC
LIMIT 1;

/*
6. Write a query to display the customer_id,customer name, email and order details 
(order id, product desc,product qty, subtotal(product_quantity * product_price)) for all 
customers even if they have not ordered any item.(225 ROWS) 
[NOTE : TABLE TO BE USED - online_customer, order_header, order_items, 
product]
*/

SELECT C.CUSTOMER_ID, CONCAT(C.CUSTOMER_FNAME, ' ', C.CUSTOMER_LNAME) AS FULL_NAME, C.CUSTOMER_EMAIL,
OH.ORDER_ID, P.PRODUCT_DESC, O.PRODUCT_QUANTITY, (O.PRODUCT_QUANTITY * P.PRODUCT_PRICE) AS SUBTOTAL
FROM ONLINE_CUSTOMER AS C
LEFT JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID= C.CUSTOMER_ID
LEFT JOIN ORDER_ITEMS O ON O.ORDER_ID = OH.ORDER_ID
LEFT JOIN PRODUCT P ON P.PRODUCT_ID= O.PRODUCT_ID
ORDER BY CUSTOMER_ID;

/* 7. Write a query to display carton id ,(len*width*height) as carton_vol and identify the 
optimum carton (carton with the least volume whose volume is greater than the total volume of 
all items(len * width * height * product_quantity)) for a given order whose order id is 10006 
, Assume all items of an order are packed into one single carton (box) .(1 ROW)[NOTE : 
CARTON TABLE] 
*/

SELECT CA.CARTON_ID, (CA.LEN*CA.WIDTH*CA.HEIGHT) AS CARTON_VOL FROM CARTON AS CA
WHERE (CA.LEN*CA.WIDTH*CA.HEIGHT) > (SELECT SUM(P.LEN*P.WIDTH*P.HEIGHT*OI.PRODUCT_QUANTITY) 
                                     FROM ORDER_ITEMS OI
									 INNER JOIN PRODUCT P ON P.PRODUCT_ID= OI.PRODUCT_ID
                                     WHERE OI.ORDER_ID= 10006)
ORDER BY (CA.LEN*CA.WIDTH*CA.HEIGHT) ASC
LIMIT 1;

/*
8. Write a query to display details (customer id,customer fullname,order id,product quantity) 
of customers who bought more than ten (i.e. total order qty) products with credit card or net 
banking as the mode of payment per shipped order. (6 ROWS) 
[NOTE: TABLES TO BE USED - online_customer, order_header, order_items,] 
*/ 
SELECT C.CUSTOMER_ID, CONCAT(C.CUSTOMER_FNAME, ' ', C.CUSTOMER_LNAME) AS FULL_NAME, O.ORDER_ID,
O.PRODUCT_QUANTITY, OH.PAYMENT_MODE, OH.ORDER_STATUS FROM ONLINE_CUSTOMER AS C
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID= C.CUSTOMER_ID
INNER JOIN ORDER_ITEMS O ON O.ORDER_ID=OH.ORDER_ID
WHERE O.PRODUCT_QUANTITY > 10 AND OH.PAYMENT_MODE IN ('Credit Card','Net Banking') AND OH.ORDER_STATUS= 'Shipped'
ORDER BY CUSTOMER_ID;

/*9.Write a query to display the order_id,customer_id and customer fullname starting with “A” along 
with (product quantity) as total quantity of products shipped for order ids > 10030 
(5 Rows) [NOTE: TABLES to be used-online_customer,Order_header, order_items] 
*/
SELECT C.CUSTOMER_ID, CONCAT(C.CUSTOMER_FNAME, ' ', C.CUSTOMER_LNAME) AS FULL_NAME, O.ORDER_ID,
SUM(O.PRODUCT_QUANTITY) AS TOTAL_QUANTITY, OH.ORDER_STATUS FROM ONLINE_CUSTOMER AS C
INNER JOIN ORDER_HEADER OH ON OH.CUSTOMER_ID= C.CUSTOMER_ID
INNER JOIN ORDER_ITEMS O ON O.ORDER_ID=OH.ORDER_ID
WHERE CONCAT(C.CUSTOMER_FNAME, ' ', C.CUSTOMER_LNAME) LIKE 'A%' AND O.ORDER_ID > 10030 AND OH.ORDER_STATUS= 'Shipped'
GROUP BY OH.ORDER_ID
ORDER BY C.CUSTOMER_ID;
 
/*
10. Write a query to display product class description, totalquantity(sum(product_quantity), Total 
value (product_quantity * product price) and show which class of products have been shipped 
highest(Quantity) to countries outside India other than USA? Also show the total value of those 
items. 
 (1 ROWS)[NOTE:PRODUCT TABLE,ADDRESS TABLE,ONLINE_CUSTOMER 
TABLE,ORDER_HEADER TABLE,ORDER_ITEMS TABLE,PRODUCT_CLASS TABLE] 

*/

SELECT PC.PRODUCT_CLASS_DESC, SUM(O.PRODUCT_QUANTITY) AS TOTAL_QUANT, 
(O.PRODUCT_QUANTITY*P.PRODUCT_PRICE) AS TOTAL_VALUE, OH.ORDER_STATUS, A.COUNTRY 
FROM PRODUCT_CLASS AS PC
INNER JOIN PRODUCT P ON P.PRODUCT_CLASS_CODE= PC.PRODUCT_CLASS_CODE
INNER JOIN ORDER_ITEMS O ON O.PRODUCT_ID= P.PRODUCT_ID
INNER JOIN ORDER_HEADER OH ON OH.ORDER_ID= O.ORDER_ID
INNER JOIN ONLINE_CUSTOMER C ON C.CUSTOMER_ID= OH.CUSTOMER_ID
INNER JOIN ADDRESS A ON A.ADDRESS_ID=C.ADDRESS_ID
WHERE OH.ORDER_STATUS ='Shipped' AND A.COUNTRY NOT IN ('USA') 
GROUP BY PC.PRODUCT_CLASS_DESC
ORDER BY TOTAL_QUANT DESC
limit 1



 