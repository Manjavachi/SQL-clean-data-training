/* Limpando dados em SQL Queries*/


SELECT *
FROM PortifolioProject.dbo.NashvilleHousing
--------------------
-- Ajustando Formato de data


ALTER TABLE NashVilleHousing
ADD SaleDateConverted DATE;

UPDATE NashvilleHousing
SET SaleDateConverted = CONVERT(DATE,SaleDate)

SELECT SaleDateConverted, CONVERT(DATE,SaleDate)
FROM PortifolioProject.dbo.NashvilleHousing


--------------------
-- Povoando o endereço do proprietário

SELECT *
FROM PortifolioProject.dbo.NashvilleHousing
order by ParcelID

-- ISNULL avalia elementos de uma certa coluna se são nulos e substitui pelo valor indicado, pode ser uma string ou valor de uma outra celula

SELECT a.ParcelID, a.PropertyAddress, b.ParcelID, b.PropertyAddress, ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortifolioProject.dbo.NashvilleHousing a
JOIN PortifolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

UPDATE a
SET PropertyAddress = ISNULL(a.PropertyAddress, b.PropertyAddress)
FROM PortifolioProject.dbo.NashvilleHousing a
JOIN PortifolioProject.dbo.NashvilleHousing b
	ON a.ParcelID = b.ParcelID
	AND a.[UniqueID ]<>b.[UniqueID ]
WHERE a.PropertyAddress is null

--------------------
-- Quebrando o enderedo do proprietário

SELECT PropertyAddress
FROM PortifolioProject.dbo.NashvilleHousing

--SUBSTRING Avalia os elementos da coluna, começando em uma posicao qualquer, até chegar em uma certa posicao

SELECT
SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1) as Address,
SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress)) as City
FROM PortifolioProject.dbo.NashvilleHousing

ALTER TABLE NashVilleHousing
ADD City Nvarchar(255);

UPDATE NashvilleHousing
SET City = SUBSTRING(PropertyAddress,CHARINDEX(',',PropertyAddress)+1,LEN(PropertyAddress))

ALTER TABLE NashVilleHousing
ADD SplitAddress Nvarchar(255);

UPDATE NashvilleHousing
SET SplitAddress = SUBSTRING(PropertyAddress,1,CHARINDEX(',',PropertyAddress)-1)

SELECT *
FROM NashvilleHousing

-- Outra forma de fazer isso é utilizando o PARSENAME, esse método olha os valores de trás para frente e procura pontos como divisores.
-- é necessário mudar as virgulas por pontos para o PARSENAME funcionar.
SELECT
PARSENAME(REPLACE(OwnerAddress,',','.'),3) as Address,
PARSENAME(REPLACE(OwnerAddress,',','.'),2) as City,
PARSENAME(REPLACE(OwnerAddress,',','.'),1) as State
FROM PortifolioProject.dbo.NashvilleHousing

ALTER TABLE NashVilleHousing
ADD SplitOwnerAddress Nvarchar(255);

UPDATE NashvilleHousing
SET SplitOwnerAddress = PARSENAME(REPLACE(OwnerAddress,',','.'),3)

ALTER TABLE NashVilleHousing
ADD SplitOwnerCity Nvarchar(255);

UPDATE NashvilleHousing
SET SplitOwnerCity = PARSENAME(REPLACE(OwnerAddress,',','.'),2)

ALTER TABLE NashVilleHousing
ADD SplitOwnerState Nvarchar(255);

UPDATE NashvilleHousing
SET SplitOwnerState = PARSENAME(REPLACE(OwnerAddress,',','.'),1)

SELECT *
from PortifolioProject.dbo.NashvilleHousing

------------------------------
-- Alterando a coluna 'SoldAsVacant'

SELECT Distinct(SoldAsVacant), Count(SoldAsVacant)
FROM PortifolioProject.dbo.NashvilleHousing
Group by SoldAsVacant
order by 2

--Resultado em 4 formas diferentes (sem um único padrão)

Select SoldAsVacant, 
	CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END
FROM PortifolioProject.dbo.NashvilleHousing

Update NashvilleHousing
SET SoldAsVacant = CASE WHEN SoldAsVacant = 'Y' THEN 'Yes'
		 WHEN SoldAsVacant = 'N' THEN 'No'
	ELSE SoldAsVacant
	END

-------------------------------------------------------------
-- Removendo duplicatas

WITH RowNumCTE AS(
SELECT *,
	ROW_NUMBER() OVER(
	PARTITION BY ParcelID,
				 PropertyAddress,
				 SalePrice,
				 SaleDate,
				 LegalReference
				 ORDER BY
					UniqueID) row_num
FROM PortifolioProject.dbo.NashvilleHousing
)
SELECT *
--DELETE
FROM RowNumCTE
Where row_num > 1
--Order by PropertyAddress


-------------------------------------------------------------
-- Removendo colunas não utilizadas

SELECT *
from PortifolioProject.dbo.NashvilleHousing

ALTER TABLE PortifolioProject.dbo.NashvilleHousing
DROP COLUMN OwnerAddress, PropertyAddress, TaxDistrict, SaleDate