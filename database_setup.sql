/*CREATE TABLE calendar (
    Date TEXT
);*/

CREATE TABLE inventory (
    Store_ID TEXT ,
	Product_ID TEXT pri,
	Stock_On_Hand INT
);

CREATE TABLE products (
	Product_ID TEXT,
	Product_Name VARCHAR(255),
	Product_Category VARCHAR(255),
	Product_Cost INT,
	Product_Price INT
);

CREATE TABLE sales (
	Sale_ID TEXT,
	Date DATE,
	Store_ID TEXT,
	Product_ID TEXT,
	Units INT
);


CREATE TABLE stores (
	Store_ID TEXT,
	Store_Name TEXT,
	Store_City TEXT,
	Store_Location TEXT,
	Store_Open_Date DATE
);