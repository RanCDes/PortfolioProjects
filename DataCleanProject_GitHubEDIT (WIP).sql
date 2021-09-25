
----------------------------------------------------------------------------------------------------
-- Cleaning Data in SQL Queries
----------------------------------------------------------------------------------------------------

-- Standardizing Date Format
-- note: converting date/time format to a standardized 'YYYY-MM-DD' format

Select SaleDateConverted, CONVERT(Date, SaleDate)
From DataCleanProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SaleDate = CONVERT(Date, SaleDate)

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)

----------------------------------------------------------------------------------------------------

-- Populating Property Address Data
-- note: looking for 'null' values in 'PropertyAddress' and populating with a property with an address of the same 'ParcelID'

/*
Select *
From DataCleanProject.dbo.NashvilleHousing
Where PropertyAddress is null
order by ParcelID
*/

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleanProject.dbo.NashvilleHousing a
JOIN DataCleanProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

Update a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
From DataCleanProject.dbo.NashvilleHousing a
JOIN DataCleanProject.dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID] <> b.[UniqueID]
Where a.PropertyAddress is null

----------------------------------------------------------------------------------------------------

-- Dividing Address into Individual Columns (Address, City, State)
-- note: breaking up (Address, City, State) into individual columns, dropping delimiters

Select PropertyAddress
From DataCleanProject.dbo.NashvilleHousing
--Where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress)) as Address
From DataCleanProject.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1)

ALTER TABLE NashvilleHousing
Add PropertySplitCity nvarchar(255);

Update NashvilleHousing
SET PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1, LEN(PropertyAddress))

/*
Select *
From DataCleanProject.dbo.NashvilleHousing
*/

Select OwnerAddress
From DataCleanProject.dbo.NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From DataCleanProject.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)


ALTER TABLE NashvilleHousing
Add OwnerSplitCity nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)


ALTER TABLE NashvilleHousing
Add OwnerSplitState nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

/*
Select *
From DataCleanProject.dbo.NashvilleHousing
*/

----------------------------------------------------------------------------------------------------

-- In SoldAsVacant field, Changing Y and N to Yes and No

Select Distinct(SoldAsVacant), Count(SoldAsVacant)
From DataCleanProject.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From DataCleanProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
From DataCleanProject.dbo.NashvilleHousing

----------------------------------------------------------------------------------------------------

-- Removing Duplicates

WITH RowNumCTE AS (
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
From DataCleanProject.dbo.NashvilleHousing
)
DELETE
From RowNumCTE
Where row_num > 1

----------------------------------------------------------------------------------------------------

-- Deleting Unused Columns

Select *
From DataCleanProject.dbo.NashvilleHousing

ALTER TABLE DataCleanProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, TaxDistrict, PropertyAddress, SaleDate
