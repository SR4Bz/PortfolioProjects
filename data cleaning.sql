--Chagne/Ctandrize Data Format

Select *
From PortfoliloProject.dbo.NashvilleHousing

Select SaleDateConverted, CONVERT(date,SaleDate)
From PortfoliloProject.dbo.NashvilleHousing

update PortfoliloProject.dbo.NashvilleHousing
Set SaleDate = CONVERT(date,SaleDate)

Alter table PortfoliloProject.dbo.NashvilleHousing
Add SaleDateConverted Date;

update PortfoliloProject.dbo.NashvilleHousing
Set SaleDateConverted = CONVERT(date,SaleDate)


-- Populate columns that has NULL Data (In this example populate property adress data)

Select * 
From PortfoliloProject.dbo.NashvilleHousing
--Where PropertyAddress is null
order by ParcelID


Select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfoliloProject.dbo.NashvilleHousing a
Join PortfoliloProject.dbo.NashvilleHousing b on
a.ParcelID = b.ParcelID 
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 


update a
set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
From PortfoliloProject.dbo.NashvilleHousing a
Join PortfoliloProject.dbo.NashvilleHousing b on
a.ParcelID = b.ParcelID 
And a.[UniqueID ] <> b.[UniqueID ]
where a.PropertyAddress is null 

-- Breaking columns intro individual colmuns (in this example Adress into Adress, City, State)

Select PropertyAddress
From PortfoliloProject.dbo.NashvilleHousing


Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 ) AS Address,
SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress)) AS City
From PortfoliloProject.dbo.NashvilleHousing



Alter table NashvilleHousing
Add PropertyAddressOnly Nvarchar(255);

update PortfoliloProject.dbo.NashvilleHousing
Set PropertyAddressOnly = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1 )


Alter table NashvilleHousing
Add PropertyCityOnly Nvarchar(255);

update PortfoliloProject.dbo.NashvilleHousing
Set PropertyCityOnly = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 1, len(PropertyAddress))



Select *
From PortfoliloProject.dbo.NashvilleHousing

Select OwnerAddress
From PortfoliloProject.dbo.NashvilleHousing

Select 
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2),
PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)
From PortfoliloProject.dbo.NashvilleHousing

Alter table NashvilleHousing
Add OwnerAddressOnly Nvarchar(255);

update PortfoliloProject.dbo.NashvilleHousing
Set OwnerAddressOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 3)

Alter table NashvilleHousing
Add OwnerCityOnly Nvarchar(255);

update PortfoliloProject.dbo.NashvilleHousing
Set OwnerCityOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 2)

Alter table NashvilleHousing
Add OwnerStateOnly Nvarchar(255);

update PortfoliloProject.dbo.NashvilleHousing
Set OwnerStateOnly = PARSENAME(REPLACE(OwnerAddress, ',', '.'), 1)

Select *
From PortfoliloProject.dbo.NashvilleHousing



-- changing Y and N to Yes and No in 'SoldAsVacant' column


Select distinct(SoldAsVacant), COUNT(SoldAsVacant)
From PortfoliloProject.dbo.NashvilleHousing
group by SoldAsVacant
order by 2


Select SoldAsVacant
, CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant	
		END
From PortfoliloProject.dbo.NashvilleHousing

update PortfoliloProject.dbo.NashvilleHousing
Set SoldAsVacant = CASE When SoldAsVacant = 'Y' then 'Yes'
		When SoldAsVacant = 'N' then 'No'
		Else SoldAsVacant	
		END




-- Remove Duplicates (its not hleathy to remove data, insted we can put in in different table)


with RowNumCTE as(
Select *,
	ROW_NUMBER() over (
	PARTITION BY parcelID,
				propertyAddress,
				SalePrice,
				SaleDate,
				LegalReference
				Order by UniqueID
				) row_num
From PortfoliloProject.dbo.NashvilleHousing
--Order by ParcelID
)

--Delete
--From RowNumCTE
--where row_num > 1

Select *
From RowNumCTE
where row_num > 1


-- Delete Unused Columns

Select *
From PortfoliloProject.dbo.NashvilleHousing

Alter Table PortfoliloProject.dbo.NashvilleHousing
Drop Column OwnerAddress, PropertyAddress, TaxDistrict

Alter Table PortfoliloProject.dbo.NashvilleHousing
Drop Column SaleDate


