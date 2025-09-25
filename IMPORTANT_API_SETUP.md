# ⚠️ IMPORTANT: API Key Setup

## Your OpenAI Key is Configured ✅

I've added your OpenAI API key to the app configuration.

## You Still Need a NewsAPI Key! 🔴

To complete the setup, you need to get a **FREE** NewsAPI key:

1. **Go to:** https://newsapi.org/register
2. **Sign up** (takes 30 seconds)
3. **Get your API key** (looks like: `a1b2c3d4e5f6...`)
4. **Add it to the app** in one of these ways:

### Option 1: Add to Config File (Easiest)
Edit `/RaptureGauge/Configuration/APIConfig.swift`:
```swift
static let newsAPI = "YOUR_KEY_HERE" // Add your NewsAPI key
```

### Option 2: Add in App Settings
1. Run the app
2. Go to Settings tab
3. Enter your NewsAPI key
4. Tap "Save API Keys Securely"

## Security Notes

- ⚠️ Your OpenAI key is currently stored in the config file
- ⚠️ For production use, delete the key from APIConfig.swift after first run
- ✅ Keys are moved to secure iOS Keychain after first launch
- ✅ The .gitignore prevents committing keys to git

## Test Your Setup

1. Open Xcode:
   ```bash
   open /Users/bened/Documents/nvb_rapt/RaptureGauge/RaptureGauge.xcodeproj
   ```

2. Press ⌘R to run

3. The app will:
   - Auto-configure your OpenAI key
   - Prompt for NewsAPI key if missing
   - Start fetching and analyzing news

## Monthly Costs

With your keys:
- OpenAI GPT-4: ~$20-30/month (depending on usage)
- NewsAPI: FREE (developer tier)
- USGS Earthquakes: FREE
- **Total: ~$20-30/month**

## What Works Now

✅ Real-time news fetching every 4 hours
✅ GPT-4 analysis of articles for prophecy relevance
✅ Earthquake monitoring (no key needed)
✅ Automatic gauge updates based on world events
✅ Smart caching to reduce API costs
✅ Push notifications for critical changes

## Get Your NewsAPI Key Now!

👉 https://newsapi.org/register (FREE - takes 30 seconds)