--Cleaning data in SQL Project

-- See all the data
SELECT * 
	FROM nashville_housing

-- Standardize Date Format
SELECT SaleDate
	FROM nashville_housing

ALTER TABLE nashville_housing
	ADD SaleDateConverted date

UPDATE nashville_housing
	SET SaleDateConverted = CONVERT(date, SaleDate)

-- Populate Property Adress Data
SELECT PropertyAddress
	FROM nashville_housing
	WHERE PropertyAddress IS NULL

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM nashville_housing AS a
	JOIN nashville_housing AS b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress IS NULL

UPDATE a 
	SET PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
	FROM nashville_housing AS a
	JOIN nashville_housing AS b
		ON a.ParcelID = b.ParcelID
		AND a.[UniqueID] <> b.[UniqueID]
	WHERE a.PropertyAddress IS NULL

-- Breaking out Address into Individual Columns (Address, City, State)
SELECT PropertyAddress
	FROM nashville_housing
	 
SELECT 
	SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) AS Address,
	SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) AS Address
FROM nashville_housing

ALTER TABLE nashville_housing
	ADD PropertySplitAddress nvarchar(255)

UPDATE nashville_housing
	SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE nashville_housing
	ADD PropertySplitCity nvarchar(255)

UPDATE nashville_housing
	SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

SELECT PropertySplitAddress, PropertySplitCity
	FROM nashville_housing

SELECT
	PARSENAME(REPLACE(OwnerAddress, ',','.') ,3),
	PARSENAME(REPLACE(OwnerAddress, ',','.') ,2),
	PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)
FROM nashville_housing

ALTER TABLE nashville_housing
	ADD OwnerSplitAddress nvarchar(255)

UPDATE nashville_housing
	SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',','.') ,3)

ALTER TABLE nashville_housing
	ADD OwnerSplitCity nvarchar(255)

UPDATE nashville_housing
	SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',','.') ,2)

ALTER TABLE nashville_housing
	ADD OwnerSplitState nvarchar(255)

UPDATE nashville_housing
	SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',','.') ,1)

-- Change Y and N to Yes and No in "Sold as Vacant" field
SELECT SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	     WHEN SoldAsVacant = 'N' THEN 'No'
		 ELSE SoldAsVacant
		 END
	FROM nashville_housing

UPDATE nashville_housing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
						 WHEN SoldAsVacant = 'N' THEN 'No'
						 ELSE SoldAsVacant
						 END

-- Remove Duplicates
WITH RowNumCTE AS(
	SELECT *, 
		ROW_NUMBER() OVER (PARTITION BY ParcelID, PropertyAddress, SalePrice, SaleDate, LegalReference ORDER BY UniqueID) AS row_num
	FROM nashville_housing)

DELETE FROM RowNumCTE
	WHERE row_num > 1

-- Delete Unused Columns
SELECT * 
	FROM nashville_housing

ALTER TABLE nashville_housing
	DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate

