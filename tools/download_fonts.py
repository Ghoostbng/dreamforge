import os
import requests

# URLs directes depuis Google Fonts CDN
fonts = {
    "Poppins-Regular": "https://fonts.googleapis.com/css2?family=Poppins&display=swap",
    "Poppins-Bold": "https://fonts.googleapis.com/css2?family=Poppins:wght@700&display=swap",
    "RobotoSlab-Regular": "https://fonts.googleapis.com/css2?family=Roboto+Slab&display=swap",
    "RobotoSlab-Bold": "https://fonts.googleapis.com/css2?family=Roboto+Slab:wght@700&display=swap",
    "NotoSans-Regular": "https://fonts.googleapis.com/css2?family=Noto+Sans&display=swap",
    "NotoSans-Bold": "https://fonts.googleapis.com/css2?family=Noto+Sans:wght@700&display=swap",
}

# Création du dossier assets/fonts
fonts_dir = os.path.join("assets", "fonts")
os.makedirs(fonts_dir, exist_ok=True)

print("📥 Téléchargement des polices via Google Fonts CDN...")

for name, url in fonts.items():
    try:
        # Obtenir le CSS qui contient l'URL de la police
        response = requests.get(url, headers={'User-Agent': 'Mozilla/5.0'})
        if response.status_code == 200:
            # Extraire l'URL de la police du CSS
            css_content = response.text
            font_url = None
            
            # Chercher l'URL de la police dans le CSS
            if 'url(' in css_content:
                start = css_content.find('url(') + 4
                end = css_content.find(')', start)
                font_url = css_content[start:end].strip('"\'')

            if font_url and font_url.startswith('http'):
                # Télécharger la police
                font_response = requests.get(font_url)
                if font_response.status_code == 200:
                    file_path = os.path.join(fonts_dir, name + ".ttf")
                    with open(file_path, "wb") as f:
                        f.write(font_response.content)
                    print(f"✅ {name}.ttf téléchargée")
                else:
                    print(f"❌ Erreur téléchargement police {name} (code: {font_response.status_code})")
            else:
                print(f"❌ Impossible d'extraire l'URL de police pour {name}")
        else:
            print(f"❌ Erreur téléchargement CSS {name} (code: {response.status_code})")
    except Exception as e:
        print(f"❌ Erreur lors du téléchargement de {name}: {str(e)}")

print("\n🎯 Téléchargement terminé")