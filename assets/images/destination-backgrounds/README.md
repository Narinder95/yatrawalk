# Destination Background Images

Add your destination-specific background images to this folder. The app expects the following image files:

## Required Images

1. **golden_temple.png**
   - Destination: Golden Temple, Amritsar, Punjab
   - Used in: Your Yatra card (Steps Screen & Home Screen)

2. **kedarnath.png**
   - Destination: Kedarnath, Uttarakhand
   - Used in: Your Yatra card (Steps Screen & Home Screen)

3. **vaishno_devi.png**
   - Destination: Vaishno Devi, Jammu
   - Used in: Your Yatra card (Steps Screen & Home Screen)

4. **tirupati_balaji.png**
   - Destination: Tirupati Balaji, Andhra Pradesh
   - Used in: Your Yatra card (Steps Screen & Home Screen)

5. **bodh_gaya.png**
   - Destination: Bodh Gaya, Bihar
   - Used in: Your Yatra card (Steps Screen & Home Screen)

6. **ajmer_sharif.png**
   - Destination: Ajmer Sharif, Rajasthan
   - Used in: Your Yatra card (Steps Screen & Home Screen)

7. **shirdi_sai_baba.png**
   - Destination: Shirdi Sai Baba, Maharashtra
   - Used in: Your Yatra card (Steps Screen & Home Screen)

## Image Requirements

- **Format**: PNG (supports transparency)
- **Dimensions**: Recommended 600x400px or similar aspect ratio
- **Size**: Keep under 500KB each for optimal performance
- **Content**: Beautiful, high-quality images of each destination or related spiritual/pilgrimage imagery

## How to Add Images

1. Copy your prepared images to this folder
2. Ensure filenames match exactly (case-sensitive on some systems):
   - `golden_temple.png`
   - `kedarnath.png`
   - `vaishno_devi.png`
   - `tirupati_balaji.png`
   - `bodh_gaya.png`
   - `ajmer_sharif.png`
   - `shirdi_sai_baba.png`

3. Run `flutter clean` and `flutter pub get`
4. Run the app - the images will automatically display on the Yatra cards!

## How It Works

When a user selects a destination to start a Yatra:
- The corresponding destination background image is stored with the journey
- The image displays on the "Your Yatra" card on the Steps Screen
- The same image also displays on the Home Screen hero animation
- Creates a cohesive, destination-specific visual experience
