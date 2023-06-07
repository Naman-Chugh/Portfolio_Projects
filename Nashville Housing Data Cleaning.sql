SELECT*
FROM Nashville_Housing

--FIXING SALEDATE
SELECT SaleDate
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD SaleDateUpdated DATE;

UPDATE Nashville_Housing
Set SaleDateUpdated=CONVERT(Date, SaleDate)

SELECT SaleDateUpdated
FROM Nashville_Housing



--FIXING PROPERTY ADDRESS
SELECT ParcelID, COUNT(PropertyAddress) AS PropertyAddressWithSameParcelID
FROM Nashville_Housing
--WHERE PropertyAddress IS NULL
GROUP BY ParcelID
ORDER BY ParcelID

Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing AS a
JOIN Nashville_Housing AS b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM Nashville_Housing AS a
JOIN Nashville_Housing AS b
on a.ParcelID = b.ParcelID
AND a.[UniqueID ]<> b.[UniqueID ]
WHERE a.PropertyAddress IS NULL



--BREAKING ADDRESS INTO INDIVIDUAL COLUMNS (ADDRESS, CITY, STATE)
--PROPERTY ADDRESS
SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) AS Address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress)) AS Address
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD PropertySplitAddress nvarchar(255);

UPDATE Nashville_Housing
Set PropertySplitAddress=SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

ALTER TABLE Nashville_Housing
ADD PropertySplitCity nvarchar(255);

UPDATE Nashville_Housing
Set PropertySplitCity=SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress)+1, LEN(PropertyAddress))

SELECT*
FROM Nashville_Housing


--OWNER ADDRESS
SELECT OwnerAddress
FROM Nashville_Housing

SELECT PARSENAME(REPLACE(OwnerAddress,',','.'),3)
,PARSENAME(REPLACE(OwnerAddress,',','.'),2)
,PARSENAME(REPLACE(OwnerAddress,',','.'),1)
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
ADD OwnerSplitAddress nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitAddress=PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE Nashville_Housing
ADD OwnerSplitCity nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitCity=PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE Nashville_Housing
ADD OwnerSplitState nvarchar(255);

UPDATE Nashville_Housing
Set OwnerSplitState=PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT*
FROM Nashville_Housing



--CORRECTING SOLD AS VACANT
SELECT SoldAsVacant, COUNT(SoldAsVacant)
FROM Nashville_Housing
GROUP BY SoldAsVacant
ORDER BY 2

SELECT SoldAsVacant
, CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
	   WHEN SoldAsVacant = 'N' THEN 'No'
	   ELSE SoldAsVacant
END
FROM Nashville_Housing

UPDATE Nashville_Housing
SET SoldAsVacant= CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
					   WHEN SoldAsVacant = 'N' THEN 'No'
					   ELSE SoldAsVacant
				  END

SELECT *
FROM Nashville_Housing



--REMOVING DUPLICATES
WITH RowNumCTE AS(
SELECT*, ROW_NUMBER() 
OVER( PARTITION BY ParcelID,
				   PropertyAddress,
				   SaleDate,
				   SalePrice,
				   LegalReference
				   ORDER BY UniqueID) row_num
FROM Nashville_Housing
)
SELECT *
FROM RowNumCTE
WHERE row_num >1



--DELETING UNUSED COLUMN
SELECT *
FROM Nashville_Housing

ALTER TABLE Nashville_Housing
DROP COLUMN PropertyAddress, OwnerAddress, SaleDate