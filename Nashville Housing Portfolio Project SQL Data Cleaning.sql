/*

Cleaning Data in SQL Queries

*/

SELECT *
FROM NashvilleHousing


-- Standardize Date Format
-- Updated the table so that the saledate column is actually in date format and created a new date column.

SELECT SaleDateConverted, CONVERT(Date,SaleDate)
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SaleDate = CONVERT(Date,SaleDate)

ALTER TABLE nashvillehousing
ADD SaleDateConverted Date

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(Date,SaleDate)


-- Populate Property Address data
-- Used an ISNULL function so that if a.propertyaddress is null, then it'll populate with the b.propertyaddress.

SELECT *
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
ORDER BY ParcelID

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.propertyaddress,b.PropertyAddress)
FROM NashvilleHousing a
JOIN NashvilleHousing b
   ON a.ParcelID = b.ParcelID
   AND a.[UniqueID ] <> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL


-- Breaking our Address into Individual Columns (Address, City, State)
-- Used substrings as a delimiter to separate the address from the city.
-- Added a new address and city column, then updated the table to set their values.

SELECT PropertyAddress
FROM NashvilleHousing
--WHERE PropertyAddress IS NULL
--ORDER BY ParcelID

SELECT
SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1) AS Address
, SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress)) AS Address
FROM NashvilleHousing

ALTER TABLE nashvillehousing
ADD PropertySplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitAddress = SUBSTRING(propertyaddress, 1, CHARINDEX(',', propertyaddress)-1)

ALTER TABLE nashvillehousing
ADD PropertySplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET PropertySplitCity = SUBSTRING(propertyaddress, CHARINDEX(',', propertyaddress)+1, LEN(propertyaddress))

SELECT *
FROM NashvilleHousing

-- Showing the method to split up the address, city, and state by using parsename instead of substrings.
-- Added a new address, city, and state column, then updated the table to set their values.

SELECT OwnerAddress
FROM NashvilleHousing

SELECT
PARSENAME(REPLACE(owneraddress, ',', '.') ,3)
,PARSENAME(REPLACE(owneraddress, ',', '.') ,2)
,PARSENAME(REPLACE(owneraddress, ',', '.') ,1)
FROM NashvilleHousing

ALTER TABLE nashvillehousing
ADD OwnerSplitAddress NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(owneraddress, ',', '.') ,3)

ALTER TABLE nashvillehousing
ADD OwnerSplitCity NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(owneraddress, ',', '.') ,2)

ALTER TABLE nashvillehousing
ADD OwnerSplitState NVARCHAR(255)

UPDATE NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(owneraddress, ',', '.') ,1)

SELECT *
FROM NashvilleHousing


-- Change Y and N to Yes and No in "Sold as Vacant" field using CASE statement

SELECT DISTINCT(soldasvacant), COUNT(SoldasVacant)
FROM NashvilleHousing
GROUP BY SoldasVacant
ORDER BY 2

SELECT SoldasVacant
, CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
       WHEN SoldasVacant = 'N' THEN 'No'
	   ELSE SoldasVacant
	   END
FROM NashvilleHousing

UPDATE NashvilleHousing
SET SoldasVacant = CASE WHEN SoldasVacant = 'Y' THEN 'Yes'
      WHEN SoldasVacant = 'N' THEN 'No'
	  ELSE SoldasVacant
	  END


-- Remove Duplicates
-- Used a CTE so that I could use a WHERE clause on the new column created from a PARTITION BY.

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


FROM NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress


-- Delete Unused Columns

SELECT *
FROM NashvilleHousing

ALTER TABLE NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress

ALTER TABLE NashvilleHousing
DROP COLUMN SaleDate
