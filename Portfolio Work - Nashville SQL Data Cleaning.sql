-- Cleaning Data in SQL Project
-- Using the Nashville Housing data set, I am going to clean and transform the data to become more user friendly.

SELECT *
From NashvilleHousing.dbo.NashvilleHousing

-- Fixing the dates
-- Using CONVERT, I transform the date format into a format I prefer.

SELECT SaleDate,  CONVERT(Date, SaleDate)
From NashvilleHousing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
SET SaleDateConverted = CONVERT(Date, SaleDate)


-- Pupulate Property Address data
-- To retrieve the NULL Property Address Data, I perform a self-join on the table and analyze the data to identify instances where the ParcelID matches its PropertyAddress.
-- By identifying these cases, I can conclude that the PropertyAddress for both sets of data should be the same. Consequently, I utilize this information to fill in the NULL values.

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing
---WHERE PropertyAddress is null
order by ParcelID

SELECT AAA.ParcelID, AAA.PropertyAddress, BBB.ParcelID, BBB.PropertyAddress, ISNULL(AAA.PropertyAddress, BBB.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing AAA
JOIN NashvilleHousing.dbo.NashvilleHousing BBB
	on AAA.ParcelID = BBB.ParcelID
	AND AAA.[UniqueID ] <> BBB.[UniqueID ]
WHERE AAA.PropertyAddress is null

--- Using ISNULL to see if AAA.PropertyAddress is NULL then populate the values with BBB.PropertyAddress.

Update AAA
SET PropertyAddress = ISNULL(AAA.PropertyAddress, BBB.PropertyAddress)
FROM NashvilleHousing.dbo.NashvilleHousing AAA
JOIN NashvilleHousing.dbo.NashvilleHousing BBB
	on AAA.ParcelID = BBB.ParcelID
	AND AAA.[UniqueID ] <> BBB.[UniqueID ]
WHERE AAA.PropertyAddress is null

-- Now I'm going to break the Address column into individual Columns (Address, City, State), this allows for the data to be more usable.

SELECT PropertyAddress
FROM NashvilleHousing.dbo.NashvilleHousing

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 ) as Address
, SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as Address
FROM NashvilleHousing.dbo.NashvilleHousing

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress) -1 )

ALTER TABLE NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
SET PropertySplitAddress = SUBSTRING(PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))



SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing

SELECT OwnerAddress
FROM NashvilleHousing.dbo.NashvilleHousing

SELECT
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)
,PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
FROM NashvilleHousing.dbo.NashvilleHousing


ALTER TABLE NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

ALTER TABLE NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

ALTER TABLE NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
SET OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)


SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing

-- Here I will change Y and N to Yes and No in "Sold as Vacant" field, this is done to make the data more coherent. 

SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2

SELECT SoldAsVacant
, CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
FROM NashvilleHousing.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE When SoldAsVacant = 'Y' THEN 'YES'
	   When SoldAsVacant = 'N' THEN 'NO'
	   ELSE SoldAsVacant
	   END
--- Check of  it works
SELECT Distinct(SoldAsVacant),COUNT(SoldAsVacant)
FROM NashvilleHousing.dbo.NashvilleHousing
Group by SoldAsVacant
Order by 2 


-- Remove Duplicates
-- Check of there are dublicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num

FROM NashvilleHousing.dbo.NashvilleHousing
--ORDER BY ParcelID
)
SELECT *
FROM RowNumCTE
WHERE row_num > 1
ORDER BY PropertyAddress

-- Then delete dublicates
WITH RowNumCTE AS (
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					)row_num

FROM NashvilleHousing.dbo.NashvilleHousing
--ORDER BY ParcelID
)
DELETE
FROM RowNumCTE
WHERE row_num > 1
--ORDER BY PropertyAddress

SELECT *
FROM NashvilleHousing.dbo.NashvilleHousing


