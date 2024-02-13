/*

Data Cleaning in SQL

*/

Select *
From [Project 2].dbo.NashvilleHousing

--Standardize Date Format

Select SaleDateConverted, CONVERT(Date,SaleDate)
From [Project 2].dbo.NashvilleHousing

Update NashvilleHousing
Set SaleDate = CONVERT(Date,SaleDate)

Alter Table NashvilleHousing
Add SaleDateConverted Date;

Update NashvilleHousing
Set SaleDateConverted = CONVERT(Date,SaleDate)




-- Populate Property Address Data

Select PropertyAddress
From [Project 2].dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Project 2].dbo.NashvilleHousing a
Join [Project 2].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null


Update a
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From [Project 2].dbo.NashvilleHousing a
Join [Project 2].dbo.NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
Where a.PropertyAddress is null



-- Breaking out Address into Indivdaul Columns (Address, City, State)

Select PropertyAddress
From [Project 2].dbo.NashvilleHousing


Select
SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1) as Address
, SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress)) as City
From [Project 2].dbo.NashvilleHousing

Alter Table NashvilleHousing
Add PropertySplitAddress Nvarchar(255);

Update NashvilleHousing
Set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',',PropertyAddress)-1)

Alter Table NashvilleHousing
Add PropertySplitCity Nvarchar(255);

Update NashvilleHousing
Set PropertySplitCity = SUBSTRING (PropertyAddress, CHARINDEX(',',PropertyAddress) + 1, LEN(PropertyAddress))


Select *
From [Project 2].dbo.NashvilleHousing


Select OwnerAddress
From [Project 2].dbo.NashvilleHousing

Select
PARSENAME(Replace(OwnerAddress,',','.') , 3)
,PARSENAME(Replace(OwnerAddress,',','.') , 2)
,PARSENAME(Replace(OwnerAddress,',','.') , 1)

From [Project 2].dbo.NashvilleHousing



Alter Table NashvilleHousing
Add OwnerSplitAddress Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitAddress = PARSENAME(Replace(OwnerAddress,',','.') , 3)


Alter Table NashvilleHousing
Add OwnerSplitCity Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitCity = PARSENAME(Replace(OwnerAddress,',','.') , 2)


Alter Table NashvilleHousing
Add OwnerSplitState Nvarchar(255);

Update NashvilleHousing
Set OwnerSplitState = PARSENAME(Replace(OwnerAddress,',','.') , 1)


-- Change Y and N in "Sold as Vacant" field

Select Distinct(SoldAsVacant), COUNT(SoldasVacant)
From [Project 2].dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End
From [Project 2].dbo.NashvilleHousing

Update NashvilleHousing
Set SoldAsVacant = Case When SoldAsVacant = 'Y' Then 'Yes'
       When SoldAsVacant = 'N' Then 'No'
	   Else SoldAsVacant
	   End


-- Find and Remove Duplicates

With RowNumCTE AS(
Select *,
   Row_Number() Over(
   Partition By ParcelID,
                PropertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order By
				  UniqueID
				  ) row_num
  
From [Project 2].dbo.NashvilleHousing
)
Select*
From RowNumCTE
Where row_num > 1


-- Delete Unused Columns


Select *
From [Project 2].dbo.NashvilleHousing

Alter Table [Project 2].dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, SaleDate