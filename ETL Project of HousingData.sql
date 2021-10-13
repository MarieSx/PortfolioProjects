-- Cleaning Data in T-SQL Queries
-- Using NashvilleHousing dataset


-- STEP ONE: learn the content and context & doing relative research
SELECT *
FROM [PortfolioPoject].[dbo].[NashvilleHousing]

-- STEP TWO: preclean and import to SSMS

--------------------------------------------------------------------------------------------------------------------------
-- STEP THREE: Data cleaning 
-- #3.1 Standardize Date Format

SELECT SaleDate, CONVERT(Date, SaleDate)
FROM [PortfolioPoject].[dbo].[NashvilleHousing]

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

-- Note: Somtimes it doesn't Update properly, may need to try ALTER

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)

SELECT saleDateConverted, CONVERT(Date,SaleDate)
From [PortfolioPoject].[dbo].[NashvilleHousing]


 --------------------------------------------------------------------------------------------------------------------------

-- #3.2 Populate Property Address data

SELECT *
FROM [PortfolioPoject]..[NashvilleHousing];

-- check if there is null value

SELECT *
FROM PortfolioPoject..NashvilleHousing
WHERE PropertyAddress IS NULL

-- Because it contains Null value, so order by parcelID to see if there is possible to fill in

SELECT *
FROM PortfolioPoject..NashvilleHousing
ORDER BY ParcelID;

-- Then I found out that when ParcelID is same, then address is same
-- So I could populate the address when parcelID is same, but with NULL value in address
-- Using SELF JOIN, to see if there is qualified field to be filled

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress
FROM PortfolioPoject..NashvilleHousing a
JOIN PortfolioPoject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL
;
-- Using ISNULL function to fill in the a.PropertyAddress

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress,
		ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioPoject..NashvilleHousing a
JOIN PortfolioPoject..NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

-- update property address

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortfolioPoject..NashvilleHousing a
JOIN PortfolioPoject..NashvilleHousing b
	ON a.parcelID = b.PARCELid
	AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL;

--------------------------------------------------------------------------------------------------------------------------

-- #3.3 Breaking out Address into Individual Columns (Address, City, State)
--Check the content, found the delimiter is comma

SELECT PortfolioPoject..NashvilleHousing.PropertyAddress
FROM PortfolioPoject..NashvilleHousing

--Using SUBSTRING

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress)) AS Address
FROM PortfolioPoject..NashvilleHousing;

--To remove comma at the end

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address
FROM PortfolioPoject..NashvilleHousing;

--To split Address into two column with address and city, using +1 to skip comma

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) AS Address
,SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM PortfolioPoject..NashvilleHousing;

--Create two new columns to add these values in

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',' , PropertyAddress) -1) 

ALTER TABLE NashvilleHousing
ADD PropertySplitCity Nvarchar(255);
UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

--Check the result

SELECT *
FROM PortfolioPoject..NashvilleHousing

------------------------------------------------------------------------------------
-- #3.4 Breaking out OwnerAddress into Individual Columns (Address, City, State)
-- Using Parse name
-- Check the content

Select OwnerAddress
From PortfolioPoject..NashvilleHousing

-- Note: parse name only works on period, so need to replace comma to period
-- First try if it works

SELECT 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM PortfolioPoject..NashvilleHousing

-- Add all filters, notice its backforward

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
,PARSENAME(REPLACE(OwnerAddress, ',','.'),1)
FROM PortfolioPoject..NashvilleHousing

--Add columns OwnerSplitAddress | OwnerSplitCity | OwnerSplitState

ALTER TABLE PortfolioPoject..NashvilleHousing
ADD OwnerSplitAddress Nvarchar(255);
UPDATE PortfolioPoject..NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
ALTER TABLE PortfolioPoject..NashvilleHousing
ADD OwnerSplitCity Nvarchar(255);
UPDATE PortfolioPoject..NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.'),2)
ALTER TABLE PortfolioPoject..NashvilleHousing
ADD OwnerSplitState Nvarchar(255);
UPDATE PortfolioPoject..NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.'),1)

--check the result

SELECT *
FROM PortfolioPoject..NashvilleHousing

-----------------------------------------------------------------------------------

-- #3.5 Change Y and N to Yes and No in "Sold as Vacant" field
--Check distinct value first

SELECT DISTINCT (SoldAsVacant)
FROM PortfolioPoject..NashvilleHousing

-- There are N, Yes, Y, No four different answers
-- Add count and group by to check which one is more popular

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioPoject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- turns out Yes No is more popular
-- Start changing

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END
FROM PortfolioPoject..NashvilleHousing

-- Update the value

UPDATE PortfolioPoject..NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant 
	   END

-- Check the result

SELECT DISTINCT (SoldAsVacant), COUNT(SoldAsVacant)
FROM PortfolioPoject..NashvilleHousing
GROUP BY SoldAsVacant
ORDER BY 2

-- Only Yes No left

-----------------------------------------------------------------------------------------

-- #3.6 Remove Duplicates
-- Checkt the content first

SELECT *
FROM PortfolioPoject..NashvilleHousing

-- Add rownumber, partition
-- when several columns are same at one single row, see it as dupilicate

SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioPoject..NashvilleHousing

-- Check if it is reliable, then add ORDER BY row_num to know the amount

SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioPoject..NashvilleHousing
ORDER BY row_num DESC

-- Add CTE

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioPoject..NashvilleHousing
)
SELECT *
FROM RowNumCTE
WHERE row_num >1
ORDER BY PropertyAddress

-- DELET row_num >1 colums

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY 
					UniqueID
					) row_num
FROM PortfolioPoject..NashvilleHousing
)
DELETE
FROM RowNumCTE
WHERE row_num >1

-- then check the previous query to see if there is still duplicates, turns out none

---------------------------------------------------------------------------------------------------------

-- #3.7 Delete Unused Columns
-- Checkt the content

SELECT *
FROM PortfolioPoject..NashvilleHousing

ALTER TABLE PortfolioPoject..NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate


