from flask import Flask, render_template, request, send_file
from get_info import get_weather, get_name
import os
import json
from datetime import datetime

app = Flask(__name__)

HISTORY_FILE = 'search_history.json'

def save_search_history(city):
    history = []
    if os.path.exists(HISTORY_FILE):
        with open(HISTORY_FILE, 'r') as file:
            history = json.load(file)
    history.append({"city": city, "date": datetime.now().strftime('%Y-%m-%d %H:%M:%S')})
    with open(HISTORY_FILE, 'w') as file:
        json.dump(history, file, indent=4)

@app.route('/')
def get_city():
    button_color = os.getenv('BG_COLOR', '#007BFF')
    return render_template('welcome.html', error=None, button_color=button_color)

@app.route('/get_info')
def get_info():
    city = request.args.get('city')
    if city == 'georgie':
        return render_template('georgie_image.html')
    
    names = get_name(city)
    if names is None or names.get("results") is None:
        return render_template('welcome.html', error="The city was not found. Enter a city", button_color=None)
    
    data = get_weather(city)
    save_search_history(city)
    return render_template('show_weather.html', data=data, names=names, button_color=None)

@app.route('/history')
def history():
    if not os.path.exists(HISTORY_FILE):
        return render_template('history.html', history=[], error="No search history found.")
    with open(HISTORY_FILE, 'r') as file:
        history = json.load(file)
    return render_template('history.html', history=history, error=None)

@app.route('/download_history')
def download_history():
    if not os.path.exists(HISTORY_FILE):
        return "No history file found", 404
    return send_file(HISTORY_FILE, as_attachment=True)

if __name__ == "__main__":
    app.run(debug=True)
