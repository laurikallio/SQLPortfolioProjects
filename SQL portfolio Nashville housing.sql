-- cleaning data  in sql queries

Select *
from PortfolioProject..NashvilleHousing

-----------------------------------------------------------------------------
--Standardize date format

Select SaleDateConverted, CONVERT(date, saledate)
from PortfolioProject..NashvilleHousing

Update  NashvilleHousing
Set SaleDate = CONVERT(date, saledate)

ALTER TABLE NashvilleHousing
ADD SaleDateConverted Date;

Update  NashvilleHousing
Set SaleDateConverted = CONVERT(date, saledate)

-----------------------------------------------------------------------------
-- Populate Property address

Select *
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
order by ParcelID
---------                                                 isnull jos a.prop = null -> laita sen paikalle b.prop...
Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

Update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from PortfolioProject..NashvilleHousing a
Join PortfolioProject..NashvilleHousing b
	on a.ParcelID = b.ParcelID
	AND a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null

------------------------------------------------------------------------------------
--breaking out address into individual columns (address, city, state)

Select PropertyAddress
from PortfolioProject..NashvilleHousing
--where PropertyAddress is null
--order by ParcelID

SELECT
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) as address
, SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress)) as address

from PortfolioProject..NashvilleHousing

ALTER TABLE NashvilleHousing
ADD PropertySplitAddress nvarchar(255);

Update  NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) -1 ) 


ALTER TABLE NashvilleHousing
ADD PropertySplitCity nvarchar(255);

Update  NashvilleHousing
Set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) +1 , LEN(PropertyAddress))

Select *
from PortfolioProject..NashvilleHousing




Select OwnerAddress
from PortfolioProject..NashvilleHousing

Select
PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2)
, PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)
from PortfolioProject..NashvilleHousing


--address
ALTER TABLE NashvilleHousing
ADD OwnerSplitAddress nvarchar(255);

Update  NashvilleHousing
Set OwnerSplitAddress = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  3) 

--city
ALTER TABLE NashvilleHousing
ADD OwnerSplitCity nvarchar(255);

Update  NashvilleHousing
Set OwnerSplitCity = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  2)

--state
ALTER TABLE NashvilleHousing
ADD OwnerSplitState nvarchar(255);

Update  NashvilleHousing
Set OwnerSplitState = PARSENAME(REPLACE(OwnerAddress, ',', '.'),  1)


Select *
from PortfolioProject..NashvilleHousing


---------------------------------------------------------------------------------------------------
--change Y and N to yes and no in  "sold as vacant" field

Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfolioProject..NashvilleHousing
group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE	when SoldAsVacant = 'Y' THEN 'Yes'
		When  SoldAsVacant = 'N' tHEN 'NO'
		Else SoldAsVacant
		End
From PortfolioProject..NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = CASE	when SoldAsVacant = 'Y' THEN 'Yes'
						When  SoldAsVacant = 'N' tHEN 'NO'
						Else SoldAsVacant
						End

---------------------------------------------------------------------------------------------------
--Remove Duplicants
WITH RowNumCTE as (
Select *,
	ROW_NUMBER() OVER (
	Partition by ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID
					) row_num
From PortfolioProject..NashvilleHousing
--Order by ParcelID
)
select *
from RowNumCTE
where row_num > 1
order by propertyaddress


----------------------------------------------------------------------------------------------------------------
-- delete unused columns


Select *
From PortfolioProject..NashvilleHousing


Alter Table PortfolioProject..NashvilleHousing
Drop Column OwnerAddress, TaxDistrict, PropertyAddress

Alter Table PortfolioProject..NashvilleHousing
Drop Column SaleDate