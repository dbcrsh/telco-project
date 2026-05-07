/*
For this query, I need to join the CUSTOMERS and TARIFFS tables. 
This is because the customer details are in one table, but the tariff name is in another. 
I used the TARIFF_ID to match them and filtered the results by the specific tariff name.
*/
SELECT c.CUSTOMER_ID, c.FULL_NAME
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.TARIFF_NAME = 'Kobiye Destek';


/*
To find the distribution, I group the customers based on their tariff names. 
I use the COUNT function to see exactly how many customers belong to each tariff. 
The JOIN operation is necessary to display the actual tariff name instead of just the ID number.
*/
SELECT t.TARIFF_NAME, COUNT(c.CUSTOMER_ID) AS TOTAL_CUSTOMERS
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
GROUP BY t.TARIFF_NAME;


/*
I need to find customers who reached or exceeded their limits in all three categories. 
I use multiple AND conditions to check data, minutes, and SMS usage against their limits. 
All three conditions must be true at the exact same time for the customer to appear on the list.
*/
SELECT c.CUSTOMER_ID, c.FULL_NAME
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.USED_DATA_GB >= t.DATA_LIMIT_GB
  AND m.USED_MIN >= t.MIN_LIMIT
  AND m.USED_SMS >= t.SMS_LIMIT;

/*
I need to find the customers who have the oldest signup dates in the whole database. 
I use a subquery to find the absolute minimum date from the CUSTOMERS table first. 
Then, I select all customers whose signup date perfectly matches this minimum date.
*/
SELECT CUSTOMER_ID, FULL_NAME, SIGNUP_DATE
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS);

/*
I build on the previous query to group these early customers by their city. 
I use the GROUP BY clause on the CITY column to organize the data properly. 
The COUNT function then calculates how many of these early birds are located in each city.
*/
SELECT CITY, COUNT(CUSTOMER_ID) AS EARLY_CUSTOMER_COUNT
FROM CUSTOMERS
WHERE SIGNUP_DATE = (SELECT MIN(SIGNUP_DATE) FROM CUSTOMERS)
GROUP BY CITY;

/*
Some customers do not have records in the MONTHLY_STATS table due to an insertion error. 
I can find them easily by using a LEFT JOIN from the CUSTOMERS table to the MONTHLY_STATS table. 
If the STAT_ID is NULL, it means the customer is definitely missing their monthly usage record.
*/
SELECT c.CUSTOMER_ID
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.STAT_ID IS NULL;

/*
First, I get the customers who use the 'Kobiye Destek' tariff by joining the tables. 
Then, I sort the results by their signup date in descending order so the newest comes first. 
Finally, I use the FETCH FIRST command to get just the single newest customer from the top of the list.
*/
SELECT c.CUSTOMER_ID, c.FULL_NAME, c.SIGNUP_DATE
FROM CUSTOMERS c
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE t.TARIFF_NAME = 'Kobiye Destek'
ORDER BY c.SIGNUP_DATE DESC
FETCH FIRST 1 ROW ONLY;


/*
I take the missing customers from the previous step and look at their city data. 
I use the GROUP BY command on the city column to group them geographically. 
Then, I count how many missing records exist in each specific city.
*/
SELECT c.CITY, COUNT(c.CUSTOMER_ID) AS MISSING_COUNT
FROM CUSTOMERS c
LEFT JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.STAT_ID IS NULL
GROUP BY c.CITY;

/*
I want to see how many paid and unpaid statuses exist for each tariff plan. 
I group the data by both the tariff name and the payment status columns. 
This gives a very clear breakdown of payment behaviors across the different subscription types.
*/
SELECT t.TARIFF_NAME, m.PAYMENT_STATUS, COUNT(m.STAT_ID) AS STATUS_COUNT
FROM TARIFFS t
JOIN CUSTOMERS c ON t.TARIFF_ID = c.TARIFF_ID
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
GROUP BY t.TARIFF_NAME, m.PAYMENT_STATUS
ORDER BY t.TARIFF_NAME;

/*
This query looks directly into the MONTHLY_STATS table for payment issues. 
I filter the PAYMENT_STATUS column to only match the word 'UNPAID'. 
I also join the customers table to show the actual names instead of just the ID numbers.
*/
SELECT c.CUSTOMER_ID, c.FULL_NAME, m.PAYMENT_STATUS
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
WHERE m.PAYMENT_STATUS = 'UNPAID';
/*
This query calculates the data usage percentage for each individual customer. 
I join the stats and tariffs tables to compare the used data with the allowed limit. 
I filter the results to only show the users where the usage ratio is 75 percent or higher.
*/
SELECT c.CUSTOMER_ID, c.FULL_NAME, m.USED_DATA_GB, t.DATA_LIMIT_GB
FROM CUSTOMERS c
JOIN MONTHLY_STATS m ON c.CUSTOMER_ID = m.CUSTOMER_ID
JOIN TARIFFS t ON c.TARIFF_ID = t.TARIFF_ID
WHERE m.USED_DATA_GB >= (t.DATA_LIMIT_GB * 0.75);





