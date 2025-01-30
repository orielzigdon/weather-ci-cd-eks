import requests
import time


def get_weather(city_name):
    url = f'https://weather.visualcrossing.com/VisualCrossingWebServices/rest/services/timeline/{city_name}/next7days?unitGroup=metric&elements=datetime%2Ctempmax%2Ctempmin%2Chumidity&include=days&key=WHFH3BH7G5K5KAKVDRCCTAKMT&contentType=json'

    response = requests.get(url)
    #print(response)
    if response.status_code == 200:
        return response.json()
    return None

def get_name(city_name):
    url = f"https://geocoding-api.open-meteo.com/v1/search?name={city_name}&count=1&language=en&format=json"

    names = requests.get(url)
    if names.status_code == 200:
        return names.json()
    return None




# def get_weather(city_name):
#     url = f'https://weatherapi-com.p.rapidapi.com/forecast.json?q={city_name}&days=7'
#     headers = {
#         "X-RapidAPI-Key": "58553f6e80mshca3e92d962b54a1p1a2b7bjsnd1cdb2cd48fb",
#         "X-RapidAPI-Host": "weatherapi-com.p.rapidapi.com"
#     }
#     params = {
#         "q": city_name,
#         "days":7
#     }
#
#     response = requests.get(url, headers=headers)
#     print(response)
#     if response.status_code == 200:
#         return response.json()
#     return None
#
#
# def get_coordinates(city_name):
#     base_url = 'https://nominatim.openstreetmap.org/search'
#     params = {
#         'q': city_name,
#         'format': 'json',
#         'limit': 1
#     }

#     for attempt in range(3):  # Retry mechanism
#         try:
#             response = requests.get(base_url, params=params)
#             response.raise_for_status()  # Raise an HTTPError for bad responses
#             data = response.json()

#             if data:
#                 lat = data[0]['lat']
#                 lon = data[0]['lon']
#                 return lat, lon
#             else:
#                 return None, None
#         except requests.exceptions.RequestException as e:
#             print(f"Attempt {attempt + 1} failed: {e}")
#             time.sleep(2)  # Wait before retrying

#     return None, None
    

# def get_weather_forecast(lat, lon):
#     #maybe can get the humitidy
#     weather_url = 'https://api.open-meteo.com/v1/forecast'
#     params = {
#         'latitude': lat,
#         'longitude': lon,
#         'daily': 'temperature_2m_max,temperature_2m_min',
#         'timezone': 'auto'
#     }
    
#     response = requests.get(weather_url, params=params)
#     return response.json()

