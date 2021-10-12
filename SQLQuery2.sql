
/*
Cleaning Data in T-SQL Queries
*/

/*Using NashvilleHousing dataset*/


/*STEP ONE: learn the content and context & doing relative research*/
SELECT *
FROM [PortfolioPoject].[dbo].[NashvilleHousing]

--------------------------------------------------------------------------------------------------------------------------
/*STEP TWO: Data cleaning*/
-- #1.1 Standardize Date Format

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

-- #1.2 Populate Property Address data

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

-- #1.3 Breaking out Address into Individual Columns (Address, City, State)

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





Select OwnerAddress
From PortfolioProject.dbo.NashvilleHousing


Select
PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)
From PortfolioProject.dbo.NashvilleHousing



ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 2)



ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.') , 1)



Select *
From PortfolioProject.dbo.NashvilleHousing




--------------------------------------------------------------------------------------------------------------------------


-- Change Y and N to Yes and No in "Sold as Vacant" field


Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From PortfolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2




Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END
From PortfolioProject.dbo.NashvilleHousing


Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'Yes'
	   When SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
	   END






-----------------------------------------------------------------------------------------------------------------------------------------------------------

-- Remove Duplicates

WITH RowNumCTE AS(
Select *,
	ROW_NUMBER() OVER (
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num

From PortfolioProject.dbo.NashvilleHousing
--order by ParcelID
)
Select *
From RowNumCTE
Where row_num > 1
Order by PropertyAddress



Select *
From PortfolioProject.dbo.NashvilleHousing




---------------------------------------------------------------------------------------------------------

-- Delete Unused Columns



Select *
From PortfolioProject.dbo.NashvilleHousing


ALTER TABLE PortfolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
