#Taller: Sergio rueda, Salome quintero 
import pandas as pd 
import numpy as np

df_cgsse = pd.read_csv("https://github.com/niconomist98/DataAnalyticsUQ/raw/refs/heads/main/Datos/GEIH2025/cgsse.CSV"
                       ,encoding="latin", sep= ";") 
df_ft = pd.read_csv("https://github.com/niconomist98/DataAnalyticsUQ/raw/refs/heads/main/Datos/GEIH2025/Fuerza%20de%20trabajo.CSV"
                       ,encoding="latin", sep= ";", low_memory=False) 
df_ocupado = pd.read_csv("https://github.com/niconomist98/DataAnalyticsUQ/raw/refs/heads/main/Datos/GEIH2025/Ocupados.CSV"
                       ,encoding="latin", sep= ";", low_memory=False) 
df_desocupados = pd.read_csv("https://github.com/niconomist98/DataAnalyticsUQ/raw/refs/heads/main/Datos/GEIH2025/No%20ocupados.CSV"
                       ,encoding="latin", sep= ";") 
pobcol = df_cgsse["FEX_C18"].sum()
print('Población total de colombia:', int(pobcol))
menores_12 = df_cgsse[df_cgsse['P6040']<15]['FEX_C18'].sum()
edad_trabajar = df_cgsse[df_cgsse['P6040']>=15]['FEX_C18'].sum() #PET


print('La poblacion total sin edad para trabajar es:',int(menores_12))
print('La poblacion total con edad para trabjar es:',int(edad_trabajar))

pea = df_ocupado["FEX_C18"].sum() + df_desocupados[df_desocupados['DSI']==1]["FEX_C18"].sum()
pei = df_ft[df_ft['FFT']==1]['FEX_C18'].sum()

print(f'La poblacion economicamente activa es:', int(pea))
print(f'La poblacion economicamente inactiva es:', int(pei))
TAO = (df_ocupado['FEX_C18'].sum() / edad_trabajar)

print(f'La tasa de ocupacion: {TAO:.2%}')
TAD = (df_desocupados[df_desocupados['DSI']==1]['FEX_C18'].sum() / pea)
print(f'La tasa de desempleo es {TAD:.2%}')
df_desocupados_ec = df_desocupados[(df_desocupados['DSI']==1) & (df_desocupados['DPTO']==63) | (df_desocupados['DPTO']==66) | (df_desocupados['DPTO']==17)]
PQRC = df_desocupados[(df_desocupados['DSI']==1) & (df_desocupados['DPTO']==63) | (df_desocupados['DPTO']==66) | (df_desocupados['DPTO']==17)]['FEX_C18'].sum()
print(f' POBLACION DEL QUINDIO, RISARALDA y CALDAS:',int(PQRC))

df_desocupados_genero_ec = pd.merge(df_desocupados_ec, df_cgsse[['DIRECTORIO','SECUENCIA_P','ORDEN','P3271']],
                       on=['DIRECTORIO','SECUENCIA_P','ORDEN'], how='left')

PHDO = df_desocupados_genero_ec[df_desocupados_genero_ec['P3271']==1]['FEX_C18'].sum()
PMDO = df_desocupados_genero_ec[df_desocupados_genero_ec['P3271']==2]['FEX_C18'].sum()
print(f' Hombres desempleados:',int(PHDO))
print(f' Mujeres desempleados:',int(PMDO))
#3
## Agrupar por Departamento y Sexo
grupo = df.groupby(["Departamento", "Sexo"])
tasa_desempleo = grupo.apply(lambda x: 1 - x["ocupado"].mean()).reset_index()
tasa_desempleo = grupo.apply(lambda x: 1 - x["ocupado"].mean()).reset_index()
tasa_desempleo.columns = ["Departamento", "Sexo", "Tasa de Desempleo"]

# Convertir la tasa a porcentaje
tasa_desempleo["Tasa de Desempleo"] = tasa_desempleo["Tasa de Desempleo"] * 100

# Mostrar resultados ordenados
print(tasa_desempleo.sort_values(by="Tasa de Desempleo", ascending=False))



#4
# Cargar tu DataFrame
df3 = df_ft = pd.read_csv("https://github.com/niconomist98/DataAnalyticsUQ/raw/refs/heads/main/Datos/GEIH2025/Fuerza%20de%20trabajo.CSV"
                       ,encoding="latin", sep= ";", low_memory=False) 

# Limpiar columnas si es necesario
df3.columns = df3.columns.str.strip().str.lower()

# Filtrar solo personas en la fuerza laboral
df_laboral = df3[df3["fuerza_laboral"] == 1]

# Definir grupos de edad
def clasificar_edad(edad):
    if 18 <= edad < 24:
        return "18-24"
    elif 24 <= edad < 30:
        return "24-30"
    elif 30 <= edad < 40:
        return "30-40"
    elif 40 <= edad < 50:
        return "40-50"
    elif edad >= 60:
        return "60+"
    else:
        return "Fuera de rango"

df_laboral["grupo_edad"] = df_laboral["edad"].apply(clasificar_edad)

# Agrupar por departamento y grupo de edad
grupo = df_laboral.groupby(["departamento", "grupo_edad"])

# Calcular tasa de desempleo
tasa_desempleo = grupo.apply(lambda x: 1 - x["ocupado"].mean()).reset_index()
tasa_desempleo.columns = ["Departamento", "Grupo de Edad", "Tasa de Desempleo"]
tasa_desempleo["Tasa de Desempleo"] *= 100

# Determinar grupo con mayor y menor desempleo por departamento
def resumen_por_departamento(grupo):
    grupo_max = grupo.loc[grupo["Tasa de Desempleo"].idxmax()]
    grupo_min = grupo.loc[grupo["Tasa de Desempleo"].idxmin()]
    return pd.Series({
        "grupo_mayor_desempleo": grupo_max["Grupo de Edad"],
        "tasa_mayor_desempleo": grupo_max["Tasa de Desempleo"],
        "grupo_menor_desempleo": grupo_min["Grupo de Edad"],
        "tasa_menor_desempleo": grupo_min["Tasa de Desempleo"]
    })

resumen = tasa_desempleo.groupby("Departamento").apply(resumen_por_departamento).reset_index()

# Mostrar resultados
print(resumen.sort_values(by="tasa_mayor_desempleo", ascending=False))
