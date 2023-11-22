-- Task 2: Perform a Simple Query 
-- To display the specific address from transactions table 
SELECT * FROM `bigquery-public-data.crypto_bitcoin.transactions` as transactions -- To select a database called crypto_bitcoin from the big database bigquery called bigquery-public-data and select a table called transactions and named this selection as transactions. Write SELECT * FROM 'bigquery-public-data.crypto_bitcoin.transactions' as transactions
WHERE transactions.hash = 'a1075db55d416d3ca199f55b6084e2115b9345e16c5cf302fc80e9d5fbf5d48d' -- To specify the selection, write WHERE to select where the column is hash on the table transactions, write: WHERE transactions.hash = '' and inside the quotation write the address we are selecting or searching for
   
   

-- Task 3: Validate The Data 
-- To calculate and display the balance of each account for Dogecoin in crypto_dogecoin database of bigquery-public-data
WITH double_entry_book AS (	-- Using the WITH clause to make a Common Table Expression(CTE) of a subquery or a function that later will be called in this query called double_entry_book with the clause AS to specify the inside structure of the subquery. write: WITH double_entry_book AS (..)
	--debits	(This part is to calculate the debits)
	SELECT array_to_string(inputs.addresses, ",") AS address, -- Select the address customer in inputs.addresses and convert it from array to string with the "," delimiter and save it in a column called address. Write SELECT array_to_string(inputs.addresses, ",") AS address,
		inputs.type,	-- Then also select the inputs.type to display the type
		-inputs.value AS value	-- Also the value of the debits in the account by writing -inputs.value AS value. Add the - to the inputs.value to calculate the balance with credits value. so credits value - debits value which then be balance
	FROM `bigquery-public-data.crypto_dogecoin.inputs` AS inputs	-- Select it from the crypto-dogecoin.inputs by writing FROM `bigquery-public-data.crypto_bitcoin.inputs` AS inputs. Remember the inputs and outputs is a view object, not a table so it is temporary

	UNION ALL	-- All of those selected rows or record will be union or merge with below records. The ALL in UNION ALL is to UNIONIZED all the records incluiding duplicate records

	--credits	(This part is to calculate the credits)
	SELECT array_to_string(outputs.addresses, ",") AS address,	-- The credits values in in outputs view so write SELECT array_to_string(outputs.addresses, ",") AS address,
		outputs.type,	-- Write also the type as in outputs.type,
		outputs.value AS value	-- The value: outputs.value AS value
	FROM `bigquery-public-data.crypto_dogecoin.outputs` AS outputs	-- From the .crypto_dogecoin.outputs AS outputs
)
SELECT address,	-- To select the result on the unionized records above, write SELECT address as in both address in inputs and outputs
	type,	-- type as in type in inputs and outputs
	SUM(value) AS balance	-- SUM(value) AS balance. This part is to sum all the value in the same address and type. So in this step is to calculate the balance of debits and credits of the same address and type because later on we add "GROUP BY 1, 2"
FROM double_entry_book	-- FROM double_entry_book --> the subquery
GROUP BY 1, 2	-- Write GROUP BY 1,2 to Group the records by the column 1 (address) and column 2(type) so it will eventually sum(value) of the same address or the same account only
ORDER BY balance DESC	-- Use ORDER BY balance DESC to order the records by balance in a descending way. So the first row will be the largest and descending along the way
LIMIT 100	-- With a Limit of 100 records or rows to display, write LIMIT 100



-- Task 5: Explore Two Famous Cryptocurrency Events
--1. To display the transaction has of the large mystery transfer of 194993 BTC and store it in a table 51 inside the lab dataset
CREATE OR REPLACE TABLE lab.51 (transaction_hash STRING) AS -- To create a new table or replace an existing table and will be named "51" inside the lab dataset or database. And create a column named transaction_hash with a STRING datatype. Creating that as:
SELECT transaction_id FROM `bigquery-public-data.bitcoin_blockchain.transactions` , UNNEST(outputs) AS outputs	-- Select that a column named transaction_id from the `bigquery-public-data.bitcoin_blockchain.transaction`. Meaning to select from the bigquery-public-data and select the bitcoin_blockchain database and the transaction table because that is where the specified transaction placed. The UNNEST(outputs) is to expand the array column "outputs" into individual rows and place it in a column named outputs (hence the AS outputs), this step is to expand the values in outputs column into individual values so it will result in more rows as well
WHERE outputs.output_satoshis = 19499300000000	-- To specify the select, add the WHERE clause, write WHERE outputs.output_satoshis = 19499300000. outputs.ouput_satoshis is to specify to look in the outputs table and outputs_satoshis column. The value 19499300000 is the 194993 BTC but converted in the sitoshis (0.00000001 BTC = 1 sitoshis)
 
--2. To display the Balance of the specified address from Task 2: Perform a Simple Query of the inputs.addresses column and store it in the table 52 inside the lab dataset
CREATE OR REPLACE TABLE lab.52 (balance NUMERIC) AS	-- To create a new table or replce an existing table and will be named "52" inside the lab dataset or database. And create a column named balance with a NUMERIC datatype. Write: CREATE OR REPLACE TABLE lab.52 (balance NUMERIC) AS
WITH double_entry_book AS (		-- Create a subquery called double_entry_book, write: WITH double_entry_book AS (
	-- debits
	SELECT  array_to_string(inputs.addresses, ",") AS address,	-- Select the address customer in inputs.addresses and convert it from array to string with the "," delimiter and save it in a column called address. Write SELECT array_to_string(inputs.addresses, ",") AS address,
		-inputs.value AS value		-- Also the value of the debits in the account by writing -inputs.value AS value. Add the - to the inputs.value to calculate the balance with credits value. so credits value - debits value which then be balance
	FROM `bigquery-public-data.crypto_bitcoin.inputs` AS inputs		-- Select it from the crypto-bitcoin.inputs by writing FROM `bigquery-public-data.crypto_bitcoin.inputs` AS inputs. Remember the inputs and outputs is a view object, not a table so it is temporary

	UNION ALL

	-- credits
	SELECT array_to_string(outputs.addresses, ",") AS address,	-- The credits values in in outputs view so write SELECT array_to_string(outputs.addresses, ",") AS address,
		outputs.value AS value		-- The value: outputs.value AS value
	FROM `bigquery-public-data.crypto_bitcoin.outputs` AS outputs	-- From the .crypto_bitcoin.outputs AS outputs
) 
SELECT 
	SUM(value) AS balance		-- SUM(value) AS balance. This part is to sum all the value in the same address and type. So in this step is to calculate the balance of debits and credits of the same address and type because later on we add "GROUP BY 1, 2"
FROM double_entry_book		-- FROM double_entry_book --> the subquery
WHERE address = '1XPTgDRhN8RFnzniWCddobD9iKZatrvH4'	-- Add the WHERE clause WHERE address = '' to only select where the address match with what we specify in this step