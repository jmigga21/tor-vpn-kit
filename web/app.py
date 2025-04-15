from flask import Flask, render_template, request, redirect, url_for, send_file
from dotenv import load_dotenv
import os
import qrcode
import subprocess

load_dotenv()

ADMIN_PASSWORD = os.getenv('ADMIN_PASSWORD')
app = Flask(__name__)

CONFIG_DIR = "configs"
os.makedirs(CONFIG_DIR, exist_ok=True)

def get_clients():
    return [f.split(".conf")[0] for f in os.listdir(CONFIG_DIR) if f.endswith(".conf")]

@app.route('/', methods=['GET', 'POST'])
def login():
    if request.method == 'POST':
        if request.form['password'] == ADMIN_PASSWORD:
            return redirect(url_for('dashboard'))
        else:
            return "❌ Неверный пароль", 401
    return render_template('login.html')

@app.route('/dashboard')
def dashboard():
    clients = get_clients()
    return render_template('dashboard.html', clients=clients)

@app.route('/client/<client>')
def client(client):
    conf_path = os.path.join(CONFIG_DIR, f"{client}.conf")
    if not os.path.exists(conf_path):
        return "❌ Конфиг не найден", 404
    with open(conf_path) as f:
        conf = f.read()
    qr = qrcode.make(conf)
    qr_path = os.path.join(CONFIG_DIR, f"{client}.png")
    qr.save(qr_path)
    return render_template("client.html", client=client, config=conf, qr_path=f"/qr/{client}.png")

@app.route('/download/<client>')
def download(client):
    return send_file(os.path.join(CONFIG_DIR, f"{client}.conf"), as_attachment=True)

@app.route('/qr/<filename>')
def qr(filename):
    return send_file(os.path.join(CONFIG_DIR, filename))

@app.route('/add', methods=['GET', 'POST'])
def add_client():
    if request.method == 'POST':
        name = request.form['client_name']
        subprocess.run(["bash", "../server/wireguard.sh", name])
        src = f"/etc/wireguard/{name}.conf"
        dst = os.path.join(CONFIG_DIR, f"{name}.conf")
        if os.path.exists(src):
            subprocess.run(["cp", src, dst])
        return redirect(url_for('dashboard'))
    return render_template('add_client.html')

if __name__ == '__main__':
    app.run(host="0.0.0.0", port=8080)
