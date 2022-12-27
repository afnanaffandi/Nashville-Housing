#Cleaning Data in SQL Queries

--Check The Data
select *
From [SQL Data Cleaning]

--Standardize Date Format for sale date column from datetime to date
select SaleDate, CONVERT (Date,SaleDate)
From [SQL Data Cleaning]

Alter Table [SQL Data Cleaning]
Add SaleDateConverted Date

Update [SQL Data Cleaning]
Set SaleDateConverted = CONVERT (Date,SaleDate)

--Populate Property Address (some of the propertyaddress got some null, some of the  propertyadress has double with different unique id)
select *
From [SQL Data Cleaning]
order by  ParcelID

select a.ParcelID,a.PropertyAddress,b.ParcelID,b.PropertyAddress, isnull(a.PropertyAddress,b.PropertyAddress)
From [SQL Data Cleaning] a
Join [SQL Data Cleaning] b
 On a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null

 update a
 Set PropertyAddress = isnull(a.PropertyAddress,b.PropertyAddress)
 From [SQL Data Cleaning] a
Join [SQL Data Cleaning] b
 On a.ParcelID = b.ParcelID
 and a.[UniqueID ] <> b.[UniqueID ]
 Where a.PropertyAddress is null 


 --Break out the adress into individual column  (adress,city,state) for proeprty address & owner address
 Select 
SUBSTRING(PropertyAddress,1,CHARINDEX(',' ,PropertyAddress) -1 )  as Address , 
SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress) +1 , LEN (PropertyAddress))  as City
 From [SQL Data Cleaning]

 Alter Table [SQL Data Cleaning]
Add PropertiesAddress Nvarchar(255)

Update [SQL Data Cleaning]
Set PropertiesAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',' ,PropertyAddress) -1 )

 Alter Table [SQL Data Cleaning]
Add PropertiesCity Nvarchar(255)

Update [SQL Data Cleaning]
Set PropertiesCity =SUBSTRING(PropertyAddress,CHARINDEX(',' ,PropertyAddress) +1 , LEN (PropertyAddress))

Select *
From [SQL Data Cleaning]

--For the owner address also repeat the same step but instead using substring, just use parsename

exec sp_rename '[SQL Data Cleaning].OwnerAddress' , 'FullOwnerAdress','column';

select
PARSENAME(Replace(FullOwnerAdress,',' ,'.'),3 ) 
,PARSENAME(Replace(FullOwnerAdress, ',','.'),2 )
,PARSENAME(Replace(FullOwnerAdress, ',','.'),1 )
From [SQL Data Cleaning]

 Alter Table [SQL Data Cleaning]
Add OwnerAddress Nvarchar(255)

Update [SQL Data Cleaning]
Set OwnerAddress =PARSENAME (Replace (FullOwnerAdress, ',' , '.') ,3 )

 Alter Table [SQL Data Cleaning]
Add OwnerCity Nvarchar(255)

Update [SQL Data Cleaning]
Set OwnerCity =PARSENAME (Replace (FullOwnerAdress, ',' , '.') ,2 )

 Alter Table [SQL Data Cleaning]
Add OwnerState Nvarchar(255)

Update [SQL Data Cleaning]
Set OwnerState =PARSENAME (Replace (FullOwnerAdress, ',' , '.') ,1 )

--change Y & N to Yes and No on column SoldAsVacant
Select Distinct SoldAsVacant
From [SQL Data Cleaning]
Order By SoldAsVacant

Select SoldAsVacant, 
Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End
From [SQL Data Cleaning]

Update [SQL Data Cleaning]
Set SoldAsVacant = Case When SoldAsVacant = 'Y' then 'Yes'
     When SoldAsVacant = 'N' then 'No'
	 Else SoldAsVacant
	 End

--Remove Duplicates

With RowNumCte As(                 --To check how many Duplicates in the table
Select *,
       ROW_NUMBER() Over (
       Partition By ParcelID,
                    PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By
					  UniqueID
					  ) row_num
From [SQL Data Cleaning]
)
Select *
From RowNumCte
Where row_num > 1 
order by PropertyAddress

With RowNumCte As(                  --Delete the duplicate column
Select *,
       ROW_NUMBER() Over (
       Partition By ParcelID,
                    PropertyAddress,
					SalePrice,
					SaleDate,
					LegalReference
					Order By
					  UniqueID
					  ) row_num
From [SQL Data Cleaning]
)
Delete               
From RowNumCte
Where row_num > 1 


--Delete Unused Column
Select *
From  [SQL Data Cleaning]

Alter Table [SQL Data Cleaning]
Drop Column PropertyAddress,FullOwnerAdress