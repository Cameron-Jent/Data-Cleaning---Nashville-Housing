------------------------------------------------------------------------------------------------------------
/* Standardize Date Format */

--SaleDate is currently date time
select SaleDate, CONVERT(date, SaleDate)
from [Personal Projects].dbo.NashvilleHousing;

--Create Converted SaleDate field in the table
alter table [Personal Projects].dbo.NashvilleHousing
add SaleDateConverted date;

--Set the Converted SaleDate to date format
update [Personal Projects].dbo.NashvilleHousing
set SaleDateConverted = CONVERT(date, SaleDate);
------------------------------------------------------------------------------------------------------------
/* Populate Property Address field*/

--See records with null PropertyAddress
select *
from [Personal Projects].dbo.NashvilleHousing
where PropertyAddress is null;

--Order all records by ParcelID to see that records with the same ParcelID share the same address
select *
from [Personal Projects].dbo.NashvilleHousing
order by ParcelID;

--Self join to view records where ParcelIDs match with null and populated PropertyAddress values
select a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress) as FillAddress
from [Personal Projects].dbo.NashvilleHousing a
join [Personal Projects].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null;

--Update table and populate null PropertyAddresses where null
update a
set PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
from [Personal Projects].dbo.NashvilleHousing a
join [Personal Projects].dbo.NashvilleHousing b
	on a.ParcelID = b.ParcelID
	and a.[UniqueID ] != b.[UniqueID ]
where a.PropertyAddress is null;

--Check to make sure there are no records with null PropertyAddress 
select *
from [Personal Projects].dbo.NashvilleHousing
where PropertyAddress is null;
------------------------------------------------------------------------------------------------------------
/* Separate Address into Address, City, State fields*/

--SUBSTRING to extract just the street address, use charindex to separate on ','
--SUBSTRING -1 to remove the comma in StreetAddress
--SUBSTRING to extract City value after the comma
select SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1) as PropStAddress,
	SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress)) as PropCity
from [Personal Projects].dbo.NashvilleHousing

--Update table with separate address fields
alter table [Personal Projects].dbo.NashvilleHousing
add PropStAddress nvarchar(255);
update [Personal Projects].dbo.NashvilleHousing
set PropStAddress = SUBSTRING(PropertyAddress, 1, charindex(',', PropertyAddress) -1);

alter table [Personal Projects].dbo.NashvilleHousing
add PropCity nvarchar(255);
update [Personal Projects].dbo.NashvilleHousing
set PropCity = SUBSTRING(PropertyAddress, charindex(',', PropertyAddress) +1, LEN(PropertyAddress));


/* Separate OwnerAddress field */
--Verify that parsename extracts correct value
select PARSENAME(replace(OwnerAddress, ',', '.'), 3) as OwnerStAddress,
	PARSENAME(replace(OwnerAddress, ',', '.'), 2) as OwnerCity,
	PARSENAME(replace(OwnerAddress, ',', '.'), 1) as OwnerState
from [Personal Projects].dbo.NashvilleHousing;

--Add OwnerStAddress
alter table [Personal Projects].dbo.NashvilleHousing
add OwnerStAddress nvarchar(255);
update [Personal Projects].dbo.NashvilleHousing
set OwnerStAddress = PARSENAME(replace(OwnerAddress, ',', '.'), 3);

--Add OwnerCity
alter table [Personal Projects].dbo.NashvilleHousing
add OwnerCity nvarchar(255);
update [Personal Projects].dbo.NashvilleHousing
set OwnerCity = PARSENAME(replace(OwnerAddress, ',', '.'), 2);

--Add OwnerCity
alter table [Personal Projects].dbo.NashvilleHousing
add OwnerState nvarchar(255);
update [Personal Projects].dbo.NashvilleHousing
set OwnerState = PARSENAME(replace(OwnerAddress, ',', '.'), 1);
------------------------------------------------------------------------------------------------------------
/* Standardize SoldAsVacant Values to Yes and No */

--See counts of Y and N values
select distinct(SoldAsVacant), count(SoldAsVacant)
from [Personal Projects].dbo.NashvilleHousing
group by SoldAsVacant
order by 2;

--Case statement to view accurate updates
select SoldAsVacant,
	case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
	end
from [Personal Projects].dbo.NashvilleHousing

--Update values in table using the above case statements
update [Personal Projects].dbo.NashvilleHousing
set SoldAsVacant = case when SoldAsVacant = 'Y' then 'Yes'
		when SoldAsVacant = 'N' then 'No'
		else SoldAsVacant
		end
------------------------------------------------------------------------------------------------------------