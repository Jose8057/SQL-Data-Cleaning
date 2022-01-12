/****** Script for SelectTopNRows command from SSMS  ******/
SELECT TOP (1000) [UniqueID ]
      ,[ParcelID]
      ,[LandUse]
      ,[PropertyAddress]
      ,[SaleDate]
      ,[SalePrice]
      ,[LegalReference]
      ,[SoldAsVacant]
      ,[OwnerName]
      ,[OwnerAddress]
      ,[Acreage]
      ,[TaxDistrict]
      ,[LandValue]
      ,[BuildingValue]
      ,[TotalValue]
      ,[YearBuilt]
      ,[Bedrooms]
      ,[FullBath]
      ,[HalfBath]
  FROM [DataCleaning].[dbo].[Housedata]

  --Cleaning Data in SQL queires
  SELECT *
  FROM DataCleaning..Housedata

  --Standardize Date Format
  SELECT SaleDate, CONVERT(Date,SaleDate)
  FROM DataCleaning..Housedata

  UPDATE Housedata
  SET SaleDate=CONVERT(Date,SaleDate)

  ALTER TABLE Housedata
  ADD SaleDateNew Date;

  UPDATE Housedata
  SET SaleDateNew=CONVERT(Date, SaleDate)

  SELECT SaleDateNew, CONVERT(Date,SaleDate)
  FROM DataCleaning..Housedata

   --Populate Property Address data
 SELECT PropertyAddress
 FROM DataCleaning..Housedata
 WHERE PropertyAddress IS NOT NULL


 SELECT *
 FROM DataCleaning..Housedata
 --WHERE PropertyAddress IS NOT NULL
 ORDER BY ParcelID


 SELECT A.ParcelID,A.PropertyAddress,B.ParcelID,B.PropertyAddress,ISNULL(A.PropertyAddress,b.PropertyAddress)
 FROM DataCleaning..Housedata A
 JOIN DataCleaning..Housedata B
 --WHERE PropertyAddress IS NOT NULL
      ON A.ParcelID=B.ParcelID
	  AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


UPDATE A
SET PropertyAddress=ISNULL(A.PropertyAddress,b.PropertyAddress)
FROM DataCleaning..Housedata A
 JOIN DataCleaning..Housedata B
 --WHERE PropertyAddress IS NOT NULL
      ON A.ParcelID=B.ParcelID
	  AND A.[UniqueID ]<>B.[UniqueID ]
WHERE A.PropertyAddress IS NULL


--Breaking out Address into Individual Columns(Adress, City, State)


 SELECT PropertyAddress
 FROM DataCleaning..Housedata
-- WHERE PropertyAddress IS NOT NULL

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1) as Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1,LEN(PropertyAddress)) as Address
FROM DataCleaning..Housedata


ALTER TABLE Housedata
ADD PropertySplitAddress Nvarchar(255);

UPDATE Housedata
SET PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress)-1)

ALTER TABLE Housedata
ADD PropertySplitCity Nvarchar(255);

UPDATE Housedata
SET PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT *
FROM DataCleaning..Housedata

SELECT OwnerAddress
FROM DataCleaning..Housedata


SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM DataCleaning..Housedata


SELECT *
FROM DataCleaning..Housedata


ALTER TABLE Housedata
ADD OwnerSplitAddress Nvarchar(255);

UPDATE Housedata
SET OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)


ALTER TABLE Housedata
ADD OwnerSplitCity Nvarchar(255);

UPDATE Housedata
SET OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Housedata
ADD OwnerSplitState Nvarchar(255);

UPDATE Housedata
SET OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)


SELECT *
FROM DataCleaning..Housedata

--Chang Y and N to Yes and No in "Sold as Vacant" column

SELECT DISTINCT(SoldAsVacant),Count(SoldAsVacant)
FROM DataCleaning..Housedata
GROUP BY SoldAsVacant
ORDER BY 2


SELECT SoldAsVacant,
    CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	     WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM DataCleaning..Housedata

UPDATE Housedata
SET SoldAsVacant=CASE WHEN SoldAsVacant ='Y' THEN 'Yes'
	     WHEN SoldAsVacant='N' THEN 'No'
		 ELSE SoldAsVacant
		 END
FROM DataCleaning..Housedata


--Move Duplicates
--CTE
WITH Tb AS(
SELECT *,
ROW_NUMBER()OVER(
PARTITION BY ParcelID,
             PropertyAddress,
			 SalePrice,
			 SaleDate,
			 LegalReference
			 ORDER BY
			 UniqueID) row_number

FROM DataCleaning..Housedata
)
DELETE 
FROM Tb
WHERE row_number>1
--ORDER BY PropertyAddress

--Delete Unused columns

SELECT *
FROM DataCleaning..Housedata

ALTER TABLE DataCleaning..Housedata
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress,SaleDate

