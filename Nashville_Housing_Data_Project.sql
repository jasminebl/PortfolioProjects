/*

Cleaning Data in SQL queries

*/

-- Table Creation in PostgreSQL

create table nashville_housing_data (
		  uniqueid int
		, parcelid varchar (255)
		, landuse varchar (255)
		, propertyaddress varchar (255)
		, saledate date
		, saleprice varchar (255)
		, legalreference varchar (255)
		, soldasvacant varchar (255)
		, ownername varchar (255)
		, owneraddress varchar (255)
		, acreage decimal
		, taxdistrict varchar (255)
		, landvalue int
		, buildingvalue int
		, totalvalue int
		, yearbuilt int
		, bedrooms int
		, fullbath int
		, halfbath int
);

select * from nashville_housing_data


-- Standardize Date Format

select saledate 
from nashville_housing_data

-- Raw data has, date in date/time format. Setting the table code as date allowed for it be corrected before hand. 


--Populate Property Address data

select *
	from nashville_housing_data
	--where propertyaddress is null 
		order by parcelid

select a.parcelid , a.propertyaddress, b.parcelid, b.propertyaddress, coalesce(a.propertyaddress, b.propertyaddress)
	from nashville_housing_data a
	join nashville_housing_data b
		on a.parcelid = b.parcelid
		and a.uniqueid <> b.uniqueid
	where a.propertyaddress is null
	

update nashville_housing_data a
set propertyaddress = coalesce(a.propertyaddress, b.propertyaddress)
	from nashville_housing_data b
	where a.parcelid = b.parcelid
	  and a.uniqueid <> b.uniqueid
	  and a.propertyaddress is null;
							   						   
							   
-- Breaking out Address into Individual Columns (Address, City, State)							   


select propertyaddress
from nashville_housing_data
--where propertyaddress is null 
--order by parcelid
							   
select 
substring(propertyaddress, 1, position(',' in propertyaddress) -1) as address
 , substring(propertyaddress, position(',' in propertyaddress) +1 , length(propertyaddress)) as address
from nashville_housing_data							   
							   
Alter table nashville_housing_data
add propertysplitaddress varchar(255)
							   
Update 	nashville_housing_data
set propertysplitaddress = substring(propertyaddress, 1, position(',' in propertyaddress) -1)
	
							   
Alter table nashville_housing_data
add propertysplitcity varchar(255);
							   
Update 	nashville_housing_data
set propertysplitcity =	substring(propertyaddress, position(',' in propertyaddress) +1 , length(propertyaddress))					   
							   
select * 
from nashville_housing_data
							   
							   

select owneraddress 
from nashville_housing_data
							   
					   
select 
    coalesce(replace(split_part(owneraddress, ',', 1), ',', '.'), '') 
    ,coalesce(replace(split_part(owneraddress, ',', 2), ',', '.'), '') 
    ,coalesce(replace(split_part(owneraddress, ',', 3), ',', '.'), '') 
from 
    nashville_housing_data;
	


Alter table nashville_housing_data
add ownersplitaddress varchar(255);
							   
Update 	nashville_housing_data
set ownersplitaddress =	coalesce(replace(split_part(owneraddress, ',', 1), ',', '.'), '')					   
							   

Alter table nashville_housing_data
add ownersplitcity varchar(255);
							   
Update 	nashville_housing_data
set ownersplitcity = coalesce(replace(split_part(owneraddress, ',', 2), ',', '.'), '')


Alter table nashville_housing_data
add ownersplitstate varchar(255);
							   
Update 	nashville_housing_data
set ownersplitstate =	coalesce(replace(split_part(owneraddress, ',', 3), ',', '.'), '')

select * 
from nashville_housing_data


-- change Y and N to Yes and No in "Sold as Vacant" field 

select distinct(soldasvacant), count (soldasvacant) 
from nashville_housing_data
group by soldasvacant
order by 2

select soldasvacant 
	, CASE When soldasvacant = 'Y' Then 'Yes' 
		   When soldasvacant = 'N' Then 'No'
		   ELSE soldasvacant
		   END
from nashville_housing_data


Update 	nashville_housing_data
set soldasvacant = CASE When soldasvacant = 'Y' Then 'Yes' 
		   When soldasvacant = 'N' Then 'No'
		   ELSE soldasvacant
		   END




--Remove Duplicates 
 --(Not standard practice to delete data, for project purposes only)


WITH RowNumCTE AS(
select *, 
	row_number() over (
	partition by parcelid,
				propertyaddress,
				saleprice,
		        saledate,
		        legalreference
		        order by
					uniqueid
					) row_number
		
from nashville_housing_data
order by parcelid
)
select * 
from RowNumCTE
where row_number > 1
order by propertyaddress




WITH RowNumCTE as (
    select 
        *,
        row_number() over (
            partition by 
                parcelid,
                propertyaddress,
                saleprice,
                saledate,
                legalreference
            order by 
                uniqueid
        ) as row_number
    from 
        nashville_housing_data
)
delete from nashville_housing_data
using rownumcte
where 
    nashville_housing_data.uniqueid = rownumcte.uniqueid
    and rownumcte.row_number > 1



--delete unused columns


select *
from nashville_housing_data


alter table nashville_housing_data
drop column owneraddress,
drop column taxdistrict,
drop column propertyaddress













	