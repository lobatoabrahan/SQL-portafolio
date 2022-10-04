/*Muestra la probabilidad de morir en todos los paises si contraes covid*/
select location, (sum(total_deaths)/sum(total_cases))*100 as porcentaje_mortalidad
from covid_deaths
where total_deaths is not NULL
group by location
order by porcentaje_mortalidad desc

-- Muestra la probabilidad de morir si contrae covid en su pais
select location, date, total_cases, total_deaths, (total_deaths/total_cases)*100 as porcentaje_mortalidad
from covid_deaths
where location = 'United States'

-- Muestra que porcentaje de poblacion esta infectada con covid
select location, population, (sum(total_cases)/sum(population))*100 as porcentaje_infectados
from covid_deaths
where total_cases is not null and population is not null
GROUP by location, population
order by porcentaje_infectados desc

-- Paises con la tasa de infeccion mas alta en comparacion con la poblacion
select location, population, max(total_cases) as mayor_infeccion, max((total_cases/population))*100 as porcentaje_infectados
from covid_deaths
where population is not null and total_cases is not null
group by location, population
order by mayor_infeccion desc

-- Paises con mayor recuento de muertes por paises
select location, max(cast(total_deaths as int)) as mayor_muertes_por_pais
from covid_deaths
where total_deaths is not null
group by location 
order by mayor_muertes_por_pais desc


-- Mostrar los continentes con el recuento de muertes mas alto
select continent, max(cast(total_deaths as int)) as mayor_muertes_por_continentes
from covid_deaths
where continent is not null
group by continent
order by mayor_muertes_por_continentes desc

-- Muestra el porcentaje de poblacion que ha recibido al menos una vacuna covid
select d.location, d.population, max(v.new_vaccinations) as total_vacunados, (sum(v.new_vaccinations)/sum(d.population))*100 as porcentaje_vacunados
from covid_deaths d
join covid_vaccunations v
	on d.location = v.location
where v.new_vaccinations is not null
group by d.location, d.population
order by porcentaje_vacunados desc

-- Muestra el porcentaje de poblacion que ha recibido al menos una vacuna covid segun la fecha
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date asc) as total_vacunados
from covid_deaths d
join covid_vaccunations v
	on d.location = v.location
	and d.date = v.date
where v.new_vaccinations is not null and d.continent is not null

-- Uso de CTE para mejorar la rapidez del calculo en la particion en la consulta anterior
with poblacionVSvacunas (continente, pais, fecha, poblacion, nuevas_vacunas, total_vacunados)
    as 
    (
        select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date asc) as total_vacunados
        from covid_deaths d
        join covid_vaccunations v
	        on d.location = v.location
	        and d.date = v.date
        where v.new_vaccinations is not null and d.continent is not null
        order by d.location, d.date asc
    )

select *, (total_vacunados/poblacion)*100 as porcentaje_vacunados
from poblacionVSvacunas

-- Usando una tabla temporal para realizar el calculo en la particion de la consulta anterior
drop table if exists porcentaje_poblacion_vacunada;
create table porcentaje_poblacion_vacunada (
	continentes varchar(50),
	pais varchar(50),
	fecha date,
	poblacion float,
	nuevas_vacunas float,
	total_vacunados float
)

insert into porcentaje_poblacion_vacunada
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date asc) as total_vacunados
from covid_deaths d
join covid_vaccunations v
	on d.location = v.location
	and d.date = v.date
where v.new_vaccinations is not null and d.continent is not null

select *, (total_vacunados/poblacion)*100 as porcentaje_vacunados
from porcentaje_poblacion_vacunada

-- Crear vista para almacenar datos para visualizaciones posteriores
create view porcentaje_poblacion_vacunados as
select d.continent, d.location, d.date, d.population, v.new_vaccinations, sum(v.new_vaccinations) over (partition by d.location order by d.location, d.date asc) as total_vacunados
from covid_deaths d
join covid_vaccunations v
	on d.location = v.location
	and d.date = v.date
where v.new_vaccinations is not null and d.continent is not null