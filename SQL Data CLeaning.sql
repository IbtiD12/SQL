/*Cleaning Data*/

Select SalesDateConverted from Project_Portfolio.dbo.Sheet1$

/*Standardize Date Format*/
select SaleDate, CONVERT(Date,SaleDate) From Project_Portfolio.dbo.Sheet1$

Update Sheet1$ Set SaleDate =CONVERT(Date,SaleDate)

ALTER TABLE Sheet1$ ADD SalesDateConverted Date;
Update Sheet1$ Set SalesDateConverted =CONVERT(Date,SaleDate)


---Populate poperty address---

Select PropertyAddress from Project_Portfolio.dbo.Sheet1$ where PropertyAddress is null

--Reference point to populate property address
Select * from Project_Portfolio.dbo.Sheet1$ order by ParcelID
--Found same parcelID with null value and adress value

Select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project_Portfolio.dbo.Sheet1$ as a
JOIN Project_Portfolio.dbo.Sheet1$ as b on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

-- need to use alias when updating and not Sheet1 orelse error
Update a 
Set PropertyAddress = ISNULL(a.PropertyAddress,b.PropertyAddress)
from Project_Portfolio.dbo.Sheet1$ as a
JOIN Project_Portfolio.dbo.Sheet1$ as b 
on a.ParcelID=b.ParcelID
and a.[UniqueID ]<>b.[UniqueID ]
where a.PropertyAddress is null

--Breaking out Adress into individual Coloumns(Address, City, State)

--finding where the , is
Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)) as Address,
CHARINDEX(',',PropertyAddress) -- index of comma
from Project_Portfolio.dbo.Sheet1$

-- starting at 1 up to comma-1
--starting at comma+1 to city/state

Select 
SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress)) as Address
from Project_Portfolio.dbo.Sheet1$

---Making the change in Table
ALTER TABLE Sheet1$
ADD PropertySplitAddress nvarchar(255);
Update Sheet1$ 
Set PropertySplitAddress =SUBSTRING(PropertyAddress, 1, CHARINDEX (',',PropertyAddress)-1)

ALTER TABLE Sheet1$
ADD PropertySplitCity nvarchar(255);
Update Sheet1$ 
Set PropertySplitCity =SUBSTRING(PropertyAddress, CHARINDEX (',',PropertyAddress)+1, LEN(PropertyAddress))

--OwnerAddress splits
--Parsename does things backwards
Select 
PARSENAME(Replace(OwnerAddress,',','.'),3),
PARSENAME(Replace(OwnerAddress,',','.'),2),
PARSENAME(Replace(OwnerAddress,',','.'),1)from Project_Portfolio.dbo.Sheet1$

---Making the change in Table
ALTER TABLE Sheet1$
ADD OwnerSplitAddress nvarchar(255);
Update Sheet1$ 
Set OwnerSplitAddress =PARSENAME(Replace(OwnerAddress,',','.'),3)

ALTER TABLE Sheet1$
ADD OwnerSplitCity nvarchar(255);
Update Sheet1$ 
Set OwnerSplitCity =PARSENAME(Replace(OwnerAddress,',','.'),2)

ALTER TABLE Sheet1$
ADD OwnerSplitState nvarchar(255);
Update Sheet1$ 
Set OwnerSplitState =PARSENAME(Replace(OwnerAddress,',','.'),1)

--Sold as Vacant, make Y and N to Yes and No

Select Distinct(SoldAsVacant), COUNT(SoldAsVacant)
From Project_Portfolio.dbo.Sheet1$
Group by SoldAsVacant
order by 2

Select SoldAsVacant
, CASE When SoldAsVacant= 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END
From Project_Portfolio.dbo.Sheet1$

Update Sheet1$ 
Set SoldAsVacant =CASE When SoldAsVacant= 'Y' THEN 'Yes'
		when SoldAsVacant = 'N' THEN 'No'
		ELSE SoldAsVacant
		END

---Remove Duplicates
--(Deleting rows only for practice, in actual work deletion from database is not recommended)
--Partitioning over things that are unique to each row
--creating a CTE
With RowNumCTE AS(
select *, 
ROW_NUMBER() Over (
Partition by ParcelID,
PropertyAddress,
SalePrice, 
SaleDate,
LegalReference
Order by ParcelID) row_num
From Project_Portfolio.dbo.Sheet1$)
DELETE From RowNumCTE
Where row_num>1
--Order by PropertyAddress

With RowNumCTE AS(
select *, 
ROW_NUMBER() Over (
Partition by ParcelID,
PropertyAddress,
SalePrice, 
SaleDate,
LegalReference
Order by ParcelID) row_num
From Project_Portfolio.dbo.Sheet1$)
Select * From RowNumCTE
Where row_num>1
Order by PropertyAddress

--Delete Unused Coloumn (Not to be done on raw data)

Select * From Project_Portfolio.dbo.Sheet1$

ALTER TABLE Project_Portfolio.dbo.Sheet1$
Drop Column OwnerAddress,TaxDistrict, PropertyAddress

ALTER TABLE Project_Portfolio.dbo.Sheet1$
Drop Column SaleDate

