select *
from PortofolioProject..NashvilleHousing

--Populate Property Address data

select* --PropertyAddress
from PortofolioProject..NashvilleHousing
order by ParcelID


select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress,isnull(a.PropertyAddress,b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
join PortofolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null


update a
set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
from PortofolioProject..NashvilleHousing a
join PortofolioProject..NashvilleHousing b
on a.ParcelID = b.ParcelID
and a.UniqueID != b.UniqueID
where a.PropertyAddress is null


--Breaking out Address into individual columns (Adress,City,State)

select PropertyAddress
from PortofolioProject..NashvilleHousing


SELECT 
    SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1) AS Address,
    SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress)) AS City
FROM 
    PortofolioProject..NashvilleHousing


alter table NashvilleHousing
add PropertySplitCity Nvarchar(255);

update NashvilleHousing
set PropertySplitCity = SUBSTRING(PropertyAddress, CHARINDEX(',', PropertyAddress) + 2, LEN(PropertyAddress))

alter table NashvilleHousing
add PropertySplitAddress Nvarchar(255);

update NashvilleHousing
set PropertySplitAddress = SUBSTRING(PropertyAddress, 1, CHARINDEX(',', PropertyAddress) - 1)

select *
from PortofolioProject..NashvilleHousing


--Similar outcome by using parsename for the column OwnerAddress

select
Parsename(replace(OwnerAddress,',','.'),3)
,Parsename(replace(OwnerAddress,',','.'),2)
,Parsename(replace(OwnerAddress,',','.'),1)
from PortofolioProject..NashvilleHousing



alter table NashvilleHousing
add OwnerSplitAddress Nvarchar(255)
update NashvilleHousing
set OwnerSplitAddress = Parsename(replace(OwnerAddress,',','.'),3)

alter table NashvilleHousing
add OwnerSplitCity Nvarchar(255)
update NashvilleHousing
set OwnerSplitCity = Parsename(replace(OwnerAddress,',','.'),2)

alter table NashvilleHousing
add OwnerSplitState Nvarchar(255)
update NashvilleHousing
set OwnerSplitState = Parsename(replace(OwnerAddress,',','.'),1)



--Remove duplicates

with RowNumCTE as(
select *,
ROW_NUMBER()over(
partition by ParcelID,
PropertyAddress,
SalePrice,
SaleDate,
LegalReference
order by UniqueID)
row_num


from PortofolioProject..NashvilleHousing
--order by ParcelID
)

delete
from RowNumCTE
where row_num >1
--order by PropertyAddress


--Delete Unused Columns

select *
from PortofolioProject..NashvilleHousing

alter table PortofolioProject..NashvilleHousing
drop column OwnerAddress, TaxDistrict, PropertyAddress


alter table PortofolioProject..NashvilleHousing
drop column SaleDate